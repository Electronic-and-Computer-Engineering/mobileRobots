function [poses, cost, stats] = astar_car(CM, startPose, goalXY, tol)
%ASTAR_CAR  A* over POSES: your astar_graph, with the car as the map.
%
%   [poses, cost, stats] = ASTAR_CAR(CM, startPose, goalXY, tol)
%
%   CM         the car model from CC_CAR_MODEL
%   startPose  [x y theta] where the car is now
%   goalXY     [x y] where it should get to -- the heading is free
%   tol        how close counts as arrived (m)
%
%   poses      N-by-3, the route as a list of poses
%   cost       length of the route in metres
%   stats      .expansions .order .g
%
%   ------------------------------------------------------------------
%   OPEN YOUR astar_graph.m NEXT TO THIS FILE. You have written this
%   loop before. Four things are different, and that is all:
%
%     1 The neighbours come from the CAR, not from a table:
%           [nb, w, np] = car_neighbors(CM, pose(u,:));
%       instead of
%           [nb, w] = graph_neighbors(W, u);
%
%     2 There is a THIRD output, np -- the actual poses. A grid cell IS
%       its position; a pose node is only a rounded-off pose, so the
%       exact one has to be stored: pose(v,:) = np(k,:).
%
%     3 The goal is a PLACE, not a node. You arrive when you are within
%       tol metres of it, whichever way the car happens to point.
%
%     4 h takes a pose instead of a node number:
%           cc_car_heuristic(pose(v,:), goalXY)
%
%   Container, key, relaxation, the closed check, walking the
%   predecessors back: unchanged. Do not reinvent them.
%
%   TODO 1  Push the start with the key g(s) + h(s).
%   TODO 2  Stop when the popped pose is within tol of the goal.
%   TODO 3  Ask the car for its neighbours.
%   TODO 4  Relax: if the new route is cheaper, store g, par, AND pose,
%           then push with the key g(v) + h(v).
%
%   Check with:  check_car_plan
%   Guide:       ANLEITUNGEN/10_crazycar_track.md

if nargin < 4 || isempty(tol), tol = 0.15; end

n      = CM.nNodes;
g      = inf(n, 1);
par    = zeros(n, 1);
pose   = zeros(n, 3);
closed = false(n, 1);
order  = zeros(1, 0);

s = cc_pose_index(startPose, CM);
if isempty(s)
    error('astar_car:start', 'The start pose is not on the track.');
end
g(s)      = 0;
pose(s,:) = startPose;

OPEN = open_new('minkey');

% TODO 1 -- push the start with its key
OPEN = open_push(OPEN, s, 0);

goalNode = 0;

while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);
    if closed(u)
        continue
    end
    closed(u)    = true;
    order(end+1) = u;                           %#ok<AGROW>
    trace_step(numel(order), u);

    % TODO 2 -- have we arrived? (within tol metres of goalXY)
    if false
        goalNode = u;
        break
    end

    % TODO 3 -- the neighbours the car can actually reach
    nb = [];
    w  = [];
    np = zeros(0,3);

    for k = 1:numel(nb)
        v = nb(k);
        if closed(v)
            continue
        end

        % TODO 4 -- relax, and remember the pose as well as the cost
        gNew = inf;
        if gNew < g(v)
            g(v)   = gNew;
            par(v) = u;

            OPEN = open_push(OPEN, v, g(v));
        end
    end
end

if goalNode == 0
    poses = zeros(0,3);
    cost  = inf;
else
    chain = goalNode;
    while chain(end) ~= s
        chain(end+1) = par(chain(end));         %#ok<AGROW>
    end
    chain = fliplr(chain);
    poses = pose(chain, :);
    cost  = g(goalNode);
end

stats.expansions = numel(order);
stats.order      = order;
stats.g          = g;

error('task:todo', 'Complete tasks/astar_car.m -- see ANLEITUNGEN/10_crazycar_track.md');
end
