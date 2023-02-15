@isTest
private class Test_RestAccounts_v9_2 {
    static testMethod void testDoGet() {
        // Prepare data
        // Incomlend Operations
        Account accountAtradius = new Account();
        accountAtradius.Name = 'Atradius';
        accountAtradius.Type = 'Partner';
        accountAtradius.Sub_type__c = 'NA';
        accountAtradius.VAT_applicable__c = true;
        insert accountAtradius;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestURI = v_baseUrl+'/v9.2/Account';
        req.addParameter('lastModifiedStartDate', String.valueof(Date.today()));
        req.addParameter('lastModifiedEndDate', String.valueof(Date.today()));
        RestAccounts_v9_2.doGet();
        System.assertEquals(200, res.statusCode);
	}
	
    static testMethod void TestDoGetFailNoDate(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

        req.httpMethod = 'GET';
        req.requestURI = v_baseUrl+'/v9.2/Account';
        RestContext.request = req;
        RestContext.response = res;
        RestAccounts_v9_2.doGet();
        System.assertEquals(400, res.statusCode);
        System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Start date is required'))), res.responseBody);

    }
    
    static testMethod void TestDoGetFailInvalidStartDate(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

        req.httpMethod = 'GET';
        req.requestURI = v_baseUrl+'/v9.2/Account';
        req.addParameter('lastModifiedStartDate', 'aaaa-16-17');
        RestContext.request = req;
        RestContext.response = res;
        RestAccounts_v9_2.doGet();
        System.assertEquals(400, res.statusCode);
        System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid date'))), res.responseBody);
    }
    
    static testMethod void TestDoGetFailInvalidStartDateBeforeEndDate(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

        req.httpMethod = 'GET';
        req.requestURI = v_baseUrl+'/v9.2/Account';
        req.addParameter('lastModifiedStartDate', '2021-06-07');
        req.addParameter('lastModifiedEndDate', '2021-05-18');
        RestContext.request = req;
        RestContext.response = res;
        RestAccounts_v9_2.doGet();
        System.assertEquals(400, res.statusCode);
        System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Start date must be before end date'))), res.responseBody);
    }
    
    static testMethod void TestDoGetFailInvalidEndDate(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

        req.httpMethod = 'GET';
        req.requestURI = v_baseUrl+'/v9.2/Account';
        req.addParameter('lastModifiedStartDate', '2021-06-10');
        req.addParameter('lastModifiedEndDate', '2021-06-80');
        RestContext.request = req;
        RestContext.response = res;
        RestAccounts_v9_2.doGet();
        System.assertEquals(400, res.statusCode);
        System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid date'))), res.responseBody);
    }
 
}