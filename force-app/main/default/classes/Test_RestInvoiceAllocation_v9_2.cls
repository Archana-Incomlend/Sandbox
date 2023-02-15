@isTest
private class Test_RestInvoiceAllocation_v9_2 {
    static testMethod void testDoGetSuccess() {
        Map<String, Object> result = SeedTest.init(null, null, null);
        Invoice_Allocation__c Invoice_Allocation = (Invoice_Allocation__c)result.get('invAllocation');
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestURI = v_baseUrl+'/v9.2/InvoiceAllocation/' + Invoice_Allocation.id;
        RestInvoiceAllocation_v9_2.doGet();
        System.assertEquals(200, res.statusCode);
    }
    
    static testMethod void testDoGetFailId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestURI = v_baseUrl+'/v9.2/InvoiceAllocation/123123';
        RestInvoiceAllocation_v9_2.doGet();
        System.assertEquals(400, res.statusCode);
    }
    
    static testMethod void testDoGetFailIdnotFound() {

        Map<String, Object> result = SeedTest.init(null, null, null);
        Invoice_Allocation__c Invoice_Allocation = (Invoice_Allocation__c)result.get('invAllocation');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestURI = v_baseUrl+'/v9.2/InvoiceAllocation/' + Invoice_Allocation.id;
        delete Invoice_Allocation;
        RestInvoiceAllocation_v9_2.doGet();
        System.assertEquals(400, res.statusCode);
    }
}