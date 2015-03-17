classdef Strategy_1 < managers.ContractStrategy
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
            
            thisStrategy@managers.ContractStrategy();
            
            import managers.*
            import behavior.principal.*
			
            % Set index
            thisStrategy.setIndex(1);
            
            % Create decision rule objects
            rule_1 = ContractOffer.Rule_1();
            
            % Initialize cell array of strategy objects
            thisStrategy.decisionRuleArray{1} = rule_1;
            
            % Populate parameters properties of rules implemented
            
        end
        
    end
    
end