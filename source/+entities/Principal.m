classdef Principal <  entities.Player
    %PRINCIPAL Summary of this class goes here
    %   Detailed explanation goes here
    %{
    
    %}

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
        inspectionAction     % Strategy object
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
        function thisPrincipal = Principal (progSet, contract, problem)
            import managers.*
            
            % Creates instance of object of the superclass Player
            thisPrincipal@entities.Player(contract, problem);
            
            % Cost single inspection
            cinsp = progSet.returnItemSetting(ItemSetting.COST_INSP);
            thisPrincipal.costSingleInspection = cinsp.value;
            
            % Assigns inspection strategy attribute
            action = progSet.returnItemSetting(ItemSetting.STRATS_INSP);
            thisPrincipal.inspectionAction = returnCopyAction(action);
            
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

        
        %{
        
            Input
                None
            Output
                operation: [class Operation] 
        %}
        function operation = submitOperation(thisPrincipal)
            import dataComponents.Operation
            import dataComponents.Message
            import managers.Strategy
            import managers.Information
            
            if isempty(thisPrincipal.submittedOperation)
                
                msg = Message(thisPrincipal);
                msg.setTypeRequestedInfo(Information.TIME_INSPECTION);
                
                thisPrincipal.inspectionAction.decide(msg);
                
                timeNextInspection = msg.getOutput(Information.TIME_INSPECTION);
                
                isSens = thisPrincipal.inspectionAction.isSensitive();
                
                operation = Operation(timeNextInspection, Operation.INSPECTION, isSens, []);
                
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