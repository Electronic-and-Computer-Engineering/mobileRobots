%EXPERIMENT_CC_TUNING  Your tuning bench: fast against safe, measured.
%
%   run('experiments/experiment_cc_tuning.m')
%
%   Edit ONE struct at the top, run, read three numbers. Then argue with
%   them.
%
%   The three numbers are deliberately not combinable into one score.
%   Anybody can hand you a formula that turns "fast" and "safe" into a
%   single figure of merit; the formula is where the engineering judgment
%   gets hidden. Here it stays in the open, and it stays yours.
%
%   See also CC_TUNING_DEFAULTS, CC_SCORECARD, CC_CLEARANCE.

clc
trace_on('off');

%% ======================================================================
%  YOUR SETTINGS -- this is the only block you edit
%  ======================================================================
cfg = cc_tuning_defaults();

% cfg.safety = 0.05;
% cfg.ayPlan = 1.00;
% cfg.ABrake = 2.5;
% cfg.AAccel = 2.0;
% cfg.Ld0    = 0.16;
% cfg.kLd    = 0.08;
% cfg.LdMax  = 0.35;
% cfg.kv     = 90;

% ======================================================================

fprintf('\n');
fprintf('  safety %.3f m   ayPlan %.0f %%   ABrake %.1f   AAccel %.1f\n', ...
    cfg.safety, 100*cfg.ayPlan, cfg.ABrake, cfg.AAccel);
fprintf('  Ld %.2f + %.2f*v, capped %.2f m   kv %d\n\n', ...
    cfg.Ld0, cfg.kLd, cfg.LdMax, cfg.kv);

%% ---------- 1. the CrazyCar track ------------------------------------
fprintf('============ CrazyCar track ============\n\n');
tic
S = cc_scorecard(cfg);
fprintf('  (%.0f s of simulation)\n\n', toc);

if ~S.ok
    fprintf('  NO LAP: %s\n\n', S.why);
    fprintf('  That is a result, not a failure. Write down which value you\n');
    fprintf('  had just raised, and by how much.\n\n');
    return
end

fprintf('  LAP TIME        %6.2f s        <- make this small\n', S.lap);
fprintf('  CLEARANCE       %6.0f mm       <- room in SPACE, keep it large\n', 1000*S.clear);
fprintf('  GRIP RESERVE    %6.0f %%        <- room in GRIP, keep it low\n', 100*S.reserve);
fprintf('\n');
fprintf('  route           %6.2f m\n', S.route);
fprintf('  planning        %6d expansions\n', S.expansions);
fprintf('  top speed       %6.2f m/s   (the car can do %.2f)\n', ...
    max(S.log.v), cc_top_speed(S.T.P));
fprintf('  at the grip limit in %d of %d steps\n', ...
    sum(S.log.slipping), numel(S.log.t));

fprintf('\n  How to read the reserve: %.0f %% means this setup still gets\n', ...
    100*S.reserve);
if S.reserve >= 1.0
    fprintf('  round only with the full modelled grip -- it already failed on\n');
    fprintf('  the first rung of the ladder, at 95 %%. On a real car, which is\n');
    fprintf('  always a few per cent worse than its model, that is no margin.\n');
else
    fprintf('  round with tyres %.0f %% worse than the model. That is what you\n', ...
        100*(1-S.reserve));
    fprintf('  have in hand for a floor, a battery or a tyre you did not model.\n');
end

%% ---------- 2. does it transfer? --------------------------------------
fprintf('\n============ The practice oval, same settings ============\n\n');
O = cc_scorecard(cfg, 'Track', 'oval');
if O.ok
    fprintf('  lap %.2f s, clearance %.0f mm, reserve %.0f %%\n', ...
        O.lap, 1000*O.clear, 100*O.reserve);
    fprintf('\n  It transfers. A setup that only works on the track it was\n');
    fprintf('  tuned on is a fitted curve, not a controller.\n');
else
    fprintf('  NO LAP on the oval: %s\n', O.why);
    fprintf('\n  Worth pausing on. The oval is the EASY track -- every corner\n');
    fprintf('  on it is wider than anything on the CrazyCar circuit. A setup\n');
    fprintf('  that gets round the hard track and not the easy one has been\n');
    fprintf('  tuned to the specific walls of the hard one.\n');
end

%% ---------- 3. against the baseline ----------------------------------
base = cc_tuning_defaults();
if ~isequal(cfg, base)
    fprintf('\n============ Against the baseline ============\n\n');
    B = cc_scorecard(base);
    fprintf('  %-12s %10s %10s\n', '', 'baseline', 'yours');
    fprintf('  %-12s %9.2f s %9.2f s   %+.2f s\n', 'lap time', ...
        B.lap, S.lap, S.lap - B.lap);
    fprintf('  %-12s %8.0f mm %8.0f mm   %+.0f mm\n', 'clearance', ...
        1000*B.clear, 1000*S.clear, 1000*(S.clear - B.clear));
    fprintf('  %-12s %9.0f %% %9.0f %%   %+.0f pp\n', 'reserve', ...
        100*B.reserve, 100*S.reserve, 100*(S.reserve - B.reserve));
    fprintf('\n  A row that improved and a row that got worse is a TRADE.\n');
    fprintf('  Two rows that improved is a find -- check it on the oval\n');
    fprintf('  before you believe it.\n');
end

%% ---------- pictures --------------------------------------------------
figure('Name','Your lap','Position',[60 60 1120 520]);
cc_plot_track(S.T, 'Route', S.XY, 'Driven', S.log, 'Cars', 28, ...
    'Title', sprintf('%.2f s   clearance %.0f mm   reserve %.0f %%', ...
    S.lap, 1000*S.clear, 100*S.reserve));

[~, ~, dAll] = cc_clearance(S.T, S.log);
figure('Name','Where the room went','Position',[100 100 900 620]);

subplot(3,1,1)
plot(S.log.t, S.log.v, 'LineWidth', 1.6); hold on
plot(S.log.t, interp1(1:size(S.XY,1), S.vRef, ...
     linspace(1, size(S.XY,1), numel(S.log.t))), '--', 'LineWidth', 1.1);
ylabel('v [m/s]'); legend('driven','asked for','Location','best'); grid on
title('speed, grip, and distance to the nearest wall')

subplot(3,1,2)
plot(S.log.t, S.log.ay, 'LineWidth', 1.6); hold on
yline(S.T.P.ayMax, 'r--', 'the grip the car has');
yline(cfg.ayPlan * S.T.P.ayMax, ':', 'the grip you planned with');
ylabel('a_y [m/s^2]'); grid on

subplot(3,1,3)
tS = S.log.t(1:2:numel(S.log.t));
plot(tS(1:numel(dAll)), 1000*dAll, 'LineWidth', 1.6); hold on
yline(1000*min(dAll), 'r--', sprintf('%.0f mm', 1000*min(dAll)));
ylabel('clearance [mm]'); xlabel('t [s]'); grid on

fprintf('\n  The bottom trace is the one to look at. Every dip is a place\n');
fprintf('  where the lap was nearly over. Find the deepest one on the\n');
fprintf('  track picture and say what the car was doing there.\n\n');
