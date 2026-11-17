function prim = cc_primitives_probe(P)
%CC_PRIMITIVES_PROBE  The motion space, measured by driving the simulator.
%
%   prim = CC_PRIMITIVES_PROBE(P)
%
%   Same struct as CAR_PRIMITIVES. This one does not use the formula: it
%   holds a steering angle, drives CC_STEP until the car has covered
%   P.arc metres, and writes down where it ended up.
%
%   WHY THIS EXISTS
%
%   You derive the motion space from the bicycle model and write it into
%   tasks/car_primitives.m. This function arrives at the same five moves
%   from the other direction, without the formula. If your formula and
%   this measurement disagree, one of the two is wrong -- and that is a
%   far more useful test than comparing your answer with a copy of the
%   answer.
%
%   CHECK_CAR_PRIMITIVES is the referee. It is also what CHECK_TOOLS
%   uses, so the toolbox can be tested before you have written anything.
%
%   THE ONE THING WORTH NOTICING
%   Change P.probeThrottle from 40 to 30 or to 100. The number of
%   simulator steps changes a lot; dx, dy and dtheta do not move. The
%   reason is the line this whole chapter turns on:
%
%       dtheta/ds = cos(beta) * tan(delta) / L
%
%   The speed cancelled. Driving the same arc faster does not make it a
%   different arc.
%
%   See also CAR_PRIMITIVES, CHECK_CAR_PRIMITIVES, CC_STEP.

if nargin < 1 || isempty(P), P = cc_params(); end

nSub = 4;

for k = 1:numel(P.steerLevels)
    delta     = P.steerLevels(k) * P.deltaMax;
    steerPerc = P.steerLevels(k) * 100;

    % The steering starts where it is supposed to be. The servo needs
    % 0.2 s to swing the full 22 degrees, and a probe only lasts about
    % half a second -- start at zero and a third of the measurement is
    % the servo moving, not the car turning.
    st = struct('x',0, 'y',0, 'theta',0, 'v',0, 'delta',delta);

    s     = 0;
    traj  = [0 0 0 0];             % [arcLength x y theta]
    guard = 0;
    while s < P.arc
        xPrev = st.x;
        yPrev = st.y;
        st = cc_step(st, [P.probeThrottle, steerPerc], P);
        s  = s + hypot(st.x - xPrev, st.y - yPrev);
        traj(end+1,:) = [s, st.x, st.y, st.theta];   %#ok<AGROW>

        guard = guard + 1;
        if guard > 2000
            error('cc_primitives_probe:stuck', ...
                ['The car has not covered %.3f m after 2000 steps.\n' ...
                 'P.probeThrottle is %.1f %%, and below %.2f %% the motor ' ...
                 'does nothing at all.'], ...
                P.arc, P.probeThrottle, P.Vdead/P.Vmax*100);
        end
    end

    % The last step overshot: the car does not stop on a round number.
    % Interpolate inside it, or the arc comes out 3 to 8 per cent too
    % long and full lock no longer turns exactly one heading step.
    cut = @(col) interp1(traj(:,1), traj(:,col), P.arc);

    pts = zeros(nSub, 3);
    for q = 1:nSub
        sq = P.arc * q / nSub;
        pts(q,:) = [interp1(traj(:,1), traj(:,2), sq), ...
                    interp1(traj(:,1), traj(:,3), sq), ...
                    interp1(traj(:,1), traj(:,4), sq)];
    end

    prim(k).delta = delta;                          %#ok<AGROW>
    prim(k).dx    = cut(2);                         %#ok<AGROW>
    prim(k).dy    = cut(3);                         %#ok<AGROW>
    prim(k).dth   = cut(4);                         %#ok<AGROW>
    prim(k).pts   = pts;                            %#ok<AGROW>
    prim(k).len   = P.arc;                          %#ok<AGROW>
    prim(k).cost  = P.arc + P.wSteer * abs(P.steerLevels(k));   %#ok<AGROW>
    prim(k).steps = size(traj,1) - 1;               %#ok<AGROW>
end
end
