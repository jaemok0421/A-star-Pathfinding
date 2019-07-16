function pathfinding
    % Draw a map
    tic
    mapValue = drawMap(4);
    preparation(mapValue)
    fprintf('Used time: %.1fs\n',toc);
    % Set on function for mouse click
    set(gcf,'WindowButtonDownFcn',@mouseClickFcn);
end

% Display the map
function mapValue = drawMap(n)
    % Initialize
    global mapNum
    global hasStart
    global hasGoal
    mapNum = n;
    hasStart = false;
    hasGoal = false;
    adr = ['map0',int2str(mapNum),'.png'];
    
    % Load map
    hold off
    mapImage = imread(adr);
    imshow(mapImage)
    mapValue = im2double(mapImage);
    hold on
end

% Prepare map table
function preparation(mapValue)
    % Initialize
    global map
    global xb
    global zb
    
    % Get the boundary
    [xb, zb] = size(mapValue);
    xb = (xb-mod(xb,10))/10;
    zb = (zb-mod(zb,10))/10;
    %map = zeros(zb,xb);
    map = Point(0,0,0);
    % Initialize map points
    for j = 1:zb
        for i = 1:xb
            %map(i,j) = mapValue(i*10-5,j*10-5);
            map(inx(i,j)) = Point(i,mapValue(j*10-5,i*10-5),j);
        end
    end
    % Set child points, which can go through to
    for i = 1:xb
        for j = 1:zb
            setChilds(i,j)
        end
    end
    fprintf('Set finished\n');
end

% Checked all surrounding points, and set what can be passed to be child
function setChilds(x,z)
    global map
    global xb
    global zb
    parentPoint = map(inx(x,z));
    parentPoint.childs = Point(0,0,0);
    parentPoint.childs(1) = [];
    
    for i = x-1:x+1
        for j = z-1:z+1
            % Check if this is the point located in the map
            if i >= 1 && i <= xb && j >= 1 && j <= zb
                % Except the point itself
                if i ~= x || j ~=z
                    childPoint = map(inx(i,j));
                    % NEWS points
                    if i == x || j == z
                        if childPoint.isPassable(parentPoint)
                            parentPoint.childs(length(parentPoint.childs)+1) = childPoint;
                        end
                    % NE NW SE SW
                    else
                        assetPoint1 = map(inx(x,j));
                        assetPoint2 = map(inx(i,z));
                        if assetPoint1.isPassable(parentPoint) && assetPoint2.isPassable(parentPoint) && assetPoint1.isPassable(childPoint) && assetPoint2.isPassable(childPoint)
                            parentPoint.childs(length(parentPoint.childs)+1) = childPoint;
                        end
                    end
                end
            end
        end
    end
    map(inx(x,z)) = parentPoint;
end

function index = inx(x,z)
    global xb
    index = (z-1)*xb+x;
end

function redisplayMap(startPoint,goalPoint,path,drawPath)
    global hasStart
    global hasGoal
    global mapNum
    global exist
    adr = ['map0',int2str(mapNum),'.png'];
    
    % Load map
    hold off
    mapImage = imread(adr);
    imshow(mapImage)
    hold on
    
    if hasStart
        plot(startPoint.x*10-5,startPoint.z*10-5,'ro','markerfacecolor',[1,0,0]);
    end
    if hasGoal
        plot(goalPoint.x*10-5,goalPoint.z*10-5,'go','markerfacecolor',[0,1,0]);
    end
    if drawPath
        for i = 1:length(path)
            plot(path(i).x*10-5,path(i).z*10-5,'o','markersize',2);
        end
        if ~exist
            plot(path(1).x*10-5,path(1).z*10-5,'bo','markerfacecolor',[0,0,1]);
        end
    end
end

function clearMap
    global mapNum
    drawMap(mapNum);
end

function mouseClickFcn(src, event)
    % Initialize
    global map
    global hasStart
    global hasGoal
    global xb
    global zb
    persistent startPoint
    persistent goalPoint
    bestPath = Point(0,0,0);
    bestPath(1) = [];
	pt = get(gca,'CurrentPoint');
    x = pt(1,1);
    z = pt(1,2);
    
    % If the point is located in the map, get the point
    if x >= 1 && x <= xb*10 && z >= 1 && z <= zb*10
        x = (x-mod(x,10))/10+1;
        z = (z-mod(z,10))/10+1;
        % Set the start point
        if strcmp(get(gcf,'SelectionType'),'normal')
            %startPoint = Point(x,map(z,x),z);
            startPoint = map(inx(x,z));
            hasStart = true;
        % Set the goal point
        elseif strcmp(get(gcf,'SelectionType'),'alt')
            %goalPoint = Point(x,map(z,x),z);
            goalPoint = map(inx(x,z));
            hasGoal = true;
        % Reset the map
        else
            clearMap
        end
        redisplayMap(startPoint,goalPoint,bestPath,false)
        % If both start and goal points are existed, find the best path
        if hasGoal == true && hasStart == true && startPoint.isEqual(goalPoint) == false
            tic
            bestPath = aStarFcn(startPoint,goalPoint);
            fprintf('Used time: %.1fs\n',toc);
            redisplayMap(startPoint,goalPoint,bestPath,true)
        end
    end
