function [u, ctl] = cc_pure_pursuit(st, ref, ctl, P)
%CC_PURE_PURSUIT  Turn a planned line into throttle and steering.
%
%   [u, ctl] = CC_PURE_PURSUIT(st, ref, ctl, P)
%
%   st    the car's state (see CC_STEP)
%   ref   the route: an N-by-3 list [x y vTarget], metres and m/s
%   ctl   the controller's own memory; pass [] the first time
%   P     parameters from CC_PARAMS
%   u     [throttlePercent steerPercent] -- what CC_STEP wants
%
%   PURE PURSUIT IN ONE PICTURE
%   Put a dot on the route a fixed distance ahead of the car -- the
%   LOOKAHEAD point. Now steer so the car drives a circular arc from
%   where it is to that dot. Repeat 25 times a second. The dot keeps
%   running away, the car keeps chasing it, and the result is a car that
%   follows the line.
%
%   The steering angle for that arc is
%
%       delta = atan( 2 * L * sin(alpha) / Ld )
%
%   with L the wheelbase, Ld the lookahead distance and alpha the angle
%   between where the car points and where the dot is.
%
%   THE ONE KNOB THAT MATTERS: Ld
%     too SHORT  the car reacts to every kink, wobbles, and at speed it
%                oscillates until it hits a wall
%     too LONG   the car cuts corners -- it aims at a dot that is already
%                past the bend, and shortens the route by driving through
%                the inside of it
%   So Ld grows with speed: slow and precise in corners, long and calm on
%   a straight. Those two numbers are in ctl.Ld0 and ctl.kLd, and they
%   are the first thing to try changing when the car misbehaves.
%
%   THE DEAD BAND
%   Below about 28 % throttle the motor produces nothing at all (1.11 V
%   of 4 V). A plain proportional controller asks for 5 % as it nears its
%   target speed, gets nothing, slows down, asks for 6 % ... and crawls.
%   So any positive demand is lifted to the dead band. Real motors have
%   this; pretending otherwise produces a controller that works in the
%   simulation and not on the car.
%
%   See also CC_SIMULATE, CC_SPEED_PROFILE, CC_STEP.

if nargin < 4 || isempty(P), P = cc_params(); end

if isempty(ctl)
    % These four numbers were tuned on this track, by trying them. With
    % a longer lookahead the car cuts the first corner into the wall;
    % with a shorter one it wobbles. Change them and watch.
    ctl.Ld0   = 0.16;   % m, lookahead when standing still
    ctl.kLd   = 0.08;   % s, extra lookahead per m/s
    ctl.LdMax = 0.35;   % m
    ctl.kv    = 90;     % percent throttle per (m/s) of speed error
    ctl.i     = 1;      % where on the route we were last time
    ctl.done  = false;
end

% ---- where are we on the route? --------------------------------------
% Only search FORWARD from last time. On a lap the route comes back close
% to itself, and a global nearest-point search would happily jump to the
% wrong lap and declare the car finished.
window = 200;
hi  = min(size(ref,1), ctl.i + window);
seg = ctl.i : hi;
d2  = (ref(seg,1) - st.x).^2 + (ref(seg,2) - st.y).^2;
[~, k] = min(d2);
ctl.i = seg(k);

% ---- the lookahead point ---------------------------------------------
Ld = min(ctl.LdMax, ctl.Ld0 + ctl.kLd * abs(st.v));

j = ctl.i;
n = size(ref,1);
acc = 0;
while j < n && acc < Ld
    acc = acc + hypot(ref(j+1,1)-ref(j,1), ref(j+1,2)-ref(j,2));
    j = j + 1;
end
if j >= n && acc < Ld
    ctl.done = true;    % the end of the route is closer than Ld
end
target = ref(j, 1:2);

% ---- steering ---------------------------------------------------------
dx = target(1) - st.x;
dy = target(2) - st.y;
alpha = atan2(dy, dx) - st.theta;
alpha = atan2(sin(alpha), cos(alpha));          % wrap to -pi .. pi

LdReal = max(hypot(dx, dy), 1e-6);
delta  = atan2(2 * P.L * sin(alpha), LdReal);   % radians

steerPerc = rad2deg(delta) / P.deltaMax * 100;
steerPerc = max(-100, min(100, steerPerc));

% ---- throttle ---------------------------------------------------------
vWant = ref(ctl.i, 3);
err   = vWant - st.v;
throttle = ctl.kv * err;

deadPerc = P.Vdead / P.Vmax * 100;
if throttle > 0 && throttle < deadPerc
    throttle = deadPerc;        % below this the motor does nothing at all
end
throttle = max(-100, min(100, throttle));

u = [throttle, steerPerc];
end
