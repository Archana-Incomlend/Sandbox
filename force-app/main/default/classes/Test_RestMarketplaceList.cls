@isTest(SeeAllData=true)
private class Test_RestMarketplaceList {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    Id FXRATE = seedincomlenddata.addFXRate('EUR',123);
    Id MARKETPLACE = seedincomlenddata.seedMarketplace('EUR',FXRATE);
    
    ID AgentID;
    AgentID = seedincomlenddata.SeedIncomlendAccounts();
      
    ID USDMarketplace;
    USDMarketplace = seedincomlenddata.SeedProducts();
    ID funderID = seedincomlenddata.SeedTestFunderAccounts(AgentID, USDMarketplace);

    req.requestURI = baseUrl+'/services/apexrest/marketplaces/'+funderID;  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    RestMarketplaceList.ReturnClass results = RestMarketplaceList.doGet();
    
    System.assertEquals('true', results.success);
    /*System.assertEquals(3, results.records.size());*/
    System.assertEquals('Query executed successfully.', results.message);

  }

}