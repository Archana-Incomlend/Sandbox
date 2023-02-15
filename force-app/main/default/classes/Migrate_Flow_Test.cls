@isTest
public class Migrate_Flow_Test {

    static testMethod void testBankBalance() {
        Map<String, Object> result = new Map<String, Object>(); 
        insert SeedTest.createAccount(result, 'Incomlend Operations', 'Internal');
        Bank_Account__c objBankAccount = SeedTest.createBankAccount(result, 'Incomlend Operations');
        insert objBankAccount;
        
        Bank_Account_Balance__c objBankAccountBalance = new Bank_Account_Balance__c();
        objBankAccountBalance.amount__c = 500000;
        objBankAccountBalance.As_of_DateTime__c = System.now();
        objBankAccountBalance.Bank_Account_Detail__c = objBankAccount.Id;
        insert objBankAccountBalance;
        // no longer in use
        // System.assertEquals(objBankAccountBalance.amount__c, [SELECT Latest_Balance__c FROM Bank_Account__c WHERE Id =: objBankAccount.Id].Latest_Balance__c);
    }

    static testMethod void testFxRate() {

        String CCY = 'EUR';
        Map<String, Object> result = SeedTest.init(null, CCY, ''); 
        Test.startTest();


        Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice'); 
        invoice.Actual_Repayment_Received_Date__c = System.today();
        invoice.Actual_Repayment_Amount__c = invoice.invoice_amount__c;
        invoice.Phase__c = '4:CLOSED';
        invoice.Status__c = 'Paid';    
        update invoice;

        RefreshFXRates.isNeedRunTrigger = true;
        FX_Rates__c rate = ((FX_Rates__c)result.get('rate' + CCY)).clone(false, true, false, false);
        rate.date__c = System.today();
        insert rate;
        System.assertEquals(rate.Id, [SELECT FX_Rate__c FROM Invoice_Finance_Deal__c WHERE Id =: invoice.Id].FX_Rate__c);
        RefreshFXRates.isNeedRunTrigger = false;
        Test.stopTest();
    }

    static testMethod void testMapLegalDocument() {
        Map<String, Object> result = new Map<String, Object>();
        String CCY = 'USD';
        SeedTest.createMarketPlace(result, CCY);
        SeedTest.createAccountingPeriod(result);
        String funderId = 'Funder';
        List<Account> listAccount = new List<Account>();
        for (String accountType : new String[] {'Supplier', 'Buyer' } ) {
            String name = accountType;
            insert SeedTest.createAccount(result, name, accountType);
            insert SeedTest.createBankAccount(result, name);
            insert SeedTest.createEWallet(result, name, CCY);
            insert SeedTest.createEWalletTrustee(result, name, CCY);
        }
        insert SeedTest.createMap(result, '', 'Supplier', 'Buyer', CCY, 0.8, '');

        Map_Supporting_Document__c mapLegalDocument = new Map_Supporting_Document__c();
        mapLegalDocument.Supplier_Buyer_Map__c = SeedTest.getId(result, 'map');
        insert mapLegalDocument;
        Supplier_Buyer_Map__c supplierBuyerMap = [SELECT Id, Name, Buyer__c, Supplier__c, Buyer__r.Account_Name_for_unique_index__c, Supplier__r.Account_Name_for_unique_index__c FROM Supplier_Buyer_Map__c WHERE Id =: mapLegalDocument.Supplier_Buyer_Map__c];
        mapLegalDocument = [SELECT Id, Supplier_Buyer_Map__c, Buyer__c, Supplier__c, Buyer_name__c, Supplier_name__c FROM Map_Supporting_Document__c WHERE Id =: mapLegalDocument.Id];
        System.assertEquals(mapLegalDocument.Buyer__c, supplierBuyerMap.Buyer__c);
        System.assertEquals(mapLegalDocument.Supplier__c, supplierBuyerMap.Supplier__c);
        System.assertEquals(mapLegalDocument.Buyer_name__c, supplierBuyerMap.Buyer__r.Account_Name_for_unique_index__c);
        System.assertEquals(mapLegalDocument.Supplier_name__c, supplierBuyerMap.Supplier__r.Account_Name_for_unique_index__c);
    }

