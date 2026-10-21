% EXPERIMENT_OPEN_FIFO_LIFO — FIFO and LIFO: which node leaves OPEN next?
% TASK: Run this script, then change ONLY the mode to 'lifo' and run again.
% Predict the extraction order before each run.
% A search stores discovered nodes in OPEN until they are processed.

clearvars
mode = 'fifo';                         % TASK: Change to 'lifo'.
OPEN = open_new(mode);                % Create an EMPTY container.
fprintf('New OPEN: count=%d, empty=%d\n', ...
    open_size(OPEN), open_isempty(OPEN));

nodes = [4 2 7];
for k = 1:numel(nodes)
    OPEN = open_push(OPEN, nodes(k)); % SAVE the returned OPEN!
    fprintf('After push %d: count=%d, empty=%d\n', ...
        nodes(k), open_size(OPEN), open_isempty(OPEN));
end
% MATLAB's size/isempty see the 1x1 struct, not its waiting entries.
fprintf('MATLAB size(OPEN) = [%d %d]; open_size(OPEN) = %d\n', ...
    size(OPEN,1),size(OPEN,2),open_size(OPEN));

% open_pop returns TWO values: changed OPEN and the removed node u.
while ~open_isempty(OPEN)
    before = open_size(OPEN);
    [OPEN,u] = open_pop(OPEN);
    fprintf('pop -> %d; count %d -> %d\n', u, before, open_size(OPEN));
end
fprintf('End: count=%d, empty=%d\n',open_size(OPEN),open_isempty(OPEN));
fprintf('MATLAB isempty(OPEN) = %d; open_isempty(OPEN) = %d\n', ...
    isempty(OPEN),open_isempty(OPEN));
% CHECKPOINT: Why is checking open_isempty useful before open_pop?
