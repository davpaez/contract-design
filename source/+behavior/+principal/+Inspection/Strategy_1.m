classdef Strategy_1 < managers.Strategy
    
    methods
        %% Constructor
        
        function thisStrategy = Strategy_1(theFaculty)
            
            import managers.*
            import behavior.principal.*
            
            id = 'Fixed_plus_random';
            thisStrategy@managers.Strategy(id, theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_1 = Inspection.Rule_1();
            
            % Initialize cell array of decision rule objects
            thisStrategy.addDecisionRule(rule_1);
        end
        
    end
    
end