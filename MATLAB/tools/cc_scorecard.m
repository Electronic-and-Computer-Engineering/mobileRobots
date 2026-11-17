function S = cc_scorecard(cfg, varargin)
%CC_SCORECARD  Judge one set of tuning values on three numbers at once.
%
%   S = CC_SCORECARD(cfg)
%   S = CC_SCORECARD(cfg, 'Track', 'oval', 'Verbose', true)
%
%   cfg   the eight tuning values -- see CC_TUNING_DEFAULTS
%   S     .lap       lap time in seconds, NaN if the lap did not close
%         .reserve   the grip reserve: the lowest fraction of the car's
%                    grip at which this setup still gets round
%         .clear     the smallest gap between body and wall, in metres
%         .ok        true if the lap closed without a crash
%         .why       what went wrong, if anything
%         .expansions / .route   what the planning cost and produced
%         .T .XY .vRef .log      so you can plot it
%
%   Options:
%     'Track'    'crazycar' (default) or 'oval'
%     'Reserve'  false to skip the grip ladder (eight times faster)
%     'Verbose'  print the planner's leg-by-leg trace
%
%   ------------------------------------------------------------------
%   THE THREE NUMBERS, AND WHY IT TAKES THREE
%
%   A lap time on its own is not a result. Any lap time can be improved
%   by asking the car for more than it has; the setup then gets round
%   once, in the simulator, with the model it was tuned against. The
%   question that matters is whether it would still get round if the
%   world were slightly worse than the model -- and that is a different
%   measurement.
%
%   .lap      what you are trying to make small.
%
%   .clear    how much room in SPACE the lap had. A lap that passed 4 mm
%             from a wall did not crash; it was lucky. See CC_CLEARANCE.
%
%   .reserve  how much room in GRIP it had. The same route and the same
%             controller are driven again with the tyres made weaker:
%             95 %, 90 %, 85 % ... of P.ayMax. The reserve is the lowest
%             value that still gets round, so LOW IS GOOD. 1.00 means
%             the setup failed on the first rung -- tyres 5 % worse than
%             the model already end the lap, and a real car is always a
%             few per cent worse than its model.
%
%   Tune one number and the other two move. That is the exercise.
%
%   See also CC_TUNING_DEFAULTS, CC_CLEARANCE, EXPERIMENT_CC_TUNING.

q = inputParser();
q.addParameter('Track', 'crazycar');
q.addParameter('Reserve', true);
q.addParameter('Verbose', false);
q.parse(varargin{:});
o = q.Results;

cfg = local_fill(cfg);

S = struct('lap', NaN, 'reserve', NaN, 'clear', NaN, 'ok', false, ...
           'why', '', 'expansions', NaN, 'route', NaN);
S.cfg = cfg;      % assigned separately: struct() with a struct value is
                  % one of those calls that works until it does not.

% ---- 1) plan ----------------------------------------------------------
P  = cc_params('Track', o.Track, 'safety', cfg.safety);
T  = cc_track(P);
CM = cc_car_model(T, P);

[poses, info] = cc_lap_plan(CM, 'Verbose', o.Verbose);

S.T          = T;
S.expansions = info.expansions;
S.XY         = cc_resample_path(poses(:,1:2), 0.04);
S.route      = sum(hypot(diff(S.XY(:,1)), diff(S.XY(:,2))));

% ---- 2) the speed profile, with the grip YOU chose to plan with -------
S.vRef = cc_speed_profile(S.XY, P, ...
    'ABrake', cfg.ABrake, 'AAccel', cfg.AAccel, ...
    'AyMax',  cfg.ayPlan * P.ayMax);

% ---- 3) drive ---------------------------------------------------------
S.log = local_drive(T, S.XY, S.vRef, cfg, 1.0);

if S.log.crashed
    S.why = sprintf('crashed at (%.2f, %.2f) after %.2f s', ...
        S.log.crashAt(1), S.log.crashAt(2), S.log.t(end));
    S.clear = 0;
    S.reserve = NaN;
    return
elseif ~S.log.finished
    S.why = 'did not close the lap inside the time limit';
    return
end

S.ok  = true;
S.lap = S.log.lapTime;

% ---- 4) how much room in space ---------------------------------------
S.clear = cc_clearance(T, S.log);

% ---- 5) how much room in grip ----------------------------------------
if o.Reserve
    S.reserve = 1.00;
    for frac = [0.95 0.90 0.85 0.80 0.75 0.70 0.65 0.60]
        % The same route and the same controller. Only the car is worse.
        Lw = local_drive(T, S.XY, S.vRef, cfg, frac);
        if Lw.finished && ~Lw.crashed
            S.reserve = frac;
        else
            break
        end
    end
end
end

% -----------------------------------------------------------------------
function log = local_drive(T, XY, vRef, cfg, gripFrac)
%LOCAL_DRIVE  One run. The plan never changes; only the car's grip does.
P = T.P;
P.ayMax = P.ayMax * gripFrac;

ctl0 = struct('Ld0', cfg.Ld0, 'kLd', cfg.kLd, 'LdMax', cfg.LdMax, ...
              'kv',  cfg.kv,  'i',   1,       'done',  false);

% CC_SIMULATE hands the controller an empty ctl on the first step and
% expects it to fill it in. CC_PURE_PURSUIT fills it with ITS defaults,
% which is exactly what we are trying to override -- so the seeding
% happens here, on the way in.
ctrl = @(st, ref, ctl, Pq) cc_pure_pursuit(st, ref, local_seed(ctl, ctl0), Pq);

log = cc_simulate(T, [XY, vRef], 'Controller', ctrl, 'Params', P);
end

% -----------------------------------------------------------------------
function ctl = local_seed(ctl, ctl0)
%LOCAL_SEED  Put the tuned gains in before the controller sees the gap.
if isempty(ctl)
    ctl = ctl0;
end
end

% -----------------------------------------------------------------------
function cfg = local_fill(cfg)
%LOCAL_FILL  Anything you left out keeps its default value.
d = cc_tuning_defaults();
f = fieldnames(d);
for k = 1:numel(f)
    if ~isfield(cfg, f{k}) || isempty(cfg.(f{k}))
        cfg.(f{k}) = d.(f{k});
    end
end
extra = setdiff(fieldnames(cfg), f);
if ~isempty(extra)
    error('cc_scorecard:unknown', ...
        ['There is no tuning value called "%s".\n' ...
         'The eight you may set are: %s'], extra{1}, strjoin(f, ', '));
end
end
