@isTest(SeeAllData=true)
private class Test_RestReceiveBid_v1 {

  static {
    // setup test data  
  }

  static testMethod void testDoPost() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    System.debug('baseUrl: '+ baseUrl);
    
    ID product_id;
    Id map_id;
    ID marketplace_id;
    Boolean acceptPartialBid;
    Double amount;
        
marketplace_id = [Select ID from marketplace__c where Currency__c = 'XXX'].get(0).id;
    product_id= [SELECT id FROM incomlend_product__c where CCYs__c = 'XXX' AND active__c=true].get(0).Id;
    map_id    = [SELECT id FROM Supplier_Buyer_Map__c where Currency__c = 'XXX' AND buyer_supplier_map_approved__c=true].get(0).Id;
        
    ID invoiceID = seedincomlenddata.makeInvoice(map_id, product_id,'2:ON MARKETPLACE','On marketplace',1);
    
    System.debug('invoiceID: '+ invoiceID);
    
    ID AgentID;
    AgentID = seedincomlenddata.SeedIncomlendAccounts();
      
    ID USDMarketplace;
    USDMarketplace = seedincomlenddata.SeedProducts();
    ID funderID = seedincomlenddata.SeedTestFunderAccounts(AgentID, USDMarketplace);
    ID contactID = seedincomlenddata.createFunderContact(funderID);
    
    amount = 1000;
    acceptPartialBid = true;
    
    req.requestURI = baseUrl+'/v1/invoice/invoiceAllocation';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
        
    RestReceiveBid_v1.ReturnClass results = RestReceiveBid_v1.doPost(invoiceID, funderID, amount, acceptPartialBid, contactID);
    
    System.assertEquals('true', results.success);
    System.assertEquals('Reservation is accepted', results.message);

  }

}