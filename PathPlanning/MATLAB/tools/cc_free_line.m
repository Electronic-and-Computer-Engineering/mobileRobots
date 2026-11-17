function ok = cc_free_line(p1, p2, T, useRaw)
%CC_FREE_LINE  Is the straight line from p1 to p2 clear of walls?
%
%   ok = CC_FREE_LINE(p1, p2, T)           the INFLATED 5 cm planning map
%   ok = CC_FREE_LINE(p1, p2, T, true)     the REAL walls at 1 cm
%
%   p1, p2   [x y] in metres
%   T        the track from CC_TRACK
%
%   The line is sampled every half cell. Half a cell is small enough that
%   no cell can be jumped over: a straight line cannot leave and re-enter
%   a cell between two samples that are closer together than the cell is
%   wide.
%
%   USE THE RIGHT MAP FOR THE RIGHT QUESTION. Smoothing asks "may a
%   point go here?" and uses the inflated map. A crash test asks "did
%   the car touch a wall?" and must use the real walls -- on the 5 cm
%   map it would be wrong by up to 5 cm, half the width of the car, and
%   would report crashes that never happened.
%
%   This is the only collision test the smoothing needs, and it is worth
%   understanding, because a smoothed route that is never tested is a
%   route that drives through a wall. A curve that bulges outwards
%   between two free cells can cross a corner that the original route
%   went neatly around.
%
%   See also CC_SHORTCUT_PATH, CC_TRACK.

if nargin < 4 || isempty(useRaw), useRaw = false; end

if useRaw
    M = T.Mfine;   cs = T.fineSize;   R = T.Rf;   C = T.Cf;
else
    M = T.M;       cs = T.cellSize;   R = T.R;    C = T.C;
end

d = hypot(p2(1)-p1(1), p2(2)-p1(2));
n = max(2, ceil(d / (0.5 * cs)) + 1);

xs = linspace(p1(1), p2(1), n);
ys = linspace(p1(2), p2(2), n);

% Points may leave the track entirely; that counts as blocked.
c = floor(xs / cs) + 1;
r = R - floor(ys / cs);
if any(c < 1 | c > C | r < 1 | r > R)
    ok = false;
    return
end

ok = ~any(M(sub2ind([R C], r, c)) ~= 0);
end
