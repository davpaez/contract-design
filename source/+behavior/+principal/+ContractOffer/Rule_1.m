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
            thisRule.setDecisionVars_Number(4);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.CONTRACT_DURATION; ...
                Information.PAYMENT_SCHEDULE; ...
                Information.REVENUE_RATE_FUNC; ...
                Information.PERFORMANCE_THRESHOLD});
            
            % Set as Sensitive
            thisRule.setTypeRule_Sensitivity(DecisionRule.INSENSITIVE);
            
            % Set as Deterministic
            thisRule.setTypeRule_Determinacy(DecisionRule.DETERMINISTIC);
            
            % Type of output produced by this rule
            thisRule.setTypeRule_Output({ DecisionRule.ABSOLUTE_VALUE; ...
                DecisionRule.ABSOLUTE_VALUE; ...
                DecisionRule.ABSOLUTE_VALUE; ...
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
            import dataComponents.PaymentSchedule
            import dataComponents.Transaction
            
            thePrincipal = theMsg.getExecutor();
            
            % Submit response
            %{
              - tm: contract duration
              - pc: principal's contribution
              - rf: revenue rate function
              - k: performance threshold
            %}
            
            tm = 25;
            
            pc_time = [0, 5, 10, 15];
            pc_value = [150, 150, 50, 50];
            pc = PaymentSchedule();
            pc.buildFromVectors(pc_time, pc_value, Transaction.CONTRIBUTION);
            
            rf = @revenueRate;
            k = 70;
            
            theMsg.submitResponse(Information.CONTRACT_DURATION, tm, ...
                Information.PAYMENT_SCHEDULE, pc, ...
                Information.REVENUE_RATE_FUNC, rf, ...
                Information.PERFORMANCE_THRESHOLD, k);
        end
        
        
    end
    
end

function rate = revenueRate(d)
%{
* 

    Input
        d:      Rate of demand

    Output
        rate:   Rate of revenue
%}
    fare = 720/10e7;    
    rate = d*fare;
end