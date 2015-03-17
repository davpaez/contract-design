classdef VolMaintStrategy < managers.Strategy
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
        
        function thisStrategy = VolMaintStrategy()
            
            thisStrategy@managers.Strategy();
            
            import managers.*
            import behavior.agent.*
            
			% Set type action
			thisStrategy.typeAction = Action.VOL_MAINT;
            
            % One decision variable: Time of volMaint, PerfGoal volMaint
            thisStrategy.setDecisionVars_Number(2);
            
            % Nature of decision vars
            thisStrategy.setDecisionVars_TypeInfo({ Information.TIME_VOL_MAINT , ...
                Information.PERF_VOL_MAINT });
            
        end
    end
    
end