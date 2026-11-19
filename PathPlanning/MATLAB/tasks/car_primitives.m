function prim = car_primitives(P)
%CAR_PRIMITIVES  The car's motion space, from the bicycle model. YOUR TASK.
%
%   prim = CAR_PRIMITIVES(P)
%
%   P      the parameters from CC_PARAMS
%   prim   one entry per steering level, each a struct:
%            .delta   the steering angle held, in degrees
%            .dx .dy  where that move ends up, IN THE CAR'S OWN FRAME
%            .dth     how far the car turned, in radians
%            .pts     the same arc as 4 intermediate poses, one row each
%            .len     how far it drove along the arc (= P.arc)
%            .cost    what the move costs the search
%
%   WHAT A MOTION PRIMITIVE IS
%
%   Up to chapter 07 a node was a cell and a move was a step to a
%   neighbouring cell. For a car, a node is a POSE (x, y, theta) and a
%   move is: hold one steering angle and drive P.arc metres. Five
%   steering angles, five moves. That set is the car's MOTION SPACE, and
%   every route the planner can build is made of these five moves and
%   nothing else.
%
%   You compute them from the model, in the car's own frame: start at
%   the origin pointing along +x. CAR_NEIGHBORS will rotate them to
%   wherever the car actually is.
%
%   ------------------------------------------------------------------
%   TODO 1 -- THE SIDE SLIP ANGLE
%
%   The reference point (st.x, st.y) is the middle of the body, not the
%   rear axle. When the front wheels are turned, the middle of the car
%   does not travel in the direction the car is pointing: it travels at
%   an angle beta to it.
%
%       beta = atan( (P.lr / P.L) * tan(d) )          d in RADIANS
%
%   Set it to zero and every arc you compute is slightly wrong, always
%   in the same direction, and the planner will believe it for ever.
%
%   TODO 2 -- TURNING PER METRE DRIVEN
%
%   The bicycle model per SECOND is
%
%       theta_dot = (v / P.L) * cos(beta) * tan(d)
%
%   Divide by v to get turning per METRE driven:
%
%       dthdS = cos(beta) * tan(d) / P.L              radians per metre
%
%   The v cancelled. That one cancellation is why this whole chapter
%   works: the SHAPE of an arc does not depend on how fast it is driven,
%   so the search can plan in metres and leave the speed to chapter 09.
%
%   If you would rather picture it than differentiate it: held steering
%   means the car drives a CIRCLE, and the steering angle picks its
%   radius R = P.L / (cos(beta)*tan(d)). dthdS is exactly 1/R. Walking
%   ds along a circle of radius R turns you by ds/R -- which is what a
%   radian means. At full lock, R = 0.303 m.
%
%   TODO 3 -- WALK THE ARC, ONE STEP AT A TIME
%
%   No integral. nSub equal steps of ds = P.arc/nSub, and EVERY STEP IS
%   THE SAME FOUR STATEMENTS. Work out one step and the loop is written.
%
%   The number every step shares is its turn: dthdS*ds, the ds/R from
%   above. At full lock that is 0.09818 rad, or 5.63 deg, per step.
%
%     thMove  where THIS PIECE goes: th plus HALF the step's turn
%     th      where the CAR POINTS afterwards: th plus the whole turn
%     x       move ds from here, in the direction thMove + beta
%     y       the same, with sin instead of cos
%
%   Two names because they are two different things. th is a property of
%   the CAR and gets stored; thMove is a property of the straight PIECE
%   you are walking along, and is used once and thrown away.
%
%   Why half a step ahead: each piece replaces a bit of arc by the
%   straight line between its two ends, and that line points half the
%   bit's turn ahead of where the car points when it sets off.
%
%   THE ORDER: work out thMove before th is advanced, or the value you
%   needed is gone -- the slots below are in that order for this reason.
%   And the DIRECTION OF TRAVEL is thMove + beta, not thMove: the heading
%   says where the car points, beta is the angle between pointing and
%   moving. Leave beta out and a full-lock arc ends 23 mm off; use th
%   instead of thMove and it ends 5.8 mm off, with the heading still
%   coming out right.
%
%   CHECK_CAR_PRIMITIVES compares your arcs against the simulator, and
%   DEMO_MY_MOTION_SPACE draws them, which is usually faster than
%   reading a table of numbers.
%
%   IF IT DOES NOT COME OUT, CHECK ONE ITERATION
%   At full lock (delta = 22 deg) the values after the FIRST pass of
%   the loop are:
%
%       beta  = 0.19933      dthdS = 3.3002      ds = 0.02975
%       thMove = 0.04909      th    = 0.09818
%       x     = 0.02884      y     = 0.00731
%
%   beta and dthdS right but the first pass wrong -> TODO 3 alone.
%   th right but x and y wrong -> the "+ beta" is missing.
%
%   Store each of the nSub poses in pts -- CAR_NEIGHBORS tests all four
%   of them against the walls, not just the end of the arc.
%
%   ------------------------------------------------------------------
%   Check with:  check_car_primitives
%   Guide:       ANLEITUNGEN/08_vehicle_neighbors.md

if nargin < 1 || isempty(P), P = cc_params(); end

nSub = 4;
ds   = P.arc / nSub;

for k = 1:numel(P.steerLevels)
    delta = P.steerLevels(k) * P.deltaMax;      % degrees
    d     = deg2rad(delta);                     % radians

    % ---- TODO 1: the side slip angle ---------------------------------
    % One line. beta depends on d, P.lr and P.L.
    beta = 0;                       % <-- TODO 1 goes here

    % ---- TODO 2: turning per metre driven ----------------------------
    % One line. dthdS depends on beta, d and P.L.
    dthdS = 0;                      % <-- TODO 2 goes here      %#ok<NASGU>

    % ---- TODO 3: walk the arc in nSub steps --------------------------
    % The loop and the bookkeeping are here. Four statements are missing
    % inside it, and every step uses the same four. The turn of one step
    % is dthdS*ds; thMove is half a step further on than th, and th is a
    % whole step further on. Work out thMove BEFORE you advance th, or
    % you have lost the value you needed.
    x = 0; y = 0; th = 0;
    pts = zeros(nSub, 3);
    for q = 1:nSub

        % (a) the heading in the middle of this step
        thMove = th;                 % <-- TODO 3a

        % (b) advance the heading to the end of this step
        % th = ...                  % <-- TODO 3b

        % (c) move ds in the direction the car is TRAVELLING
        % x = ...                   % <-- TODO 3c
        % y = ...                   % <-- TODO 3d

        pts(q,:) = [x, y, th];      % given: record the pose
    end

    prim(k).delta = delta;                          %#ok<AGROW>
    prim(k).dx    = x;                              %#ok<AGROW>
    prim(k).dy    = y;                              %#ok<AGROW>
    prim(k).dth   = th;                             %#ok<AGROW>
    prim(k).pts   = pts;                            %#ok<AGROW>
    prim(k).len   = P.arc;                          %#ok<AGROW>
    prim(k).cost  = P.arc + P.wSteer * abs(P.steerLevels(k));   %#ok<AGROW>
    prim(k).steps = nSub;                           %#ok<AGROW>
end

error('task:todo', 'Complete tasks/car_primitives.m -- see ANLEITUNGEN/08_vehicle_neighbors.md');
end
