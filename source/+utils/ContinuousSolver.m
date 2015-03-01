classdef ContinuousSolver
    %CONTINUOUSSOLVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        
        function y = solveFutureState(fnc, t0, tf, y0)
        %{
        
            Input
                
            Output
                
        %}
            assert(length(tf)==1, 'The time parameter must be a scalar')
            assert(t0<tf, 'Time tf must be greater than t0')
            
            if tf > t0
                [t,v] = ode45(fnc, [t0, tf], y0);
                y = v(end);
                
            elseif time == t0
                y = y0;
            end
        end
        
        
    end
    
end

