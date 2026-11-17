function M = maze_random(hCells, wCells, seed)
%MAZE_RANDOM  Build a random perfect maze.
%
%   M = MAZE_RANDOM(hCells, wCells) builds a maze of hCells x wCells
%   rooms. The grid that comes back is (2*hCells+1) x (2*wCells+1):
%   between any two rooms there is a wall position, and a closed wall
%   runs all the way around the outside.
%
%   M = MAZE_RANDOM(hCells, wCells, seed) makes the result repeatable --
%   for teaching, that is close to mandatory.
%
%   HOW IT WORKS: start in one room, knock down a wall to a random
%   unvisited neighbour, move there, repeat. Stuck? Back up until a room
%   with an unvisited neighbour turns up. That is depth-first search,
%   used as a builder instead of a planner.
%
%   WHAT COMES OUT is a perfect maze: between any two free cells there
%   is exactly one route. No loops and no walled-off regions, so the
%   number of free cells is always 2*hCells*wCells - 1.
%
%   BE WARNED: in a narrow maze almost every cell gets expanded, even
%   with a good estimate. That is not a bug -- straight-line distance
%   says very little when walls force long detours. Use MAZE_OBSTACLES
%   for the comparison where the estimate really pays off.
%
%   See also MAZE_OBSTACLES, PLOT_GRID.

if nargin < 1 || isempty(hCells), hCells = 15; end
if nargin < 2 || isempty(wCells), wCells = 25; end
if nargin >= 3 && ~isempty(seed)
    rng(seed);
end

R = 2 * hCells + 1;
C = 2 * wCells + 1;

M = ones(R, C);                     % all wall; we dig corridors into it
visited = false(hCells, wCells);

% room (r,c) sits at (2r, 2c) in the wall grid
visited(1, 1) = true;
M(2, 2) = 0;
stack = [1 1];                      % stack of room coordinates

while ~isempty(stack)
    cr = stack(end, 1);
    cc = stack(end, 2);

    % Unbesuchte Nachbarzellen sammeln.
    cand = [cr - 1, cc
            cr + 1, cc
            cr, cc - 1
            cr, cc + 1];
    ok = zeros(1, 0);
    for k = 1:4
        rr = cand(k, 1);
        ccx = cand(k, 2);
        if rr >= 1 && rr <= hCells && ccx >= 1 && ccx <= wCells ...
                && ~visited(rr, ccx)
            ok(end + 1) = k; %#ok<AGROW>
        end
    end

    if isempty(ok)
        stack(end, :) = [];         % Sackgasse -> Backtracking
    else
        k  = ok(randi(numel(ok)));  % zufaelliger unbesuchter Nachbar
        nr = cand(k, 1);
        nc = cand(k, 2);

        % knock down the wall between (cr,cc) and (nr,nc). In the wall
            % grid it sits exactly in the middle: (cr+nr, cc+nc).
        M(cr + nr, cc + nc) = 0;
        M(2 * nr, 2 * nc)   = 0;

        visited(nr, nc) = true;
        stack(end + 1, :) = [nr, nc]; %#ok<AGROW>
    end
end
end
