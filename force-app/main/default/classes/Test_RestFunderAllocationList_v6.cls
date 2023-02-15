@isTest(SeeAllData=true)
private class Test_RestFunderAllocationList_v6 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

    ID AgentID;
    AgentID = seedincomlenddata.SeedIncomlendAccounts();
      
    ID USDMarketplace;
    USDMarketplace = seedincomlenddata.SeedProducts();
    ID funderID = seedincomlenddata.SeedTestFunderAccounts(AgentID, USDMarketplace);
            
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    RestFunderAllocationList_v6.ReturnClass results;
    
    req.requestURI = baseUrl+'/services/apexrest/v6/user/invoiceallocations/USD/inprogress/0010k000008v'; 
    results = RestFunderAllocationList_v6.doGet();
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid user ID', results.message);
    
    req.requestURI = baseUrl+'/services/apexrest/v6/user/invoiceallocations/AAA/inprogress/'+funderID; 
    results = RestFunderAllocationList_v6.doGet();
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid currency', results.message);
    
    req.requestURI = baseUrl+'/services/apexrest/v6/user/invoiceallocations/USD/phase/'+funderID; 
    results = RestFunderAllocationList_v6.doGet();
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid phase', results.message);
    
    req.requestURI = baseUrl+'/services/apexrest/v6/user/invoiceallocations/USD/onmarketplace/'+funderID; 
    results = RestFunderAllocationList_v6.doGet();
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);
    
    req.requestURI = baseUrl+'/services/apexrest/v6/user/invoiceallocations/USD/inprogress/'+funderID; 
    results = RestFunderAllocationList_v6.doGet();
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);
    
    req.requestURI = baseUrl+'/services/apexrest/v6/user/invoiceallocations/USD/closed/'+funderID; 
    results = RestFunderAllocationList_v6.doGet();
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}