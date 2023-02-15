@isTest(SeeAllData=true)
private class Test_RestUserEwallet_v8_2 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    ID v_AgentAccountId = seedincomlenddata.SeedIncomlendAccounts();
    ID v_USDMarketplace = seedincomlenddata.SeedProducts();
    ID v_funderAccountId = seedincomlenddata.SeedTestFunderAccounts(v_AgentAccountId, v_USDMarketplace);
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.EwalletListReturnClass v_results;
        
    req.requestURI = v_baseUrl+'/v8.2/ewallet';   
    req.addParameter('accountId', '0010k000008v');
    v_results = RestUserEwallet_v8_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user account Id', v_results.v_message);
        
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req1.requestURI = v_baseUrl+'/v8.2/ewallet';
    req1.addParameter('accountId', v_funderAccountId);
    v_results = RestUserEwallet_v8_2.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    RestRequest req2 = new RestRequest(); 
    req2.addHeader('email', 'test@test.com');
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/v8.2/ewallet';   
    req2.addParameter('accountId', v_funderAccountId);
    v_results = RestUserEwallet_v8_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Email Id', v_results.v_message);

  }

}