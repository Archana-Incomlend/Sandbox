@isTest
private class Test_RestEWalletTrusteeData_v9_2 {
    static testMethod void testDoGet() {
        String funderId = 'Funder';
        String CCY = 'USD';
        Map<String, Object> result = new Map<String, Object>();
        SeedTest.createMarketPlace(result, CCY);
        insert SeedTest.createAccount(result, funderId, 'Purchaser');
        insert SeedTest.createBankAccount(result, funderId);
        insert SeedTest.createEWallet(result, funderId, CCY);
        eWallet_Trustee__c eWallet_TrusteeFunder = SeedTest.createEWalletTrustee(result, funderId, CCY);
        insert eWallet_TrusteeFunder;

        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestURI = v_baseUrl+'/v9.2/EWalletTrustee/' + eWallet_TrusteeFunder.id;
        RestEWalletTrusteeData_v9_2.doGet();
        System.assertEquals(200, res.statusCode);

        delete eWallet_TrusteeFunder;
        RestEWalletTrusteeData_v9_2.doGet();
        System.assertEquals(400, res.statusCode);
        Test.stopTest();
    }
    
    static testMethod void testDoGetFailId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestURI = v_baseUrl+'/v9.2/EWalletTrustee/123123';
        RestEWalletTrusteeData_v9_2.doGet();
        System.assertEquals(400, res.statusCode);
    }
}