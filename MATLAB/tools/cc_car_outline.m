function XY = cc_car_outline(st, P)
%CC_CAR_OUTLINE  The four corners of the car, in metres on the track.
%
%   XY = CC_CAR_OUTLINE(st, P)   returns a 5-by-2 list, first point
%                                repeated at the end so it draws closed
%
%   The reference point of the state (st.x, st.y) is the middle of the
%   body, the same point the original simulator draws the car around. The
%   body reaches P.bodyL/2 forwards and backwards and P.bodyW/2 to each
%   side, and the whole rectangle is turned by st.theta.
%
%   WHY THIS EXISTS
%   The planner thinks the car is a point. It is not: it is 22 by 10.5
%   centimetres. The walls were grown by half the WIDTH so a point-sized
%   planner stays honest sideways -- but the car is twice as long as it
%   is wide, and when it turns, the corners swing out. This outline is
%   what the collision check actually uses, against the REAL walls.
%
%   So a route can be perfectly legal for the planner and still put a
%   corner of the car into a wall. Finding that out is part of the lab.
%
%   See also CC_SIMULATE, CC_PLOT_TRACK, CC_STEP.

if nargin < 2 || isempty(P), P = cc_params(); end

hl = P.bodyL / 2;
hw = P.bodyW / 2;

local = [ hl,  hw;
          hl, -hw;
         -hl, -hw;
         -hl,  hw;
          hl,  hw];

ct = cos(st.theta);
sn = sin(st.theta);

XY = [st.x + local(:,1)*ct - local(:,2)*sn, ...
      st.y + local(:,1)*sn + local(:,2)*ct];
end
