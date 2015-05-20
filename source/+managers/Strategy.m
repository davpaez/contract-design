classdef Strategy < matlab.mixin.Copyable
    
    properties
        id
        decisionVars
        decisionRuleList
    end
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
        %{
        * 
            Input
                
            Output
                
        %}
            
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            if ~isempty(obj.decisionRuleList)
                n = length(obj.decisionRuleList);
                for i=1:n
                    cpObj.decisionRuleList{i} = copy(obj.decisionRuleList{i});
                end
            end
        end
        
        
    end
    
    methods
        
        function thisStrategy = Strategy(id, decVars)
        %{
        
            Input
                
            Output
                
        %}
            thisStrategy.id = id;
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

