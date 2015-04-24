classdef Infrastructure < matlab.mixin.Copyable
    
    properties (Constant)
        TIMESTEP = 20/365    % Resolution in years of the performance samples

    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        nullPerf               % Null performance  
        maxPerf                % Maximum possible performance
        initialPerf
        
        contResponseFnc    % Continuous response function handle
        shockResponseFnc   % Shock response function handle
        
        % ----------- %
        % Objects
        % ----------- %
        history         % Observation object (list of performance values)

    end
    
    properties (Dependent)
        % timeLastMaintenance     % Time last maintenance
        performance             % Current performance
        time                    % Current time
    end
    
    events
        timeUpdate
    end
    
    methods
        %% Constructor
        
        
        %{
        
            Input
                
            Output
                
        %}
        function thisInfrastructure = Infrastructure(progSet)
            import dataComponents.Observation
            import managers.*
            
            % Null, Maximum and Initial performance values
            thisInfrastructure.nullPerf = progSet.returnItemSetting(ItemSetting.NULL_PERF).value;
            thisInfrastructure.maxPerf = progSet.returnItemSetting(ItemSetting.MAX_PERF).value;
            thisInfrastructure.initialPerf = progSet.returnItemSetting(ItemSetting.INITIAL_PERF).value;
            
            % Initial observation
            initialTime = 0;
            thisInfrastructure.history = Observation();
            thisInfrastructure.history.register(initialTime, thisInfrastructure.initialPerf);
            
            % Continuous response function
            fnc = progSet.returnItemSetting(ItemSetting.CONT_RESP_FNC);
            thisInfrastructure.contResponseFnc = fnc.equation;
            
            % Shock response function
            fnc = progSet.returnItemSetting(ItemSetting.SHOCK_RESP_FNC);
            thisInfrastructure.shockResponseFunction = fnc.equation;
            

        end
        
        %% Getter functions
        function p = get.performance(thisInfrastructure)
            p = thisInfrastructure.history.getCurrentValue();   % Last value of history
        end
        
        function t = get.time(thisInfrastructure)
            t = thisInfrastructure.history.getCurrentTime();    % Last value of time
        end
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        
        

        function performance = getPerformance(thisInfrastructure)
        %{
        
            Input
                
            Output
                
        %}
            performance = thisInfrastructure.performance;
        end
        
        
        function obs = getObservation(thisInfra)
        %{
        
            Input
                
            Output
                
        %}
            
            import dataComponents.Observation
            
            obs = Observation(thisInfra.time, thisInfra.performance);
        end
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------
        % ----------------------------------------------------------------
        
        
        %{
        * This method must be called BEFORE a jump action is applied!
        
            Input
                
            Output
                
        %}
        function setTime(thisInfra, newTime)
            
            if newTime > thisInfra.time
                currentTime =  thisInfra.time;
                currentPerf = thisInfra.performance;
                
                deltaTime = newTime - currentTime;
                f = (deltaTime/thisInfra.TIMESTEP);
                n = max([3,floor(f)]);
                
                [t,v] = ode45(thisInfra.detRate, linspace(currentTime, newTime, n), currentPerf);
                
                % Truncate performance values lower than null perf
                v(v<thisInfra.nullPerf) = thisInfra.nullPerf;
                
                n = length(t);
                
                for i=2:n
                    thisInfra.history.register(t(i), v(i));
                end
            end
        end
        
        
        function evolve(thisInfra, t, v)
            n = length(t);
            
            for i = 2:n
                thisInfra.history.register(t(i), v(i));
            end
        end
        
        
        %{
        
            Input
                
            Output
                
        %}
        function registerObservation(thisInfrastructure, time, perf)
            
            %thisInfrastructure.setTime(time);
            thisInfrastructure.history.register(time, perf);
            
        end
            
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
        %{
        
            Input
                time: [class double] Time value at which the
                performance of Infrastructure is to be calculated
        
            Output
                performance: [class double] Value of performance
                calculated.
        %}
        function perf = solvePerformanceForTime(thisInfra, time)
            error('hola')
            
            l = length(time);
            assert(l==1, 'The time parameter must be a scalar')
            
            currentTime = thisInfra.time;
            currentPerf = thisInfra.performance;
            
            if time > currentTime
                [t,v] = ode45(thisInfra.detRate, [currentTime, time], currentPerf);
                perf = v(end);
                
                % Truncate performance values lower than null perf
                if perf < thisInfra.nullPerf
                    perf = thisInfra.nullPerf;
                end
                
            elseif time == currentTime
                perf = currentPerf;
            else
                % TODO Implement this if necessary
                error('This has not been implemented yet!')
            end

        end
        
        
        %{
        * This method returns the value of the deterioration function for a
        given value of time.
        
            Input
                performance: [class double]
        
            Output
                time: [class double]
        %}
        function time = solveTimeForPerformance(thisInfrastructure, performance)
            % TODO Implement this if necessary
            error('This has not been implemented yet!')
        end
        
    end
end

%% Auxiliary functions

