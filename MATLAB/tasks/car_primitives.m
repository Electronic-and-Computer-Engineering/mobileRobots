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
%   TODO 3 -- INTEGRATE ALONG THE ARC
%
%   This one you write yourself. The rule is three sentences:
%
%     - Walk the arc in nSub equal steps of ds = P.arc/nSub.
%     - Over each step the heading advances by dthdS*ds, and the car
%       moves ds in the direction it is TRAVELLING, which is theta+beta
%       and not theta.
%     - For the position step use the heading in the MIDDLE of the step,
%       not at its start and not at its end.
%
%   That third point is worth thinking about before you code it. The
%   heading at the end of the step makes every arc bend too early; the
%   heading at the start makes it bend too late. The middle cancels both
%   to first order, and at four steps it matches the simulator to under
%   a tenth of a millimetre -- while the start-of-step version misses a
%   full-lock arc by 5.8 mm, with the heading still coming out right.
%
%   CHECK_CAR_PRIMITIVES compares your arcs against the simulator, and
%   DEMO_MY_MOTION_SPACE draws them, which is usually faster than
%   reading a table of numbers.
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
    % inside it, and the order matters: work out the MIDDLE heading of
    % this step before you advance th, or you have lost the value you
    % needed.
    x = 0; y = 0; th = 0;
    pts = zeros(nSub, 3);
    for q = 1:nSub

        % (a) the heading in the middle of this step
        thMid = th;                 % <-- TODO 3a

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
