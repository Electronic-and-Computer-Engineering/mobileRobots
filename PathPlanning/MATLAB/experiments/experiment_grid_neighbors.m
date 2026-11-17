% EXPERIMENT_GRID_NEIGHBORS — Compare legal 4/8-neighbour movement.
% TASK: Inspect the printed cell coordinates and edge costs.
clearvars
M=[0 0 0 0; 0 1 0 0; 0 0 0 0];
u=sub2ind(size(M),2,3);
conn=4;                         % TASK: Change to 8.
[nb,w]=grid_neighbors(M,u,conn,false);
fprintf('For conn=%d, neighbours [row col cost] are:\n',conn);
[rr,cc]=ind2sub(size(M),nb);
disp([rr(:) cc(:) w(:)]);

% Corner-cutting experiment. (1,1) is free, but the cells beside it
% are walls: reaching it diagonally from (2,2) squeezes between walls.
Mc=[0 1 0; 1 0 0; 0 0 0];
uc=sub2ind(size(Mc),2,2);
[nNo,~]=grid_neighbors(Mc,uc,8,false);
[nYes,~]=grid_neighbors(Mc,uc,8,true);
target=sub2ind(size(Mc),1,1);
fprintf('Diagonal to (1,1) allowed? corner cut OFF=%d, ON=%d\n', ...
    ismember(target,nNo),ismember(target,nYes));
% CHECKPOINT: Why can a plotted diagonal be physically impossible?
