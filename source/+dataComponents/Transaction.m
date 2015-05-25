classdef Transaction < handle
    % A transaction is a transfer of money between emitter and receiver
    
    properties (Constant, Hidden = true)
        EMITTER = 'EMITTER'
        RECEIVER = 'RECEIVER'
        
        % Types of cash flow/actions
        INVESTMENT = 'INVESTMENT'
        CONTRIBUTION = 'CONTRIBUTION'
        MAINTENANCE = 'MAINTENANCE'
        INSPECTION = 'INSPECTION'
        PENALTY = 'PENALTY'
        FINAL = 'FINAL'
    end
    
    properties
        time        % [class double] Time of transaction:
        value       % [class double] Value of transaction:  Always positive
        type        % String
        emitter     % [class string] ID of emitter
        receiver    % [class string] ID of receiver
        
        confirmationEmitter = false
        confirmationReceiver = false
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function thisTran = Transaction(t, v, tp)
        %{
        
            Input
                t: [class double] Time of transaction
            
                v: [class double] Value of transaction. Always positive
                from emitter to receiver
            
                tp: [class string] Type of transaction. See constants
                Transaction class.
            
            Output
                
        %}
            import dataComponents.Transaction
            import managers.Information
            
            switch tp
                case Transaction.INVESTMENT
                    em = Information.AGENT;
                    r = [];
                
                case Transaction.CONTRIBUTION
                    em = Information.PRINCIPAL;
                    r = Information.AGENT;
                    
                case Transaction.MAINTENANCE
                    em = Information.AGENT;
                    r = [];
                    
                case Transaction.INSPECTION
                    em = Information.PRINCIPAL;
                    r = [];
                    
                case Transaction.PENALTY
                    em = Information.AGENT;
                    r = Information.PRINCIPAL;
                
                case Transaction.FINAL
                    em = Information.AGENT;
                    r = Information.PRINCIPAL;
                    v = 0;
            end
            
            thisTran.time = t;
            thisTran.value = v;
            thisTran.type = tp;
            thisTran.emitter = em;
            thisTran.receiver = r;
            
            if isempty(em)
                thisTran.completedEmitterSide();
            end
            
            if isempty(r)
                thisTran.completedReceiverSide();
            end
        end
        
        
		%% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
        
        function ve = getValueEmitter(thisTran)
        %{
        * 
        
            Input
                
            Output
                
        %}
            ve = - thisTran.value;
        end
        
        
        function vr = getValueReceiver(thisTran)
        %{
        * 
        
            Input
                
            Output
                
        %}
            vr = thisTran.value;
        end
        
        
        function [em, r] = returnEmitterReceiver(thisTran, thePrincipal, theAgent)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            if ~isempty(thisTran.emitter)
                switch thisTran.emitter
                    case Information.PRINCIPAL
                        em = thePrincipal;
                    case Information.AGENT
                        em = theAgent;
                end
            else
                em = [];
            end
            
            
            if ~isempty(thisTran.receiver)
                switch thisTran.receiver
                    case Information.PRINCIPAL
                        r = thePrincipal;
                    case Information.AGENT
                        r = theAgent;
                end
            else
                r = [];
            end
        end
        
        
        function [value, role] = getPayoffValue(thisTran, thePlayer)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            switch thePlayer.NAME
                case thisTran.emitter
                    value = thisTran.getValueEmitter();
                    role = thisTran.EMITTER;
                case thisTran.receiver
                    value = thisTran.getValueReceiver();
                    role = thisTran.RECEIVER;
            end
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function completedEmitterSide(thisTran)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            thisTran.confirmationEmitter = true;
        end
        
        
        function completedReceiverSide(thisTran)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            thisTran.confirmationReceiver = true;
        end
        
        
        function confirmExecutionBy(thisTran, role)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            switch role
                case thisTran.EMITTER
                    thisTran.completedEmitterSide();
                case thisTran.RECEIVER
                    thisTran.completedReceiverSide;
                otherwise
                    warning('The role does not coincide with neither emitter nor reciever')
            end
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function answer = isExecuted(thisTran)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            answer = thisTran.confirmationEmitter && thisTran.confirmationReceiver;
        end
        
        
    end
end

