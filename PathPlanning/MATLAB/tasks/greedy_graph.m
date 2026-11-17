function [path, cost, stats] = greedy_graph(W, s, t, h)
%GREEDY_GRAPH  TASK 3 -- greedy best-first search.
%
%   Same pattern again. This time the order is decided by a number: the
%   estimate h(v) of how far it still is from v to the goal.
%
%   Copy your bfs_graph and change two things:
%     - the container has to sort by a key
%     - the key has to be handed over when pushing:
%           open_push(OPEN, v, <key>)
%
%   Nothing else. No g, no relaxation -- greedy only ever looks ahead.
%
%   h is a vector with one estimate per node, h(t) = 0.
%
%   Target:  A - D - F, cost 7, 3 expansions.
%
%   Check:   check_my_code('greedy')
%
%   Worth thinking about: greedy needs the same number of expansions as
%   depth-first search and finds the same path. Is that a coincidence?

error('task:todo', 'Task 3 not started -- delete this line and begin.');
end
