function [idx, r, c] = cc_world2grid(x, y, T)
%CC_WORLD2GRID  From metres on the track to a cell of the planning map.
%
%   idx          = CC_WORLD2GRID(x, y, T)
%   [idx, r, c]  = CC_WORLD2GRID(x, y, T)
%
%   x, y   where the car is, in METRES, measured from the bottom-left
%          corner of the track. x runs right, y runs up.
%   T      the track from CC_TRACK
%   idx    the LINEAR index of that cell -- exactly what you hand to
%          dfs_graph, astar_graph and friends as a start or a goal
%   r, c   row and column, if you want to see them
%
%   THE ONE THING THAT TRIPS EVERYBODY UP
%   The map is stored like a picture: ROW 1 IS THE TOP. But y is measured
%   from the BOTTOM. So the row number runs the other way than y:
%
%       r = R - floor(y / cellSize)
%
%   Get this backwards and your car drives the track upside down -- and
%   it will look almost plausible, because the track is roughly
%   symmetric. That is exactly why it is worth checking once, by hand,
%   with CC_GRID2WORLD.
%
%   Works on vectors of x and y as well.
%
%   THE 1e-9 BELOW IS NOT DECORATION
%   Type `floor(0.6/0.05)` into MATLAB. It is 11, not 12 -- because 0.05
%   cannot be written exactly in binary, so 0.6/0.05 comes out as
%   11.999999999999998. A point exactly on a cell boundary then lands in
%   the cell BELOW, and the start pose of this very track is such a
%   point. The tiny offset makes the boundary case go one way every
%   time instead of depending on which numbers you happened to type.
%
%   See also CC_GRID2WORLD, CC_TRACK, CC_PATH_TO_WORLD.

cs = T.cellSize;

c = floor(x(:) / cs + 1e-9) + 1;
r = T.R - floor(y(:) / cs + 1e-9);

if any(c < 1 | c > T.C | r < 1 | r > T.R)
    bad = find(c < 1 | c > T.C | r < 1 | r > T.R, 1);
    error('cc_world2grid:outside', ...
        ['The point (%.3f, %.3f) is not on the track.\n' ...
         'The track runs from (0, 0) to (%.2f, %.2f) metres.'], ...
        x(bad), y(bad), T.C * cs, T.R * cs);
end

idx = sub2ind([T.R, T.C], r, c);

if numel(idx) == 1
    r = r(1);
    c = c(1);
end
end
