function P = cc_params(varargin)
%CC_PARAMS  Every CrazyCar number, in one place.
%
%   P = CC_PARAMS()                      the defaults
%   P = CC_PARAMS('CellSize', 0.04)      change one of them
%
%   In the original simulator the same quantity appears with different
%   values in different files: the kinematics uses a length of 0.14 m,
%   the drawing is 0.22 m long, and the wheel positions in the drawing
%   give a wheelbase of 0.12 m. A model cannot be right in three ways at
%   once, so every number lives here now and nowhere else.
%
%   WHICH LENGTH THE BICYCLE MODEL NEEDS
%   It needs the WHEELBASE -- the distance from the rear axle to the
%   front axle. That is what decides how sharply the car turns. The
%   overall body length decides only whether you hit a wall. They are
%   different numbers and they are used in different places.
%
%   Fields:
%     .L            wheelbase (m)                 front axle to rear axle
%     .bodyL,.bodyW body size (m)                 for collision and drawing
%     .deltaMax     steering limit (deg)
%     .steerRate    servo speed (deg/s)
%     .Vmax         motor voltage at 100 % (V)
%     .Vdead        below this the motor does not turn (V)
%     .ayMax        lateral acceleration the tyres hold (m/s^2)
%     .dt           one simulation step (s)       1/25, as in the original
%     .cellSize     planning grid cell (m)
%     .inflate      obstacle inflation (m)        see CC_TRACK
%     .start        [x y theta] start pose (m, m, rad)
%     .finishX      x of the finish line (m)
%
%   See also CC_TRACK, CC_STEP, CC_SIMULATE.

% ---- geometry ---------------------------------------------------------
% Wheel centres in +car/plotCar.m of the original simulator sit at
% x = +0.07 (front) and x = -0.05 (rear) relative to the body centre.
P.L     = 0.12;      % wheelbase (m)      = 0.07 - (-0.05)
P.lr    = 0.06;      % rear axle to the reference point (m)
P.bodyL = 0.22;      % body length (m)    22.0 cm in plotCar.m
P.bodyW = 0.105;     % body width  (m)    10.5 cm in plotCar.m

% ---- steering ---------------------------------------------------------
P.deltaMax  = 22;    % deg, from percToCar.m and SteerServo_model.m
P.steerRate = 110;   % deg/s, = deltaMax / 0.2 s, from SteerServo_model.m

% ---- motor ------------------------------------------------------------
P.Vmax      = 4.0;       % V at 100 % throttle, from percToCar.m
P.Vdead     = 1.11;      % V, below this motor_model.m produces no torque
P.Rm        = 0.55;      % Ohm
P.km        = 0.002753408439503;   % V s / rad
P.gear      = 5.2727;    % motor turns per wheel turn
P.rWheel    = 0.018;     % m
P.rWheelDyn = P.rWheel * 0.98;
P.mass      = 0.6;       % kg
P.cRoll     = 0.05851;   % rolling resistance coefficient (-)
P.area      = 0.0084;    % m^2 frontal area
P.cDrag     = 0.44;      % drag coefficient (-)
P.rhoAir    = 1.2041;    % kg/m^3
P.kRev      = 0.11;      % m of travel per wheel revolution (~2*pi*rWheel)

% Rolling resistance. In the original this is a FORCE, m*g*c_r = 0.344 N,
% which is then multiplied by the speed as well -- so it behaves like a
% VISCOUS damping coefficient in N*s/m, and that is how the car's other
% numbers were calibrated. Written honestly as a damping coefficient the
% arithmetic is unchanged and the units finally agree. Do not "fix" this
% into a constant force without re-measuring: the same parameters then
% give a top speed of about 51 km/h.
P.dRoll     = P.mass * 9.81 * P.cRoll;   % N*s/m  (= 0.3444)

