@isTest
private class Test_RestFunderAllocationList_v9 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    Map<String, Object> result = new Map<String, Object>();
    Account funder = SeedTest.createAccount(result, null, 'Purchaser');
    insert funder;

    Test.startTest();

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

    ID v_funderAccountId = funder.Id;
            
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.AllocationListReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/v9/user/invoiceallocations';
    req.addParameter('funderAccountId', '0010k000008v');
    req.addParameter('phase', 'inprogress');
    req.addParameter('ccy', 'USD');
    req.addParameter('overdue', 'true');
    v_results = RestFunderAllocationList_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user account Id', v_results.v_message);
    
    
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req1.requestURI = v_baseUrl+'/v9/user/invoiceallocations';
    req1.addParameter('funderAccountId',v_funderAccountId);
    req1.addParameter('phase', 'inprogress');
    req1.addParameter('ccy', 'AAA');
    req1.addParameter('overdue', 'false');
    v_results = RestFunderAllocationList_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid currency', v_results.v_message);
    
    RestRequest req2 = new RestRequest(); 
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/v9/user/invoiceallocations';
    req2.addParameter('funderAccountId',v_funderAccountId);
    req2.addParameter('phase', 'phase');
    req2.addParameter('ccy', 'USD');
    req2.addParameter('overdue', 'false');
    v_results = RestFunderAllocationList_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid phase', v_results.v_message);
    
    RestRequest req3 = new RestRequest(); 
    req3.httpMethod = 'GET';
    RestContext.request = req3;
    req3.requestURI = v_baseUrl+'/v9/user/invoiceallocations';
    req3.addParameter('funderAccountId',v_funderAccountId);
    req3.addParameter('phase', 'onmarketplace');
    req3.addParameter('ccy', 'USD');
    req3.addParameter('overdue', 'false');
    v_results = RestFunderAllocationList_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
   
  }

}