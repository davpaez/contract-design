classdef Rule_1 < managers.DecisionRule
    %{
    Related player: Principal
    Related action: Contract Offer
    Class name: Rule_1
    Index: 1
    Name: Standard contract
    ID: principalBehavior.contractOffer.Rule_1
    Type of rule:
        * 
        * 
        * 
    
    Parameters:
        * 
    
    Input:
        * 
        * 
    
    Output:
        * 
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_1
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        MAINTENANCE_TIME_INTERVAL = 'maintenanceTimeInterval'
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
            thisRule.setName('Standard contract');

            % One decision variable: Time of voluntary maintenance
            thisRule.setDecisionVars_Number(5);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.CONTRACT_DURATION , ...
                Information.PAYMENT_SCHEDULE, ...
                Information.REVENUE_RATE_FUNC, ...
                Information.PERFORMANCE_THRESHOLD, ...
                Information.PENALTY_FEE_STRAT});
            
            % Set as Sensitive
            thisRule.setTypeRule_Sensitivity(DecisionRule.INSENSITIVE);
            
            % Set as Deterministic
            thisRule.setTypeRule_Determinacy(DecisionRule.DETERMINISTIC);
            
            % Type of output produced by this rule
            thisRule.setTypeRule_Output({ DecisionRule.ABSOLUTE_VALUE, ...
                DecisionRule.ABSOLUTE_VALUE, ...
                DecisionRule.ABSOLUTE_VALUE, ...
                DecisionRule.ABSOLUTE_VALUE, ...
                DecisionRule.ABSOLUTE_VALUE});
            
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
        function mainAlgorithm(thisRule, theMsg)
            import dataComponents.Event
            import managers.Information
            
            thePrincipal = theMsg.getExecutor();
            
            % Submit response
            %{
              - contract duration
              - payment schedule
              - revenue rate function
              - performance threshold
              - penalty fee strategy (passed as argument)
            %}
            theMsg.submitResponse(Information.CONTRACT_DURATION, tm, ...
                Information.PAYMENT_SCHEDULE, h, ...
                Information.REVENUE_RATE_FUNC, rf, ...
                Information.PERFORMANCE_THRESHOLD, k, ...
                Information.PENALTY_FEE_STRAT, sl);
        end
        
        
    end
    
end