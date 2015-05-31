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
        
        function contract = generateContract(self, progSet)
        %{
        
            Input
                
            Output
                
        %}
            import dataComponents.Message
            import dataComponents.Contract
            import managers.Information
            
            msg = Message(self);
            msg.setTypeRequestedInfo(Information.CONTRACT_DURATION, ...
                Information.PERFORMANCE_THRESHOLD, ...
                Information.PAYMENT_SCHEDULE, ...
                Information.REVENUE_RATE_FUNC);
            
            self.contractStrategy.decide(msg);
            
            conDur = msg.getOutput(Information.CONTRACT_DURATION);
            perfThreshold = msg.getOutput(Information.PERFORMANCE_THRESHOLD);
            paymentSchedule = msg.getOutput(Information.PAYMENT_SCHEDULE);
            revRateFnc = msg.getOutput(Information.REVENUE_RATE_FUNC);
            
            contract = Contract(progSet, conDur, perfThreshold, ...
                paymentSchedule, revRateFnc);
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
            
            if isempty(self.submittedOperation)
                
                msg = Message(self);
                msg.setTypeRequestedInfo(Information.TIME_INSPECTION);
                
                self.inspectionStrategy.decide(msg);
                
                timeNextInspection = msg.getOutput(Information.TIME_INSPECTION);
                
                isSens = self.inspectionStrategy.isSensitive();
                
                operation = Operation(timeNextInspection, Operation.INSPECTION, isSens, []);
                self.setSubmittedOperation(operation);
                
            else
                operation = self.submittedOperation;
            end
            
        end
        
        
        function operation = submitFinalInspection(self)
        %{
        * 
            Input
                
            Output
                
        %}
            
            % TODO DELETE method
            
            warning('Deprecated. Final inspection is responsability of theinspection strategy.')
            
            import dataComponents.Operation
            
            finalTimeContract = self.contract.getContractDuration();
            
            operation = Operation(finalTimeContract, Operation.INSPECTION, false, [] );
            self.setSubmittedOperation(operation);
        end
        
        
    end
end