% ---- grip -------------------------------------------------------------
% The original computes a centrifugal force and a friction limit in
% calcRotuPos.m and then never compares them -- the 'if' is commented
% out. So the car corners at any speed. Here the limit is real.
% 0.8 * 9.81 is a plain rubber-on-smooth-floor assumption; MEASURE IT on
% the real car before you trust a lap time to three decimals.
P.ayMax = 0.8 * 9.81;    % m/s^2

% ---- simulation -------------------------------------------------------
P.dt = 1 / 25;           % s, MainFrequency = 25 Hz in +env/startup.m

% ---- which track ------------------------------------------------------
% 'oval'      a plain practice loop. Start here: a lap plans in a couple
%             of seconds, so you can get your car_neighbors working
%             before the track has anything to say about it.
% 'crazycar'  the real thing, from the CrazyCar simulator.
%
%   P = cc_params('Track', 'oval')
%
% Everything below that depends on the track is set at the bottom of this
% file, in local_track.
P.track = 'crazycar';

% ---- track and planning ----------------------------------------------
P.cellSize = 0.05;       % m, one planning cell

% Obstacle inflation for the POINT planner of chapters 01-08. Half the
% body width plus a margin. The planner treats the car as a point, so
% the walls grow instead.
%
% Note what this does NOT cover: the car is twice as long as it is wide,
% and when it turns, its corners swing out well beyond half the width.
% A route planned this way is collision-free for a point and not for the
% car. Chapter 10 is that sentence, made visible.
P.inflate = P.bodyW / 2 + 0.02;      % m  -> 0.0725

% ---- planning with the vehicle model (chapter 08) ---------------------
% The pose planner does NOT use P.inflate. It tests the car's real
% rectangle against the walls, so it needs no inflation -- only a safety
% margin, because a route that touches a wall leaves the controller no
% room. Measured: with 0 margin the planner shaves a wall corner to
% within 3 mm and the first bit of tracking error is a crash.
P.safety = 0.05;     % m

P.poseCell = 0.10;   % m, how finely the pose search tells positions
                     % apart. This is NOT P.cellSize: the pose search
                     % has 16 headings per position, so the same number
                     % of cells costs 16 times the memory.
P.nTheta = 16;       % how many headings the search may distinguish
                     % 16 bins = 22.5 degrees apart
P.arc    = 0.119;    % m, how far one motion primitive drives
                     % chosen so that FULL LOCK turns exactly one bin:
                     % arc = (2*pi/nTheta) / (cos(beta)*tan(deltaMax)/L)
P.steerLevels = [-1, -0.5, 0, 0.5, 1];   % fractions of deltaMax
P.wSteer = 0.02;     % m of extra cost for using full lock, so that the
                     % search prefers a straight line when both work

% Throttle for the probe runs in CAR_PRIMITIVES. The car is driven with
% this, from rest, until it has covered P.arc -- and the arc that comes
% out is the same whatever you put here, because the SHAPE of a path
% does not depend on how fast it is driven. 40 % gives about 13
% simulator steps per primitive, which is a comfortable resolution.
% Below P.Vdead/P.Vmax = 27.75 % the motor does nothing and the probe
% never finishes.
P.probeThrottle = 40;    % percent

% ---- the lap ----------------------------------------------------------
% WHY CHECKPOINTS EXIST AT ALL
% A search needs a start and a goal that are different cells. On a lap
% they are the SAME cell, and the cheapest route from a cell to itself
% is to stand still. So a lap cannot be one search. It is a CHAIN of
% searches through points that lie on the way round.
%
% The checkpoints also decide the DIRECTION. Read them backwards and the
% car drives the other way round -- that is the 'CCW'/'CW' switch of the
% original simulator, expressed as data instead of as a flag.
%
% How close the car has to get to a checkpoint to count as having
% reached it. The HEADING is free: it is the next leg's problem.
P.cpTol = 0.15;      % m
P.goalTol = 0.12;    % m, for the last leg back to the start

