function trace_step(nr, u)
%TRACE_STEP  Print one step of the search.
%
%   trace_step(nExp, u) prints that in round nExp the node u was taken
%   out of OPEN -- but only while the trace is switched on.
%
%   Put this line right after you count nExp up. It produces exactly the
%   "taken" column you would write down when running the algorithm with
%   pen and paper.
%
%   Nodes 1..26 print as A..Z, anything above that as a number.
%
%   See also TRACE_ON.

if ~trace_on()
    return
end
if u >= 1 && u <= 26
    fprintf('  step %d: take %s\n', nr, char('A' + u - 1));
else
    fprintf('  step %d: take node %d\n', nr, u);
end
end
