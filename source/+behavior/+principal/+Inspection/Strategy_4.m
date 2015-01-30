classdef Strategy_4 < managers.InspectionStrategy
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
        
        function thisStrategy = Strategy_4()
            
            thisStrategy@managers.InspectionStrategy();
            
            import managers.*
            import behavior.principal.*
			
            % Set index
            thisStrategy.setIndex(4);
            
            % Create decision rule objects
            rule_4 = Inspection.Rule_4();
            
            % Initialize cell array of decision rule objects
            thisStrategy.decisionRuleArray{1} = rule_4;
            
            % Populate parameters properties of rules implemented
            
        end
        
    end
    
end