@isTest(SeeAllData=true)
private class Test_RestBuyerStats_v1 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    ID mapId = [SELECT id FROM Supplier_Buyer_Map__c where marketplace__r.Currency__c ='USD' and buyer_supplier_map_approved__c=true and Incomlend_product__r.approved__c=true].get(0).Id;
       
    req.requestURI = baseUrl+'/services/apexrest/v1/buyer/stats/'+mapId;  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
        
    RestBuyerStats_v1.ReturnClass results = RestBuyerStats_v1.doGet();
    
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}