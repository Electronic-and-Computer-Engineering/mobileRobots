function tf = open_isempty(OPEN)
%OPEN_ISEMPTY  True when no node is waiting any more.
%
%   See also OPEN_SIZE.

tf = open_size(OPEN) == 0;
end
