@isTest(SeeAllData=true)
private class Test_RestMyBuyersList_v3 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    ID supplierId =  seedincomlenddata.seedAll();
    System.debug('supplierId: '+ supplierId);
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.requestURI = baseUrl+'/services/apexrest/v3/buyersuppliermap/'+supplierId;  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
        
    RestMyBuyersList_v3.ReturnClass results = RestMyBuyersList_v3.doGet();
    
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}