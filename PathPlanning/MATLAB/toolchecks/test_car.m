function test_car()
%TEST_CAR  Check the CrazyCar tools -- track, vehicle model, primitives.
%
%   Only the provided tools. Your own astar_car is tested by
%   CHECK_CAR_PLAN, not here.

fprintf('  test_car\n');

P = cc_params();

% ---- parameters -------------------------------------------------------
expect(abs(P.L - 0.12) < 1e-12, 'the wheelbase is 0.12 m (not 0.14, see the review)');
expect(P.bodyL > P.bodyW, 'the car is longer than it is wide');
expect(abs(P.dt - 1/25) < 1e-12, 'one step is 1/25 s, as in the original simulator');

% ---- top speed: solved and simulated must agree -----------------------
vTop = cc_top_speed(P);
expect(abs(vTop - 3.722) < 0.01, 'top speed comes out at 3.72 m/s');

st = struct('x',0, 'y',0, 'theta',0, 'v',0, 'delta',0);
for k = 1:600
    st = cc_step(st, [100 0], P);
end
expect(abs(st.v - vTop) < 1e-3, 'simulating to steady state gives the same top speed');

% ---- the dead band ----------------------------------------------------
st = struct('x',0, 'y',0, 'theta',0, 'v',0, 'delta',0);
for k = 1:125
    st = cc_step(st, [27 0], P);
end
expect(st.v == 0, '27 % throttle does nothing -- the motor has a dead band');

st = struct('x',0, 'y',0, 'theta',0, 'v',0, 'delta',0);
for k = 1:125
    st = cc_step(st, [28 0], P);
end
expect(st.v > 0, '28 % throttle does move the car');

% ---- the servo takes time, and it does come back ----------------------
st = struct('x',0, 'y',0, 'theta',0, 'v',0, 'delta',0);
st = cc_step(st, [0 100], P);
expect(st.delta > 0 && st.delta < P.deltaMax, 'the servo needs more than one step to reach full lock');

st.delta = -10;                      % wheels turned LEFT ...
st = cc_step(st, [0 0], P);          % ... and straight ahead commanded
expect(st.delta > -10, 'commanding straight from a left-hand angle MOVES the steering');
% ^ this is finding 1 of VEHICLE_MODEL_REVIEW.md. In the original the
%   steering freezes here and the car circles for ever.

% ---- the turning circle -----------------------------------------------
d    = deg2rad(P.deltaMax);
beta = atan((P.lr/P.L) * tan(d));
Rmin = P.L / (cos(beta) * tan(d));
expect(abs(Rmin - 0.303) < 0.002, 'the tightest radius is 0.303 m');

st = struct('x',0, 'y',0, 'theta',0, 'v',1, 'delta',P.deltaMax);
[st2, info] = cc_step(st, [0 100], P);
% Note: the speed is updated BEFORE the geometry inside cc_step, so the
% yaw rate belongs to the speed the car has at the END of the step.
expect(abs(info.yawRate - st2.v/Rmin) < 1e-9, 'the yaw rate is v / R_min at full lock');
expect(~info.slipping, 'at about 1 m/s the tyres still hold');

st = struct('x',0, 'y',0, 'theta',0, 'v',3, 'delta',P.deltaMax);
[~, info3] = cc_step(st, [0 100], P);
expect(info3.slipping, 'at 3 m/s in the same corner the tyres do NOT hold');
expect(info3.ay > P.ayMax, 'and the demanded lateral acceleration says why');

% ---- the track --------------------------------------------------------
T = cc_track(P);
expect(T.R == 59 && T.C == 131, 'the planning map is 59 by 131 cells');
expect(T.Rf == 294 && T.Cf == 654, 'the collision map is 294 by 654 cells of 1 cm');
expect(sum(T.M(:) == 0) == 5200, '5200 cells are free for a point planner');
expect(sum(T.Msafe(:) ~= 0) > sum(T.Mfine(:) ~= 0), 'Msafe has more blocked cells than Mfine');
expect(T.M(T.s) == 0, 'the start cell is free');
expect(all(T.M(T.cp) == 0), 'all checkpoints are free');

% ---- coordinates round-trip ------------------------------------------
[idx, r, c] = cc_world2grid(3.5, 0.6, T);
[xb, yb]    = cc_grid2world(idx, T);
expect(r == 47 && c == 71, 'the start pose is row 47, column 71');
expect(abs(xb - 3.525) < 1e-12 && abs(yb - 0.625) < 1e-12, ...
    'back again gives the centre of that cell');
[~, rLow]  = cc_world2grid(3.0, 0.2, T);
[~, rHigh] = cc_world2grid(3.0, 2.5, T);
expect(rLow > rHigh, 'a larger y gives a SMALLER row -- row 1 is the top');

% ---- the car model ----------------------------------------------------
% The reference primitives, so this runs before car_primitives is written.
CM = cc_car_model(T, P, @cc_primitives_probe);
expect(CM.nNodes == 29*65*16, 'the pose space has 29 x 65 x 16 nodes');
expect(numel(CM.prim) == numel(P.steerLevels), 'one primitive per steering level');

fullLock = CM.prim(end);
expect(abs(rad2deg(fullLock.dth) - 360/CM.nTheta) < 0.02, ...
    'full lock turns the car exactly one heading step');
