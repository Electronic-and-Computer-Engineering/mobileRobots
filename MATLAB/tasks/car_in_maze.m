function [path, cost, stats] = car_in_maze(M, s, t, method, showAnimation)
%CAR_IN_MAZE  Student task: use YOUR search to drive a displayed car in a grid.
%
%   [path,cost,stats] = car_in_maze(M,s,t,'astar',true)
%
%   TODO 1  Call search_student_grid(M,s,t,method). Explain why this is
%           YOUR algorithm, whereas search_grid is the reference solver.
%   TODO 2  Handle an empty path (goal unreachable) before animation.
%   TODO 3  If showAnimation is true, use animate_car_grid(M,path).
%
%   Visual playback is not a physically valid steering trajectory.
%   Refer to ANLEITUNGEN/08_car_in_maze.md for the guided exercise.

if nargin < 4 || isempty(method), method = 'astar'; end
if nargin < 5 || isempty(showAnimation), showAnimation = true; end

% The following outputs are placeholders until you complete the task.
path  = [];
cost  = inf;
stats = struct();

error('task:todo', 'Complete tasks/car_in_maze.m using the lab instructions.');
end
