function idx = cc_pose_index(pose, CM)
%CC_POSE_INDEX  Give a pose a node number the search can use.
%
%   idx = CC_POSE_INDEX([x y theta], CM)
%
%   Returns one whole number, or [] if the pose is off the track.
%
%   ------------------------------------------------------------------
%   WHY A POSE NEEDS A NUMBER AT ALL
%
%   Every search in this course does the same thing with `closed`:
%
%       if closed(u), continue, end
%
%   That line is what stops the search going round in circles, and it
%   needs a NUMBER to index with. On a grid the cell number was free --
%   the cell was the state. A pose is three real numbers; two poses are
%   never exactly equal, so without rounding, `closed` would never fire
%   and the search would run until memory ran out.
%
%   So the pose space is cut into boxes: 10 cm by 10 cm by 22.5 degrees.
%   Two poses in the same box count as the same state, and the cheaper
%   one wins.
%
%   HOW COARSE TO MAKE THE BOXES -- THE ONE REAL TRADE-OFF HERE
%     too COARSE  two genuinely different poses are declared identical.
%                 The search throws away a route it needed and reports
%                 that there is no way through a gap the car fits in.
%     too FINE    nothing is ever recognised as a repeat, the search
%                 explores for ever, and 30160 nodes become a million.
%
%   16 headings and 10 cm is a working compromise for THIS car on THIS
%   track. It is not a universal constant -- change the car and you
%   change it too.
%
%   The heading wraps: 359 degrees and 1 degree are one bin apart, not
%   358. Forgetting that is the classic bug here, and it shows up as a
%   search that refuses to drive in one particular direction.
%
%   See also CAR_NEIGHBORS, CC_CAR_MODEL.

x  = pose(1);
y  = pose(2);
th = pose(3);

% The 1e-9 keeps a point that sits exactly on a cell boundary from
% falling into the cell below -- see CC_WORLD2GRID for why that happens.
c = floor(x / CM.poseCell + 1e-9) + 1;
r = CM.R - floor(y / CM.poseCell + 1e-9);

if c < 1 || c > CM.C || r < 1 || r > CM.R
    idx = [];
    return
end

% mod() first, so that -0.1 rad lands in the last bin and not in bin -1
t = mod(round(th / CM.dTheta), CM.nTheta) + 1;

idx = sub2ind([CM.R, CM.C, CM.nTheta], r, c, t);
end
