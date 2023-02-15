@isTest(SeeAllData=true)
private class Test_RestMyBuyersList_v4 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    RestMyBuyersList_v4.ReturnClass results;
    
    ID supplierId =  seedincomlenddata.seedAll();
    System.debug('supplierId: '+ supplierId);
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
     
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    
    req.requestURI = baseUrl+'/services/apexrest/v4/buyersuppliermap/USD/0010k000008v';  
    results = RestMyBuyersList_v4.doGet();
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid user ID', results.message);
    
    req.requestURI = baseUrl+'/services/apexrest/v4/buyersuppliermap/ABC/0010k000008v';  
    results = RestMyBuyersList_v4.doGet();
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid currency', results.message);
    
    req.requestURI = baseUrl+'/services/apexrest/v4/buyersuppliermap/USD/'+supplierId;     
    results = RestMyBuyersList_v4.doGet();
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}