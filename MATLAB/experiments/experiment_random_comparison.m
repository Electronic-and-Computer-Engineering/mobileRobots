%% EXPERIMENT_RANDOM_COMPARISON — guided experiment with YOUR planners
% Mobile Robots / Path Planning · CORE route
%
% BEFORE RUNNING:
%  1. Complete the five tasks/*_graph.m files and run check_my_code.
%  2. Predict: Which methods guarantee the minimum cost in a 4-neighbour
%     grid with all edges costing 1? Which might expand fewer nodes?
%  3. Run setup_path once from the project root.
%
% Run this file as a script. It uses search_student_grid, which calls
% your OWN search functions. No change to the provided tools is required.

% TASK A: Change ONLY seeds to 1:8 if you have extra time.
% TASK B: Change ONE density and predict whether results will change.
densities = [0.15, 0.25];
seeds = 1:4;                     % CORE: eight maps; OPTIONAL: 1:8
methods = {'dfs', 'bfs', 'greedy', 'dijkstra', 'astar'};

rows = cell(0, 7);
for density = densities
    for seed = seeds
        [M, s, t] = maze_obstacles(30, 40, density, seed);
        [~, referenceCost] = search_student_grid(M, s, t, 'dijkstra');

        for k = 1:numel(methods)
            [path, cost, stats] = search_student_grid(M, s, t, methods{k});
            rows(end+1,:) = {density, seed, methods{k}, cost, ...
                             stats.expansions, 1000*stats.searchTime, ...
                             cost/referenceCost}; %#ok<AGROW>
        end
    end
end

results = cell2table(rows, 'VariableNames', ...
    {'Density', 'Seed', 'Method', 'Cost', 'Expansions', 'SearchMs', 'CostRatio'});

disp('First rows of your measurement table:');
disp(results(1:min(height(results), 10),:));

fprintf('\n%-8s %-9s %10s %12s %12s\n', ...
        'Density','Algorithm','MeanRatio','MeanExpand','MedianMs');
for density = densities
    for k = 1:numel(methods)
        idx = results.Density == density & strcmp(results.Method, methods{k});
        fprintf('%-8.2f %-9s %10.3f %12.1f %12.3f\n', ...
            density, methods{k}, mean(results.CostRatio(idx)), ...
            mean(results.Expansions(idx)), median(results.SearchMs(idx)));
    end
end

% THINK (write 1-2 sentences each, no long report):
%  1. Which methods had CostRatio = 1 for all these 4-neighbour maps?
%  2. Which methods had fewer expansions, and at what cost to path quality?
%  3. Do these 8 maps PROVE which algorithm is universally faster? Why not?
%
% OPTIONAL: test seeds = 1:8 and compare the summary. For runtime claims,
% repeat measurements and do not confuse graph-building preparation time
% with search time.
