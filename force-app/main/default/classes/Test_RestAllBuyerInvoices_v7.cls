@isTest(SeeAllData=true)
private class Test_RestAllBuyerInvoices_v7 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {
 Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    ID v_mapId = [SELECT id FROM Supplier_Buyer_Map__c where marketplace__r.Currency__c ='USD' and buyer_supplier_map_approved__c=true and Incomlend_product__r.approved__c=true].get(0).Id;
    ID v_marketplaceId = [Select ID from marketplace__c where Currency__c = 'USD'].get(0).id;
    ID v_productId= [SELECT id FROM incomlend_product__c where approved__c=true].get(0).Id;
    ID v_buyerId = [SELECT buyer__c FROM Supplier_Buyer_Map__c where Id =:v_mapId].get(0).buyer__c;
        
    ID v_lastMadeInvoiceId = SeedIncomlendData.makeInvoice(v_mapId, v_productId,'3:IN PROGRESS','In Progress',10);
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.InvoiceListReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/allbuyer/invoices/buyer/onmarketplace/0010k000008v';  
    v_results = RestAllBuyerInvoices_v7.doGet();
     
    req.requestURI = v_baseUrl+'/services/apexrest/v7/allbuyer/invoices/buyer/onmarketplace/'+v_buyerId;  
    v_results = RestAllBuyerInvoices_v7.doGet();
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/allbuyer/invoices/buyer/inprogress/'+v_buyerId; 
    v_results = RestAllBuyerInvoices_v7.doGet();
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/allbuyer/invoices/buyer/closed/'+v_buyerId; 
    v_results = RestAllBuyerInvoices_v7.doGet();
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/allbuyer/invoices/buyer/prelisting/'+v_buyerId; 
    v_results = RestAllBuyerInvoices_v7.doGet();
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/allbuyer/invoices/test/prelisting/'+v_buyerId; 
    v_results = RestAllBuyerInvoices_v7.doGet();
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7/allbuyer/invoices/map/prelisting/'+v_mapId; 
    v_results = RestAllBuyerInvoices_v7.doGet();
    
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}