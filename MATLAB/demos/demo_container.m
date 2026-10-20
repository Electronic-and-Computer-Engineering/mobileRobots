function demo_container()
%DEMO_CONTAINER  See for yourself what the OPEN container does.
%
%   Usage:  demo_container
%
%   No plot here -- the container is a list, and a list is best read as
%   text. Everything else in this course gets a picture.
%
%   Verifies: open_new, open_push, open_pop, open_isempty, open_size.

clc
fprintf('\n============================================================\n');
fprintf(' DEMO -- the OPEN container\n');
fprintf('============================================================\n');
fprintf('\n A container is a list of nodes that the search takes ONE out\n');
fprintf(' of in every round. The mode decides which one. That is the\n');
fprintf(' only difference between the five algorithms.\n');

fprintf('\n------------------------------------------------------------\n');
fprintf(' 1) lifo -- last in, first out\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n    OPEN = open_new(''lifo'');\n');
OPEN = open_new('lifo');
for v = [1 2 3]
    fprintf('    OPEN = open_push(OPEN, %d);      %% %d waiting\n', ...
        v, open_size(OPEN) + 1);
    OPEN = open_push(OPEN, v);
end
fprintf('\n    comes out as:  ');
while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);
    fprintf('%d ', u);
end
fprintf('\n    -> a stack of plates. On the top, off the top.\n');

fprintf('\n------------------------------------------------------------\n');
fprintf(' 2) fifo -- first in, first out\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n    The very same code, one word changed in open_new.\n');
OPEN = open_new('fifo');
for v = [1 2 3]
    OPEN = open_push(OPEN, v);
end
fprintf('\n    comes out as:  ');
while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);
    fprintf('%d ', u);
end
fprintf('\n    -> a queue at a counter. Join at the back, served at the front.\n');

fprintf('\n------------------------------------------------------------\n');
fprintf(' 3) minkey -- smallest key first\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n    Here every node gets a NUMBER when it goes in.\n\n');
OPEN = open_new('minkey');
nodes = [5 3 4];
keys  = [5 1 3];
for k = 1:3
    fprintf('    OPEN = open_push(OPEN, %d, %d);\n', nodes(k), keys(k));
    OPEN = open_push(OPEN, nodes(k), keys(k));
end
fprintf('\n    comes out as:  ');
while ~open_isempty(OPEN)
    [OPEN, u, key] = open_pop(OPEN);
    fprintf('%d (key %g)   ', u, key);
end
fprintf('\n    -> not 5,3,4 but sorted by key. The insertion order is\n');
fprintf('       irrelevant here, which is what makes Dijkstra and A* work.\n');

fprintf('\n------------------------------------------------------------\n');
fprintf(' 4) What happens on a tie\n');
fprintf('------------------------------------------------------------\n');
fprintf('\n    Nodes 7, 2 and 5, all with key 2:  ');
OPEN = open_new('minkey');
for v = [7 2 5]
    OPEN = open_push(OPEN, v, 2);
end
while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);
    fprintf('%d ', u);
end
fprintf('\n    -> by node number. open_push appends the node number as a\n');
fprintf('       second key column, so every run behaves identically.\n');

fprintf('\n------------------------------------------------------------\n');
fprintf(' 5) The same node, twice in the container\n');
fprintf('------------------------------------------------------------\n');
OPEN = open_new('minkey');
OPEN = open_push(OPEN, 4, 9);
OPEN = open_push(OPEN, 4, 2);
fprintf('\n    open_push(OPEN, 4, 9) and open_push(OPEN, 4, 2)\n');
fprintf('    open_size(OPEN) = %d\n\n', open_size(OPEN));
[OPEN, u1, k1] = open_pop(OPEN);
[~,    u2, k2] = open_pop(OPEN);
fprintf('    first:  node %d, key %g\n', u1, k1);
fprintf('    then:   node %d, key %g   <- stale, too expensive\n', u2, k2);
fprintf('\n    -> This is allowed and Dijkstra needs it. The cheaper entry\n');
fprintf('       comes out first; the stale one is dropped by the closed\n');
fprintf('       check at the top of the search loop.\n\n');
end
