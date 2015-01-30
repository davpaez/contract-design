classdef MandMaintStrategy < managers.Strategy
    %MANDMAINTSTRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
		
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    methods
        
        % Constructor
        
        function thisStrategy = MandMaintStrategy()
            
            thisStrategy@managers.Strategy();
            
            import managers.*
            import behavior.agent.*
            
			% Set type action
			thisStrategy.typeAction = Action.MAND_MAINT;
            
            % One decision variable: PerfGoal mandMaint
            thisStrategy.setDecisionVars_Number(1);
            
            % Nature of decision vars
            thisStrategy.setDecisionVars_TypeInfo({ Information.PERF_MAND_MAINT });
            
        end
    end
    
end