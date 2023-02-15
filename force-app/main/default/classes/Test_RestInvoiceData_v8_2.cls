@isTest(SeeAllData=true)
private class Test_RestInvoiceData_v8_2 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    ID v_supplierAccountId = seedincomlenddata.seedAll();
    ID v_userContactId = seedincomlenddata.createSupplierContact(v_supplierAccountId);
    ID v_invoiceID = seedincomlenddata.makeInvoiceBuyer(1, v_supplierAccountId);
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.InvoiceReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v8.2/invoice/0010k000008v';  
    v_results = RestInvoiceData_v8_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid invoice id', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v8.2/invoice/'+v_invoiceID;  
    v_results = RestInvoiceData_v8_2.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    req.addHeader('email', 'test@test.com');
    req.requestURI = v_baseUrl+'/services/apexrest/v8.2/invoice/'+v_invoiceID;  
    v_results = RestInvoiceData_v8_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Email Id', v_results.v_message);

  }

}