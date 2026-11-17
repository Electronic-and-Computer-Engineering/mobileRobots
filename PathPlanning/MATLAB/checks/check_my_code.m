function check_my_code(which)
%CHECK_MY_CODE  Check the searches you wrote yourself.
%
%   check_my_code              check everything you have started
%   check_my_code('dfs')       check only depth-first search
%   check_my_code('bfs')       and so on with greedy, dijkstra, astar
%
%   Six cases are run: three jobs in the course graph, one completely
%   different graph, and two special cases (start equals goal, goal
%   unreachable). Path, cost and number of expansions all have to match.
%
%   The second graph is not decoration. Some mistakes do not show up in
%   the course graph at all -- leave the relaxation out of Dijkstra and
%   it still gives the right answer there.
%
%   When something is wrong, the checker compares your result with what
%   the other four methods would have produced and names the most
%   frequent match. Nine times out of ten you swapped exactly one line.
%
%   See also CHECK_TOOLS, TESTCASES.

if nargin < 1 || isempty(which)
    which = 'all';
end

allNames = {'dfs', 'bfs', 'greedy', 'dijkstra', 'astar'};
if strcmpi(which, 'all')
    names = allNames;
else
    names = {lower(which)};
    if ~any(strcmp(names{1}, allNames))
        error('check_my_code:name', ...
            'Unknown: "%s". Allowed: dfs, bfs, greedy, dijkstra, astar, all.', ...
            which);
    end
end

F     = testcases();
wasOn = trace_on();
trace_on('off');                                  % keep the output readable
cleanup = onCleanup(@() trace_on(wasOn));   %#ok<NASGU>

fprintf('\n=== Checking your own searches ===\n');

totOk  = 0;
totBad = 0;
open   = {};

for a = 1:numel(names)
    name = names{a};
    fprintf('\n%s\n', upper(name));
    [ok, bad, notStarted] = local_one(name, F, allNames);
    totOk  = totOk + ok;
    totBad = totBad + bad;
    if notStarted
        open{end+1} = name;   %#ok<AGROW>
    end
end

fprintf('\n--------------------------------------------\n');
fprintf('  %d passed, %d failed', totOk, totBad);
if ~isempty(open)
    fprintf(', %d not started yet (%s)', numel(open), strjoin(open, ', '));
end
fprintf('\n--------------------------------------------\n\n');
end


% =======================================================================
function [ok, bad, notStarted] = local_one(name, F, allNames)
ok = 0;
bad = 0;
notStarted = false;

fh      = str2func([name '_graph']);
needsH  = any(strcmp(name, {'greedy', 'astar'}));

votes    = zeros(1, numel(allNames));   % how often does it look like X?
tooCheap = false;
tooDear  = false;
tooMany  = false;
noOrder  = false;

for i = 1:numel(F)
    f = F(i);
    try
        if needsH
            [p, c, st] = fh(f.W, f.s, f.t, f.h(:));
        else
            [p, c, st] = fh(f.W, f.s, f.t);
        end
    catch err
        if strcmp(err.identifier, 'task:todo')
            fprintf('    open    not started yet\n');
            notStarted = true;
            return
        end
        fprintf('    FAILED  %s\n            aborted: %s\n', f.text, err.message);
        bad = bad + 1;
        continue
    end

    if ~isstruct(st) || ~isfield(st, 'order')
        noOrder = true;
    end

    want = f.exp.(name);
    [matches, what] = local_cmp(p, c, st, want);
    if matches
        fprintf('    ok      %s\n', f.text);
        ok = ok + 1;
        continue
    end

    bad = bad + 1;
    fprintf('    FAILED  %s   (%s)\n', f.text, what);
    fprintf('            expected  %s\n', local_show(want{1}, want{2}, want{3}));
    fprintf('            got       %s\n', local_show(p, c, local_exp(st)));

    for b = 1:numel(allNames)
        if strcmp(allNames{b}, name)
            continue
        end
        if local_cmp(p, c, st, f.exp.(allNames{b}))
            votes(b) = votes(b) + 1;
        end
    end

    if c < want{2} - 1e-12
        tooCheap = true;
    end
    if c > want{2} + 1e-12
        tooDear = true;
    end
    if local_exp(st) > size(f.W, 1)
        tooMany = true;
    end
end

if notStarted
    return
end

% ---- one clear diagnosis ----------------------------------------------
if bad > 0
    fprintf('\n            What is going on:\n');
    [best, idx] = max(votes);
    if best > 0
        fprintf('            In %d of %d cases your result is exactly what %s gives.\n', ...
            best, bad, upper(allNames{idx}));
        fprintf('            %s\n', local_hint(name, allNames{idx}));
    end
    if tooMany
        fprintf(['            More nodes are expanded than the graph has. The '...
                 'closed check\n            right after open_pop is missing.\n']);
    end
    if tooCheap && any(strcmp(name, {'dfs', 'bfs', 'greedy'}))
        fprintf(['            Your result is CHEAPER than this method is allowed '...
                 'to find.\n            You are relaxing -- %s never compares '...
                 'costs.\n'], upper(name));
    end
    if tooDear && any(strcmp(name, {'dijkstra', 'astar'}))
        fprintf(['            Your result is MORE EXPENSIVE than the optimum. You '...
                 'are not\n            relaxing: gNew = g(u) + w(k) together with '...
                 'the test gNew < g(v).\n']);
    end
    if best == 0 && ~tooMany && ~tooCheap && ~tooDear
        fprintf('            Compare your file line by line with the pattern.\n');
    end
    return
