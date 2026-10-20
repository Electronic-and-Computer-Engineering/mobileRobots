function tf = trace_on(state)
%TRACE_ON  Switch the step-by-step trace on or off.
%
%   trace_on('off')   stop printing
%   trace_on('on')    start printing (this is the default)
%   tf = trace_on()   ask for the current state
%
%   The trace is on to begin with: while you build a search you want to
%   see the order in which it takes nodes out. The checker switches it
%   off by itself so its output stays readable.
%
%   See also TRACE_STEP.

persistent isOn
if isempty(isOn)
    isOn = true;
end
if nargin > 0
    if islogical(state) || isnumeric(state)
        isOn = logical(state);
    else
        isOn = any(strcmpi(state, {'on', 'true', 'yes'}));
    end
end
tf = isOn;
end
