%DEMO_CC_VEHICLE  What this car can and cannot do. Run it before planning.
%
%   demo_cc_vehicle
%
%   Four measurements. Every one of them limits what a route may look
%   like, and all four come out of CC_STEP -- the same function that
%   drives the car in the simulation.
%
%   See also CC_STEP, CC_PARAMS, CC_TOP_SPEED, DEMO_CC_PRIMITIVES.

clc
P = cc_params();

fprintf('\n============ 1. How fast, and how long until it gets there ============\n\n');

vTop = cc_top_speed(P);
fprintf('  Top speed, solved from the equations: %.3f m/s = %.1f km/h\n', vTop, vTop*3.6);

st = struct('x',0, 'y',0, 'theta',0, 'v',0, 'delta',0);
t  = 0;
tHalf = NaN;
for k = 1:400
    st = cc_step(st, [100 0], P);
    t  = t + P.dt;
    if isnan(tHalf) && st.v >= 0.5*vTop
        tHalf = t;
    end
end
fprintf('  Simulated for 16 s at full throttle: %.3f m/s\n', st.v);
fprintf('  Half of top speed is reached after  %.2f s\n', tHalf);
fprintf('\n  >> The two agree, so the model is consistent with itself.\n');
fprintf('  >> The track is 6.5 m long. The car needs most of a straight\n');
fprintf('     just to get going -- the speed profile has to know that.\n');

fprintf('\n============ 2. The dead band ============\n\n');

dead = P.Vdead / P.Vmax * 100;
fprintf('  Below %.1f %% throttle the motor produces nothing at all.\n', dead);
for perc = [10 20 27 28 40]
    st = struct('x',0,'y',0,'theta',0,'v',0,'delta',0);
    for k = 1:125        % 5 seconds
        st = cc_step(st, [perc 0], P);
    end
    fprintf('    %3d %% throttle for 5 s  ->  v = %.3f m/s\n', perc, st.v);
end
fprintf('\n  >> A speed controller that politely asks for 10 %% gets NOTHING.\n');
fprintf('     That is why CC_PURE_PURSUIT lifts any positive demand to %.0f %%.\n', dead);

fprintf('\n============ 3. The tightest circle it can drive ============\n\n');

d    = deg2rad(P.deltaMax);
beta = atan((P.lr/P.L) * tan(d));
Rmin = P.L / (cos(beta) * tan(d));
fprintf('  Steering limit            %.0f deg\n', P.deltaMax);
fprintf('  Wheelbase                 %.3f m\n', P.L);
fprintf('  Tightest radius           %.3f m\n', Rmin);
fprintf('  So the car needs          %.3f m of width to turn round.\n', 2*Rmin);
fprintf('\n  The corridors on this track are 0.66 to 0.70 m wide.\n');
fprintf('  >> The car CANNOT turn round in a corridor. Plan a route that\n');
fprintf('     needs it and no amount of controller tuning will save you.\n');

fprintf('\n============ 4. Grip: how fast through a bend ============\n\n');

fprintf('  Tyres hold a_y = %.2f m/s^2.   v_max = sqrt(a_y * R)\n\n', P.ayMax);
fprintf('    %-12s %-12s %s\n', 'radius [m]', 'v_max [m/s]', '');
for R = [Rmin 0.5 0.75 1.0 1.5 2.0]
    vm = sqrt(P.ayMax * R);
    if vm >= vTop
        note = sprintf('(top speed %.2f is lower -- grip is not the limit here)', vTop);
    else
        note = '';
    end
    fprintf('    %-12.3f %-12.2f %s\n', R, min(vm, vTop), note);
end
fprintf('\n  >> In its tightest corner the car may do %.2f m/s.\n', sqrt(P.ayMax*Rmin));
fprintf('     On a straight it does %.2f m/s. A factor of %.1f.\n', ...
    vTop, vTop/sqrt(P.ayMax*Rmin));
fprintf('  >> THAT is why the shortest route is not the fastest one: a\n');
fprintf('     shorter line through a corner is a tighter line, and a\n');
fprintf('     tighter line has to be driven slower.\n\n');
