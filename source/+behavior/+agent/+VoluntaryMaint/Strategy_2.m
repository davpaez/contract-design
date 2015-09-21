classdef Strategy_2 < managers.Strategy
	
    methods
        %% Constructor
        
        function thisStrategy = Strategy_2(theFaculty)
            
            import managers.*
            import behavior.agent.*
			
            id = 'Perfect random maintenance';
            thisStrategy@managers.Strategy(id, theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_2 = VoluntaryMaint.Rule_2();
            rule_10 = VoluntaryMaint.Rule_10();
            
            % Customize parameters properties of rules implemented
            
            
            % Initialize cell array of strategy objects
            thisStrategy.addDecisionRule(rule_2);
            thisStrategy.addDecisionRule(rule_10);
        end
        
    end
    
end