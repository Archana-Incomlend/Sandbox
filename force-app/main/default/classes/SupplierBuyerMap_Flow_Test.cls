@isTest
private class SupplierBuyerMap_Flow_Test {
    static testMethod void myTest() {
        
        Account objSupplierAgent = new Account();
        objSupplierAgent.Name = 'Test Supplier Agent Account';
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
        insert SupplierAccount;
        
        
        Account objBuyerAgent = new Account();
        objBuyerAgent.Name = 'Test Buyer Agent Account';
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
        insert objMarketplace;
        
        Incomlend_product__c objProduct = new Incomlend_product__c();
        objProduct.Name = 'Standard Insured - USD' ;
        objProduct.launch_date__c = Date.newInstance(2000, 01, 01);
        objProduct.CCYs__c = 'USD';
        objProduct.months_relationship_with_buyer__c = 12;
        objProduct.Auction_Type__c = 'Fixed Discount Rate';
        objProduct.approved__c = true;
        objProduct.insured__c = true;
        insert objProduct;
        
        Supplier_Buyer_Map__c objSupplierBuyerMap = new Supplier_Buyer_Map__c();

        objSupplierBuyerMap.Buyer__c = BuyerAccount.Id;
        objSupplierBuyerMap.Supplier__c = SupplierAccount.Id;
        objSupplierBuyerMap.Incomlend_product__c = objProduct.Id;
        objSupplierBuyerMap.Marketplace__c = objMarketplace.Id;
        objSupplierBuyerMap.Trustee__c = 'Amicorp Trust';
        objSupplierBuyerMap.buyer_supplier_map_approved__c = true;
        objSupplierBuyerMap.map_onboarding_stage__c = '90.Onboarded';
        objSupplierBuyerMap.Inprogress_invoice_amount_usd_equiv__c = 0;
        objSupplierBuyerMap.Ops_Owner__c = null;
        objSupplierBuyerMap.accepted_incoterms__c = 'EXW;FOB;CFR;CIF';
        objSupplierBuyerMap.CL_Limit_requested_for_this_Map__c = 1000000;
        objSupplierBuyerMap.CL_Incomlend_for_this_Map__c = 1000000;
        objSupplierBuyerMap.Geographical_zone__c = 'Zone 1';
        objSupplierBuyerMap.Overdue_Additional_Discount_rate__c = 0;
        objSupplierBuyerMap.Funder_Discount_Rate__c = 0; 
        objSupplierBuyerMap.Minimum_Spread__c = 0;
        objSupplierBuyerMap.Supplier_Discount_Rate__c = 0.75;
        
        insert objSupplierBuyerMap;
        
        Supplier_Buyer_Map__c updatedSupplierBuyerMap = [Select Id, Active__c from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap.Id];
        
        System.assertEquals(updatedSupplierBuyerMap.Active__c , True);
        
        objSupplierBuyerMap.Credit_Committee_Status__c = 'Approved';
        objSupplierBuyerMap.General_Status_Map__c = 'Dormant';
        update objSupplierBuyerMap;
        objSupplierBuyerMap.General_Status_Map__c = 'Active'; // to be cloned later
        
        updatedSupplierBuyerMap = [Select Id, Active__c, Buyer_Sales_Zone__c, Supplier_Zone__c, Account_Agent__c, supplier_contacts_for_invoice_approval__c from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap.Id];

        System.assertEquals(updatedSupplierBuyerMap.Buyer_Sales_Zone__c , 0);
        System.assertEquals(updatedSupplierBuyerMap.Supplier_Zone__c , 100);
        System.assertEquals(updatedSupplierBuyerMap.Active__c , False);
        System.assert(updatedSupplierBuyerMap.supplier_contacts_for_invoice_approval__c.equalsIgnoreCase(SupplierAccount.Primary_contact_email__c));
        System.assertEquals(updatedSupplierBuyerMap.Account_Agent__c , objSupplierAgent.Id);
        
        Marketplace__c objMarketPlaceReverse = objMarketPlace.clone(false, true, false, false);
        objMarketPlaceReverse.Name = 'USD Reverse Factoring';
        insert objMarketPlaceReverse; 
        
        Incomlend_product__c objProductReverse = objProduct.clone(false, true, false, false);
        objProductReverse.Name = 'Reverse Factoring USD Insured' ;
        objProduct.Auction_Type__c = 'Auction';
        insert objProductReverse;

        BuyerAccount.Trade_Model__c = 'R-Factoring Buyer';
        update BuyerAccount;
        
        Supplier_Buyer_Map__c objSupplierBuyerMap1 = objSupplierBuyerMap.clone(false, true, false, false);

        objSupplierBuyerMap1.Incomlend_product__c = objProductReverse.Id;
        objSupplierBuyerMap1.Marketplace__c = objMarketPlaceReverse.Id;
        objSupplierBuyerMap1.Recommended_Discount_Rate__c = 0.75;
        
        insert objSupplierBuyerMap1;
        
        objSupplierBuyerMap1 = [Select Id, Active__c, Buyer_Sales_Zone__c, Supplier_Zone__c, supplier_contacts_for_invoice_approval__c, Supplier_Discount_Rate__c, Account_Agent__c from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap1.Id];
        
        System.assertEquals(objSupplierBuyerMap1.Account_Agent__c , BuyerAccount.Agent__c);
        System.assertEquals(objSupplierBuyerMap1.Active__c , True);
        System.assertEquals(objSupplierBuyerMap1.Supplier_Discount_Rate__c , 0.75);
        System.assertEquals(objSupplierBuyerMap1.Buyer_Sales_Zone__c , 50); 
        System.assertEquals(objSupplierBuyerMap1.Supplier_Zone__c , 50);

        updatedSupplierBuyerMap.Select_View__c = 'Risk';
        update updatedSupplierBuyerMap;
        
        updatedSupplierBuyerMap = [Select Id, RecordTypeId, Recordtype.DeveloperName  from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap.Id];
        System.assertEquals(updatedSupplierBuyerMap.Recordtype.DeveloperName , 'Risk');
        
        updatedSupplierBuyerMap.Select_View__c = 'Operations';
        update updatedSupplierBuyerMap;
        
        updatedSupplierBuyerMap = [Select Id, RecordTypeId, Recordtype.DeveloperName  from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap.Id];
        System.assertEquals(updatedSupplierBuyerMap.Recordtype.DeveloperName , 'Supplier_Buyer_Map');
        
        updatedSupplierBuyerMap.Select_View__c = 'Funders';
        update updatedSupplierBuyerMap;
        
        updatedSupplierBuyerMap = [Select Id, RecordTypeId, Recordtype.DeveloperName  from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap.Id];
        System.assertEquals(updatedSupplierBuyerMap.Recordtype.DeveloperName , 'Funders');
        
        updatedSupplierBuyerMap.Select_View__c = 'External';
        update updatedSupplierBuyerMap;
        
        updatedSupplierBuyerMap = [Select Id, RecordTypeId, Recordtype.DeveloperName  from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap.Id];
        System.assertEquals(updatedSupplierBuyerMap.Recordtype.DeveloperName , 'Extern');
        
        updatedSupplierBuyerMap.Credit_Committee_Status__c = 'Approved';
        updatedSupplierBuyerMap.map_onboarding_stage__c = '05.Funders feedback Positive';
        updatedSupplierBuyerMap.Credit_Committee_Expected_Date__c = system.today();
        updatedSupplierBuyerMap.CL_Incomlend_for_this_Map__c = 2000000;
        update updatedSupplierBuyerMap;
        
        updatedSupplierBuyerMap = [Select Id, Name, Name_Indexed__c, Previous_CL_Incomlend__c, Credit_Committee_Approval_Date__c from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap.Id];
        System.assertEquals(updatedSupplierBuyerMap.Credit_Committee_Approval_Date__c , system.today());
        System.assertEquals(updatedSupplierBuyerMap.Previous_CL_Incomlend__c , 1000000);
       
        Account objSupplierAgentNew = objSupplierAgent.clone(false, true, false, false);
        objSupplierAgentNew.Name = 'Test Supplier Agent Account New';
        insert objSupplierAgentNew;
        SupplierAccount.Primary_contact_email__c = 'testSupplierNew@primarycontact.com';
        SupplierAccount.Agent__c = objSupplierAgentNew.Id;
        update SupplierAccount;
        updatedSupplierBuyerMap = [Select Id, supplier_contacts_for_invoice_approval__c, Account_Agent__c from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap.Id];
        System.assert(updatedSupplierBuyerMap.supplier_contacts_for_invoice_approval__c.equalsIgnoreCase(SupplierAccount.Primary_contact_email__c));
        System.assertEquals(updatedSupplierBuyerMap.Account_Agent__c , objSupplierAgentNew.Id);

    }
       
}