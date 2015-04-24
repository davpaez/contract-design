classdef Operation < managers.TypedClass
    
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
        %% Constructor
        
        function thisOp = Operation(time, type, sens, param)
            import dataComponents.Operation
            
            listTypes = {  Operation.VOL_MAINT, ...
                Operation.MAND_MAINT, ...
                Operation.SHOCK, ...
                Operation.INSPECTION };
            
            thisOp@managers.TypedClass(listTypes);
            
            % Validation of Input Data
            assert(time >= 0 , ...
                'Time argument must be greater or equal than zero')
            assert(thisOp.isValidType(type) == true, ...
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
            thisOp.time = time;
            thisOp.setType(type);
            thisOp.sensitive = sens;
            
            if isMaintenance == true
                thisOp.perfGoal = param;
            end
            
            if strcmp(type, Operation.SHOCK)
                thisOp.forceValue = param;
            end
            
            % Validation of constructed object
            if thisOp.isType(Operation.INSPECTION)
                assert(isempty(thisOp.perfGoal) && isempty(thisOp.forceValue), ...
                    'An inspection operation must have an empty perfGoal and forceValue attributes')
            end
            
            if thisOp.isDeltaOperation()
                assert(~isempty(thisOp.perfGoal) || ~isempty(thisOp.forceValue), ...
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
        function setType(thisOp, type)
            if thisOp.isValidType(type)
                thisOp.type = type;
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
        function answer = isType(thisOp, type)
            
            assert(thisOp.isValidType(type), 'The type entered as argument is not valid')
            
            if strcmp(thisOp.type, type)
                answer = true;
            else
                answer = false;
            end
        end

        
        
    end
    
end