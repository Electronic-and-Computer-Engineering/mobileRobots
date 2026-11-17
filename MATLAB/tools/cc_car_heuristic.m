function h = cc_car_heuristic(pose, goalXY)
%CC_CAR_HEURISTIC  The estimate of what is still ahead, for the pose search.
%
%   h = CC_CAR_HEURISTIC(pose, goalXY)
%
%   pose     [x y theta], or an N-by-3 block of poses
%   goalXY   [x y] of the goal
%   h        straight-line distance, in metres
%
%   It is the SAME h as in chapter 06, in the same role: never an
%   overestimate, so A* still returns the cheapest route it can find.
%
%   WHY IT IS ALLOWED
%   The cost of a move is the distance driven. No route between two
%   points can be shorter than the straight line between them, so the
%   straight line never overestimates. Rule obeyed, A* stays honest.
%
%   WHY IT IS WEAK HERE, AND WHY THAT IS INTERESTING
%   The straight line knows nothing about the car. A goal 20 cm behind
%   the car looks 20 cm away -- and costs over a metre, because the car
%   has to swing out and come back. So the estimate is far too low
%   exactly where the car is in trouble, and A* explores a great deal
%   around tight spots. You can watch that happen: the expanded poses
%   pile up at the corners and thin out on the straights.
%
%   The honest fix is a heuristic that does know the track: flood the
%   grid outwards from the goal once with Dijkstra and look the answer
%   up. That is a well-known trick and a good exercise -- see chapter
%   10, "Try this".
%
%   See also GRID_HEURISTIC, CAR_NEIGHBORS.

if size(pose, 2) < 2
    error('cc_car_heuristic:pose', 'pose must be [x y theta] or N-by-3.');
end

h = hypot(pose(:,1) - goalXY(1), pose(:,2) - goalXY(2));
end
