function XY = cc_path_to_world(path, T)
%CC_PATH_TO_WORLD  A planned route of cells becomes a line in metres.
%
%   XY = CC_PATH_TO_WORLD(path, T)
%
%   path   linear cell indices, exactly as your planner returned them
%   T      the track from CC_TRACK
%   XY     an N-by-2 list of points [x y] in metres, the centre of each
%          cell on the route
%
%   This is the handover point of the whole course. Up to here everything
%   was cells, steps and expansions. From here on it is metres, seconds
%   and a steering angle.
%
%   LOOK AT WHAT YOU GET BACK
%   The points sit on a 5 cm lattice and every turn is a right angle or a
%   45 degree kink. No car can drive that. The planner was never asked to
%   produce something driveable -- it was asked for the cheapest sequence
%   of cells, and it delivered. Making it driveable is the next two
%   functions' job.
%
%   See also CC_SHORTCUT_PATH, CC_SPEED_PROFILE, CC_GRID2WORLD.

if isempty(path)
    error('cc_path_to_world:empty', ...
        ['The route is empty, so there is nothing to drive.\n' ...
         'Your planner found no way to the goal -- check start and goal.']);
end

[x, y] = cc_grid2world(path, T);
XY = [x(:), y(:)];
end
