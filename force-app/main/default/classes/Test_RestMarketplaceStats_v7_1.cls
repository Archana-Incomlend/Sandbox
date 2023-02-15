@isTest(SeeAllData=true)
private class Test_RestMarketplaceStats_v7_1 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    Id v_FXRATE = seedincomlenddata.addFXRate('EUR',123);
    //Id v_marketplaceId = seedincomlenddata.seedMarketplace('EUR',v_FXRATE);
    Id v_marketplaceId = [Select ID from marketplace__c where Currency__c = 'USD'].get(0).id;  

    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.StringMapReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7.1/marketplace/0010k000008v'; 
    v_results = RestMarketplaceStats_v7_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Marketplace Id', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7.1/marketplace/a09O000000M3gXX'; 
    v_results = RestMarketplaceStats_v7_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Marketplace Id', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7.1/marketplace/'+v_marketplaceId; 
    v_results = RestMarketplaceStats_v7_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}