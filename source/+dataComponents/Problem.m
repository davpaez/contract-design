classdef Problem < matlab.mixin.Copyable
    % This class saves useful public information
    % TODO This class may not be necessary
    
    properties
        discountRate
        demandFnc
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

            item = progSettings.returnItemSetting(ItemSetting.DISC_RATE);
            self.discountRate = item.value;
            
            item = progSettings.returnItemSetting(ItemSetting.DEMAND_FNC);
            self.demandFnc = item.equation;
            
            
        end
        
        
    end
end

