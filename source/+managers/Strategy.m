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
        
        
        function decide(self, theMsg)
        %{
        * 
            Input
                
            Output
                
        %}
            n = length(self.decisionRuleList);
            
            for i = 1:n
                
                currentRule = self.decisionRuleList{i};
                
                decVarsType_fromRule = currentRule.decisionVars_TypeInfo;
                
                [answer, ~] = ismember(decVarsType_fromRule, ...
                    self.decisionVars);
                
                membershipTest = all(answer);
                
                if membershipTest == true
                    currentRule.decide(theMsg);
                else
                    error('Every type of decision variable value produced by any rule must also be specified in the attribute decisionVars_TypeInfo of thisStrategy')
                end
                
            end
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
        
        
        function answer = isSensitive(self)
        %{
        *
            Input
                
            Output
                
        %}
            
            n = length(self.decisionRuleList);
            answer = false;
            for i=1:n
                if self.decisionRuleList{i}.isSensitive()
                    answer = true;
                    break
                end
            end
        end
        
    end
    
end

