%DEMO_CC_PRIMITIVES  Watch the motion space appear, by driving the car.
%
%   demo_cc_primitives
%
%   RUN THIS BEFORE YOU WRITE tasks/car_primitives.m -- but note that it
%   is NOT the code you are about to write. Your task is to compute the
%   five arcs from the bicycle model. This script arrives at the same
%   five arcs the other way round: it holds a steering angle and drives
%   CC_STEP until the car has covered P.arc metres.
%
%   Seeing them appear is what makes the formula worth trusting, and it
%   is what CHECK_CAR_PRIMITIVES later judges your formula against.
%
%   It works before your file does, because it uses nothing from it.
%
%   See also CAR_PRIMITIVES, CC_PRIMITIVES_PROBE, CC_STEP.

clc
P = cc_params('Track', 'oval');
T = cc_track(P);

fprintf('\n============ 1. One probe, step by step ============\n\n');
fprintf('  Hold full lock, drive at %.0f %% throttle, and watch the\n', P.probeThrottle);
fprintf('  distance add up until it reaches P.arc = %.3f m.\n\n', P.arc);

delta     = P.deltaMax;              % hold the wheels at full lock
steerPerc = 100;

% The steering starts WHERE WE WANT IT, not at zero. The servo would
% need 0.2 s to swing there, and that swing is not part of the arc.
st = struct('x',0, 'y',0, 'theta',0, 'v',0, 'delta',delta);

s    = 0;
traj = [0 0 0 0];                    % [arcLength x y theta]

fprintf('  %-5s %-9s %-9s %-9s %-9s %s\n', 'step', 'v [m/s]', 'x [m]', 'y [m]', 'theta', 'arc so far');
n = 0;
while s < P.arc
    xPrev = st.x;  yPrev = st.y;
    st = cc_step(st, [P.probeThrottle, steerPerc], P);
    s  = s + hypot(st.x - xPrev, st.y - yPrev);
    traj(end+1,:) = [s, st.x, st.y, st.theta];   %#ok<SAGROW>
    n = n + 1;
    fprintf('  %-5d %-9.4f %-9.5f %-9.5f %+8.3f deg  %.5f\n', ...
        n, st.v, st.x, st.y, rad2deg(st.theta), s);
end

fprintf('\n  The last step overshot: %.5f m instead of %.5f m.\n', s, P.arc);
fprintf('  So cut the arc where it belongs, inside that step:\n\n');

dx  = interp1(traj(:,1), traj(:,2), P.arc);
dy  = interp1(traj(:,1), traj(:,3), P.arc);
dth = interp1(traj(:,1), traj(:,4), P.arc);

fprintf('      dx = %+.5f m    dy = %+.5f m    dtheta = %+.4f deg\n\n', dx, dy, rad2deg(dth));
fprintf('  One heading step of the search is %.2f deg.\n', 360/P.nTheta);
fprintf('  >> Full lock turns the car EXACTLY one heading step. P.arc was\n');
fprintf('     chosen for that, and it is why the search never has to round.\n');

fprintf('\n============ 2. The throttle does not matter ============\n\n');
fprintf('  %-10s %-8s %-11s %-11s %s\n', 'throttle', 'steps', 'dx [m]', 'dy [m]', 'dtheta');
for thr = [30 40 100]
    [a, b, c, steps] = local_probe(P, delta, thr);
    fprintf('  %-10s %-8d %+10.5f %+10.5f  %+8.4f deg\n', ...
        sprintf('%d %%', thr), steps, a, b, rad2deg(c));
end
fprintf('\n  >> Different journeys, the same shape. The number of steps\n');
fprintf('     changes by a factor of three and the arc does not move.\n');
fprintf('  >> A path''s SHAPE does not depend on how fast it is driven.\n');
fprintf('     That is what lets the planner work in metres and leave the\n');
fprintf('     speed to cc_speed_profile afterwards.\n');

