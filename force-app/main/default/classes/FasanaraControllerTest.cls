@isTest
private class FasanaraControllerTest {
    static testMethod void testDoGet() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"access_token": "abc"}'));
        // FasanaraController.refreshToken(null);

        // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(401, '{"error_summary": "expired_access_token/...", "error": {".tag": "expired_access_token"}}'));
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        req.httpMethod = 'POST';  
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = v_baseUrl+'/v9/Fasanara';
        FasanaraController.doPost();

        new FasanaraController().Logs = new Helper_Log();
        

    }
}