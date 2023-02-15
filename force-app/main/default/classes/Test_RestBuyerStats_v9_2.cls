@isTest(SeeAllData=true)
private class Test_RestBuyerStats_v9_2 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    ID v_mapId = [SELECT id FROM Supplier_Buyer_Map__c where buyer_supplier_map_approved__c=true and Incomlend_product__r.approved__c=true].get(0).Id;
     
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.DecimalMapReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9.2/buyer/stats/0010k000008v'; 
    v_results = RestBuyerStats_v9_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Supplier buyer map ID', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9.2/buyer/stats/'+v_mapId; 
    v_results = RestBuyerStats_v9_2.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}