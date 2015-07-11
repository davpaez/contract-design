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
        CONTRACT_DURATION = 'CONTRACT_DURATION'
        FARE = 'FARE'
        PERFORMANCE_THRESHOLD = 'PERFORMANCE_THRESHOLD'
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
            thisRule.setName('Simple parametrized');

            % One decision variable: Time of voluntary maintenance
            thisRule.setDecisionVars_Number(4);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.CONTRACT_DURATION; ...
                Information.PAYMENT_SCHEDULE; ...
                Information.REVENUE_RATE_FUNC; ...
                Information.PERFORMANCE_THRESHOLD});
            
            % Set as a parametrized rule
            thisRule.setAsParametrized();
            
            % Set number or parameters
            thisRule.setParams_Number(3);
            
            % Set name of parameters
            thisRule.setParams_Name({ ...
                thisRule.CONTRACT_DURATION, ...
                thisRule.FARE, ...
                thisRule.PERFORMANCE_THRESHOLD});
            
            % Set number set of parameters
            thisRule.setParams_NumberSet({ ...
                InputData.REAL, ...
                InputData.REAL, ...
                InputData.REAL})
            
            % Set upper and lower bounds for parameters
            thisRule.setParams_LowerBounds([ 1, 5e-7 10]);
            thisRule.setParams_UpperBounds([ 50 5e-5 95]);
            
			% Set default parameters value
			thisRule.setParams_Value( [10, 2.5E-6, 60] );
            
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
            
            tm = thisRule.params_Value(1);
            fare = thisRule.params_Value(2);
            k = thisRule.params_Value(3);
            
            pc_time = [0, 5, 10, 15];
            pc_value = [150, 150, 50, 50];
            pc = PaymentSchedule();
            pc.buildFromVectors(pc_time, pc_value, Transaction.CONTRIBUTION);
            
            rf = @(d)revenueRate(d, fare);
            
            theMsg.submitResponse(Information.CONTRACT_DURATION, tm, ...
                Information.PAYMENT_SCHEDULE, pc, ...
                Information.REVENUE_RATE_FUNC, rf, ...
                Information.PERFORMANCE_THRESHOLD, k);
        end
        
        
    end
    
end

function rate = revenueRate(d, fare)
%{
* 

    Input
        d:      Rate of demand

    Output
        rate:   Rate of revenue
%}   
    rate = d*fare;
end