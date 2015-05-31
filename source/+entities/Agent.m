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
        solvePerformanceForTime
        solveTimeForPerformance
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
        
        function contract = submitContract(progSet, contractStrategy)
        %{
        
            Input
                
            Output
                
        %}
            
            import dataComponents.*
            import managers.*
            
            
            msg = Message();
            msg.setTypeRequestedInfo(Information.CONTRACT_DURATION, ...
                Information.PAYMENT_SCHEDULE, ...
                Information.REVENUE_RATE_FUNC, ...
                Information.PERFORMANCE_THRESHOLD);
            
            contractStrategy.decide(msg);
            
            conDur = msg.getOutput(Information.CONTRACT_DURATION);
            paymentSch = msg.getOutput(Information.PAYMENT_SCHEDULE);
            revRateFnc = msg.getOutput(Information.REVENUE_RATE_FUNC);
            threshold = msg.getOutput(Information.PERFORMANCE_THRESHOLD);
            
            contract = Contract(progSet, conDur, paymentSch, revRateFnc, threshold);
            
        end
        
        
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
        
        function operation = submitOperation(self, currentPerf, ...
                solvePerformanceForTime, solveTimeForPerformance, ...
                perfRange, infra)
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
            import managers.Strategy
            import managers.Information
            
            self.solvePerformanceForTime = solvePerformanceForTime;
            self.solveTimeForPerformance = solveTimeForPerformance;
            
            msg = Message(self);
            msg.setTypeRequestedInfo(Information.TIME_VOL_MAINT, ...
                                     Information.PERF_VOL_MAINT);
            
            msg.setExtraInfo(Message.MAX_PERF, infra.maxPerf)
            
            self.volMaintStrategy.decide(msg);
            
            isSens = self.volMaintStrategy.isSensitive();
            
            timeMaint = msg.getOutput(Information.TIME_VOL_MAINT);
            perfGoal = msg.getOutput(Information.PERF_VOL_MAINT);
            
            operation = Operation(timeMaint, Operation.VOL_MAINT, isSens, perfGoal);
            
            % Stores Operation object
            self.setSubmittedOperation(operation);
            
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