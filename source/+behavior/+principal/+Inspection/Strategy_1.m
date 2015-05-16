classdef Strategy_1 < managers.Strategy
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %

        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
	
    methods
        %% Constructor
        
        function thisStrategy = Strategy_1(theFaculty)
            
            import managers.*
            import behavior.principal.*
            
            thisStrategy@managers.Strategy(theFaculty.decisionVars);
            
            % Create decision rule objects
            rule_1 = Inspection.Rule_1();
            
            % Customize parameters properties of rules implemented
            
            
            % Initialize cell array of decision rule objects
            thisStrategy.addDecisionRule(rule_1);
        end
        
    end
    
end