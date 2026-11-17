function [vRef, kappa] = cc_speed_profile(XY, P, varargin)
%CC_SPEED_PROFILE  How fast the car may go at every point of the route.
%
%   [vRef, kappa] = CC_SPEED_PROFILE(XY, P)
%   [vRef, kappa] = CC_SPEED_PROFILE(XY, P, 'VMax', 3.0, 'ABrake', 2.5)
%
%   XY      the route in metres (N-by-2), smoothed
%   P       parameters from CC_PARAMS
%   vRef    one target speed per point (m/s)
%   kappa   the curvature at each point (1/m)
%
%   Options:
%     'VMax'    highest speed to ask for (default: the car's top speed)
%     'ABrake'  how hard the car may slow down (default 2.5 m/s^2)
%     'AAccel'  how hard it may speed up (default 2.0 m/s^2)
%     'AyMax'   the grip you PLAN with (default: P.ayMax, the grip the
%               car actually has). Setting this lower is how you buy
%               safety with time -- see chapter 10.
%
%   THE SHORTEST ROUTE IS NOT THE FASTEST ONE, AND HERE IS WHY
%
%   Three steps, each one a single idea:
%
%   1 CURVATURE. How tightly the line bends, as 1/radius. A straight has
%     kappa = 0; a bend of 30 cm radius has kappa = 3.3 per metre.
%
%   2 GRIP. Going round a bend of radius R at speed v pulls the car
%     sideways with v^2/R. The tyres hold only P.ayMax. So
%
%         v <= sqrt(P.ayMax / |kappa|)
%
%     On this car that is 1.5 m/s in the tightest possible corner, while
%     the car could do 3.7 m/s on a straight.
%
%   3 BRAKING. Knowing the limit at the corner is useless if you arrive
%     at it flat out: a car cannot drop from 3.7 to 1.5 m/s instantly.
%     So walk the route BACKWARDS from the end and pull every speed down
%     until the car could still stop in time:
%
%         v(i) <= sqrt( v(i+1)^2 + 2 * ABrake * ds )
%
%     That backward pass is why the car starts slowing down long before
%     the corner -- which is exactly what a driver does.
%
%   Then one forward pass does the same for acceleration, because the
%   motor cannot speed up instantly either.
%
%   See also CC_SHORTCUT_PATH, CC_PURE_PURSUIT, CC_SIMULATE.

q = inputParser();
q.addParameter('VMax', []);
q.addParameter('ABrake', 2.5);
q.addParameter('AAccel', 2.0);
q.addParameter('AyMax', []);
q.parse(varargin{:});
o = q.Results;

if isempty(o.VMax)
    o.VMax = cc_top_speed(P);
end
if isempty(o.AyMax)
    o.AyMax = P.ayMax;        % plan with exactly the grip the car has
end

n = size(XY, 1);
if n < 3
    vRef  = repmat(o.VMax, n, 1);
    kappa = zeros(n, 1);
    return
end

% ---- 1) curvature from three consecutive points ----------------------
% Three points that are not in a line lie on exactly one circle. Its
% radius comes from the triangle: R = (a*b*c) / (4*area).
kappa = zeros(n, 1);
for k = 2:n-1
    A = XY(k-1,:);  B = XY(k,:);  Cp = XY(k+1,:);
    a = hypot(B(1)-A(1), B(2)-A(2));
    b = hypot(Cp(1)-B(1), Cp(2)-B(2));
    c = hypot(Cp(1)-A(1), Cp(2)-A(2));
    area2 = abs((B(1)-A(1))*(Cp(2)-A(2)) - (B(2)-A(2))*(Cp(1)-A(1)));
    if a*b*c < eps || area2 < eps
        kappa(k) = 0;
    else
        kappa(k) = 2 * area2 / (a*b*c);    % = 1/R
    end
end
kappa(1)   = kappa(2);
kappa(end) = kappa(end-1);

% ---- 2) the grip limit, point by point -------------------------------
vRef = repmat(o.VMax, n, 1);
turning = kappa > 1e-6;
vRef(turning) = min(o.VMax, sqrt(o.AyMax ./ kappa(turning)));

% ---- 3) make it reachable: backwards for braking ---------------------
ds = hypot(diff(XY(:,1)), diff(XY(:,2)));
for k = n-1 : -1 : 1
    vRef(k) = min(vRef(k), sqrt(vRef(k+1)^2 + 2*o.ABrake*ds(k)));
end
% ... and forwards for accelerating
for k = 2 : n
    vRef(k) = min(vRef(k), sqrt(vRef(k-1)^2 + 2*o.AAccel*ds(k-1)));
end
end
