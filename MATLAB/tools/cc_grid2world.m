function [x, y] = cc_grid2world(idx, T)
%CC_GRID2WORLD  From a cell of the planning map back to metres.
%
%   [x, y] = CC_GRID2WORLD(idx, T)
%
%   idx    one cell, or a whole path of cells (linear indices)
%   T      the track from CC_TRACK
%   x, y   the CENTRE of each cell, in metres
%
%   This is the exact inverse of CC_WORLD2GRID, up to the size of one
%   cell: a cell covers an area, a point does not, so you get the middle
%   of the cell back and not the point you started from.
%
%   That half-cell is not a rounding detail -- it is the resolution limit
%   of everything the planner says. With 5 cm cells, a route is only ever
%   right to within 2.5 cm. The car is 10.5 cm wide.
%
%   Example -- check that the two functions really are inverses:
%       T = cc_track();
%       i = cc_world2grid(3.5, 0.6, T);
%       [x, y] = cc_grid2world(i, T)      % 3.525   0.625
%
%   See also CC_WORLD2GRID, CC_PATH_TO_WORLD, CC_TRACK.

idx = idx(:);
if any(idx < 1 | idx > T.R * T.C | idx ~= fix(idx))
    error('cc_grid2world:index', 'Those are not valid cells of this map.');
end

[r, c] = ind2sub([T.R, T.C], idx);

x = (c - 0.5) * T.cellSize;
y = (T.R - r + 0.5) * T.cellSize;
end
