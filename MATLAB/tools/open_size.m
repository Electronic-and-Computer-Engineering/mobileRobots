function n = open_size(OPEN)
%OPEN_SIZE  How many nodes are waiting in OPEN.
%
%   'fifo' takes from the front without shifting the array, so there the
%   count is the distance between the read position and the end.

if strcmp(OPEN.mode, 'fifo')
    n = OPEN.n - OPEN.head + 1;
else
    n = OPEN.n;
end
end
