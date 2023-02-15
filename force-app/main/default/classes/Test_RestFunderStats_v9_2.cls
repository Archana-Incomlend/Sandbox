@isTest(SeeAllData=true)
private class Test_RestFunderStats_v9_2 {

  static testMethod void testDoGet() {

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

    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.DecimalMapReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9.2/funder/stats';
    req.addParameter('ccy', 'USD');
    req.addParameter('funderAccountId', '0010k000008v');
    v_results = RestFunderStats_v9_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid User Account Id', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9.2/funder/stats';
    req.addParameter('ccy', 'AAA');
    req.addParameter('funderAccountId', v_funderAccountId);
    v_results = RestFunderStats_v9_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid currency', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9.2/funder/stats';
    req.addParameter('ccy', 'XXX');
    req.addParameter('funderAccountId', v_funderAccountId);
    v_results = RestFunderStats_v9_2.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}