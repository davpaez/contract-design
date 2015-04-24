classdef PaymentSchedule < handle
    
    properties
        listTransactions
    end
    
    methods
        
        function thisPaymentSch = PaymentSchedule()
        %{
        *   
            Input
                
            Output
                
        %}
            
            thisPaymentSch.listTransactions = cell(0,1);
            
        end
        
        function addTransaction(thisPaySch, time, value, type, emitter, receiver)
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
            
            thisPaySch.listTransactions{end+1} = Transaction(time, value, type, emitter, receiver);

        end
        
        function nextTransaction = getNextTransaction(thisPaySch)
            n = length(thisPaySch.listTransactions);
            
            for i=1:n
                currentTran = thisPaySch.listTransactions{i};
                if currentTran.isPending()
                    nextTransaction = currentTran;
                    break
                end
            end
        end
        
        
        
    end
    
end

