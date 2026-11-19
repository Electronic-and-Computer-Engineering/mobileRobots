function ok = check_car_primitives()
%CHECK_CAR_PRIMITIVES  Test your formula against the simulator.
%
%   check_car_primitives
%   ok = check_car_primitives()
%
%   Your CAR_PRIMITIVES computes the five arcs from the bicycle model.
%   CC_PRIMITIVES_PROBE measures the same five arcs by driving CC_STEP.
%   Neither one knows about the other. If they agree, the model in your
%   head and the model in the simulator are the same model.
%
%   Four things are checked:
%
%     1 shape       every arc against the measured one, to 1 mm
%     2 geometry    the chord can never be longer than the arc
%     3 symmetry    +22 deg and -22 deg must mirror each other
%     4 the lattice full lock must turn exactly one heading step
%
%   See also CAR_PRIMITIVES, CC_PRIMITIVES_PROBE, CC_CAR_MODEL.

P = cc_params();

try
    prim = car_primitives(P);
catch err
    if strcmp(err.identifier, 'task:todo')
        fprintf('\n  tasks/car_primitives.m is still the skeleton.\n');
        fprintf('  Work through ANLEITUNGEN/08_vehicle_neighbors.md first.\n\n');
        ok = false;
        return
    end
    fprintf('\n  car_primitives failed: %s\n\n', err.message);
    ok = false;
    return
end

ref = cc_primitives_probe(P);

fprintf('\n');
problems = {};

if ~isstruct(prim) || numel(prim) ~= numel(ref)
    fprintf('  FAIL  got %d primitives, expected %d\n\n', numel(prim), numel(ref));
    ok = false;
    return
end

% ---- 1 and 2 ----------------------------------------------------------
fprintf('  %-4s %-9s %-11s %-11s %-11s %s\n', ...
    '', 'steering', 'dx [m]', 'dy [m]', 'dtheta', 'arc / chord');
nGood = 0;
for k = 1:numel(prim)
    dxErr  = prim(k).dx  - ref(k).dx;
    dyErr  = prim(k).dy  - ref(k).dy;
    dthErr = prim(k).dth - ref(k).dth;
    chord  = hypot(prim(k).dx, prim(k).dy);

    good = abs(dxErr) < 1e-3 && abs(dyErr) < 1e-3 && abs(dthErr) < deg2rad(0.1);
    if good
        nGood = nGood + 1;
        tag = 'ok  ';
    else
        tag = 'FAIL';
    end
    fprintf('  %-4s %+7.1f   %+9.5f   %+9.5f   %+8.3f deg   %.4f / %.4f\n', ...
        tag, prim(k).delta, prim(k).dx, prim(k).dy, rad2deg(prim(k).dth), ...
        prim(k).len, chord);

    if chord > prim(k).len + 1e-9
        problems{end+1} = 'chord';                      %#ok<AGROW>
    elseif prim(k).delta ~= 0 && abs(prim(k).dth) < 1e-9
        problems{end+1} = 'straight';                   %#ok<AGROW>
    elseif ~good && abs(dthErr) > deg2rad(0.1)
        problems{end+1} = 'turn';                       %#ok<AGROW>
    elseif ~good
        problems{end+1} = 'beta';                       %#ok<AGROW>
    end
end

% ---- 3) symmetry ------------------------------------------------------
sym = true;
for k = 1:numel(prim)
    m = find(abs([prim.delta] + prim(k).delta) < 1e-9, 1);
    if isempty(m), continue, end
    if abs(prim(k).dx - prim(m).dx) > 1e-6 || ...
            abs(prim(k).dy + prim(m).dy) > 1e-6 || ...
            abs(prim(k).dth + prim(m).dth) > 1e-9
        sym = false;
    end
end
fprintf('\n  %-4s left and right mirror each other\n', local_tag(sym));
if ~sym, problems{end+1} = 'beta'; end

% ---- 4) the lattice ---------------------------------------------------
[~, iMax] = max(abs([prim.delta]));
oneBin = 2*pi / P.nTheta;
onBin  = abs(abs(prim(iMax).dth) - oneBin) < 0.02 * oneBin;
fprintf('  %-4s full lock turns exactly one heading step (%.2f of %.2f deg)\n', ...
    local_tag(onBin), rad2deg(abs(prim(iMax).dth)), rad2deg(oneBin));
if ~onBin, problems{end+1} = 'lattice'; end

% ---- the verdict ------------------------------------------------------
ok = (nGood == numel(prim)) && sym && onBin;
fprintf('\n');

if ok
    fprintf('  All green. Your formula and the simulator agree, so the\n');
    fprintf('  search will plan arcs the car can actually drive.\n');
    fprintf('  Next: tasks/car_neighbors.m, then check_car_neighbors.\n\n');
    return
end

fprintf('  What that most likely means:\n\n');
if any(strcmp(problems, 'straight'))
    fprintf('    A primitive with the steering turned ends up going\n');
    fprintf('    perfectly straight. dthdS is still zero: TODO 2.\n\n');
end
if any(strcmp(problems, 'turn'))
    fprintf('    The car turns by the WRONG AMOUNT, which means dthdS is\n');
    fprintf('    wrong. Two usual causes:\n');
    fprintf('      - beta left at zero. It appears in TODO 2 as well as\n');
    fprintf('        TODO 3: dthdS = cos(beta) * tan(d) / P.L. Dropping\n');
    fprintf('        it turns full lock by 22.96 instead of 22.50 deg and\n');
    fprintf('        misses the end of the arc by 23 mm.\n');
    fprintf('      - d in degrees instead of radians. deg2rad is already\n');
    fprintf('        applied for you at the top of the loop; use d, not\n');
    fprintf('        delta.\n\n');
end
if any(strcmp(problems, 'beta'))
    fprintf('    The arc turns by the RIGHT amount and still ends up in\n');
    fprintf('    the wrong place, so TODO 2 is fine and the integration\n');
    fprintf('    is not. Two usual causes:\n');
    fprintf('      - the `+ beta` missing inside the cos and sin of\n');
    fprintf('        TODO 3. The car travels at an angle to the way it\n');
    fprintf('        points, and that angle is beta.\n');
    fprintf('      - the heading at the START of the step used instead of\n');
    fprintf('        thMove. That bends every arc too late and misses by\n');
    fprintf('        about 5.8 mm at full lock.\n\n');
end
if any(strcmp(problems, 'chord'))
    fprintf('    The straight-line distance from start to end is LONGER\n');
    fprintf('    than the arc you say you drove. Along a curve that is\n');
    fprintf('    impossible. Your step length is probably P.arc instead\n');
    fprintf('    of ds = P.arc/nSub, so each arc is four times too long.\n\n');
end
if any(strcmp(problems, 'lattice')) && isempty(problems(~strcmp(problems,'lattice')))
    fprintf('    The arcs match the simulator but full lock does not land\n');
    fprintf('    on a heading step. Check that you used P.arc and did not\n');
    fprintf('    round it: 0.119 m is chosen so that full lock turns\n');
    fprintf('    exactly 360/P.nTheta degrees.\n\n');
end
end

% -----------------------------------------------------------------------
function s = local_tag(tf)
if tf, s = 'ok  '; else, s = 'FAIL'; end
end
