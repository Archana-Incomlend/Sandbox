@isTest
private class InvFinanaceDeal_InvAllocation_Flow_Test {


    private static Map<String, Id> setup(List<SObject> listObj) {
        Map<String, Id> mapId = new Map<String, Id>();
        if (listObj == null) listObj = new List<SObject>();
        Account SampleAccount = new Account();
        SampleAccount.onboarding_approved__c = true;
        
        Account FunderAccount = SampleAccount.clone(false, true, false, false);
        FunderAccount.Name = 'Test Funder Account';
        FunderAccount.Type = 'Customer';
        FunderAccount.Sub_type__c = 'Purchaser';
        FunderAccount.onboarding_stage__c = '99.Onboarded';
        FunderAccount.Primary_contact_email__c = 'testFunder@primarycontact.com';
        insert FunderAccount;
        listObj.add(FunderAccount);
        mapId.put('FunderAccount', FunderAccount.Id);

        Account objSupplierAgent = SampleAccount.clone(false, true, false, false);
        objSupplierAgent.Name = 'Test Supplier Agent Account';
        objSupplierAgent.Type = 'Agent';
        objSupplierAgent.Primary_contact_email__c = 'Test@primaryContact.Com';
        insert objSupplierAgent;
        listObj.add(objSupplierAgent);
        
        Account SupplierAccount = SampleAccount.clone(false, true, false, false);
        SupplierAccount.Name = 'Test Supplier Account';
        SupplierAccount.Agent__c = objSupplierAgent.Id;
        SupplierAccount.Type = 'Supplier';
        SupplierAccount.Sub_type__c = 'Supplier';
        SupplierAccount.onboarding_stage__c = '99.Onboarded';
        SupplierAccount.Primary_contact_email__c = 'testSupplier@primarycontact.com';
        SupplierAccount.Credit_insurance_fee__c = 0.65;
        insert SupplierAccount;
        listObj.add(SupplierAccount);
        mapId.put('SupplierAccount', SupplierAccount.Id);
        
        Account BuyerAccount = SampleAccount.clone(false, true, false, false);
        BuyerAccount.Name = 'Test Buyer Account';
        BuyerAccount.Type = 'Buyer';
        BuyerAccount.Sub_type__c = 'Buyer';
        BuyerAccount.onboarding_stage__c = '99.Onboarded';
        BuyerAccount.Credit_Insurance_CCY__c = 'USD';
        BuyerAccount.Credit_Limit_Requested_CCY__c = 'USD';
        BuyerAccount.Credit_limit_insurance_currency__c = 1000000;
        BuyerAccount.Total_CL_Limit_from_Incomlend__c = 5000000;
        insert BuyerAccount;
        listObj.add(BuyerAccount);
        mapId.put('BuyerAccount', BuyerAccount.Id);

        FX_Rates__c objFxRate = new FX_Rates__c();
        objFxRate.from_currency__c = 'USD';
        objFxRate.from_currency__c = 'USD';
        objFxRate.to_currency__c = 'USD';
        objFxRate.date__c = system.today();
        objFxRate.rate__c = 1;
        insert objFxRate;
        listObj.add(objFxRate);
        
        Marketplace__c objMarketPlace = new Marketplace__c();
        objMarketPlace.Name = 'USD insured';
        objMarketplace.Currency__c = 'USD';
        objMarketplace.latest_to_usd_rate__c = 1;
        objMarketplace.FX_Rate_for_MI__c = objFxRate.Id;
        objMarketplace.currency_symbol__c = '$';
        objMarketplace.minimum_purchase_amount__c = 0;
        objMarketplace.OwnerId = UserInfo.getUserId();
        insert objMarketplace;
        listObj.add(objMarketplace);
        
        Incomlend_product__c objProduct = new Incomlend_product__c();
        objProduct.Name = 'Standard Insured - USD' ;
        objProduct.launch_date__c = Date.newInstance(2000, 01, 01);
        objProduct.CCYs__c = 'USD';
        objProduct.months_relationship_with_buyer__c = 12;
        objProduct.Auction_Type__c = 'Fixed Discount Rate';
        objProduct.approved__c = true;
        objProduct.insured__c = true;
        insert objProduct;
        listObj.add(objProduct);
        
        Bank_Account__c objBankAccount = new Bank_Account__c();
        objBankAccount.Account__c = FunderAccount.Id;
        objBankAccount.Bank_Name__c = 'Test Bank';
        objBankAccount.SWIFT_Code__c = 'Test123456';
        objBankAccount.Currency__c = 'USD';
        objBankAccount.Country__c = 'Dubai';
        objBankAccount.transfer_cutoff_time__c = '18:00';
        objBankAccount.Bank_Account_Number__c = '0123456789';
        objBankAccount.Beneficiary_Name__c = 'Some Company Pte Ltd';
        insert objBankAccount;
        listObj.add(objBankAccount);
        
        Supplier_Buyer_Map__c objSupplierBuyerMap = new Supplier_Buyer_Map__c();
        objSupplierBuyerMap.Buyer__c = BuyerAccount.Id;
        objSupplierBuyerMap.Supplier__c = SupplierAccount.Id;
        objSupplierBuyerMap.Incomlend_product__c = objProduct.Id;
        objSupplierBuyerMap.Marketplace__c = objMarketplace.Id;
        objSupplierBuyerMap.Trustee__c = 'Amicorp Trust';
        objSupplierBuyerMap.buyer_supplier_map_approved__c = true;
        objSupplierBuyerMap.map_onboarding_stage__c = '90.Onboarded';
        objSupplierBuyerMap.Inprogress_invoice_amount_usd_equiv__c = 0;
        objSupplierBuyerMap.Buyer_Sales_Zone__c = 10;
        objSupplierBuyerMap.Supplier_Zone__c = 5;
        objSupplierBuyerMap.Ops_Owner__c = null;
        objSupplierBuyerMap.accepted_incoterms__c = 'EXW;FOB;CFR;CIF';
        objSupplierBuyerMap.CL_Limit_requested_for_this_Map__c = 1000000;
        objSupplierBuyerMap.CL_Incomlend_for_this_Map__c = 1000000;
        objSupplierBuyerMap.Geographical_zone__c = 'Zone 1';
        objSupplierBuyerMap.Overdue_Additional_Discount_rate__c = 0;
        objSupplierBuyerMap.Funder_Discount_Rate__c = 0.56; 
        objSupplierBuyerMap.Minimum_Spread__c = 0;
        objSupplierBuyerMap.Supplier_Discount_Rate__c = 0.75;
        objSupplierBuyerMap.invoice_validation_instructions_for_ops__c = 'Test Supplier Buyer Map';
        objSupplierBuyerMap.Public_Verification_Requirements__c = 'Test Supplier Buyer Map';
        objSupplierBuyerMap.Account_Agent__c = objSupplierAgent.Id;
        
        insert objSupplierBuyerMap;
        listObj.add(objSupplierBuyerMap);
        mapId.put('objSupplierBuyerMap', objSupplierBuyerMap.Id);
        
        Integer amount = 1000;
        Decimal sdr = 0.85;
        Integer expectedFinancePeriod = 90;
        Integer actualFinancingPeriod = expectedFinancePeriod;
        Date dueDate = System.today().addDays(expectedFinancePeriod - 1);
        
        Invoice_finance_deal__c objInvoice = new Invoice_finance_deal__c();
        objInvoice.supplier_invoice_reference_number__c = 'INV-' + objSupplierBuyerMap.Name;
        objInvoice.Invoice_date__c = System.today();
        objInvoice.Due_Date__c = dueDate;
        objInvoice.Listing_Start__c = System.today();
        objInvoice.Listing_End__c = dueDate;
        objInvoice.advance_send_to_supplier_date__c = System.today();
        objInvoice.Insured_by__c = 'Atradius';
        objInvoice.Country_of_Origin__c = 'China';
        objInvoice.Country_of_Destination__c = 'Australia';
        objInvoice.Incoterm__c = 'FOB';
        objInvoice.Goods_Services_description__c = 'test';
        objInvoice.Tolerance_overdue_days__c = 0;
        objInvoice.CCY__c = 'USD';
        objInvoice.Incomlend_product_del__c = objProduct.Id;
        objInvoice.Notice_of_Assignment_signed__c = true;
        objInvoice.Total_Supplier_Discount__c = sdr;
        objInvoice.Phase__c = '4:CLOSED';
        objInvoice.Status__c = 'Paid';
        objInvoice.Real_Face_Value__c = amount;
        objInvoice.Invoice_amount__c = amount;
        objInvoice.requested_amount__c = amount * 0.9;
        objInvoice.Supplier_Buyer_Map__c = objSupplierBuyerMap.Id;
        objInvoice.Marketplace_link__c =  objMarketplace.Id;
        objInvoice.Actual_Repayment_Received_Date__c = System.today().addDays(actualFinancingPeriod - 1);
        objInvoice.External_View__c = false;
        insert objInvoice;
        listObj.add(objInvoice);
        mapId.put('objInvoice', objInvoice.Id);

        eWallet__c objeWallet = new eWallet__c();
        objeWallet.Account__c = FunderAccount.Id;
        objeWallet.CCY__c = 'USD';
        objeWallet.Marketplace_for_FX__c = objMarketplace.Id;
        objeWallet.Bank_Account__c = objBankAccount.Id;
        objeWallet.Balance__c = 1000000;
        objeWallet.Reservations__c = 0;
        listObj.add(objeWallet);
        insert objeWallet;

        FunderAccount.USD_eWallet__c = objeWallet.Id;
        update FunderAccount; 
        // system.debug('***** FunderAccount == '+ FunderAccount);
        
        eWallet_Trustee__c eWallet_Trustee = new eWallet_Trustee__c();
        eWallet_Trustee.Main_eWallet__c = objeWallet.id;
        eWallet_Trustee.Account__c = FunderAccount.Id;
        eWallet_Trustee.CCY__c = 'USD';
        eWallet_Trustee.Marketplace_for_FX__c = objMarketplace.id;
        insert eWallet_Trustee;
        listObj.add(eWallet_Trustee);
        
        Tax_Rate__c taxRate = new Tax_Rate__c();
        taxRate.Rate__c = 7.00;
        taxRate.Country__c = 'Singapore';
        insert taxRate;
        listObj.add(taxRate);
        
        Accounting_Period__c Accounting_Period = new Accounting_Period__c();
        Accounting_Period.Name = (System.today()).year() + '-' + System.today().month().format().leftpad(2,'0');              
        Accounting_Period.Start_Date__c = System.today().addMonths(-12);
        Accounting_Period.End_Date__c = System.today().addMonths(12);
        insert Accounting_Period;
        listObj.add(Accounting_Period);
        
        Transaction__c trn = new Transaction__c();
        trn.Status__c = 'Confirmed by operations';
        trn.Type__c = '70.Deposit';
        trn.CCY__c = 'USD';
        trn.isArchived__c = false;
        trn.Account__c = FunderAccount.Id;
        trn.eWallet__c = objeWallet.id;
        trn.eWallet_Trustee__c = eWallet_Trustee.Id;
        trn.Accounting_Period__c = Accounting_Period.Id;
        trn.Amount__c = 1000000;
        trn.Effective_Date__c = System.today();
        trn.Invoice_Finance_Deal__c = objInvoice.Id;
        insert trn;
        listObj.add(trn);
        
        Invoice_Allocation__c objAllocation = new Invoice_Allocation__c();
        objAllocation.Applied_Funder_Discount_Profit_Share_Pct__c = 0.00;
        objAllocation.notes__c = FunderAccount.Id;
        objAllocation.Funder__c = FunderAccount.Id;
        objAllocation.amount__c = 100000;
        objAllocation.Invoice__c = objInvoice.Id;
        objAllocation.Status__c = 'Reservation';
        objAllocation.Allocation_Reservation_date__c = System.today();
        objAllocation.CCY__c = 'USD';
        objAllocation.Applied_MPR__c = 0.5;
        objAllocation.eWallet__c  = objeWallet.Id;
        insert objAllocation;
        listObj.add(objAllocation);
        
        return mapId;
    }


