@isTest(SeeAllData=true)
private class Test_RestInvoiceList_v7_2 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Id v_FXRATE = seedincomlenddata.addFXRate('EUR',123);
    Id v_marketplaceId = seedincomlenddata.seedMarketplace('EUR',v_FXRATE);
    Supplier_Buyer_Map__c v_map = [SELECT id, Supplier__r.Id, Buyer__r.Id   FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true].get(0);
    
    Id v_mapId = v_map.Id;
    Id v_supplierAccountId = v_map.Supplier__r.Id;
    Id v_buyerAccountId = v_map.Buyer__r.Id;
    
    System.debug('v_supplierAccountId: '+ v_supplierAccountId);
    System.debug('v_buyerAccountId: '+ v_buyerAccountId);

    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.InvoiceListReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req.addParameter('marketplace', v_marketplaceId);
    req.addParameter('phase', 'onmarketplace');
    req.addParameter('ccy', 'XXX');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
        
    RestRequest req1 = new RestRequest(); 
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req1.addParameter('supplierAccountId', v_supplierAccountId);
    req1.addParameter('phase', 'onmarketplace');
    req1.addParameter('ccy', 'XXX');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    RestRequest req2 = new RestRequest(); 
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req2.addParameter('buyerAccountId', v_buyerAccountId);
    req2.addParameter('phase', 'onmarketplace');
    req2.addParameter('ccy', 'XXX');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    RestRequest req3 = new RestRequest(); 
    req3.httpMethod = 'GET';
    RestContext.request = req3;
    req3.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req3.addParameter('mapId', v_mapId);
    req3.addParameter('phase', 'onmarketplace');
    req3.addParameter('ccy', 'XXX');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    RestRequest req4 = new RestRequest(); 
    req4.httpMethod = 'GET';
    RestContext.request = req4;
    req4.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req4.addParameter('supplierAccountId', '0010k000008v');
    req4.addParameter('phase', 'onmarketplace');
    req4.addParameter('ccy', 'XXX');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user ID', v_results.v_message);
    
    RestRequest req5 = new RestRequest(); 
    req5.httpMethod = 'GET';
    RestContext.request = req5;
    req5.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req5.addParameter('supplierAccountId', v_buyerAccountId);
    req5.addParameter('phase', 'onmarketplace');
    req5.addParameter('ccy', 'XXX');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user', v_results.v_message);
    
    RestRequest req6 = new RestRequest(); 
    req6.httpMethod = 'GET';
    RestContext.request = req6;
    req6.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req6.addParameter('buyerAccountId', '0010k000008v');
    req6.addParameter('phase', 'onmarketplace');
    req6.addParameter('ccy', 'XXX');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user ID', v_results.v_message);
    
    RestRequest req7 = new RestRequest(); 
    req7.httpMethod = 'GET';
    RestContext.request = req7;
    req7.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req7.addParameter('buyerAccountId', v_supplierAccountId);
    req7.addParameter('phase', 'onmarketplace');
    req7.addParameter('ccy', 'XXX');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user', v_results.v_message);
    
    RestRequest req8 = new RestRequest(); 
    req8.httpMethod = 'GET';
    RestContext.request = req8; 
    req8.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req8.addParameter('marketplace', '0010k000008v');
    req8.addParameter('phase', 'onmarketplace');
    req8.addParameter('ccy', 'XXX');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid marketplace Id', v_results.v_message);
    
    RestRequest req9 = new RestRequest(); 
    req9.httpMethod = 'GET';
    RestContext.request = req9;
    req9.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req9.addParameter('marketplace', v_marketplaceId);
    req9.addParameter('phase', 'onmarketplace');
    req9.addParameter('ccy', 'ABC');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid currency', v_results.v_message);
    
    RestRequest req10 = new RestRequest(); 
    req10.httpMethod = 'GET';
    RestContext.request = req10;
    req10.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req10.addParameter('marketplace', v_marketplaceId);
    req10.addParameter('phase', 'onmarketplace1');
    req10.addParameter('ccy', 'XXX');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid phase', v_results.v_message);
    
    RestRequest req11 = new RestRequest(); 
    req11.httpMethod = 'GET';
    RestContext.request = req11;
    req11.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req11.addParameter('mapId', v_mapId);
    req11.addParameter('phase', 'onmarketplace');
    req11.addParameter('ccy', 'XXX');
    req11.addParameter('overdue', 'true');
    req11.addParameter('passthrough', 'true');
    req11.addParameter('supplierApprovalStatus', 'Approved');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    RestRequest req12 = new RestRequest(); 
    req12.httpMethod = 'GET';
    RestContext.request = req12;
    req12.requestURI = v_baseUrl+'/services/apexrest/v7.2/invoices';
    req12.addParameter('mapId', v_mapId);
    req12.addParameter('phase', 'onmarketplace');
    req12.addParameter('ccy', 'XXX');
    req12.addParameter('overdue', 'false');
    req12.addParameter('passthrough', 'false');
    req12.addParameter('supplierApprovalStatus', 'Not Approved');
    v_results = RestInvoiceList_v7_2.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}