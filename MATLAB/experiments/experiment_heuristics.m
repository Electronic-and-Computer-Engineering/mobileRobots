% EXPERIMENT_HEURISTICS — Estimate remaining distance, ignore obstacles.
% TASK: Predict the Manhattan distance before calling MATLAB.
clearvars
R=5; C=6;
u=sub2ind([R C],2,2);
t=sub2ind([R C],4,5);
kind='manhattan';                % TASK: Try 'octile', 'euclid', 'zero'.
hfun=grid_heuristic(kind,R,C,t); % Returns FUNCTION HANDLE, not a number.
fprintf('%s: h(u)=%g; h(goal)=%g\n',kind,hfun(u),hfun(t));
% TASK: Change the target coordinate (4,5), then recalculate hfun.
% CHECKPOINT: Why does adding a wall NOT change this estimate?
