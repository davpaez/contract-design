classdef Rule_1 < managers.DecisionRule
    %{
    Related player: Agent
    Related action: Mandatory maintenance
    Class name: Rule_1
    Index: 1
    Name: Perfect Mandatory Maintenance
    ID: agentBehavior.mandatoryMaint.Rule_1
    Type of rule:
        * Sensitive
        * Deterministic
        * Delta
    
    Parameters:
        *
    
    Input:
        * perfThreshold
		* maxPerf
    
    Output:
        * deltaPerfAboveThreshold
    
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
            thisRule.setName('Perfect Mandatory Maintenance');
			
            % One decision variable: PerfGoal mandatory maintenance
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.PERF_MAND_MAINT });
            
            % Set as Sensitive
            thisRule.setTypeRule_Sensitivity(DecisionRule.SENSITIVE);
            
            % Set as Deterministic
            thisRule.setTypeRule_Determinacy(DecisionRule.DETERMINISTIC);

            % Type of output produced by this rule
            thisRule.setTypeRule_Output({ DecisionRule.DELTA_VALUE });
            
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
        * Perfect maintenance. This rule returns the change in performance that is necessary to achieve the maximum 'as good as new' performance of the infrastructure.
		
            Input
                theAgent: [class Agent] Agent object that is using this strategy.
				
				inputStructInfo: [class struct] Structure created and passed by Realization which contains information that may be useful to calculate output of this rule.
            Output
                deltaPerfAboveThreshold: [class double] Real value representing the value of performance additional to the threshold to be exerted on the infrastructure system.
        %}
        function mainAlgorithm(~, theMsg)
            import managers.Information
            
            theAgent = theMsg.getExecutor();
            perfThreshold = theAgent.contract.getPerfThreshold();
            maxPerf = theMsg.getExtraInfo(theMsg.MAX_PERF);
            
            deltaPerfAboveThreshold = 1* (maxPerf - perfThreshold);
            
            theMsg.submitResponse(Information.PERF_MAND_MAINT, deltaPerfAboveThreshold);
            
        end
        
        
    end
    
end