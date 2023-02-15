@isTest(SeeAllData=true)
private class Test_RestAccountTrusteeData_v9 {
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
    GlobalMethods_v9.AccountReturnClass v_results;
                
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req1.requestURI = v_baseUrl+'/v9/Account/'+v_supplierAccountId;  
    v_results = RestAccountTrusteeData_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
      
    RestRequest req2 = new RestRequest(); 
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/v9/Account/0010k000008v';  
    v_results = RestAccountTrusteeData_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid account id', v_results.v_message);
      
    RestRequest req3 = new RestRequest();
    req3.addHeader('email', 'test@test.com');
    req3.httpMethod = 'GET';
    RestContext.request = req3;
    req3.requestURI = v_baseUrl+'/v9/Account/'+v_supplierAccountId;  
    v_results = RestAccountTrusteeData_v9.doGet();
    System.assertEquals('false', v_results.v_success);
  }
}