classdef Strategy_4 < managers.Strategy
    
    methods
        %% Constructor
        
        function thisStrategy = Strategy_4(theFaculty)
            
            import managers.*
            import behavior.principal.*
            
            id = 'Heuristic_1';
            thisStrategy@managers.Strategy(id, theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_4 = Inspection.Rule_4();
            
            % Customize parameters properties of rules implemented
            
            
            % Initialize cell array of decision rule objects
            thisStrategy.addDecisionRule(rule_4);
        end
        
    end
    
end