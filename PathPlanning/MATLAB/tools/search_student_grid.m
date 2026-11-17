function [path, cost, stats] = search_student_grid(M, s, t, method, varargin)
%SEARCH_STUDENT_GRID  Run the STUDENT'S OWN *_graph search on a small grid.
%
%   [p,c,st] = search_student_grid(M,s,t,'astar')
%   [p,c,st] = search_student_grid(M,s,t,'astar','Conn',8)
%
%   Options: 'Conn' = 4/8; 'CornerCut' = false/true;
%            'Heuristic' = 'manhattan'/'octile'/'euclid'/'zero'.
%   If Heuristic is omitted, conn=4 uses manhattan and conn=8 octile.
%
%   Unlike SEARCH_GRID (which is a separate reference implementation),
%   this function invokes dfs_graph, bfs_graph, dijkstra_graph,
%   greedy_graph, or astar_graph from the active MATLAB path.
%
%   stats.preparationTime: building sparse W and h, seconds
%   stats.searchTime:      running the student search, seconds
%   Compare searchTime, not total elapsed time, across algorithms.
%   For precise timings repeat measurements and account for machine noise.
%
%   On a large grid an implicit graph is preferable. The conversion here
%   is deliberately used for teaching, not proposed as a production API.

p = inputParser();
p.addParameter('Conn', 4);
p.addParameter('CornerCut', false);
p.addParameter('Heuristic', '');
p.parse(varargin{:});
a = p.Results;

if isempty(a.Heuristic)
    if a.Conn == 4
        a.Heuristic = 'manhattan';
    else
        a.Heuristic = 'octile';
    end
end

if ~isscalar(s) || ~isscalar(t) || s < 1 || t < 1 || ...
        s > numel(M) || t > numel(M) || s ~= fix(s) || t ~= fix(t) || ...
        M(s) ~= 0 || M(t) ~= 0
    error('search_student_grid:endpoints', ...
        'Start and goal must be valid free-cell linear indices.');
end

prepClock = tic;
W = grid_to_graph(M, a.Conn, a.CornerCut);
[R, C] = size(M);
hfun = grid_heuristic(a.Heuristic, R, C, t);
h = hfun((1:numel(M)).');
preparationTime = toc(prepClock);

wasOn = trace_on();
trace_on('off');
cleanup = onCleanup(@() trace_on(wasOn)); %#ok<NASGU>

searchClock = tic;
switch lower(char(method))
    case 'dfs'
        [path, cost, stats] = dfs_graph(W, s, t);
    case 'bfs'
        [path, cost, stats] = bfs_graph(W, s, t);
    case 'dijkstra'
        [path, cost, stats] = dijkstra_graph(W, s, t);
    case 'greedy'
        [path, cost, stats] = greedy_graph(W, s, t, h);
    case 'astar'
        [path, cost, stats] = astar_graph(W, s, t, h);
    otherwise
        error('search_student_grid:method', ...
            'method must be dfs, bfs, dijkstra, greedy, or astar.');
end
searchTime = toc(searchClock);
stats.preparationTime = preparationTime;
stats.searchTime = searchTime;
end
