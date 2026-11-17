%EXPERIMENT_CC_LAP  Plan a lap with your own search, then drive it.
%
%   run('experiments/experiment_cc_lap.m')
%
%   Six searches, one speed profile, one controller, one lap time.
%
%   See also CC_LAP_PLAN, ASTAR_CAR, CC_SPEED_PROFILE, CC_SIMULATE.

clc
P  = cc_params();
T  = cc_track(P);
CM = cc_car_model(T, P);

trace_on('off');

fprintf('\n============ 1. Plan ============\n\n');
tPlan = tic;
[poses, info] = cc_lap_plan(CM);
fprintf('  planning took %.1f s\n', toc(tPlan));

fprintf('\n============ 2. Speed profile ============\n\n');
XY = cc_resample_path(poses(:,1:2), 0.04);
[vRef, kappa] = cc_speed_profile(XY, P);

[kMax, iMax] = max(kappa);
fprintf('  route length          %.2f m\n', sum(hypot(diff(XY(:,1)), diff(XY(:,2)))));
fprintf('  tightest bend         R = %.3f m at (%.2f, %.2f)\n', ...
    1/kMax, XY(iMax,1), XY(iMax,2));
fprintf('  slowest point         %.2f m/s\n', min(vRef));
fprintf('  fastest point         %.2f m/s   (top speed is %.2f)\n', ...
    max(vRef), cc_top_speed(P));

fprintf('\n============ 3. Drive ============\n\n');
log = cc_simulate(T, [XY, vRef]);

if log.crashed
    fprintf('  CRASHED at (%.2f, %.2f) after %.2f s\n', ...
        log.crashAt(1), log.crashAt(2), log.t(end));
elseif log.finished
    fprintf('  LAP TIME              %.2f s\n', log.lapTime);
    fprintf('  average speed         %.2f m/s\n', ...
        sum(hypot(diff(log.x), diff(log.y))) / log.lapTime);
    fprintf('  top speed reached     %.2f m/s\n', max(log.v));
    fprintf('  tyres at the limit in %d of %d steps\n', sum(log.slipping), numel(log.t));
else
    fprintf('  did not close the lap within the time limit\n');
end

err = zeros(numel(log.t),1);
for k = 1:numel(log.t)
    err(k) = min(hypot(XY(:,1)-log.x(k), XY(:,2)-log.y(k)));
end
fprintf('  worst tracking error  %.0f mm   (average %.0f mm)\n', ...
    1000*max(err), 1000*mean(err));

%% ---------- pictures ---------------------------------------------------
figure('Name','The lap','Position',[60 60 1120 520]);
cc_plot_track(T, 'Route', XY, 'Driven', log, 'Cars', 28, ...
    'Title', sprintf('Lap in %.2f s  (route %.2f m, planned by astar_car)', ...
    log.lapTime, sum(hypot(diff(XY(:,1)), diff(XY(:,2))))));

figure('Name','Speed and steering','Position',[100 100 900 620]);
subplot(3,1,1)
plot(log.t, log.v, 'LineWidth', 1.6); hold on
plot(log.t, interp1(1:size(XY,1), vRef, ...
     linspace(1, size(XY,1), numel(log.t))), '--', 'LineWidth', 1.1);
ylabel('v [m/s]'); legend('driven','asked for','Location','best'); grid on
title('Where the car brakes, and why')

subplot(3,1,2)
plot(log.t, log.delta, 'LineWidth', 1.6)
ylabel('steering [deg]'); grid on
yline( P.deltaMax, ':'); yline(-P.deltaMax, ':');

subplot(3,1,3)
plot(log.t, log.ay, 'LineWidth', 1.6); hold on
yline(P.ayMax, 'r--', 'grip limit');
ylabel('a_y [m/s^2]'); xlabel('t [s]'); grid on

fprintf('\n  Look at the three traces together. Every dip in the speed\n');
fprintf('  trace sits under a peak in the steering trace -- that is the\n');
fprintf('  speed profile paying for curvature, exactly as designed.\n');
fprintf('\n  To watch it:  cc_animate_lap(T, log, ''Route'', XY)\n\n');
