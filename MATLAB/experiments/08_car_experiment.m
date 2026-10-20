%% 08_car_experiment — my planner sends a car through a maze
% Before running:
% 1. Finish car_in_maze.m in tasks/.
% 2. Run check_my_code('astar') and check_car_maze.
% 3. Explain why a grid path is not automatically drivable by a real car.

[M, s, t] = maze_obstacles(18, 25, 0.20, 7);
method = 'astar';
showAnimation = true;
[path, cost, stats] = car_in_maze(M, s, t, method, showAnimation);

fprintf('Algorithm: %s | steps: %d | cost: %.3f | expansions: %d\n', ...
    method, numel(path)-1, cost, stats.expansions);

% OPTIONAL: Switch to 'bfs' or 'dijkstra'; compare routes and expansions.
% OPTIONAL: Change the map seed. Predict what changes before executing.
% The animation has NO physical steering, acceleration, or footprint model.
