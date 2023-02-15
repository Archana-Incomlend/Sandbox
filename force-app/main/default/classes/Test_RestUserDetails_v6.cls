@isTest(SeeAllData=true)
private class Test_RestUserDetails_v6 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    ID supplierId =  seedincomlenddata.seedAll();
    System.debug('supplierId: '+ supplierId);
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    RestUserDetails_v6.ReturnClass results;
    
    req.requestURI = baseUrl+'/services/apexrest/v6/user/0010k000008v';      
    results = RestUserDetails_v6.doGet();
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid user ID', results.message);
        
    req.requestURI = baseUrl+'/services/apexrest/v6/user/'+supplierId;      
    results = RestUserDetails_v6.doGet();
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}