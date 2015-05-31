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
        
        function self = Transaction(t, v, tp)
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
            
            self.time = t;
            self.value = v;
            self.type = tp;
            self.emitter = em;
            self.receiver = r;
            
            if isempty(em)
                self.completedEmitterSide();
            end
            
            if isempty(r)
                self.completedReceiverSide();
            end
        end
        
        
		%% ::::::::::::::::::::    Accessor methods    ::::::::::::::::::::
        % *****************************************************************
        
        function ve = getValueEmitter(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            ve = - self.value;
        end
        
        
        function vr = getValueReceiver(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            vr = self.value;
        end
        
        
        function [em, r] = returnEmitterReceiver(self, thePrincipal, theAgent)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            import managers.Information
            
            if ~isempty(self.emitter)
                switch self.emitter
                    case Information.PRINCIPAL
                        em = thePrincipal;
                    case Information.AGENT
                        em = theAgent;
                end
            else
                em = [];
            end
            
            
            if ~isempty(self.receiver)
                switch self.receiver
                    case Information.PRINCIPAL
                        r = thePrincipal;
                    case Information.AGENT
                        r = theAgent;
                end
            else
                r = [];
            end
        end
        
        
        function [value, role] = getPayoffValue(self, thePlayer)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            switch thePlayer.NAME
                case self.emitter
                    value = self.getValueEmitter();
                    role = self.EMITTER;
                case self.receiver
                    value = self.getValueReceiver();
                    role = self.RECEIVER;
                otherwise
                    value = 0;
                    role = [];
            end
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function completedEmitterSide(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            self.confirmationEmitter = true;
        end
        
        
        function completedReceiverSide(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            self.confirmationReceiver = true;
        end
        
        
        function confirmExecutionBy(self, role)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            switch role
                case self.EMITTER
                    self.completedEmitterSide();
                case self.RECEIVER
                    self.completedReceiverSide;
                otherwise
                    warning('The role does not coincide with neither emitter nor reciever')
            end
        end
        
        
        %% ::::::::::::::::::    Informative methods    :::::::::::::::::::
        % *****************************************************************
        
        function answer = isExecuted(self)
        %{
        * 
        
            Input
                
            Output
                
        %}
            
            answer = self.confirmationEmitter && self.confirmationReceiver;
        end
        
        
    end
end

