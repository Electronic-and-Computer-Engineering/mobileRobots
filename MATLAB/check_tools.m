function check_tools()
%CHECK_TOOLS  Verify every tool before you build anything on it.
%
%   Run this once at the beginning. If everything here is green, you can
%   trust the tools -- and any error you hit later is in your own code,
%   not in the toolbox. That single fact saves half the lab session.
%
%   Usage:  check_tools
%
%   See also SETUP_PATH, CHECK_MY_CODE.

here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, 'tools'));
addpath(fullfile(here, 'toolchecks'));

global TOOLCHECK_COUNT   %#ok<GVMIS>
TOOLCHECK_COUNT = [0 0];

fprintf('\n=== Checking the tools ===\n\n');

tests = {@test_open, @test_graph, @test_path, @test_grid, @test_maze};
for k = 1:numel(tests)
    try
        tests{k}();
    catch err
        TOOLCHECK_COUNT(2) = TOOLCHECK_COUNT(2) + 1;
        fprintf('    ABORTED %s: %s\n', func2str(tests{k}), err.message);
    end
    fprintf('\n');
end

ok   = TOOLCHECK_COUNT(1);
bad  = TOOLCHECK_COUNT(2);

fprintf('--------------------------------------------\n');
if bad == 0
    fprintf('  %d checks, all passed.\n', ok);
    fprintf('  The tools are ready. Open 01_basics.md.\n');
else
    fprintf('  %d passed, %d FAILED.\n', ok, bad);
    fprintf('  Fix the tools before going on.\n');
end
fprintf('--------------------------------------------\n\n');
end
