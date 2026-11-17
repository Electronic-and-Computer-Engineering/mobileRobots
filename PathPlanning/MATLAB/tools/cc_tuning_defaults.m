function cfg = cc_tuning_defaults()
%CC_TUNING_DEFAULTS  The eight numbers you are allowed to tune, and why.
%
%   cfg = CC_TUNING_DEFAULTS()
%
%   These are the values the lab has used up to now. They get round the
%   CrazyCar track in 12.16 s. Every one of them is a compromise someone
%   made, and this is the chapter where you get to disagree.
%
%   Hand this struct to CC_SCORECARD. Change one field, run it again,
%   and write down what moved.
%
%   ------------------------------------------------------------------
%   THE PLAN -- what route, with how much room
%
%   cfg.safety   [m]   how far the planner stays away from every wall.
%                      Bigger = a route further from the walls, and a
%                      CHEAPER search (a tighter map has fewer poses to
%                      expand). Too big and no route exists at all.
%
%   ------------------------------------------------------------------
%   THE SPEED PROFILE -- how fast to ask for, given that route
%
%   cfg.ayPlan   [x]   the fraction of the car's real grip you PLAN
%                      with. This is the single most dangerous knob in
%                      the lab, and the most tempting.
%
%                      1.00 = plan with exactly the grip the car has.
%                      0.80 = plan as if the tyres were 20 % worse:
%                             slower corners, a time penalty, and room
%                             left over if the real car is worse than
%                             the model.
%                      1.30 = plan as if they were 30 % BETTER than
%                             they are. The profile then asks for corner
%                             speeds the tyres cannot deliver. The car
%                             does not refuse -- it slides, which in
%                             this model means it keeps going straighter
%                             than the steering asked for.
%
%                      Above 1.0 you are not tuning. You are betting.
%
%   cfg.ABrake   [m/s^2]  how hard the profile may slow the car down.
%   cfg.AAccel   [m/s^2]  how hard it may speed it up.
%                      Both are limits the PROFILE respects, not limits
%                      the car has. Raise them and the profile plans
%                      later braking and earlier power. Raise them past
%                      what the motor and the tyres can do and the car
%                      falls behind its own plan -- which the controller
%                      then tries to make up for.
%
%   ------------------------------------------------------------------
%   THE CONTROLLER -- how to actually follow it
%
%   cfg.Ld0      [m]   lookahead when standing still
%   cfg.kLd      [s]   extra lookahead per m/s of speed
%   cfg.LdMax    [m]   the longest lookahead allowed
%                      Short: precise, twitchy, oscillates at speed.
%                      Long: calm, and cuts corners -- the car aims at a
%                      point that is already past the bend. Cutting a
%                      corner is how a lap gets fast AND how it finds a
%                      wall, which is the whole tension in this chapter.
%
%   cfg.kv   [%/(m/s)] throttle per m/s of speed error. Bigger = the car
%                      holds the planned speed more tightly, and the
%                      throttle chatters more.
%
%   ------------------------------------------------------------------
%   WHAT YOU MAY NOT CHANGE
%
%   P.ayMax, P.bodyL, P.bodyW, P.L, P.deltaMax, P.Vdead -- the car.
%   Tuning is choosing what to ask of a given car. Changing the car is
%   a different exercise, and an easier one.
%
%   See also CC_SCORECARD, EXPERIMENT_CC_TUNING, CC_SPEED_PROFILE,
%   CC_PURE_PURSUIT.

cfg.safety = 0.05;   % m
cfg.ayPlan = 1.00;   % fraction of P.ayMax
cfg.ABrake = 2.5;    % m/s^2
cfg.AAccel = 2.0;    % m/s^2
cfg.Ld0    = 0.16;   % m
cfg.kLd    = 0.08;   % s
cfg.LdMax  = 0.35;   % m
cfg.kv     = 90;     % percent per (m/s)
end
