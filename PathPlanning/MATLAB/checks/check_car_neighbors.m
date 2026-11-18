function ok = check_car_neighbors()
%CHECK_CAR_NEIGHBORS  Test your tasks/car_neighbors.m and say what is wrong.
%
%   check_car_neighbors
%   ok = check_car_neighbors()
%
%   Eight poses on the practice track, chosen so that each one catches a
%   different mistake. If something is red, the message below the table
%   names the line to look at.
%
%   See also CAR_NEIGHBORS, CC_POSE_FREE, CC_CAR_MODEL.

P  = cc_params('Track', 'oval');
T  = cc_track(P);

try
    CM = cc_car_model(T, P);
catch err
    if any(strcmp(err.identifier, {'task:todo', 'cc_car_model:noPrimitives'}))
        fprintf('\n  tasks/car_primitives.m is still the skeleton, and the\n');
        fprintf('  neighbours are built out of those five moves -- so there is\n');
        fprintf('  nothing to test yet. Do step 5 of chapter 08 first, then\n');
        fprintf('  come back here.\n\n');
        ok = false;
        return
    end
    rethrow(err)
end

% Eight poses, each chosen to catch a different mistake. Cases 2 to 5
% and 7 fail if the primitive is not rotated; case 6 fails if only the
% end of the arc is tested. Case 1 passes either way -- which is exactly
% why it is first, and why passing it proves nothing.
cases = { ...
    [1.60 0.50 0],            'on the bottom straight, pointing along it'
    [1.60 0.50 pi],           'same place, pointing the other way'
    [2.90 1.00 pi/2],         'right-hand corner, pointing up'
    [0.30 1.00 -pi/2],        'left-hand corner, pointing down'
    [1.60 1.50 pi],           'top straight, going left'
    [0.85 1.35 deg2rad(179)], 'the arc clips the inner wall'
    [2.69 0.56 deg2rad(224)], 'only some of the moves are left'
    [1.60 0.50 pi/2],         'across the lane -- the car does not fit here'
};

fprintf('\n');
nGood   = 0;
nRun    = 0;
noRot   = 0;
endOnly = 0;

for k = 1:size(cases,1)
    pose = cases{k,1};
    name = cases{k,2};

    try
        [nb, w, poses] = car_neighbors(CM, pose);
    catch err
        if strcmp(err.identifier, 'task:todo')
            fprintf('  tasks/car_neighbors.m is still the skeleton.\n');
            fprintf('  Work through ANLEITUNGEN/08_vehicle_neighbors.md first.\n\n');
            ok = false;
            return
        end
        fprintf('  [%d] ERROR  %-44s %s\n', k, name, err.message);
        nRun = nRun + 1;
        continue
    end
    nRun = nRun + 1;

    [want, wantW, wantP] = local_reference(CM, pose);
    problems = local_compare(CM, pose, nb, w, poses, want, wantW, wantP);

    if isempty(problems)
        fprintf('  [%d] ok     %-44s %d of %d moves free\n', ...
            k, name, numel(nb), numel(CM.prim));
        nGood = nGood + 1;
    else
        fprintf('  [%d] FAIL   %-44s %d moves, want %d\n', ...
            k, name, numel(nb), numel(want));
        for q = 1:numel(problems)
            fprintf('             %s\n', problems{q});
            if strncmp(problems{q}, 'rot', 3),  noRot   = noRot + 1;   end
            if strncmp(problems{q}, 'arc', 3),  endOnly = endOnly + 1; end
        end
    end
end

fprintf('\n');
ok = (nGood == size(cases,1));

if ok
    fprintf('  All green. Now plan a lap on the practice track:\n');
    fprintf('      run(''experiments/experiment_oval_lap.m'')\n\n');
    return
end

fprintf('  What that most likely means:\n\n');
if noRot > 0
    fprintf('    The end pose is in the wrong place. Look at TODO 1. The\n');
    fprintf('    primitive is measured in the CAR''s frame, so BOTH dx and dy\n');
    fprintf('    have to be rotated by the car''s heading:\n');
    fprintf('        nx = x + pr.dx*cos(th) - pr.dy*sin(th)\n');
    fprintf('        ny = y + pr.dx*sin(th) + pr.dy*cos(th)\n');
    fprintf('    Note that case [1] passes even when this is wrong: with the\n');
    fprintf('    car pointing along +x, sin(th) is 0 and the error hides.\n\n');
