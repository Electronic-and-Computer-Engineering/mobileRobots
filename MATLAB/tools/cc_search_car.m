function [poses, cost, stats] = cc_search_car(CM, startPose, goalXY, tol, neighborFcn)
%CC_SEARCH_CAR  A* over poses. Given to you, because you have written it.
%
%   [poses, cost, stats] = CC_SEARCH_CAR(CM, startPose, goalXY, tol)
%   [poses, cost, stats] = CC_SEARCH_CAR(..., @myNeighbors)
%
%   CM           the car model from CC_CAR_MODEL
%   startPose    [x y theta] where the car is now
%   goalXY       [x y] where it should get to -- the heading is free
%   tol          how close counts as arrived (m)
%   neighborFcn  which neighbour function to use (default @car_neighbors)
%
%   poses        N-by-3, the route as a list of poses
%   cost         length of the route in metres
%   stats        .expansions .order .g .poses
%
%   ------------------------------------------------------------------
%   READ THIS BEFORE YOU USE IT
%
%   This is YOUR astar_graph from chapter 06. Put the two files side by
%   side -- the loop below is the same loop, line for line. Container
%   'minkey', key g + h, the closed check, the relaxation, walking the
%   predecessors back. Nothing new.
%
%   Exactly three things differ, and all three are consequences of the
%   state being a POSE instead of a cell:
%
%     1 the neighbours come from neighborFcn, which asks the car
%     2 that function returns a THIRD output -- the exact poses -- and
%       they are stored in a `pose` array beside `g` and `par`
%     3 the goal is a place, so arriving means being within tol of it
%
%   It is given to you so that the only thing you write in this chapter
%   is the piece that is actually new: CAR_NEIGHBORS. If you would
%   rather write the search as well, it is there as an optional task in
%   tasks/astar_car.m -- and then you can pass it to CC_LAP_PLAN
%   instead of this one.
%
%   See also CAR_NEIGHBORS, CC_LAP_PLAN, ASTAR_CAR, CC_CAR_MODEL.

if nargin < 4 || isempty(tol),         tol = 0.15;                 end
if nargin < 5 || isempty(neighborFcn), neighborFcn = @car_neighbors; end

n      = CM.nNodes;
g      = inf(n, 1);
par    = zeros(n, 1);
pose   = zeros(n, 3);
closed = false(n, 1);
order  = zeros(1, 0);

s = cc_pose_index(startPose, CM);
if isempty(s)
    error('cc_search_car:start', ...
        'The start pose (%.2f, %.2f) is not on the track.', ...
        startPose(1), startPose(2));
end
g(s)      = 0;
pose(s,:) = startPose;

OPEN = open_new('minkey');
OPEN = open_push(OPEN, s, g(s) + cc_car_heuristic(startPose, goalXY));

goalNode = 0;

while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);
    if closed(u)
        continue
    end
    closed(u)    = true;
    order(end+1) = u;                           %#ok<AGROW>
    trace_step(numel(order), u);

    if cc_car_heuristic(pose(u,:), goalXY) <= tol
        goalNode = u;
        break
    end

    [nb, w, np] = neighborFcn(CM, pose(u,:));

    for k = 1:numel(nb)
        v = nb(k);
        if closed(v)
            continue
        end
        gNew = g(u) + w(k);
        if gNew < g(v)
            g(v)      = gNew;
            par(v)    = u;
            pose(v,:) = np(k,:);
            OPEN = open_push(OPEN, v, g(v) + cc_car_heuristic(np(k,:), goalXY));
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
stats.poses      = pose;
end
