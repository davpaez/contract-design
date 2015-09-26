classdef CommonFnc
    
    properties (Constant)
        
        null_perf = 0
        max_perf = 100
        initial_perf = 100
        agent_initial_balance = 875
        cost_single_inspection = 875/500
        
    end
    methods (Static)
        
        
        function force = continuousEnvForce(t)
        %{
        * Resembles the rain period in Colombia.
        
            Input
                t:  Time (years)
                
            Output
                f:  Precipitation [mm/year]
        %}
            
            A = 612;    % Amplitude
            f = 2;      % Cycles per year
            phi = pi/4; % Phase shift (radians)
            m = 1032;   % Mean value
            
            force = -A*sin((2*pi*f)*t + phi) + m;
        end
        
        
        function finalPerf = shockResponseFunction(nullP, maxP, currentPerf, forceValue)
        %{
        * 

            Input
                nullP:          Minimum performance
                maxP:           Maximum performance
                currentPerf:    Current performance
                forceValue:     Instantaneous environmental force
            
            Output
                finalPerf:      Performance after shock
        %}

        assert(forceValue >= 0, 'Force value must be non-negative')
        
        if currentPerf/forceValue <= 100/50
            finalPerf = 0;
        else
            finalPerf = currentPerf - 100/50*forceValue;
        end
        
        end
        
        function r = continuousRespFunction(f, d, v, t)
        %{
        * 

            Input
                f:  Continuous environmental force
                d:  Demand
                v:  Performance
                t:  Time (years)

            Output
                r:  Response
        %}

        a = 1.3;
        b = 2.3;
        vi = 100;

        r = -a*b*((vi-v)./a).^((b-1)/b) - 0.01 - 0.6*t; %- (d/28e6)*20*((v^2)/500);
        if v <= 0
            r = 0;
        end

        end
        
        
        function up = principalUtility(thePrincipal)
        %{
        * 

            Input
                thePrincipal:   Principal object
            
            Output
                up:             Principal's utility
        %}
            import dataComponents.Transaction
            
            perf_mean = thePrincipal.observationList.getMeanValue();
            balance = thePrincipal.payoffList.getBalance();
            sumContrib = abs(thePrincipal.contract.paymentSchedule.getSumTransactions(...
                Transaction.CONTRIBUTION));
            
            if balance >= -sumContrib
                up = (10*perf_mean - balance - sumContrib)/1000;
            else
                up = (10*perf_mean + balance + sumContrib)/1000;
            end
        end
        
        
        function ua = agentUtility(theAgent)
        %{
        * 

            Input
                theAgent:   Agent's object
            
            Output
                ua:         Agent's utility
        %}
            if ~isempty(theAgent.payoffList)
                ua = theAgent.payoffList.getBalance();
            else
                ua = 0;
            end
        end
        
        
        function cost = maintenanceCostFunction(inv, nullP, maxP, currentP, goalP)

            % inv:      Cost of construction: Investment
            % nullP:    Null performance
            % maxP:     Max performance
            % fixedCost:    Fixed (minimum) cost of a maintenance work

            % Maintenance cost can be at most epsilon times the value
            % of the construction investment
            epsilon = 0.2;
            fixedCost = 4;

            cost = ((goalP-currentP) / (maxP-nullP))*epsilon*inv + fixedCost;

            assert(isreal(cost), 'Cost must be a real number.')
        end
        
    end

end