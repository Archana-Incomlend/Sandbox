@isTest(SeeAllData=true)
private class Test_RestAgentStats_v3{

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    ID agentId =  seedincomlenddata.SeedIncomlendAccounts();
    ID USDMarketplace;
    USDMarketplace = seedincomlenddata.SeedProducts();
    ID funderID = seedincomlenddata.SeedTestFunderAccounts(agentId, USDMarketplace);
    ID supplierID = seedincomlenddata.SeedTestAccounts(agentId, USDMarketplace);
    
    seedincomlenddata.createTransactions(agentId, '061.Agent Commission on Transaction Fee');
    seedincomlenddata.createTransactions(agentId, '051.Agent Commission on Discount Amount');
    seedincomlenddata.makeAllocation(supplierID, funderID);

    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.requestURI = baseUrl+'/services/apexrest/v3/agent/stats/'+agentId;  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    Test.startTest();    
    RestAgentStats_v3.ReturnClass results = RestAgentStats_v3.doGet();
    Test.stopTest();
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}