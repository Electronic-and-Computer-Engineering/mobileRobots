function test_open()
%TEST_OPEN  Check the OPEN container in all three modes.
%
%   The most important check of all: if OPEN is wrong, all five searches
%   give wrong answers later, and the bug looks like a bug in the
%   algorithm.

fprintf('  test_open\n');

% ---- lifo: last in, first out -----------------------------------------
O = open_new('lifo');
O = open_push(O, 1);
O = open_push(O, 2);
O = open_push(O, 3);
expect(open_size(O) == 3, 'lifo: three nodes pushed');
[O, u1] = open_pop(O);
[O, u2] = open_pop(O);
[O, u3] = open_pop(O);
expect(isequal([u1 u2 u3], [3 2 1]), 'lifo: order 3 2 1');
expect(open_isempty(O), 'lifo: empty afterwards');

% ---- fifo: first in, first out ----------------------------------------
O = open_new('fifo');
O = open_push(O, 1);
O = open_push(O, 2);
O = open_push(O, 3);
[O, u1] = open_pop(O);
[O, u2] = open_pop(O);
[O, u3] = open_pop(O);
expect(isequal([u1 u2 u3], [1 2 3]), 'fifo: order 1 2 3');
expect(open_isempty(O), 'fifo: empty afterwards');

% ---- fifo: pushing and popping alternately ----------------------------
O = open_new('fifo');
O = open_push(O, 1);
O = open_push(O, 2);
[O, a] = open_pop(O);
O = open_push(O, 3);
[O, b] = open_pop(O);
[O, c] = open_pop(O);
expect(isequal([a b c], [1 2 3]), 'fifo: keeps the order even when mixing push and pop');

% ---- minkey: smallest key first ---------------------------------------
O = open_new('minkey');
O = open_push(O, 5, 5);
O = open_push(O, 3, 1);
O = open_push(O, 4, 3);
[O, u1] = open_pop(O);
[O, u2] = open_pop(O);
[O, u3] = open_pop(O);
expect(isequal([u1 u2 u3], [3 4 5]), 'minkey: sorted by key');

% ---- minkey: Einfuegereihenfolge darf egal sein -----------------------
O = open_new('minkey');
for v = [4 1 6 2 5 3]
    O = open_push(O, v, 10 - v);
end
raus = zeros(1, 6);
for k = 1:6
    [O, raus(k)] = open_pop(O);
end
expect(isequal(raus, [6 5 4 3 2 1]), 'minkey: independent of insertion order');

% ---- minkey: ties break by node number --------------------------------
O = open_new('minkey');
O = open_push(O, 7, 2);
O = open_push(O, 2, 2);
O = open_push(O, 5, 2);
[O, u1] = open_pop(O);
[O, u2] = open_pop(O);
[O, u3] = open_pop(O);
expect(isequal([u1 u2 u3], [2 5 7]), 'minkey: ties break by node number');

% ---- minkey: multi-column keys, compared column by column -------------
O = open_new('minkey');
O = open_push(O, 1, [2  0]);
O = open_push(O, 2, [2 -1]);
O = open_push(O, 3, [1 99]);
[O, u1] = open_pop(O);
[O, u2] = open_pop(O);
[O, u3] = open_pop(O);
expect(isequal([u1 u2 u3], [3 2 1]), 'minkey: the second key column decides a tie');

% ---- minkey: the same node may sit in there more than once ------------
O = open_new('minkey');
O = open_push(O, 4, 9);
O = open_push(O, 4, 2);
expect(open_size(O) == 2, 'minkey: the same node may be pushed twice');
[O, ~, k1] = open_pop(O);
[~, ~, k2] = open_pop(O);
expect(k1 == 2 && k2 == 9, 'minkey: the cheaper entry comes out first');

% ---- minkey: pushing and popping alternately --------------------------
O = open_new('minkey');
O = open_push(O, 1, 5);
O = open_push(O, 2, 3);
[O, a] = open_pop(O);
O = open_push(O, 3, 1);
O = open_push(O, 4, 4);
[O, b] = open_pop(O);
[O, c] = open_pop(O);
[O, d] = open_pop(O);
expect(isequal([a b c d], [2 3 4 1]), 'minkey: stays sorted when mixing push and pop');

% ---- error cases ------------------------------------------------------
O = open_new('fifo');
fehlerKam = false;
try
    [~, ~] = open_pop(O);
catch
    fehlerKam = true;
end
expect(fehlerKam, 'open_pop on an empty container raises an error');

fehlerKam = false;
try
    open_new('stack');
catch
    fehlerKam = true;
end
expect(fehlerKam, 'open_new refuses an unknown mode');
end
