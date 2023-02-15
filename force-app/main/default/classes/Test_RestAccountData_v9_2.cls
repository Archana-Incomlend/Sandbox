@isTest
private class Test_RestAccountData_v9_2 {
    
    static testMethod void testDoGetTypeSuccessWithAuditTrailSupplier() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        Account account = new Account();
        account.Name = 'TestAccountData';
        account.Sub_type__c = 'Supplier';
        
        Insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.id;
        contact.Incomlend_username__c = 'luna@abc.com';
        contact.LastName = 'Me';
        insert contact;
        
        Audit_Trail__c auditTrail = new Audit_Trail__c();
        auditTrail.Account__c = account.id;
        auditTrail.Type__c = 'Online Approval of GTC';
        auditTrail.Status__c = 'Approved';
        auditTrail.Additional_Information__c = 'v1.0';
        
        Insert auditTrail;
        
        req.requestURI = v_baseUrl+'/v9.2/Account/' + account.id;
        req.addParameter('fieldSetType', 'basic_data');
        req.addParameter('email', 'luna@abc.com');
        RestAccountData_v9_2.doGet();
        System.assertEquals(200, res.statusCode);
    }
    
    static testMethod void testDoGetTypeSuccessWithAuditTrailBuyer() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        Account account = new Account();
        account.Name = 'TestAccountData';
        account.Sub_type__c = 'Buyer';
        
        Insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.id;
        contact.Incomlend_username__c = 'luna@abc.com';
        contact.LastName = 'Me';
        insert contact;
        
        Audit_Trail__c auditTrail = new Audit_Trail__c();
        auditTrail.Account__c = account.id;
        auditTrail.Type__c = 'Online Approval of GTC';
        auditTrail.Status__c = 'Approved';
        auditTrail.Additional_Information__c = 'v1.0';
        
        Insert auditTrail;
        
        req.requestURI = v_baseUrl+'/v9.2/Account/' + account.id;
        req.addParameter('fieldSetType', 'basic_data');
        req.addParameter('email', 'luna@abc.com');
        RestAccountData_v9_2.doGet();
        System.assertEquals(200, res.statusCode);
    }
    
    static testMethod void testDoGetTypeSuccessWithAuditTrailPurchaser() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        Account account = new Account();
        account.Name = 'TestAccountData';
        account.Sub_type__c = 'Purchaser';
        
        Insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.id;
        contact.Incomlend_username__c = 'luna@abc.com';
        contact.LastName = 'Me';
        insert contact;
        
        Audit_Trail__c auditTrail = new Audit_Trail__c();
        auditTrail.Account__c = account.id;
        auditTrail.Type__c = 'Online Approval of GTC';
        auditTrail.Status__c = 'Approved';
        auditTrail.Additional_Information__c = 'v1.0';
        
        Insert auditTrail;
        
        req.requestURI = v_baseUrl+'/v9.2/Account/' + account.id;
        req.addParameter('fieldSetType', 'basic_data');
        req.addParameter('email', 'luna@abc.com');
        RestAccountData_v9_2.doGet();
        System.assertEquals(200, res.statusCode);
    }
    
    static testMethod void testDoGetTypeSuccessWithAuditTrailOther() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        Account account = new Account();
        account.Name = 'TestAccountData';
        
        Insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.id;
        contact.Incomlend_username__c = 'luna@abc.com';
        contact.LastName = 'Me';
        insert contact;
        
        Audit_Trail__c auditTrail = new Audit_Trail__c();
        auditTrail.Account__c = account.id;
        auditTrail.Type__c = 'Online Approval of GTC';
        auditTrail.Status__c = 'Approved';
        auditTrail.Additional_Information__c = 'v2.0';
        
        Insert auditTrail;
        
        req.requestURI = v_baseUrl+'/v9.2/Account/' + account.id;
        req.addParameter('fieldSetType', 'basic_data');
        req.addParameter('email', 'luna@abc.com');
        RestAccountData_v9_2.doGet();
        System.assertEquals(200, res.statusCode);
    }
    
    static testMethod void testDoGetTypeSuccessWithoutAuditTrail() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        Account account = new Account();
        account.Name = 'TestAccountData';
        
        Insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.id;
        contact.Incomlend_username__c = 'luna@abc.com';
        contact.LastName = 'Me';
        insert contact;
        
        req.requestURI = v_baseUrl+'/v9.2/Account/' + account.id;
        req.addParameter('fieldSetType', 'basic_data');
        req.addParameter('email', 'luna@abc.com');
        RestAccountData_v9_2.doGet();
        System.assertEquals(200, res.statusCode);
    }
    
    static testMethod void testDoGetSuccessNoType() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        Account account = new Account();
        account.Name = 'TestAccountData';
        
        Insert account;
        
        Contact contact = new Contact();
        contact.AccountId = account.id;
        contact.Incomlend_username__c = 'luna@abc.com';
        contact.LastName = 'Me';
        insert contact;
        
        req.requestURI = v_baseUrl+'/v9.2/Account/' + account.id;
        req.addParameter('email', 'luna@abc.com');
        RestAccountData_v9_2.doGet();
        System.assertEquals(200, res.statusCode);
    }
    
    static testMethod void testDoGetFailInvalidUser() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        String invalidID = 'notUserId';
        
        req.requestURI = v_baseUrl+'/v9.2/Account/' + invalidID;
        req.addParameter('email', 'luna@abc.com');
        RestAccountData_v9_2.doGet();
        System.assertEquals(400, res.statusCode);
        System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.AccountReturnClass('false','Invalid user ID', null))), res.responseBody);
    }
    
    static testMethod void testDoGetFailAccountNotExist() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        Account account = new Account();
        account.Name = 'TestAccountData';
        
        Insert account;
        
        Account account1 = new Account();
        account1.Name = 'TestAccountData1';
        
        Insert account1;
        
        Contact contact = new Contact();
        contact.AccountId = account.id;
        contact.Incomlend_username__c = 'luna@abc.com';
        contact.LastName = 'Me';
        insert contact;
        
        String idAccount = account1.id;
        req.requestURI = v_baseUrl+'/v9.2/Account/' + idAccount;
        req.addParameter('fieldSetType', 'basic_data');
        req.addParameter('email', 'luna@abc.com');
        
        Delete account1;
        
        RestAccountData_v9_2.doGet();
        System.assertEquals(400, res.statusCode);
        System.assertEquals(Blob.valueOf(JSON.serialize(new GlobalMethods_v9.AccountReturnClass('false','Invalid user ID', null))), res.responseBody);
    }
    
    static testMethod void testDoGetTypeFailEmail() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        
        Account account = new Account();
        account.Name = 'TestAccountData';
        account.Sub_type__c = 'Supplier';
        
        Insert account;
        
        Audit_Trail__c auditTrail = new Audit_Trail__c();
        auditTrail.Account__c = account.id;
        auditTrail.Type__c = 'Online Approval of GTC';
        auditTrail.Status__c = 'Approved';
        auditTrail.Additional_Information__c = 'v1.0';
        
        Insert auditTrail;
        
        req.requestURI = v_baseUrl+'/v9.2/Account/' + account.id;
        req.addParameter('fieldSetType', 'basic_data');
        req.addParameter('email', 'luna@abc.com');
        RestAccountData_v9_2.doGet();
        //System.assertEquals(400, res.statusCode);
    }
}