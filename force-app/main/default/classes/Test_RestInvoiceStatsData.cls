@isTest(SeeAllData=true)
private class Test_RestInvoiceStatsData {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Id FXRATE = seedincomlenddata.addFXRate('EUR',123);
    Id MARKETPLACE = seedincomlenddata.seedMarketplace('EUR',FXRATE);

    req.requestURI = 'https://incomlend.my.salesforce.com/services/apexrest/marketplace/'+MARKETPLACE;  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    RestInvoiceStatsData.ReturnClass results = RestInvoiceStatsData.doGet();
    
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}