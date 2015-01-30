classdef Nature < handle
    %NATURE Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant, Hidden = true)
        % Actions available
        SHOCK = 'SHOCK'
        UPDATEPERF = 'UPDATEPERF';
    end
    
    
    properties
        % ----------- %
        % Attributes
        % ----------- %
        time = 0
        hazard          % [Boolean] Turns on and off the natural hazards
        
        % ----------- %
        % Objects
        % ----------- %
        
        shockAction
        
        infrastructure
        
        submittedOperation
        
    end
    
    events
        finishedShock
    end
    
    methods (Access = protected)

    end
    
    methods
        %% Constructor
        
        
        %{
        
            Input
                
            Output
                
        %}
        function thisNature = Nature(progSet, contract)
            import managers.*
            
            % Active hazard status
            thisNature.hazard = progSet.returnItemSetting(ItemSetting.NAT_HAZARD).value;
            
            % Shock strategy
            action = progSet.returnItemSetting(ItemSetting.STRATS_SHOCK);
            thisNature.shockAction = returnCopyAction(action);
            
            % Creates infrastructure object
            thisNature.infrastructure = entities.Infrastructure(progSet, contract);
        end
        
        %% Getter functions
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        %{
        
            Input
                
            Output
                
        %}
        function time = getTime(thisNature)
            time = thisNature.time;
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function performance = getCurrentPerformance(thisNature)
            performance = thisNature.infrastructure.getPerformance();
        end
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------
        % ----------------------------------------------------------------
        
        
        %{
        
            Input
                
            Output
                
        %}
        function setTime(thisNature,time)
            if time > thisNature.time
                thisNature.time = time;
                thisNature.infrastructure.setTime(time);
            end
        end
        
        %{
        
            Input
                
            Output
                
        %}
        function operation = submitOperation(thisNature)
            import dataComponents.Operation
            import dataComponents.Message
            import managers.Strategy
            import managers.Information
            
            if thisNature.hazard == true
                if isempty(thisNature.submittedOperation)
                    
                    msg = Message(thisNature);
                    
                    msg.setTypeRequestedInfo(Information.TIME_SHOCK, ...
                                             Information.FORCE_SHOCK);
                                         
                    thisNature.shockAction.decide(msg);
                    
                    isSens = thisNature.shockAction.isSensitive();
                    
                    timeShock = msg.getOutput(Information.TIME_SHOCK);
                    shockForce = msg.getOutput(Information.FORCE_SHOCK);
                    
                    operation = Operation( timeShock, Operation.SHOCK, isSens, shockForce);
                    
                    % Stores Operation object
                    thisNature.setSubmittedOperation( operation );
                    
                else
                    operation = thisNature.submittedOperation;
                end
                
            else
                % If natural hazard is turned off, the next shock will not
                % occur
                timeOp = inf;
                perfGoalOp = 0;
                operation = Operation( timeOp, Operation.SHOCK, false, perfGoalOp);
            end
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function applyOperation(thisNature, operation)
            import dataComponents.Operation
            
            condition = operation.isType(Operation.VOL_MAINT) || operation.isType(Operation.MAND_MAINT) || ...
                operation.isType(Operation.SHOCK);
            
            assert(condition == true, 'Only maintenance (vol or maint) or shock operation can be applied to nature')
            
            if operation.isType(Operation.VOL_MAINT) || operation.isType(Operation.MAND_MAINT)
                thisNature.infrastructure.registerObservation(operation.time, operation.perfGoal);
                
            else % For shock operations, the force value must be translated into perfGoal
                perfBeforeShock = thisNature.solvePerformanceForTime(operation.time);
                forceValue = operation.forceValue;
                perfGoal = thisNature.infrastructure.shockResponseFunction(perfBeforeShock, forceValue);
                
                thisNature.infrastructure.registerObservation(operation.time, perfGoal);
                
            end
            
        end
        
        function confirmExecutionSubmittedOperation(thisNature, operation)
            assert(~isempty(thisNature.submittedOperation), ...
                'The attribute submitted operation should not be empty.')
            
            assert(thisNature.submittedOperation.eq(operation), ...
                'The operation executed does not coincide with the operation submitted.')
            
            thisNature.clearSubmittedOperation();
            
        end
        
        %{
        
            Input
                
            Output
                
        %}
        function setSubmittedOperation(thisNature, operation)
            thisNature.submittedOperation = operation;
        end
        
        %{
        
            Input
                
            Output
                
        %}
        function clearSubmittedOperation(thisNature)
            thisNature.submittedOperation = [];
        end
       

        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
        %{
        
            Input
                
            Output
                
        %}
        function performance = solvePerformanceForTime(thisNature,time)
            performance = thisNature.infrastructure.solvePerformanceForTime(time);
        end
        
    end
end

%% Auxiliary functions


    %{

        Input

        Output

    %}

