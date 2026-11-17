% EXPERIMENT_RANDOM_MAPS — What does a fixed random seed accomplish?
% TASK: Generate the SAME map twice and compare via isequal.
clearvars
seed=7;
density=0.20;
[M1,s,t]=maze_obstacles(15,20,density,seed);
[M2,~,~]=maze_obstacles(15,20,density,seed);
fprintf('Same seed -> identical? %d\n',isequal(M1,M2));

% TASK: Change ONLY the seed below; predict whether the map changes.
M3=maze_obstacles(15,20,density,seed+1);
fprintf('Different seed -> identical? %d\n',isequal(M1,M3));
figure; plot_grid(M1,'Start',s,'Goal',t,'Title','Obstacle field');
% OPTIONAL TASK: Change density from 0.20 to 0.30, keeping the seed.
% OPTIONAL TASK: Compare with a perfect maze from maze_random(5,8,seed).
