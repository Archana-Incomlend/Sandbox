@isTest(SeeAllData=true)
private class Test_InvoiceRepaidCreateTransactions {    
    @isTest static void TestCreateTransactions() {
        // Create Invoice
        System.debug('Create Invoice');
        invoice_finance_deal__c invoice= new invoice_finance_deal__c();
        invoice.supplier_invoice_reference_number__c = 'PH21051980HB';
        invoice.Country_of_Origin__c = 'France';
        invoice.Country_of_Destination__c = 'Italy';
        invoice.Goods_Services_description__c = 'Heavy and expensive stuff';
        invoice.Phase__c = '3:IN PROGRESS';
        invoice.Status__c = 'In Progress';
        invoice.Invoice_date__c = date.today();
        invoice.advance_send_to_supplier_date__c = date.today().addDays(9);
        invoice.Due_Date__c = date.today().addDays(57);
        invoice.Actual_Repayment_Received_Date__c = date.today().addDays(59);
        invoice.invoice_amount__c = 10000+80000*Math.random();
        Integer sbm_count = [SELECT COUNT() FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true];
        Integer sbm_rand = Math.floor(Math.random() * sbm_count).intValue();
        List<Supplier_Buyer_Map__c> sbm_list = [SELECT Id, Name, Supplier__c, Buyer__c, currency__c FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true];
        invoice.Supplier_Buyer_Map__c = sbm_list.get(sbm_rand).Id; // Select random SB map
        invoice.CCY__c = sbm_list.get(sbm_rand).currency__c;
        invoice.discount_rate__c = 0.80;
        invoice.requested_amount__c = 0.9*invoice.invoice_amount__c;
        System.debug(invoice);
        insert invoice;
        // Create Allocations
        System.debug('Create Allocations');
        Integer funders_count = [SELECT COUNT() FROM Account WHERE Type = 'Customer' AND Sub_type__c = 'Purchaser'];
        List<Account> funders_list = [SELECT Id, Name, (SELECT Id, balance__c, CCY__c FROM eWallets__r WHERE CCY__C =:invoice.CCY__c LIMIT 1) FROM Account WHERE Type = 'Customer' AND Sub_type__c = 'Purchaser'];
        Integer funders_nb = Math.min(30,Math.min(funders_count,5+Math.floor((0.10+0.20*Math.random()) * funders_count).intValue())); // between 10% and 30% of the funders (+5 to have minimum to choose from)
        List<Invoice_Allocation__c> allocations = new List<Invoice_Allocation__c>{};
        Integer allocation_nb = 0;
        System.debug('funders_nb: '+funders_nb);
        List<Integer> funders_index_list = new List<Integer>{};
        For (Integer i = 0; i < 2*funders_nb; i++) {
            Integer funder_rand = Math.floor(Math.random() * funders_nb).intValue(); // pick funder randomly   
            System.debug('funder_rand: '+funder_rand);
            System.debug('is in funders_index_list: '+funders_index_list.indexOf(funder_rand));
            System.debug('funders_list.get(funder_rand).eWallets__r.isEmpty: '+funders_list.get(funder_rand).eWallets__r.isEmpty());
            if (funders_index_list.indexOf(funder_rand)==-1 && !funders_list.get(funder_rand).eWallets__r.isEmpty()){
                Invoice_Allocation__c allocation = new Invoice_Allocation__c();
                allocation.Invoice__c = invoice.id;
                allocation.Allocation_Reservation_date__c = date.today().addDays(2);
                allocation.Allocation_Confirmed_Date__c = date.today().addDays(4);
                allocation.Status__c = 'Confirmed';
                allocation.Funder__c = funders_list.get(funder_rand).Id;
                allocation.eWallet__c = funders_list.get(funder_rand).eWallets__r[0].Id;
                Decimal availableFund = funders_list.get(funder_rand).eWallets__r[0].balance__c;
                System.debug('availableFund: '+availableFund);
                if (availableFund!=null && availableFund>1){
                    allocation.amount__c = Math.max(0,Math.min(availableFund,(invoice.requested_amount__c / funders_nb)*(0.7+0.3*Math.random()))); //each allocation is random
                    allocation.funder_discount_amount__c = (invoice.discount_rate__c/30) * 50 * allocation.amount__c; // approximate formula for testing purpose
                    allocation.Funder_Agent_Commission_Amount__c = 0.1 * allocation.funder_discount_amount__c;
                    allocation.CCY__c = invoice.CCY__c;
                    allocations.add(allocation);
                    allocation_nb++;
                    System.debug('allocation_nb: '+allocation_nb);                 
                }
            }
        }
        System.debug('Insert allocations'); 
        System.debug(allocations);
        insert allocations;
        
        // Call InvoiceRepaidCreateTransactions
        System.debug('Call InvoiceRepaidCreateTransactions');
        List<InvoiceRepaidCreateTransactions.CreateTransactionsRequest> requests = new List<InvoiceRepaidCreateTransactions.CreateTransactionsRequest>();
        InvoiceRepaidCreateTransactions.CreateTransactionsRequest request = new InvoiceRepaidCreateTransactions.CreateTransactionsRequest();
        request.invoiceId = invoice.id;
        requests.add(request);
        InvoiceRepaidCreateTransactions.createTransactions(requests);
        invoice = [SELECT Id, CCY__c, funded_amount__c, requested_amount__c, 
                   Actual_Repayment_Amount__c,
                   Gross_funder_discount_amount_expected__c,
                   Balance_for_upfront_fee__c,
                   Supplier_s_Agent_Commission_amount__c,
                   Total_Incomlend_Discount_Commissions__c,
                   Actual_supplier_s_Agent_Commission_amt__c,
                   Premium_IC_fee_from_from_supplier_disc__c,
                   Balance_to_be_credited_to_supplier__c,
                   Phase__c, Status__c
                   FROM invoice_finance_deal__c WHERE Id = :invoice.Id];
        
        System.debug('Checks');
        // Check number of transactions        
        Integer transaction_cnt = [SELECT count() FROM Transaction__c WHERE Invoice_Finance_Deal__c=:invoice.id];
        Integer expt_transaction_cnt = allocation_nb*6;
        if(invoice.Actual_Repayment_Amount__c>0){expt_transaction_cnt += 2;}
        if((invoice.Gross_funder_discount_amount_expected__c+invoice.Supplier_s_Agent_Commission_amount__c)>0){expt_transaction_cnt += 2;}
        if(invoice.Total_Incomlend_Discount_Commissions__c>0){expt_transaction_cnt += 2;}
        if(invoice.Actual_supplier_s_Agent_Commission_amt__c>0){expt_transaction_cnt += 2;}
        if(invoice.Premium_IC_fee_from_from_supplier_disc__c>0){expt_transaction_cnt += 2;}
        if(invoice.Balance_to_be_credited_to_supplier__c>0){expt_transaction_cnt += 2;}
        System.debug('allocation_nb:'+allocation_nb);
        System.debug('expt_transaction_cnt:'+expt_transaction_cnt);
        System.debug('transaction_cnt:'+transaction_cnt);
        //System.assertEquals(expt_transaction_cnt,transaction_cnt); // TO_DO: Check with funder agents
        
        // Check invoice phase and status 
        invoice = [SELECT Id, Phase__c, Status__c FROM Invoice_Finance_Deal__c WHERE Id=:invoice.id];
        System.debug('invoice.Phase__c:'+invoice.Phase__c);
        System.assertEquals('4:CLOSED',invoice.Phase__c);
        System.assertEquals('Paid',invoice.Status__c);
        
        // Check Incomlend Operation eWallets are null 
        Account incAcc = [SELECT Id, name, (SELECT id, Balance__c, CCY__C FROM eWallets__r) FROM Account Where Name='Incomlend Operations'];
        List<eWallet__c> inc_eWallets = incAcc.eWallets__r;
        for (eWallet__C eWallet : inc_eWallets){
            System.assertEquals(0,eWallet.Balance__c);
            System.debug('eWallet.Balance__c:'+eWallet.Balance__c);
        }
    }
}