function log = cc_simulate(T, ref, varargin)
%CC_SIMULATE  Drive the planned route and bring back a lap time.
%
%   log = CC_SIMULATE(T, ref)
%   log = CC_SIMULATE(T, ref, 'MaxTime', 90, 'Controller', @myController)
%
%   T    the track from CC_TRACK
%   ref  the route to follow: N-by-3, [x y vTarget] in metres and m/s
%
%   Options:
%     'MaxTime'     give up after this many seconds (default 90)
%     'Controller'  a function [u, ctl] = f(st, ref, ctl, P)
%                   (default @cc_pure_pursuit)
%     'Params'      your own CC_PARAMS struct
%
%   log  .t .x .y .theta .v .delta   one row per step
%        .u                          what was commanded, N-by-2
%        .ay .slipping               grip demanded, and whether it held
%        .lapTime                    seconds, NaN if the lap was not closed
%        .crashed                    true if the body touched a wall
%        .crashAt                    [x y] where, if it did
%        .finished                   true if the car got round
%
%   THE LOOP IS THE SAME SIX LINES AS THE REAL SIMULATOR
%       ask the controller   ->   step the car   ->   did it crash?
%       ->   did it cross the line?   ->   write it down   ->   again
%   at 25 Hz, exactly like +env/run_proc.m. What changed is only WHERE
%   the controller gets its information: the original reads three
%   infrared sensors and reacts; this one reads a route it planned in
%   advance. Reacting versus planning -- that is the whole difference
%   between the two labs.
%
%   NOTHING IS DRAWN HERE. The run produces numbers; CC_PLOT_TRACK and
%   CC_ANIMATE_LAP draw them afterwards. That way a hundred runs with
%   different settings cost a second, not a minute of animation.
%
%   See also CC_PURE_PURSUIT, CC_STEP, CC_PLOT_TRACK, CC_ANIMATE_LAP.

q = inputParser();
q.addParameter('MaxTime', 90);
q.addParameter('Controller', @cc_pure_pursuit);
q.addParameter('Params', []);
q.parse(varargin{:});
o = q.Results;

P = o.Params;
if isempty(P), P = T.P; end

if size(ref,2) < 3
    error('cc_simulate:ref', ...
        'ref must be N-by-3: [x y vTarget]. Use CC_SPEED_PROFILE for column 3.');
end

nMax = ceil(o.MaxTime / P.dt);

st.x     = P.start(1);
st.y     = P.start(2);
st.theta = P.start(3);
st.v     = 0;
st.delta = 0;

log.t        = zeros(nMax,1);
log.x        = zeros(nMax,1);
log.y        = zeros(nMax,1);
log.theta    = zeros(nMax,1);
log.v        = zeros(nMax,1);
log.delta    = zeros(nMax,1);
log.u        = zeros(nMax,2);
log.ay       = zeros(nMax,1);
log.slipping = false(nMax,1);

ctl      = [];
crossed  = false;
armed    = false;
lapTime  = NaN;
crashed  = false;
crashAt  = [NaN NaN];
finished = false;

% The finish line is the start line: the car has done a lap when it comes
% back past x = P.finishX travelling forwards, in the bottom straight.
% It has to be ARMED first -- the car is standing on the line at t = 0,
% and a lap that is over before it starts is not a lap.
totalLen = sum(hypot(diff(ref(:,1)), diff(ref(:,2))));

k = 0;
for n = 1:nMax
    [u, ctl] = o.Controller(st, ref, ctl, P);

    xPrev = st.x;
    [st, info] = cc_step(st, u, P);

    k = n;
    log.t(n)        = (n-1) * P.dt;
    log.x(n)        = st.x;
    log.y(n)        = st.y;
    log.theta(n)    = st.theta;
    log.v(n)        = st.v;
    log.delta(n)    = st.delta;
    log.u(n,:)      = u;
    log.ay(n)       = info.ay;
    log.slipping(n) = info.slipping;

    % ---- did the body touch a wall? ----------------------------------
    out = cc_car_outline(st, P);
    for e = 1:4
        if ~cc_free_line(out(e,:), out(e+1,:), T, true)
            crashed = true;
            crashAt = [st.x, st.y];
            break
        end
    end
    if crashed, break, end

    % ---- arm, then time the crossing ---------------------------------
    travelled = 0;
    if ctl.i > 1
        travelled = sum(hypot(diff(ref(1:ctl.i,1)), diff(ref(1:ctl.i,2))));
    end
    if ~armed && travelled > 0.5 * totalLen
        armed = true;
    end
    if armed && ~crossed && ...
            xPrev < P.finishX && st.x >= P.finishX && ...
            st.y >= P.finishY(1) && st.y <= P.finishY(2)
        crossed  = true;
        lapTime  = log.t(n);
        finished = true;
    end

    if crossed
        break
    end
end

f = 1:k;
log.t        = log.t(f);
log.x        = log.x(f);
log.y        = log.y(f);
log.theta    = log.theta(f);
log.v        = log.v(f);
log.delta    = log.delta(f);
log.u        = log.u(f,:);
log.ay       = log.ay(f);
log.slipping = log.slipping(f);

log.lapTime  = lapTime;
log.crashed  = crashed;
log.crashAt  = crashAt;
log.finished = finished;
log.ref      = ref;
log.P        = P;
end
