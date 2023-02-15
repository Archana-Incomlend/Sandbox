@isTest(SeeAllData=true)
private class Test_RestAuditTrailData_v9 {
  static testMethod void testDoPost() {
    RestRequest request = new RestRequest();
    GlobalMethods_v9.AuditReturnClass v_results;
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    // Create Invoice
    System.debug('Create Invoice');
    invoice_finance_deal__c invoice= new invoice_finance_deal__c();
    invoice.supplier_invoice_reference_number__c = 'PH21051980HB';
    invoice.Country_of_Origin__c = 'France';
    invoice.Country_of_Destination__c = 'Italy';
    invoice.Goods_Services_description__c = 'Heavy and expensive stuff';
    invoice.Phase__c = '2:ON MARKETPLACE';
    invoice.Status__c = 'On marketplace';
    invoice.Invoice_date__c = date.today();
    invoice.advance_send_to_supplier_date__c = date.today().addDays(9);
    invoice.Due_Date__c = date.today().addDays(57);
    invoice.invoice_amount__c = 10000+80000*Math.random();
    Integer sbm_count = [SELECT COUNT() FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true];
    System.debug('sbm_count:'+sbm_count);
    Integer sbm_rand = Math.floor(Math.random() * sbm_count).intValue();
    System.debug('sbm_rand:'+sbm_rand);
    List<Supplier_Buyer_Map__c> sbm_list = [SELECT Id, Name, Supplier__c, Buyer__c, currency__c FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true]; // AND currency__c!='XXX'
    invoice.Supplier_Buyer_Map__c = sbm_list.get(sbm_rand).Id; // Select random SB map
    System.debug('Supplier Buyer Map:'+sbm_list.get(sbm_rand).Id);
    invoice.CCY__c = sbm_list.get(sbm_rand).currency__c;
    invoice.discount_rate__c = 0.80;
    invoice.requested_amount__c = 0.9*invoice.invoice_amount__c;
    invoice.credit_insurance_fee_percentage__c = 0.05;       
    insert invoice;

    
    request.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/v9/AuditTrail';
    request.httpMethod = 'POST';
    RestContext.request = request;

    v_results = RestAuditTrailData_v9.doPost('Online Approval of GTC', 'Approved', '+6587799423', null, null, null);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('No email id is in header', v_results.v_message);
    System.assertEquals(false, v_results.v_isApproved);
    
    request.addHeader('email', 'test@yopmail.com');
    RestContext.request = request;

    v_results = RestAuditTrailData_v9.doPost('Online Approval of GTC', 'Approved', '+6587799423', null, null, null);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Email Id', v_results.v_message);
    System.assertEquals(false, v_results.v_isApproved);

    request.addHeader('email', 'jack705@yopmail.com');
    RestContext.request = request;

    v_results = RestAuditTrailData_v9.doPost('Buyer Request Signature', 'Approved', '+6587799423', 'add info', '<div></div>', invoice.Id);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    System.assertEquals(true, v_results.v_isApproved);
        
    v_results = RestAuditTrailData_v9.doPost('Buyer Request Signature', 'Rejected', '+6587799423', 'add info', '<div></div>', invoice.Id);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    System.assertEquals(false, v_results.v_isApproved);

    v_results = RestAuditTrailData_v9.doPost('Supplier Request Signature', 'Approved', '+6587799423', 'add info', '<div></div>', invoice.Id);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    System.assertEquals(true, v_results.v_isApproved);
        
    v_results = RestAuditTrailData_v9.doPost('Supplier Request Signature', 'Rejected', '+6587799423', 'add info', '<div></div>', invoice.Id);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    System.assertEquals(false, v_results.v_isApproved);

    v_results = RestAuditTrailData_v9.doPost('Wrong Type', 'Approved', '+6587799423', 'add info', '', invoice.Id);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Incorrect type', v_results.v_message);
    System.assertEquals(false, false);
  }
}