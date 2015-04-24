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
    
    properties (Dependent)
        
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
        %% Constructor
        
        %% Getter functions
        
        function answer = get.determinedRule(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            if isempty(thisRule.determinedRule)
                answer = thisRule.isDeterminedRule();
            else
                answer = thisRule.determinedRule;
            end
        end
        
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        
        function setIndex(thisRule, index)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check that index is integer
            assert(rem(index,1) == 0, ...
                'Index must be integer')
            thisRule.index = index;
        end
        
        
        function setName(thisRule, nameStr)
        %{
        * 
            Input
                
            Output
                
        %}
            thisRule.name = nameStr;
        end
        
        
        function setTypeRule_Sensitivity(thisRule, typeRule)
        %{
        * 
            Input
                
            Output
                
        %}
            assert(thisRule.isValid_Sensitivity(typeRule),...
                'The type entered as argument is not valid');
            thisRule.typeRule_Sensitivity = typeRule;
        end
        
        
        function setTypeRule_Determinacy(thisRule, typeRule)
        %{
        * 
            Input
                
            Output
                
        %}
            assert(thisRule.isValid_Determinacy(typeRule),...
                'The type entered as argument is not valid');
            thisRule.typeRule_Determinacy = typeRule;
        end
        
        
        function setTypeRule_Output(thisRule, cell)
        %{
        * 
            Input
                
            Output
                
        %}
            assert(~isempty(thisRule.decisionVars_Number) == true, ...
                'The number of decision variables has not been set in this rule')
            
            n = length(cell);
            
            assert(n == thisRule.decisionVars_Number, ...
                'The number of elements in the attribute typeRule_Output must be equal to the value of the attribute decisionVars_Number')
            
            for i=1:n
                currentType = cell{i};
                assert(thisRule.isValid_TypeOutput(currentType), ...
                    'One type entered as argument is not valid');
            end
            
            thisRule.typeRule_Output = cell;
        end
        
        
        function setDecisionVars_Number(thisRule, number)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check that index is integer
            assert(rem(number,1) == 0, ...
                'Number of variables must be represented with an integer value.')
            thisRule.decisionVars_Number = number;
        end
        
        
        function setDecisionVars_TypeInfo(thisRule, cell)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.Information
            
            % Check that the attribute decisionVars_Number is non-empty
            assert(~isempty(thisRule.decisionVars_Number) == true, ...
                'The number of decision variables has not been set in this rule')
            
            n = length(cell);
            
            % Check that the length of cell coincides with the number of
            % decision variables of thisRule
            assert(n == thisRule.decisionVars_Number, ...
                'The number of elements in the attribute decisionVars_TypeInfo must be equal to the value of the attribute decisionVars_Number')
            
            for i=1:n
                currentType = cell{i};
                % Check that currentType is a valid Information type
                assert(Information.isValid_TypeInfo(currentType), ...
                    'One type entered as argument is not valid type of information. See Information class.')
            end
            
            thisRule.decisionVars_TypeInfo = cell;
        end
        
        
        function setAsParametrized(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            thisRule.parametrized = true;
        end
        
        
        function setParams_Number(thisRule, numberOfParameters)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check that the rule is parametrized
            assert(thisRule.parametrized == true, ...
                'This rule has not been set as parametrized')
            
            % Check that number of parameters is integer
            assert(rem(numberOfParameters,1) == 0, ...
                'Number of parameters must be integer')
            
            thisRule.params_Number = numberOfParameters;
        end
        
        
        function setParams_Name(thisRule, cell)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check that the rule is parametrized
            assert(thisRule.parametrized == true, ...
                'This rule has not been set as parametrized')
            
            % Check that there is a specified number of parameters
            assert( thisRule.params_Number > 0 , ...
                'The number of parameters specified in params_Number must be greater than zero.')
            
            n = length(cell);
            
            % Check that the length of cell coincides with the number of
            % parameters of thisRule
            assert(n == thisRule.params_Number, ...
                'Length of cell does not coincide with number of parameters')
            thisRule.params_Name = cell;
        end
        
        
        function setParams_NumberSet(thisRule, cell)
        %{
        * 
            Input
                
            Output
                
        %}
             % Check that the rule is parametrized
            assert(thisRule.parametrized == true, ...
                'This rule has not been set as parametrized')
            
            n = length(cell);
            
            % Check that the length of cell coincides with the number of
            % parameters of thisRule
            assert(n == thisRule.params_Number, ...
                'Length of cell does not coincide with number of parameters')
            
            thisRule.params_NumberSet = cell;
        end
        
        
        function setParams_LowerBounds(thisRule, rowVector)
        %{
        * 
            Input
                
            Output
                
        %}
             % Check that the rule is parametrized
            assert(thisRule.parametrized == true, ...
                'This rule has not been set as parametrized')
            
            n = length(rowVector);
            
            % Check that the length of rowVector coincides with the number of
            % parameters of thisRule
            assert(n == thisRule.params_Number, ...
                'Length of rowVector does not coincide with number of parameters')
            
            thisRule.params_LowerBounds = rowVector;
        end
        
        
        function setParams_UpperBounds(thisRule, rowVector)
        %{
        * 
            Input
                
            Output
                
        %}
             % Check that the rule is parametrized
            assert(thisRule.parametrized == true, ...
                'This rule has not been set as parametrized')
            
            n = length(rowVector);
            
            % Check that the length of rowVector coincides with the number of
            % parameters of thisRule
            assert(n == thisRule.params_Number, ...
                'Length of rowVector does not coincide with number of parameters')
            
            thisRule.params_UpperBounds = rowVector;
        end
        
        
        % --- The following methods are responsible for defining ------
        %     the specific behavior of the decision rule by:
        %       - Fixing the value of all parameters
        %       - Calling the rule to decide its output
        
        
        function setParams_Value(thisRule, rowVector)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check that all parameters properties have been set
            assert(thisRule.areAllParamsPropertiesSet() == true, ...
                'Not all parameters properties have been set')
            
            n = length(rowVector);
            
            % Check that the length of rowVector coincides with the number of
            % parameters of thisRule
            assert(n == thisRule.params_Number, ...
                'Length of rowVector does not coincide with number of parameters')
            
            if isempty(thisRule.params_Value) || any(thisRule.params_Value ~= rowVector)
            
                % Check compliance for lower bounds
                comp = thisRule.params_LowerBounds <= ...
                    rowVector;
                lowerBoundsCompliance = all(comp);
                assert(lowerBoundsCompliance, ...
                    'Parameters passed as arguments violate lower bounds')

                % Check compliance for upper bounds
                comp = thisRule.params_UpperBounds >= ...
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
                thisRule.lastOutput = [];
                
                % Updates value of parameters
                thisRule.params_Value = rowVector;
            end
        end
        
        
        function setParamsValue_UserInput(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            home
            disp('Seleccion of parameters: ---------------------')
            disp(' ')
            
            disp(['Class name:      ',class(thisRule)])
            disp(' ')
            
            disp('Name of parameters:')
            disp(thisRule.params_Name)
            
            disp('Number set:')
            disp(thisRule.params_NumberSet)
            
            disp('Bounds (Upper and Lower):')
            disp([thisRule.params_LowerBounds ; thisRule.params_UpperBounds])
            
            val = input('Input parameters as a row vector and hit enter:\n');
            
            thisRule.setParams_Value(val);
            
            disp(' ')
        end
        
        
        function setParamsValue_Random(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            if thisRule.parametrized == true
                
                numParams = thisRule.params_Number;
                rowVector = zeros(1,numParams);
                
                for i=1:numParams
                    lower = thisRule.params_LowerBounds(i);
                    upper = thisRule.params_UpperBounds(i);
                    numberSet = thisRule.params_NumberSet(i);
                    
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
                
                thisRule.setParams_Value(rowVector);
                
            end
        end
        
        
        function decide(thisRule, theMsg)
        %{
        * 
            Input
                
            Output
                
        %}
            assert(thisRule.determinedRule == true, ...
                'The rule must be determined before it can be executed')
            
            thisRule.mainAlgorithm(theMsg);
        end
        
        
        function validateRule(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            % The rule must be determined to be valid
            if ~isempty(thisRule.determinedRule)
                isDet = thisRule.determinedRule;
            else
                isDet = thisRule.isDeterminedRule();
            end
            assert(isDet == true, ...
                'The rule must be determined to be valid');
            thisRule.determinedRule = isDet;
            
            
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
        function answer = isSensitive(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            if strcmp(thisRule.typeRule_Sensitivity, managers.DecisionRule.SENSITIVE)
                answer = true;
            else
                answer = false;
            end
        end
        
        
        function answer = isStochastic(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            if strcmp(thisRule.typeRule_Determinacy, managers.DecisionRule.STOCHASTIC)
                answer = true;
            else
                answer = false;
            end
        end
        
        %{
        function answer = isDelta(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            if strcmp(thisRule.typeRule_Output, managers.DecisionRule.DELTA_VALUE)
                answer = true;
            else
                answer = false;
            end
        end
        %}
        
        
        function answer = areAllParamsPropertiesSet(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check the state of parameter's properties
            param = thisRule.parametrized;
            number = thisRule.params_Number > 0;
            paramName = ~isempty(thisRule.params_Name);
            numberSet = ~isempty(thisRule.params_NumberSet);
            lowerBounds = ~isempty(thisRule.params_LowerBounds);
            upperBounds = ~isempty(thisRule.params_UpperBounds);

            answer = ...
                param && ...
                number && ...
                paramName && ...
                numberSet && ...
                lowerBounds && ...
                upperBounds ;
        end
        
        
        function answer = isDeterminedRule(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            % Check if rule is parametrized
            if thisRule.parametrized == true
                
                % Check that:
                %   * all params properties are set
                %   * the default values of parameters values are non-empty
                if thisRule.areAllParamsPropertiesSet() == true && ...
                    ~isempty(thisRule.params_Value)
                    
                    answer = true;
                else
                    answer = false;
                end
            else
                % If not parametrized, it is always determined by default
                answer = true;
            end
        end
        
        %{
        function answer = isCurrentlyOutputInvariant(thisRule)
        %{
        * 
            Input
                
            Output
                
        %}
            answer = thisRule.determinedRule && ...
                ~thisRule.isStochastic() && ...
                ~isempty(thisRule.lastOutput) && ...
                ~thisRule.isSensitive();
        end
        %}
        
    end
    
end