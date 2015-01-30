classdef PenaltyFeeStrategy < managers.Strategy
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
        
        function thisStrategy = PenaltyFeeStrategy()
            
            thisStrategy@managers.Strategy();
            
            import managers.*
            import behavior.principal.*
			
			% Set type action
			thisStrategy.typeAction = Action.PENALTY;
            
            % One decision variable: Monetary value of penalty fee
            thisStrategy.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisStrategy.setDecisionVars_TypeInfo({ Information.VALUE_PENALTY_FEE });
            
        end
        
    end
    
end