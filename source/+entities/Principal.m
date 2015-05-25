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
        
        function thisPrincipal = Principal (progSet, problem)
        %{
        
            Input
                
            Output
                
        %}
            import managers.*
            
            % Creates instance of object of the superclass Player
            thisPrincipal@entities.Player(problem);
            
            % Cost single inspection
            cinsp = progSet.returnItemSetting(ItemSetting.COST_INSP);
            thisPrincipal.costSingleInspection = cinsp.value;
            
            % Assigns contract offer strategy attribute
            faculty = progSet.returnItemSetting(ItemSetting.STRATS_CONTRACT);
            thisPrincipal.contractStrategy = faculty.getSelectedStrategy();
            
            % Assigns inspection strategy attribute
            faculty = progSet.returnItemSetting(ItemSetting.STRATS_INSP);
            thisPrincipal.inspectionStrategy = faculty.getSelectedStrategy();
            
            % Utility function
            fnc = progSet.returnItemSetting(ItemSetting.PRINCIPAL_UTIL_FNC);
            thisPrincipal.utilityFunction = fnc.equation;    
            
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function contract = generateContract(thisPrincipal, progSet)
        %{
        
            Input
                
            Output
                
        %}
            import dataComponents.Message
            import dataComponents.Contract
            import managers.Information
            
            msg = Message(thisPrincipal);
            msg.setTypeRequestedInfo(Information.CONTRACT_DURATION, ...
                Information.PERFORMANCE_THRESHOLD, ...
                Information.PAYMENT_SCHEDULE, ...
                Information.REVENUE_RATE_FUNC);
            
            thisPrincipal.contractStrategy.decide(msg);
            
            conDur = msg.getOutput(Information.CONTRACT_DURATION);
            perfThreshold = msg.getOutput(Information.PERFORMANCE_THRESHOLD);
            paymentSchedule = msg.getOutput(Information.PAYMENT_SCHEDULE);
            revRateFnc = msg.getOutput(Information.REVENUE_RATE_FUNC);
            
            contract = Contract(progSet, conDur, perfThreshold, ...
                paymentSchedule, revRateFnc);
        end
        
        
        function operation = submitOperation(thisPrincipal)
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
            
            if isempty(thisPrincipal.submittedOperation)
                
                msg = Message(thisPrincipal);
                msg.setTypeRequestedInfo(Information.TIME_INSPECTION);
                
                thisPrincipal.inspectionStrategy.decide(msg);
                
                timeNextInspection = msg.getOutput(Information.TIME_INSPECTION);
                
                isSens = thisPrincipal.inspectionStrategy.isSensitive();
                
                operation = Operation(timeNextInspection, Operation.INSPECTION, isSens, []);
                thisPrincipal.setSubmittedOperation(operation);
                
            else
                operation = thisPrincipal.submittedOperation;
            end
            
        end
        
        
        function operation = submitFinalInspection(thisPrincipal)
        %{
        * 
            Input
                
            Output
                
        %}
            
            % TODO DELETE method
            
            warning('Deprecated. Final inspection is responsability of theinspection strategy.')
            
            import dataComponents.Operation
            
            finalTimeContract = thisPrincipal.contract.getContractDuration();
            
            operation = Operation(finalTimeContract, Operation.INSPECTION, false, [] );
            thisPrincipal.setSubmittedOperation(operation);
        end
        
        
    end
end