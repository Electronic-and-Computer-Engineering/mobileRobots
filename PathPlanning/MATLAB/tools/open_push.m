function OPEN = open_push(OPEN, item, key)
%OPEN_PUSH  Put a node into OPEN.
%
%   OPEN = OPEN_PUSH(OPEN, v)        puts v in without a key.
%   OPEN = OPEN_PUSH(OPEN, v, key)   puts v in with a sorting key.
%
%   'lifo' and 'fifo' ignore the key -- those containers sort by the
%   order things went in, not by a number.
%
%   'minkey' appends the node number to the key automatically. That way
%   two keys are never exactly equal and the order is reproducible.
%
%   The same node may be put in more than once. Stale entries are thrown
%   away later by the closed check inside the search loop.
%
%   Cost: O(1) for lifo/fifo, O(log n) for minkey.
%
%   IMPORTANT: this function GIVES OPEN BACK. You have to assign it:
%       OPEN = open_push(OPEN, v);        correct
%       open_push(OPEN, v);               does nothing at all
%
%   See also OPEN_NEW, OPEN_POP, OPEN_LESS.

if nargin < 3
    key = 0;
end
if ~isscalar(item) || item ~= fix(item) || item < 1
    error('open_push:item', 'item must be a positive whole number.');
end

OPEN.n = OPEN.n + 1;
OPEN.item(OPEN.n, 1) = item;

if ~strcmp(OPEN.mode, 'minkey')
    return
end

% ---- from here on: minkey only ----------------------------------------
full = [key(:).', item];
if OPEN.n == 1
    OPEN.key = zeros(1, numel(full));
elseif numel(full) ~= size(OPEN.key, 2)
    error('open_push:keySize', ...
        'Key has %d entries, so far it was %d.', ...
        numel(full) - 1, size(OPEN.key, 2) - 1);
end
OPEN.key(OPEN.n, :) = full;

% sift-up: the new entry rises as long as it is smaller than its parent.
% In an array heap the parent of i is always floor(i/2).
i = OPEN.n;
while i > 1
    p = floor(i / 2);
    if ~open_less(OPEN.key(i, :), OPEN.key(p, :))
        break
    end
    tmpKey         = OPEN.key(i, :);
    OPEN.key(i, :) = OPEN.key(p, :);
    OPEN.key(p, :) = tmpKey;
    tmpItem        = OPEN.item(i);
    OPEN.item(i)   = OPEN.item(p);
    OPEN.item(p)   = tmpItem;
    i = p;
end
end
