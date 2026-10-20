function demo_grid()
%DEMO_GRID  See how a map becomes a graph, and where the one trap is.
%
%   Usage:  demo_grid
%
%   This is the most important demo. Almost every grid bug comes from
%   ONE thing: the conversion between (row, column) and the single
%   number the search works with.
%
%   Verifies: sub2ind, ind2sub, grid_neighbors, plot_grid.

clc
M = [0 0 0 0
     0 1 0 0
     0 0 0 0];
[R, C] = size(M);

fprintf('\n============================================================\n');
fprintf(' DEMO -- the grid\n');
fprintf('============================================================\n');

fprintf('\n A map is a matrix of 0 and 1. 0 is free, 1 is an obstacle.\n\n');
for r = 1:R
    fprintf('    ');
    fprintf('%2d', M(r, :));
    fprintf('\n');
end

% ---------------------------------------------------------------- 1
fprintf('\n------------------------------------------------------------\n');
fprintf(' 1) One cell is one number -- and MATLAB counts DOWN COLUMNS\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n');
for r = 1:R
    fprintf('    ');
    for c = 1:C
        fprintf('%4d', sub2ind([R C], r, c));
    end
    fprintf('\n');
end
fprintf('\n    Not 1 2 3 4 across the first row -- down the first column.\n');
i = sub2ind([R C], 2, 3);
[rr, cc] = ind2sub([R C], i);
fprintf('\n      i = sub2ind(size(M), 2, 3)     ->  i = %d\n', i);
fprintf('      [r,c] = ind2sub(size(M), %d)    ->  r = %d, c = %d\n', i, rr, cc);
fprintf('      M(%d) = %d   and   M(%d,%d) = %d   -- the same cell\n', ...
    i, M(i), rr, cc, M(rr, cc));

idx = reshape(1:numel(M), R, C);
figure('Name', 'demo_grid: the cell numbers');
plot_grid(M, 'Values', idx, 'Format', '%d', ...
    'Title', 'Every free cell and its number');
fprintf('\n    First window: the numbers printed into the cells. The dark\n');
fprintf('    cell is the obstacle -- it has a number too, but no search\n');
fprintf('    will ever stand on it.\n');

% ---------------------------------------------------------------- 2
fprintf('\n------------------------------------------------------------\n');
fprintf(' 2) grid_neighbors with 4 neighbours\n');
fprintf('------------------------------------------------------------\n');
local_show(M, 2, 3, 4, false, 'in the open');
local_show(M, 1, 1, 4, false, 'in the corner -- the border is handled for you');
local_show(M, 3, 2, 4, false, 'next to the obstacle -- it is simply not listed');

u  = sub2ind([R C], 2, 3);
nb = grid_neighbors(M, u, 4);
figure('Name', 'demo_grid: neighbours, conn = 4');
plot_grid(M, 'Mark', nb, 'Start', u, 'Values', idx, 'Format', '%d', ...
    'Title', 'conn = 4: cell 8 (circle) and its neighbours (outlined)');
fprintf('\n    Second window: the circle is cell 8, the outlined cells are\n');
fprintf('    what grid_neighbors returned. Count them against the list.\n');

% ---------------------------------------------------------------- 3
fprintf('\n------------------------------------------------------------\n');
fprintf(' 3) Eight neighbours, and why the costs change\n');
fprintf('------------------------------------------------------------\n');
local_show(M, 2, 3, 8, false, 'the same cell, now with diagonals');
fprintf('\n    Diagonals cost sqrt(2) = %.4f, not 1. From here on the grid\n', sqrt(2));
fprintf('    is a WEIGHTED graph -- counting steps is no longer the same\n');
fprintf('    as counting cost.\n');

nb8 = grid_neighbors(M, u, 8);
figure('Name', 'demo_grid: neighbours, conn = 8');
plot_grid(M, 'Mark', nb8, 'Start', u, 'Values', idx, 'Format', '%d', ...
    'Title', 'conn = 8: five neighbours, not seven');

% ---------------------------------------------------------------- 4
fprintf('\n------------------------------------------------------------\n');
fprintf(' 4) The corner-cutting trap\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n    Cell 8 is (2,3). Diagonally up-left is cell 4 = (1,2), and\n');
fprintf('    that cell is FREE. So the step looks legal. But the obstacle\n');
fprintf('    at (2,2) sits right between -- a real robot would scrape it.\n\n');
fprintf('      numel(grid_neighbors(M, 8, 8, false))  = %d   %% the default\n', ...
    numel(grid_neighbors(M, u, 8, false)));
fprintf('      numel(grid_neighbors(M, 8, 8, true))   = %d   %% cutting allowed\n', ...
    numel(grid_neighbors(M, u, 8, true)));

nbCut = grid_neighbors(M, u, 8, true);
figure('Name', 'demo_grid: corner cutting allowed');
plot_grid(M, 'Mark', nbCut, 'Start', u, 'Values', idx, 'Format', '%d', ...
    'Title', 'corner cutting ON: two extra diagonals squeeze past the wall');
fprintf('\n    Fourth window: compare it with the third. The two extra\n');
fprintf('    outlined cells push past the obstacle. In reality that does\n');
fprintf('    not work, which is why the default is false.\n\n');
end


% =======================================================================
function local_show(M, r, c, conn, cut, what)
[R, C] = size(M);
i = sub2ind([R C], r, c);
[nb, w] = grid_neighbors(M, i, conn, cut);
fprintf('\n    %s\n', what);
fprintf('    grid_neighbors(M, %d, %d)        %% cell (%d,%d)\n', i, conn, r, c);
fprintf('    -> %d neighbours:\n', numel(nb));
for k = 1:numel(nb)
    [nr, nc] = ind2sub([R C], nb(k));
    fprintf('         %3d = (%d,%d)   cost %.4f\n', nb(k), nr, nc, w(k));
end
end
