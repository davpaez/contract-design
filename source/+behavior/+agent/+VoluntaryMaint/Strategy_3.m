classdef Strategy_3 < managers.Strategy
	
    methods
        %% Constructor
        
        function thisStrategy = Strategy_3(theFaculty)
            
            import managers.*
            import behavior.agent.*
			
            id = 'Perfect maintenance before violation';
            thisStrategy@managers.Strategy(id, theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_3 = VoluntaryMaint.Rule_3();
            rule_10 = VoluntaryMaint.Rule_10();
            
            % Customize parameters properties of rules implemented
            
            
            % Initialize cell array of strategy objects
            thisStrategy.addDecisionRule(rule_3);
            thisStrategy.addDecisionRule(rule_10);
        end
        
    end
    
end