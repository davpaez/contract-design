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
        
        function thisStrategy = Strategy_1()
            
            import managers.*
            import behavior.nature.*
            
            idFaculty = Faculty.SHOCK;
            decVars = Faculty.getInfoDecVars(idFaculty);
            thisStrategy@managers.Strategy(decVars);
            
            % Create decision rule objects
            rule_1 = Shock.Rule_1();
            rule_10 = Shock.Rule_10();
            
            % Initialize cell array of strategy objects
            thisStrategy.addDecisionRule(rule_1);
            thisStrategy.addDecisionRule(rule_10);
            
            % Populate parameters properties of rules implemented
            
        end
        
    end
    
end