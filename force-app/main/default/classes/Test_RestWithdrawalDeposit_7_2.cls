@isTest(SeeAllData=true)
private class Test_RestWithdrawalDeposit_7_2 {

  static {
    // setup test data  
  }

  static testMethod void testDoPost() {

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();            
    ID v_agentAccountId = seedincomlenddata.SeedIncomlendAccounts();
    ID v_USDMarketplace = seedincomlenddata.SeedProducts();
    ID v_funderAccountId = seedincomlenddata.SeedTestFunderAccounts(v_agentAccountId, v_USDMarketplace);
    //seedincomlenddata.createTransactions(v_funderAccountId, '70.Deposit');
    Id v_banckAccountId = seedincomlenddata.makeBankAcccountFunder(v_funderAccountId);
    Double v_amount = 1000;
    String v_notes = 'test notes';
           
    req.requestURI = baseUrl+'/7.2/withdrawaldeposit';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.WithdrawalDepositReturnClass v_results;
    
    v_results = RestWithdrawalDeposit_7_2.doPost('deposit', v_funderAccountId, 'AAA', v_banckAccountId, v_amount, v_notes);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid currency', v_results.v_message);
    
    v_results = RestWithdrawalDeposit_7_2.doPost('withdrawal', v_funderAccountId, 'USD', v_banckAccountId, -1, v_notes);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid amount', v_results.v_message);
    
    v_results = RestWithdrawalDeposit_7_2.doPost('withdrawal', v_funderAccountId, 'USD', '0010k00000A0azt', v_amount, v_notes);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Bank account ID or Bank Account is not for logged in user', v_results.v_message);
            
    v_results = RestWithdrawalDeposit_7_2.doPost('withdrawal', v_funderAccountId, 'USD', v_banckAccountId, v_amount, v_notes);
    System.assertEquals('true', v_results.v_success);
    
    v_results = RestWithdrawalDeposit_7_2.doPost('deposit', v_funderAccountId, 'USD', v_banckAccountId, v_amount, v_notes);
    System.assertEquals('true', v_results.v_success);
    
  }

}