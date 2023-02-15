@isTest(SeeAllData=true)
private class Test_RestAccountData_v9_1 {
  static testMethod void testDoGet() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    Supplier_Buyer_Map__c v_map = [SELECT id, Supplier__r.Id, Buyer__r.Id   FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true].get(0);
    Id v_mapId = v_map.Id;
    Id v_supplierAccountId = v_map.Supplier__r.Id;

    Audit_Trail__c auditTrail = new Audit_Trail__c();
    auditTrail.Account__c = v_supplierAccountId;
    auditTrail.Type__c = 'Online Approval of GTC';
    auditTrail.Status__c = 'Approved';
    auditTrail.Additional_Information__c = '{GTC Version: v1.0}';
    insert auditTrail;
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.AccountReturnClass v_results;
        
    req.requestURI = v_baseUrl+'/v9.1/Account/'+v_supplierAccountId;   
    req.addParameter('fieldSetType', 'buyer');
    req.addParameter('ccy', 'USD');
    req.addParameter('trustee', 'Amicorp');
    req.addParameter('email', 'jack705@yopmail.com');
    v_results = RestAccountData_v9_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
        
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req1.requestURI = v_baseUrl+'/v9.1/Account/'+v_supplierAccountId;  
    req1.addParameter('fieldSetType', 'supplier1');
    req1.addParameter('ccy', 'USD');
    v_results = RestAccountData_v9_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Field set parameter is missing or invalid value', v_results.v_message);
    
    RestRequest req2 = new RestRequest(); 
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/v9.1/Account/0010k000008v';  
    req2.addParameter('fieldSetType', 'supplier');
    req2.addParameter('ccy', 'USD');
    v_results = RestAccountData_v9_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user ID', v_results.v_message);
    
    RestRequest req3 = new RestRequest(); 
    req3.httpMethod = 'GET';
    RestContext.request = req3;
    req3.requestURI = v_baseUrl+'/v9.1/Account/'+v_supplierAccountId;   
    req3.addParameter('fieldSetType', 'buyer_dashboard');
    req3.addParameter('ccy', 'USD');
    v_results = RestAccountData_v9_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    RestRequest req4 = new RestRequest(); 
    req4.addHeader('email', 'test@test.com');
    req4.httpMethod = 'GET';
    RestContext.request = req4;
    req4.requestURI = v_baseUrl+'/v9.1/Account/'+v_supplierAccountId;   
    req4.addParameter('fieldSetType', 'buyer_dashboard');
    req4.addParameter('ccy', 'USD');
    v_results = RestAccountData_v9_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Email Id', v_results.v_message);

    RestRequest req5 = new RestRequest(); 
    req5.httpMethod = 'GET';
    RestContext.request = req5;
    req5.requestURI = v_baseUrl+'/v9.1/Account/'+v_supplierAccountId;   
    req5.addParameter('fieldSetType', 'buyer_dashboard');
    req5.addParameter('ccy', 'FFF');
    v_results = RestAccountData_v9_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid currency', v_results.v_message);
  }
}