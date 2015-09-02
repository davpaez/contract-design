classdef Strategy_3 < managers.Strategy
    
    methods
        %% Constructor
        
        function thisStrategy = Strategy_3(theFaculty)
            
            import managers.*
            import behavior.principal.*
            
            id = 'Heuristic';
            thisStrategy@managers.Strategy(id, theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_3 = Inspection.Rule_3();
            
            % Customize parameters properties of rules implemented
            
            
            % Initialize cell array of decision rule objects
            thisStrategy.addDecisionRule(rule_3);
        end
        
    end
    
end