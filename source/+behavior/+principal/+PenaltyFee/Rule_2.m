classdef Rule_2 < managers.DecisionRule
    %{
    Related player: Principal
    Related action: Penalty
    Class name: Rule_2
    Index: 2
    Name: Incremental
    ID: behavior.principal.penaltyFee.Rule_2
    Type of rule:
        * Sensitive
        * Deterministic
        * Absolute
    
    Parameters:
        * 
    
    Input:
        * pastPenalties
        * maxSumPenalties
        * contractDuration
        * violationTime
    
    Output:
        * valuePenaltyFee
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_2
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
        
        function thisRule = Rule_2()
            thisRule@managers.DecisionRule();
            
            import managers.*
            
            % Set index
            thisRule.setIndex(2);
            
            % Set name
            thisRule.setName('Incremental');
			
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
            import dataComponents.Transaction
            import managers.Information
            
            thePrincipal = theMsg.getExecutor();
            penaltyPayoffs = thePrincipal.payoffList.returnPayoffsOfType(Transaction.PENALTY);
            pmax = 500; % Arbitrary value
            tm = thePrincipal.contract.duration;

            sumPastPenalties = sum(penaltyPayoffs.valueFlow);
            
			violationTime = theMsg.getExtraInfo(theMsg.TIME_DETECTION);
			
            gamma = log(pmax+1)/tm;
            currentNecessarySumPenalties = exp(gamma*violationTime)-1;
            
            valuePenaltyFee = currentNecessarySumPenalties - sumPastPenalties;
            
            theMsg.submitResponse(Information.VALUE_PENALTY_FEE, valuePenaltyFee);
            
        end
        
        
    end
    
end