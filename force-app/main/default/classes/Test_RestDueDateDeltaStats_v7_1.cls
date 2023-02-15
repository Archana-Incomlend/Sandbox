@isTest(SeeAllData=true)
private class Test_RestDueDateDeltaStats_v7_1 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    Supplier_Buyer_Map__c v_map = [SELECT id, Supplier__r.Id, Buyer__r.Id   FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true].get(0);
    Id v_mapId = v_map.Id;
    Id v_supplierAccountId = v_map.Supplier__r.Id;
    Id v_buyerAccountId = v_map.Buyer__r.Id;
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.StringMapReturnClass v_results;
        
    req.requestURI = v_baseUrl+'/v7.1/invoice/duedatedelta';   
    req.addParameter('fieldset', 'deltaBucketCount');
    req.addParameter('phase', 'inprogress');
    req.addParameter('option', 'due');
    req.addParameter('supplierAccountId',v_supplierAccountId);
    v_results = RestDueDateDeltaStats_v7_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
        
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req1.requestURI = v_baseUrl+'/v7.1/invoice/duedatedelta';   
    req1.addParameter('fieldset', 'supplier1');
    req1.addParameter('phase', 'inprogress');
    req1.addParameter('option', 'overdue');
    req1.addParameter('buyerAccountId',v_buyerAccountId);
    v_results = RestDueDateDeltaStats_v7_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Field set parameter is missing or invalid value', v_results.v_message);
    
    
    RestRequest req2 = new RestRequest(); 
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/v7.1/invoice/duedatedelta';   
    req2.addParameter('fieldset', 'deltaBucketCount');
    req2.addParameter('phase', 'inprogress');
    req2.addParameter('mapId',v_mapId);
    v_results = RestDueDateDeltaStats_v7_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    RestRequest req3 = new RestRequest(); 
    req3.httpMethod = 'GET';
    RestContext.request = req3;
    req3.requestURI = v_baseUrl+'/v7.1/invoice/duedatedelta';   
    req3.addParameter('fieldset', 'totalinvoiceUSD');
    req3.addParameter('phase', 'inprogress');
    req3.addParameter('option', 'overdue');
    req3.addParameter('buyerAccountId',v_buyerAccountId);
    v_results = RestDueDateDeltaStats_v7_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    

  }

}