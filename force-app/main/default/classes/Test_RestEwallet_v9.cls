@isTest
private class Test_RestEwallet_v9 {

  @isTest
  private static void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    Map<String, Object> result = new Map<String,Object>();
    Account account = SeedTest.createAccount(result, 'Funder', 'Purchaser');
    insert account;
    insert SeedTest.createBankAccount(result, account.Name);
    String CCY = 'USD';
    SeedTest.createMarketPlace(result, CCY);
    insert SeedTest.createEWallet(result, account.Name, CCY);
    insert SeedTest.createEWalletTrustee(result, account.Name, CCY);
    SeedTest.createAccountingPeriod(result);
    insert SeedTest.createTransaction(result, 'Funder', CCY, null, null);
        
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.EwalletTrusteeListReturnClass v_results;
        
    req.requestURI = v_baseUrl+'/v9/ewallet';   
    req.addParameter('accountId', '0010k000008v');
    v_results = RestEwallet_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user account Id', v_results.v_message);
        
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req1.requestURI = v_baseUrl+'/v9/ewallet';
    req1.addParameter('accountId', account.Id);
    v_results = RestEwallet_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    req1.addParameter('trustee', 'Amicorp Trust');
    v_results = RestEwallet_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
      
    RestRequest req2 = new RestRequest(); 
    req2.addHeader('email', 'test@test.com');
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/v9/ewallet';   
    req2.addParameter('accountId', account.Id);
    v_results = RestEwallet_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Email Id', v_results.v_message);

  }

}