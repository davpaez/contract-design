classdef CommonFnc
    
    methods (Static)
        
        
        function force = continuousEnvForce(t)
        %{
        * Resembles the rain period in Colombia.
        
            Input
                t:  Time (years)
                
            Output
                f:  Precipitation [mm/year]
        %}
            force = (-(51*sin(t*2*pi./0.5 + pi/4))+86)*12;
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
            r = -(f./1000).*20.*(0.5./((v+10)./100));
            if v <= 0 % TODO Make this truncation works when arguments are vectors
                r = 0;
            end
            
        end
        
        
        function d = demandFunction(v, fare)
        %{
        * Bilinear demand function
        
            Input
                v:      Performance
                fare:	Unitary price for infrastructure usage
            
            Output
                d:      Rate of demand
        %}
            
            a = 160000;
            b = 40000;
            k = 50;
            
            n = length(v);
            d = zeros(n,1);
            
            for i=1:n
                if v(i) <= k
                    d(i) = a*v(i);
                else
                    d(i) = a*k + b*(v(i)-k);
                end
            end
        end
        
        
        function rate = revenueRate(d, fare)
        %{
        * 
        
            Input
                d:      Rate of demand
                fare:	Price received per unit of demand
            
            Output
                rate:   Rate of revenue
        %}
            rate = d*fare;
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
        minF = 3;
        maxF = 30;

        assert(forceValue >= 0, 'Force value must be non-negative')

        condition = forceValue >= minF + ((maxF-minF) / (maxP-nullP))*(currentPerf-nullP);

        if condition == true
            finalPerf = nullP;
        elseif forceValue <= minF
            finalPerf = currentPerf;
        else

            p1 = [nullP , minF , nullP];
            p2 = [maxP  , maxF , nullP];
            p3 = [maxP  , minF , maxP ];

            r_12 = p2-p1;
            r_13 = p3-p1;

            n = cross(r_12, r_13);
            p = p1;

            finalPerf = (  -n(1)*(currentPerf-p(1)) ...
                -n(2)*(forceValue -p(2)) ...
                +n(3)*p(3)                      )/n(3);

            if finalPerf < nullP
                finalPerf = nullP;
            end

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
            up = thePrincipal.observationList.getMeanValue();
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
        
    end

end