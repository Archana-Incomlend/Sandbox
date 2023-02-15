@isTest(SeeAllData=true)
private class Test_RestInvoicePicklists_v7_1 {

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
    GlobalMethods.ListMapReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7.1/invoice/picklists';  
    v_results = RestInvoicePicklists_v7_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}