@isTest(SeeAllData=true)
private class Test_RestUpdateInvoice_v7_1 {

  static {
    // setup test data  
  }

  static testMethod void testDoPost() {

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    ID v_supplierAccountId = seedincomlenddata.seedAll();
    ID v_userContactId = seedincomlenddata.createSupplierContact(v_supplierAccountId);
    ID v_invoiceID = seedincomlenddata.makeInvoiceSupplier(1, v_supplierAccountId);
    ID v_xxxInvoiceID = seedincomlenddata.makeXXXInvoice(v_supplierAccountId);
   
    String v_phase = '2:ON MARKETPLACE';
    String v_status = 'On marketplace';
    Date v_listingStart = system.today().addDays(-2);
    Date v_listingEnd =  system.today().addDays(2);
    
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.InvoiceReturnClass v_results;
    req.requestURI = v_baseUrl+'/v7.1/invoice/update';    
    
    v_results = RestUpdateInvoice_v7_1.doPost('0010k00000A0azt', v_phase, v_status, v_listingStart, v_listingEnd);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid invoice ID', v_results.v_message);
    
    v_results = RestUpdateInvoice_v7_1.doPost(v_xxxInvoiceID, 'Test', v_status, v_listingStart, v_listingEnd);
    System.assertEquals('false', v_results.v_success);
        
    v_results = RestUpdateInvoice_v7_1.doPost(v_xxxInvoiceID, v_phase, v_status, v_listingStart, v_listingEnd);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Invoice is successfully updated', v_results.v_message);

  }

}