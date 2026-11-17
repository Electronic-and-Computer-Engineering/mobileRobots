function ok = check_car_plan()
%CHECK_CAR_PLAN  Test your tasks/astar_car.m and say what is wrong.
%
%   check_car_plan
%   ok = check_car_plan()
%
%   Three legs with known answers, then four questions that a route has
%   to answer whatever algorithm produced it:
%
%     does it start where the car is?
%     does it end at the goal?
%     is every step one the CAR can make?
%     does the car fit, everywhere along it?
%
%   The last two are what separate this from chapter 06. A route can be
%   the cheapest one in the search space and still be nonsense if the
%   poses are not actually linked by a primitive -- that happens as soon
%   as you forget to store the pose in the relaxation.
%
%   See also ASTAR_CAR, CAR_NEIGHBORS, CHECK_MY_CODE.

P  = cc_params();
T  = cc_track(P);
CM = cc_car_model(T, P);

wasOn = trace_on();
trace_on('off');
cleanup = onCleanup(@() trace_on(wasOn)); %#ok<NASGU>

% start pose,                  goal,          tol,  cost,   expansions
cases = { ...
    [3.50 0.60 0],            [4.80 0.60],   0.12, 1.1900,  11,  'short straight'
    [3.50 0.60 0],            [6.18 1.65],   0.15, 3.5310, 453,  'first leg, right-hand turn'
    [6.18 1.65 pi/2],         [4.35 2.55],   0.15, 2.3410, 118,  'top-right sweep'
};

fprintf('\n');
nGood  = 0;
tooMany = 0;
tooFew  = 0;
tooDear = 0;

for k = 1:size(cases,1)
    startPose = cases{k,1};
    goalXY    = cases{k,2};
    tol       = cases{k,3};
    wantCost  = cases{k,4};
    wantExp   = cases{k,5};
    name      = cases{k,6};

    try
        [poses, cost, stats] = astar_car(CM, startPose, goalXY, tol);
    catch err
        if strcmp(err.identifier, 'task:todo')
            fprintf('  tasks/astar_car.m is still the skeleton.\n');
            fprintf('  Work through ANLEITUNGEN/10_crazycar_track.md first.\n\n');
            ok = false;
            return
        end
        fprintf('  [%d] %-28s ERROR: %s\n', k, name, err.message);
        continue
    end

    problems = local_validate(CM, poses, cost, startPose, goalXY, tol);

    costOK = abs(cost - wantCost) < 0.02;
    if ~costOK && cost > wantCost
        tooDear = tooDear + 1;
    end
    if costOK && stats.expansions > 1.6*wantExp
        tooMany = tooMany + 1;
    end
    if costOK && stats.expansions < 0.5*wantExp
        tooFew = tooFew + 1;
    end

    if isempty(problems) && costOK
        fprintf('  [%d] ok    %-28s %.4f m, %d expansions\n', ...
            k, name, cost, stats.expansions);
        nGood = nGood + 1;
    else
        fprintf('  [%d] FAIL  %-28s %.4f m (want %.4f), %d expansions (want %d)\n', ...
            k, name, cost, wantCost, stats.expansions, wantExp);
        for q = 1:numel(problems)
            fprintf('            %s\n', problems{q});
        end
    end
end

fprintf('\n');
ok = (nGood == size(cases,1));

if ok
    fprintf('  All green. Now plan a whole lap:\n');
    fprintf('      T = cc_track(); CM = cc_car_model(T);\n');
    fprintf('      poses = cc_lap_plan(CM);\n\n');
    return
end

% ---- the targeted hints ----------------------------------------------
fprintf('  What that most likely means:\n\n');

if tooMany >= 2
    fprintf('    The route is right but the search does FAR too much work.\n');
    fprintf('    Your key is g alone. That is Dijkstra -- chapter 04.\n');
    fprintf('    A* needs  g(v) + cc_car_heuristic(np(k,:), goalXY),\n');
    fprintf('    and it needs it in BOTH open_push calls.\n\n');
end
if tooFew >= 2
    fprintf('    The search is suspiciously fast. Your key is h alone.\n');
    fprintf('    That is greedy best-first -- chapter 05. You lost the g.\n\n');
end
if tooDear >= 2
    fprintf('    The routes come out too expensive. Either nothing is being\n');
    fprintf('    relaxed (check gNew = g(u) + w(k), not just w(k)), or the\n');
    fprintf('    key dropped the g.\n\n');
end
fprintf('    If a route is "not a move the car can make": you are not\n');
fprintf('    storing the pose. The relaxation needs all THREE lines:\n');
fprintf('        g(v) = gNew;  par(v) = u;  pose(v,:) = np(k,:);\n');
fprintf('    Leave the last one out and the search walks a tree of poses\n');
fprintf('    that are all [0 0 0].\n\n');
end

% -----------------------------------------------------------------------
function problems = local_validate(CM, poses, cost, startPose, goalXY, tol)
problems = {};

if isempty(poses)
    problems{end+1} = 'no route found at all';
    return
end
if size(poses,2) ~= 3
    problems{end+1} = 'poses must be N-by-3: [x y theta] per row';
    return
end

if hypot(poses(1,1)-startPose(1), poses(1,2)-startPose(2)) > 1e-6
    problems{end+1} = 'the route does not start where the car is';
end
if hypot(poses(end,1)-goalXY(1), poses(end,2)-goalXY(2)) > tol + 1e-9
    problems{end+1} = sprintf('the route ends %.0f mm from the goal, tol is %.0f mm', ...
        1000*hypot(poses(end,1)-goalXY(1), poses(end,2)-goalXY(2)), 1000*tol);
end

% every step must be one of the primitives, applied to the previous pose
sumCost = 0;
for k = 1:size(poses,1)-1
    [nb, w, np] = car_neighbors(CM, poses(k,:)); %#ok<ASGLU>
    hit = 0;
    for q = 1:size(np,1)
        if max(abs(np(q,1:2) - poses(k+1,1:2))) < 1e-9 && ...
                abs(np(q,3) - poses(k+1,3)) < 1e-9
            hit = q;
            break
        end
    end
    if hit == 0
        problems{end+1} = sprintf( ...
            'step %d is not a move the car can make', k); %#ok<AGROW>
        return
    end
    sumCost = sumCost + w(hit);
end

if abs(sumCost - cost) > 1e-6
    problems{end+1} = sprintf( ...
        'cost says %.4f but the steps add up to %.4f', cost, sumCost);
end
end
