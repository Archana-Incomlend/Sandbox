@isTest(SeeAllData=true)
private class Test_RestSupplierStats {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Id FXRATE = seedincomlenddata.addFXRate('EUR',123);
    Id MARKETPLACE = seedincomlenddata.seedMarketplace('EUR',FXRATE);
    System.debug('FXRATE: '+ FXRATE);
    System.debug('MARKETPLACE: '+ MARKETPLACE);
    
    ID supplierId =  seedincomlenddata.seedAll();
    System.debug('supplierId: '+ supplierId);
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

    req.requestURI = baseUrl+'/services/apexrest/supplier/stats/'+MARKETPLACE+'/'+supplierId;
    System.debug('URL: '+ req.requestURI);
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    RestSupplierStats.ReturnClass results = RestSupplierStats.doGet();
    
    System.assertEquals('true', results.success);
    /*System.assertEquals(3, results.records.size());*/
    System.assertEquals('Query executed successfully.', results.message);

  }

}