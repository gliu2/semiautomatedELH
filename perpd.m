%%%%%%% perpd.m %%%%%%%
% Goal: calculate perpendicular distance of midpoint from chord given 3 pts
% on arc
% 
% Input: x - x-coordinates of 3 points
%        y - y-coordinates of 3 points
%         *note: x and y store values of [end1, mid, end2]
% Output: D - perpendicular distance of midpoint from ends 
% 5/3/2016
%
% Dependencies: none

function D = perpd(x, y)
    u = [x(2)-x(1), y(2)-y(1), 0];
    v = [x(3)-x(1), y(3)-y(1), 0];
    D = norm(cross(u,v))/norm(v);
    
    % displacement is negative if arc is bowed to right (inward)
    if x(2) > mean([x(1), x(3)])
        D = -D;
    end
    
end