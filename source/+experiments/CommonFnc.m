classdef CommonFnc
    %SHAREDPARAMS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        
        function finalPerf = shockResponseFunction(nullP, maxP, currentPerf, forceValue)

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
            up = thePrincipal.observation.getMeanValue();
        end

        function ua = agentUtility(theAgent)

            if ~isempty(theAgent.payoff)
                tm = theAgent.contract.getContractDuration();
                ua = theAgent.payoff.getNPV(tm);
            else
                ua = 0;
            end
        end
        
    end    
end