end

function bestPath = aStarFcn(startPoint,goalPoint)
    % Initialize
    global map
    global exist
    startPoint.g = 0;
    startPoint.h = startPoint.calculateH(goalPoint);
    openlist = startPoint;
    nearestPoint = startPoint;
    exist = false;
    resetMap
    
    while ~isempty(openlist)
        currentPoint = openlist(length(openlist));
        x = currentPoint.x;
        z = currentPoint.z;
        % mark currentPoint to be checked and remove it from openlist
        currentPoint.checked = true;
        currentPoint.opening = false;
        map(inx(x,z)) = currentPoint;
        openlist(length(openlist)) = [];
        % add child points in open list
        openlist = addPoint(openlist,currentPoint,goalPoint);
        nearestPoint = getNearerPoint(nearestPoint,currentPoint,startPoint,goalPoint);
        % [exist,n] = checkList(openlist,goalPoint);
        if map(inx(goalPoint.x,goalPoint.z)).opening
            goalPoint = openlist(length(openlist));
            exist = true;
            bestPath = getBestPath(startPoint,goalPoint);
            break
        end
    end
    if isempty(openlist) && ~exist
        % goalPoint = goalPoint.findNearest(map,startPoint);
        bestPath = getBestPath(startPoint,nearestPoint);
    end
end

function nearestPoint = getNearerPoint(nearestPoint,currentPoint,startPoint,goalPoint)
    dns = abs(nearestPoint.x-startPoint.x)+abs(nearestPoint.z-startPoint.z);
    dng = abs(nearestPoint.x-goalPoint.x)+abs(nearestPoint.z-goalPoint.z);
    dcs = abs(currentPoint.x-startPoint.x)+abs(currentPoint.z-startPoint.z);
    dcg = abs(currentPoint.x-goalPoint.x)+abs(currentPoint.z-goalPoint.z);
    if dcg < dng
        nearestPoint = currentPoint;
    elseif dcg == dng && dcs < dns
        nearestPoint = currentPoint;
    end
end

function resetMap
    global map
    for i = 1:length(map)
        map(i).checked = false;
        map(i).opening = false;
    end
end

function openlist = addPoint(openlist,lastPoint,goalPoint)
    global map
    
    for i = 1:length(lastPoint.childs)
        thisPoint = lastPoint.childs(i);
        x = thisPoint.x;
        z = thisPoint.z;
        thisPoint = map(inx(x,z));
        % If this point can be passed through and not be checked,
        % add it in open list
        if ~thisPoint.checked
            thisPoint.g = thisPoint.calculateG(lastPoint);
            thisPoint.h = thisPoint.calculateH(goalPoint);
            % [exist,n] = checkList(openlist,thisPoint);
            if thisPoint.opening
                n = thisPoint.find(openlist);
                if openlist(n).isLarge(thisPoint)
                    openlist(n) = [];
                    thisPoint.parent = lastPoint;
                    openlist = thisPoint.insert(openlist);
                end
            else
                thisPoint.parent = lastPoint;
                thisPoint.opening = true;
                openlist = thisPoint.insert(openlist);
            end
            map(inx(x,z)) = thisPoint;
        end
    end
end

% Check if the point in open list. If it is, get the index
function [exist,n] = checkList(list,thisPoint)
    exist = false;
    n = 0;
    if ~isempty(list)
        for i=1:length(list)
            if thisPoint.isEqual(list(i))
                exist = true;
                n = i;
                break
            end
        end
    end
end

% Get the best path
function bestPath = getBestPath(startPoint,goalPoint)
    % Initialize
    i = 1;
    currentPoint = goalPoint;
    
    while ~currentPoint.isEqual(startPoint)
        bestPath(i) = currentPoint;
        i = i+1;
        currentPoint = currentPoint.parent;
    end
    bestPath(i) = startPoint;
end