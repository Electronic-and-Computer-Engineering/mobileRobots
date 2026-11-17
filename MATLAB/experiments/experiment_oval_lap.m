%EXPERIMENT_OVAL_LAP  A lap on the practice track, with YOUR car_neighbors.
%
%   run('experiments/experiment_oval_lap.m')
%
%   Short on purpose: a plain oval, a 6.3 m lap, a couple of seconds of
%   planning. Get this working before you touch the CrazyCar track --
%   when something is wrong there, you will not be able to tell whether
%   it is your code or the track.
%
%   Nothing here is yours except car_primitives and car_neighbors.
%   The search, the simulator and the controller are all given.
%
%   See also CAR_PRIMITIVES, CAR_NEIGHBORS, EXPERIMENT_CC_LAP.

clc
P  = cc_params('Track', 'oval');
T  = cc_track(P);
CM = cc_car_model(T, P);

trace_on('off');

fprintf('\n============ The practice track ============\n\n');
fprintf('  %.2f m by %.2f m, a plain loop\n', P.worldX, P.worldY);
fprintf('  planning cells   %d x %d\n', T.R, T.C);
fprintf('  pose space       %d x %d x %d headings = %d nodes\n', ...
    CM.R, CM.C, CM.nTheta, CM.nNodes);
fprintf('  corner radius    0.50 m along the lane centre\n');
fprintf('  the car needs    %.3f m at the very least\n', ...
    P.L / (cos(atan((P.lr/P.L)*tan(deg2rad(P.deltaMax)))) * tan(deg2rad(P.deltaMax))));

fprintf('\n============ 1. Plan ============\n\n');
tPlan = tic;
[poses, info] = cc_lap_plan(CM);
fprintf('  planning took %.1f s\n', toc(tPlan));

fprintf('\n============ 2. Drive ============\n\n');
XY = cc_resample_path(poses(:,1:2), 0.04);
[vRef, kappa] = cc_speed_profile(XY, P);
log = cc_simulate(T, [XY, vRef]);

fprintf('  route length   %.2f m\n', sum(hypot(diff(XY(:,1)), diff(XY(:,2)))));
fprintf('  tightest bend  R = %.3f m\n', 1/max(kappa));
fprintf('  speed          %.2f .. %.2f m/s\n', min(vRef), max(vRef));
if log.crashed
    fprintf('  CRASHED at (%.2f, %.2f) after %.2f s\n', ...
        log.crashAt(1), log.crashAt(2), log.t(end));
    fprintf('\n  On this track that should not happen. Run check_car_primitives\n');
    fprintf('  and check_car_neighbors.\n');
elseif log.finished
    fprintf('  LAP TIME       %.2f s\n', log.lapTime);
    fprintf('  top speed      %.2f m/s\n', max(log.v));
else
    fprintf('  did not close the lap within the time limit\n');
end

figure('Name','Practice lap','Position',[80 80 760 520]);
cc_plot_track(T, 'Route', XY, 'Driven', log, 'Cars', 20, ...
    'Title', sprintf('Practice track: %.2f m lap, driven in %.2f s', ...
    sum(hypot(diff(XY(:,1)), diff(XY(:,2)))), log.lapTime));

fprintf('\n  To watch it:  cc_animate_lap(T, log, ''Route'', XY)\n');
fprintf('  When this works, go to the real track:\n');
fprintf('      run(''experiments/experiment_cc_lap.m'')\n\n');
