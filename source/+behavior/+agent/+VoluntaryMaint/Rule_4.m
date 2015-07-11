classdef Rule_4 < managers.DecisionRule
    %{
    Related player: Agent
    Related action: Voluntary maintenance
    Class name: Rule_4
    Index: 4
    Name: Prediction time before inspection
    ID: agentBehavior.voluntaryMaint.Rule_4
    Type of rule:
        * Sensitive
        * Deterministic
        * Absolute
    
    Parameters:
        * 
    
    Input:
        * pastInspectionTimes
        * currentTime
    
    Output:
        * timeNextMaintenance
    
    Child rules:
        * 
    
    Parent rules:
        * 
    
    Parent strategies:
        * Strategy_4
    %}
    
    properties (Constant, Hidden = true)
        % Names or parameters in order
        
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        finalMaint = false
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    methods
        %% Constructor
        
        function thisRule = Rule_4()
            thisRule@managers.DecisionRule();
            
            import managers.*
            
            % Set index
            thisRule.setIndex(4);
            
            % Set name
            thisRule.setName('Prediction time before inspection');
            
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
        function mainAlgorithm(thisRule, theMsg)
            import dataComponents.Event
            import managers.Information
            
            %TODO Improve bugs
            %TODO Figure out the conditions that a rule must have to not
            %make the program cycle indefinitely
            
            theAgent = theMsg.getExecutor();
            
            inspEvents = theAgent.eventList.getEventsOfType(Event.INSPECTION);
            if isempty(inspEvents)
                timeNextVolMaint = theAgent.time*3;
                
            elseif length(inspEvents.time) == 1
                expInterval = inspEvents.time;
                timeNextVolMaint = ceil(theAgent.time/expInterval)*expInterval*0.98;
                
            else
                expInterval = mean(diff(inspEvents.time));
                timeLastInsp = inspEvents.time(end);
                lastVolMaintEvent = theAgent.eventList.getLastEventOfType(Event.VOL_MAINT);
                if isempty(lastVolMaintEvent) || lastVolMaintEvent.time > timeLastInsp
                    timeNextVolMaint = timeLastInsp + 2*expInterval;
                else
                    timeNextVolMaint = timeLastInsp + 0.95*expInterval;
                end
            end
            
            assert(~isnan(timeNextVolMaint), 'Hola')
            
            if timeNextVolMaint <= theAgent.time
                timeNextVolMaint = theAgent.time + 0.1;
            end
            
            timeTermination = theAgent.contract.contractDuration;
            if timeNextVolMaint > timeTermination
                if thisRule.finalMaint == false
                    timeNextVolMaint = max(timeTermination - 0.1, ...
                        (theAgent.time+timeTermination)/2);
                    thisRule.finalMaint = true;
                else
                    timeNextVolMaint = inf;
                end
            end
            
            theMsg.submitResponse(Information.TIME_VOL_MAINT, timeNextVolMaint);
            
        end
        
        
    end
    
end