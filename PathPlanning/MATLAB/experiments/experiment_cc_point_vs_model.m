%EXPERIMENT_CC_POINT_VS_MODEL  The same car, the same controller, two planners.
%
%   run('experiments/experiment_cc_point_vs_model.m')
%
%   This is the experiment the whole CrazyCar block exists for.
%
%   Nothing changes between the two runs except WHO PLANNED THE ROUTE.
%   Same track, same vehicle model, same controller, same gains, same
%   speed profile. One route is planned for a point; the other is
%   planned by the car itself.
%
%   See also CC_LAP_PLAN, ASTAR_CAR, SEARCH_STUDENT_GRID, CC_SIMULATE.

clc
P  = cc_params();
T  = cc_track(P);
CM = cc_car_model(T, P);

trace_on('off');

%% ---------- A: planned as a POINT, on the 5 cm grid -------------------
fprintf('\n=========== A: planned as a POINT (your A* on the grid) ===========\n\n');

goals  = [P.checkpoints; P.start(1), P.start(2)];
from   = cc_world2grid(P.start(1), P.start(2), T);
gridPath = [];
gridExp  = 0;
for k = 1:size(goals,1)
    to = cc_world2grid(goals(k,1), goals(k,2), T);
    [p, c, st] = search_student_grid(T.M, from, to, 'astar', 'Conn', 8);
    if isempty(p)
        error('No route for leg %d. Did check_my_code pass?', k);
    end
    if isempty(gridPath)
        gridPath = p;
    else
        gridPath = [gridPath, p(2:end)];      %#ok<AGROW>
    end
    gridExp = gridExp + st.expansions;
    from = to;
    fprintf('  leg %d: %3d cells, %5.2f m, %5d expansions\n', ...
        k, numel(p)-1, c*T.cellSize, st.expansions);
end
XYgrid = cc_path_to_world(gridPath, T);
XYgrid = cc_shortcut_path(XYgrid, T);            % even WITH smoothing
[vg, kg] = cc_speed_profile(XYgrid, P);
logA = cc_simulate(T, [XYgrid, vg]);

fprintf('\n  route %.2f m, %d expansions\n', ...
    sum(hypot(diff(XYgrid(:,1)), diff(XYgrid(:,2)))), gridExp);
local_report(logA, T);

%% ---------- B: planned by the CAR, over poses -------------------------
fprintf('\n=========== B: planned WITH the vehicle model (your astar_car) ===========\n\n');

[poses, info] = cc_lap_plan(CM);
XYcar = cc_resample_path(poses(:,1:2), 0.04);
[vc, kc] = cc_speed_profile(XYcar, P);
logB = cc_simulate(T, [XYcar, vc]);

fprintf('\n');
local_report(logB, T);

%% ---------- the two side by side --------------------------------------
figure('Name','Point planner against model planner','Position',[60 60 1120 900]);

subplot(2,1,1)
cc_plot_track(T, 'Route', XYgrid, 'Driven', logA, 'Cars', 20, ...
    'Title', 'A: planned as a POINT -- the body does not fit through its own route');

subplot(2,1,2)
cc_plot_track(T, 'Route', XYcar, 'Driven', logB, 'Cars', 26, ...
    'Title', sprintf('B: planned WITH the model -- lap in %.2f s', logB.lapTime));

fprintf('\n=========== What to take away ===========\n\n');
fprintf('  The point route is SHORTER (%.2f m against %.2f m).\n', ...
    sum(hypot(diff(XYgrid(:,1)), diff(XYgrid(:,2)))), ...
    sum(hypot(diff(XYcar(:,1)), diff(XYcar(:,2)))));
fprintf('  It is also collision-free -- for a point.\n');
fprintf('  The car is 22 by 10.5 cm and its corners swing out when it turns.\n');
fprintf('  Growing the walls by half the WIDTH does not pay for the LENGTH.\n\n');
fprintf('  The model planner never had the choice. A pose whose rectangle\n');
fprintf('  touches a wall is simply not a neighbour, so the search cannot\n');
fprintf('  pick it. The constraint lives in the search space, not in a\n');
fprintf('  repair step afterwards.\n\n');

%% -----------------------------------------------------------------------
function local_report(log, T) %#ok<INUSD>
if log.crashed
    fprintf('  RESULT: CRASHED at (%.2f, %.2f) after %.2f s\n', ...
        log.crashAt(1), log.crashAt(2), log.t(end));
    driven = sum(hypot(diff(log.x), diff(log.y)));
    fprintf('          got %.2f m round the lap before hitting a wall\n', driven);
elseif log.finished
    fprintf('  RESULT: lap completed in %.2f s\n', log.lapTime);
    fprintf('          top speed %.2f m/s, tyres at the limit in %d of %d steps\n', ...
        max(log.v), sum(log.slipping), numel(log.t));
else
    fprintf('  RESULT: ran out of time without closing the lap\n');
end
end