end

% ---- extra checks, only once the six cases pass -----------------------
if noOrder
    fprintf(['    FAILED  stats.order is missing -- without it you cannot plot '...
             'the search.\n            Collect the expanded nodes in a vector '...
             'and return it.\n']);
    bad = bad + 1;
end

f = F(1);
if needsH
    [p, c] = fh(f.W, f.s, f.t, f.h(:));
else
    [p, c] = fh(f.W, f.s, f.t);
end
[valid, why] = local_valid(p, c, f.W, f.s, f.t);
if valid
    fprintf('    ok      the path you return really exists and the cost fits it\n');
    ok = ok + 1;
else
    fprintf('    FAILED  %s\n', why);
    bad = bad + 1;
end

if strcmp(name, 'astar')
    try
        [pA, cA, stA] = astar_graph(f.W, f.s, f.t, zeros(size(f.W, 1), 1));
        [pD, cD, stD] = dijkstra_graph(f.W, f.s, f.t);
        if isequal(pA(:).', pD(:).') && abs(cA - cD) < 1e-12 && ...
                local_exp(stA) == local_exp(stD)
            fprintf('    ok      A* with h = 0 behaves exactly like your Dijkstra\n');
            ok = ok + 1;
        else
            fprintf(['    FAILED  A* with h = 0 should be Dijkstra line for line.\n'...
                     '            >> h is not reaching the key at one of the two '...
                     'places.\n']);
            bad = bad + 1;
        end
    catch
        fprintf('    (skipped A* against Dijkstra -- Dijkstra not started yet)\n');
    end

    hBad = [3 8 8 1 1 0].';
    [~, cB] = astar_graph(f.W, f.s, f.t, hBad);
    if cB > 3 + 1e-12
        fprintf(['    ok      with an inadmissible h, A* returns a worse path '...
                 '(cost %g instead of 3)\n'], cB);
        ok = ok + 1;
    else
        fprintf(['    FAILED  with an inadmissible h, A* should go wrong here.\n'...
                 '            >> most likely h is not used at all.\n']);
        bad = bad + 1;
    end
end
end


% =======================================================================
function [matches, what] = local_cmp(p, c, st, want)
e = local_exp(st);
matches = true;
parts = {};
if ~isequal(p(:).', want{1}(:).')
    matches = false;
    parts{end+1} = 'path';
end
if ~(abs(c - want{2}) < 1e-12 || (isinf(c) && isinf(want{2})))
    matches = false;
    parts{end+1} = 'cost';
end
if e ~= want{3}
    matches = false;
    parts{end+1} = 'expansions';
end
what = strjoin(parts, ' + ');
end


function e = local_exp(st)
if isstruct(st) && isfield(st, 'expansions')
    e = st.expansions;
else
    e = -1;
end
end


function s = local_show(p, c, e)
if isempty(p)
    ps = '(no path)';
else
    ps = strjoin(arrayfun(@(v) char('A' + v - 1), p(:).', ...
        'UniformOutput', false), ' - ');
end
s = sprintf('%-20s cost %-7g expansions %d', ps, c, e);
end


function [ok, why] = local_valid(p, c, W, s, t)
ok = false;
if isempty(p)
    why = 'no path was returned although one exists.';
    return
end
if p(1) ~= s || p(end) ~= t
    why = 'the path does not start at the start or does not end at the goal.';
    return
end
if numel(unique(p)) ~= numel(p)
    why = 'a node appears twice in the path -- that is not a path.';
    return
end
total = 0;
for k = 1:numel(p) - 1
    if W(p(k), p(k+1)) <= 0
        why = sprintf('there is no edge at all between %c and %c.', ...
            char('A' + p(k) - 1), char('A' + p(k+1) - 1));
        return
    end
    total = total + W(p(k), p(k+1));
end
if abs(total - c) > 1e-12
    why = sprintf('the cost you report (%g) does not match the path (%g).', ...
        c, total);
    return
end
ok = true;
why = '';
end


function txt = local_hint(built, instead)
switch sprintf('%s<%s', built, instead)
    case 'dfs<bfs'
        txt = 'open_new says ''fifo'', it should say ''lifo''.';
    case 'bfs<dfs'
        txt = 'open_new says ''lifo'', it should say ''fifo''.';
    case {'bfs<dijkstra', 'bfs<astar'}
        txt = ['Your BFS does arithmetic. It picked up the relaxation -- ' ...
               'BFS never compares costs.'];
    case 'greedy<astar'
        txt = 'The key contains g. Greedy uses ONLY h(v).';
    case {'greedy<dfs', 'greedy<bfs'}
        txt = ['The key is not arriving. It has to be open_new(''minkey'') ' ...
               'and open_push(OPEN, v, h(v)).'];
    case {'dijkstra<dfs', 'dijkstra<bfs', 'dijkstra<greedy'}
        txt = ['Nothing is being relaxed. Check gNew = g(u) + w(k) and the ' ...
               'test gNew < g(v).'];
    case 'dijkstra<astar'
        txt = 'The key contains h -- that makes it A*, not Dijkstra.';
    case 'astar<dijkstra'
        txt = ['The key is still g instead of g + h. Remember BOTH places: ' ...
               'the start and inside the loop.'];
    case 'astar<greedy'
        txt = 'The key is missing g. A* uses g(v) + h(v), not just h(v).';
    otherwise
        txt = 'Compare your file line by line with the pattern.';
end
end
