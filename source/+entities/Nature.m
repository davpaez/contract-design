classdef Nature < handle
    % This class represents the natural environment
    
    properties
        % ----------- %
        % Attributes
        % ----------- %
        time = 0
        hazard          % [Boolean] Turns on and off the natural hazards
        
        contEnvForce    % Function handle
        
        % ----------- %
        % Objects
        % ----------- %
        
        infrastructure
        shockAction
        submittedOperation
        
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function thisNature = Nature(progSet)
        %{
        
            Input
                
            Output
                
        %}
            import managers.ItemSetting
            import entities.Infrastructure
            
            % Active hazard status
            thisNature.hazard = progSet.returnItemSetting(ItemSetting.NAT_HAZARD).value;
            
            % Shock strategy
            action = progSet.returnItemSetting(ItemSetting.STRATS_SHOCK);
            thisNature.shockAction = action.returnCopy();
            
            % Creates infrastructure object
            thisNature.infrastructure = Infrastructure(progSet);
        end
        
        
        %% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
        
        function time = getTime(thisNature)
        %{
        
            Input
                
            Output
                
        %}
            time = thisNature.time;
        end
        
        
        function performance = getCurrentPerformance(thisNature)
        %{
        
            Input
                
            Output
                
        %}
            performance = thisNature.infrastructure.getPerformance();
        end


        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function setTime(thisNature,time)
        %{
        
            Input
                
            Output
                
        %}
            if time > thisNature.time
                thisNature.time = time;
                thisNature.infrastructure.setTime(time);
            end
        end
        
        
        function operation = submitOperation(thisNature)
        %{
        
            Input
                
            Output
                
        %}
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
        
        
        function applyOperation(thisNature, operation)
        %{
        
            Input
                
            Output
                
        %}
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
        
        
        function finalizeHistory(thisNature, time)
        %{
        
            Input
                
            Output
                
        %}
            thisNature.infrastructure.setTime(time);
        end
        
        
        function confirmExecutionSubmittedOperation(thisNature, operation)
        %{
        
            Input
                
            Output
                
        %}
            assert(~isempty(thisNature.submittedOperation), ...
                'The attribute submitted operation should not be empty.')
            
            assert(thisNature.submittedOperation.eq(operation), ...
                'The operation executed does not coincide with the operation submitted.')
            
            thisNature.clearSubmittedOperation();
            
        end
        
        
        function setSubmittedOperation(thisNature, operation)
        %{
        
            Input
                
            Output
                
        %}
            thisNature.submittedOperation = operation;
        end
        
        
        function clearSubmittedOperation(thisNature)
        %{
        
            Input
                
            Output
                
        %}
            thisNature.submittedOperation = [];
        end
       
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function performance = solvePerformanceForTime(thisNature,time)
        %{
        
            Input
                
            Output
                
        %}
            performance = thisNature.infrastructure.solvePerformanceForTime(time);
        end
        
        
    end
end