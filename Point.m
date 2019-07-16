classdef Point
    properties
        g
        h
        x
        y
        z
        parent
        childs
        checked
        opening
    end
    properties (Dependent)
        f
    end
    
    % Initialize
    methods
        function p = Point(x,y,z)
            p.x = x;
            p.y = y;
            p.z = z;
            p.checked = false;
            p.opening = false;
        end
    end
    
    % Setter and Getter
    methods
        function p = set.g(p,g)
            p.g = g;
        end
        function p = set.h(p,h)
            p.h = h;
        end
        function p = set.x(p,x)
            p.x = x;
        end
        function p = set.y(p,y)
            p.y = y;
        end
        function p = set.z(p,z)
            p.z = z;
        end
        function p = set.parent(p,parent)
            p.parent = parent;
        end
        function p = set.childs(p,child)
            p.childs = child;
        end
        function p = set.checked(p,checked)
            p.checked = checked;
        end
        function p = set.opening(p,opening)
            p.opening = opening;
        end
        function f = get.f(p)
            f = p.g+p.h;
        end
        function g = get.g(p)
            g = p.g;
        end
        function h = get.h(p)
            h = p.h;
        end
        function x = get.x(p)
            x = p.x;
        end
        function y = get.y(p)
            y = p.y;
        end
        function z = get.z(p)
            z = p.z;
        end
        function parent = get.parent(p)
            parent = p.parent;
        end
        function child = get.childs(p)
            child = p.childs;
        end
        function checked = get.checked(p)
            checked = p.checked;
        end
        function opening = get.opening(p)
            opening = p.opening;
        end
    end
    
    % Other methods
    methods
        % Check if two points are same
        function equal = isEqual(p, pAnother)
            if p.x == pAnother.x && p.z == pAnother.z
                equal = true;
            else
                equal = false;
            end
        end
        % Check if the point be passible
        function pass = isPassable(p, pAnother)
            dy = abs(p.y-pAnother.y);
            if dy < 0.2
                pass = true;
            else
                pass = false;
            end
        end
        % Check if the point is in the list
        function exist = isExist(p, list)
            exist = false;
            if ~isempty(list)
                for i=1:length(list)
                    if p.isEqual(list(i)) == true
                        exist = true;
                        break
                    end
                end
            end
        end
        % Check if the value f of point is larger than another
        function large = isLarge(p, pAnother)
            if p.f > pAnother.f
                large = true;
            else
                large = false;
            end
        end
        % Check if the value f of point is smaller than another
        function small = isSmall(p, pAnother)
            if p.f < pAnother.f
                small = true;
            else
                small = false;
            end
        end
        % Find where the point is in the list
        function n = find(p, list)
            n = 0;
            for i=1:length(list)
                if p.isEqual(list(i)) == true
                    n = i;
                    break
                end
            end
        end
        % Find the nearest point in the list
        function pNear = findNearest(p, list, pAnother)
            pNear = list(1);
            d = abs(p.x-pNear.x)+abs(p.z-pNear.z);
            ds = abs(pAnother.x-pNear.x)+abs(pAnother.z-pNear.z);
            len = length(list);
            if len >= 2
                for i = 2:len
                    thisPoint = list(i);
                    if thisPoint.checked
                        dp = abs(p.x-thisPoint.x)+abs(p.z-thisPoint.z);
                        dsp = abs(pAnother.x-thisPoint.x)+abs(pAnother.z-thisPoint.z);
                        if dp < d
                            pNear = thisPoint;
                            d = dp;
                            ds = dsp;
                        elseif dp == d
                            if dsp < ds
                                pNear = thisPoint;
                                d = dp;
                                ds = dsp;
                            end
                        end
                    end
                end
            end
        end
        % Calculate value g by the last point
        function g = calculateG(p, pLast)
            d = (abs(p.x-pLast.x))^2+((abs(p.y-pLast.y)*255))^2+(abs(p.z-pLast.z))^2;
            d = sqrt(d);
            g = d*10;
            g = g+pLast.g;
        end
        % Calculate value g with the goal point
        function h = calculateH(p, pGoal)
            dx = abs(p.x-pGoal.x);
            dy = abs(p.y-pGoal.y)*255;
            dz = abs(p.z-pGoal.z);
            %m = min([dx,dy,dz]);
            %h = sqrt(3*m^2);
            %dx = dx-m;
            %dy = dy-m;
            %dz = dz-m;
            %s = dx+dy+dz;
            %if s ~= 0
            %    if s == dx || s == dy || s == dz
            %        h = h + s;
            %    else
            %        if dz ~= 0
            %            if dx == 0
            %                dx = dz;
            %            else
            %                dy = dz;
            %            end
            %        end
            %        m = min([dx,dy]);
            %        h = h+sqrt(2*m^2);
            %        dx = dx-m;
            %        dy = dy-m;
            %        s = dx+dy;
            %        h = h+s;
            %    end
            %end
            
            h = dx+dy+dz;
            h = h*10;
        end
        % Insert point in open list and sort it
        function list = insert(p,list)
            if isempty(list)
                list = p;
            else
                len = length(list);
                for i = len:-1:1
                    if ~p.isLarge(list(i))
                        list = [list(1:i),p,list(i+1:len)];
                        break
                    elseif i == 1
                        list = [p,list];
                    end
                end
            end
        end
    end
end