classdef Operation < managers.TypedClass
    % 
    properties (Constant, Hidden = true)
        % Types of operations
        INSPECTION  = 'INSPECTION'
        VOL_MAINT   = 'VOL_MAINT'
        MAND_MAINT  = 'MAND_MAINT'
        SHOCK       = 'SHOCK'
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        time
        type
        pendingExecution = false
        perfGoal
        forceValue
        sensitive
        
        % ----------- %
        % Objects
        % ----------- %
        
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Operation(time, type, sens, param)
        %{
        * 
        
            Input
            
            Output
                
        %}
            import dataComponents.Operation
            
            listTypes = {  Operation.VOL_MAINT, ...
                Operation.MAND_MAINT, ...
                Operation.SHOCK, ...
                Operation.INSPECTION };
            
            self@managers.TypedClass(listTypes);
            
            % Validation of Input Data
            assert(time >= 0 , ...
                'Time argument must be greater or equal than zero')
            assert(self.isValidType(type) == true, ...
                'The type parameter is not valid')
            assert(islogical(sens), ...
                'Adaptiveness parameter must be boolean');
            
            isMaintenance = strcmp(type, Operation.VOL_MAINT) || strcmp(type, Operation.MAND_MAINT);
            
            %{
            % TODO How to acces the maxPerf and nullPerf information?
            if isMaintenance == true
                assert(param <= Infrastructure.MAXPERF && param >= 0, ...
                'The performance goal must be within the interval [0, Infrastructure.MAXPERF]')                
            end
            %}
            
            % Object construction
            self.time = time;
            self.setType(type);
            self.sensitive = sens;
            
            if isMaintenance == true
                self.perfGoal = param;
            end
            
            if strcmp(type, Operation.SHOCK)
                self.forceValue = param;
            end
            
            % Validation of constructed object
            if self.isType(Operation.INSPECTION)
                assert(isempty(self.perfGoal) && isempty(self.forceValue), ...
                    'An inspection operation must have an empty perfGoal and forceValue attributes')
            end
            
            if self.isDeltaOperation()
                assert(~isempty(self.perfGoal) || ~isempty(self.forceValue), ...
                    'A  delta operation (maintenances or shock) operation  must have a non-empty either perfGoal or forceValue attribute')
            end
            
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function setType(self, type)
        %{
        * Sets the type attribute of self if type argument is valid
        
            Input
                type: [class String] 
            Output
                answer: [class Boolean]
        %}
            if self.isValidType(type)
                self.type = type;
            else
                error('The type entered as argument is not valid')
            end
        end
        
        
        function setAsPending(self)
        %{
        * 
            Input
                
            Output
                
        %}
            self.pendingExecution = true;
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function answer = isDeltaOperation(self)
        %{
        * 
            Input
                
            Output
                
        %}
            import dataComponents.Operation
            
            answer = self.isType(Operation.VOL_MAINT) || ...
                self.isType(Operation.MAND_MAINT) || ...
                self.isType(Operation.SHOCK) ;
        end
        
        
        function answer = isType(self, type)
        %{
        * 
            Input
                
            Output
                
        %}
            assert(self.isValidType(type), 'The type entered as argument is not valid')
            
            if strcmp(self.type, type)
                answer = true;
            else
                answer = false;
            end
        end
        
        
    end
end