    static testMethod void myTest() {
        List<SObject> listObj = new List<SObject>();
        Map<String,Id> mapId = setup(listObj);
        Invoice_finance_deal__c objInvoice = new Invoice_finance_deal__c();
        objInvoice.Id = mapId.get('objInvoice');

        Supplier_Buyer_Map__c objSBM = [Select Id, Account_Agent__c, Account_Agent__r.Name, Supplier_Discount_Rate__c, invoice_validation_instructions_for_ops__c, Public_Verification_Requirements__c, Trustee__c, Funder_Discount_Rate__c, Supplier__r.Credit_insurance_fee__c from Supplier_Buyer_Map__c where Id =: mapId.get('objSupplierBuyerMap')];
        Invoice_finance_deal__c objInvoiceFinance = [Select Id, ready_for_posting_date__c, invoice_amount__c , advanced_amount__c, Invoice_Amount_Formula__c, first_deal_for_map__c, Total_Supplier_Discount__c, credit_insurance_fee_percentage__c, discount_rate__c from Invoice_finance_deal__c where Id =: objInvoice.Id];

        system.assertEquals(objInvoiceFinance.first_deal_for_map__c , true);
        system.assertEquals(objInvoiceFinance.Total_Supplier_Discount__c , objSBM.Supplier_Discount_Rate__c);
        system.assertEquals(objInvoiceFinance.discount_rate__c , objSBM.Funder_Discount_Rate__c);
        system.assertEquals(objInvoiceFinance.credit_insurance_fee_percentage__c , objSBM.Supplier__r.Credit_insurance_fee__c);
                
        objInvoiceFinance = [Select Id, in_progress_date__c, invoice_amount__c , Agent_from_the_Map__c, Invoice_Validation_Notes_for_OPs__c, Public_Verification_Requirements__c, Trustee__c, advanced_amount__c, Invoice_Amount_Formula__c, first_deal_for_map__c, Total_Supplier_Discount__c, credit_insurance_fee_percentage__c, discount_rate__c from Invoice_finance_deal__c where Id =: objInvoice.Id];
        
        system.assertEquals(objInvoiceFinance.invoice_amount__c , objInvoiceFinance.Invoice_Amount_Formula__c);
        system.assertEquals(objInvoiceFinance.Invoice_Validation_Notes_for_OPs__c , objSBM.invoice_validation_instructions_for_ops__c);
        system.assertEquals(objInvoiceFinance.Public_Verification_Requirements__c , objSBM.Public_Verification_Requirements__c);
        system.assertEquals(objInvoiceFinance.Trustee__c , objSBM.Trustee__c);
        system.assertEquals(objInvoiceFinance.Agent_from_the_Map__c , objSBM.Account_Agent__r.Name);
        
        Incomlend_product__c objProduct = null;
        for (SObject obj : listObj) { if (obj instanceof Incomlend_product__c) { objProduct = (Incomlend_product__c)obj; break; }}
        objProduct = objProduct.clone(false, true, false, false);
        objProduct.Name = 'Standart';
        insert objProduct;
        objInvoice.Phase__c = '3:IN PROGRESS';
        objInvoice.Status__c = 'In Progress';
        objInvoice.Incomlend_product_del__c = objProduct.Id;
        update objInvoice;
        
        objInvoiceFinance = [Select Id, ready_for_posting_date__c, RecordTypeId, RecordType.Developername , in_progress_date__c, due_date_delta_bucket__c ,due_date_delta_bucket_value__c,  over_due_days__c, over_due_days_value__c from Invoice_finance_deal__c where Id =: objInvoice.Id];
        
        system.assertNotEquals(objInvoiceFinance.in_progress_date__c , null);
        system.assertEquals(objInvoiceFinance.due_date_delta_bucket__c , objInvoiceFinance.due_date_delta_bucket_value__c);
        system.assertEquals(objInvoiceFinance.over_due_days__c , objInvoiceFinance.over_due_days_value__c);
        system.assertEquals(objInvoiceFinance.RecordType.Developername , 'Auction_Product');


        objInvoice.Phase__c = '2:ON MARKETPLACE';
        objInvoice.Status__c = 'On marketplace - waiting for auction to start';
        objInvoice.Invoice_ready_for_Posting__c = True;
        objInvoice.Waiting_for_allocations__c = True;
        update objInvoice;
        
        Invoice_finance_deal__c objInvoiceFinance1 = [Select Id, Waiting_for_Allocations_date__c, Invoice_ready_for_Posting__c, ready_for_posting_date__c from Invoice_finance_deal__c where Id =: objInvoice.id];
        system.assertEquals(objInvoiceFinance1.ready_for_posting_date__c , system.today());
        system.assertEquals(objInvoiceFinance1.Waiting_for_Allocations_date__c , system.today());
        
        
    }
    