fprintf('\n============ 3. Measurement against formula ============\n\n');
ref = cc_primitives_probe(P);
fprintf('  %-10s %-22s %s\n', 'steering', 'probed (this script)', 'cc_primitives_probe');
for k = 1:numel(P.steerLevels)
    dg = P.steerLevels(k) * P.deltaMax;
    [a, b, c] = local_probe(P, dg, P.probeThrottle);
    fprintf('  %+7.1f    dx %+.5f dth %+7.3f    dx %+.5f dth %+7.3f\n', ...
        dg, a, rad2deg(c), ref(k).dx, rad2deg(ref(k).dth));
end
fprintf('\n  >> Under a millimetre apart, and the angles agree to three\n');
fprintf('     decimals. They must: cc_step integrates the same equations.\n');

% ---- the picture ------------------------------------------------------
figure('Name','The motion space','Position',[80 80 1180 500]);

subplot(1,2,1)
hold on
col = [0.75 0.20 0.20; 0.90 0.55 0.20; 0.20 0.45 0.75; 0.90 0.55 0.20; 0.75 0.20 0.20];
for k = 1:numel(P.steerLevels)
    dg = P.steerLevels(k) * P.deltaMax;
    [~, ~, ~, ~, tr] = local_probe(P, dg, P.probeThrottle);
    plot(tr(:,2), tr(:,3), '-', 'Color', col(k,:), 'LineWidth', 2.2);
    plot(tr(end,2), tr(end,3), 'o', 'Color', col(k,:), 'MarkerFaceColor', col(k,:), 'MarkerSize', 6);
    text(tr(end,2)+0.004, tr(end,3), sprintf('%+.0f deg', dg), 'FontSize', 9);
end
out = cc_car_outline(struct('x',0, 'y',0, 'theta',0), P);
plot(out(:,1), out(:,2), '-', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.2);
axis equal, grid on
xlabel('x [m]'), ylabel('y [m]')
title(sprintf('Five probes of %.0f cm, read off the simulator', P.arc*100))
hold off

subplot(1,2,2)
cc_plot_track(T, 'Title', 'The same five moves, from the start pose');
hold on
pose = P.start;
for k = 1:numel(P.steerLevels)
    dg = P.steerLevels(k) * P.deltaMax;
    [~, ~, ~, ~, tr] = local_probe(P, dg, P.probeThrottle);
    ct = cos(pose(3));  sn = sin(pose(3));
    px = pose(1) + tr(:,2)*ct - tr(:,3)*sn;
    py = pose(2) + tr(:,2)*sn + tr(:,3)*ct;
    plot(px, py, '-', 'Color', col(k,:), 'LineWidth', 2.2);
end
axis([P.start(1)-0.25, P.start(1)+0.35, P.start(2)-0.25, P.start(2)+0.25])
hold off

fprintf('\n  Those five arcs are the car''s whole motion space. Now open\n');
fprintf('  tasks/car_primitives.m and compute them from the model instead:\n');
fprintf('      beta  = atan((P.lr/P.L) * tan(d))\n');
fprintf('      dthdS = cos(beta) * tan(d) / P.L\n');
fprintf('  then walk the arc in four steps. check_car_primitives compares\n');
fprintf('  your answer against the measurement you have just watched.\n\n');

% -----------------------------------------------------------------------
function [dx, dy, dth, steps, traj] = local_probe(P, delta, throttle)
%LOCAL_PROBE  One probe run. This is tasks/car_primitives.m in miniature.
st   = struct('x',0, 'y',0, 'theta',0, 'v',0, 'delta',delta);
s    = 0;
traj = [0 0 0 0];
guard = 0;
while s < P.arc
    xPrev = st.x;  yPrev = st.y;
    st = cc_step(st, [throttle, delta/P.deltaMax*100], P);
    s  = s + hypot(st.x - xPrev, st.y - yPrev);
    traj(end+1,:) = [s, st.x, st.y, st.theta];   %#ok<AGROW>
    guard = guard + 1;
    if guard > 2000
        error('demo_cc_primitives:stuck', ...
            'The car never covered %.3f m -- is the throttle above the dead band?', P.arc);
    end
end
dx    = interp1(traj(:,1), traj(:,2), P.arc);
dy    = interp1(traj(:,1), traj(:,3), P.arc);
dth   = interp1(traj(:,1), traj(:,4), P.arc);
steps = size(traj,1) - 1;
end
