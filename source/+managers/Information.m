classdef Information
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Hidden = true)
        
		
		
		%{
		----  These constants seem to be unnecesary  ----
		--------- Delete if not needed ------------------
		
        % Nature of decision variables
        TIME                = 'TIME'
        PERFORMANCE         = 'PERFORMANCE'
        MONEY               = 'MONEY'
        
        
        % Types of actions
        INSPECTION  = 'INSPECTION'
        VOL_MAINT   = 'VOL_MAINT'
        MAND_MAINT  = 'MAND_MAINT'
        SHOCK       = 'SHOCK'
		%}
		
		
        
        % Specific type of information related to each action available to
        % a player of the game
            % Contract offer Action
            CONTRACT_DURATION = 'CONTRACT_DURATION'
            PAYMENT_SCHEDULE = 'PAYMENT_SCHEDULE'
            REVENUE_RATE_FUNC = 'REVENUE_RATE_FUNC'
            PERFORMANCE_THRESHOLD = 'PERFORMANCE_THRESHOLD'
            PENALTY_FEE_STRAT = 'PENALTY_FEE_STRAT'
            
            % Inspection Action
            TIME_INSPECTION     = 'TIME_INSPECTION'

            % Voluntary Maintenance Action
            TIME_VOL_MAINT      = 'TIME_VOL_MAINT'
            PERF_VOL_MAINT      = 'PERF_VOL_MAINT'

            % Mandatory Maintenance Action
            PERF_MAND_MAINT     = 'PERF_MAND_MAINT'

            % Shock Action
            TIME_SHOCK          = 'TIME_SHOCK'
            FORCE_SHOCK         = 'FORCE_SHOCK'
            PERF_SHOCK          = 'PERF_SHOCK'
            
            % Penalty
            VALUE_PENALTY_FEE   = 'VALUE_PENALTY_FEE'
        
        % Information related with events of the game
            

    end
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        
        % ----------- %
        % Objects
        % ----------- %
        
        
    end
    
    methods(Static)
        
        function answer = isValid_TypeInfo(str)
            import managers.Information
            
            validTypes = {  Information.CONTRACT_DURATION, ...
                Information.PAYMENT_SCHEDULE, ...
                Information.REVENUE_RATE_FUNC, ...
                Information.PERFORMANCE_THRESHOLD, ...
                Information.PENALTY_FEE_STRAT, ...
                Information.TIME_INSPECTION, ...
                Information.TIME_VOL_MAINT, ...
                Information.PERF_VOL_MAINT, ...
                Information.PERF_MAND_MAINT, ...
                Information.TIME_SHOCK, ...
                Information.FORCE_SHOCK, ...
                Information.PERF_SHOCK, ...
                Information.VALUE_PENALTY_FEE};
             
             answer = any(strcmp(validTypes, str));
        end
    end
    
    methods
        %% Constructor
        
        %% Getter functions
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
        
        %{
        
            Input
                
            Output
                
        %}
        
        
        
        % ----------------------------------------------------------------
        % ---------- Mutator methods -------------------------------------
        % ----------------------------------------------------------------
        
        
        
        % ----------------------------------------------------------------
        % ---------- Informative methods ---------------------------------
        % ----------------------------------------------------------------
        
        
    end
    
end