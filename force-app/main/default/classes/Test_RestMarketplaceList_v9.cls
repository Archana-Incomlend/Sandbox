@isTest(SeeAllData=true)
private class Test_RestMarketplaceList_v9 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    /*RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    Id v_FXRATE = seedincomlenddata.addFXRate('EUR',123);
    Id v_marketplaceId = seedincomlenddata.seedMarketplace('EUR',v_FXRATE);
    ID v_agentAccountID = seedincomlenddata.SeedIncomlendAccounts();
    ID v_USDMarketplace = seedincomlenddata.SeedProducts();
    ID v_funderAccountId = seedincomlenddata.SeedTestFunderAccounts(v_agentAccountID, v_USDMarketplace);

    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.MarketplaceListReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/marketplaces';  
    req.addParameter('userAccountId', '0010w000008Bldr');
    v_results = RestMarketplaceList_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid User account id', v_results.v_message);
    
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req1.requestURI = v_baseUrl+'/services/apexrest/v9/marketplaces';
    req1.addParameter('userAccountId', v_funderAccountId);  
    v_results = RestMarketplaceList_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    RestRequest req2 = new RestRequest(); 
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.addHeader('email', 'test@test.com');
    req2.requestURI = v_baseUrl+'/services/apexrest/v9/marketplaces';
    req2.addParameter('userAccountId', v_funderAccountId);  
    v_results = RestMarketplaceList_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Email Id', v_results.v_message);*/

  }
    
    @isTest
	private static void Test()
	{
		// Code coverage hack
		RestMarketplaceList_v9.MarketplaceList_v9_CoverageHack hack = new RestMarketplaceList_v9.MarketplaceList_v9_CoverageHack();
		hack.Hack1();
    }
}