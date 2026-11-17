function ok = cc_pose_free(CM, x, y, theta)
%CC_POSE_FREE  Can the car stand here, in this direction?
%
%   ok = CC_POSE_FREE(CM, x, y, theta)
%
%   CM           the car model from CC_CAR_MODEL
%   x, y, theta  a pose, in metres and radians
%   ok           true if the car's whole rectangle fits, with the safety
%                margin P.safety on top
%
%   You are given this one. It takes the car's outline, turns it to face
%   `theta`, moves it to `(x, y)`, and looks up every one of those points
%   in the 1 cm map. If a single point lands in a wall -- or off the
%   track -- the answer is false.
%
%   THE WHOLE CAR, NOT ITS CENTRE
%   This is the function that makes a pose search different from a
%   grid search: one position, two headings, two different answers.
%   The point planner asked "is this cell free?". This asks "does a
%   22 by 10.5 cm rectangle, pointing this way, fit?" -- and the answer
%   changes with the direction, which is exactly what a map of free and
%   blocked cells could never express.
%
%   Try it: at the start pose the car fits pointing along the track, and
%   does not fit turned across it.
%
%       T = cc_track(); CM = cc_car_model(T);
%       cc_pose_free(CM, 3.5, 0.6, 0)        % 1 -- along the straight
%       cc_pose_free(CM, 3.5, 0.6, pi/2)     % 0 -- across it
%
%   See also CAR_NEIGHBORS, CC_CAR_MODEL, CC_CAR_OUTLINE, CC_TRACK.

T = CM.T;

ct = cos(theta);
sn = sin(theta);

B  = CM.body;                      % 2-by-N, in the car's own frame
px = x + ct*B(1,:) - sn*B(2,:);
py = y + sn*B(1,:) + ct*B(2,:);

fs = T.fineSize;
c  = floor(px / fs + 1e-9) + 1;
r  = T.Rf - floor(py / fs + 1e-9);

if any(c < 1 | c > T.Cf | r < 1 | r > T.Rf)
    ok = false;                    % off the track counts as blocked
    return
end

ok = ~any(T.Msafe(sub2ind([T.Rf T.Cf], r, c)) ~= 0);
end
