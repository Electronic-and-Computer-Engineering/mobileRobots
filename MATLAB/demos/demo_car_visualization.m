%DEMO_CAR_VISUALIZATION  Understand the supplied path-animation helper.
% See ANLEITUNGEN/08_car_in_maze.md before implementing car_in_maze.
M = zeros(5,7);
M(3,3:5) = 1;
% This path goes above the obstacles, then down toward the goal.
rr = [2 2 2 2 2 3 4 4];
cc = [2 3 4 5 6 6 6 7];
path = sub2ind(size(M),rr,cc);
animate_car_grid(M,path,'StepPause',0.15);
% Experiment: change StepPause to 0.02, then change the obstacle positions.
% Does animation speed change the path cost? Why not?
