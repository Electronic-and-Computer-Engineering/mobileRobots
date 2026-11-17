function v = cc_top_speed(P, V)
%CC_TOP_SPEED  How fast this car can go, worked out rather than guessed.
%
%   v = CC_TOP_SPEED(P)        at full throttle
%   v = CC_TOP_SPEED(P, V)     at a given voltage
%
%   A car reaches its top speed when the push from the motor exactly
%   equals everything holding it back. Write that down and solve it:
%
%       F_drive(v) = F_roll(v) + F_drag(v)
%
%       A * (V - v*km*gear/kRev)  =  dRoll*v  +  0.5*rho*area*cDrag*v^2
%
%   with A = km*gear / (4*rWheelDyn*Rm). That is an ordinary quadratic
%   equation in v, so there is no need to simulate for ten seconds and
%   hope it has settled.
%
%   The original simulator answers the same question with a lookup table
%   in +car/lut_motor.mat, which was itself produced by simulating this
%   very model. The two agree to within 5 %; the remainder is the drag
%   term, which the original multiplies by the speed one time too many.
%
%   See also CC_PARAMS, CC_STEP, CC_SPEED_PROFILE.

if nargin < 2 || isempty(V)
    V = P.Vmax;
end
if abs(V) < P.Vdead
    v = 0;
    return
end

A  = P.km * P.gear / (4 * P.rWheelDyn * P.Rm);
a2 = 0.5 * P.rhoAir * P.area * P.cDrag;
a1 = P.dRoll + A * P.km * P.gear / P.kRev;
a0 = -A * abs(V);

v = (-a1 + sqrt(a1^2 - 4*a2*a0)) / (2*a2);
v = sign(V) * v;
end
