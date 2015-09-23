classdef Problem < matlab.mixin.Copyable
    % This class saves useful public information
    
    properties
        discountRate
        demandFnc
        timeRes
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = Problem(progSettings)
        %{
        
            Input
                
            Output
                
        %}
            % Discount rate
            import managers.ItemSetting
            
            item = progSettings.returnItemSetting(ItemSetting.DEMAND_FNC);
            self.demandFnc = item.equation;
            
            item = progSettings.returnItemSetting(ItemSetting.TIME_RES);
            self.timeRes = item.value;
        end
        
        
    end
end

