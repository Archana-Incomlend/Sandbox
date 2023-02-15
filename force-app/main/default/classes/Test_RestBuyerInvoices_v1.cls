@isTest(SeeAllData=true)
private class Test_RestBuyerInvoices_v1 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {
 Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    System.debug('baseUrl: '+ baseUrl);
    
    ID mapId = [SELECT id FROM Supplier_Buyer_Map__c where marketplace__r.Currency__c ='USD' and buyer_supplier_map_approved__c=true and Incomlend_product__r.approved__c=true].get(0).Id;
    ID marketplace_id = [Select ID from marketplace__c where Currency__c = 'USD'].get(0).id;
    ID product_id= [SELECT id FROM incomlend_product__c where approved__c=true].get(0).Id;
        
    ID lastmadeinvoiceid = SeedIncomlendData.makeInvoice(mapId, product_id,'3:IN PROGRESS','In Progress',10);
    
     
    req.requestURI = baseUrl+'/services/apexrest/v1/buyer/invoices/onmarketplace/'+mapId;  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
        
    RestBuyerInvoices_v1.ReturnClass results1 = RestBuyerInvoices_v1.doGet();
    
    req.requestURI = baseUrl+'/services/apexrest/v1/buyer/invoices/inprogress/'+mapId; 
    RestBuyerInvoices_v1.ReturnClass results2 = RestBuyerInvoices_v1.doGet();
    
    req.requestURI = baseUrl+'/services/apexrest/v1/buyer/invoices/closed/'+mapId; 
    RestBuyerInvoices_v1.ReturnClass results3 = RestBuyerInvoices_v1.doGet();
    
    req.requestURI = baseUrl+'/services/apexrest/v1/buyer/invoices/prelisting/'+mapId; 
    RestBuyerInvoices_v1.ReturnClass results4 = RestBuyerInvoices_v1.doGet();
    
    System.assertEquals('true', results1.success);
    System.assertEquals('Query executed successfully.', results1.message);

  }

}