@isTest
private class Test_RestIntermediateDeploymentFix_v9 {
    static testMethod void testDoGet() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = v_baseUrl+'/v9/IntermediateDeploymentFix/000';
        req.addParameter('date', '2021-07-01');
        req.addParameter('test', 'true');
        RestIntermediateDeploymentFix_v9.doGet();
        System.assertEquals(200, res.statusCode);

        // req.addParameter('module', 'rate');
        // req.addParameter('latest', 'true');
        // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('SGD', true));
        // RestIntermediateDeploymentFix_v9.doGet();
        // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // System.assertEquals(200, res.statusCode);

    }
}