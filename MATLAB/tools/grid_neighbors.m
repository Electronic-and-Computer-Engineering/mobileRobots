function [nb, w] = grid_neighbors(M, i, conn, allowCornerCut)
%GRID_NEIGHBORS  The neighbours of one grid cell.
%
%   [nb, w] = GRID_NEIGHBORS(M, i, conn, allowCornerCut)
%
%     M                the map: 0 is free, anything else is an obstacle
%     i                the cell, as a single linear index
%     conn             4 (up/down/left/right) or 8 (also diagonals)
%     allowCornerCut   false by default, see below
%
%   Returns the neighbouring cells as linear indices and what the step
%   to each of them costs: 1 straight, sqrt(2) diagonal.
%
%   The function checks the border of the map and the obstacles itself,
%   so you never have to.
%
%   CORNER CUTTING: a diagonal step from (r,c) to (r',c') squeezes
%   between the two cells (r,c') and (r',c). If either of those is an
%   obstacle, a real robot would scrape the corner. By default such a
%   step is refused. Pass true to allow it and see the difference.
%
%   See also GRAPH_NEIGHBORS, GRID_HEURISTIC, PLOT_GRID.


if nargin < 3 || isempty(conn)
    conn = 4;
end
if nargin < 4 || isempty(allowCornerCut)
    allowCornerCut = false;
end

[R, C] = size(M);
[r, c] = ind2sub([R, C], i);

if conn == 4
    d    = [-1 0; 1 0; 0 -1; 0 1];
    cost = [1 1 1 1];
elseif conn == 8
    d    = [-1 0; 1 0; 0 -1; 0 1; -1 -1; -1 1; 1 -1; 1 1];
    sq2  = sqrt(2);
    cost = [1 1 1 1 sq2 sq2 sq2 sq2];
else
    error('grid_neighbors:conn', 'conn must be 4 or 8, not %d.', conn);
end

m  = size(d, 1);
nb = zeros(1, m);
w  = zeros(1, m);
k  = 0;

for q = 1:m
    rr = r + d(q, 1);
    cc = c + d(q, 2);

    % outside the map?
    if rr < 1 || rr > R || cc < 1 || cc > C
        continue
    end
    % an obstacle?
    if M(rr, cc) ~= 0
        continue
    end
    % a diagonal squeezing past a corner?
    if ~allowCornerCut && d(q, 1) ~= 0 && d(q, 2) ~= 0
        if M(r, cc) ~= 0 || M(rr, c) ~= 0
            continue
        end
    end

    k = k + 1;
    nb(k) = sub2ind([R, C], rr, cc);
    w(k)  = cost(q);
end

nb = nb(1:k);
w  = w(1:k);
end
