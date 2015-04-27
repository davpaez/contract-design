classdef Problem < matlab.mixin.Copyable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        discountRate
        
        
    end
    
    methods
        
        function thisProblem = Problem(progSettings)
        %{
        
            Input
                
            Output
                
        %}
            % Discount rate
            dicountRateId = managers.ItemSetting.DISC_RATE;
            thisProblem.discountRate = progSettings.returnItemSetting(dicountRateId).value;
            
        end
        
        function rate = getDiscountRate(thisProblem)
        %{
        
            Input
                
            Output
                
        %}
            rate = thisProblem.discountRate;
        end
        
    end
    
end

