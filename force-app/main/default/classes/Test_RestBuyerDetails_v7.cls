@isTest(SeeAllData=true)
private class Test_RestBuyerDetails_v7 {

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
       
    GlobalMethods.AccountReturnClass v_results;
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/buyer/user/0010k000008v';      
    v_results = RestBuyerDetails_v7.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user account id', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/buyer/'+v_funderAccountId;      
    v_results = RestBuyerDetails_v7.doGet();
    System.assertEquals('true', v_results.v_success);

  }

}