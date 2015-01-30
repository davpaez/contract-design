function plotCashFlow(cashFlow)

timeSeries = cashFlow.time;
cashSeries = cashFlow.amount;
typeSeries = cashFlow.type;


% Create figure
figure1 = figure;

% Create subplot
subplot1 = subplot(1,1,1,'Parent',figure1,'Tag','CashFlowAxes');

colors = [
    255     0       0   % Red           1
    255     128     0   % Orage         2
    0       255     0   % Green         3
    0       128     255 % Light blue    4
    0       0       255 % Blue          5
    127     0       255 % Purple        6
    255     0       255 % Magenta       7
    255     0       127 % Pink          8
    192     192     192 % Light Grey    9
    ]/255;

types = getUniqueTypes(typeSeries);
nTypes = size(types,2);
nFlows = size(timeSeries,2);

for i=1:nFlows
    
y = cashSeries(i);
dY = [0 y];
x = timeSeries(i);
flowColor = [1 1 1];

% Is on top of other?
if i>1
    % Are at the same time and have the same sign?
    if timeSeries(i-1) == x && y*cashSeries(i-1)>0
        y = cashSeries(i-1) + y;
        dY = [cashSeries(i-1) y];
    end
end
   
% Which type is it?
for j=1:nTypes
    t = typeSeries{i};
    if strcmp(types{j}, t)
        flowColor = colors(j,:);
    end
end

% Create line
line([x,x],[dY],'Parent',subplot1,'Tag','CashFlowLines','Color',flowColor);

% Create marker
if y < 0
    tagName = 'DownArrowHead';
    marker = 'v';
else
    tagName = 'UpArrowHead';
    marker = '^';
end

line([x],[y],'Parent',subplot1,'Tag','UpArrowHead',...
    'MarkerFaceColor',flowColor,...
    'Marker',marker,...
    'LineStyle','none',...
    'Color',flowColor);
end

% Create line
line([0,max(timeSeries)],[0,0],'Parent',subplot1,'Tag','XAxis','Color',colors(9,:));

% Create title
title(subplot1, 'Principals''s cash flow','FontWeight','bold')


end


function types = getUniqueTypes(typeSeries)
nSeries = size(typeSeries,2);
types = {};
for i = 1:nSeries
    t = typeSeries{i};
    if isempty(types)
        types{end+1} = t;
    else
        index = find(strcmp(types,t), 1, 'first');
        if isempty(index)
            types{end+1} = t;
        end
    end
end
end

    

