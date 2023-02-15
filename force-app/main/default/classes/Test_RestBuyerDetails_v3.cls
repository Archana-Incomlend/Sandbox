@isTest(SeeAllData=true)
private class Test_RestBuyerDetails_v3 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    System.debug('baseUrl: '+ baseUrl);
    
    Supplier_Buyer_Map__c v_map = [SELECT id, Supplier__r.Id, Buyer__r.Id   FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true].get(0);
    Id v_mapId = v_map.Id;
          
    req.requestURI = baseUrl+'/services/apexrest/v3/buyer/'+v_mapId;  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
        
    RestBuyerDetails_v3.ReturnClass results = RestBuyerDetails_v3.doGet();
    
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}