@isTest(SeeAllData=true)
private class Test_RestEWalletTrustees_v9_2 {
  static testMethod void testDoGet() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    req.requestURI = v_baseUrl+'/v9.2/EWalletTrustee';
    req.addParameter('lastModifiedStartDate', '2021-06-07');
    req.addParameter('lastModifiedEndDate', '2021-06-08');
    RestEWalletTrustees_v9_2.doGet();
    System.assertEquals(200, res.statusCode);

    RestRequest req1 = new RestRequest();
    req1.httpMethod = 'GET';
    RestContext.request = req1;
    req1.requestURI = v_baseUrl+'/v9.2/EWalletTrustee';
    RestEWalletTrustees_v9_2.doGet();
    System.assertEquals(400, res.statusCode);
    System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Start date is required'))), res.responseBody);

    RestRequest req2 = new RestRequest();
    req2.httpMethod = 'GET';
    RestContext.request = req2;
    req2.requestURI = v_baseUrl+'/v9.2/EWalletTrustee';
    req2.addParameter('lastModifiedStartDate', '2021-16-17');
    RestEWalletTrustees_v9_2.doGet();
    System.assertEquals(400, res.statusCode);
    System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid date'))), res.responseBody);

    RestRequest req3 = new RestRequest();
    req3.httpMethod = 'GET';
    RestContext.request = req3;
    req3.requestURI = v_baseUrl+'/v9.2/EWalletTrustee';
    req3.addParameter('lastModifiedStartDate', '2021-06-07');
    req3.addParameter('lastModifiedEndDate', '2021-05-18');
    RestEWalletTrustees_v9_2.doGet();
    System.assertEquals(400, res.statusCode);
    System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Start date must be before end date'))), res.responseBody);

    RestRequest req4 = new RestRequest();
    req4.httpMethod = 'GET';
    RestContext.request = req4;
    req4.requestURI = v_baseUrl+'/v9.2/EWalletTrustee';
    req4.addParameter('lastModifiedStartDate', '2021-06-17abc');
    RestEWalletTrustees_v9_2.doGet();
    System.assertEquals(400, res.statusCode);
    System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid date'))), res.responseBody);

    RestRequest req5 = new RestRequest();
    req5.httpMethod = 'GET';
    RestContext.request = req5;
    req5.requestURI = v_baseUrl+'/v9.2/EWalletTrustee';
    req5.addParameter('lastModifiedStartDate', '2021-06-07');
    req5.addParameter('lastModifiedEndDate', '2021-06-18asd');
    RestEWalletTrustees_v9_2.doGet();
    System.assertEquals(400, res.statusCode);
    System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid date'))), res.responseBody);

  }
}