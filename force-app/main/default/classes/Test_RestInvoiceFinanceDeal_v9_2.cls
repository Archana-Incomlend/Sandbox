@isTest(SeeAllData=true)
private class Test_RestInvoiceFinanceDeal_v9_2 {
  static testMethod void testDoGet() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

    req.httpMethod = 'GET';  
    RestContext.request = req;
    RestContext.response = res;

    invoice_finance_deal__c invoice = [SELECT Id FROM invoice_finance_deal__c LIMIT 1];
    req.requestURI = v_baseUrl+'/v9.2/InvoiceFinanceDeal/' + invoice.Id;
    RestInvoiceFinanceDeal_v9_2.doGet();
    System.assertEquals(200, res.statusCode);

    RestRequest req1 = new RestRequest();
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req1.requestURI = v_baseUrl+'/v9.2/InvoiceFinanceDeal/0010k000008v';
    RestInvoiceFinanceDeal_v9_2.doGet();
    System.assertEquals(400, res.statusCode);
    System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid deal id'))), res.responseBody);

    RestRequest req2 = new RestRequest();
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/v9.2/InvoiceFinanceDeal/a090T000000wghXZZZ';
    RestInvoiceFinanceDeal_v9_2.doGet();
    System.assertEquals(400, res.statusCode);
    System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid deal id'))), res.responseBody);

  }
}