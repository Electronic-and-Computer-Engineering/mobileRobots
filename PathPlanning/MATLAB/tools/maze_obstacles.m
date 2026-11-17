function [M, s, t] = maze_obstacles(R, C, density, seed)
%MAZE_OBSTACLES  An open field with scattered obstacles.
%
%   [M, s, t] = MAZE_OBSTACLES(R, C, density) builds an R x C grid in
%   which about density (0..1) of the cells are obstacles. The start s
%   is near the top left, the goal t near the bottom right; both are
%   guaranteed free and guaranteed connected by some path.
%
%   [M, s, t] = MAZE_OBSTACLES(R, C, density, seed) makes it repeatable.
%
%   WHY TWO KINDS OF MAP? In the narrow maze from MAZE_RANDOM an
%   estimate helps hardly at all, because walls force detours it cannot
%   see. On this open field it helps a lot. Run the same search on both
%   and compare the coloured area -- that contrast is the point.
%
%   See also MAZE_RANDOM, PLOT_GRID.

if nargin < 1 || isempty(R),       R = 41;        end
if nargin < 2 || isempty(C),       C = 61;        end
if nargin < 3 || isempty(density), density = 0.28; end
if nargin >= 4 && ~isempty(seed)
    rng(seed);
end

maxTries = 50;

for attempt = 1:maxTries
    M = double(rand(R, C) < density);

    % A wall all the way round, so no path can sneak around the outside
    % and the neighbour check stays easy to read.
    M(1, :)   = 1;
    M(R, :)   = 1;
    M(:, 1)   = 1;
    M(:, C)   = 1;

    % clear the start and the goal, plus the cells right around them
    M(2:3, 2:3)             = 0;
    M(R-2:R-1, C-2:C-1)     = 0;

    s = sub2ind([R, C], 2, 2);
    t = sub2ind([R, C], R - 1, C - 1);

    if local_reachable(M, s, t)
        return
    end
end

error('maze_obstacles:unconnected', ...
    ['After %d tries start and goal were never connected. ', ...
        'Density %.2f is too high for %dx%d -- try below 0.40.'], ...
    maxTries, density, R, C);
end

% -------------------------------------------------------------------------

function tf = local_reachable(M, s, t)
%LOCAL_REACHABLE  Flood fill: can t be reached from s?
%   Deliberately its own small search rather than a call into the
%   course code -- generating a map must not depend on the searches
%   being finished.

[R, C] = size(M);
seen = false(R, C);
q = s;
head = 1;
seen(s) = true;

while head <= numel(q)
    u = q(head);
    head = head + 1;
    if u == t
        tf = true;
        return
    end
    [r, c] = ind2sub([R, C], u);
    d = [-1 0; 1 0; 0 -1; 0 1];
    for k = 1:4
        rr = r + d(k, 1);
        cc = c + d(k, 2);
        if rr < 1 || rr > R || cc < 1 || cc > C
            continue
        end
        if M(rr, cc) ~= 0
            continue
        end
        v = sub2ind([R, C], rr, cc);
        if ~seen(v)
            seen(v) = true;
            q(end + 1) = v; %#ok<AGROW>
        end
    end
end

tf = false;
end
