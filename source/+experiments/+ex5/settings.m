%{

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
data.setAsGiven();
data.value = Experiment.SING;

progSet.add(data);

% 2. Time resolution
data = InputData();

data.setIdentifier(ItemSetting.TIME_RES);
data.setAsGiven();
data.value = 1/365;

progSet.add(data);

% 3. Annual discount rate
data = InputData();

data.setIdentifier(ItemSetting.DISC_RATE);
data.setAsGiven();
data.value = 0.04;

progSet.add(data);

%% Optimization (16 - 30)

% 16. Number of realizations per simulation of game
data = InputData();

data.setIdentifier(ItemSetting.NUM_REALIZ);
data.setAsGiven();
data.value = 500;

progSet.add(data);

% 17. Maximum number of interations - Stopping criterion
% This is the maximum number of generations of the genetic algorithm
% both the inner and outer
data = InputData();

data.setIdentifier(ItemSetting.MAX_ITER);
data.setAsGiven();
data.value = 100;

progSet.add(data);

% 18. Tolerance - Stopping criterion
data = InputData();

data.setIdentifier(ItemSetting.TOL);
data.setAsGiven();
data.value = 0.005;

progSet.add(data);

%% Realization (31 - 45)


%% Infrastructure (106 - 120)

% 106. Null performance
nullp = InputData();

nullp.setIdentifier(ItemSetting.NULL_PERF);
nullp.setAsGiven();
nullp.value = 0;

progSet.add(nullp);

% 107. Maximum performance
maxp = InputData();

maxp.setIdentifier(ItemSetting.MAX_PERF);
maxp.setAsGiven();
maxp.value = 100;

progSet.add(maxp);

% 108. Initial performance
% Warning!!!!: The initial performance cannot be less than the null
% performance
data = InputData();

data.setIdentifier(ItemSetting.INITIAL_PERF);
data.setAsGiven();
data.value = progSet.returnItemSetting(ItemSetting.MAX_PERF).value;

progSet.add(data);

% 109. Deterioration function
fnc = Function();

fnc.setIdentifier(ItemSetting.DET_RATE);
fnc.setAsGiven();
fnc.equation = @deteriorationRate;

progSet.add(fnc);

% 110. Shock response function
fnc = Function();

fnc.setIdentifier(ItemSetting.SHOCK_RESP_FNC);
fnc.setAsGiven();
fnc.equation = @(currentPerf, forceValue)experiments.CommonFnc.shockResponseFunction( nullp.value, ...
                                                                maxp.value, ...
                                                                currentPerf, ...
                                                                forceValue);

progSet.add(fnc);


%% Contract (46 - 60)

% 46. Contract duration
data = InputData();

data.setIdentifier(ItemSetting.CON_DUR);
data.setAsControlled(ItemSetting.PRINCIPAL);
data.value = 25;
data.setValue_NumberSet(InputData.REAL);
data.value_LowerBound = 5;
data.value_UpperBound = 100;

progSet.add(data);

% 47. Performance threshold
data = InputData();

data.setIdentifier(ItemSetting.PERF_THRESH);
data.setAsControlled(ItemSetting.PRINCIPAL);
data.value = 70;

data.setValue_NumberSet(InputData.REAL);
data.value_LowerBound = progSet.returnItemSetting(ItemSetting.NULL_PERF).value;
data.value_UpperBound = progSet.returnItemSetting(ItemSetting.MAX_PERF).value;

progSet.add(data);

% 48. Revenue: Tolls
data = InputData();

data.setIdentifier(ItemSetting.REV);
data.setAsGiven();
data.value = 1800;

progSet.add(data);

% 49. Investment
inv = InputData();

inv.setIdentifier(ItemSetting.INV);
inv.setAsGiven();
inv.value = 875;

progSet.add(inv);

% 50. Contributions
data = InputData(); 

data.setIdentifier(ItemSetting.CONTRIB);
data.setAsGiven();
data.value = 400;

progSet.add(data);

% 51. Maximum cumulative penalty
data = InputData();

data.setIdentifier(ItemSetting.MAX_SUM_PEN);
data.setAsGiven();
data.value = 400;

progSet.add(data);

% 52. Strategies Penalty fee enforcement action
action = Action(Action.PENALTY, ItemSetting.PRINCIPAL);

action.setIdentifier(ItemSetting.PEN_POLICY);
action.setAsGiven();
action.selectStrategy(1);
action.setParamsValue_Random();

progSet.add(action);


%% Nature (61 - 75)

% 61. Natural hazard
data = InputData();

data.setIdentifier(ItemSetting.NAT_HAZARD);
data.setAsGiven();
data.value = false;

progSet.add(data);

% 62. Strategies Shock action
action = Action(Action.SHOCK, ItemSetting.NATURE);

action.setIdentifier(ItemSetting.STRATS_SHOCK)
action.setAsGiven();
action.selectStrategy(1);
action.setParamsValue_Random();

progSet.add(action);


%% Principal (76 - 90)

% 76. Strategies Inspection action
action = Action(Action.INSPECTION, ItemSetting.PRINCIPAL);

action.setIdentifier(ItemSetting.STRATS_INSP);
action.setAsGiven();
action.selectStrategy(1);
%action.setParamsValue_Random();

progSet.add(action);

% 77. Cost of single inspection
data = InputData();

data.setIdentifier(ItemSetting.COST_INSP);
data.setAsGiven();
data.value = progSet.returnItemSetting(ItemSetting.INV).value / 1000;

progSet.add(data);

% 78. Principal utility function
fnc = Function();

fnc.setIdentifier(ItemSetting.PRINCIPAL_UTIL_FNC);
fnc.setAsGiven();
fnc.equation = @experiments.CommonFnc.principalUtility;

progSet.add(fnc);

%% Agent (91 - 105)

% 91. Participation constraint
data = InputData();

data.setIdentifier(InputData.PART_CONSTR);
data.setAsGiven();
data.value = 120;

progSet.add(data);

% 92. Strategies VoluntaryMaint action
action = Action(Action.VOL_MAINT, ItemSetting.AGENT);

action.setIdentifier(ItemSetting.STRATS_VOL_MAINT);
action.setAsGiven();
action.selectStrategy(4);
%action.setParamsValue_Random();

progSet.add(action);

% 93. Strategies MandatoryMaint action
action = Action(Action.MAND_MAINT, ItemSetting.AGENT);

action.setIdentifier(ItemSetting.STRATS_MAND_MAINT);
action.setAsGiven();
action.selectStrategy(1);
action.setParamsValue_Random();

progSet.add(action);

% 94. Fixed maintenance cost
fixedMaintCost = InputData();

fixedMaintCost.setIdentifier(InputData.FIXED_MAINT_COST);
fixedMaintCost.setAsGiven();
fixedMaintCost.value = 4;

progSet.add(fixedMaintCost);

% 95. Maintenance cost function
fnc = Function();

fnc.setIdentifier(InputData.MAINT_COST_FNC);
fnc.setAsGiven();
fnc.equation = @(current, goal)maintenanceCostFunction( inv.value, ...
                                                        nullp.value, ...
                                                        maxp.value, ...
                                                        fixedMaintCost.value, ...
                                                        current, ...
                                                        goal);

progSet.add(fnc);

% 96. Agent utility function
fnc = Function();

fnc.setIdentifier(ItemSetting.AGENT_UTIL_FNC);
fnc.setAsGiven();
fnc.equation = @experiments.CommonFnc.agentUtility;

progSet.add(fnc);


%% Finalization

disp(['    Completed: ',num2str(progSet.getNumberItems()),' settings objects created'])

progSet.lockSettings();
disp(' ')

end


%% Auxiliar functions

function cost = maintenanceCostFunction(inv, nullP, maxP, fixedCost, currentP, goalP)

    % inv:      Cost of construction: Investment
    % nullP:    Null performance
    % maxP:     Max performance
    % fixedCost:    Fixed (minimum) cost of a maintenance work
    
    % Maintenance cost can be at most epsilon times the value
    % of the construction investment
    epsilon = 0.2;

    cost = (  sqrt((goalP-nullP) / (maxP-nullP)) - ...
              sqrt((currentP-nullP) / (maxP-nullP)))*epsilon*inv + fixedCost;

    assert(isreal(cost), 'Cost must be a real number.')
end

function dydt = deteriorationRate(t,v)
a = 1.3;
b = 2.3;
vi = 100;

dydt = -15;
end