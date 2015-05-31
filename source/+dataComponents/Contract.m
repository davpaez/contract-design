classdef Contract < matlab.mixin.Copyable
    
    properties (GetAccess = public, SetAccess = protected)
        contractDuration 	% Mission time (years)
        initialPerf         % Initial perf of infrastructure: Assummed to be equal to MAX_PERF
        perfThreshold       % Minimum perf required by principal
        revenueRate             % Function handle
        %investment          % Land purchase and construction cost
        paymentSchedule        % Government contributions Array[nx2] --> [time value]
        maxSumPenalties     % Maximum possible penalty
        penaltyStrategy       % Penalty policy (Strategy object)
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Contract(progSet, conDur, perfThreshold, ...
                contributions, revRateFnc)
        %{
        * 
        
            Input
                
                ps: [nx2 array] time and value of payments from principal
                to agent
            Output
                
        %}
            
            import managers.*
            import dataComponents.Transaction
            import dataComponents.PaymentSchedule
            
            % Contract duration
            self.contractDuration = conDur;
            
            % revenueRate
            self.revenueRate = revRateFnc;
            
            % Performance threshold
            self.perfThreshold = perfThreshold;
            
            % Initial performance
            self.initialPerf = progSet.returnItemSetting(ItemSetting.INITIAL_PERF).value;
            
            % Penalty policy
            faculty = progSet.returnItemSetting(ItemSetting.PEN_POLICY);
            self.penaltyStrategy = faculty.getSelectedStrategy();
            
            % Create payment schedule object: Investment and Contributions
            inv = progSet.returnItemSetting(ItemSetting.INV).value;
            self.createPaymentSchedule(inv, contributions);
        end
        
        
		%% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
        
        function obs = getInitialPerfObs(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            initPerf = self.initialPerf;
            
            obs = struct();
            obs.value = initPerf;
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function createPaymentSchedule(self, investment, contributions)
        %{
        * 
        
            Input
                inv: [double] Investment
                contrib: [nx2 array] time and value of payments from principal
                to agent
            
            Output
                
        %}
            import dataComponents.PaymentSchedule
            import dataComponents.Transaction
            
            self.paymentSchedule = PaymentSchedule();
            
            % Investment
            self.paymentSchedule.addTransaction(...
                0, ...
                investment, ...
                Transaction.INVESTMENT);
            
            % ContributionS
            numberPayments = size(contributions, 1);
            for i=1:numberPayments
                self.paymentSchedule.addTransaction(...
                    contributions(i,1), ...
                    contributions(i,2), ...
                    Transaction.CONTRIBUTION);
            end
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function answer = isViolation(self, currentPerf)
        %{
        * 
        
            Input
                
            Output
                
        %}
            if currentPerf < self.getThresholdPerf()
                answer = true;
            else
                answer = false;
            end
        end
        
        
        function [time, value] = getNextPayment(self, currentTime)
        %{
        * 
        
            Input
                
            Output
                
        %}
            index = find(self.paymentSchedule >= currentTime, 1, 'first');
            
            if ~isempty(index)
                time = self.paymentSchedule(index, 1);
                value = self.paymentSchedule(index, 2);
            end
            
        end
        
        
    end
    
end

