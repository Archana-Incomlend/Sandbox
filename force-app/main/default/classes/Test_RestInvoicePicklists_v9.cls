@isTest(SeeAllData=true)
private class Test_RestInvoicePicklists_v9 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();        
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.ListMapReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/invoice/picklists';  
    v_results = RestInvoicePicklists_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}