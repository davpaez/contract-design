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
    
    properties (GetAccess = public, SetAccess = protected)
        % ----------- %
        % Attributes
        % ----------- %
        
        time
        type % One of the constant attributes of Event class
        observation
        transaction
        
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Event(t, tp, obs, trn)
        %{
        * 
		
            Input
                
            Output
                
        %}
            self.time = t;
            self.type = tp;
            self.observation = obs;
            self.transaction = trn;
            
        end
		
        
    end
end