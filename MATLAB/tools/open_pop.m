function [OPEN, u, key] = open_pop(OPEN)
%OPEN_POP  Take the next node out of OPEN.
%
%   [OPEN, u] = OPEN_POP(OPEN) returns the node the mode asks for: the
%   one put in last (lifo), the one put in first (fifo), or the one with
%   the smallest key (minkey).
%
%   [OPEN, u, key] = OPEN_POP(OPEN) also returns the key v was stored
%   with (empty for lifo/fifo).
%
%   Cost: O(1) for lifo/fifo, O(log n) for minkey.
%
%   See also OPEN_PUSH, OPEN_ISEMPTY.

if open_isempty(OPEN)
    error('open_pop:empty', 'OPEN is empty -- check with open_isempty first.');
end

key = [];

switch OPEN.mode
    case 'lifo'
        u      = OPEN.item(OPEN.n);
        OPEN.n = OPEN.n - 1;

    case 'fifo'
        u         = OPEN.item(OPEN.head);
        OPEN.head = OPEN.head + 1;

    case 'minkey'
        u   = OPEN.item(1);
        key = OPEN.key(1, 1:end-1);   % without the tie-break column

        % Last entry to the root, then sift-down: it sinks as long as one
        % of its children is smaller. Children of i are 2i and 2i+1.
        OPEN.item(1)   = OPEN.item(OPEN.n);
        OPEN.key(1, :) = OPEN.key(OPEN.n, :);
        OPEN.n         = OPEN.n - 1;

        i = 1;
        while true
            l = 2 * i;
            r = l + 1;
            m = i;
            if l <= OPEN.n && open_less(OPEN.key(l, :), OPEN.key(m, :))
                m = l;
            end
            if r <= OPEN.n && open_less(OPEN.key(r, :), OPEN.key(m, :))
                m = r;
            end
            if m == i
                break
            end
            tmpKey         = OPEN.key(i, :);
            OPEN.key(i, :) = OPEN.key(m, :);
            OPEN.key(m, :) = tmpKey;
            tmpItem        = OPEN.item(i);
            OPEN.item(i)   = OPEN.item(m);
            OPEN.item(m)   = tmpItem;
            i = m;
        end
end
end