% ---- overrides, in two passes -----------------------------------------
% Pass 1 picks up 'Track', because everything about the track depends on
% it. Pass 2 runs after the track defaults are in, so an explicit
% override still wins over them.
if mod(numel(varargin), 2) ~= 0
    error('cc_params:pairs', 'Options come in Name/Value pairs.');
end
names = cell(1, numel(varargin)/2);
for k = 1:2:numel(varargin)
    if ~ischar(varargin{k}) && ~isstring(varargin{k})
        error('cc_params:name', 'Option %d is not a name.', (k+1)/2);
    end
    names{(k+1)/2} = char(varargin{k});
end

hit = find(strcmpi(names, 'track'), 1, 'last');
if ~isempty(hit)
    P.track = char(varargin{2*hit});
end

P = local_track(P);

% Names are matched WITHOUT regard to case, against the fields that
% exist. Otherwise 'Track' -- the spelling used everywhere, because it
% reads as an option rather than a variable -- would not match the field
% P.track, and every call that passes it would stop here.
flds = fieldnames(P);
for k = 1:2:numel(varargin)
    name = names{(k+1)/2};
    j    = find(strcmpi(flds, name), 1);
    if isempty(j)
        error('cc_params:unknown', ...
            ['There is no parameter called "%s".\n' ...
             'Type  cc_params  with no arguments to see them all.'], name);
    end
    P.(flds{j}) = varargin{k+1};
end
end

% -----------------------------------------------------------------------
function P = local_track(P)
%LOCAL_TRACK  Everything that depends on WHICH track is being driven.

switch lower(P.track)

case 'oval'
    % A plain loop: two straights and two half circles, lane 0.50 m wide,
    % centreline corner radius 0.50 m. The car's tightest possible radius
    % is 0.303 m, so every corner here is comfortably driveable -- which
    % is the point. Nothing about this track is meant to be difficult.
    P.trackImage = 'track_oval.png';
    P.worldX = 3.200;
    P.worldY = 2.000;
    P.start  = [1.60, 0.50, 0];       % bottom straight, pointing +x
    P.finishX = 1.60;
    P.finishY = [0.25 0.75];
    P.checkpoints = [2.90, 1.00;      % CP1  right-hand half circle
                     1.60, 1.50;      % CP2  top straight, going left
                     0.30, 1.00];     % CP3  left-hand half circle
    % Lap along the centreline: 2*1.60 + 2*pi*0.50 = 6.34 m.

case 'crazycar'
    P.trackImage = 'track.png';
    P.worldX = 6.540;      % m  (6540 px at 1000 px/m)
    P.worldY = 2.940;      % m  (2940 px at 1000 px/m)

    % Start pose, exactly as +env/startup.m sets it.
    P.start = [3.5, 0.6, 0];

    % Start/finish line. The original times a lap with a gate between
    % x = 3.0 and x = 3.5 in the band y = 0 .. 0.76 (data.TimeLane in
    % +env/startup.m). The car starts on the right edge of that gate, so
    % x = 3.5 is the line, and crossing it forwards closes the lap.
    P.finishX = 3.5;
    P.finishY = [0.0 0.76];

    % This track is a SERPENTINE, not a ring: between CP2 and CP4 you
    % have to come down into the middle channel and back up. CP3 sits in
    % that channel so no leg becomes much longer than the others.
    % Each one sits at the WIDEST point of its piece of corridor --
    % measured, not guessed. A checkpoint 8 cm from a wall disappears as
    % soon as the walls grow, and then the lap cannot be planned at all.
    P.checkpoints = [6.18, 1.65;    % CP1  right-hand turnaround
                     4.35, 2.55;    % CP2  top right
                     3.00, 1.15;    % CP3  middle channel, heading left
                     0.50, 2.45;    % CP4  top left
                     0.45, 1.35];   % CP5  left-hand edge

otherwise
    error('cc_params:track', ...
        'Unknown track "%s". Use ''oval'' or ''crazycar''.', P.track);
end
end
