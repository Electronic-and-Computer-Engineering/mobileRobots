function OPEN = open_new(mode)
%OPEN_NEW  Create an empty OPEN container.
%
%   OPEN = OPEN_NEW(mode) creates the container that a search takes one
%   node out of in every round. The mode decides WHICH node that is --
%   and that is the only difference between the five search algorithms.
%
%     'lifo'     last one in comes out first     (a stack)
%     'fifo'     first one in comes out first    (a queue)
%     'minkey'   smallest key comes out first    (a priority queue)
%
%   'minkey' keeps a min-heap internally. On a tie the node number
%   decides, so every run of your program gives the same answer.
%
%   See also OPEN_PUSH, OPEN_POP, OPEN_ISEMPTY, OPEN_SIZE.

mode = lower(mode);
if ~any(strcmp(mode, {'lifo', 'fifo', 'minkey'}))
    error('open_new:mode', ...
        'Unknown mode "%s". Allowed: lifo, fifo, minkey.', mode);
end

OPEN.mode = mode;
OPEN.item = zeros(0, 1);   % the node numbers
OPEN.key  = zeros(0, 0);   % only used by minkey
OPEN.n    = 0;             % how many slots are in use
OPEN.head = 1;             % fifo only: where the next one is taken from
end
