classdef Operation < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
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
    
    methods (Static)
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function answer = isValidType(type)
            import dataComponents.Operation
            
            answer = false;
            validTypes = {  Operation.VOL_MAINT, ...
                            Operation.MAND_MAINT, ...
                            Operation.SHOCK, ...
                            Operation.INSPECTION };
            nTypes = length(validTypes);
            
            for i=1:nTypes
                currentType = validTypes{i};
                
                if strcmp(currentType, type);
                    answer = true;
                    break
                end
            end
        end
        
    end
    
    
    methods
        %% Constructor
        
        function thisOperation = Operation(time, type, sens, param)
            import dataComponents.Operation
            
            % Validation of Input Data
            assert(time >= 0 , ...
                'Time argument must be greater or equal than zero')
            assert(Operation.isValidType(type) == true, ...
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
            thisOperation.time = time;
            thisOperation.setType(type);
            thisOperation.sensitive = sens;
            
            if isMaintenance == true
                thisOperation.perfGoal = param;
            end
            
            if strcmp(type, Operation.SHOCK)
                thisOperation.forceValue = param;
            end
            
            % Validation of constructed object
            if thisOperation.isType(Operation.INSPECTION)
                assert(isempty(thisOperation.perfGoal) && isempty(thisOperation.forceValue), ...
                    'An inspection operation must have an empty perfGoal and forceValue attributes')
            end
            
            if thisOperation.isDeltaOperation()
                assert(~isempty(thisOperation.perfGoal) || ~isempty(thisOperation.forceValue), ...
                    'A  delta operation (maintenances or shock) operation  must have a non-empty either perfGoal or forceValue attribute')
            end
            
        end
        
        %% Getter functions
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        %{
        * Sets the type attribute of thisOperation if type argument is valid
        
            Input
                type: [class String] 
            Output
                answer: [class Boolean]
        %}
        function setType(thisOperation, type)
            if dataComponents.Operation.isValidType(type)
                thisOperation.type = type;
            else
                error('The type entered as argument is not valid')
            end
        end
        
        %{
        
            Input
                
            Output
                
        %}
        
        function setAsPending(thisOperation)
            thisOperation.pendingExecution = true;
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        %{
        
            Input
                
            Output
                
        %}
        
        function answer = isDeltaOperation(thisOperation)
            import dataComponents.Operation
            
            answer = thisOperation.isType(Operation.VOL_MAINT) || ...
                thisOperation.isType(Operation.MAND_MAINT) || ...
                thisOperation.isType(Operation.SHOCK) ;
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function answer = isType(thisOperation, type)
            
            assert(dataComponents.Operation.isValidType(type), 'The type entered as argument is not valid')
            
            if strcmp(thisOperation.type, type)
                answer = true;
            else
                answer = false;
            end
        end

        
        
    end
    
end