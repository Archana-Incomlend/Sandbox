global class InvoiceFundedCreateTransactions {
  @InvocableMethod(label='Create Transactions')
  global static void createTransactions(List<CreateTransactionsRequest> requests) {
    for (CreateTransactionsRequest request : requests) {
      createTransactions(request);
    }
    return;
  }
     
  public static void createTransactions(CreateTransactionsRequest request) {
      List<Transaction__c> transactions = new List<Transaction__c>{};
      invoice_finance_deal__c invoice = [SELECT Id, CCY__c, funded_amount__c,
                                         credit_insurance_fee__c,
                                         Total_supplier_discount_amount_expected__c,
                                         Balance_for_upfront_fee__c,
                                         Total_platform_fee__c,
                                         Total_platform_fee_for_upfront_fee__c,
                                         Supplier_Buyer_Map__r.Supplier__c,
                                         advance_send_to_supplier_date__c, Listing_End__c, Phase__c
                                         FROM invoice_finance_deal__c WHERE Id = :request.invoiceId];
      // Check that advance_send_to_supplier_date is not empty
      if(invoice.advance_send_to_supplier_date__c==null){
          throw new CreateTransactionsException('Advance send to supplier date is empty');
      }
      // Define accounting period
      ID accountingPeriod = Accounting_Period.lookup(date.today());
      // Fetch Incomlend Operation account and eWallet
      Account incomlendOpp = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend Operations'];

      // Create transactions from funders to Incomlend Operation
      List<Invoice_Allocation__c> allocationsToUpdate = new List<Invoice_Allocation__c>{};
      for(Invoice_Allocation__c allocation : [SELECT Id, Allocation_Confirmed_Date__c, amount__c, CCY__c, Funder__c, Status__c, eWallet__c
                                              FROM Invoice_Allocation__c
                                              WHERE Invoice__c=:request.invoiceId AND Status__c != 'Canceled'])
      {
          //Update allocation
          allocation.Allocation_Confirmed_Date__c = date.today();
          allocation.Status__c = 'Confirmed';
          allocationsToUpdate.add(allocation);
          // Create FROM transaction
          Transaction__c from_t_alloc = new Transaction__c();
          from_t_alloc.accounting_period__c = accountingPeriod;
          from_t_alloc.eWallet__c = allocation.eWallet__c;
          from_t_alloc.account__c = allocation.Funder__c;
          from_t_alloc.ccy__c = allocation.CCY__c;
          from_t_alloc.amount__c = allocation.amount__c * -1;
          from_t_alloc.effective_date__c = date.today();
          from_t_alloc.status__C = 'Confirmed by operations';
          from_t_alloc.type__c = '01.Invoice Purchase';
          from_t_alloc.Invoice_Allocation__c = allocation.Id;
          from_t_alloc.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(from_t_alloc);  
          // Create TO transaction
          Transaction__c to_t_alloc = new Transaction__c();
          to_t_alloc.accounting_period__c = accountingPeriod;
          to_t_alloc.eWallet__c = incomlendOpp.eWallets__r[0].Id;
          to_t_alloc.account__c = incomlendOpp.Id;
          to_t_alloc.ccy__c = allocation.CCY__c;
          to_t_alloc.amount__c = allocation.amount__c;
          to_t_alloc.effective_date__c = date.today();
          to_t_alloc.status__C = 'Confirmed by operations';
          to_t_alloc.type__c = '01.Invoice Purchase';
          to_t_alloc.Invoice_Allocation__c = allocation.Id;
          to_t_alloc.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(to_t_alloc);
      }
      
      // Create transaction from Incomlend Operation to Supplier
      // Fetch supplier account and eWallet
      Account supplier = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Id=:invoice.Supplier_Buyer_Map__r.Supplier__c];
      
      if(invoice.funded_amount__c>0){
          // Create FROM Incomlend Operation transaction
          Transaction__c from_t_cdt = new Transaction__c();
          from_t_cdt.accounting_period__c = accountingPeriod;
          from_t_cdt.eWallet__c = incomlendOpp.eWallets__r[0].Id;
          from_t_cdt.account__c = incomlendOpp.Id;
          from_t_cdt.ccy__c = invoice.CCY__c;
          from_t_cdt.amount__c = invoice.funded_amount__c * -1;
          from_t_cdt.effective_date__c = date.today();
          from_t_cdt.status__C = 'Confirmed by operations';
          from_t_cdt.type__c = '02.Invoice Advance Amount';
          from_t_cdt.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(from_t_cdt);
          // Create TO Supplier transaction
          Transaction__c to_t_cdt = new Transaction__c();
          to_t_cdt.accounting_period__c = accountingPeriod;
          to_t_cdt.eWallet__c = supplier.eWallets__r[0].Id;
          to_t_cdt.account__c = supplier.Id;
          to_t_cdt.ccy__c = invoice.CCY__c;
          to_t_cdt.amount__c = invoice.funded_amount__c;
          to_t_cdt.effective_date__c = date.today();
          to_t_cdt.status__C = 'Confirmed by operations';
          to_t_cdt.type__c = '02.Invoice Advance Amount';
          to_t_cdt.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(to_t_cdt);
      }

      // Create transaction from Supplier to credit insurance
      if(invoice.credit_insurance_fee__c>0){
          System.debug('IFCT:credit_insurance_fee__c:'+invoice.credit_insurance_fee__c); 
          // Fetch EH Account and eWallet
          Account eulerHermes = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Atradius'];
          // Create FROM supplier transaction
          Transaction__c from_t_ass = new Transaction__c();
          from_t_ass.accounting_period__c = accountingPeriod;
          from_t_ass.eWallet__c = supplier.eWallets__r[0].Id;
          from_t_ass.account__c = supplier.Id;
          from_t_ass.ccy__c = invoice.CCY__c;
          from_t_ass.amount__c = invoice.credit_insurance_fee__c * -1;
          from_t_ass.effective_date__c = date.today();
          from_t_ass.status__C = 'Confirmed by operations';
          from_t_ass.type__c = '07.Credit Insurance';
          from_t_ass.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(from_t_ass);
          // Create TO credit insurance transaction
          Transaction__c to_t_ass = new Transaction__c();
          to_t_ass.accounting_period__c = accountingPeriod;
          to_t_ass.eWallet__c = eulerHermes.eWallets__r[0].Id;
          to_t_ass.account__c = eulerHermes.Id;
          to_t_ass.ccy__c = invoice.CCY__c;
          to_t_ass.amount__c = invoice.credit_insurance_fee__c;
          to_t_ass.effective_date__c = date.today();
          to_t_ass.status__C = 'Confirmed by operations';
          to_t_ass.type__c = '07.Credit Insurance';
          to_t_ass.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(to_t_ass);
      }
  
      // Create transaction from Supplier to Incomlend Supply Discount
          // Fetch Incomlend Supply Discount Account and eWallet
          Account incomlendSD = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend - Supplier Discount'];
      	  if(invoice.Total_supplier_discount_amount_expected__c>0){
              // Create FROM supplier transaction
              Transaction__c from_t_sd = new Transaction__c();
              from_t_sd.accounting_period__c = accountingPeriod;
              from_t_sd.eWallet__c = supplier.eWallets__r[0].Id;
              from_t_sd.account__c = supplier.Id;
              from_t_sd.ccy__c = invoice.CCY__c;
              from_t_sd.amount__c = invoice.Total_supplier_discount_amount_expected__c * -1;
              from_t_sd.effective_date__c = date.today();
              from_t_sd.status__C = 'Confirmed by operations';
              from_t_sd.type__c = '06.Transaction Fee';
              from_t_sd.Invoice_Finance_Deal__c = invoice.Id;
              transactions.add(from_t_sd);
              // Create TO Incomlend Supply Discount transaction
              Transaction__c to_t_sd = new Transaction__c();
              to_t_sd.accounting_period__c = accountingPeriod;
              to_t_sd.eWallet__c = incomlendSD.eWallets__r[0].Id;
              to_t_sd.account__c = incomlendSD.Id;
              to_t_sd.ccy__c = invoice.CCY__c;
              to_t_sd.amount__c = invoice.Total_supplier_discount_amount_expected__c;
              to_t_sd.effective_date__c = date.today();
              to_t_sd.status__C = 'Confirmed by operations';
              to_t_sd.type__c = '06.Transaction Fee';
              to_t_sd.Invoice_Finance_Deal__c = invoice.Id;
              transactions.add(to_t_sd);
      	  }
      
      // Create transaction from Incomlend Supply Discount to Incomlend fees
          // Fetch Incomlend fees Account and eWallet
          Account incomlendFees = [SELECT Id, name, (SELECT id, CCY__C FROM eWallets__r WHERE CCY__C =:invoice.CCY__c) FROM Account Where Name='Incomlend - fees'];
          // Create FROM Incomlend Supply Discount transaction
          if(invoice.Balance_for_upfront_fee__c>0){
              Transaction__c from_t_fees = new Transaction__c();
              from_t_fees.accounting_period__c = accountingPeriod;
              from_t_fees.eWallet__c = incomlendSD.eWallets__r[0].Id;
              from_t_fees.account__c = incomlendSD.Id;
              from_t_fees.ccy__c = invoice.CCY__c;
              from_t_fees.amount__c = invoice.Balance_for_upfront_fee__c * -1;
              from_t_fees.effective_date__c = date.today();
              from_t_fees.status__C = 'Confirmed by operations';
              from_t_fees.type__c = '06.Transaction Fee';
              from_t_fees.Invoice_Finance_Deal__c = invoice.Id;
              transactions.add(from_t_fees);
              // Create TO Incomlend fees transaction
              Transaction__c to_t_fees = new Transaction__c();
              to_t_fees.accounting_period__c = accountingPeriod;
              to_t_fees.eWallet__c = incomlendFees.eWallets__r[0].Id;
              to_t_fees.account__c = incomlendFees.Id;
              to_t_fees.ccy__c = invoice.CCY__c;
              to_t_fees.amount__c = invoice.Balance_for_upfront_fee__c;
              to_t_fees.effective_date__c = date.today();
              to_t_fees.status__C = 'Confirmed by operations';
              to_t_fees.type__c = '06.Transaction Fee';
              to_t_fees.Invoice_Finance_Deal__c = invoice.Id;
              transactions.add(to_t_fees);
      	  }
      
       // Create transaction from Supplier to Incomlend Operation (Platform fees)
       if(invoice.Total_platform_fee__c>0){
          // Create FROM supplier transaction
          Transaction__c from_t_pltf = new Transaction__c();
          from_t_pltf.accounting_period__c = accountingPeriod;
          from_t_pltf.eWallet__c = supplier.eWallets__r[0].Id;
          from_t_pltf.account__c = supplier.Id;
          from_t_pltf.ccy__c = invoice.CCY__c;
          from_t_pltf.amount__c = invoice.Total_platform_fee__c * -1;
          from_t_pltf.effective_date__c = date.today();
          from_t_pltf.status__C = 'Confirmed by operations';
          from_t_pltf.type__c = '06.Transaction Fee';
          from_t_pltf.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(from_t_pltf);
          // Create TO Incomlend Operation transaction
          Transaction__c to_t_pltf = new Transaction__c();
          to_t_pltf.accounting_period__c = accountingPeriod;
          to_t_pltf.eWallet__c = incomlendOpp.eWallets__r[0].Id;
          to_t_pltf.account__c = incomlendOpp.Id;
          to_t_pltf.ccy__c = invoice.CCY__c;
          to_t_pltf.amount__c = invoice.Total_platform_fee__c;
          to_t_pltf.effective_date__c = date.today();
          to_t_pltf.status__C = 'Confirmed by operations';
          to_t_pltf.type__c = '06.Transaction Fee';
          to_t_pltf.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(to_t_pltf);
       }
      // Transfert platform upfront fee to Incomlend fee
       if(invoice.Total_platform_fee_for_upfront_fee__c>0){
          // Create FROM Incomlend Operation transaction
          Transaction__c from_t_pltf_upfront = new Transaction__c();
          from_t_pltf_upfront.accounting_period__c = accountingPeriod;
          from_t_pltf_upfront.eWallet__c = incomlendOpp.eWallets__r[0].Id;
          from_t_pltf_upfront.account__c = incomlendOpp.Id;
          from_t_pltf_upfront.ccy__c = invoice.CCY__c;
          from_t_pltf_upfront.amount__c = invoice.Total_platform_fee_for_upfront_fee__c * -1;
          from_t_pltf_upfront.effective_date__c = date.today();
          from_t_pltf_upfront.status__C = 'Confirmed by operations';
          from_t_pltf_upfront.type__c = '06.Transaction Fee';
          from_t_pltf_upfront.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(from_t_pltf_upfront);
          // Create TO Incomlend fees transaction
          Transaction__c to_t_pltf_upfront = new Transaction__c();
          to_t_pltf_upfront.accounting_period__c = accountingPeriod;
          to_t_pltf_upfront.eWallet__c = incomlendFees.eWallets__r[0].Id;
          to_t_pltf_upfront.account__c = incomlendFees.Id;
          to_t_pltf_upfront.ccy__c = invoice.CCY__c;
          to_t_pltf_upfront.amount__c = invoice.Total_platform_fee_for_upfront_fee__c;
          to_t_pltf_upfront.effective_date__c = date.today();
          to_t_pltf_upfront.status__C = 'Confirmed by operations';
          to_t_pltf_upfront.type__c = '06.Transaction Fee';
          to_t_pltf_upfront.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(to_t_pltf_upfront);
       }
      // Transfert balance of platform fee to Incomlend Supply Discount
       if((invoice.Total_platform_fee__c-invoice.Total_platform_fee_for_upfront_fee__c)>0){
          // Create FROM Incomlend Operation transaction
          Transaction__c from_t_pltf_bl = new Transaction__c();
          from_t_pltf_bl.accounting_period__c = accountingPeriod;
          from_t_pltf_bl.eWallet__c = incomlendOpp.eWallets__r[0].Id;
          from_t_pltf_bl.account__c = incomlendOpp.Id;
          from_t_pltf_bl.ccy__c = invoice.CCY__c;
          from_t_pltf_bl.amount__c = (invoice.Total_platform_fee__c-invoice.Total_platform_fee_for_upfront_fee__c) * -1;
          from_t_pltf_bl.effective_date__c = date.today();
          from_t_pltf_bl.status__C = 'Confirmed by operations';
          from_t_pltf_bl.type__c = '06.Transaction Fee';
          from_t_pltf_bl.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(from_t_pltf_bl);
          // Create TO Incomlend Supply Discount transaction
          Transaction__c to_t_pltf_bl = new Transaction__c();
          to_t_pltf_bl.accounting_period__c = accountingPeriod;
          to_t_pltf_bl.eWallet__c = incomlendSD.eWallets__r[0].Id;
          to_t_pltf_bl.account__c = incomlendSD.Id;
          to_t_pltf_bl.ccy__c = invoice.CCY__c;
          to_t_pltf_bl.amount__c = (invoice.Total_platform_fee__c-invoice.Total_platform_fee_for_upfront_fee__c);
          to_t_pltf_bl.effective_date__c = date.today();
          to_t_pltf_bl.status__C = 'Confirmed by operations';
          to_t_pltf_bl.type__c = '06.Transaction Fee';
          to_t_pltf_bl.Invoice_Finance_Deal__c = invoice.Id;
          transactions.add(to_t_pltf_bl);
       }
      
      // DML operations with lists outside of the loop (counted as a single DML operation each)
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
		
      // Update Invoice
	  invoice.Phase__c = '3:IN PROGRESS';
      invoice.Status__c =  'In Progress';  
      update invoice;
      
	  return;
  }

  global class CreateTransactionsRequest {
    @InvocableVariable(required=true)
    global ID invoiceId;
  }

  class CreateTransactionsException extends Exception {}
}