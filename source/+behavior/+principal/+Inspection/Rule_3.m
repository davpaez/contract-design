classdef Rule_3 < managers.DecisionRule
    %{
    index:  3
    ID:     principalBehavior.inspection.Rule_3
    Name:   extrapolation_detectViolation
    Type of rule:
        Sensitive
		Deterministic
        Absolute
    
    Parameters (From the optimization solver):
        None
    
    Input (From thePrincipal object):
        pastPerfObs: [struct] Structure with past inpections
    
        currentTime: [double] Current time of realization
        
        perfThreshold: [doublue] Performance threshold specified in
            the current constract object in realization
    
    Output:
        timeNextInspection
    
    Uses rules:
        Rule_2
    
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
            import behavior.principal.*
            
            % Set index
            thisRule.setIndex(3);
            
            % One decision variable: Time of inspection
            thisRule.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisRule.setDecisionVars_TypeInfo({ Information.TIME_INSPECTION });
            
            % Auxiliary decision rule: Rule_2: guess
            thisRule.auxRuleArray{1} = Inspection.Rule_2();
			
            % Set as Non-adaptive
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
        %TODO Change method signature to receive theMsg object
        function timeNextInspection = mainAlgorithm(thisRule, thePrincipal, inputStructInfo)
            %TODO Fix this. It is not working
            
            useAuxRule = false;
            numberPastInspections = thePrincipal.observation.getLength();
            
            if numberPastInspections >= 3
                pastInspections = thePrincipal.observation.getData();
                
                % Selects three last inspections
                lastThreeInsp.time = pastInspections.time(end-2:end);
                lastThreeInsp.value = pastInspections.value(end-2:end);
                
                if isNonIncreasing(lastThreeInsp.value)

                    t = lastThreeInsp.time;
                    v = lastThreeInsp.value;

                    perfThreshold = thePrincipal.contract.getPerfThreshold();
                    
                    inspectAtPerfValue = 1.1*perfThreshold;
                    
                    % Determine if set of points is convex/linear
                    if isConvexLinear(lastThreeInsp)
                        % If points are convex or linear 
                        % --> Linear extrapolation using points 1 and 2
                        %       solving for 0.9k*
                        timeNextInspection = ((t(2)-t(1)) / (v(2)-v(1)))* ...
                            (inspectAtPerfValue - v(1)) + t(1);
                    else
                        % If points are concave
                        % --> Quadratic extrapolation using all 3 points
                        %       solving for 0.9k*
                        A = [ t(1)^2    t(1)     1
                              t(2)^2    t(2)     1
                              t(3)^2    t(3)     1 ];

                        b = [v(1)   v(2)   v(3)]';

                        % Solving linear system
                        coeff = A\b ;

                        a = coeff(1);
                        b = coeff(2);
                        c = coeff(3);

                        % Finding root of ax^2 + bx + (c - 0.9k*) = 0
                        discriminante = b^2 - 4*a*(c-inspectAtPerfValue);
                        if discriminante < 0
                            useAuxRule = true;
                        else
                            timeNextInspection = (-b - sqrt( discriminante )) / (2*a);
                            
                            intervalLimit = thePrincipal.contract.getContractDuration()/5;
                            if timeNextInspection - t(end) > intervalLimit
                                timeNextInspection = t(end) + intervalLimit;
                            end
                            
                        end
                    end
                else
                    useAuxRule = true;
                end
            else
                useAuxRule = true;
            end
            
            if useAuxRule == true
                rule_2 = thisRule.auxRuleArray{1};
                timeNextInspection = rule_2.mainAlgorithm(thePrincipal,[]);
            end
            
            currentTime = thePrincipal.time;
            
            if timeNextInspection <= currentTime
                timeNextInspection = currentTime+1/365;
            end
            
            assert(isreal(timeNextInspection), 'This time value must be a real number.')
            assert(timeNextInspection >= 0, 'This time value must be a non-negative number.')
            
        end
        
    end
    
end

%% Auxiliar functions

%{
* Determines if all adjacent elements of a vector are non-increasing
    Input

    Output

%}
function answer = isNonIncreasing(v)
    n = length(v);
    answer = true;

    for i=1:n-1
        if v(i) < v(i+1)
            answer = false;
            break
        end
    end
end

%{
* Determines three last inspections are convex/linear
    Input

    Output

%}
function answer = isConvexLinear(inspections)
    t = inspections.time;
    v = inspections.value;

    assert(length(t) == 3, 'Vector must have length equal to 3')
    assert(length(v) == 3, 'Vector must have length equal to 3')

    % If points are convex or linear
    if v(2) <= v(1) + (v(3) - v(1)) *( (t(2) - t(1)) / (t(3) - t(1)) );
        answer = true;

    else  % If points are concave
        answer = false;

    end
end



