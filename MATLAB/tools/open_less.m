function tf = open_less(a, b)
%OPEN_LESS  Compare two key rows, column by column.
%
%   tf = OPEN_LESS(a, b) is true when a belongs before b. The first
%   column is compared first; on a tie the second decides, and so on.
%   The last column is always the node number, so a true tie never
%   happens.
%
%   See also OPEN_PUSH, OPEN_POP.

for i = 1:numel(a)
    if a(i) < b(i)
        tf = true;
        return
    elseif a(i) > b(i)
        tf = false;
        return
    end
end
tf = false;   % completely equal is not "less"
end
