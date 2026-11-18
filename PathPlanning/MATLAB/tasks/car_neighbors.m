function [nb, w, poses] = car_neighbors(CM, pose)
%CAR_NEIGHBORS  The poses the car can reach from here. YOUR EXERCISE.
%
%   [nb, w, poses] = CAR_NEIGHBORS(CM, pose)
%
%   CM      the car model from CC_CAR_MODEL
%   pose    [x y theta] -- where the car is, and which way it points
%
%   nb      node numbers of the reachable poses      (1-by-n)
%   w       what each of those moves costs, in metres (1-by-n)
%   poses   the reachable poses themselves            (n-by-3)
%
%   ------------------------------------------------------------------
%   THE SECOND OF THE TWO FILES YOU WRITE IN THIS CHAPTER
%
%   CAR_PRIMITIVES worked out WHAT the car's five moves are. This file
%   decides WHERE they lead from a given pose and WHETHER the car fits
%   along the way. The search, the simulator, the controller and the
%   collision test are all given; this is the step where the vehicle
%   model decides what counts as a neighbour.
%
%   Compare it with chapter 01:
%
%       [nb, w] = graph_neighbors(W, u)       asks a TABLE
%       [nb, w] = car_neighbors(CM, pose)     asks the CAR
%
%   Same outputs, same place in the loop. Your A* does not care where
%   the neighbours came from -- it never did.
%
%   ------------------------------------------------------------------
%   WHAT YOU HAVE TO WORK WITH
%
%   CM.prim(k) is one motion primitive: "hold this steering angle and
%   drive CM.P.arc metres". It comes from YOUR CAR_PRIMITIVES, in the
%   CAR'S OWN FRAME -- as if the car sat at (0, 0) pointing along +x:
%
%       pr.dx, pr.dy, pr.dth   where that move ends up
%       pr.pts                 the same arc as 4 intermediate poses,
%                              one row each: [x y theta]
%       pr.cost                what the move costs
%
%   Run CHECK_CAR_PRIMITIVES first: if those five are wrong, nothing
%   you write here can be right.
%
%   You are also given:
%       cc_pose_free(CM, x, y, theta)   does the whole car fit there?
%       cc_pose_index([x y theta], CM)  the node number of a pose, or []
%
%   ------------------------------------------------------------------
%   TODO 1 -- PUT THE PRIMITIVE WHERE THE CAR IS
%
%   pr.dx and pr.dy are measured in the car's frame. The car is at
%   (x, y) pointing at th, so the move has to be TURNED by th and then
%   MOVED to (x, y). That is the plane rotation you already know,
%
%       x' = x*cos(th) - y*sin(th)
%       y' = x*sin(th) + y*cos(th)
%
%   applied to (pr.dx, pr.dy) and then offset by the car's position.
%   The heading simply adds. ct and sn are computed for you above; they
%   do not change inside the loop.
%
%   > Forgetting to rotate dy is the mistake almost everyone makes, and
%   > it hides well: with the car pointing along +x, sin(th) is 0 and
%   > everything looks right. It only breaks once the car turns -- and
%   > then the route comes apart in the corners, which is where you were
%   > going to blame the controller.
%
%   TODO 2 -- CHECK THE WHOLE ARC, NOT JUST THE END
%
%   A primitive is 11.9 cm of driving and the car is 22 cm long. Every
%   row of pr.pts is a pose [x y theta] in the CAR'S frame. Move each
%   one into the world with the same transform as TODO 1, hand it to
%   cc_pose_free, and stop as soon as one of them does not fit.
%
%   You will write that transform twice, here and in TODO 1. If that
%   irritates you, you have understood something: put it in a local
%   function at the bottom of this file and call it from both.
%
%   > Checking only the end point lets the car cut straight through a
%   > wall corner and arrive somewhere perfectly legal.
%
%   TODO 3 -- NODE NUMBER AND COST
%
%   cc_pose_index gives the node number, or [] if the move left the
%   track. Skip those. The cost is pr.cost.
%
%   ------------------------------------------------------------------
%   CHECK ONE MOVE BY HAND
%   At the start pose the car points along +x, so ct is 1 and sn is 0:
%   a wrong rotation still looks right there. Use a pose that points up.
%
%       pose = [2.90  1.00  pi/2]        ct = 0,  sn = 1
%
%       the +22 deg move ends at        (2.85441, 1.10914)
%       with the rotation left out      (3.00914, 1.04559)
%
%   Those are 17 cm apart, in different directions.
%
%   See it:      demo_my_motion_space
%   Check with:  check_car_neighbors
%   Then:        run('experiments/experiment_oval_lap.m')
%   Guide:       ANLEITUNGEN/08_vehicle_neighbors.md

x  = pose(1);
y  = pose(2);
th = pose(3);

ct = cos(th);
sn = sin(th);

m     = numel(CM.prim);
nb    = zeros(1, m);
w     = zeros(1, m);
poses = zeros(m, 3);
kept  = 0;

for k = 1:m
    pr = CM.prim(k);

    % ---- TODO 2: is the car clear all the way along the arc? ----------
    % pr.pts is nSub-by-3: one pose [x y theta] per row, in the CAR's
    % frame. The loop is here; three statements are missing inside it.
    ok = true;
    for q = 1:size(pr.pts, 1)

        % (a) this row, moved into the world -- the same transform you
        %     will write again in TODO 1
        % px = ...                  % <-- TODO 2a
        % py = ...                  % <-- TODO 2b

        % (c) if the car does not fit there, this primitive is out.
        %     cc_pose_free(CM, px, py, theta) answers it. Remember that
        %     the heading of this row is th + pr.pts(q,3).
        % if ~cc_pose_free(...)     % <-- TODO 2c
        %     ok = false;
        %     break
        % end
    end

    if ~ok
        continue
    end

    % ---- TODO 1: where does this primitive put the car? ---------------
    % Three statements. Two of them need ct and sn; the third does not.
    nx  = x;                        % <-- TODO 1a
    ny  = y;                        % <-- TODO 1b
    nth = th;                       % <-- TODO 1c

    % ---- TODO 3: the node number and the cost -------------------------
    % cc_pose_index is given. Only the cost is missing, and CM.prim(k)
    % already carries it.
    idx = cc_pose_index([nx ny nth], CM);
    if isempty(idx)
        continue
    end

    kept          = kept + 1;
    nb(kept)      = idx;
    w(kept)       = 0;              % <-- TODO 3
    poses(kept,:) = [nx, ny, nth];
end

nb    = nb(1:kept);
w     = w(1:kept);
poses = poses(1:kept, :);

error('task:todo', 'Complete tasks/car_neighbors.m -- see ANLEITUNGEN/08_vehicle_neighbors.md');
end
