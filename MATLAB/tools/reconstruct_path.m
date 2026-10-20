function [path, cost] = reconstruct_path(par, s, t, W)
%RECONSTRUCT_PATH  Turn the predecessor array into a path.
%
%   [path, cost] = RECONSTRUCT_PATH(par, s, t, W) walks backwards from t
%   through par until it reaches s, then reverses what it collected.
%
%   par(v) is the node the search came from when it reached v. A search
%   never builds a path while it runs -- it only fills in par, and this
%   function reads the path back out at the very end.
%
%   Without W the cost returned is the number of steps instead.
%
%   No path found: path is [] and cost is Inf. An empty path is NOT the
%   same as a path of length 0, so test it with isempty(path).
%
%   A cycle in par raises an error rather than looping forever.
%
%   See also GRAPH_NEIGHBORS.


if nargin < 4
    W = [];
end

n = numel(par);

% special case: the start already is the goal.
if s == t
    path = s;
    cost = 0;
    return
end

% no predecessor at the goal means it was never reached.
if par(t) == 0
    path = [];
    cost = inf;
    return
end

path  = zeros(1, 0);
u     = t;
guard = 0;

while u ~= 0
    path = [u, path];   %#ok<AGROW>  paths are short, this is fine
    if u == s
        break
    end
    u = par(u);
    guard = guard + 1;
    if guard > n + 1
        error('reconstruct_path:cycle', ...
            ['The predecessor array contains a cycle. Usual cause: ', ...
             'par gets written even though the cost did not actually ', ...
             'improve.']);
    end
end

% walking back has to arrive at the start, otherwise par is broken.
if isempty(path) || path(1) ~= s
    path = [];
    cost = inf;
    return
end

if isempty(W)
    cost = numel(path) - 1;
else
    cost = 0;
    for k = 1:numel(path) - 1
        cost = cost + W(path(k), path(k + 1));
    end
end
end
