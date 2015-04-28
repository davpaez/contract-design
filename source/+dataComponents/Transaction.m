classdef Transaction < handle
    % A transaction is a transfer of money between emitter and receiver
    
    properties (Constant, Hidden = true)
        EMITTER = 'EMITTER'
        RECEIVER = 'RECEIVER'
        
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
        type        % String
        emitter     % [class string] ID of emitter
        receiver    % [class string] ID of receiver
        
        confirmationEmitter = false
        confirmationReceiver = false
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function thisTran = Transaction(t, v, tp, em, r)
        %{
        
            Input
                t: [class double] Time of transaction
            
                v: [class double] Value of transaction. Always positive
                from emitter to receiver
            
                em: [class string] ID of emitter
            
                r: [class string] ID of receiver
            Output
                
        %}
            % Check that at least one party (emitter or receiver) is passed
            assert(~isempty(em) || ~isempty(r) == true, ...
                'At least one (emitter or receiver) must be non-empty')
            
            % Check that emitter is different from receiver
            assert(strcmp(em,r) == false, ...
                'The emitter and the receiver must be different')
            
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
                    thisTran.confirmationEmitter = true;
                case thisTrans.RECEIVER
                    thisTran.confirmationReceiver = true;
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