end
if endOnly > 0
    fprintf('    Too many moves are being allowed. Look at TODO 2: the WHOLE\n');
    fprintf('    arc has to be clear, not only its end point. Walk over the\n');
    fprintf('    rows of pr.pts and call cc_pose_free on each of them.\n\n');
end
fprintf('    If the counts are right but the costs are 0: TODO 3, w(kept) = pr.cost.\n');
fprintf('    If nothing at all comes back: check that you did not leave\n');
fprintf('    ok = true without ever testing anything, and that nx, ny, nth\n');
fprintf('    are no longer just x, y, th.\n\n');
end

% -----------------------------------------------------------------------
function [nb, w, poses] = local_reference(CM, pose)
%LOCAL_REFERENCE  What the answer should be. Independent of the student file.
x = pose(1); y = pose(2); th = pose(3);
ct = cos(th); sn = sin(th);
nb = zeros(1,0); w = zeros(1,0); poses = zeros(0,3);
for k = 1:numel(CM.prim)
    pr = CM.prim(k);
    ok = true;
    for q = 1:size(pr.pts,1)
        px = x + pr.pts(q,1)*ct - pr.pts(q,2)*sn;
        py = y + pr.pts(q,1)*sn + pr.pts(q,2)*ct;
        if ~cc_pose_free(CM, px, py, th + pr.pts(q,3))
            ok = false;
            break
        end
    end
    if ~ok, continue, end
    nx  = x + pr.dx*ct - pr.dy*sn;
    ny  = y + pr.dx*sn + pr.dy*ct;
    nth = th + pr.dth;
    idx = cc_pose_index([nx ny nth], CM);
    if isempty(idx), continue, end
    nb(end+1)      = idx;              %#ok<AGROW>
    w(end+1)       = pr.cost;          %#ok<AGROW>
    poses(end+1,:) = [nx ny nth];      %#ok<AGROW>
end
end

% -----------------------------------------------------------------------
function problems = local_compare(CM, pose, nb, w, poses, want, wantW, wantP)
problems = {};

if numel(w) ~= numel(nb) || size(poses,1) ~= numel(nb)
    problems{end+1} = sprintf( ...
        'the three outputs have different lengths: %d, %d, %d', ...
        numel(nb), numel(w), size(poses,1));
    return
end

if numel(nb) ~= numel(want)
    if numel(nb) > numel(want)
        problems{end+1} = sprintf( ...
            'arc: %d moves allowed, only %d of them are actually clear', ...
            numel(nb), numel(want));
    else
        problems{end+1} = sprintf( ...
            'got %d moves, expected %d', numel(nb), numel(want));
    end
    return
end

if ~isempty(nb) && ~isequal(sort(nb(:).'), sort(want(:).'))
    % Did the student forget to rotate? Check against that specific error.
    bad = local_unrotated(CM, pose);
    if ~isempty(bad) && isequal(sort(nb(:).'), sort(bad(:).'))
        problems{end+1} = 'rot: the end poses match an UNROTATED primitive';
    else
        problems{end+1} = 'the node numbers are not the ones those moves lead to';
    end
end

if ~isempty(w) && any(w <= 0)
    problems{end+1} = 'some move costs 0 or less -- TODO 3, use pr.cost';
end

if ~isempty(poses) && size(poses,1) == size(wantP,1)
    d = max(max(abs(sort(poses,1) - sort(wantP,1))));
    if d > 1e-9
        problems{end+1} = sprintf('the returned poses are off by up to %.3f m', d);
    end
end
end

% -----------------------------------------------------------------------
function nb = local_unrotated(CM, pose)
%LOCAL_UNROTATED  The answer you get if you forget to turn the primitive.
x = pose(1); y = pose(2); th = pose(3);
ct = cos(th); sn = sin(th);
nb = zeros(1,0);
for k = 1:numel(CM.prim)
    pr = CM.prim(k);
    ok = true;
    for q = 1:size(pr.pts,1)
        px = x + pr.pts(q,1)*ct - pr.pts(q,2)*sn;
        py = y + pr.pts(q,1)*sn + pr.pts(q,2)*ct;
        if ~cc_pose_free(CM, px, py, th + pr.pts(q,3))
            ok = false;
            break
        end
    end
    if ~ok, continue, end
    idx = cc_pose_index([x + pr.dx, y + pr.dy, th + pr.dth], CM);
    if isempty(idx), continue, end
    nb(end+1) = idx;      %#ok<AGROW>
end
end
