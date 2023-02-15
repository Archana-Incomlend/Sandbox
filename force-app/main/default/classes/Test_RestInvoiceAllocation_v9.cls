@isTest(SeeAllData=true)
private class Test_RestInvoiceAllocation_v9 {

  static {
    // setup test data  
  }

  static testMethod void testDoPost() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();    
    ID v_productId;
    Id v_mapId;
    ID v_marketplaceId;
    Boolean v_acceptPartialBid;
    Integer v_amount;
    String v_confirmationReceipt;
        
    v_marketplaceId = [Select ID from marketplace__c where Currency__c = 'XXX'].get(0).id;
    v_productId= [SELECT id FROM incomlend_product__c where active__c=true].get(0).Id;
    v_mapId    = [SELECT id FROM Supplier_Buyer_Map__c where Currency__c ='XXX' and buyer_supplier_map_approved__c=true].get(0).Id;
        
    ID v_invoiceID = seedincomlenddata.makeInvoice(v_mapId, v_productId,'2:ON MARKETPLACE','On marketplace',1);
        
    ID v_agentID;
    v_agentID = seedincomlenddata.SeedIncomlendAccounts();
      
    ID v_USDMarketplace;
    v_USDMarketplace = seedincomlenddata.SeedProducts();
    ID v_funderAccountId = seedincomlenddata.SeedTestFunderAccounts(v_agentID, v_USDMarketplace);
    ID v_contactId = seedincomlenddata.createFunderContact(v_funderAccountId);
    
    GlobalMethods_v9.DecimalMapReturnClass v_results;
    
    v_amount = 5000;
    v_acceptPartialBid = true;
    v_confirmationReceipt = 'Test receipt';
    
    req.requestURI = v_baseUrl+'/v8.2/invoiceallocation';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    req.addHeader('email', 'funder@test.com');
    
    v_results = RestInvoiceAllocation_v9.doPost('0010k00000A0azt', v_amount, v_acceptPartialBid, v_confirmationReceipt);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid invoice Id', v_results.v_message);
    
    v_results = RestInvoiceAllocation_v9.doPost(v_invoiceID, 50000, v_acceptPartialBid, v_confirmationReceipt);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('You do not have enough ewallet balance', v_results.v_message);
    
    v_results = RestInvoiceAllocation_v9.doPost(v_invoiceID, 500, v_acceptPartialBid, v_confirmationReceipt);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Reservation amount should be greater than minimum amount', v_results.v_message);
    
    v_results = RestInvoiceAllocation_v9.doPost(v_invoiceID, 8500, v_acceptPartialBid, v_confirmationReceipt);
    System.assertEquals('false', v_results.v_success);
    
    v_results = RestInvoiceAllocation_v9.doPost(v_invoiceID, v_amount, v_acceptPartialBid, v_confirmationReceipt);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Reservation is accepted', v_results.v_message);
    
    v_results = RestInvoiceAllocation_v9.doPost(v_invoiceID, v_amount, false, v_confirmationReceipt);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Requested reservation amount is not available', v_results.v_message);
    
    v_results = RestInvoiceAllocation_v9.doPost(v_invoiceID, 1000, v_acceptPartialBid, v_confirmationReceipt);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Reservation is accepted', v_results.v_message);
    
    Invoice_Finance_Deal__c invoiceData = [SELECT Id, MAX_bid_amount__c FROM invoice_finance_deal__c WHERE Id = :v_invoiceID];
    invoiceData.MAX_bid_amount__c = 2000;
    update invoiceData;
    
    v_results = RestInvoiceAllocation_v9.doPost(v_invoiceID, 3000, v_acceptPartialBid, v_confirmationReceipt);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Reservation amount should be less than maximum amount', v_results.v_message);
    
    v_results = RestInvoiceAllocation_v9.doPost(v_invoiceID, 2000, v_acceptPartialBid, v_confirmationReceipt);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Reservation is accepted', v_results.v_message);
    
    v_results = RestInvoiceAllocation_v9.doPost(v_invoiceID, 1000, v_acceptPartialBid, v_confirmationReceipt);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Reservation is accepted', v_results.v_message);
    
    v_results = RestInvoiceAllocation_v9.doPost(v_invoiceID, v_amount, v_acceptPartialBid, v_confirmationReceipt);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Reservation for this invoice is full', v_results.v_message);

  }

}