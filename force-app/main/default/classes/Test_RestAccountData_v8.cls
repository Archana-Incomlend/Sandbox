@isTest(SeeAllData=true)
private class Test_RestAccountData_v8 {

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
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.AccountReturnClass v_results;
        
    req.requestURI = v_baseUrl+'/v8/Account/'+v_supplierAccountId;   
    req.addParameter('fieldSetType', 'buyer');
    req.addParameter('ccy', 'XXX');
    v_results = RestAccountData_v8.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
        
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req1.requestURI = v_baseUrl+'/v8/Account/'+v_supplierAccountId;  
    req1.addParameter('fieldSetType', 'supplier1');
    req1.addParameter('ccy', 'XXX');
    v_results = RestAccountData_v8.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Field set parameter is missing or invalid value', v_results.v_message);
    
    RestRequest req2 = new RestRequest(); 
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/v8/Account/0010k000008v';  
    req2.addParameter('fieldSetType', 'supplier');
    req2.addParameter('ccy', 'XXX');
    v_results = RestAccountData_v8.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user ID', v_results.v_message);
    
    RestRequest req3 = new RestRequest(); 
    req3.httpMethod = 'GET';
    RestContext.request = req3;
    req3.requestURI = v_baseUrl+'/v8/Account/'+v_supplierAccountId;   
    req3.addParameter('fieldSetType', 'buyer_dashboard');
    req3.addParameter('ccy', 'XXX');
    v_results = RestAccountData_v8.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}