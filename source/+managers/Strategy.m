classdef Strategy < matlab.mixin.Copyable
    %STRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        decisionVars
        decisionRuleList
    end
    
    methods
        
        function thisStrategy = Strategy(decVars)
            thisStrategy.decisionVars = decVars;
            thisStrategy.decisionRuleList = cell(0);
        end
        
        function action = generateAction(thisStrategy)
            % TODO
        end
        
        function addDecisionRule(thisStrategy, rule)
            thisStrategy.decisionRuleList{end+1, 1} = rule;
        end
        
        function setDecisionRuleList(thisStrategy, decRuleList)
            thisStrategy.decisionRuleList = decRuleList;
        end
    end
    
end

