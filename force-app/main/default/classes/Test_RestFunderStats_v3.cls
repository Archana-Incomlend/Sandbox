@isTest(SeeAllData=true)
private class Test_RestFunderStats_v3 {

  static testMethod void testDoGet() {

Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

    ID AgentID;
    AgentID = seedincomlenddata.SeedIncomlendAccounts();
      
    ID USDMarketplace;
    USDMarketplace = seedincomlenddata.SeedProducts();
    ID funderID = seedincomlenddata.SeedTestFunderAccounts(AgentID, USDMarketplace);

    req.requestURI = baseUrl+'/services/apexrest/v1/funder/stats/USD/'+funderID;
    System.debug('URL: '+ req.requestURI);
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    RestFunderStats_v3.ReturnClass results = RestFunderStats_v3.doGet();
    
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}