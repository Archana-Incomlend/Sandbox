@isTest(SeeAllData=true)
private class Test_RestOnboardingChecklist_v9 {
    
    static {
        // setup test data  
    }
    
    static testMethod void testDoGet() {
        
        Savepoint sv = Database.setSavepoint();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        ID USDMarketplace = SeedIncomlendData.SeedProducts(); 
        //ID v_supplierAccountId = SeedIncomlendData.SeedTestAccounts(null, USDMarketplace);
        //Supplier_Buyer_Map__c v_map = [SELECT id, Buyer__r.Id FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c=true AND Supplier__r.Id=:v_supplierAccountId].get(0);
        //Id v_buyerId = v_map.Buyer__r.Id;
        Id v_buyerId = SeedTestAccounts(USDMarketplace);
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        GlobalMethods_v9.OnboardingChecklistListReturnClass v_results;
        
        String v_documentType = 'Financial Statements';
        onboarding_checklist__c onboarding_checklist = new onboarding_checklist__c();
        onboarding_checklist.account__c = v_buyerId;
        onboarding_checklist.Document_Type__c = v_documentType;
        insert onboarding_checklist;
        
        req.requestURI = v_baseUrl+'/v9/onboardingchecklist';  
        req.addParameter('accountId', v_buyerId);  
        RestOnboardingChecklist_v9.doGet();
        v_results = (GlobalMethods_v9.OnboardingChecklistListReturnClass)JSON.deserialize(res.responseBody.toString(), GlobalMethods_v9.OnboardingChecklistListReturnClass.class);
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        
        req.requestURI = v_baseUrl+'/v9/onboardingchecklist';   
        req.addParameter('documentType', v_documentType);
        req.addParameter('accountId', v_buyerId);
        RestOnboardingChecklist_v9.doGet();
        v_results = (GlobalMethods_v9.OnboardingChecklistListReturnClass)JSON.deserialize(res.responseBody.toString(), GlobalMethods_v9.OnboardingChecklistListReturnClass.class);
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        
        req.requestURI = v_baseUrl+'/v9/onboardingchecklist';  
        Blob body = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = onboarding_checklist.Id;
        attachment.Name = 'Test';
        attachment.Body = body;
        insert(attachment);
        req.addParameter('accountId', v_buyerId);
        req.addParameter('attachmentId', attachment.Id);
        RestOnboardingChecklist_v9.doGet();
        System.assertEquals(200, res.statusCode);
        
        req.requestURI = v_baseUrl+'/v9/onboardingchecklist';  
        req.addParameter('accountId', v_buyerId);
        req.addParameter('attachmentId', '0010k00023v');
        RestOnboardingChecklist_v9.doGet();
        v_results = (GlobalMethods_v9.OnboardingChecklistListReturnClass)JSON.deserialize(res.responseBody.toString(), GlobalMethods_v9.OnboardingChecklistListReturnClass.class);
        System.assertEquals('false', v_results.v_success);
        
        req.requestURI = v_baseUrl+'/v9/onboardingchecklist'; 
        req.addParameter('documentType', 'supplier1');
        req.addParameter('accountId', v_buyerId);
        RestOnboardingChecklist_v9.doGet();
        v_results = (GlobalMethods_v9.OnboardingChecklistListReturnClass)JSON.deserialize(res.responseBody.toString(), GlobalMethods_v9.OnboardingChecklistListReturnClass.class);
        System.assertEquals('false', v_results.v_success);
        
        req.requestURI = v_baseUrl+'/v9/onboardingchecklist';  
        req.addParameter('accountId', '0010k0008v');
        RestOnboardingChecklist_v9.doGet();
        v_results = (GlobalMethods_v9.OnboardingChecklistListReturnClass)JSON.deserialize(res.responseBody.toString(), GlobalMethods_v9.OnboardingChecklistListReturnClass.class);
        System.assertEquals('false', v_results.v_success);
        
        req.requestURI = v_baseUrl+'/v9/onboardingchecklist';  
        req.addParameter('accountId', v_buyerId);
        req.addParameter('attachmentId', '0010k0000234223423');
        RestOnboardingChecklist_v9.doGet();
        v_results = (GlobalMethods_v9.OnboardingChecklistListReturnClass)JSON.deserialize(res.responseBody.toString(), GlobalMethods_v9.OnboardingChecklistListReturnClass.class);
        System.assertEquals('false', v_results.v_success);
        
        Database.rollback(sv);
        
    }
    
    public static id SeedTestAccounts(id marketplace) {
        Account newAccount;
        List<Account> existingAccount;
        
        newAccount = new Account();
        ID rt= [SELECT id FROM RecordType WHERE Name='Supplier'].get(1).Id;
        
        newAccount.Name = 'Test';
        newAccount.Type = 'Customer';
        newAccount.sub_Type__c = 'Buyer';
        newAccount.RecordTypeid = rt;
        newAccount.onboarding_stage__c = '99.Onboarded';
        //newAccount.agent__C = agentID;
        newAccount.Public_Profile__c = 'test';
        newAccount.onboarding_next_action_on__c = '*onboarded*';
        newAccount.onboarding_approved__c = true;
        newAccount.suspended__c = false;
        newAccount.has_ewallet__c = true;
        
        existingAccount = [SELECT id FROM Account WHERE Name=:newAccount.Name];
        if (existingAccount.isEmpty())
            insert newAccount;
        if (!existingAccount.isEmpty()) return existingAccount[0].id;
        return newAccount.id;
        
    }

    
}