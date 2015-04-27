classdef Strategy < matlab.mixin.Copyable
    %STRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        decisionVars
        decisionRuleList
    end
    
    methods
        
        function thisStrategy = Strategy(decVars)
        %{
        
            Input
                
            Output
                
        %}
            thisStrategy.decisionVars = decVars;
            thisStrategy.decisionRuleList = cell(0);
        end
        
        function action = generateAction(thisStrategy)
        %{
        
            Input
                
            Output
                
        %}
            % TODO
        end
        
        function addDecisionRule(thisStrategy, rule)
        %{
        
            Input
                
            Output
                
        %}
            thisStrategy.decisionRuleList{end+1, 1} = rule;
        end
        
        function setDecisionRuleList(thisStrategy, decRuleList)
        %{
        
            Input
                
            Output
                
        %}
            thisStrategy.decisionRuleList = decRuleList;
        end
    end
    
end

