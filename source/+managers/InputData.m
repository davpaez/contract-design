classdef InputData < managers.ItemSetting
    
    properties (Constant, Hidden = true)
        % Number set: Associated with any 'value' attribute
        INTEGER         = 'INTEGER'
        REAL            = 'REAL'
        BOOLEAN         = 'BOOLEAN'
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    properties (GetAccess = public, SetAccess = public)
        % ----------- %
        % Attributes
        % ----------- %
        
%         category
%         category_constraints
%         category_elementOf
        
        value
        value_LowerBound
        value_UpperBound
        value_NumberSet         % [string] --> See Number set constants
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    properties (Dependent)
        determined
    end
    
    methods (Static)
        
        function answer = isValidNumberSet(str)
            import managers.InputData
            
            validTypes = {  InputData.INTEGER, ...
                            InputData.REAL, ...
                            InputData.BOOLEAN};
                        
             answer = any(strcmp(validTypes, str));
        end
    end
    
    methods
        %% Constructor
        
        
        
        %% Getter functions
        
        function answer = get.determined(self)
            answer = false;
            
            condition = ~self.isEmptyDataObject() && ...
                ~isempty(self.value);
            
            if condition == true
                answer = true;
            end
        end
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        

        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        %{
        * This dataInput object is not constrained to a specific value or
        range of values. It must however be part of its proper number set
        
            Input
                
            Output
                
        %}
        %TODO Is this useful? The property degreeFreedom should exist?
        function setAsFree(self)
            self.degreeFreedom = InputData.FREE;
        end
        
        
        %{
        * The possible values (apart from being a part of its proper number
        set) are restricted. The possible values are stored as rows in the
        value attribute of the inputData object
        
            Input
                
            Output
                
        %}
        %TODO Is this useful? The property degreeFreedom should exist?
        function setAsLimited(self)
            self.degreeFreedom = InputData.LIMITED;
        end
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        %{
        
            Input
                
            Output
                
        %}
        function answer = isEmptyDataObject(self)
            if isempty(self.identifier)
                answer = true;
            else
                answer = false;
            end
        end
        

        
        %{
        
            Input
                
            Output
                
        %}
        function answer = isInteger(self)
            if strcmp(self.value_NumberSet, InputData.INTEGER)
                answer = true;
            else
                answer = false;
            end
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        %TODO
        function checkValidity(self)
            %
            if isempty(self.value)
                if self.isGiven()
                    error('This inputData is GIVEN, therefore it cannot have an empty value attribute')
                else % If it is not-given, it must have bounds and  numberset and they must be valid
                    assert(~isempty(self.value_LowerBound), ...
                        'The lower bound attribute of this inputData cannot be empty')
                    assert(~isempty(self.value_UpperBound), ...
                        'The upper bound attribute of this inputData cannot be empty')
                    
                    
                    assert(self.value_LowerBound < self.value_UpperBound, ...
                        'The value bounds of this inputData must hold that lowerBound < upperBound')
                    
                    assert(~isempty(self.value_NumberSet), ...
                        'The number set attribute of this inputData cannot be empty')
                end
                
            else
                if self.isGiven() % It if is given, it must have empty bounds and numberset
                    assert(isempty(self.value_LowerBound), ...
                        'The lower bound attribute of this inputData must be empty')
                    assert(isempty(self.value_UpperBound), ...
                        'The upper bound attribute of this inputData must be empty')
                    assert(isempty(self.value_NumberSet), ...
                        'The number set attribute of this inputData must be empty')
                    
                else % If it is not-given, it must have bounds and  numberset and they must be valid
                    assert(~isempty(self.value_LowerBound), ...
                        'The lower bound attribute of this inputData cannot be empty')
                    assert(~isempty(self.value_UpperBound), ...
                        'The upper bound attribute of this inputData cannot be empty')
                    assert(self.value_LowerBound < self.value_UpperBound, ...
                        'The value bounds of this inputData must hold that lowerBound < upperBound')
                    
                    boundsCompliance = self.value >= self.value_LowerBound && ...
                        self.value <= self.value_UpperBound;
                    
                    assert(boundsCompliance == true, ...
                        'The value attribute does not comply with the bounds of this inputData')
                    
                    assert(~isempty(self.value_NumberSet), ...
                        'The number set attribute of this inputData cannot be empty')
                end
            end
        end
            

    end
    
end

%% Auxiliar functions

        %{
        
            Input
                
            Output
                
        %}
    function out1 = auxiliarFunction()

    end

