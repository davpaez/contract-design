classdef Strategy_2 < managers.Strategy
    
    methods
        %% Constructor
        
        function thisStrategy = Strategy_2(theFaculty)
            
            import managers.*
            import behavior.principal.*
            
            id = 'Random_1';
            thisStrategy@managers.Strategy(id, theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_2 = Inspection.Rule_2();
            
            % Initialize cell array of decision rule objects
            thisStrategy.addDecisionRule(rule_2);
        end
        
    end
    
end