% EXPERIMENT_GRID_INDEXING — Convert row/column to MATLAB node ID.
% TASK: Predict the index of (row=2,col=3) in a 3-by-4 matrix.
clearvars
M=[0 0 0 0; 0 1 0 0; 0 0 0 0];
u=sub2ind(size(M),2,3);
[r,c]=ind2sub(size(M),u);
fprintf('Grid is %d x %d. Cell (2,3) -> index %d -> (%d,%d).\n', ...
    size(M,1),size(M,2),u,r,c);
disp('Linear node IDs (MATLAB column-major ordering):');
disp(reshape(1:numel(M),size(M)));
% TASK: Change ONLY the row argument of sub2ind from 2 to 1.
% CHECKPOINT: Why does adding one column change an index by num rows?
