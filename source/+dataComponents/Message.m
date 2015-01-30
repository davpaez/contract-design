classdef Message < handle
    %MESSAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Hidden = true)
        MAX_PERF            = 'MAX_PERF'
        
        TIME_DETECTION      = 'TIME_DETECTION'
        PERF_DETECTION      = 'PERF_DETECTION'
    end
    
    properties
        
        % ----------- %
        % Attributes
        % ----------- %
        
        typeRequestedInfo           % Cell with types from Information class
        typeExtraInfo               % Cell with constants of this class
        extraInfo = cell(0)
        valuesResponse = cell(0)
        validated = false
        
        % ----------- %
        % Objects
        % ----------- %
        
        executor
        
    end
    
    methods(Static)
        
        function answer = isValid_TypeExtraInput(str)
        %{
        
            Input
                
            Output
                
        %}
            import dataComponents.Message
            
            validTypes = {  Message.MAX_PERF, ...
                            Message.TIME_DETECTION, ...
                            Message.PERF_DETECTION};
             
             answer = any(strcmp(validTypes, str));
        end
        
    end
    
    methods
        %% Constructor
        
        function thisMsg = Message(theExecutor)
        %{
        
            Input
                
            Output
                
        %}
            % Check that theExecutor is of class Player
            isPrincipal = isa(theExecutor,'entities.Principal');
            isAgent = isa(theExecutor,'entities.Agent');
            isNature = isa(theExecutor,'entities.Nature');
            
            isPlayer = any([isPrincipal, isAgent, isNature]);
            
            assert(isPlayer, ...
                'The parameter passed must be an object of either Principal, Agent or Nature class')
            
            thisMsg.executor = theExecutor;
            
        end
        
        
        %% Getter functions
        
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        function ex = getExecutor(thisMsg)
        %{
        
            Input
                
            Output
                
        %}
            ex = thisMsg.executor;
        end
        
        
        function value = getOutput(thisMsg, typeOutput)
        %{
        
            Input
                
            Output
                
        %}
            import managers.Information
            
            thisMsg.validate()
            
            assert(Information.isValid_TypeInfo(typeOutput), ...
                    'The type of output response specified is not valid.')
            
            idx = strcmp(thisMsg.typeRequestedInfo, typeOutput);
            value = thisMsg.valuesResponse{idx};
        end
        
        
        function value = getExtraInfo(thisMsg, varargin)
        %{
        
            Input
                
            Output
                
        %}
            typeExtra = varargin;
            
            assert(thisMsg.isValid_TypeExtraInput(typeExtra), ...
                    'The type extra info specified is not valid.')
            
            idx = strcmp(thisMsg.typeExtraInfo, typeExtra);
            value = thisMsg.extraInfo{idx};
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------
        % ----------------------------------------------------------------
        
        
        function setTypeRequestedInfo(thisMsg, varargin)
        %{
        
            Input
                
            Output
                
        %}
            import managers.Information
            
            cellIdentifiers = varargin;
            % Check valitidy of types of outputs
            n = length(cellIdentifiers);
            for i=1:n
                assert(Information.isValid_TypeInfo(cellIdentifiers{i}), ...
                    'The type of output response specified is not valid.')
            end
            
            assert(length(cellIdentifiers) == length(unique(cellIdentifiers)), ...
                'The types entered must be unique')
            
            thisMsg.typeRequestedInfo = cellIdentifiers;
            
        end
        
        
        function setExtraInfo(thisMsg, varargin)
        %{
        
            Input
                
            Output
                
        %}
            import managers.Information
            
            cellIdentifiers = varargin(1:2:length(varargin));
            values = varargin(2:2:length(varargin));
            
            % Check valitidy of types of outputs
            n = length(cellIdentifiers);
            for i=1:n
                assert(thisMsg.isValid_TypeExtraInput(cellIdentifiers{i}), ...
                    'The type extra info specified is not valid.')
            end
            
            thisMsg.typeExtraInfo = cellIdentifiers;
            thisMsg.extraInfo = values;
            
        end
        
        
        function submitResponse(thisMsg, varargin)
        %{
        
            Input
                
            Output
                
        %}
            cellIdentifiers = varargin(1:2:length(varargin));
            values = varargin(2:2:length(varargin));
            
            n = length(cellIdentifiers);
            for i=1:n
                varName = cellIdentifiers{i};
                idx = find(strcmp(thisMsg.typeRequestedInfo, varName));
                assert(~isempty(idx), ...
                    'The submitted response type must coincide with the types of the requested info')
                
                % Assign value
                thisMsg.valuesResponse{idx} = values{i};
            end
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
        function validate(thisMsg)
        %{
        
            Input
                
            Output
                
        %}
            if thisMsg.validated == false
                % The RequestedInfo array must be non-empty
                assert(~isempty(thisMsg.typeRequestedInfo), ...
                    'The types of requested info must be non-empty')

                % Check the length of the value response array
                assert(length(thisMsg.valuesResponse) == length(thisMsg.typeRequestedInfo), ...
                    'The length of the value responses array is not valid')

                % No reponse value cell should be empty
                assert(any(cellfun(@isempty, thisMsg.valuesResponse)) == false, ...
                    'All response values must have been submitted')
                
                % Mark as validated
                thisMsg.validated = true;
            end
        end 
        
        
    end
    
end

