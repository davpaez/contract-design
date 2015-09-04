%{
-------------------------------------------------------------
Experiment 1

This experiment is being used as a test for the new features
of the model!
-------------------------------------------------------------

Description:
Single and deterministic analysis of the game

%}

% Initialize variables
function progSet = settings()

import managers.*

disp('Initializing problem settings:')
progSet = ProgramSettings();

progSet.unlockSettings();
disp('    Creating settings objects...')

%% Management
% Path of current settings file
[pathFolder, nameFile] = fileparts(mfilename('fullpath'));

fi = FileInfo();
fi.setIdentifier(ItemSetting.FILE_INFO);

fi.fileSettings_name = nameFile;
fi.expFolder_path = pathFolder;
parts = strsplit(pathFolder,'\');
fi.experiment_name = parts{end};

% Write output or not
fi.logStatus = false;

progSet.add(fi);

%% Problem (1 - 15)

% 1. Type of experiment
data = InputData();

data.setIdentifier(ItemSetting.TYPE_EXP);
data.value = Experiment.SING;

progSet.add(data);

% 2. Time resolution
data = InputData();

data.setIdentifier(ItemSetting.TIME_RES);
data.value = round(1*(1/365)*(1/10), 4);

progSet.add(data);

% 3. Annual discount rate
data = InputData();

data.setIdentifier(ItemSetting.DISC_RATE);
data.value = 0.04;

progSet.add(data);

%% Optimization (16 - 30)

% 16. Number of realizations per simulation of game
data = InputData();

data.setIdentifier(ItemSetting.NUM_REALIZ);
data.value = 100;

progSet.add(data);

% 17. Maximum number of interations - Stopping criterion
% This is the maximum number of generations of the genetic algorithm
% both the inner and outer
data = InputData();

data.setIdentifier(ItemSetting.MAX_ITER);
data.value = 100;

progSet.add(data);

% 18. Tolerance - Stopping criterion
data = InputData();

data.setIdentifier(ItemSetting.TOL);
data.value = 0.005;

progSet.add(data);

%% Realization (31 - 45)


%% Infrastructure (106 - 120)

% 106. Null performance
nullp = InputData();

nullp.setIdentifier(ItemSetting.NULL_PERF);
nullp.value = 0;

progSet.add(nullp);

% 107. Maximum performance
maxp = InputData();

maxp.setIdentifier(ItemSetting.MAX_PERF);
maxp.value = 100;

progSet.add(maxp);


nullPerf = progSet.returnItemSetting(ItemSetting.NULL_PERF).value;
maxPerf = progSet.returnItemSetting(ItemSetting.MAX_PERF).value;


% 108. Initial performance
% Warning!!!!: The initial performance cannot be less than the null
% performance
data = InputData();

data.setIdentifier(ItemSetting.INITIAL_PERF);
data.value = maxPerf;

progSet.add(data);

% 4. Demand function
fnc = Function();

fnc.setIdentifier(ItemSetting.DEMAND_FNC);
fnc.equation = @(v)demandFunction(v, nullPerf, maxPerf);

progSet.add(fnc);

% 109. Continuous response function
fnc = Function();

fnc.setIdentifier(ItemSetting.CONT_RESP_FNC);
fnc.equation = @continuousRespFunction;

progSet.add(fnc);

% 110. Shock response function
fnc = Function();

fnc.setIdentifier(ItemSetting.SHOCK_RESP_FNC);
fnc.equation = @(currentPerf, forceValue)CommonFnc.shockResponseFunction( nullp.value, ...
    maxp.value, ...
    currentPerf, ...
    forceValue);

progSet.add(fnc);


%% Contract (46 - 60)

% 49. Investment
inv = InputData();

inv.setIdentifier(ItemSetting.INV);
inv.value = 875;

progSet.add(inv);


%% Nature (61 - 75)

% 61. Natural hazard
data = InputData();

data.setIdentifier(ItemSetting.NAT_HAZARD);
data.value = false;

progSet.add(data);

% 62. Strategies Shock action
faculty = Faculty(Faculty.SHOCK);

faculty.setIdentifier(ItemSetting.STRATS_SHOCK)
faculty.selectStrategy('Test');

progSet.add(faculty);

% 63. Continuous environmental force
fnc = Function();

fnc.setIdentifier(ItemSetting.CONT_ENV_FORCE);
fnc.equation = @CommonFnc.continuousEnvForce;

progSet.add(fnc);


%% Principal (76 - 90)

% 75. Strategies Conctract offer action
faculty = Faculty(Faculty.CONTRACT_OFFER);

faculty.setIdentifier(ItemSetting.STRATS_CONTRACT);
faculty.selectStrategy('Simple');
rule = 'Simple parametrized';
params = [25, 6e-6, 70]; % [tm, fare, k*]
faculty.setParams(rule, params);

progSet.add(faculty);

% 52. Strategies Penalty fee enforcement action
faculty = Faculty(Faculty.PENALTY);

faculty.setIdentifier(ItemSetting.PEN_POLICY);
faculty.selectStrategy('Fixed');

progSet.add(faculty);

% 76. Strategies Inspection action
faculty = Faculty(Faculty.INSPECTION);

faculty.setIdentifier(ItemSetting.STRATS_INSP);
faculty.selectStrategy('Fixed_plus_random');
rule = 'Fixed inspection interval with random component';
params = [4, 0];
faculty.setParams(rule, params);

progSet.add(faculty);

% 77. Cost of single inspection
data = InputData();

data.setIdentifier(ItemSetting.COST_INSP);
data.value = progSet.returnItemSetting(ItemSetting.INV).value / 500;

progSet.add(data);

% 78. Principal utility function
fnc = Function();

fnc.setIdentifier(ItemSetting.PRINCIPAL_UTIL_FNC);
fnc.equation = @CommonFnc.principalUtility;

progSet.add(fnc);

%% Agent (91 - 105)

% 91. Participation constraint
data = InputData();

data.setIdentifier(InputData.PART_CONSTR);
data.value = 120;

progSet.add(data);

% 92. Strategies VoluntaryMaint action
faculty = Faculty(Faculty.VOL_MAINT);

faculty.setIdentifier(ItemSetting.STRATS_VOL_MAINT);
faculty.selectStrategy('Test_4');

progSet.add(faculty);

% 93. Strategies MandatoryMaint action
faculty = Faculty(Faculty.MAND_MAINT);

faculty.setIdentifier(ItemSetting.STRATS_MAND_MAINT);
faculty.selectStrategy('Minimum');

progSet.add(faculty);

% 95. Maintenance cost function
fnc = Function();

fnc.setIdentifier(InputData.MAINT_COST_FNC);
fnc.equation = @(current, goal)maintenanceCostFunction( inv.value, ...
                                                        nullp.value, ...
                                                        maxp.value, ...
                                                        current, ...
                                                        goal);

progSet.add(fnc);

% 96. Agent utility function
fnc = Function();

fnc.setIdentifier(ItemSetting.AGENT_UTIL_FNC);
fnc.equation = @CommonFnc.agentUtility;

progSet.add(fnc);


%% Finalization

disp(['    Completed: ',num2str(progSet.getNumberItems()),' settings objects created'])

progSet.lockSettings();
disp(' ')

end


%% Auxiliar functions

function cost = maintenanceCostFunction(inv, nullP, maxP, currentP, goalP)

    % inv:      Cost of construction: Investment
    % nullP:    Null performance
    % maxP:     Max performance
    % fixedCost:    Fixed (minimum) cost of a maintenance work
    
    % Maintenance cost can be at most epsilon times the value
    % of the construction investment
    epsilon = 0.2;
    fixedCost = 4;

    cost = ((goalP-currentP) / (maxP-nullP))*epsilon*inv + fixedCost;

    assert(isreal(cost), 'Cost must be a real number.')
end

function r = continuousRespFunction(f, d, v, t)
%{
* 

    Input
        f:  Continuous environmental force
        d:  Demand
        v:  Performance
        t:  Time (years)

    Output
        r:  Response
%}

a = 1.3;
b = 2.3;
vi = 100;

r = -a*b*((vi-v)./a).^((b-1)/b) - 0.01 - 0.6*t; %- (d/28e6)*20*((v^2)/500);
if v <= 0
    r = 0;
end

end

function d = demandFunction(v, nullPerf, maxPerf)
%{
* Bilinear demand function

    Input
        v:      Current performance
        nullPerf:   Minimum performance
        maxPerf:    Maximum performance

    Output
        d:      Rate of demand
%}
    
    n = length(v);
    d = zeros(n,1);

    for i=1:n
        d(i) = 12e6;
    end
end