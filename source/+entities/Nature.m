classdef Nature < handle
    % This class represents the natural environment
    
    properties
        % ----------- %
        % Attributes
        % ----------- %
        time = 0
        hazard          % [Boolean] Turns on and off the natural hazards
        
        contEnvForceFnc    % Function handle
        
        % ----------- %
        % Objects
        % ----------- %
        shockStrategy
        submittedOperation
        problem
        
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Nature(progSet, prob)
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
            
            % Continuous environmental force
            item = progSet.returnItemSetting(ItemSetting.CONT_ENV_FORCE);
            self.contEnvForceFnc = item.equation;
            
            % Problem object
            self.problem = prob;
        end
        
        
        %% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
        


        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function setTime(self,time)
        %{
        
            Input
                
            Output
                
        %}
            if time > self.time
                self.time = time;
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
            import managers.Faculty
            
            if self.hazard == true
                if isempty(self.submittedOperation)
                    
                    msg = Faculty.createEmptyMessage(self, Faculty.SHOCK);
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
        
        
        function applyOperation(self, operation, infrastructure)
        %{
        
            Input
                
            Output
                
        %}
            import dataComponents.Operation
            
            condition = operation.isType(Operation.VOL_MAINT) || operation.isType(Operation.MAND_MAINT) || ...
                operation.isType(Operation.SHOCK);
            
            assert(condition == true, 'Only maintenance (vol or maint) or shock operation can be applied to nature')
            
            if operation.isType(Operation.VOL_MAINT) || operation.isType(Operation.MAND_MAINT)
                infrastructure.registerObservation(operation.time, operation.perfGoal);
                
            else % For shock operations, the force value must be translated into perfGoal
                perfBeforeShock = infrastructure.getPerformance();
                forceValue = operation.forceValue;
                perfGoal = infrastructure.shockResponseFnc(perfBeforeShock, forceValue);
                
                infrastructure.registerObservation(operation.time, perfGoal);
                
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