% EXPERIMENT_OPEN_RETURN_VALUES — Why must the returned OPEN be assigned?
% TASK: Compare Case A with Case B. Predict the effect before executing.
% MATLAB passes and returns container values; open_push does not change
% the caller's OPEN unless you keep its returned value.

clearvars
% Case A — the returned container is saved.
OPEN = open_new('fifo');
OPEN = open_push(OPEN,1);
OPEN = open_push(OPEN,2);
OPEN = open_push(OPEN,3);
fprintf('Case A: entries waiting = %d\n',open_size(OPEN));
[OPEN,a1] = open_pop(OPEN);
[OPEN,a2] = open_pop(OPEN);
[OPEN,a3] = open_pop(OPEN);
fprintf('Case A: extraction order = [%d %d %d]\n',a1,a2,a3);

% Case B — one returned container is NOT saved intentionally.
OPEN = open_new('fifo');
OPEN = open_push(OPEN,1);
open_push(OPEN,2);                  % INTENTIONAL: no OPEN = .
OPEN = open_push(OPEN,3);
fprintf('Case B: entries waiting = %d\n',open_size(OPEN));
[OPEN,b1] = open_pop(OPEN);
[OPEN,b2] = open_pop(OPEN);
fprintf('Case B: extraction order = [%d %d]\n',b1,b2);

% TASK: Explain why node 2 is missing. Restore OPEN = and rerun.
% NOTE: open_size(OPEN) counts waiting entries. MATLAB's size(OPEN)
% describes the dimensions of the struct, NOT the number of waiting nodes.
% Optional: compare size(OPEN) and open_size(OPEN).
