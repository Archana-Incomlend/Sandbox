global class InvoiceRepaidCreateTransactions {
    @InvocableMethod(label='Create Transactions')
    global static void createTransactions(List<CreateTransactionsRequest> requests) {
        for (CreateTransactionsRequest request : requests) {
            createTransactions(request);
        }
        return;
    }
    
    public static void createTransactions(CreateTransactionsRequest request) {
        try
        {
            List<Transaction__c> transactions = new List<Transaction__c> {};
                invoice_finance_deal__c invoice = [SELECT Id, CCY__c, funded_amount__c,
                                                   Actual_Repayment_Amount__c,
                                                   Gross_funder_discount_amount_expected__c,
                                                   Supplier_s_Agent_Commission_amount__c,
                                                   Total_Incomlend_Discount_Commissions__c,
                                                   Actual_supplier_s_Agent_Commission_amt__c,
                                                   Premium_IC_fee_from_from_supplier_disc__c,
                                                   Balance_to_be_credited_to_supplier__c,
                                                   Supplier_Buyer_Map__r.Supplier__c,
                                                   Supplier_Buyer_Map__r.Buyer__c,
                                                   Supplier_Buyer_Map__r.Supplier__r.Agent__c,
                                                   Supplier_Agent__c,
                                                   Actual_Repayment_Received_Date__c, Listing_End__c, Phase__c
                                                   FROM invoice_finance_deal__c WHERE Id = :request.invoiceId];
            
            // Check that Actual_Repayment_Received_Date__c is not empty
            if(invoice.Actual_Repayment_Received_Date__c == null)
                throw new CreateTransactionsException('Actual repayment received date is empty');
            
            // Define accounting period
            ID accountingPeriod = Accounting_Period.lookup(date.today());
            if(accountingPeriod == null)
                throw new CreateTransactionsException('Accounting Period does not exist');
            
            // Fetch Incomlend Operation account and eWallet
            Account incomlendOpp = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend Operations'];
            
            // Create buyer repayment transaction
            // Fetch buyer account and eWallet
            Account buyer = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Id=:invoice.Supplier_Buyer_Map__r.Buyer__c];      
            if(invoice.Actual_Repayment_Amount__c>0){
                if(buyer.eWallets__r == null || buyer.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Buyer\'s eWallet does not exist');
                if(incomlendOpp.eWallets__r == null || incomlendOpp.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Incomlend Operation\'s eWallet does not exist');
                
                // Create FROM buyer transaction
                Transaction__c from_t_br = new Transaction__c();
                from_t_br.accounting_period__c = accountingPeriod;
                from_t_br.eWallet__c = buyer.eWallets__r[0].Id;
                from_t_br.account__c = buyer.Id;
                from_t_br.ccy__c = invoice.CCY__c;
                from_t_br.amount__c = invoice.Actual_Repayment_Amount__c * -1;
                from_t_br.effective_date__c = date.today();
                from_t_br.status__C = 'Confirmed by operations';
                from_t_br.type__c = '03.Invoice Repayment';
                from_t_br.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(from_t_br);
                
                // Create TO Incomlend Operation transaction
                Transaction__c to_t_br = new Transaction__c();
                to_t_br.accounting_period__c = accountingPeriod;
                to_t_br.eWallet__c = incomlendOpp.eWallets__r[0].Id;
                to_t_br.account__c = incomlendOpp.Id;
                to_t_br.ccy__c = invoice.CCY__c;
                to_t_br.amount__c = invoice.Actual_Repayment_Amount__c;
                to_t_br.effective_date__c = date.today();
                to_t_br.status__C = 'Confirmed by operations';
                to_t_br.type__c = '03.Invoice Repayment';
                to_t_br.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(to_t_br);
            }
            
            // Create transaction from Incomlend Supply Discount to Incomlend Operation
            // Fetch Incomlend Supply Discount Account and eWallet
            Account incomlendSD = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend - Supplier Discount'];
            if((invoice.Gross_funder_discount_amount_expected__c+invoice.Supplier_s_Agent_Commission_amount__c) > 0){
                if(incomlendSD.eWallets__r == null || incomlendSD.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Incomlend Supply Discount\'s eWallet does not exist');
                if(incomlendOpp.eWallets__r == null || incomlendOpp.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Incomlend Operation\'s eWallet does not exist');
                
                // Create FROM Incomlend Supply Discount transaction
                Transaction__c from_t_sd = new Transaction__c();
                from_t_sd.accounting_period__c = accountingPeriod;
                from_t_sd.eWallet__c = incomlendSD.eWallets__r[0].Id;
                from_t_sd.account__c = incomlendSD.Id;
                from_t_sd.ccy__c = invoice.CCY__c;
                from_t_sd.amount__c = (invoice.Gross_funder_discount_amount_expected__c + invoice.Supplier_s_Agent_Commission_amount__c) * -1;
                from_t_sd.effective_date__c = date.today();
                from_t_sd.status__C = 'Confirmed by operations';
                from_t_sd.type__c = '06.Transaction Fee';
                from_t_sd.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(from_t_sd);
                
                // Create TO Incomlend Operation transaction
                Transaction__c to_t_sd = new Transaction__c();
                to_t_sd.accounting_period__c = accountingPeriod;
                to_t_sd.eWallet__c = incomlendOpp.eWallets__r[0].Id;
                to_t_sd.account__c = incomlendOpp.Id;
                to_t_sd.ccy__c = invoice.CCY__c;
                to_t_sd.amount__c = (invoice.Gross_funder_discount_amount_expected__c + invoice.Supplier_s_Agent_Commission_amount__c);
                to_t_sd.effective_date__c = date.today();
                to_t_sd.status__C = 'Confirmed by operations';
                to_t_sd.type__c = '06.Transaction Fee';
                to_t_sd.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(to_t_sd);
            }
            
            // Create transaction for each allocation on the invoice
            List<Invoice_Allocation__c> allocationsToUpdate = new List<Invoice_Allocation__c>{};
                List<Invoice_Allocation__c> allocations = [SELECT Id, Allocation_Confirmed_Date__c, amount__c, funder_discount_amount__c, Funder_Agent_Commission_Amount__c, CCY__c, Funder__c, Funder__r.Agent__c, Status__c, eWallet__c
                                                           FROM Invoice_Allocation__c
                                                           WHERE Invoice__c=:request.invoiceId AND Status__c != 'Canceled'];
            // Fetch funder agents account and eWallet
            List<Id> agentIds = new List<Id>{};
                for(Invoice_Allocation__c allocation : allocations){
                    agentIds.add(allocation.Funder__r.Agent__c);
                } 
            List<Account> agents = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Id IN :agentIds];          
            for(Invoice_Allocation__c allocation : allocations)
            {
                if(incomlendOpp.eWallets__r == null || incomlendOpp.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Incomlend Operation\'s eWallet does not exist');
                
                //Update allocation
                allocation.Status__c = 'Repaid invoice deal closed';
                allocationsToUpdate.add(allocation);
                
                // Create funder capital repayment transaction
                // Create FROM Incomlend Operation transaction
                Transaction__c from_t_fcr = new Transaction__c();
                from_t_fcr.accounting_period__c = accountingPeriod;
                from_t_fcr.eWallet__c = incomlendOpp.eWallets__r[0].Id;
                from_t_fcr.account__c = incomlendOpp.Id;
                from_t_fcr.ccy__c = allocation.CCY__c;
                from_t_fcr.amount__c = allocation.amount__c * -1;
                from_t_fcr.effective_date__c = date.today();
                from_t_fcr.status__C = 'Confirmed by operations';
                from_t_fcr.type__c = '04.Invoice Capital Repayment';
                from_t_fcr.Invoice_Allocation__c = allocation.Id;
                from_t_fcr.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(from_t_fcr);
                
                // Create TO funder transaction
                Transaction__c to_t_fcr = new Transaction__c();
                to_t_fcr.accounting_period__c = accountingPeriod;
                to_t_fcr.eWallet__c = allocation.eWallet__c;
                to_t_fcr.account__c = allocation.Funder__c;
                to_t_fcr.ccy__c = allocation.CCY__c;
                to_t_fcr.amount__c = allocation.amount__c;
                to_t_fcr.effective_date__c = date.today();
                to_t_fcr.status__C = 'Confirmed by operations';
                to_t_fcr.type__c = '04.Invoice Capital Repayment';
                to_t_fcr.Invoice_Allocation__c = allocation.Id;
                to_t_fcr.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(to_t_fcr);
                
                // Create funder discount amount transaction
                // Create FROM Incomlend Operation transaction
                Transaction__c from_t_fda = new Transaction__c();
                from_t_fda.accounting_period__c = accountingPeriod;
                from_t_fda.eWallet__c = incomlendOpp.eWallets__r[0].Id;
                from_t_fda.account__c = incomlendOpp.Id;
                from_t_fda.ccy__c = allocation.CCY__c;
                from_t_fda.amount__c = allocation.funder_discount_amount__c * -1;
                from_t_fda.effective_date__c = date.today();
                from_t_fda.status__C = 'Confirmed by operations';
                from_t_fda.type__c = '05.Invoice Discount Amount';
                from_t_fda.Invoice_Allocation__c = allocation.Id;
                from_t_fda.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(from_t_fda);
                
                // Create TO funder transaction
                Transaction__c to_t_fda = new Transaction__c();
                to_t_fda.accounting_period__c = accountingPeriod;
                to_t_fda.eWallet__c = allocation.eWallet__c;
                to_t_fda.account__c = allocation.Funder__c;
                to_t_fda.ccy__c = allocation.CCY__c;
                to_t_fda.amount__c = allocation.funder_discount_amount__c;
                to_t_fda.effective_date__c = date.today();
                to_t_fda.status__C = 'Confirmed by operations';
                to_t_fda.type__c = '05.Invoice Discount Amount';
                to_t_fda.Invoice_Allocation__c = allocation.Id;
                to_t_fda.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(to_t_fda);
                
                // Create funder agent commission transaction
                // Find funder agent (with eWallet)
                Account funder_agent;
                for (Account agent:agents){
                    if(agent.id==allocation.Funder__r.Agent__c){
                        funder_agent = agent;
                        break;
                    } 
                }
                if ( funder_agent != null && allocation.Funder_Agent_Commission_Amount__c != 0)
                {
                    if(funder_agent.eWallets__r == null || funder_agent.eWallets__r.size() == 0)
                        throw new CreateTransactionsException('Funder Agent\'s eWallet does not exist');
                    if(incomlendOpp.eWallets__r == null || incomlendOpp.eWallets__r.size() == 0)
                        throw new CreateTransactionsException('Incomlend Operation\'s eWallet does not exist');
                    
                    // Create FROM Incomlend Operation transaction
                    Transaction__c from_t_fac = new Transaction__c();
                    from_t_fac.accounting_period__c = accountingPeriod;
                    from_t_fac.eWallet__c = incomlendOpp.eWallets__r[0].Id;
                    from_t_fac.account__c = incomlendOpp.Id;
                    from_t_fac.ccy__c = allocation.CCY__c;
                    from_t_fac.amount__c = allocation.Funder_Agent_Commission_Amount__c * -1;
                    from_t_fac.effective_date__c = date.today();
                    from_t_fac.status__C = 'Confirmed by operations';
                    from_t_fac.type__c = '051.Agent Commission on Discount Amount';
                    from_t_fac.Invoice_Allocation__c = allocation.Id;
                    from_t_fac.Invoice_Finance_Deal__c = invoice.Id;
                    transactions.add(from_t_fac);
                    
                    // Create TO funder agent transaction
                    Transaction__c to_t_fac = new Transaction__c();
                    to_t_fac.accounting_period__c = accountingPeriod;
                    to_t_fac.eWallet__c = funder_agent.eWallets__r[0].Id;
                    to_t_fac.account__c = allocation.Funder__r.Agent__c;
                    to_t_fac.ccy__c = allocation.CCY__c;
                    to_t_fac.amount__c = allocation.Funder_Agent_Commission_Amount__c;
                    to_t_fac.effective_date__c = date.today();
                    to_t_fac.status__C = 'Confirmed by operations';
                    to_t_fac.type__c = '051.Agent Commission on Discount Amount';
                    to_t_fac.Invoice_Allocation__c = allocation.Id;
                    to_t_fac.Invoice_Finance_Deal__c = invoice.Id;
                    transactions.add(to_t_fac);             
                }
            }
            
            // Create transaction for Incomlend founder discount commission
            // Fetch Incomlend fees Account and eWallet
            Account incomlendFees = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend - fees'];
            if(invoice.Total_Incomlend_Discount_Commissions__c > 0){
                if(incomlendFees.eWallets__r == null || incomlendFees.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Incomlend Fees\'s eWallet does not exist');
                if(incomlendOpp.eWallets__r == null || incomlendOpp.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Incomlend Operation\'s eWallet does not exist');
                
                // Create FROM Incomlend Operation transaction
                Transaction__c from_t_fdc = new Transaction__c();
                from_t_fdc.accounting_period__c = accountingPeriod;
                from_t_fdc.eWallet__c = incomlendOpp.eWallets__r[0].Id;
                from_t_fdc.account__c = incomlendOpp.Id;
                from_t_fdc.ccy__c = invoice.CCY__c;
                from_t_fdc.amount__c = invoice.Total_Incomlend_Discount_Commissions__c * -1;
                from_t_fdc.effective_date__c = date.today();
                from_t_fdc.status__C = 'Confirmed by operations';
                from_t_fdc.type__c = '052.discount amount fees';
                from_t_fdc.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(from_t_fdc);
                
                // Create TO Incomlend fees transaction
                Transaction__c to_t_fdc = new Transaction__c();
                to_t_fdc.accounting_period__c = accountingPeriod;
                to_t_fdc.eWallet__c = incomlendFees.eWallets__r[0].Id;
                to_t_fdc.account__c = incomlendFees.Id;
                to_t_fdc.ccy__c = invoice.CCY__c;
                to_t_fdc.amount__c = invoice.Total_Incomlend_Discount_Commissions__c;
                to_t_fdc.effective_date__c = date.today();
                to_t_fdc.status__C = 'Confirmed by operations';
                to_t_fdc.type__c = '052.discount amount fees';
                to_t_fdc.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(to_t_fdc);
            }
            
            // Create transaction for Supplier's agent commission
            // Fetch supplier account and eWallet
            Account supplier = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Id=:invoice.Supplier_Buyer_Map__r.Supplier__c];
            Account supplierAgent = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Id=:invoice.Supplier_Buyer_Map__r.Supplier__r.Agent__c];
            if(invoice.Actual_supplier_s_Agent_Commission_amt__c > 0){
                if(supplierAgent.eWallets__r == null || supplierAgent.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Supplier Agent\'s eWallet does not exist');
                if(incomlendOpp.eWallets__r == null || incomlendOpp.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Incomlend Operation\'s eWallet does not exist');
                
                // Create FROM Incomlend Operation transaction
                Transaction__c from_t_sac = new Transaction__c();
                from_t_sac.accounting_period__c = accountingPeriod;
                from_t_sac.eWallet__c = incomlendOpp.eWallets__r[0].Id;
                from_t_sac.account__c = incomlendOpp.Id;
                from_t_sac.ccy__c = invoice.CCY__c;
                from_t_sac.amount__c = invoice.Actual_supplier_s_Agent_Commission_amt__c * -1;
                from_t_sac.effective_date__c = date.today();
                from_t_sac.status__C = 'Confirmed by operations';
                from_t_sac.type__c = '061.Agent Commission on Transaction Fee';
                from_t_sac.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(from_t_sac);
                
                // Create TO supplier's agent transaction
                Transaction__c to_t_sac = new Transaction__c();
                to_t_sac.accounting_period__c = accountingPeriod;
                to_t_sac.eWallet__c = supplierAgent.eWallets__r[0].Id;
                to_t_sac.account__c = supplierAgent.Id;
                to_t_sac.ccy__c = invoice.CCY__c;
                to_t_sac.amount__c = invoice.Actual_supplier_s_Agent_Commission_amt__c;
                to_t_sac.effective_date__c = date.today();
                to_t_sac.status__C = 'Confirmed by operations';
                to_t_sac.type__c = '061.Agent Commission on Transaction Fee';
                to_t_sac.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(to_t_sac);
            }
            
            // Create transaction for Incomlend platform fee
            if(invoice.Premium_IC_fee_from_from_supplier_disc__c != null && invoice.Premium_IC_fee_from_from_supplier_disc__c != 0){
                if(incomlendFees.eWallets__r == null || incomlendFees.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Incomlend Fees\'s eWallet does not exist');
                if(incomlendOpp.eWallets__r == null || incomlendOpp.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Incomlend Operation\'s eWallet does not exist');
                
                // Create FROM Incomlend Operation transaction
                Transaction__c from_t_sac = new Transaction__c();
                from_t_sac.accounting_period__c = accountingPeriod;
                from_t_sac.eWallet__c = incomlendOpp.eWallets__r[0].Id;
                from_t_sac.account__c = incomlendOpp.Id;
                from_t_sac.ccy__c = invoice.CCY__c;
                from_t_sac.amount__c = invoice.Premium_IC_fee_from_from_supplier_disc__c * -1;
                from_t_sac.effective_date__c = date.today();
                from_t_sac.status__C = 'Confirmed by operations';
                from_t_sac.type__c = '06.Transaction Fee';
                from_t_sac.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(from_t_sac);
                
                // Create TO Incomlend fees transaction
                Transaction__c to_t_sac = new Transaction__c();
                to_t_sac.accounting_period__c = accountingPeriod;
                to_t_sac.eWallet__c = incomlendFees.eWallets__r[0].Id;
                to_t_sac.account__c = incomlendFees.Id;
                to_t_sac.ccy__c = invoice.CCY__c;
                to_t_sac.amount__c = invoice.Premium_IC_fee_from_from_supplier_disc__c;
                to_t_sac.effective_date__c = date.today();
                to_t_sac.status__C = 'Confirmed by operations';
                to_t_sac.type__c = '06.Transaction Fee';
                to_t_sac.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(to_t_sac);
            }
            
            // Create transaction for the remaining balance for supplier
            if(invoice.Balance_to_be_credited_to_supplier__c > 0){
                if(supplier.eWallets__r == null || supplier.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Supplier\'s eWallet does not exist');
                if(incomlendOpp.eWallets__r == null || incomlendOpp.eWallets__r.size() == 0)
                    throw new CreateTransactionsException('Incomlend Operation\'s eWallet does not exist');
                
                // Create FROM Incomlend Operation transaction
                Transaction__c from_t_sac = new Transaction__c();
                from_t_sac.accounting_period__c = accountingPeriod;
                from_t_sac.eWallet__c = incomlendOpp.eWallets__r[0].Id;
                from_t_sac.account__c = incomlendOpp.Id;
                from_t_sac.ccy__c = invoice.CCY__c;
                from_t_sac.amount__c = invoice.Balance_to_be_credited_to_supplier__c * -1;
                from_t_sac.effective_date__c = date.today();
                from_t_sac.status__C = 'Confirmed by operations';
                from_t_sac.type__c = '08.Invoice Balance Payment';
                from_t_sac.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(from_t_sac);
                
                // Create TO supplier transaction
                Transaction__c to_t_sac = new Transaction__c();
                to_t_sac.accounting_period__c = accountingPeriod;
                to_t_sac.eWallet__c = supplier.eWallets__r[0].Id;
                to_t_sac.account__c = supplier.Id;
                to_t_sac.ccy__c = invoice.CCY__c;
                to_t_sac.amount__c = invoice.Balance_to_be_credited_to_supplier__c;
                to_t_sac.effective_date__c = date.today();
                to_t_sac.status__C = 'Confirmed by operations';
                to_t_sac.type__c = '08.Invoice Balance Payment';
                to_t_sac.Invoice_Finance_Deal__c = invoice.Id;
                transactions.add(to_t_sac);
            }
            
            // Update Invoice
            invoice.Phase__c = '4:CLOSED';
            invoice.Status__c =  'Paid';  
            update invoice;
            
            // DML operation with list outside of the loop (counted as a single DML operation each)
            update allocationsToUpdate;
            insert transactions;
            // Updated related transactions (double-entry transactions)
            Integer lnTrans = transactions.size();
            if(math.mod(lnTrans, 2) == 0){
                for (Integer i = 0 ; i < lnTrans/2 ; i++) {
                    transactions[2*i].Related_Transaction__c = transactions[2*i+1].Id;
                    transactions[2*i+1].Related_Transaction__c = transactions[2*i].Id;              
                }
                update transactions;
            }else{
                system.debug('Number of transactions: ' + lnTrans);
                throw new CreateTransactionsException('Number of transactions is odd, which is odd');
            }
        }
        catch(CreateTransactionsException managedException)
        {
            throw managedException;
        }
        catch(Exception unmanagedException)
        {
            throw new CreateTransactionsException('An unexpected error occured, please contact your System Administrator');
        }
        
        return;
    }
    
    global class CreateTransactionsRequest {
        @InvocableVariable(required=true)
        global ID invoiceId;
    }
    
    class CreateTransactionsException extends Exception {}
}