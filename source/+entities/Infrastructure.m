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
        performance             % Current performance
        time                    % Current time
    end
    
    events
        timeUpdate
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Infrastructure(progSet)
        %{
        
            Input
                
            Output
                
        %}
            import dataComponents.ObservationList
            import managers.*
            
            % Null, Maximum and Initial performance values
            self.nullPerf = progSet.returnItemSetting(ItemSetting.NULL_PERF).value;
            self.maxPerf = progSet.returnItemSetting(ItemSetting.MAX_PERF).value;
            self.initialPerf = progSet.returnItemSetting(ItemSetting.INITIAL_PERF).value;
            
            % Initial observation
            initialTime = 0;
            self.history = ObservationList();
            self.history.register(initialTime, self.initialPerf);
            
            % Continuous response function
            fnc = progSet.returnItemSetting(ItemSetting.CONT_RESP_FNC);
            self.contResponseFnc = fnc.equation;
            
            % Shock response function
            fnc = progSet.returnItemSetting(ItemSetting.SHOCK_RESP_FNC);
            self.shockResponseFnc = fnc.equation;
        end
        
        
        %% ::::::::::::::::::::    Getter methods    ::::::::::::::::::::::
        % *****************************************************************
        
        function p = get.performance(self)
            p = self.history.getCurrentValue();   % Last value of history
        end
        
        
        function t = get.time(self)
            t = self.history.getCurrentTime();    % Last value of time
        end
        
        
		%% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************

        function performance = getPerformance(self)
        %{
        
            Input
                
            Output
                
        %}
            performance = self.performance;
        end
        
        
        function obs = getObservation(self)
        %{
        
            Input
                
            Output
                
        %}
            
            import dataComponents.Observation
            
            obs = Observation(self.time, self.performance);
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function setTime(self, newTime)
        %{
        * This method must be called BEFORE a jump action is applied!
        
            Input
                
            Output
                
        %}
            if newTime > self.time
                currentTime =  self.time;
                currentPerf = self.performance;
                
                deltaTime = newTime - currentTime;
                f = (deltaTime/self.TIMESTEP);
                n = max([3,floor(f)]);
                
                [t,v] = ode45(self.detRate, linspace(currentTime, newTime, n), currentPerf);
                
                % Truncate performance values lower than null perf
                v(v<self.nullPerf) = self.nullPerf;
                
                n = length(t);
                
                for i=2:n
                    self.history.register(t(i), v(i));
                end
            end
        end
        
        
        function evolve(self, t, v)
        %{
        * 
            
            Input
                
            Output
                
        %}
            n = length(t);
            
            for i = 2:n
                self.history.register(t(i), v(i));
            end
        end
        
        
        function registerObservation(self, time, perf)
        %{
        *
        
            Input
                
            Output
                
        %}
            %self.setTime(time);
            self.history.register(time, perf);
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function perf = solvePerformanceForTime(self, time)
        %{
        
            Input
                time: [class double] Time value at which the
                performance of Infrastructure is to be calculated
        
            Output
                performance: [class double] Value of performance
                calculated.
        %}
            
            l = length(time);
            assert(l==1, 'The time parameter must be a scalar')
            
            currentTime = self.time;
            currentPerf = self.performance;
            
            if time > currentTime
                [t,v] = ode45(self.detRate, [currentTime, time], currentPerf);
                perf = v(end);
                
                % Truncate performance values lower than null perf
                if perf < self.nullPerf
                    perf = self.nullPerf;
                end
                
            elseif time == currentTime
                perf = currentPerf;
            else
                % TODO Implement this if necessary
                error('This has not been implemented yet!')
            end
        end
        
        
        function time = solveTimeForPerformance(self, performance)
        %{
        * This method returns the value of the deterioration function for a
        given value of time.
        
            Input
                performance: [class double]
        
            Output
                time: [class double]
        %}
            
            % TODO Implement this if necessary
            error('This has not been implemented yet!')
        end
        
        
    end
end