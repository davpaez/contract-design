classdef Strategy < matlab.mixin.Copyable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Hidden = true)
        % Types of strategies: Regarding sensitivity to model state
        SENSITIVE            = 'SENSITIVE'
        INSENSITIVE        = 'INSENSITIVE'
        
        % Types of strategies: Regarding determinacy
        DETERMINISTIC       = 'DETERMINISTIC'
        STOCHASTIC          = 'STOCHASTIC'
    end
    
    properties
        % ----------- %
        % Attributes
        % ----------- %
        index
        
        %{
        Sensitive or Insensitive
          * It is an sensitive strategy if at least one of its decision
            rules is sensitive. Thus...
          * It is an insensitive strategy if none of its decision rules
            is sensitive.
        %}
        
        typeStrategy_Sensitivity
        typeStrategy_Determinacy
        
        typeAction
        
        rules_Number
        
        decisionVars_Number         % Scalar integer
        decisionVars_TypeInfo       % Type of information. See Information class (Constants)
                                        % Row cell of strings
        
        lastOutput
        
        determinedStrategy
        
        % ----------- %
        % Objects
        % ----------- %
        decisionRuleArray       % Cell array of decision rule objects
        
    end
    
    methods(Static)

    end
    
    methods (Access = protected)
        
        
        function cpObj = copyElement(obj)
        %{
        * 
            Input
                
            Output
                
        %}
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            if ~isempty(obj.decisionRuleArray)
                n = length(obj.decisionRuleArray);
                for i=1:n
                    cpObj.decisionRuleArray{i} = copy(obj.decisionRuleArray{i});
                end
            end
        end
        
        
    end
    
    methods
        %% Constructor
        
        
        %% Getter functions
        
        
        function rules_Number = get.rules_Number(thisStrategy)
        %{
        * 
            Input
                
            Output
                
        %}
            rules_Number = length(thisStrategy.decisionRuleArray);
            thisStrategy.rules_Number = rules_Number;
        end
        
        
        function answer = get.determinedStrategy(thisStrategy)
        %{
        * 
            Input
                
            Output
                
        %}
            n = length(thisStrategy.decisionRuleArray);
            answer = true;
            
            % Check that all decision rules in arra are determined
            for i=1:n
                if thisStrategy.decisionRuleArray{i}.determinedRule == false
                    answer = false;
                    break
                end
            end
        end
        
        
        function type = get.typeStrategy_Sensitivity(thisStrategy)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.Strategy
            
            n = length(thisStrategy.decisionRuleArray);
            type = Strategy.INSENSITIVE;
            
            for i=1:n
                if thisStrategy.decisionRuleArray{i}.isSensitive()
                    type = Strategy.SENSITIVE;
                    break
                end
            end
            
            thisStrategy.typeStrategy_Sensitivity = type;
        end
        
        
        function type = get.typeStrategy_Determinacy(thisStrategy)
        %{
        * 
            Input
                
            Output
                
        %}
            import managers.Strategy
            
            n = length(thisStrategy.decisionRuleArray);
            type = Strategy.DETERMINISTIC;
            
            for i=1:n
                if thisStrategy.decisionRuleArray{i}.isStochastic
                    type = Strategy.STOCHASTIC;
                    break
                end
            end
            
            thisStrategy.typeStrategy_Determinacy = type;
        end
        
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
		function type = getTypeAction(thisStrategy)
        %{
        * 
            Input
                
            Output
                
        %}
			type = thisStrategy.typeAction;
		end
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        
        function setIndex(thisStrategy, index)
        %{
        * 
            Input
                
            Output
                
        %}
            thisStrategy.index = index;
        end
        
        
        function setDecisionVars_Number(thisStrategy, number)
        %{
        * 
            Input
                
            Output
                
        %}
            thisStrategy.decisionVars_Number = number;
        end
        
        
        function setDecisionVars_TypeInfo(thisStrategy, cell)
        %{
        * 
            Input
                
            Output
                
        %}
            thisStrategy.decisionVars_TypeInfo = cell;
        end
        
        
        function populateParametersProperties(thisStrategy)
        %{
        * 
            Input
                
            Output
                
        %}
        %TODO Necessary for the optimization process !!!!
        % But not for the realization of a determined game
        
            n = thisStrategy.rules_Number;
            
            % Initialize parameters properties
            thisStrategy.params_Number          = cell(n,1);
            thisStrategy.params_Name            = cell(n,1);
            thisStrategy.params_NumberSet       = cell(n,1);
            thisStrategy.params_LowerBounds     = cell(n,1);
            thisStrategy.params_UpperBounds     = cell(n,1);
            thisStrategy.params_Value           = cell(n,1);
            
            % Loops through all decision rules implemented in the strategy
            for i=1:n
                nParams = thisStrategy.decisionRuleArray{i}.params_Number;
                thisStrategy.params_Number{i} = nParams;
                
                thisStrategy.params_Name{i} = ...
                    thisStrategy.decisionRuleArray{i}.params_Name;
                thisStrategy.params_NumberSet{i} = ...
                    thisStrategy.decisionRuleArray{i}.params_NumberSet;
                thisStrategy.params_LowerBounds{i} = ...
                    thisStrategy.decisionRuleArray{i}.params_LowerBounds;
                thisStrategy.params_UpperBounds(i) = ...
                    thisStrategy.decisionRuleArray{i}.params_UpperBounds;
                thisStrategy.params_Value{i} = ...
                    thisStrategy.decisionRuleArray{i}.params_Value;
            end
        end
        
        
        function setParams_Value(thisStrategy)
        %{
        * TODO This code must set all the params of all decision rules
        implemented by thisStrategy
            
            Input
                
            Output
                
        %}
            thisStrategy.validateRulesAndDecisionVars();

        end
        
        
        function setParamsValue_Random(thisStrategy)
        %{
        * 
            Input
                
            Output
                
        %}
            n = thisStrategy.rules_Number;
            
            for i=1:n
                thisStrategy.decisionRuleArray{i}.setParamsValue_Random();
            end
            thisStrategy.validateStrategy();
        end
        
        
        function setParamsValue_UserInput(thisStrategy)
        %{
        * 
            Input
                
            Output
                
        %}
            n = thisStrategy.rules_Number;
            
            for i=1:n
                rule = thisStrategy.decisionRuleArray{i};
                if rule.parametrized == true
                    rule.setParamsValue_UserInput();
                end
            end
            thisStrategy.validateStrategy();
        end
        
        
        function decide(thisStrategy, theMsg)
        %{
        * 
            Input
                
            Output
                
        %}
            
            thisStrategy.gatherOutputFromRules(theMsg);
            
        end
        
        
        function gatherOutputFromRules(thisStrategy, theMsg, varargin)
        %{
        * 
            Input
                
            Output
                
        %}
            n = thisStrategy.rules_Number;
            
            for i = 1:n
                
                currentRule = thisStrategy.decisionRuleArray{i};
                
                decVarsType_fromRule = currentRule.decisionVars_TypeInfo;
                
                [answer, ~] = ismember(decVarsType_fromRule, ...
                    thisStrategy.decisionVars_TypeInfo);
                
                membershipTest = all(answer);
                
                if membershipTest == true
                    currentRule.decide(theMsg);
                else
                    error('Every type of decision variable value produced by any rule must also be specified in the attribute decisionVars_TypeInfo of thisStrategy')
                end
                
            end
        end
        
        
        %%
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
        function validateStrategy(thisStrategy)
        %{
        *
            Input
                
            Output
                
        %}
            n = thisStrategy.rules_Number;
            
            decVarsTypesFromAllRules = {};
            
            for i=1:n
                rule = thisStrategy.decisionRuleArray{i};
                decVarsType =  rule.decisionVars_TypeInfo;
                
                decVarsTypesFromAllRules = cat(2, ...
                    decVarsTypesFromAllRules, decVarsType);
                
                rule.validateRule();
                
            end
            
            % Check that number of decision vars of strategy are equal to
            % the aggregation of decision vars produced by all decision
            % rules implemented by this strategy
            numberDecVars_Strat = thisStrategy.decisionVars_Number;
            numberDecsVars_Rules = length(decVarsTypesFromAllRules);
            assert(numberDecVars_Strat == numberDecsVars_Rules, ...
                ['The number of decision variables produced by the ', ...
                'implemented rules do not coincide with the number ', ...
                'of decision variables required by this strategy.'])
            
            % Check that the each type of decision var required by this
            % strategy is implemented by the decision rules
            membershipArray = ismember(decVarsTypesFromAllRules, ...
                thisStrategy.decisionVars_TypeInfo);
            fullMembershipTest = all(membershipArray);
            assert(fullMembershipTest == true, ...
                ['There are decision variables required by this strategy ', ...
                'that are not being produced by the decision rules that ', ...
                'this strategy implements.'])
        end
        
        
        function answer = isSensitive(thisStrategy)
        %{
        *
            Input
                
            Output
                
        %}
            if strcmp(thisStrategy.typeStrategy_Sensitivity, managers.Strategy.SENSITIVE)
                answer = true;
            else
                answer = false;
            end
        end
        
        
        function answer = isStochastic(thisStrategy)
        %{
        *
            Input
                
            Output
                
        %}
            if strcmp(thisStrategy.typeStrategy_Determinacy, managers.Strategy.STOCHASTIC)
                answer = true;
            else
                answer = false;
            end
        end
        
        
        %{
        function answer = isCurrentlyOutputInvariant(thisStrategy)
            answer = thisStrategy.determinedStrategy && ...
                ~isempty(thisStrategy.lastOutput) && ...
                ~thisStrategy.isStochastic() && ...
                ~thisStrategy.isSensitive();
        end
        %}
        
        
    end
    
end