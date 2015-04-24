classdef Event < matlab.mixin.Copyable
    
    properties (Constant, Hidden = true)
        INIT        = 'INIT'
        CONTRIBUTION = 'CONTRIBUTION'
        INSPECTION  = 'INSPECTION'
        VOL_MAINT   = 'VOL_MAINT'
        MAND_MAINT  = 'MAND_MAINT'
        DETECTION   = 'DETECTION'
        SHOCK       = 'SHOCK'
        FINAL       = 'FINAL'
    end
    
    properties (GetAccess = protected, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        time
        type
        observation
        transaction
        
    end
    
    
    methods
        %% Constructor
        
        
        %{
        * 
		
            Input
                
            Output
                
        %}
        function thisEvent = Event(t, tp, obs, trn)
            
            thisEvent.time = t;
            thisEvent.type = tp;
            thisEvent.observation = obs;
            thisEvent.transaction = trn;
            
        end
        
        %% Getter funcions
        
        
        
        %% Regular methods
        
        % ----------------------------------------------------------------
        % ---------- Accessor methods ------------------------------------
        % ----------------------------------------------------------------
		
		  
		
        %{
        *  
            Input
                
            Output
                
        %}

        
        %{
        * 
        
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