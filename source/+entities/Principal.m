classdef Principal <  entities.Player
    
    properties (Constant, Hidden = true)
        NAME = 'PRINCIPAL'
    end
    
    properties (GetAccess = public, SetAccess = protected, Hidden = true)
        costSingleInspection
    end

    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        % ----------- %
        % Objects
        % ----------- %
        
        % Active strategies
        contractStrategy      % Strategy object
        inspectionStrategy    % Strategy object
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Principal (progSet, problem)
        %{
        
            Input
                
            Output
                
        %}
            import managers.*
            
            % Creates instance of object of the superclass Player
            self@entities.Player(problem);
            
            % Cost single inspection
            cinsp = progSet.returnItemSetting(ItemSetting.COST_INSP);
            self.costSingleInspection = cinsp.value;
            
            % Assigns contract offer strategy attribute
            faculty = progSet.returnItemSetting(ItemSetting.STRATS_CONTRACT);
            self.contractStrategy = faculty.getSelectedStrategy();
            
            % Assigns inspection strategy attribute
            faculty = progSet.returnItemSetting(ItemSetting.STRATS_INSP);
            self.inspectionStrategy = faculty.getSelectedStrategy();
            
            % Utility function
            fnc = progSet.returnItemSetting(ItemSetting.PRINCIPAL_UTIL_FNC);
            self.utilityFunction = fnc.equation;    
            
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function contract = generateContract(self, progSet, infra)
        %{
        
            Input
                
            Output
                
        %}
            import dataComponents.Message
            import dataComponents.Contract
            import managers.Information
            import managers.Faculty
            
            msg = Faculty.createEmptyMessage(self, Faculty.CONTRACT_OFFER);
            self.contractStrategy.decide(msg);
            
            conDur = msg.getOutput(Information.CONTRACT_DURATION);
            perfThreshold = msg.getOutput(Information.PERFORMANCE_THRESHOLD);
            principalContributions = msg.getOutput(Information.PAYMENT_SCHEDULE);
            revRateFnc = msg.getOutput(Information.REVENUE_RATE_FUNC);
            
            assert(infra.nullPerf <= perfThreshold && perfThreshold <= infra.maxPerf, ...
                'Performance threshold must be withinn [nullPerf, maxPerf] interval.')
            
            contract = Contract(progSet, conDur, principalContributions, ...
                revRateFnc, perfThreshold);
        end
        
        
        function operation = submitOperation(self)
        %{
        
            Input
                None
            Output
                operation: [class Operation] 
        %}
            import dataComponents.Operation
            import dataComponents.Message
            import dataComponents.Transaction
            import managers.Strategy
            import managers.Information
            import managers.Faculty
            
            if isempty(self.submittedOperation)
                
                msg = Faculty.createEmptyMessage(self, Faculty.INSPECTION);
                self.inspectionStrategy.decide(msg);
                
                timeNextInspection = msg.getOutput(Information.TIME_INSPECTION);
                
                isSens = self.inspectionStrategy.isSensitive();
                
                operation = Operation(timeNextInspection, Operation.INSPECTION, isSens, []);
                self.setSubmittedOperation(operation);
                
            else
                operation = self.submittedOperation;
            end
            
        end
        
    end
end