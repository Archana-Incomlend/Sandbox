@isTest
private class Test_RestWithdrawalDeposit_v9 {

  static {
    // setup test data  
  }

  static testMethod void testDoPost() {

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();            
    // ID v_agentAccountId = seedincomlenddata.SeedIncomlendAccounts();
    // ID v_USDMarketplace = seedincomlenddata.SeedProducts();
    // ID v_funderAccountId = seedincomlenddata.SeedTestFunderAccounts(v_agentAccountId, v_USDMarketplace);
    // //seedincomlenddata.createTransactions(v_funderAccountId, '70.Deposit');
    // Id v_banckAccountId = seedincomlenddata.makeBankAcccountFunder(v_funderAccountId);
    String CCY = 'USD';
    Double v_amount = 1000;
    String v_notes = 'test notes';
    String v_trustee = 'Amicorp Trust';

    Map<String, Object> result = new Map<String, Object>();
    SeedTest.createMarketPlace(result, CCY);
    SeedTest.createAccountingPeriod(result);
    String funderId = 'Funder';
    Account funder = SeedTest.createAccount(result, funderId, 'Purchaser');
    insert funder;
    Id v_funderAccountId = funder.Id;
    Bank_Account__c bankAccount = SeedTest.createBankAccount(result, funderId);
    insert bankAccount;
    Id v_banckAccountId = bankAccount.Id;
    insert SeedTest.createEWallet(result, funderId, CCY);
    insert SeedTest.createEWalletTrustee(result, funderId, CCY);
    insert SeedTest.createTransaction(result, null, funderId, CCY, v_amount, null);

    req.requestURI = baseUrl+'/v9/withdrawaldeposit';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.WithdrawalDepositReturnClass v_results;
    
    v_results = RestWithdrawalDeposit_v9.doPost('deposit', v_funderAccountId, 'AAA', v_banckAccountId, v_amount, v_notes, v_trustee);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid currency', v_results.v_message);
    
    v_results = RestWithdrawalDeposit_v9.doPost('withdrawal', v_funderAccountId, CCY, v_banckAccountId, -1, v_notes, v_trustee);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid amount', v_results.v_message);
    
    v_results = RestWithdrawalDeposit_v9.doPost('withdrawal', v_funderAccountId, CCY, '0010k00000A0azt', v_amount, v_notes, v_trustee);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Bank account ID or Bank Account is not for logged in user', v_results.v_message, v_trustee);
            
    v_results = RestWithdrawalDeposit_v9.doPost('withdrawal', v_funderAccountId, CCY, v_banckAccountId, v_amount, v_notes, v_trustee);
    System.assertEquals('true', v_results.v_success);
    
    v_results = RestWithdrawalDeposit_v9.doPost('deposit', v_funderAccountId, CCY, v_banckAccountId, v_amount, v_notes, v_trustee);
    System.assertEquals('true', v_results.v_success);
    
  }

}