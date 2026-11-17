function [dMin, at, dAll] = cc_clearance(T, log, varargin)
%CC_CLEARANCE  How close the car came to a wall. The honest safety number.
%
%   dMin           = CC_CLEARANCE(T, log)
%   [dMin, at]     = CC_CLEARANCE(T, log)
%   [dMin, at, dA] = CC_CLEARANCE(T, log)
%
%   T      the track from CC_TRACK
%   log    a run from CC_SIMULATE
%   dMin   the smallest distance, in metres, between the car's body and
%          any REAL wall, over the whole run
%   at     [x y] where that happened
%   dAll   the same distance at every sampled step, so you can plot it
%
%   Options:
%     'Every'   sample every n-th step (default 2 -- 12.5 Hz)
%     'Cap'     stop looking past this distance (default 0.5 m)
%
%   WHY "IT DID NOT CRASH" IS NOT A SAFETY MEASUREMENT
%
%   CC_SIMULATE answers one question: did the body touch a wall, yes or
%   no. That is a pass/fail, and pass/fail is the worst possible signal
%   to tune against, because it tells you nothing until it is too late.
%   Two laps that both say "no crash" can be
%
%       a lap that passed 70 mm from every wall, and
%       a lap that passed 4 mm from one of them
%
%   and the second one is not safe -- it is lucky. On the real car, where
%   the tyres, the battery and the floor are all slightly different from
%   the model, that 4 mm is gone.
%
%   So this function measures the thing you actually want to keep large.
%   Use it together with the grip reserve from
%   EXPERIMENT_CC_TUNING: one says how much room the car had in SPACE,
%   the other how much it had in GRIP.
%
%   HOW IT WORKS
%   For every sampled pose the body outline is sampled into points, and
%   for each point the nearest blocked cell of T.Mfine is found by
%   looking in a square window that grows until it hits something. No
%   toolbox, no distance transform -- and fast enough, because the
%   answer is usually found within 20 cells.
%
%   See also CC_SIMULATE, CC_CAR_OUTLINE, EXPERIMENT_CC_TUNING.

q = inputParser();
q.addParameter('Every', 2);
q.addParameter('Cap', 0.5);
q.parse(varargin{:});
o = q.Results;

P    = T.P;
fs   = T.fineSize;
kCap = ceil(o.Cap / fs);

nSteps = numel(log.t);
idx    = 1 : o.Every : nSteps;

dAll = zeros(numel(idx), 1);
dMin = o.Cap;
at   = [NaN NaN];

% The body, sampled finely enough that no wall can slip between two
% samples: T.fineSize is 1 cm, so 7 points per edge is 3.5 cm apart on
% the long edges -- and the window search below looks at whole cells, so
% a wall 1 cm thick is still found from 3.5 cm away.
f = linspace(0, 1, 7).';

for n = 1:numel(idx)
    st = struct('x', log.x(idx(n)), 'y', log.y(idx(n)), ...
                'theta', log.theta(idx(n)));
    out = cc_car_outline(st, P);

    dStep = o.Cap;
    pStep = [NaN NaN];
    for e = 1:4
        pts = out(e,:) + f .* (out(e+1,:) - out(e,:));
        for i = 1:size(pts,1)
            d = local_nearestWall(pts(i,1), pts(i,2), T, kCap);
            if d < dStep
                dStep = d;
                pStep = pts(i,:);
            end
        end
    end

    dAll(n) = dStep;
    if dStep < dMin
        dMin = dStep;
        at   = pStep;
    end
end
end

% -----------------------------------------------------------------------
function d = local_nearestWall(x, y, T, kCap)
%LOCAL_NEARESTWALL  Distance from one point to the nearest wall SURFACE.
%
%   A blocked cell is a 1 cm square of solid wall, so the distance that
%   matters is the distance to that square -- not to its centre, which
%   would be up to 7 mm too far on a 1 cm grid. For a point outside an
%   axis-aligned square that distance is exact and takes two lines:
%
%       dx = max(0, |x - cx| - fs/2)      and the same in y
%       d  = hypot(dx, dy)
%
%   The window grows until it contains a blocked cell at all. That first
%   hit gives a bound d0, and any cell outside a window of half-width
%   ceil(d0/fs) + 1 is further away than d0 and cannot win. So the
%   window is widened once to that size and the minimum taken over it.
%   No early exit, no approximation.

fs = T.fineSize;

c0 = floor(x / fs + 1e-9) + 1;
r0 = T.Rf - floor(y / fs + 1e-9);

% A point outside the track counts as inside a wall: the car has left.
if r0 < 1 || r0 > T.Rf || c0 < 1 || c0 > T.Cf
    d = 0;
    return
end
if T.Mfine(r0, c0) ~= 0
    d = 0;
    return
end

kHit = 0;
for k = 1:kCap
    rLo = max(1, r0 - k);   rHi = min(T.Rf, r0 + k);
    cLo = max(1, c0 - k);   cHi = min(T.Cf, c0 + k);
    win = T.Mfine(rLo:rHi, cLo:cHi);
    if any(win(:))
        kHit = k;
        break
    end
end

if kHit == 0
    d = kCap * fs;          % nothing within the cap: plenty of room
    return
end

d = local_minDist(x, y, T, r0, c0, kHit);
kWide = min(kCap, ceil(d / fs) + 1);
if kWide > kHit
    d = local_minDist(x, y, T, r0, c0, kWide);
end
end

% -----------------------------------------------------------------------
function d = local_minDist(x, y, T, r0, c0, k)
%LOCAL_MINDIST  Closest wall surface within a window of half-width k.
fs  = T.fineSize;
rLo = max(1, r0 - k);   rHi = min(T.Rf, r0 + k);
cLo = max(1, c0 - k);   cHi = min(T.Cf, c0 + k);

win = T.Mfine(rLo:rHi, cLo:cHi);
[rr, cc] = find(win);
if isempty(rr)
    d = inf;
    return
end
rr = rr + rLo - 1;
cc = cc + cLo - 1;

cx = (cc - 0.5) * fs;              % centre of each blocked cell
cy = (T.Rf - rr + 0.5) * fs;

dx = max(0, abs(cx - x) - fs/2);   % to the square, not to the centre
dy = max(0, abs(cy - y) - fs/2);
d  = min(hypot(dx, dy));
end
