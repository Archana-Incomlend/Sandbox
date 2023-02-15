@isTest(SeeAllData=true)
private class Test_RestFunderStats_v7 {

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
    GlobalMethods.DecimalMapReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/funder/stats/USD/0010k000008v';
    v_results = RestFunderStats_v7.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid User Account Id', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/funder/stats/AAA/'+v_funderAccountId;
    v_results = RestFunderStats_v7.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid currency', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/funder/stats/USD/'+v_funderAccountId;
    v_results = RestFunderStats_v7.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}