classdef Strategy_2 < managers.Strategy
    
    methods
        %% Constructor
        
        function thisStrategy = Strategy_2(theFaculty)
            
            import managers.*
            import behavior.principal.*
			
            id = 'Incremental';
            thisStrategy@managers.Strategy(id, theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_2 = PenaltyFee.Rule_2();
            
            % Customize parameters properties of rules implemented
            
            
            % Initialize cell array of strategy objects
            thisStrategy.addDecisionRule(rule_2);
        end
        
    end
    
end