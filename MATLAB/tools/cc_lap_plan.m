function [poses, info] = cc_lap_plan(CM, varargin)
%CC_LAP_PLAN  A whole lap, by calling YOUR astar_car once per leg.
%
%   [poses, info] = CC_LAP_PLAN(CM)
%   [poses, info] = CC_LAP_PLAN(CM, 'Neighbors', @car_neighbors)
%   [poses, info] = CC_LAP_PLAN(CM, 'Planner', @astar_car)
%
%   poses   N-by-3, the whole lap as poses
%   info    .legs(k).poses .cost .expansions .goal
%           .cost .expansions .closes   (does the end meet the start?)
%
%   ------------------------------------------------------------------
%   WHY A LAP CANNOT BE ONE SEARCH
%
%   A search needs a start and a goal that are different. On a lap they
%   are the same place, and the cheapest route from a place to itself is
%   to stand still -- cost zero, and the search is quite right.
%
%   So a lap is a CHAIN of searches through points that lie on the way
%   round. Six legs here: start -> CP1 -> ... -> CP5 -> start.
%
%   AND THE LEGS ARE NOT INDEPENDENT
%   Each leg starts in the pose the previous one ENDED in -- not at the
%   checkpoint, and not pointing wherever you like. The car arrives at
%   CP2 pointing some way, and that is the way it sets off from CP2.
%   Hand each leg a fresh heading of 0 and the plan comes apart at every
%   checkpoint, because the car would have to turn on the spot.
%
%   That is also why the checkpoints only fix a PLACE and not a heading.
%   Fixing the heading too would mean guessing, before the search runs,
%   which way the car ought to be pointing -- and getting it wrong makes
%   a leg unplannable.
%
%   THE CLOSING TEST
%   info.closes compares the last pose with the first. If the lap does
%   not close, the car cannot start the next lap from where it finished,
%   and the lap time means nothing.
%
%   See also CAR_NEIGHBORS, CC_SEARCH_CAR, ASTAR_CAR, CC_SIMULATE.

q = inputParser();
q.addParameter('Planner', @cc_search_car);
q.addParameter('Neighbors', @car_neighbors);
q.addParameter('Verbose', true);
q.parse(varargin{:});
o = q.Results;

P = CM.P;

goals = [P.checkpoints; P.start(1), P.start(2)];
tols  = [repmat(P.cpTol, size(P.checkpoints,1), 1); P.goalTol];

pose  = P.start(:).';
poses = zeros(0,3);
totalCost = 0;
totalExp  = 0;

for k = 1:size(goals,1)
    if isequal(o.Planner, @cc_search_car)
        [legPoses, legCost, legStats] = ...
            o.Planner(CM, pose, goals(k,:), tols(k), o.Neighbors);
    else
        % your own astar_car, which has no neighbour argument
        [legPoses, legCost, legStats] = o.Planner(CM, pose, goals(k,:), tols(k));
    end

    if isempty(legPoses)
        error('cc_lap_plan:leg', ...
            ['Leg %d could not be planned: from (%.2f, %.2f) heading %.0f deg\n' ...
             'to (%.2f, %.2f). The car may not fit, or it would have to\n' ...
             'reverse -- and the primitives in CC_CAR_MODEL only go forwards.'], ...
            k, pose(1), pose(2), rad2deg(pose(3)), goals(k,1), goals(k,2));
    end

    if isempty(poses)
        poses = legPoses;
    else
        poses = [poses; legPoses(2:end, :)];     %#ok<AGROW>
    end

    info.legs(k).poses      = legPoses;
    info.legs(k).cost       = legCost;
    info.legs(k).expansions = legStats.expansions;
    info.legs(k).goal       = goals(k,:);

    totalCost = totalCost + legCost;
    totalExp  = totalExp  + legStats.expansions;

    pose = legPoses(end, :);

    if o.Verbose
        fprintf('  leg %d -> (%.2f, %.2f): %3d poses, %5.2f m, %5d expansions, arrives at %+6.1f deg\n', ...
            k, goals(k,1), goals(k,2), size(legPoses,1), legCost, ...
            legStats.expansions, mod(rad2deg(pose(3)), 360));
    end
end

dEnd  = hypot(poses(end,1) - poses(1,1), poses(end,2) - poses(1,2));
dHead = abs(atan2(sin(poses(end,3) - poses(1,3)), cos(poses(end,3) - poses(1,3))));

info.cost       = totalCost;
info.expansions = totalExp;
info.closes     = dEnd <= P.goalTol && dHead <= 2*CM.dTheta;
info.gapEnd     = dEnd;
info.gapHeading = rad2deg(dHead);

if o.Verbose
    fprintf('  LAP: %d poses, %.2f m, %d expansions. Closes: %s (%.0f mm, %.0f deg)\n', ...
        size(poses,1), totalCost, totalExp, ...
        local_yesno(info.closes), 1000*dEnd, info.gapHeading);
end
end

% -----------------------------------------------------------------------
function s = local_yesno(tf)
if tf, s = 'yes'; else, s = 'NO'; end
end
