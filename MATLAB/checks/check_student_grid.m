function check_student_grid()
%CHECK_STUDENT_GRID  Basic integration checks for the teaching grid adapter.
%
%   Requires the student's BFS, Dijkstra and A* to be completed.
%   First run check_my_code for each of the five original graph searches.

M = [0 0 0 0; 0 1 0 0; 0 0 0 0];
W = grid_to_graph(M, 4, false);
assert(issparse(W), 'The graph representation should be sparse.');
assert(isequal(W, W.'), 'The graph must be undirected.');
assert(nnz(W) > 0, 'The graph has no edges.');

for u = find(M(:) == 0).'
    [ng, wg] = graph_neighbors(W, u);
    [nm, wm] = grid_neighbors(M, u, 4, false);
    [nm, order] = sort(nm);
    wm = wm(order);
    assert(isequal(ng(:), nm(:)), 'Graph and grid neighbours differ.');
    assert(all(abs(full(wg(:)) - wm(:)) < 1e-12), ...
        'Graph and grid edge costs differ.');
end

[M, s, t] = maze_obstacles(12, 16, 0.20, 7);
[pB, cB] = search_student_grid(M, s, t, 'bfs');
[pD, cD] = search_student_grid(M, s, t, 'dijkstra');
[pA, cA, stA] = search_student_grid(M, s, t, 'astar');

assert(~isempty(pB) && ~isempty(pD) && ~isempty(pA), ...
    'A reachable grid must have a path.');
assert(abs(cB-cD) < 1e-12 && abs(cA-cD) < 1e-12, ...
    'On this unit-cost 4-grid, BFS, Dijkstra and A* must agree on cost.');
assert(stA.expansions > 0 && isfield(stA, 'searchTime'), ...
    'The adapter did not return expected statistics.');

fprintf('Grid adapter checks passed on the example and a random grid.\n');
end
