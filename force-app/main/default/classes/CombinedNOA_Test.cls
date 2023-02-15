@isTest
private class CombinedNOA_Test {
    static testMethod void myTest() {
        
        Account FunderAccount = new Account();
        FunderAccount.Name = 'Test Funder Account';
        FunderAccount.onboarding_approved__c = true;
        FunderAccount.Address_Shipping_is_Address_Billing__c = false;
        FunderAccount.Type = 'Customer';
        FunderAccount.Sub_type__c = 'Purchaser';
        FunderAccount.onboarding_stage__c = '99.Onboarded';
        FunderAccount.Primary_contact_email__c = 'testFunder@primarycontact.com';
        insert FunderAccount;

        Account objSupplierAgent = new Account();
        objSupplierAgent.Name = 'Test Supplier Agent Account 1';
        objSupplierAgent.Type = 'Agent';
        objSupplierAgent.Primary_contact_email__c = 'Test@primaryContact.Com';
        insert objSupplierAgent;
        
        
        Account SupplierAccount = new Account();
        SupplierAccount.Name = 'Test Supplier Account';
        SupplierAccount.Agent__c = objSupplierAgent.Id;
        SupplierAccount.onboarding_approved__c = true;
        SupplierAccount.Address_Shipping_is_Address_Billing__c = false;
        SupplierAccount.Type = 'Supplier';
        SupplierAccount.Sub_type__c = 'Supplier';
        SupplierAccount.onboarding_stage__c = '99.Onboarded';
        SupplierAccount.Primary_contact_email__c = 'testSupplier@primarycontact.com';
        SupplierAccount.Credit_insurance_fee__c = 0.65;
        insert SupplierAccount;
        
        
        Account objBuyerAgent = new Account();
        objBuyerAgent.Name = 'Test Buyer Agent Account 1';
        objBuyerAgent.Type = 'Agent';
        objBuyerAgent.Primary_contact_email__c = 'Test@primaryContact.Com';
        insert objBuyerAgent;
        
        Account BuyerAccount = new Account();
        BuyerAccount.Name = 'Test Buyer Account';
        BuyerAccount.Agent__c = objBuyerAgent.Id;
        BuyerAccount.onboarding_approved__c = true;
        BuyerAccount.Address_Shipping_is_Address_Billing__c = false;
        BuyerAccount.Type = 'Buyer';
        BuyerAccount.Sub_type__c = 'Buyer';
        BuyerAccount.onboarding_stage__c = '99.Onboarded';
        BuyerAccount.Credit_Insurance_CCY__c = 'USD';
        BuyerAccount.Credit_Limit_Requested_CCY__c = 'USD';
        BuyerAccount.Credit_limit_insurance_currency__c = 1000000;
        BuyerAccount.Total_CL_Limit_from_Incomlend__c = 5000000;
        insert BuyerAccount;
        
        FX_Rates__c objFxRate = new FX_Rates__c();
        objFxRate.from_currency__c = 'USD';
        objFxRate.from_currency__c = 'USD';
        objFxRate.to_currency__c = 'USD';
        objFxRate.date__c = system.today();
        objFxRate.rate__c = 1;
        insert objFxRate;
        
        Marketplace__c objMarketPlace = new Marketplace__c();
        objMarketPlace.Name = 'USD insured';
        objMarketplace.Currency__c = 'USD';
        objMarketplace.latest_to_usd_rate__c = 1;
        objMarketplace.FX_Rate_for_MI__c = objFxRate.Id;
        objMarketplace.currency_symbol__c = '$';
        objMarketplace.minimum_purchase_amount__c = 0;
        objMarketplace.OwnerId = system.UserInfo.getUserId();
        insert objMarketplace;
        
        Incomlend_product__c objProduct = new Incomlend_product__c();
        objProduct.Name = 'Standart Insured - USD' ;
        objProduct.launch_date__c = Date.newInstance(2000, 01, 01);
        objProduct.CCYs__c = 'USD';
        objProduct.months_relationship_with_buyer__c = 12;
        objProduct.Auction_Type__c = 'Fixed Discount Rate';
        objProduct.approved__c = true;
        objProduct.insured__c = true;
        insert objProduct;
        
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
        
        
        eWallet__c objeWallet = new eWallet__c();
        objeWallet.Account__c = FunderAccount.Id;
        objeWallet.CCY__c = 'USD';
        objeWallet.Marketplace_for_FX__c = objMarketplace.Id;
        objeWallet.Bank_Account__c = objBankAccount.Id;
        objeWallet.Balance__c = 1000000;
        objeWallet.Reservations__c = 0;
        insert objeWallet;
                
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
        
        
        Integer amount = 1000;
        Decimal sdr = 0.85;
        Integer expectedFinancePeriod = 90;
        Integer actualFinancingPeriod = expectedFinancePeriod;
        Date dueDate = System.today().addDays(expectedFinancePeriod - 1);
        
        List<Invoice_finance_deal__c> lstInvoice = new List<Invoice_finance_deal__c>();
        
        for(integer intI = 0; intI <= 12; intI++){
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
            objInvoice.Phase__c = '1:PRE LISTING';
            objInvoice.Status__c = 'pending incomlend review';
            objInvoice.Real_Face_Value__c = amount;
            objInvoice.Invoice_amount__c = amount;
            objInvoice.requested_amount__c = amount * 0.9;
            objInvoice.Supplier_Buyer_Map__c = objSupplierBuyerMap.Id;
            objInvoice.Marketplace_link__c =  objMarketplace.Id;
            objInvoice.Actual_Repayment_Received_Date__c = System.today().addDays(actualFinancingPeriod - 1);
            objInvoice.External_View__c = False;
            lstInvoice.add(objInvoice);
        }
        insert lstInvoice;
        
        ApexPages.currentPage().getParameters().put('Id',objSupplierBuyerMap.Id);
        SelectInvoiceForNOAController objController = new SelectInvoiceForNOAController();
        
        //objController.updateSearchItemsMap();
        string InvoiceIds = '';
        for(Invoice_finance_deal__c objInvoice : lstInvoice){
            SelectInvoiceForNOAController.WrapperClass wrapper= new SelectInvoiceForNOAController.WrapperClass (objInvoice, true);
            objController.wrapperRecordList.add(wrapper);
            if(InvoiceIds == ''){
                InvoiceIds = objInvoice.Id;
            }else {
                InvoiceIds = InvoiceIds + ','+ objInvoice.Id;
            }
        }
        objController.objSupplierBuyerMap = objSupplierBuyerMap;
        objController.getTotalPages();
        objController.first();
        objController.last();
        objController.previous();
        objController.next() ;
        objController.getItems();
        objController.getNOAFormat();
        objController.setNOAFormat('NOA (Vamani)');
        objController.savePdf();
        objController.init();
        
        
        
        ApexPages.currentPage().getParameters().put('Id',objSupplierBuyerMap.Id);
        ApexPages.currentPage().getParameters().put('InvoiceIds',InvoiceIds);
        CombinedNOASaveAsPDF objCombinedNOASaveAsPDF = new CombinedNOASaveAsPDF();
    }
}