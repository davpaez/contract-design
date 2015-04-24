classdef Contract < matlab.mixin.Copyable
    
    properties (GetAccess = public, SetAccess = protected)
        contractDuration 	% Mission time (years)
        initialPerf         % Initial performance of infrastructure: Assummed to be equal to MAX_PERF
        perfThreshold       % Minimum performance required by principal
        revenueRate             % Function handle
        investment          % Land purchase and construction cost
        paymentSchedule        % Government contributions Array[nx2] --> [time value]
        maxSumPenalties     % Maximum possible penalty
        penaltyAction       % Penalty policy (Strategy object)
    end
    
    methods
        %% Constructor
        function thisContract = Contract(progSet, ...
                conDur, paymentSchedule, revRateFnc, perfThreshold, penStrat)
            
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
            action = progSet.returnItemSetting(ItemSetting.PEN_POLICY);
            thisContract.penaltyAction = action.returnCopy();
            
            % Penalty policy strategy
            thisContract.penaltyStrategy = penStrat;
            
        end
        
        %% Getter functions
        
        %% Regular methods
        
        % ---------- Accessor methods ------------------------------------
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function tm = getContractDuration(thisContract)
            tm = thisContract.contractDuration;
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function initPerf = getInitialPerformance(thisContract)
            initPerf = thisContract.initialPerf;
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function obs = getInitialPerfObs(thisContract)
            initPerf = thisContract.initialPerf;
            
            obs = struct();
            obs.value = initPerf;
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function r = getRevenueRate(thisContract)
            r = thisContract.revenueRate;
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function inv = getInvestment(thisContract)
            inv = thisContract.investment;
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function c = getContribution(thisContract)
            c = thisContract.contribution;
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function maxPenalty = getMaxSumPenalties(thisContract)
            maxPenalty = thisContract.maxSumPenalties();
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function perfThreshold =getPerfThreshold(thisContract)
            perfThreshold = thisContract.perfThreshold;
        end
        
        % ---------- Mutator methods -------------------------------------
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function updateTm(thisContract, newTm)
            thisContract.tm = newTm;
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function updateThreshold(thisContract, newThreshold)
            if newThreshold >= 100
                error('Threshold must be less than 100')
            end
            thisContract.thresholdPerf = newThreshold;
        end
        
        % ---------- Informative methods ---------------------------------
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function answer = isViolation(thisContract, currentPerf)
            if currentPerf < thisContract.getThresholdPerf()
                answer = true;
            else
                answer = false;
            end
        end
        
        
        %{
        * 
        
            Input
                
            Output
                
        %}
        function [time, value] = getNextPayment(thisContract, currentTime)
            index = find(thisContract.paymentSchedule >= currentTime, 1, 'first');
            
            if ~isempty(index)
                time = thisContract.paymentSchedule(index, 1);
                value = thisContract.paymentSchedule(index, 2);
            end
            
        end
        
    end
    
end

