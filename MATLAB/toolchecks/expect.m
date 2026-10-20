function expect(condition, text)
%EXPECT  Record one single check.
%
%   EXPECT(condition, text) prints one line and counts it. The tally
%   lives in a global, so the individual test files do not have to pass
%   return values around.
%
%   See also CHECK_TOOLS.

global TOOLCHECK_COUNT   %#ok<GVMIS>

if isempty(TOOLCHECK_COUNT)
    TOOLCHECK_COUNT = [0 0];
end

if condition
    TOOLCHECK_COUNT(1) = TOOLCHECK_COUNT(1) + 1;
    fprintf('    ok      %s\n', text);
else
    TOOLCHECK_COUNT(2) = TOOLCHECK_COUNT(2) + 1;
    fprintf('    FAILED  %s\n', text);
end
end
