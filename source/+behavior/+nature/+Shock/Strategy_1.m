classdef Strategy_1 < managers.ShockStrategy
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
            
            thisStrategy@managers.ShockStrategy();
            
            import managers.*
            import behavior.nature.*
			
            % Set index
            thisStrategy.setIndex(1);
            
            % Create decision rule objects
            rule_1 = Shock.Rule_1();
            rule_10 = Shock.Rule_10();
            
            % Initialize cell array of strategy objects
            thisStrategy.decisionRuleArray{1} = rule_1;
            thisStrategy.decisionRuleArray{2} = rule_10;
            
            % Populate parameters properties of rules implemented
            
        end
        
    end
    
end