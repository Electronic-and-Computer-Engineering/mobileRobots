function [st, info] = cc_step(st, u, P)
%CC_STEP  One simulation step of the CrazyCar, 1/25 of a second.
%
%   [st, info] = CC_STEP(st, u, P)
%
%   st   the state, a struct:
%          .x .y      position of the car's reference point (m)
%          .theta     heading (rad), 0 = pointing along +x
%          .v         speed (m/s)
%          .delta     where the steering actually IS right now (deg)
%   u    what you command:  [throttle, steering], both in PERCENT,
%        -100 .. +100, exactly like the original simulator
%   P    parameters from CC_PARAMS
%
%   info .beta      body slip angle (rad)
%        .yawRate   how fast the car turns (rad/s)
%        .ay        lateral acceleration demanded (m/s^2)
%        .slipping  true if the tyres could not deliver it
%
%   FOUR THINGS HAPPEN, IN THIS ORDER
%     1 percent  -> volts and a steering angle you WANT
%     2 the servo moves towards that angle -- it is not there instantly
%     3 the motor changes the speed
%     4 the geometry turns speed and steering angle into a new pose
%
%   ------------------------------------------------------------------
%   WHAT WAS CORRECTED, AND WHY
%
%   (a) +car/SteerServo_model.m line 10 reads "else if" with a space.
%       In MATLAB that opens a NESTED if, not an else-branch. The result:
%       whenever you command straight ahead while the wheels are turned
%       LEFT, the whole servo block is skipped and the steering FREEZES
%       at its current angle. The car then circles for ever. It is one
%       space, and it is the worst bug in the file.
%
%   (b) +car/calcRotuPos.m line 8 computes
%           beta = atan(car_L / (car_L / tan(delta)))
%       which is algebraically just delta -- the whole line is a no-op.
%       The name gives the intention away: beta is the body SLIP ANGLE
%       of a bicycle model referred to the middle of the car. It is
%       computed properly below.
%
%   (c) line 9 then uses  theta_dot = v * beta / L  where the bicycle
%       model needs  v * tan(delta) / L. The tangent is missing. At full
%       lock that is 5 % too little yaw rate.
%
%   (d) L was 0.14 m. The car in +car/plotCar.m is 0.22 m long and its
%       wheels are 0.12 m apart. The bicycle model needs the WHEELBASE,
%       so 0.12. See CC_PARAMS.
%
%   (e) calcRotuPos.m computes a centrifugal force and a friction limit
%       and then never compares them -- the 'if' is commented out. So in
%       the original the car corners at any speed at all. Here the limit
%       is applied: ask for more grip than there is and the car runs
%       wide, which is what a real car does.
%
%   See also CC_PARAMS, CC_SIMULATE, CC_PURE_PURSUIT.

if nargin < 3 || isempty(P), P = cc_params(); end

u = u(:).';
if numel(u) ~= 2 || any(~isfinite(u))
    error('cc_step:input', 'u must be [throttlePercent steerPercent].');
end
percSpeed = max(-100, min(100, u(1)));
percSteer = max(-100, min(100, u(2)));

dt = P.dt;

% ---- 1) percent -> volts and a wanted steering angle ------------------
% From +car/percToCar.m, unchanged.
V        = (P.Vmax     / 100) * percSpeed;      % volts
deltaDes = (P.deltaMax / 100) * percSteer;      % degrees

% ---- 2) the servo ------------------------------------------------------
% It swings at a finite speed: deltaMax in 0.2 s, so 110 deg/s.
maxMove = P.steerRate * dt;                     % degrees this step
if st.delta < deltaDes
    st.delta = min(st.delta + maxMove, deltaDes);
elseif st.delta > deltaDes
    st.delta = max(st.delta - maxMove, deltaDes);
end
st.delta = max(-P.deltaMax, min(P.deltaMax, st.delta));

% ---- 3) the motor ------------------------------------------------------
% A DC motor's torque falls off as it spins faster, because its own
% back-EMF eats into the applied voltage. That is the whole of the next
% three lines, and it is why the car has a top speed at all.
nWheel = st.v / P.kRev;                  % wheel revolutions per second
if abs(V) < P.Vdead
    Vdrive = 0;          % below ~1.11 V the motor does not turn at all
else
    Vdrive = V;
end
torque = ((Vdrive - nWheel * P.km * P.gear) / P.Rm) * P.km;   % Nm at the motor
Fdrive = (torque * P.gear) / (4 * P.rWheelDyn);               % N at the road

Froll = P.dRoll * st.v;                                   % N, see CC_PARAMS
Fdrag = 0.5 * P.rhoAir * P.area * P.cDrag * st.v * abs(st.v);

st.v = st.v + (Fdrive - Froll - Fdrag) / P.mass * dt;

% ---- 4) the geometry: a bicycle model ---------------------------------
% Both front wheels are replaced by one wheel in the middle of the front
% axle, both rear wheels by one in the middle of the rear axle. For a car
% that does not slide sideways that is exact, not an approximation.
d    = deg2rad(st.delta);
beta = atan((P.lr / P.L) * tan(d));        % body slip angle -- (b) above
yawRate = (st.v / P.L) * cos(beta) * tan(d);

% Grip. Going round a bend of radius R at speed v needs a sideways
% acceleration of v^2 / R = v * yawRate. The tyres can only supply
% P.ayMax of it.
ay = abs(st.v * yawRate);
slipping = false;
if ay > P.ayMax && ay > 0
    yawRate  = yawRate * (P.ayMax / ay);   % the car runs wide -- (e) above
    slipping = true;
end

% Integrate the heading over the step and use the MIDDLE of it for the
% position. At 25 Hz the heading can change by 6 degrees in one step, so
% using the start or the end of the step instead is a visible error.
thetaMid = st.theta + 0.5 * yawRate * dt;
st.theta = st.theta + yawRate * dt;

st.x = st.x + st.v * cos(thetaMid + beta) * dt;
st.y = st.y + st.v * sin(thetaMid + beta) * dt;

info.beta     = beta;
info.yawRate  = yawRate;
info.ay       = ay;
info.slipping = slipping;
end
