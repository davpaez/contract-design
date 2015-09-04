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
        minF = 0;
        maxF = 70;

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