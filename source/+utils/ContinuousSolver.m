classdef ContinuousSolver

    properties
        realization
        
        contEnvForce % Continuous environmental force
        contRespFnc % Continuous response function
        demandFnc % Demand function
        revenueFnc % Revenue rate function
        
    end
    
    methods
        
        function self = ContinuousSolver(progSet, realz)
            
            import managers.ItemSetting
            
            self.realization = realz;
            
            % Continuous environmental force
            item = progSet.returnItemSetting(ItemSetting.CONT_ENV_FORCE);
            self.contEnvForce = item.equation;
            
            % Continuous response function
            fnc = progSet.returnItemSetting(ItemSetting.CONT_RESP_FNC);
            self.contRespFnc = fnc.equation;
            
            % Demand function
            item = progSet.returnItemSetting(ItemSetting.DEMAND_FNC);
            self.demandFnc = item.equation;
            
        end
        
        function [t, y] = solveFutureState(self, t0, tf, y0)
        %{
        
            Input
                
            Output
                t
            
                y: y(1): Performance, y(2): Agent's balance
        %}
            assert(length(tf) == 1, 'The time parameter must be a scalar')
            assert(tf > t0, 'Time tf must be greater than t0')
            
            %  ------ Differential equations for stocks -------
            
            cef = self.contEnvForce;
            crf = self.contRespFnc;
            dem = self.demandFnc;
            rev = self.realization.contract.revRateFnc;
            
            % Performance rate function
            v_f = @(t,v) crf(cef(t), ...
                dem(v), ...
                v, ...
                t);
            
            % Agent's balance rate function
            ba_f = @(v) rev(dem(v));
            
            fun = @(t,x) [v_f(t,x(1));  ba_f(x(1))];
            
            currentPerf = y0(1);
            currentAgentBalance = y0(2);
            
            [t,y] = ode45(fun, [t0, tf], [currentPerf; currentAgentBalance]);
            
        end
        
        
        function solvePerformance(self, time)
            
        end
        
        
        function solveTime(self, perf)
            
        end
        
        
    end
end