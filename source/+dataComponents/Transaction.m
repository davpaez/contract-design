classdef Transaction < handle
    %TRANSACTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Hidden = true)
        
        % Types of cash flow/actions
        CONTRIBUTION = 'CONTRIBUTION'
        INVESTMENT = 'INVESTMENT'
        MAINTENANCE = 'MAINTENANCE'
        INSPECTION = 'INSPECTION'
        PENALTY = 'PENALTY'
        FINAL = 'FINAL'
    end
    
    properties
        time        % [class double] Time of transaction:
        value       % [class double] Value of transaction:  Always positive
        emitter     % [class string] ID of emitter
        receiver    % [class string] ID of receiver
        
        pending = true
    end
    
    methods
        
        function thisTran = Transaction(t, v, em, r)
        %{
        
            Input
                t: [class double] Time of transaction
            
                v: [class double] Value of transaction. Always positive
                from emitter to receiver
            
                em: [class string] ID of emitter
            
                r: [class string] ID of receiver
            Output
                
        %}
            thisTran.time = t;
            thisTran.value = v;
            thisTran.emitter = em;
            thisTran.receiver = r;
        end
        
        function answer = isPending(thisTran)
            answer = thisTran.pending;
        end
        
        function setAsCompleted(thisTran)
            thisTran.pending = false;
        end
    end
end

