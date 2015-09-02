%% Parameters
num_points = 20;

nullP = 0;
maxP = 100;

maxForce = 100;
minForce = 0;

forceValue = linspace(minForce, maxForce, num_points);
currentPerf = linspace(nullP, maxP, num_points);

finalPerf = zeros(num_points);

for i=1:num_points
    for j=1:num_points
        finalPerf(i,j) = CommonFnc.shockResponseFunction(nullP, maxP, currentPerf(j), forceValue(i));
    end
end

% indices = finalPerf==0;
% finalPerf(indices) = nan;

close all
h = surf(currentPerf, forceValue, finalPerf, 'EdgeColor', 'white');

% h.Surface.EdgeColor = 'none';

xlabel('CurrentPerf')
ylabel('ForceValue')



%%  