classdef Contract < matlab.mixin.Copyable
    %CONTRACT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        contractDuration 	% Mission time (years)
        initialPerf         % Initial performance of infrastructure: Assummed to be equal to MAX_PERF
        perfThreshold       % Minimum performance required by principal
        revenue             % Revenue: tolls
        investment          % Land purchase and construction cost
        contribution        % Government contributions [nx2] --> [value time]
        maxSumPenalties     % Maximum possible penalty
        penaltyAction       % Penalty policy (Strategy object)
    end
    
    methods
        %% Constructor
        function thisContract = Contract(progSet)
            
            import managers.*
            
            % Contract duration
            thisContract.contractDuration = progSet.returnItemSetting(ItemSetting.CON_DUR).value;
            
            % Initial performance
            thisContract.initialPerf = progSet.returnItemSetting(ItemSetting.INITIAL_PERF).value;
            
            % Performance threshold
            thisContract.perfThreshold = progSet.returnItemSetting(ItemSetting.PERF_THRESH).value;
            
            % Revenue
            thisContract.revenue = progSet.returnItemSetting(ItemSetting.REV).value;
            
            % Investment
            thisContract.investment = progSet.returnItemSetting(ItemSetting.INV).value;
            
            % Contribution
            thisContract.contribution = progSet.returnItemSetting(ItemSetting.CONTRIB).value;
            
            % TODO: Who is making sure that this maximum is respected?
            % Answer: So far the penalty policy strategies.

            % Maximum sum of penalties
            thisContract.maxSumPenalties = progSet.returnItemSetting(ItemSetting.MAX_SUM_PEN).value;
            
            % Penalty policy
            action = progSet.returnItemSetting(ItemSetting.PEN_POLICY);
            thisContract.penaltyAction = returnCopyAction(action);
            
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
        function r = getRevenue(thisContract)
            r = thisContract.revenue;
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
        
    end
    
end

