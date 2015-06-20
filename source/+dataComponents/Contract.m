%{
# PURPOSE

The contract class contains information that define a contract. It is meant
to the accessible to all players.

%}

classdef Contract < matlab.mixin.Copyable
    
    properties (GetAccess = public, SetAccess = protected)
        contractDuration 	% Mission time (years)
        initialPerf         % Initial perf of infrastructure: Assummed to be equal to MAX_PERF
        perfThreshold       % Minimum perf required by principal
        revRateFnc          % Function handle of revenue rate
        fare                % Unitary cost of infrastructure usage
        paymentSchedule     % Government contributions Array[nx2] --> [time value]
        penaltyStrategy     % Penalty policy (Strategy object)
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Contract(progSet, conDur, contributions, ...
                revRateFnc, perfThreshold, fare)
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
            
            % Revenue rate function
            self.revRateFnc = revRateFnc;
            
            % Performance threshold
            self.perfThreshold = perfThreshold;
            
            % Fare
            self.fare = fare;
            
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
            
            ps = contributions;
            
            % Add agent's investment transaction
            ps.addTransaction(0, investment, Transaction.INVESTMENT);
            
            % Update contract's payment schedule
            self.paymentSchedule = ps;
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

