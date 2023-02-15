@isTest(SeeAllData=true)
private class Test_RestAgentStats_v9{

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    ID v_agentId =  seedincomlenddata.SeedIncomlendAccounts();
    ID v_USDMarketplace = seedincomlenddata.SeedProducts();
    ID v_funderAccountId = seedincomlenddata.SeedTestFunderAccounts(v_agentId, v_USDMarketplace);
    ID v_supplierAccountId = seedincomlenddata.SeedTestAccounts(v_agentId, v_USDMarketplace);
    GlobalMethods_v9.DecimalMapReturnClass v_results;
    
    seedincomlenddata.createTransactions(v_agentId, '061.Agent Commission on Transaction Fee');
    seedincomlenddata.createTransactions(v_agentId, '051.Agent Commission on Discount Amount');
    seedincomlenddata.makeAllocation(v_supplierAccountId, v_funderAccountId);

    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/agent/stats';
    req.addParameter('accountId', '0010k000008v');
    v_results = RestAgentStats_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user account Id', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/agent/stats';
    req.addParameter('accountId', v_agentId);
    v_results = RestAgentStats_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}