    static testMethod void myTest1() {
        
        List<SObject> listObj = new List<SObject>();
        Map<String,Id> mapId = setup(listObj);
        Invoice_finance_deal__c objInvoice = new Invoice_finance_deal__c();
        objInvoice.Id = mapId.get('objInvoice');
        Invoice_finance_deal__c objInvoiceFinance;

        objInvoice.External_View__c = True;
        update objInvoice;
        
        objInvoiceFinance = [Select Id, RecordTypeId, RecordType.Developername from Invoice_finance_deal__c where Id =: objInvoice.id];
        
        system.assertEquals(objInvoiceFinance.RecordType.Developername , 'External_View');
        
        Incomlend_product__c objProduct = null;
        for (SObject obj : listObj) { if (obj instanceof Incomlend_product__c) { objProduct = (Incomlend_product__c)obj; break; }}
        Incomlend_product__c objProductReverse = objProduct.clone(false, true, false, false);
        objProductReverse.Name = 'Reverse Insured - USD' ;
        insert objProductReverse;
        
        objInvoice.External_View__c = False;
        objInvoice.Incomlend_product_del__c = objProductReverse.Id;
        update objInvoice;
        
        objInvoiceFinance = [Select Id, RecordTypeId, RecordType.Developername from Invoice_finance_deal__c where Id =: objInvoice.id];
        
        system.assertEquals(objInvoiceFinance.RecordType.Developername , 'Pricing_V2_2018');

        objInvoice.Phase__c = '1:PRE LISTING';
        objInvoice.Status__c = 'approved for listing';
        objInvoice.Funds_Available__c = True;
        objInvoice.Invoice_ready_for_Posting__c = True;
        objInvoice.Waiting_for_allocations__c = True;
        objInvoice.supplier_approval_status__c = 'Approved';
        update objInvoice;
        
    }
    
    
    static testMethod void myTest2() {
        
        List<SObject> listObj = new List<SObject>();
        Map<String,Id> mapId = setup(listObj);
        Invoice_finance_deal__c objInvoice = new Invoice_finance_deal__c();
        objInvoice.Id = mapId.get('objInvoice');

        Invoice_Allocation__c objAllocation = null;
        for (SObject obj : listObj) { if (obj instanceof Invoice_Allocation__c) { objAllocation = (Invoice_Allocation__c)obj; break; }}
        Account FunderAccount = null;
        for (SObject obj : listObj) { if (obj.Id == mapId.get('FunderAccount')) { FunderAccount = (Account)obj; break; }}
        Supplier_Buyer_Map__c objSupplierBuyerMap = null;
        for (SObject obj : listObj) { if (obj instanceof Supplier_Buyer_Map__c) { objSupplierBuyerMap = (Supplier_Buyer_Map__c)obj; break; }}
        
        Invoice_Allocation__c objAllocation1 = [Select Id, Discount__c, funder_discount_amount__c , Customer_Email__c, Trustee__c, Current_Funder_Discount_Profit_Share_Pct__c, Applied_Funder_Discount_Profit_Share_Pct__c from Invoice_Allocation__c where Id =: objAllocation.Id];
        System.debug('****** objAllocation1 ==  '+objAllocation1);  
        
        system.assertEquals(objAllocation1.Customer_Email__c , FunderAccount.Primary_Contact__r.Email);   
        system.assertEquals(objAllocation1.Trustee__c , objSupplierBuyerMap.Trustee__c);   
        system.assertEquals(objAllocation1.Applied_Funder_Discount_Profit_Share_Pct__c , GlobalTriggerHandler.coelesce(objAllocation1.Current_Funder_Discount_Profit_Share_Pct__c));
        
        objAllocation.amount__c = 200000;
        objAllocation.Status__c = 'Confirmed';
        Update objAllocation;

        objAllocation1 = [Select Id, Discount__c , Funder_Agent_Commission_Type__c , Funder_Agent_Commision_Percentage__c , funder_discount_amount__c , Customer_Email__c, Trustee__c, Current_Funder_Discount_Profit_Share_Pct__c, Applied_Funder_Discount_Profit_Share_Pct__c from Invoice_Allocation__c where Id =: objAllocation.Id];
        System.debug('****** objAllocation1 ==  '+objAllocation1); 
        system.assertEquals(objAllocation1.funder_discount_amount__c , objAllocation1.Discount__c);  
        
    }
        
}