expect(abs(CM.prim(3).dth) < 1e-12, 'the middle primitive goes straight');
expect(abs(CM.prim(3).dx - P.arc) < 1e-12, 'and it covers exactly P.arc');
expect(fullLock.cost > CM.prim(3).cost, 'steering costs a little more than going straight');

% The chord of an arc is never longer than the arc. CAR_PRIMITIVES is
% checked against this too -- see CHECK_CAR_PRIMITIVES.
for q = 1:numel(CM.prim)
    expect(hypot(CM.prim(q).dx, CM.prim(q).dy) <= CM.prim(q).len + 1e-9, ...
        sprintf('primitive %d: the chord is no longer than the arc', q));
end

% ---- pose numbering ---------------------------------------------------
i1 = cc_pose_index([3.5 0.6 0], CM);
i2 = cc_pose_index([3.5 0.6 2*pi], CM);
i3 = cc_pose_index([3.5 0.6 -1e-9], CM);
i4 = cc_pose_index([3.5 0.6 CM.dTheta], CM);
expect(i1 == i2, 'the heading wraps at 2*pi');
expect(i1 == i3, 'and just below zero');
expect(i1 ~= i4, 'one heading step apart is a different node');
expect(isempty(cc_pose_index([-1 0.6 0], CM)), 'a pose off the track has no node');

% ---- does the car fit? (the test CAR_NEIGHBORS is built on) -----------
expect(cc_pose_free(CM, 3.5, 0.6, 0), ...
    'the car fits at the start pose, pointing along the straight');
expect(~cc_pose_free(CM, 3.5, 0.6, pi/2), ...
    'and does NOT fit turned across that same corridor');
% ^ one position, two answers. A map of free and blocked cells could
%   never say that, and that is the whole of chapter 08.
expect(~cc_pose_free(CM, 6.45, 1.5, 0), 'nose in the outer wall: does not fit');
expect(~cc_pose_free(CM, -1, 0.6, 0), 'off the track counts as blocked');

% ---- the practice track loads too -------------------------------------
Po = cc_params('Track', 'oval');
To = cc_track(Po);
expect(To.R == 40 && To.C == 64, 'the oval is 40 by 64 planning cells');
expect(To.M(To.s) == 0, 'its start cell is free');
expect(all(To.M(To.cp) == 0), 'its checkpoints are free');
CMo = cc_car_model(To, Po, @cc_primitives_probe);
expect(cc_pose_free(CMo, Po.start(1), Po.start(2), Po.start(3)), ...
    'and the car fits on its start pose');

% ---- line of sight ----------------------------------------------------
expect(cc_free_line([3.0 0.6], [3.4 0.6], T), 'a short line along the straight is free');
expect(~cc_free_line([3.0 0.6], [3.0 1.2], T), 'a line through the inner wall is not');

% ---- the speed profile ------------------------------------------------
s = (0:0.04:2).';
straight = [s, zeros(size(s))];
vS = cc_speed_profile(straight, P);
expect(all(abs(vS - vS(1)) < 1e-9) || max(vS) > 3, 'a straight is driven at full speed');

ang = (0:0.02:pi).';
circle = [0.4*cos(ang), 0.4*sin(ang)];
[vC, kC] = cc_speed_profile(circle, P);
expect(abs(median(kC) - 1/0.4) < 0.02, 'the curvature of a 0.4 m circle comes out as 1/0.4');
expect(max(vC) < 0.6 * vTop, 'a 0.4 m circle is limited by grip, not by the motor');
expect(abs(median(vC) - sqrt(P.ayMax*0.4)) < 0.02, ...
    'and the limit is sqrt(a_y,max * R) = 1.77 m/s');

% 'AyMax' is what makes step 6 of chapter 10 possible: the grip
% the profile PLANS with, separate from the grip the car has.
vHalf = cc_speed_profile(circle, P, 'AyMax', 0.25*P.ayMax);
expect(abs(median(vHalf) - 0.5*median(vC)) < 0.02, ...
    'planning with a quarter of the grip halves the corner speed');

% ---- the tuning bench ------------------------------------------------
cfg = cc_tuning_defaults();
expect(numel(fieldnames(cfg)) == 8, 'there are eight tuning values');
expect(cfg.safety == P.safety, 'and they start where cc_params has them');

ok = false;
try
    bad = cfg;  bad.notAKnob = 1;
    cc_scorecard(bad, 'Reserve', false);
catch err
    ok = strcmp(err.identifier, 'cc_scorecard:unknown');
end
expect(ok, 'cc_scorecard refuses a tuning value that does not exist');

% ---- clearance: measured against a case whose answer is known --------
% The car standing at the start pose, in a corridor whose walls are at
% known y. Nothing is driven, so the answer is pure geometry.
stLog.t     = 0;
stLog.x     = P.start(1);
stLog.y     = P.start(2);
stLog.theta = P.start(3);
dStand = cc_clearance(T, stLog, 'Every', 1);
expect(dStand > 0, 'the car is not touching a wall where it starts');
expect(dStand < 0.5, 'and it is not in open country either');

% Turn it across the corridor and it must be worse off -- the same pose
% pair CC_POSE_FREE disagrees about, five lines up.
crossLog       = stLog;
crossLog.theta = pi/2;
expect(cc_clearance(T, crossLog, 'Every', 1) < dStand, ...
    'turned across the corridor, the body is closer to a wall');
end
