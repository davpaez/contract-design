classdef Rule_3 < managers.DecisionRule
    %{
    Related player: Agent
    Related action: Voluntary maintenance
    Class name: Rule_3
    Index: 3
    Name: Prediction time before violation
    ID: agentBehavior.voluntaryMaint.Rule_3
    Type of rule:
        * Sensitive
        * Deterministic
        * Absolute
    
    Parameters:
        * 
    
    Input:
        * perfThreshold
        * currentPerf
        * currentTime
        * solveTimeForPerformance
    
    Output:
        * timeNextMaintenance
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_3
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
        
        function thisRule = Rule_3()
            thisRule@managers.DecisionRule();
            
            import managers.*
            
            % Set index
            thisRule.setIndex(3);
            
            % Set name
            thisRule.setName('Prediction time before violation');
            
            % One decision variable: Time of voluntary maintenance
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.TIME_VOL_MAINT });
            
            % Set as Sensitive
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
            import managers.Information
            
            theAgent = theMsg.getExecutor();
            
            perfThreshold = theAgent.contract.getPerfThreshold();
            currentPerf = theAgent.solvePerformanceForTime(theAgent.time);
            
            if currentPerf <= perfThreshold
                timeNextVolMaint = theAgent.time;
            else
                timeNextVolMaint = theAgent.solveTimeForPerformance(perfThreshold);
            end
            
            assert(isreal(timeNextVolMaint), 'This time value must be a real number.')
            
            theMsg.submitResponse(Information.TIME_VOL_MAINT, timeNextVolMaint);
            
        end
        
        
    end
    
end