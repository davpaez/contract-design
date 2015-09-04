classdef Solver

    properties
        realization
        
        contEnvForce % Continuous environmental force
        contRespFnc % Continuous response function
        demandFnc % Demand function
        revenueFnc % Revenue rate function
        
    end
    
    methods
        
        function self = Solver(progSet, realz)
            
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
            
            perfHistory = y(:,1);
            
            % Make perf values comply with null and max perf
            nullPerf = self.realization.infrastructure.nullPerf;
            maxPerf = self.realization.infrastructure.maxPerf;
            
            indices = perfHistory < nullPerf;
            perfHistory(indices) = nullPerf;
            
            indices = perfHistory > maxPerf;
            perfHistory(indices) = maxPerf;
            
            y(:,1) = perfHistory;
        end
        
        
        function perf = solvePerformance(self, time)
        %{
        * Solve performance for a given time
            
            Input
                time: Time at which the performance is queried
            
            Output
                perf: Performance level at time
        %}
            currentTime = self.realization.time;
            queriedTime = time;
            
            tol = 1e-5;
            
            if queriedTime < currentTime
                perf = self.realization.infrastructure.history.solveValue(time);
            elseif abs(queriedTime - currentTime) < tol
                perf = self.realization.infrastructure.performance;
            else
                % Extrapolate
                currentPerf = self.realization.infrastructure.performance;
                currentAgentBalance = self.realization.agent.payoffList.getBalance();
                
                [t, y] = self.solveFutureState(currentTime, time, [currentPerf; currentAgentBalance]);
                perfHistory = y(:,1);
                perf = perfHistory(end);
            end
        end
        
        
        function time = solveTime(self, perf)
        %{
        * 
            
            Input
                
            
            Output
                
        %}
            currentTime = self.realization.time;
            finalTime = self.realization.contract.duration;
            
            currentPerf = self.realization.infrastructure.performance;
            currentAgentBalance = self.realization.agent.payoffList.getBalance();
            
            [t, f] = self.solveFutureState(currentTime, finalTime, [currentPerf; currentAgentBalance]);
            
            y = f(:,1);
            
            % Decrease all y by perf
            y = y - perf;
            
            num = length(t);
            time = [];
            
            tol = 1e-6;
            
            for i=2:num
                if abs(y(i) - 0) < tol
                    time = t(i);
                    break
                else
                    y0 = y(i-1);
                    y1 = y(i);
                    t0 = t(i-1);
                    t1 = t(i);
                    
                    m = y0 * y1;
                    if m < 0
                        time = t1 + (t0-t1)*(0 - y1)/(y0 - y1);
                        break
                    end
                end
            end
            
            if isempty(time)
                ME = MException('solveTime:perfNotFound', 'The performance queried was not found');
                throw(ME)
            end
        end
        
        
    end
end