classdef Agent < entities.Player
    
    properties (Constant, Hidden = true)
        NAME = 'AGENT'
        
        % Types of cash flow/actions
        ALL = 'ALL';
        REVENUE = 'REVENUE'
        CONTRIBUTION = 'CONTRIBUTION'
        INVESTMENT = 'INVESTMENT'
        MAINTENANCE = 'MAINTENANCE'
        PENALTY = 'PENALTY'
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        maintCostFunction
        
        % ----------- %
        % Objects
        % ----------- %
        
        % Active strategies
        volMaintStrategy
        
        % Reactive strategies
        mandMaintStrategy
    end
    
    properties (Dependent)
        inferredInspectionRate
    end
    
    methods (Static)
        
    end
        
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Agent(progSet, problem)
        %{
        * Constructor method of Agent class
        
            Input
                contract: [class Contract] Contract object with the
                specified properties of the current contract
            
            Output
                self: [class Agent] Agent object
        %}
            
            import managers.*
            
            % Creates instance of object of the superclass Player
            self@entities.Player(problem);
            
            % Assigns voluntary maintenance action
            faculty = progSet.returnItemSetting(ItemSetting.STRATS_VOL_MAINT);
            self.volMaintStrategy = faculty.getSelectedStrategy();
            
            % Assigns mandatory maintenance action
            faculty = progSet.returnItemSetting(ItemSetting.STRATS_MAND_MAINT);
            self.mandMaintStrategy = faculty.getSelectedStrategy();
            
            % Maintenance cost function
            fnc = progSet.returnItemSetting(ItemSetting.MAINT_COST_FNC);
            self.maintCostFunction = fnc.equation;
            
            % Utility function
            fnc = progSet.returnItemSetting(ItemSetting.AGENT_UTIL_FNC);
            self.utilityFunction = fnc.equation;
            
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function operation = submitOperation(self, contSolver, infra)
        %{
        * Implements agent's decision rule, determines action to submit.
        The action is saved in the submittedAction attribute. Returns the
        time of the submitted action
        
            Input
                currentPerf: [class double] 
                solvePerformanceForTime: function handle for solving perf
            
            Output
                time: Time of the commited action
        %}
            
            import dataComponents.Operation
            import dataComponents.Message
            import managers.Information
            import managers.Faculty
            
            
            
            % Adding extra info to message
            msg = Faculty.createEmptyMessage(self, Faculty.VOL_MAINT);
            msg.setExtraInfo(...
                Message.MAX_PERF, infra.maxPerf, ...
                Message.CONT_SOLVER, contSolver);
            
            self.volMaintStrategy.decide(msg);
            
            isSens = self.volMaintStrategy.isSensitive();
            
            timeMaint = msg.getOutput(Information.TIME_VOL_MAINT);
            perfGoal = msg.getOutput(Information.PERF_VOL_MAINT);
            
            operation = Operation(timeMaint, Operation.VOL_MAINT, isSens, perfGoal);
            
            % Stores Operation object
            self.setSubmittedOperation(operation);
            
        end
        
        function evolve(self, t, bal)
            self.payoffList.registerBalance(t, bal);
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function utility = calculateUtility(self)
        %{
        
            Input
                
            Output
                
        %}
            
           utility = self.getPresentValue();
           
        end
        
        
    end
end