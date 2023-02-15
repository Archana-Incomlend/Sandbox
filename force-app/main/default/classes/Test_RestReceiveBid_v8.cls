@isTest(SeeAllData=true)
private class Test_RestReceiveBid_v8 {

  static {
    // setup test data  
  }

  static testMethod void testDoPost() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    
    ID product_id;
    Id map_id;
    ID marketplace_id;
    Boolean acceptPartialBid;
    Integer amount;
        
    marketplace_id = [Select ID from marketplace__c where Currency__c = 'XXX'].get(0).id;
    product_id= [SELECT id FROM incomlend_product__c where CCYs__c = 'XXX' AND active__c=true].get(0).Id;
    map_id    = [SELECT id FROM Supplier_Buyer_Map__c where buyer_supplier_map_approved__c=true].get(0).Id;
    System.debug('marketplace_id: '+ marketplace_id);
    System.debug('map_id: '+ map_id);
    ID invoiceID = seedincomlenddata.makeInvoice(map_id, product_id,'2:ON MARKETPLACE','On marketplace',1);
        
    ID AgentID;
    AgentID = seedincomlenddata.SeedIncomlendAccounts();
      
    ID USDMarketplace;
    USDMarketplace = seedincomlenddata.SeedProducts();
    ID funderID = seedincomlenddata.SeedTestFunderAccounts(AgentID, USDMarketplace);
    ID contactID = seedincomlenddata.createFunderContact(funderID);
    System.debug('funderID: '+ funderID);
    System.debug('contactID: '+ contactID);
    RestReceiveBid_v8.ReturnClass results;
    
    amount = 5000;
    acceptPartialBid = true;
    String confirmationReceipt = 'Test confirmation receipt';
    
    req.requestURI = baseUrl+'/v8/invoice/invoiceAllocation';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    
    results = RestReceiveBid_v8.doPost('0010k00000A0azt', funderID, amount, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid invoice Id', results.message);
    
    results = RestReceiveBid_v8.doPost(invoiceID, 'a090k000000vQWI', amount, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid user', results.message);
    
    results = RestReceiveBid_v8.doPost(invoiceID, funderID, 0, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid amount', results.message);
    
    results = RestReceiveBid_v8.doPost(invoiceID, funderID, 50000, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('false', results.success);
    System.assert(results.message.startsWith('You do not have enough ewallet balance') );
    
    results = RestReceiveBid_v8.doPost(invoiceID, funderID, 500, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('false', results.success);
    System.assert(results.message.startsWith('Reservation amount should be greater than minimum amount') );
    
    results = RestReceiveBid_v8.doPost(invoiceID, funderID, 8500, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('false', results.success);

    results = RestReceiveBid_v8.doPost(invoiceID, funderID, amount, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('true', results.success);
    System.assertEquals('Reservation is accepted', results.message);
    
    results = RestReceiveBid_v8.doPost(invoiceID, funderID, amount, false, contactID, confirmationReceipt);
    System.assertEquals('false', results.success);
    System.assertEquals('Requested reservation amount is not available', results.message);
    
    results = RestReceiveBid_v8.doPost(invoiceID, funderID, 1000, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('true', results.success);
    System.assertEquals('Reservation is accepted', results.message);
    
    Invoice_Finance_Deal__c invoiceData = [SELECT Id, MAX_bid_amount__c FROM invoice_finance_deal__c WHERE Id = :invoiceID];
    invoiceData.MAX_bid_amount__c = 2000;
    update invoiceData;
    
    results = RestReceiveBid_v8.doPost(invoiceID, funderID, 3000, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('false', results.success);
    System.assertEquals('Reservation amount should be less than maximum amount', results.message);
    
    results = RestReceiveBid_v8.doPost(invoiceID, funderID, 2000, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('true', results.success);
    System.assertEquals('Reservation is accepted', results.message);
    
    results = RestReceiveBid_v8.doPost(invoiceID, funderID, 1000, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('true', results.success);
    System.assertEquals('Reservation is accepted', results.message);
    
    results = RestReceiveBid_v8.doPost(invoiceID, funderID, amount, acceptPartialBid, contactID, confirmationReceipt);
    System.assertEquals('false', results.success);
    System.assertEquals('Reservation for this invoice is full', results.message);
    

  }

}