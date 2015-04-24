classdef Principal <  entities.Player
    
    properties (Constant, Hidden = true)
        NAME = 'AGENT'
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
        contractAction      % Strategy object
        inspectionAction    % Strategy object
    end
    
    properties ( Dependent )
        
    end
    
    methods (Access = protected)
        
    end
    
    methods
        %% Constructor
        
        
        %{
        
            Input
                
            Output
                
        %}
        function thisPrincipal = Principal (progSet, problem)
            import managers.*
            
            % Creates instance of object of the superclass Player
            thisPrincipal@entities.Player(problem);
            
            % Cost single inspection
            cinsp = progSet.returnItemSetting(ItemSetting.COST_INSP);
            thisPrincipal.costSingleInspection = cinsp.value;
            
            % Assigns contract offer strategy attribute
            action = progSet.returnItemSetting(ItemSetting.STRATS_CONTRACT);
            thisPrincipal.contractAction = action.returnCopy();
            
            % Assigns inspection strategy attribute
            action = progSet.returnItemSetting(ItemSetting.STRATS_INSP);
            thisPrincipal.inspectionAction = action.returnCopy();
            
            % Utility function
            fnc = progSet.returnItemSetting(ItemSetting.PRINCIPAL_UTIL_FNC);
            thisPrincipal.utilityFunction = fnc.equation;    
            
        end
        
        %% Getter functions
        
        
        %%
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        %%
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------
        % ----------------------------------------------------------------
        
        function contract = generateContract(thisPrincipal)
            
            import dataComponents.Message
            
            msg = Message(thisPrincipal);
            thisPrincipal.contractAction.decide(msg);
        end
        
        %{
        
            Input
                None
            Output
                operation: [class Operation] 
        %}
        function operation = submitOperation(thisPrincipal)
            import dataComponents.Operation
            import dataComponents.Message
            import dataComponents.Transaction
            import managers.Strategy
            import managers.Information
            
            if isempty(thisPrincipal.submittedOperation)
                
                msg = Message(thisPrincipal);
                msg.setTypeRequestedInfo(Information.TIME_INSPECTION);
                
                thisPrincipal.inspectionAction.decide(msg);
                
                timeNextInspection = msg.getOutput(Information.TIME_INSPECTION);
                
                isSens = thisPrincipal.inspectionAction.isSensitive();
                
                operation = Operation(timeNextInspection, Operation.INSPECTION, isSens, []);
                [timeNextPayment, valueNextPayment] = thisPrincipal.contract.getNextPayment(thisPrincipal.time);
                
                % Produce transaction if earlier than maintenance
                if timeNextPayment < timeNextInspection
                    transaction = Transaction(timeNextPayment, ...
                        valueNextPayment, ...
                        Information.PRINCIPAL, ...
                        Information.AGENT);
                    
                    operation = transaction;
                end
                
                % Stores Operation object
                thisPrincipal.setSubmittedOperation(operation);
                
            else
                operation = thisPrincipal.submittedOperation;
            end
            
        end
        
        function operation = submitFinalInspection(thisPrincipal)
            % DELETE method
            
            warning('Deprecated. Final inspection is responsability of theinspection strategy.')
            
            import dataComponents.Operation
            
            finalTimeContract = thisPrincipal.contract.getContractDuration();
            
            operation = Operation(finalTimeContract, Operation.INSPECTION, false, [] );
            thisPrincipal.setSubmittedOperation(operation);
        end
        
        
        %%
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------

        
    end
    
    methods (Static)
        
    end
    
end