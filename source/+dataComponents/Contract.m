classdef Contract < matlab.mixin.Copyable
    % 
    properties (GetAccess = public, SetAccess = protected)
        contractDuration 	% Mission time (years)
        initialPerf         % Initial perf of infrastructure: Assummed to be equal to MAX_PERF
        perfThreshold       % Minimum perf required by principal
        revenueRate             % Function handle
        investment          % Land purchase and construction cost
        paymentSchedule        % Government contributions Array[nx2] --> [time value]
        maxSumPenalties     % Maximum possible penalty
        penaltyStrategy       % Penalty policy (Strategy object)
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function thisContract = Contract(progSet, conDur, perfThreshold, ...
                paymentSchedule, revRateFnc, penStrat)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            import managers.*
            
            % Contract duration
            thisContract.contractDuration = conDur;
            
            % Contribution
            thisContract.paymentSchedule = paymentSchedule;
            
            % Revenue
            thisContract.revenue = revRateFnc;
            
            % Performance threshold
            thisContract.perfThreshold = perfThreshold;
            
            % Initial performance
            thisContract.initialPerf = progSet.returnItemSetting(ItemSetting.INITIAL_PERF).value;

            % Investment
            thisContract.investment = progSet.returnItemSetting(ItemSetting.INV).value;
            
            % Penalty policy
            strat = progSet.returnItemSetting(ItemSetting.PEN_POLICY);
            thisContract.penaltyStrategy = strat.returnCopy();
            
            % Penalty policy strategy
            thisContract.penaltyStrategy = penStrat;
            
        end
        
        
		%% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
        
        function obs = getInitialPerfObs(thisContract)
        %{
        * 
        
            Input
                
            Output
                
        %}
            initPerf = thisContract.initialPerf;
            
            obs = struct();
            obs.value = initPerf;
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function answer = isViolation(thisContract, currentPerf)
        %{
        * 
        
            Input
                
            Output
                
        %}
            if currentPerf < thisContract.getThresholdPerf()
                answer = true;
            else
                answer = false;
            end
        end
        
        
        function [time, value] = getNextPayment(thisContract, currentTime)
        %{
        * 
        
            Input
                
            Output
                
        %}
            index = find(thisContract.paymentSchedule >= currentTime, 1, 'first');
            
            if ~isempty(index)
                time = thisContract.paymentSchedule(index, 1);
                value = thisContract.paymentSchedule(index, 2);
            end
            
        end
        
        
    end
    
end

