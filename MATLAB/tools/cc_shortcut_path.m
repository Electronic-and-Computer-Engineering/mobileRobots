function XY = cc_shortcut_path(XY, T, varargin)
%CC_SHORTCUT_PATH  Turn a staircase of grid cells into a line a car can drive.
%
%   XY = CC_SHORTCUT_PATH(XY, T)
%   XY = CC_SHORTCUT_PATH(XY, T, 'Rounds', 3, 'Spacing', 0.04)
%
%   XY   the route in metres, from CC_PATH_TO_WORLD
%   T    the track from CC_TRACK
%
%   Options:
%     'Rounds'   how often to smooth after shortcutting (default 3)
%     'Spacing'  distance between the points you get back (default 0.04 m)
%     'MaxJump'  how much route a single shortcut may skip (default 1 m)
%
%   TWO STEPS, AND BOTH ARE CHECKED AGAINST THE WALLS
%
%   1 SHORTCUT. Walk forward from the first point and look for the
%     FURTHEST later point you can still reach in a straight line. Keep
%     that one and throw away everything between. A staircase of fifty
%     5 cm steps collapses into two long straights.
%
%     > WHY 'MaxJump' IS NOT OPTIONAL ON A LAP
%     > On a lap the LAST point is the first point. Without a limit the
%     > very first test asks "can I drive straight from the start to the
%     > start?", the answer is yes, and the entire lap disappears -- you
%     > get a route of one point. A shortcut may therefore skip at most
%     > MaxJump metres of the original route. Try setting it to 100 and
%     > watch the lap vanish.
%
%   2 ROUND OFF. Each remaining corner is still a hard kink. Replace
%     every point by the average of itself and its two neighbours, a few
%     times over. Corners become arcs.
%
%   AFTER EVERY SINGLE CHANGE the new piece is tested with CC_FREE_LINE,
%   and the change is undone if it would touch a wall. Smoothing without
%   that test is the classic way to produce a beautiful route that drives
%   straight through a corner -- the walls are inflated by half a car, so
%   the margin you are eating into is the car itself.
%
%   The result is still only a LINE. It says nothing about speed. That is
%   CC_SPEED_PROFILE's job.
%
%   See also CC_PATH_TO_WORLD, CC_SPEED_PROFILE, CC_FREE_LINE.

p = inputParser();
p.addParameter('Rounds', 3);
p.addParameter('Spacing', 0.04);
p.addParameter('MaxJump', 1.0);
p.parse(varargin{:});
a = p.Results;

if size(XY, 1) < 3
    return
end

% ---- 1) shortcut ------------------------------------------------------
n   = size(XY, 1);
cum = [0; cumsum(hypot(diff(XY(:,1)), diff(XY(:,2))))];

keep = 1;
i = 1;
while i < n
    % the furthest point this shortcut is allowed to reach at all
    jMax = find(cum - cum(i) <= a.MaxJump, 1, 'last');
    jMax = max(jMax, i + 1);

    j = jMax;
    while j > i + 1 && ~cc_free_line(XY(i,:), XY(j,:), T)
        j = j - 1;
    end
    keep(end+1) = j;   %#ok<AGROW>
    i = j;
end
XY = XY(keep, :);

% ---- resample, so the rounding has something to work with -------------
XY = cc_resample_path(XY, a.Spacing);

% ---- 2) round off the corners ----------------------------------------
for round = 1:a.Rounds
    Q = XY;
    for k = 2:size(XY,1)-1
        cand = 0.25*XY(k-1,:) + 0.5*XY(k,:) + 0.25*XY(k+1,:);
        if cc_free_line(Q(k-1,:), cand, T) && cc_free_line(cand, Q(k+1,:), T)
            Q(k,:) = cand;
        end
    end
    XY = Q;
end
end
