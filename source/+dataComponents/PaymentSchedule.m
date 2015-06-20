classdef PaymentSchedule < handle
    % Collection of payments between emitter and receiver
    
    properties
        listTransactions
        allExecuted = false
        isSorted = false
    end
    
    methods
        
        %% ::::::::::::::::::    Constructor method    ::::::::::::::::::::
        % *****************************************************************
        
        function self = PaymentSchedule()
        %{
        *   
            Input
                
            Output
                
        %}
            self.listTransactions = cell(0,1);
            
        end
        
        
        %% ::::::::::::::::::::    Mutator methods    :::::::::::::::::::::
        % *****************************************************************
        
        function addTransaction(self, time, value, type)
        %{
        * Adds a payment schedule between a pair (emitter, receiver)
            
            If the arguments emitter and receiver have length > 1 then each
            transaction will be associated with a particular pair
            (emitter,receiver). If emitter and receiver have lenght = 1,
            then all transactions will be associated with the same pair
            (emitter,receiver)
            
            Input
                
            Output
                
        %}
            import dataComponents.Transaction
            
            self.isSorted = false;
            self.listTransactions{end+1} = Transaction(time, value, type);
        end
        
        
        function buildFromVectors(self, timeVector, valueVector, type)
        %{
        *   
            Input
                
            Output
                
        %}
            assert(length(timeVector) == length(valueVector))
            
            n = length(timeVector);
            
            for i=1:n
                self.addTransaction(timeVector(i), valueVector(i), type);
            end
        end
        
        
        function nextTransaction = getNextTransaction(self)
        %{
        * 
        
            Input
            
            Output
                
        %}
            
            if ~self.isSorted
                self.sortTransactions()
            end
            
            if self.allExecuted == true
                nextTransaction = [];
            else
                import dataComponents.Transaction
                
                n = length(self.listTransactions);
                
                transactionPending = false;
                
                for i=1:n
                    currentTran = self.listTransactions{i};
                    if ~currentTran.isExecuted()
                        nextTransaction = currentTran;
                        transactionPending = true;
                        break
                    end
                end
                
                if transactionPending == false
                    nextTransaction = [];
                    self.setAsExecuted();
                end
            end
        end
        
        
        function setAsExecuted(self)
            self.allExecuted = true;
        end
        
        
        function sortTransactions(self)
            
            assert(~isempty(self.listTransactions))
            
            n = length(self.listTransactions);
            t = zeros(1,n);
            for i=1:n
                t(i) = self.listTransactions{i}.time;
            end
            
            unsorted = self.listTransactions;
            self.listTransactions = cell(n,1);
            
            [~, k] = sort(t);
            
            self.listTransactions = unsorted(k);
            
            self.isSorted = true;
        end
        
    end
end