    static testMethod void testSalesOpportunity() {
        Lead testLead = new Lead();
        testLead.FirstName = 'Test';
        testLead.LastName = 'Lead';
        testLead.Company = 'COMPANY LTD';
        testLead.OwnerId = UserInfo.getUserID();

        Lead objLeadSupplier = testLead.clone(false, true, false, false);
        objLeadSupplier.FirstName = 'Supplier';
        objLeadSupplier.Country = 'Austria';
        objLeadSupplier.Date_Termsheet_Sent__c = System.today().addDays(-2);
        insert objLeadSupplier;

        Lead objLeadBuyer = testLead.clone(false, true, false, false);
        objLeadBuyer.FirstName = 'Buyer';
        objLeadBuyer.Country = 'Germany';
        objLeadBuyer.Credit_Limit_Provided_by_Insurer__c = 2000000;
        objLeadBuyer.Credit_Limit_requested__c = 2000000;
        objLeadBuyer.Insurer_actual_response_date__c = System.today().addDays(-10);
        objLeadBuyer.Date_Termsheet_Sent__c = System.today().addDays(-4);
        insert objLeadBuyer;
        
        Invoice_Opportunity__c salesOpportunity = new Invoice_Opportunity__c();
        salesOpportunity.Lead_Name__c = objLeadBuyer.Id;
        salesOpportunity.Lead_Name_Supplier__c = objLeadSupplier.Id;
        salesOpportunity.Opportunity_Status__c = 'Pipeline';
        salesOpportunity.Product_type__c = 'Factoring';// 'Factoring Insured';
        insert salesOpportunity;

        salesOpportunity.First_invoice_Amount__c = 500000;
        salesOpportunity.Date_First_Invoice__c = System.today();
        salesOpportunity.Expected_Tenor__c = 90;
        salesOpportunity.SDR__c = 8;
        update salesOpportunity;
        System.assert(([SELECT Id, Important_Notes__c FROM Invoice_Opportunity__c WHERE Id =: salesOpportunity.Id].Important_Notes__c).indexOf('Forecast Looks Completed') != -1);
        Invoice_Opportunity__c temp;

        temp = salesOpportunity.clone(true, true, false, false);
        temp.First_invoice_Amount__c = null;
        update temp;
        System.assert(([SELECT Id, Important_Notes__c FROM Invoice_Opportunity__c WHERE Id =: salesOpportunity.Id].Important_Notes__c).indexOf('Forecast Non Completed') != -1);

        temp = salesOpportunity.clone(true, true, false, false);
        temp.Date_First_Invoice__c = null;
        update temp;
        System.assert(([SELECT Id, Important_Notes__c FROM Invoice_Opportunity__c WHERE Id =: salesOpportunity.Id].Important_Notes__c).indexOf('Forecast Non Completed') != -1);

        temp = salesOpportunity.clone(true, true, false, false);
        temp.Expected_Tenor__c = null;
        update temp;
        System.assert(([SELECT Id, Important_Notes__c FROM Invoice_Opportunity__c WHERE Id =: salesOpportunity.Id].Important_Notes__c).indexOf('Forecast Non Completed') != -1);

        temp = salesOpportunity.clone(true, true, false, false);
        temp.SDR__c = null;
        update temp;
        System.assert(([SELECT Id, Important_Notes__c FROM Invoice_Opportunity__c WHERE Id =: salesOpportunity.Id].Important_Notes__c).indexOf('Forecast Non Completed') != -1);

        temp = salesOpportunity.clone(false, true, false, false);
        insert temp;
        System.assert(![SELECT Id, OIP_Started__c FROM Invoice_Opportunity__c WHERE Id =: salesOpportunity.Id].OIP_Started__c);
        System.assertNotEquals('OIP', [SELECT Id, Opportunity_Status__c FROM Invoice_Opportunity__c WHERE Id =: salesOpportunity.Id].Opportunity_Status__c);
        temp.Date_Term_sheet_Signedt__c = System.today();
        update temp;
        System.assert([SELECT Id, OIP_Started__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].OIP_Started__c);
        System.assertEquals('OIP', [SELECT Id, Opportunity_Status__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Opportunity_Status__c);
        
        // workflow deleted
        // temp = salesOpportunity.clone(false, true, false, false);
        // temp.Opportunity_Status__c = 'OIP';
        // insert temp;
        // temp.Process_Status__c = 'Invoice submitted';
        // update temp;
        // System.assertEquals('Active', [SELECT Id, Opportunity_Status__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Opportunity_Status__c);

        objLeadSupplier.Date_Termsheet_Signed__c = System.today().addDays(-1);
        objLeadBuyer.Date_Termsheet_Signed__c = System.today().addDays(-3);
        update (new Lead[] {objLeadSupplier, objLeadBuyer});
        temp = salesOpportunity.clone(false, true, false, false);
        insert temp;

        // Update opporunity Supplychain (Factoring) (buyer name not set)
        System.assertEquals(objLeadBuyer.Country, [SELECT Id, Buyer_Country__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Buyer_Country__c);
        System.assertEquals(objLeadBuyer.Company, [SELECT Id, Buyer_Name__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Buyer_Name__c);
        System.assertEquals(objLeadBuyer.Credit_Limit_Provided_by_Insurer__c, [SELECT Id, CL_Provided_by_insurer__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].CL_Provided_by_insurer__c);
        System.assertEquals(objLeadBuyer.Credit_Limit_requested__c, [SELECT Id, CL_Requested__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].CL_Requested__c);
        System.assertEquals(objLeadBuyer.Insurer_actual_response_date__c, [SELECT Id, Date_Answer_Insurer__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Answer_Insurer__c);
        // Update supplier opporunity Factoring seems to run ahead
        // System.assertEquals(objLeadBuyer.Date_Termsheet_Signed__c, [SELECT Id, Date_Term_sheet_Signedt__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Term_sheet_Signedt__c);
        // System.assertEquals(objLeadBuyer.Date_Termsheet_Sent__c, [SELECT Id, Date_Termsheet_Sent__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Termsheet_Sent__c);
        System.assertEquals(objLeadSupplier.Date_Termsheet_Signed__c, [SELECT Id, Date_Term_sheet_Signedt__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Term_sheet_Signedt__c);
        System.assertEquals(objLeadSupplier.Date_Termsheet_Sent__c, [SELECT Id, Date_Termsheet_Sent__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Termsheet_Sent__c);
        System.assertEquals(objLeadSupplier.Country, [SELECT Id, Supplier_Country__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Supplier_Country__c);
        System.assertEquals(objLeadSupplier.Company, [SELECT Id, Supplier_Name__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Supplier_Name__c);
        
        // Update opporunity Supplychain (Reverse Factoring) (buyer name not set)
        temp = salesOpportunity.clone(false, true, false, false);
        temp.Product_type__c = 'Supply Chain Finance';// 'Reverse Factoring Insured';
        insert temp;
        System.assertEquals(objLeadBuyer.Country, [SELECT Id, Buyer_Country__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Buyer_Country__c);
        System.assertEquals(objLeadBuyer.Company, [SELECT Id, Buyer_Name__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Buyer_Name__c);
        System.assertEquals(objLeadBuyer.Credit_Limit_Provided_by_Insurer__c, [SELECT Id, CL_Provided_by_insurer__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].CL_Provided_by_insurer__c);
        System.assertEquals(objLeadBuyer.Credit_Limit_requested__c, [SELECT Id, CL_Requested__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].CL_Requested__c);
        System.assertEquals(objLeadBuyer.Insurer_actual_response_date__c, [SELECT Id, Date_Answer_Insurer__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Answer_Insurer__c);
        System.assertEquals(objLeadBuyer.Date_Termsheet_Signed__c, [SELECT Id, Date_Term_sheet_Signedt__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Term_sheet_Signedt__c);
        System.assertEquals(objLeadBuyer.Date_Termsheet_Sent__c, [SELECT Id, Date_Termsheet_Sent__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Termsheet_Sent__c);
        System.assertEquals(objLeadSupplier.Country, [SELECT Id, Supplier_Country__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Supplier_Country__c);
        System.assertEquals(objLeadSupplier.Company, [SELECT Id, Supplier_Name__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Supplier_Name__c);
        
        temp = salesOpportunity.clone(false, true, false, false);
        temp.Buyer_name__c = objLeadBuyer.Company;
        temp.Lead_Name_Supplier__c = null;
        insert temp;
        // Update buyer opporunity Factoring (buyer lead status set, supplier lead status unset)
        System.assertEquals(objLeadBuyer.Country, [SELECT Id, Buyer_Country__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Buyer_Country__c);
        System.assertEquals(objLeadBuyer.Company, [SELECT Id, Buyer_Name__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Buyer_Name__c);
        System.assertEquals(objLeadBuyer.Credit_Limit_Provided_by_Insurer__c, [SELECT Id, CL_Provided_by_insurer__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].CL_Provided_by_insurer__c);
        System.assertEquals(objLeadBuyer.Credit_Limit_requested__c, [SELECT Id, CL_Requested__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].CL_Requested__c);
        System.assertEquals(objLeadBuyer.Insurer_actual_response_date__c, [SELECT Id, Date_Answer_Insurer__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Answer_Insurer__c);

        temp.Lead_Name_Supplier__c = objLeadSupplier.Id;
        update temp;
        // Update supplier opporunity Factoring (supplier name not set)
        System.assertEquals(objLeadSupplier.Date_Termsheet_Signed__c, [SELECT Id, Date_Term_sheet_Signedt__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Term_sheet_Signedt__c);
        System.assertEquals(objLeadSupplier.Date_Termsheet_Sent__c, [SELECT Id, Date_Termsheet_Sent__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Date_Termsheet_Sent__c);
        System.assertEquals(objLeadSupplier.Country, [SELECT Id, Supplier_Country__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Supplier_Country__c);
        System.assertEquals(objLeadSupplier.Company, [SELECT Id, Supplier_Name__c FROM Invoice_Opportunity__c WHERE Id =: temp.Id].Supplier_Name__c);
    }
}