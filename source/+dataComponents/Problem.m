classdef Problem < matlab.mixin.Copyable
    % This class saves useful public information
    % TODO This class may not be necessary
    
    properties
        discountRate
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function thisProblem = Problem(progSettings)
        %{
        
            Input
                
            Output
                
        %}
            % Discount rate
            import managers.ItemSetting

            thisProblem.discountRate = progSettings.returnItemSetting(ItemSetting.DISC_RATE).value;
        end
        
        
    end
end

