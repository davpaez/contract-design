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
        shockStrategy
        submittedOperation
        
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Nature(progSet)
        %{
        
            Input
                
            Output
                
        %}
            import managers.ItemSetting
            import entities.Infrastructure
            
            % Active hazard status
            self.hazard = progSet.returnItemSetting(ItemSetting.NAT_HAZARD).value;
            
            % Shock strategy
            faculty = progSet.returnItemSetting(ItemSetting.STRATS_SHOCK);
            self.shockStrategy = faculty.getSelectedStrategy();
            
            % Creates infrastructure object
            self.infrastructure = Infrastructure(progSet);
        end
        
        
        %% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
        
        function time = getTime(self)
        %{
        
            Input
                
            Output
                
        %}
            time = self.time;
        end
        
        
        function performance = getCurrentPerformance(self)
        %{
        
            Input
                
            Output
                
        %}
            performance = self.infrastructure.getPerformance();
        end


        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function setTime(self,time)
        %{
        
            Input
                
            Output
                
        %}
            if time > self.time
                self.time = time;
                self.infrastructure.setTime(time);
            end
        end
        
        
        function operation = submitOperation(self)
        %{
        
            Input
                
            Output
                
        %}
            import dataComponents.Operation
            import dataComponents.Message
            import managers.Strategy
            import managers.Information
            
            if self.hazard == true
                if isempty(self.submittedOperation)
                    
                    msg = Message(self);
                    
                    msg.setTypeRequestedInfo(Information.TIME_SHOCK, ...
                                             Information.FORCE_SHOCK);
                                         
                    self.shockStrategy.decide(msg);
                    
                    isSens = self.shockStrategy.isSensitive();
                    
                    timeShock = msg.getOutput(Information.TIME_SHOCK);
                    shockForce = msg.getOutput(Information.FORCE_SHOCK);
                    
                    operation = Operation( timeShock, Operation.SHOCK, isSens, shockForce);
                    
                    % Stores Operation object
                    self.setSubmittedOperation( operation );
                    
                else
                    operation = self.submittedOperation;
                end
                
            else
                % If natural hazard is turned off, the next shock will not
                % occur
                timeOp = inf;
                perfGoalOp = 0;
                operation = Operation( timeOp, Operation.SHOCK, false, perfGoalOp);
            end
        end
        
        
        function applyOperation(self, operation)
        %{
        
            Input
                
            Output
                
        %}
            import dataComponents.Operation
            
            condition = operation.isType(Operation.VOL_MAINT) || operation.isType(Operation.MAND_MAINT) || ...
                operation.isType(Operation.SHOCK);
            
            assert(condition == true, 'Only maintenance (vol or maint) or shock operation can be applied to nature')
            
            if operation.isType(Operation.VOL_MAINT) || operation.isType(Operation.MAND_MAINT)
                self.infrastructure.registerObservation(operation.time, operation.perfGoal);
                
            else % For shock operations, the force value must be translated into perfGoal
                perfBeforeShock = self.solvePerformanceForTime(operation.time);
                forceValue = operation.forceValue;
                perfGoal = self.infrastructure.shockResponseFnc(perfBeforeShock, forceValue);
                
                self.infrastructure.registerObservation(operation.time, perfGoal);
                
            end
            
        end
        
        
        function finalizeHistory(self, time)
        %{
        
            Input
                
            Output
                
        %}
            self.infrastructure.setTime(time);
        end
        
        
        function confirmExecutionSubmittedOperation(self, operation)
        %{
        
            Input
                
            Output
                
        %}
            assert(~isempty(self.submittedOperation), ...
                'The attribute submitted operation should not be empty.')
            
            assert(self.submittedOperation.eq(operation), ...
                'The operation executed does not coincide with the operation submitted.')
            
            self.clearSubmittedOperation();
            
        end
        
        
        function setSubmittedOperation(self, operation)
        %{
        
            Input
                
            Output
                
        %}
            self.submittedOperation = operation;
        end
        
        
        function clearSubmittedOperation(self)
        %{
        
            Input
                
            Output
                
        %}
            self.submittedOperation = [];
        end
       
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function performance = solvePerformanceForTime(self,time)
        %{
        
            Input
                
            Output
                
        %}
            performance = self.infrastructure.solvePerformanceForTime(time);
        end
        
        
    end
end