function check_car_maze()
%CHECK_CAR_MAZE  Quick functional check of the student car-in-maze program.
%   Run with the completed tasks/car_in_maze.m active on the MATLAB path.
%   No figure is opened during this test (showAnimation=false).
[M,s,t] = maze_obstacles(12,16,0.20,7);
[path, cost, stats] = car_in_maze(M,s,t,'astar',false);
assert(~isempty(path), 'The car could not find a route on a connected map.');
assert(path(1)==s && path(end)==t, 'Route must begin at start and end at goal.');
assert(all(M(path)==0), 'Route includes an occupied cell.');
assert(isstruct(stats) && isfield(stats,'expansions'), ...
    'The car must return statistics from your search algorithm.');
expectedCost = 0;
for k = 1:numel(path)-1
    [nb,w] = grid_neighbors(M,path(k),4,false);
    j = find(nb==path(k+1),1);
    assert(~isempty(j), 'A move is not valid in the 4-neighbour grid.');
    expectedCost = expectedCost + w(j);
end
assert(abs(cost-expectedCost) < 1e-10, ...
    'Reported cost differs from the path-edge sum.');
[~, optimum] = search_student_grid(M,s,t,'dijkstra');
assert(abs(cost-optimum) < 1e-10, ...
    'On this 4-neighbour map A* should match Dijkstra cost.');
fprintf('Car in maze: path, collision, cost, and student search checks passed.\n');
end
