classdef Agent < entities.Player
    %AGENT Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant, Hidden = true)
        
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
        volMaintAction
        
        % Reactive strategies
        mandMaintAction
    end
    
    methods (Access = protected)

    end
    
    properties (Dependent)
        inferredInspectionRate
    end
        
    
    methods
        %% Constructor
        
        
        function thisAgent = Agent(progSet, contract, problem)
        %{
        * Constructor method of Agent class
        
            Input
                contract: [class Contract] Contract object with the
                specified properties of the current contract
            
            Output
                thisAgent: [class Agent] Agent object
        %}
            
            import managers.*
            
            % Creates instance of object of the superclass Player
            thisAgent@entities.Player(contract, problem);
            
            % Assigns voluntary maintenance action
            action = progSet.returnItemSetting(ItemSetting.STRATS_VOL_MAINT);
            thisAgent.volMaintAction = returnCopyAction(action);
            
            % Assigns mandatory maintenance action
            action = progSet.returnItemSetting(ItemSetting.STRATS_MAND_MAINT);
            thisAgent.mandMaintAction = returnCopyAction(action);
            
            % Maintenance cost function
            fnc = progSet.returnItemSetting(ItemSetting.MAINT_COST_FNC);
            thisAgent.maintCostFunction = fnc.equation;
            
            % Utility function
            fnc = progSet.returnItemSetting(ItemSetting.AGENT_UTIL_FNC);
            thisAgent.utilityFunction = fnc.equation;
            
        end
        
        
        %% Getter functions
        
        
        %{
        * Calculates inferred inspection rate from the past registered
        inspection events. This function is called every time the
        inferredInspectionRate attribute is accessed
        
            Input
                None
            
            Output
                inferredInspectionRate: [class double] Value of the inferred
                inspection rate
        %}
        %{
        function inferredInspectionRate = get.inferredInspectionRate(thisAgent)
            
            if thisAgent.eventList.isSingle()
                timeInsp = eventList.returnTimeSeries();
                inferredInspectionRate = 1/mean(diff(timeInsp));
            else
                % How should this initial value be set?
                inferredInspectionRate = 2;
            end
        end
        %}
        
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        

        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        
        function operation = submitOperation(thisAgent, currentPerf, ...
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
            
            thisAgent.solvePerformanceForTime = solvePerformanceForTime;
            thisAgent.solveTimeForPerformance = solveTimeForPerformance;
            
            msg = Message(thisAgent);
            msg.setTypeRequestedInfo(Information.TIME_VOL_MAINT, ...
                                     Information.PERF_VOL_MAINT);
            
            msg.setExtraInfo(Message.MAX_PERF, infra.maxPerf)
            
            thisAgent.volMaintAction.decide(msg);
            
            isSens = thisAgent.volMaintAction.isSensitive();
            
            timeMaint = msg.getOutput(Information.TIME_VOL_MAINT);
            perfGoal = msg.getOutput(Information.PERF_VOL_MAINT);
            
            operation = Operation(timeMaint, Operation.VOL_MAINT, isSens, perfGoal);
            
            % Stores Operation object
            thisAgent.setSubmittedOperation(operation);
            
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
        function utility = calculateUtility(thisAgent)
        %{
        
            Input
                
            Output
                
        %}
            
           utility = thisAgent.getPresentValue();
           
        end
        
        
        
    end

end