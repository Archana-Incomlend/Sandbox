@isTest(SeeAllData=true)
private class Test_RestApproveListing_v7_1 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

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
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.InvoiceReturnClass v_results;
        
    req.requestURI = v_baseUrl+'/services/apexrest/v7.1/approvelisting';   
    req.addParameter('buyerAccountId', v_buyerAccountId);
    req.addParameter('invoiceId', '0010k000008v');
    req.addParameter('userContactId', v_userContactId);
    req.addParameter('status', 'approve');
    v_results = RestApproveListing_v7_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid invoice ID', v_results.v_message);
  
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;  
    req1.requestURI = v_baseUrl+'/services/apexrest/v7.1/approvelisting';   
    req1.addParameter('buyerAccountId', v_buyerAccountId);
    req1.addParameter('invoiceId', v_invoiceID);
    req1.addParameter('userContactId', '0010k000008v');
    req1.addParameter('status', 'approve');
    v_results = RestApproveListing_v7_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid contact ID', v_results.v_message);
    
    RestRequest req2 = new RestRequest(); 
    req2.httpMethod = 'GET';
    RestContext.request = req2;  
    req2.requestURI = v_baseUrl+'/services/apexrest/v7.1/approvelisting';   
    req2.addParameter('buyerAccountId', v_buyerAccountId);
    req2.addParameter('invoiceId', v_invoiceID);
    req2.addParameter('userContactId', v_userContactId);
    req2.addParameter('status', 'approve');
    v_results = RestApproveListing_v7_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Invoice status is successfully updated', v_results.v_message);
    
    RestRequest req3 = new RestRequest(); 
    req3.httpMethod = 'GET';
    RestContext.request = req3; 
    req3.requestURI = v_baseUrl+'/services/apexrest/v7.1/approvelisting';   
    req3.addParameter('supplierAccountId', v_supplierAccountId);
    req3.addParameter('invoiceId', v_supplierInvoiceID);
    req3.addParameter('userContactId', v_userContactId);
    req3.addParameter('status', 'approve');
    v_results = RestApproveListing_v7_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Invoice status is successfully updated', v_results.v_message);

  }

}