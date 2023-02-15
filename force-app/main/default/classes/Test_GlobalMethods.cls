@isTest(SeeAllData=true)
private class Test_GlobalMethods{

    static testmethod void test_GlobalMethods() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        ID v_agentAccountId =  seedincomlenddata.SeedIncomlendAccounts();
        GlobalMethods.AccountReturnClass v_results1 = GlobalMethods.getUserData(v_agentAccountId);
        System.assertEquals('true', v_results1.v_success);
        System.assertEquals('Query executed successfully.', v_results1.v_message);
       
        ID v_USDMarketplace = seedincomlenddata.SeedProducts();
        ID v_funderAccountId = seedincomlenddata.SeedTestFunderAccounts(v_agentAccountId, v_USDMarketplace);
        Id v_banckAccountId = seedincomlenddata.makeBankAcccountFunder(v_funderAccountId);
        
        GlobalMethods.ReturnClass v_results22 = GlobalMethods.validateIsAgentForUserAccount(v_agentAccountId, v_funderAccountId);
        System.assertEquals('true', v_results22.v_success);
        System.assertEquals('Correct Agent Id', v_results22.v_message);
        
        GlobalMethods.AccountReturnClass v_results23 = GlobalMethods.getUserData(v_funderAccountId);
        System.assertEquals('true', v_results23.v_success);
        System.assertEquals('Query executed successfully.', v_results23.v_message);
        
        boolean v_results24 = GlobalMethods.validateUserAccess(v_funderAccountId, v_funderAccountId);
                
        GlobalMethods.BankAccountReturnClass v_results2 = GlobalMethods.getBankAccountData(v_banckAccountId, v_funderAccountId);
        System.assertEquals('true', v_results2.v_success);
        System.assertEquals('Query executed successfully.', v_results2.v_message);
        
        ID v_invoiceId =  seedincomlenddata.makeInvoice(1); 
        GlobalMethods.InvoiceReturnClass v_results3 = GlobalMethods.getInvoiceData(v_invoiceId);
        System.assertEquals('true', v_results3.v_success);
        System.assertEquals('Query executed successfully.', v_results3.v_message);
        
        GlobalMethods.AccountReturnClass v_results4 = GlobalMethods.getUserWalletData(v_agentAccountId);
        System.assertEquals('true', v_results4.v_success);
        System.assertEquals('Query executed successfully.', v_results4.v_message);
        
        ID v_contactId = seedincomlenddata.createFunderContact(v_funderAccountId);
        GlobalMethods.addContactLog(v_contactId, v_invoiceId, 'login', 'test', 'test');
        
        Double v_availableEwallet = GlobalMethods.getAvailableEwallet(v_funderAccountId, 'XXX');
       
        
        Boolean v_status1 = GlobalMethods.isValidId(v_contactId);
        
        Boolean v_status2 = GlobalMethods.isvalidCurrency('USD');        
        
        GlobalMethods.sendReservationSlack('test', v_invoiceId, 2000, 'false', system.now(), true, 'test', 2000);
       
        GlobalMethods.createReservationLog(v_contactId, v_invoiceId, 2000, 'false', system.now(), true, 2000);
        
        String v_maskedAccountNumber = GlobalMethods.createMaskedAccountNumber('454448745587744415');
        
        GlobalMethods.ReturnClass v_results5 = new GlobalMethods.ReturnClass('true', 'test');
        GlobalMethods.AccountListReturnClass v_results6 = new GlobalMethods.AccountListReturnClass('true', 'test', null);
        GlobalMethods.ContactListReturnClass v_results7 = new GlobalMethods.ContactListReturnClass('true', 'test', null);
        GlobalMethods.DecimalMapReturnClass v_results8 = new GlobalMethods.DecimalMapReturnClass('true', 'test', null);     
        GlobalMethods.InvoiceReturnClass v_results9 = new GlobalMethods.InvoiceReturnClass('true', 'test', null);  
        GlobalMethods.BuyerMapReturnClass v_results10 = new GlobalMethods.BuyerMapReturnClass('true', 'test', null); 
        GlobalMethods.BuyerMapListReturnClass v_results11 = new GlobalMethods.BuyerMapListReturnClass('true', 'test', null);
        GlobalMethods.InvoiceListReturnClass v_results12 = new GlobalMethods.InvoiceListReturnClass('true', 'test', null);
        GlobalMethods.AllocationListReturnClass v_results13 = new GlobalMethods.AllocationListReturnClass('true', 'test', null);
        GlobalMethods.MarketplaceReturnClass v_results14 = new GlobalMethods.MarketplaceReturnClass('true', 'test', null);
        GlobalMethods.MarketplaceListReturnClass v_results15 = new GlobalMethods.MarketplaceListReturnClass('true', 'test', null);
        GlobalMethods.BankAccountListReturnClass v_results16 = new GlobalMethods.BankAccountListReturnClass('true', 'test', null);
        GlobalMethods.BankAccountReturnClass v_results17 = new GlobalMethods.BankAccountReturnClass('true', 'test', null);
        GlobalMethods.TransactionReturnClass v_results18 = new GlobalMethods.TransactionReturnClass('true', 'test', null);
        GlobalMethods.TransactionListReturnClass v_results19 = new GlobalMethods.TransactionListReturnClass('true', 'test', null);
        GlobalMethods.AccountReturnClass v_results20 = new GlobalMethods.AccountReturnClass('true', 'test', null);
        map<String,Decimal> v_result21 = GlobalMethods.createAllocationResponse(500000, v_results3.v_records, 2000);
        GlobalMethods.AccountReturnClass v_results25 = new GlobalMethods.AccountReturnClass('true', 'test', null);
        GlobalMethods.StringMapReturnClass v_results26 = new GlobalMethods.StringMapReturnClass('true', 'test', null);
        GlobalMethods.ListMapReturnClass v_results27 = new GlobalMethods.ListMapReturnClass('true', 'test', null);
        GlobalMethods.MapProductListReturnClass v_results28 = new GlobalMethods.MapProductListReturnClass('true', 'test', null);
        GlobalMethods.MapSupportingDocsListReturnClass v_results29 = new GlobalMethods.MapSupportingDocsListReturnClass('true', 'test', null);
        GlobalMethods.WithdrawalDepositReturnClass v_results30 = new GlobalMethods.WithdrawalDepositReturnClass('true', 'test', null);
        GlobalMethods.EwalletListReturnClass v_results31 = new GlobalMethods.EwalletListReturnClass('true', 'test', null);
        
        ID v_accountId = GlobalMethods.getLoggedinUserAccountId('funder@test.com');
        GlobalMethods.ContactReturnClass v_results32 = GlobalMethods.getLoggedinUserData('funder@test.com');
         
    }
}