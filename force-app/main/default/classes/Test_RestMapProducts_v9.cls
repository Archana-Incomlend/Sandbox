@isTest(SeeAllData=true)
private class Test_RestMapProducts_v9 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    ID v_supplierAccountId = seedincomlenddata.seedAll();
    Supplier_Buyer_Map__c v_map = [SELECT id, Buyer__r.Id   FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true AND Supplier__r.Id=:v_supplierAccountId].get(0);
    Id v_mapId = v_map.Id;
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.MapProductListReturnClass v_results;
        
    req.requestURI = v_baseUrl+'/v9/mapproducts';   
    req.addParameter('fieldSetType', 'supplier');
    req.addParameter('mapId', v_mapId);
    v_results = RestMapProducts_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;     
    req1.requestURI = v_baseUrl+'/v9/mapproducts';  
    req1.addParameter('fieldSetType', 'buyer');
    req1.addParameter('mapId', v_mapId);
    v_results = RestMapProducts_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
        
    RestRequest req2 = new RestRequest(); 
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/v9/mapproducts'; 
    req2.addParameter('fieldSetType', 'supplier1');
    req2.addParameter('mapId', v_mapId);
    v_results = RestMapProducts_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Field set parameter is missing or invalid value', v_results.v_message);
    
    RestRequest req3 = new RestRequest(); 
    req3.httpMethod = 'GET';
    RestContext.request = req3;
    req3.requestURI = v_baseUrl+'/v9/mapproducts';  
    req3.addParameter('fieldSetType', 'supplier');
    req3.addParameter('mapId', '0010k000008v');
    v_results = RestMapProducts_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid supplier buyer map id', v_results.v_message);

  }

}