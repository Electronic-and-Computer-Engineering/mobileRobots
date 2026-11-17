% EXPERIMENT_OPEN_PRIORITY — A node is selected by its numeric key.
% TASK: Predict the exit order, run, then modify ONLY one key and rerun.
% This experiment requires the 'minkey' mode, not FIFO or LIFO.

clearvars
OPEN = open_new('minkey');
nodes = [5 2 7];
keys  = [10 3 6];                      % TASK: Change 10 to 1.

for k = 1:numel(nodes)
    OPEN = open_push(OPEN,nodes(k),keys(k));
    fprintf('Inserted node %d with key %g; count=%d\n', ...
        nodes(k),keys(k),open_size(OPEN));
end
while ~open_isempty(OPEN)
    [OPEN,u,key] = open_pop(OPEN);   % Third output returns the key.
    fprintf('Removed node %d (key %g); remaining=%d\n', ...
        u,key,open_size(OPEN));
end

% OPTIONAL TASK: Explore duplicates. No automatic replacement happens.
OPEN = open_new('minkey');
OPEN = open_push(OPEN,4,9);
OPEN = open_push(OPEN,4,2);
fprintf('Same node twice: waiting entries = %d\n',open_size(OPEN));
[OPEN,a,ka] = open_pop(OPEN);
[OPEN,b,kb] = open_pop(OPEN);
fprintf('First %d (key %g), then %d (key %g)\n',a,ka,b,kb);
% CHECKPOINT: How does this help Dijkstra and A* choose the next node?
