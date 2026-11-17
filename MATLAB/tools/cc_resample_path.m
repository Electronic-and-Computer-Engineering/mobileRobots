function Q = cc_resample_path(XY, spacing)
%CC_RESAMPLE_PATH  Put points along a route at an even distance apart.
%
%   Q = CC_RESAMPLE_PATH(XY, spacing)
%
%   XY        the route, N-by-2 in metres
%   spacing   how far apart the points should be (m)
%
%   WHY EVEN SPACING MATTERS
%   Two later steps measure things ALONG the route: CC_SPEED_PROFILE
%   estimates curvature from neighbouring points, and CC_PURE_PURSUIT
%   counts off its lookahead distance point by point. Both quietly
%   assume the points are evenly spaced.
%
%   A pose route is not. Its points are one motion primitive apart --
%   11.9 cm of arc, which is less than 11.9 cm of straight-line distance
%   when the car is turning. So the points bunch up in corners, exactly
%   where the curvature estimate has to be trustworthy. Resample first.
%
%   Duplicate points are dropped: a zero-length segment makes the
%   curvature formula divide by zero.
%
%   See also CC_SHORTCUT_PATH, CC_SPEED_PROFILE, CC_PURE_PURSUIT.

if nargin < 2 || isempty(spacing)
    spacing = 0.04;
end
if size(XY,1) < 2
    Q = XY;
    return
end

seg  = hypot(diff(XY(:,1)), diff(XY(:,2)));
s    = [0; cumsum(seg)];
good = [true; seg > 0];
s    = s(good);
XY   = XY(good, :);

if numel(s) < 2
    Q = XY;
    return
end

sq = (0 : spacing : s(end)).';
if sq(end) < s(end)
    sq(end+1) = s(end);
end

Q = [interp1(s, XY(:,1), sq), interp1(s, XY(:,2), sq)];
end
