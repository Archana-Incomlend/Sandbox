@isTest(SeeAllData=true)
private class Test_RestApproveListing_v9 {

  static {
    // setup test data  
  }

  static testMethod void testDoPost() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    ID v_supplierAccountId = seedincomlenddata.seedAll();
    ID v_userContactId = seedincomlenddata.createSupplierContact(v_supplierAccountId);
    ID v_supplierInvoiceID = seedincomlenddata.makeInvoiceSupplier(1, v_supplierAccountId);
    ID v_invoiceID = seedincomlenddata.makeInvoiceBuyer(1, v_supplierAccountId);
    Invoice_Finance_Deal__c v_invoiceData = [SELECT Id, Supplier_Buyer_Map__r.Buyer__r.Id, Supplier_Buyer_Map__r.Supplier__r.Id, supplier_del__c, Invoice_name__c, invoice_amount__c, CCY__c, supplier_text__c, auto_status__c FROM invoice_finance_deal__c WHERE Id = :v_invoiceID];    
    ID v_buyerAccountId = v_invoiceData.Supplier_Buyer_Map__r.Buyer__r.Id;
    
    req.httpMethod = 'POST';
    req.requestURI = v_baseUrl+'/services/apexrest/v9/approvelisting';   
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.InvoiceReturnClass v_results;
    
    v_results = RestApproveListing_v9.doPost(v_supplierInvoiceID, v_userContactId, v_supplierAccountId, 'supplier', 'approve', 'test notes');
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Invoice status is successfully updated', v_results.v_message);
    
    v_results = RestApproveListing_v9.doPost(v_supplierInvoiceID, v_userContactId, v_supplierAccountId, 'supplier', 'approve', 'test notes');
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid supplier invoice', v_results.v_message);
    
     v_results = RestApproveListing_v9.doPost(v_supplierInvoiceID, v_userContactId, v_supplierAccountId, 'test', 'approve', 'test notes');
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user type', v_results.v_message);
    
    v_supplierInvoiceID = seedincomlenddata.makeInvoiceSupplier(1, v_supplierAccountId);
    v_results = RestApproveListing_v9.doPost(v_supplierInvoiceID, v_userContactId, v_supplierAccountId, 'supplier', 'reject', 'test notes');
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Invoice status is successfully updated', v_results.v_message);
    
    
    v_results = RestApproveListing_v9.doPost(v_invoiceID, v_userContactId, v_buyerAccountId, 'buyer', 'approve', 'test notes');
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Invoice status is successfully updated', v_results.v_message);
    
    v_results = RestApproveListing_v9.doPost(v_invoiceID, v_userContactId, v_buyerAccountId, 'buyer', 'approve', 'test notes');
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid buyer invoice', v_results.v_message);
    
    v_invoiceID = seedincomlenddata.makeInvoiceBuyer(1, v_supplierAccountId);
    v_results = RestApproveListing_v9.doPost(v_invoiceID, v_userContactId, v_buyerAccountId, 'buyer', 'reject', 'test notes');
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Invoice status is successfully updated', v_results.v_message);

   
  }

}