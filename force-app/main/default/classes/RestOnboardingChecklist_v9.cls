@RestResource(urlMapping='/v9/onboardingchecklist')

global with sharing class RestOnboardingChecklist_v9 {
      
    @HttpGet
    global static void doGet() {
    
        System.debug('RestOnboardingChecklist_v9 call');
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.headers.put('Content-Type', 'application/json');
        res.statusCode = 200;

        GlobalMethods_v9.OnboardingChecklistListReturnClass result;
        
        //Get URL paramaters  
        String p_accountId = RestContext.request.params.get('accountId'); 
        String p_documentType = RestContext.request.params.get('documentType'); 
        String p_attachmentId = RestContext.request.params.get('attachmentId'); 
        
        //Initializing and declaring variables
        String v_listQuery;
        String v_detailQueryFieldSet = '';
        String v_detailQueryFieldSetCondition = '';
        List<onboarding_checklist__c> v_result = new List<onboarding_checklist__c> ();
        
        //Validating account Id
        if(p_accountId != null && GlobalMethods_v9.isValidId(p_accountId) == false) {
            result = new GlobalMethods_v9.OnboardingChecklistListReturnClass('false','Invalid account id', null);
            res.responseBody = Blob.valueOf(JSON.serialize(result));
            return;
        }
        if(!String.isEmpty(p_attachmentId) && GlobalMethods_v9.isValidId(p_attachmentId) == false) {
            result = new GlobalMethods_v9.OnboardingChecklistListReturnClass('false','Invalid attachment id', null);
            res.responseBody = Blob.valueOf(JSON.serialize(result));
            return;
        }
        
        v_detailQueryFieldSet = 'Id, Name, Document_Type__c ';
        v_detailQueryFieldSet += ', (SELECT Id, Name, ContentType, LastModifiedDate FROM Attachments)';
        // v_detailQueryFieldSetCondition = ' AND document_expiry__c <= System.today()';
        if(!String.isEmpty(p_documentType)) {
            v_detailQueryFieldSetCondition += ' AND Document_Type__c = \'' + p_documentType + '\'';
        }
        if (!String.isEmpty(p_attachmentId)) {
            v_listQuery = 'Id, (SELECT Id FROM Attachments WHERE Id = \'' + p_attachmentId + '\')';
        } 
        v_listQuery = 'SELECT '+v_detailQueryFieldSet + ' FROM onboarding_checklist__c WHERE account__c = :p_accountId '+v_detailQueryFieldSetCondition;

        //Run the query and return result
        v_result = database.query(v_listQuery);
        if (!String.isEmpty(p_attachmentId)) {
            if (v_result.size() == 0) {
                result = new GlobalMethods_v9.OnboardingChecklistListReturnClass('false','Cannot find attachment', null);
                res.responseBody = Blob.valueOf(JSON.serialize(result));
                return;
            }
            Attachment attachment = [SELECT Id, ContentType, Name, Body FROM Attachment WHERE Id = :p_attachmentId];
            if (attachment.ContentType == null)
                res.headers.put('Content-Type', 'application/octet-stream');
            else 
                res.headers.put('Content-Type', attachment.ContentType);
            res.headers.put('Content-Length', String.valueof(attachment.Body.size()));
            res.headers.put('Content-Disposition', 'attachment; filename="' + attachment.Name + '"');
            res.responseBody = attachment.Body;
            return;
        }
        result = new GlobalMethods_v9.OnboardingChecklistListReturnClass('true', 'Query executed successfully.', v_result);
        res.responseBody = Blob.valueOf(JSON.serialize(result));
    }
 
}