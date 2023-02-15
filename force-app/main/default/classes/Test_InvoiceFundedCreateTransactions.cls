@isTest(SeeAllData=true)
private class Test_InvoiceFundedCreateTransactions {
    
    @isTest static void TestCreateTransactions() {
        // Create Invoice
        System.debug('Create Invoice');
        invoice_finance_deal__c invoice= new invoice_finance_deal__c();
        invoice.supplier_invoice_reference_number__c = 'PH21051980HB';
        invoice.Country_of_Origin__c = 'France';
        invoice.Country_of_Destination__c = 'Italy';
        invoice.Goods_Services_description__c = 'Heavy and expensive stuff';
        invoice.Phase__c = '2:ON MARKETPLACE';
        invoice.Status__c = 'On marketplace';
        invoice.Invoice_date__c = date.today();
        invoice.advance_send_to_supplier_date__c = date.today().addDays(9);
        invoice.Due_Date__c = date.today().addDays(57);
        invoice.invoice_amount__c = 10000+80000*Math.random();
        Integer sbm_count = [SELECT COUNT() FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true];
        System.debug('sbm_count:'+sbm_count);
        Integer sbm_rand = Math.floor(Math.random() * sbm_count).intValue();
        System.debug('sbm_rand:'+sbm_rand);
        List<Supplier_Buyer_Map__c> sbm_list = [SELECT Id, Name, Supplier__c, Buyer__c, currency__c FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true]; // AND currency__c!='XXX'
        invoice.Supplier_Buyer_Map__c = sbm_list.get(sbm_rand).Id; // Select random SB map
        System.debug('Supplier Buyer Map:'+sbm_list.get(sbm_rand).Id);
        invoice.CCY__c = sbm_list.get(sbm_rand).currency__c;
        invoice.discount_rate__c = 0.80;
        invoice.requested_amount__c = 0.9*invoice.invoice_amount__c;
        invoice.credit_insurance_fee_percentage__c = 0.05;       
        insert invoice;
        System.debug(invoice);
        invoice = [SELECT Id, CCY__c, funded_amount__c, requested_amount__c, 
                                         credit_insurance_fee__c,
                                         Total_supplier_discount_amount_expected__c,
                                         Balance_for_upfront_fee__c,
                                         Total_platform_fee__c,
                                         Total_platform_fee_for_upfront_fee__c,
                                         Supplier_Buyer_Map__r.Supplier__c,
                                         advance_send_to_supplier_date__c, Listing_End__c, Phase__c
                                         FROM invoice_finance_deal__c WHERE Id = :invoice.Id];
        System.debug(invoice);
        // Create Allocations
        System.debug('Create Allocations');
        Integer funders_count = [SELECT COUNT() FROM Account WHERE Type = 'Customer' AND Sub_type__c = 'Purchaser'];
        List<Account> funders_list = [SELECT Id, Name, (SELECT Id, balance__c, CCY__c FROM eWallets__r WHERE CCY__C =:invoice.CCY__c LIMIT 1) FROM Account WHERE Type = 'Customer' AND Sub_type__c = 'Purchaser'];
        Integer funders_nb = Math.min(30,Math.min(funders_count,5+Math.floor((0.20+0.20*Math.random()) * funders_count).intValue())); // between 20% and 40% of the funders (+5 to have minimum to choose from)
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
                allocation.Status__c = 'Reservation';
                allocation.Funder__c = funders_list.get(funder_rand).Id;
                funders_index_list.add(funder_rand); // don't use same funder
                allocation.eWallet__c = funders_list.get(funder_rand).eWallets__r[0].Id;
                Decimal availableFund = funders_list.get(funder_rand).eWallets__r[0].balance__c;
                System.debug('availableFund: '+availableFund);
                if (availableFund!=null && availableFund>1){
                    allocation.amount__c = Math.max(0,Math.min(availableFund/2,(invoice.requested_amount__c / funders_nb)*(0.7+0.3*Math.random()))); //each allocation is random
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
        
        // Get some eWallet amount before transactions are made
        Account eulerHermes = [SELECT Id, name, (SELECT id, Balance__c, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Atradius'];
        Decimal eh_balance_before = eulerHermes.eWallets__r[0].Balance__c;
        System.debug('eulerHermes.eWallet.Balance__c:'+eh_balance_before);
        Account incomlendSD = [SELECT Id, name, (SELECT id, Balance__c, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend - Supplier Discount'];
        Decimal inc_sd_before = incomlendSD.eWallets__r[0].Balance__c;
        System.debug('incomlendSD.eWallet.Balance__c:'+inc_sd_before);
        Account incomlendFee = [SELECT Id, name, (SELECT id, Balance__c, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend - fees'];
        Decimal inc_fee_before = incomlendFee.eWallets__r[0].Balance__c;
        System.debug('incomlendFee.eWallet.Balance__c:'+inc_fee_before);   
        
        // Call InvoiceFundedCreateTransactions
        System.debug('Call InvoiceFundedCreateTransactions');
		List<InvoiceFundedCreateTransactions.CreateTransactionsRequest> requests = new List<InvoiceFundedCreateTransactions.CreateTransactionsRequest>();
		InvoiceFundedCreateTransactions.CreateTransactionsRequest request = new InvoiceFundedCreateTransactions.CreateTransactionsRequest();
        request.invoiceId = invoice.id;
        requests.add(request);
		InvoiceFundedCreateTransactions.createTransactions(requests);
        invoice = [SELECT Id, CCY__c, funded_amount__c, requested_amount__c, 
                   credit_insurance_fee__c,
                   Total_supplier_discount_amount_expected__c,
                   Balance_for_upfront_fee__c,
                   Total_platform_fee__c,
                   Total_platform_fee_for_upfront_fee__c,
                   Supplier_Buyer_Map__r.Supplier__c,
                   advance_send_to_supplier_date__c, Listing_End__c, Phase__c
                   FROM invoice_finance_deal__c WHERE Id = :invoice.Id]; 
        System.debug('invoice.credit_insurance_fee__c:'+invoice.credit_insurance_fee__c);
        System.debug('invoice.Total_supplier_discount_amount_expected__c:'+invoice.Total_supplier_discount_amount_expected__c);
        System.debug('invoice.Balance_for_upfront_fee__c:'+invoice.Balance_for_upfront_fee__c);
        System.debug('invoice.Total_platform_fee__c:'+invoice.Total_platform_fee__c);
        System.debug('invoice.Total_platform_fee_for_upfront_fee__c:'+invoice.Total_platform_fee_for_upfront_fee__c);

        System.debug('Checks');
		// Check number of transaction        
        Integer transaction_cnt = [SELECT count() FROM Transaction__c WHERE Invoice_Finance_Deal__c=:invoice.id];
		Integer expt_transaction_cnt = allocation_nb*2;
        if(invoice.funded_amount__c>0){expt_transaction_cnt += 2;}
		if(invoice.credit_insurance_fee__c>0){expt_transaction_cnt += 2;}
        if(invoice.Total_supplier_discount_amount_expected__c>0){expt_transaction_cnt += 2;}
        if(invoice.Balance_for_upfront_fee__c>0){expt_transaction_cnt += 2;}
        if(invoice.Total_platform_fee__c>0){expt_transaction_cnt += 2;}
        if(invoice.Total_platform_fee_for_upfront_fee__c>0){expt_transaction_cnt += 2;}
        if((invoice.Total_platform_fee__c-invoice.Total_platform_fee_for_upfront_fee__c)>0){expt_transaction_cnt += 2;}
        System.debug('allocation_nb:'+allocation_nb);
        System.debug('expt_transaction_cnt:'+expt_transaction_cnt);
        System.debug('transaction_cnt:'+transaction_cnt);
        System.assertEquals(expt_transaction_cnt,transaction_cnt);
        
        // Check invoice status 
        System.debug('invoice.Phase__c:'+invoice.Phase__c);
        System.assertEquals('3:IN PROGRESS',invoice.Phase__c);
        
        // Check Incomlend Operation eWallet is null 
        Account incomlendOpp = [SELECT Id, name, (SELECT id, Balance__c, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend Operations'];
        System.debug('eWallet.Balance__c:'+incomlendOpp.eWallets__r[0].Balance__c);
        System.assertEquals(0,incomlendOpp.eWallets__r[0].Balance__c);
        
        // Check transaction from Supplier to credit insurance
        Account eulerHermes_after = [SELECT Id, name, (SELECT id, Balance__c, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Atradius'];
        Decimal eh_balance_after = eulerHermes_after.eWallets__r[0].Balance__c;
        System.debug('eulerHermes.eWallet.Balance__c:'+eh_balance_after);
        //System.assertEquals(invoice.credit_insurance_fee__c,eh_balance_after-eh_balance_before);
        

        // Check Incomlend Supply Discount eWallet
        incomlendSD = [SELECT Id, name, (SELECT id, Balance__c, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend - Supplier Discount'];
        Decimal inc_sd_after = incomlendSD.eWallets__r[0].Balance__c;
        System.debug('incomlendSD.eWallet.Balance__c:'+inc_sd_after); 
        /*System.assertEquals(invoice.Total_supplier_discount_amount_expected__c
                            -invoice.Balance_for_upfront_fee__c
                            +invoice.Total_platform_fee__c
                            -invoice.Total_platform_fee_for_upfront_fee__c
                            ,inc_sd_after-inc_sd_before);*/
        
        // Check Incomlend fee eWallet
        incomlendFee = [SELECT Id, name, (SELECT id, Balance__c, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend - fees'];
        Decimal inc_fee_after = incomlendFee.eWallets__r[0].Balance__c;
        System.debug('incomlendFee.eWallet.Balance__c:'+inc_fee_after);
        /*System.assertEquals(invoice.Balance_for_upfront_fee__c
                            +invoice.Total_platform_fee_for_upfront_fee__c
                            ,inc_fee_after-inc_fee_before);*/
    }
}