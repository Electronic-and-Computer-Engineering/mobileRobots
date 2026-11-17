function [path, cost, stats] = search_grid(M, s, t, method, varargin)
%SEARCH_GRID  Run any of the five searches on a grid map.
%
%   [path, cost, stats] = SEARCH_GRID(M, s, t, method) where method is
%   one of 'dfs', 'bfs', 'greedy', 'dijkstra', 'astar'.
%
%   Options:
%       'Conn'        4 (default) or 8
%       'Heuristic'   'manhattan' (default), 'octile', 'euclid', 'zero'
%       'CornerCut'   false (default)
%
%   stats.expansions  how many cells were taken out of OPEN
%   stats.order       in which order -- pass this to plot_grid
%
%   THIS IS NOT A SIXTH ALGORITHM. It is the same loop you build on the
%   six-node graph, with exactly two lines changed:
%
%       graph:   nb      = graph_neighbors(W, u);
%       grid:    [nb, w] = grid_neighbors(M, u, conn);
%
%       graph:   h is a vector,     h(v)
%       grid:    h is a function,   hfun(v)
%
%   Everything else -- container, key, relaxation, par -- is untouched.
%   It is given to you so you can SEE your algorithms on a real map
%   straight away, instead of writing the grid version five times.
%
%   Example:
%       [Mo, s, t] = maze_obstacles(30, 40, 0.25, 7);
%       [p, c, st] = search_grid(Mo, s, t, 'astar');
%       plot_grid(Mo, 'Expanded', st.order, 'Path', p, ...
%                     'Start', s, 'Goal', t, 'Title', 'A* on a grid');
%
%   See also PLOT_GRID, GRID_NEIGHBORS, GRID_HEURISTIC.

p = inputParser();
p.addParameter('Conn',      4);
p.addParameter('Heuristic', 'manhattan');
p.addParameter('CornerCut', false);
p.parse(varargin{:});
a = p.Results;

method = lower(method);
if ~any(strcmp(method, {'dfs', 'bfs', 'greedy', 'dijkstra', 'astar'}))
    error('search_grid:method', ...
        'Unknown method "%s". Allowed: dfs, bfs, greedy, dijkstra, astar.', ...
        method);
end

[R, C] = size(M);
n      = R * C;
hfun   = grid_heuristic(a.Heuristic, R, C, t);

% a grid has thousands of cells -- the step trace would bury the screen
wasOn = trace_on();
trace_on('off');
cleanup = onCleanup(@() trace_on(wasOn));   %#ok<NASGU>

par    = zeros(n, 1);
closed = false(n, 1);
order  = zeros(1, 0);
g      = inf(n, 1);
g(s)   = 0;

withCost = any(strcmp(method, {'dijkstra', 'astar'}));

switch method
    case 'dfs',      OPEN = open_new('lifo');
    case 'bfs',      OPEN = open_new('fifo');
    otherwise,       OPEN = open_new('minkey');
end
OPEN = open_push(OPEN, s, local_key(method, g, hfun, s));

if ~withCost
    seen    = false(n, 1);
    seen(s) = true;
end

while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);
    if closed(u)
        continue
    end
    closed(u)      = true;
    order(end + 1) = u;   %#ok<AGROW>
    if u == t
        break
    end

    [nb, w] = grid_neighbors(M, u, a.Conn, a.CornerCut);
    for k = 1:numel(nb)
        v = nb(k);
        if closed(v)
            continue
        end
        if withCost
            gNew = g(u) + w(k);
            if gNew < g(v)
                g(v)   = gNew;
                par(v) = u;
                OPEN   = open_push(OPEN, v, local_key(method, g, hfun, v));
            end
        else
            if seen(v)
                continue
            end
            seen(v) = true;
            par(v)  = u;
            g(v)    = g(u) + w(k);
            OPEN    = open_push(OPEN, v, local_key(method, g, hfun, v));
        end
    end
end

[path, cost] = local_path(par, s, t, M, a.Conn, a.CornerCut);
stats.expansions = numel(order);
stats.order      = order;
stats.g          = g;
end


% =======================================================================
function key = local_key(method, g, hfun, v)
switch method
    case {'dfs', 'bfs'}
        key = 0;                    % ignored by lifo/fifo anyway
    case 'greedy'
        key = hfun(v);
    case 'dijkstra'
        key = g(v);
    case 'astar'
        key = g(v) + hfun(v);
end
end


function [path, cost] = local_path(par, s, t, M, conn, cut)
%LOCAL_PATH  Walk back through par and add up the real step costs.
path = reconstruct_path(par, s, t, []);
if isempty(path)
    cost = inf;
    return
end
cost = 0;
for k = 1:numel(path) - 1
    [nb, w] = grid_neighbors(M, path(k), conn, cut);
    cost = cost + w(nb == path(k + 1));
end
end
