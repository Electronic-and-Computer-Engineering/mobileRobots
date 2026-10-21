function setup_path(mode)
%SETUP_PATH  Put the course folders on the MATLAB path.
%
%   setup_path             your own files from tasks/ are active
%   setup_path('solution') the model solutions are active instead
%   setup_path('status')   show which folders are active right now
%
%   Run this once when you start. The folder that comes FIRST on the
%   path wins, so 'solution' simply moves solutions/ to the front.
%
%   See also CHECK_TOOLS, CHECK_MY_CODE.

if nargin < 1 || isempty(mode)
    mode = 'tasks';
end

here = fileparts(mfilename('fullpath'));
all  = {'tools', 'demos', 'toolchecks', 'checks', 'tasks', 'solutions'};

warning('off', 'MATLAB:rmpath:DirNotFound');
for k = 1:numel(all)
    p = fullfile(here, all{k});
    if exist(p, 'dir')
        rmpath(p);
    end
end

switch lower(mode)
    case 'status'
        fprintf('\nActive course folders (the top one wins):\n');
        parts = strsplit(path, pathsep);
        for k = 1:numel(parts)
            if ~isempty(strfind(parts{k}, here))   %#ok<STREMP>
                fprintf('   %s\n', parts{k});
            end
        end
        fprintf('\n');
        return

    case {'solution', 'solutions'}
        addpath(fullfile(here, 'tools'));
        addpath(fullfile(here, 'demos'));
        addpath(fullfile(here, 'toolchecks'));
        addpath(fullfile(here, 'checks'));
        addpath(fullfile(here, 'solutions'));    % model solution first
        fprintf('\n  Model solutions are active.\n');

    otherwise
        addpath(fullfile(here, 'tools'));
        addpath(fullfile(here, 'demos'));
        addpath(fullfile(here, 'toolchecks'));
        addpath(fullfile(here, 'checks'));
        addpath(fullfile(here, 'tasks'));        % your own files first
        fprintf('\n  Your own files from tasks/ are active.\n');
end

fprintf('  Next:        check_tools\n');
fprintf('  Then start:  01_basics.md\n\n');
end
