classdef DecisionRule < matlab.mixin.Copyable
    
    properties (Constant, Hidden = true)
        % Types of rules: Regarding sensitivity to model state
        SENSITIVE            = 'SENSITIVE'
        INSENSITIVE        = 'INSENSITIVE'
        
        % Types of rules: Regarding determinacy
        DETERMINISTIC       = 'DETERMINISTIC'
        STOCHASTIC          = 'STOCHASTIC'
        
        % Types of values specified as output of a decision rule
        ABSOLUTE_VALUE      = 'ABSOLUTE_VALUE'
        DELTA_VALUE         = 'DELTA_VALUE'
    end
    
    properties
        % ----------- %
        % Attributes
        % ----------- %
        
        index                       % [double]
        name = 'NotAssigned'        % [string]
        
        typeRule_Sensitivity        % [string] SENSITIVE or INSENSITIVE
        typeRule_Determinacy        % [string] DETERMINISTIC or STOCHASTIC
        typeRule_Output             % [array of string] Row cell of strings. Each cell describes the character (DELTA_VALUE or ABSOLUTE_VALUE) of one output component
        
        parametrized = false;       % [boolean] Determines if the decision 
                                    % rule receives parameters
        
        
        decisionVars_Number         % [double] Scalar integer
        decisionVars_TypeInfo       % [array of string] Type of information.
                                    %  See Information class (Constants). Row cell of strings
        
        params_Number = 0           % [double] Scalar integer
        params_Name                 % [array of string] Row cell of strings
        params_NumberSet            % [array of string] See InputData class (constants). Row cell of strings.
        params_LowerBounds          % [array of double] 
        params_UpperBounds          % [array of double] 
        params_Value                % [array of double] Row vector with specific parameters values
        params_DefaultValue         % [array of double] Row vector with specific default parameters values
        
        

                                    
        lastOutput                  % [array of double] 
        
        % True if the decision rule has been completely specified: 
        % All parameters properties have been set and all parameters values
        % have been specified
        determinedRule
        
        % ----------- %
        % Objects
        % ----------- %
        
		auxRuleArray                % [array of DecisionRule] Array of Decision Rule objects 
    end
    
    methods (Static)
        
        function answer = isValid_Sensitivity(str)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.DecisionRule
            
            validTypes = {  DecisionRule.SENSITIVE, ...
                            DecisionRule.INSENSITIVE};
            
            answer = any(strcmp(validTypes,str));
        end
        
        
        function answer = isValid_Determinacy(str)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.DecisionRule
            
            validTypes = {  DecisionRule.DETERMINISTIC, ...
                            DecisionRule.STOCHASTIC};
                        
            answer = any(strcmp(validTypes,str));
        end
        
        
        function answer = isValid_TypeOutput(str)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.DecisionRule
            
            validTypes = {  DecisionRule.ABSOLUTE_VALUE, ...
                            DecisionRule.DELTA_VALUE};
                        
            answer = any(strcmp(validTypes,str));
        end
        
        
    end
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
        %{
        * 
            Input
                
            Output
                
        %}
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            if ~isempty(obj.auxRuleArray)
                n = length(obj.auxRuleArray);
                for i=1:n
                    cpObj.auxRuleArray{i} = copy(obj.auxRuleArray{i});
                end
            end
        end
        
        
    end
    
    methods
        
        %% ::::::::::::::::::::    Getter methods    ::::::::::::::::::::::
        % *****************************************************************
        
        function answer = get.determinedRule(self)
        %{
        * 
            Input
                
            Output
                
        %}
            if isempty(self.determinedRule)
                answer = self.isDeterminedRule();
            else
                answer = self.determinedRule;
            end
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function setIndex(self, index)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check that index is integer
            assert(rem(index,1) == 0, ...
                'Index must be integer')
            self.index = index;
        end
        
        
        function setName(self, nameStr)
        %{
        * 
            Input
                
            Output
                
        %}
            self.name = nameStr;
        end
        
        
        function setTypeRule_Sensitivity(self, typeRule)
        %{
        * 
            Input
                
            Output
                
        %}
            assert(self.isValid_Sensitivity(typeRule),...
                'The type entered as argument is not valid');
            self.typeRule_Sensitivity = typeRule;
        end
        
        
        function setTypeRule_Determinacy(self, typeRule)
        %{
        * 
            Input
                
            Output
                
        %}
            assert(self.isValid_Determinacy(typeRule),...
                'The type entered as argument is not valid');
            self.typeRule_Determinacy = typeRule;
        end
        
        
        function setTypeRule_Output(self, cell)
        %{
        * 
            Input
                
            Output
                
        %}
            assert(~isempty(self.decisionVars_Number) == true, ...
                'The number of decision variables has not been set in this rule')
            
            n = length(cell);
            
            assert(n == self.decisionVars_Number, ...
                'The number of elements in the attribute typeRule_Output must be equal to the value of the attribute decisionVars_Number')
            
            for i=1:n
                currentType = cell{i};
                assert(self.isValid_TypeOutput(currentType), ...
                    'One type entered as argument is not valid');
            end
            
            self.typeRule_Output = cell;
        end
        
        
        function setDecisionVars_Number(self, number)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check that index is integer
            assert(rem(number,1) == 0, ...
                'Number of variables must be represented with an integer value.')
            self.decisionVars_Number = number;
        end
        
        
        function addDecisionVar_TypeInfo(self, type)
        %{
        
            Input
                
            Output
                
        %}
            % Make sure the type added is not repeated
            %TODO
        end
        
        
        function setDecisionVars_TypeInfo(self, cell)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.Information
            
            % Check that the attribute decisionVars_Number is non-empty
            assert(~isempty(self.decisionVars_Number) == true, ...
                'The number of decision variables has not been set in this rule')
            
            n = length(cell);
            
            % Check that the length of cell coincides with the number of
            % decision variables of self
            assert(n == self.decisionVars_Number, ...
                'The number of elements in the attribute decisionVars_TypeInfo must be equal to the value of the attribute decisionVars_Number')
            
            for i=1:n
                currentType = cell{i};
                % Check that currentType is a valid Information type
                assert(Information.isValid_TypeInfo(currentType), ...
                    'One type entered as argument is not valid type of information. See Information class.')
            end
            
            self.decisionVars_TypeInfo = cell;
        end
        
        
        function setAsParametrized(self)
        %{
        * 
            Input
                
            Output
                
        %}
            self.parametrized = true;
        end
        
        
        function setParams_Number(self, numberOfParameters)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check that the rule is parametrized
            assert(self.parametrized == true, ...
                'This rule has not been set as parametrized')
            
            % Check that number of parameters is integer
            assert(rem(numberOfParameters,1) == 0, ...
                'Number of parameters must be integer')
            
            self.params_Number = numberOfParameters;
        end
        
        
        function setParams_Name(self, cell)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check that the rule is parametrized
            assert(self.parametrized == true, ...
                'This rule has not been set as parametrized')
            
            % Check that there is a specified number of parameters
            assert( self.params_Number > 0 , ...
                'The number of parameters specified in params_Number must be greater than zero.')
            
            n = length(cell);
            
            % Check that the length of cell coincides with the number of
            % parameters of self
            assert(n == self.params_Number, ...
                'Length of cell does not coincide with number of parameters')
            self.params_Name = cell;
        end
        
        
        function setParams_NumberSet(self, cell)
        %{
        * 
            Input
                
            Output
                
        %}
             % Check that the rule is parametrized
            assert(self.parametrized == true, ...
                'This rule has not been set as parametrized')
            
            n = length(cell);
            
            % Check that the length of cell coincides with the number of
            % parameters of self
            assert(n == self.params_Number, ...
                'Length of cell does not coincide with number of parameters')
            
            self.params_NumberSet = cell;
        end
        
        
        function setParams_LowerBounds(self, rowVector)
        %{
        * 
            Input
                
            Output
                
        %}
             % Check that the rule is parametrized
            assert(self.parametrized == true, ...
                'This rule has not been set as parametrized')
            
            n = length(rowVector);
            
            % Check that the length of rowVector coincides with the number of
            % parameters of self
            assert(n == self.params_Number, ...
                'Length of rowVector does not coincide with number of parameters')
            
            self.params_LowerBounds = rowVector;
        end
        
        
        function setParams_UpperBounds(self, rowVector)
        %{
        * 
            Input
                
            Output
                
        %}
             % Check that the rule is parametrized
            assert(self.parametrized == true, ...
                'This rule has not been set as parametrized')
            
            n = length(rowVector);
            
            % Check that the length of rowVector coincides with the number of
            % parameters of self
            assert(n == self.params_Number, ...
                'Length of rowVector does not coincide with number of parameters')
            
            self.params_UpperBounds = rowVector;
        end
        
        
        % --- The following methods are responsible for defining ------
        %     the specific behavior of the decision rule by:
        %       - Fixing the value of all parameters
        %       - Calling the rule to decide its output
        
        
        function setParams_Value(self, rowVector)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check that all parameters properties have been set
            assert(self.areAllParamsPropertiesSet() == true, ...
                'Not all parameters properties have been set')
            
            n = length(rowVector);
            
            % Check that the length of rowVector coincides with the number of
            % parameters of self
            assert(n == self.params_Number, ...
                'Length of rowVector does not coincide with number of parameters')
            
            if isempty(self.params_Value) || any(self.params_Value ~= rowVector)
            
                % Check compliance for lower bounds
                comp = self.params_LowerBounds <= ...
                    rowVector;
                lowerBoundsCompliance = all(comp);
                assert(lowerBoundsCompliance, ...
                    'Parameters passed as arguments violate lower bounds')

                % Check compliance for upper bounds
                comp = self.params_UpperBounds >= ...
                    rowVector;
                upperBoundsCompliance = all(comp);
                assert(upperBoundsCompliance, ...
                    'Parameters passed as arguments violate upper bounds')
                
                % TODO Should it check compliance for number set?
                % Should it be a responsability of the optimization
                % routine?
                
                
                % Resets the lastOutput attribute because the value of the
                % parameters have been changed, therefore the lastOutput will
                % not be the same and it is no longer needed
                self.lastOutput = [];
                
                % Updates value of parameters
                if isempty(self.params_DefaultValue)
                    self.params_DefaultValue = rowVector;
                end
                self.params_Value = rowVector;
            end
        end
        
        
        function setParamsValue_UserInput(self)
        %{
        * 
            Input
                
            Output
                
        %}
            home
            disp('Seleccion of parameters: ---------------------')
            disp(' ')
            
            disp(['Class name:      ',class(self)])
            disp(' ')
            
            disp('Name of parameters:')
            disp(self.params_Name)
            
            disp('Number set:')
            disp(self.params_NumberSet)
            
            disp('Bounds (Upper and Lower):')
            disp([self.params_LowerBounds ; self.params_UpperBounds])
            
            val = input('Input parameters as a row vector and hit enter:\n');
            
            self.setParams_Value(val);
            
            disp(' ')
        end
        
        
        function setParamsValue_Random(self)
        %{
        * 
            Input
                
            Output
                
        %}
            if self.parametrized == true
                
                numParams = self.params_Number;
                rowVector = zeros(1,numParams);
                
                for i=1:numParams
                    lower = self.params_LowerBounds(i);
                    upper = self.params_UpperBounds(i);
                    numberSet = self.params_NumberSet(i);
                    
                    if strcmp(numberSet, managers.InputData.BOOLEAN)
                        value = round(rand);
                    else
                        %{
                        lambda = 0.3;   % Lambda of convex linear combination
                        probDist = makedist('Triangular', ...
                            'a',lower,...
                            'b',lower*(1-lambda) + upper*lambda,...
                            'c',upper);
                        value = random(probDist);
                        %}
                        
                        
                        lambda = 0.3;   % Lambda of convex linear combination
                        a = lower;
                        b = upper;
                        c = lower*(1-lambda) + upper*lambda;
                        uni = rand;
                        if uni < (c-a)/(b-a)
                            value = a + sqrt(uni*(b-a)*(c-a));
                        else
                            value = b - sqrt((1-uni)*(b-a)*(b-c));
                        end
                        
                        
                        
                        if strcmp(numberSet, managers.InputData.INTEGER)
                            value = round(value);
                        end
                    end
                    
                    rowVector(i) = value;
                end
                
                self.setParams_Value(rowVector);
                
            end
        end
        
        
        function decide(self, theMsg)
        %{
        * 
            Input
                
            Output
                
        %}
            
            assert(self.determinedRule == true, ...
                'The rule must be determined before it can be executed')
            
            self.mainAlgorithm(theMsg);
        end
        
        
        function validateRule(self)
        %{
        * 
            Input
                
            Output
                
        %}
            % The rule must be determined to be valid
            if ~isempty(self.determinedRule)
                isDet = self.determinedRule;
            else
                isDet = self.isDeterminedRule();
            end
            assert(isDet == true, ...
                'The rule must be determined to be valid');
            self.determinedRule = isDet;
            
            
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function v = getCoverage(self, requiredDecVars)
        %{
        * 
            Input
                
            Output
                
        %}
            ownDecVars = self.decisionVars_TypeInfo;
            
            numRequiredDecVars = length(requiredDecVars);
            numOwnDecVars = length(ownDecVars);
            
            v = false(numRequiredDecVars, 1);
            
            for i=1:numOwnDecVars
                answer = strcmp(requiredDecVars, ownDecVars{i});
                v = or(answer, v);
            end
        end
        
        
        function answer = isSensitive(self)
        %{
        * 
            Input
                
            Output
                
        %}
            if strcmp(self.typeRule_Sensitivity, self.SENSITIVE)
                answer = true;
            else
                answer = false;
            end
        end
        
        
        function answer = isStochastic(self)
        %{
        * 
            Input
                
            Output
                
        %}
            if strcmp(self.typeRule_Determinacy, managers.DecisionRule.STOCHASTIC)
                answer = true;
            else
                answer = false;
            end
        end
        
        
        function answer = areAllParamsPropertiesSet(self)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check the state of parameter's properties
            param = self.parametrized;
            number = self.params_Number > 0;
            paramName = ~isempty(self.params_Name);
            numberSet = ~isempty(self.params_NumberSet);
            lowerBounds = ~isempty(self.params_LowerBounds);
            upperBounds = ~isempty(self.params_UpperBounds);

            answer = ...
                param && ...
                number && ...
                paramName && ...
                numberSet && ...
                lowerBounds && ...
                upperBounds ;
        end
        
        
        function answer = isDeterminedRule(self)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check if rule is parametrized
            if self.parametrized == true
                
                % Check that:
                %   * all params properties are set
                %   * the default values of parameters values are non-empty
                if self.areAllParamsPropertiesSet() == true && ...
                    ~isempty(self.params_Value)
                    
                    answer = true;
                else
                    answer = false;
                end
            else
                % If not parametrized, it is always determined by default
                answer = true;
            end
        end
        
        
    end
end