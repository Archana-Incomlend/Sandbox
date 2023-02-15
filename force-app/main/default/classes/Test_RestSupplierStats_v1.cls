@isTest(SeeAllData=true)
private class Test_RestSupplierStats_v1 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
        
    ID supplierId =  seedincomlenddata.seedAll();
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

    req.requestURI = baseUrl+'/services/apexrest/v1/supplier/stats/USD/'+supplierId;
    System.debug('URL: '+ req.requestURI);
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    RestSupplierStats_v1.ReturnClass results = RestSupplierStats_v1.doGet();
    
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}