classdef Rule_1 < managers.DecisionRule
    %{
    Related player: Principal
    Related action: Penalty
    Class name: Rule_1
    Index: 1
    Name: Fixed amount
    ID: behavior.principal.penaltyFee.Rule_1
    
    Type of rule:
        * Sensitive
        * Deterministic
        * Absolute
    
    Parameters:
        * 
    
    Input:
        * pastPenalties
        * limitSumPenalties
    
    Output:
        * limitSumPenalties
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_1
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        
    end
    
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
        
        function thisRule = Rule_1()
            thisRule@managers.DecisionRule();
            
            import managers.*
            
            % Set index
            thisRule.setIndex(1);
            
            % Set name
            thisRule.setName('Fixed amount');
            
            % One decision variable: Monetary value of penalty fee
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.VALUE_PENALTY_FEE });
            
            % Set as Adaptive
            thisRule.setTypeRule_Sensitivity(DecisionRule.SENSITIVE);
            
            % Set as Deterministic
            thisRule.setTypeRule_Determinacy(DecisionRule.DETERMINISTIC);
			
            % Type of output produced by this rule
            thisRule.setTypeRule_Output({ DecisionRule.ABSOLUTE_VALUE });
        end
        
        %% Getter functions
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------        
        % ----------------------------------------------------------------
        
        
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        %{
        
            Input
                
            Output
                
        %}
        function mainAlgorithm(~, theMsg)
            import dataComponents.Payoff
            import managers.Information
            
            thePrincipal = theMsg.getExecutor();
            
            penaltyPayoffs = thePrincipal.payoff.returnPayoffsOfType(Payoff.PENALTY);
            pmax = thePrincipal.contract.getMaxSumPenalties();

            sumPastPenalties = sum(penaltyPayoffs.value);
			
			n = 10;
			valueSinglePenalty = pmax / n;
			
			slack = pmax - sumPastPenalties;
			
			assert(slack >= 0)
            
			if slack > valueSinglePenalty
				valuePenaltyFee = valueSinglePenalty;
			else
				valuePenaltyFee = slack;
            end
            
            theMsg.submitResponse(Information.VALUE_PENALTY_FEE, valuePenaltyFee);
            
        end
        
        
    end
    
end