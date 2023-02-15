@RestResource(urlMapping='/v9/AuditTrail/*')

global with sharing class RestAuditTrailData_v9 {

    // =====
    // Constants
    // =====

    private static String ALGORITHM_NAME = 'SHA3-256';
    private static String ALGORITHM_NAME_RSA = 'RSA-SHA256';
    private static String CERTIFICATE = 'Incomlend_Self_sign_Test';
    private static String APPROVED = 'Approved';

    // ==========
    // Controller
    // ==========

    @HttpPost
    global static GlobalMethods_v9.AuditReturnClass doPost(String p_type, String p_status, String p_phoneNumber, String p_additionalInfo, String p_requestBody, String p_referenceObjId) {
        Map<String,String> requestHeaders = new Map<String,String>(RestContext.request.headers);   
        IncomlendPricing_v3_Configuration.BehaviourConfiguration behavior;
        String v_email = requestHeaders.get('email');
        Boolean isApproved = APPROVED == p_status;
        Helper_Log logs = new Helper_Log();
        IncomlendPricing_v3_Configuration.NotificationConfiguration notification = null;

        if (!Test.isRunningTest()) {
                notification = new IncomlendPricing_v3_Configuration.NotificationConfiguration();
        }

        Map<String,String> p_FieldSet = new Map<String,String>{
            'email' => v_email,
            'type' => p_type,
            'status' => p_status,
            'phoneNumber' => p_phoneNumber,
            'additionalInfo' => p_additionalInfo,
            'requestBody' => p_requestBody,
            'referenceObjId' => p_referenceObjId
        };
        

        try {

            if (p_type == AuditTrailUtil.GTC_TYPE) {
                buildGTCApproval(p_FieldSet);
            } else if (p_type == AuditTrailUtil.BUYER_REQUEST_TYPE) {
                buildBuyerRequestSignature(p_FieldSet);  
            } else if (p_type == AuditTrailUtil.SUPPLIER_REQUEST_TYPE) {
                buildSupplierRequestSignature(p_FieldSet);  
            } else {
                logs.LogLine();
                logs.Log('Incorrect type: ' + p_type);
                logs.LogLine();
            
                if (!Test.isRunningTest()) {
            	    Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
                }
                return new GlobalMethods_v9.AuditReturnClass('false', 'Incorrect type', false);
            }

        } catch (GeneralException e) {
            logs.LogLine();
            logs.Log(e);
            logs.LogLine();
            
            if (!Test.isRunningTest()) {
            	Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
            }
            return new GlobalMethods_v9.AuditReturnClass('false', e.getMessage(), false);
        }


        return new GlobalMethods_v9.AuditReturnClass('true', 'Query executed successfully.', isApproved);
    }
    
    // ==========
    // Services - Builders
    // ==========

    // This methods build a audit trail, type approval of GTC
    private static void buildGTCApproval(Map<String,String> p_FieldSet) {

        GlobalMethods_v9.ContactReturnClass returnResult;
        returnResult = GlobalMethods_v9.getLoggedinUserData(p_FieldSet.get('email'));
        Contact contactDetails = returnResult.v_records;

        // Versioning of GTC
        // Default version
        String version = 'v1.0';

        if (!Test.isRunningTest()) {
            // Version depending on the sub type of the account
            String key = 'Incomlend_GTC_Latest_Version';
            if (contactDetails.Account.Sub_type__c == 'Supplier') {
                key = 'Incomlend_GTC_Supplier_Latest_Version';
        	} else if (contactDetails.Account.Sub_type__c == 'Buyer') {
                key = 'Incomlend_GTC_Buyer_Latest_Version';
        	} else if (contactDetails.Account.Sub_type__c == 'Purchaser') {
                key = 'Incomlend_GTC_Purchaser_Latest_Version';
            }
            
            // Get version from configuration
            IncomlendPricing_v3_Configuration.BehaviourConfiguration behavior = new IncomlendPricing_v3_Configuration.BehaviourConfiguration(key);
            version = behavior.configMap.get(key);
        }
        String addlInfo = '{GTC Version: ' + version + '}';

        p_FieldSet.put('additionalInfo', addlInfo);
        
        createAuditTrail(p_FieldSet);
    }

    // This methods build a audit trail, type approval of buyer request
    private static void buildBuyerRequestSignature(Map<String,String> p_FieldSet) {

        // Type dependant fields
        Map<String,String> pdfUtils = new Map<String,String>{
            'fileName' => AuditTrailUtil.BUYER_REQUEST_FILE,
            'emailTemplate' => AuditTrailUtil.EMAIL_TEMPLATE_BUYER_REQUEST
        };

        // Mandatory first step
        Audit_Trail__c auditTrail = createAuditTrail(p_FieldSet);
        Blob blobAuditTrail = createBlobAuditTrail(auditTrail);

        // Optional steps
        createHash(blobAuditTrail, auditTrail);
        createSignature(blobAuditTrail, auditTrail);
        if (!String.isBlank(p_FieldSet.get('referenceObjId'))) { 
            saveAttachment(auditTrail.Id, p_FieldSet.get('referenceObjId'), pdfUtils.get('fileName'));
        }
        sendEmail(p_FieldSet, auditTrail.Id, pdfUtils);
        sendSlackMessage(auditTrail);

        // DML
        Invoice_Finance_Deal__c invoice = LoadInvoice(p_FieldSet.get('referenceObjId'));
        if (!String.isBlank(p_FieldSet.get('referenceObjId')) && !Test.isRunningTest()) { 
            invoice.Status__c = 'pending incomlend review';
            update invoice;
        }
    }

    // This methods build a audit trail, type approval of supplier
    private static void buildSupplierRequestSignature(Map<String,String> p_FieldSet) {

        // Type dependant fields
        Map<String,String> pdfUtils = new Map<String,String>{
            'fileName' => AuditTrailUtil.SUPPLIER_REQUEST_FILE,
            'emailTemplate' => AuditTrailUtil.EMAIL_TEMPLATE_SUPPLIER_REQUEST
        };

        // Mandatory first step
        Audit_Trail__c auditTrail = createAuditTrail(p_FieldSet);
        Blob blobAuditTrail = createBlobAuditTrail(auditTrail);

        // Optional steps
        createHash(blobAuditTrail, auditTrail);
        createSignature(blobAuditTrail, auditTrail);
        if (!String.isBlank(p_FieldSet.get('referenceObjId')) && !Test.isRunningTest()) { 
            saveAttachment(auditTrail.Id, p_FieldSet.get('referenceObjId'), pdfUtils.get('fileName'));
        }
        sendEmail(p_FieldSet, auditTrail.Id, pdfUtils);
        sendSlackMessage(auditTrail);

        // DML
        Invoice_Finance_Deal__c invoice = LoadInvoice(p_FieldSet.get('referenceObjId'));
        if (!String.isBlank(p_FieldSet.get('referenceObjId')) && !Test.isRunningTest()) { 
            invoice.Supplier_Request_Signed_Date__c = System.today();
            update invoice;
        }       
    }

    // ==========
    // Services - Components
    // ==========

    // This methods create a audit trail object with request parameters
    private static Audit_Trail__c createAuditTrail(Map<String,String> p_FieldSet) {
        
        GlobalMethods_v9.ContactReturnClass returnResult;
        returnResult = GlobalMethods_v9.getLoggedinUserData(p_FieldSet.get('email'));
        Contact contactDetails = returnResult.v_records;

        Audit_Trail__c auditTrailToCreate = new Audit_Trail__c();
        auditTrailToCreate.Contact__c = contactDetails.Id;
        auditTrailToCreate.Account__c = contactDetails.Account.Id;
        auditTrailToCreate.Name__c = contactDetails.Name;
        auditTrailToCreate.Username__c = p_FieldSet.get('email');
        auditTrailToCreate.X2FA_Mobile_Number__c = p_FieldSet.get('phoneNumber');
        auditTrailToCreate.Type__c = p_FieldSet.get('type');
        auditTrailToCreate.Status__c = p_FieldSet.get('status');
        auditTrailToCreate.Additional_Information__c = p_FieldSet.get('additionalInfo');
        if (!String.isBlank(p_FieldSet.get('referenceObjId'))) {
            auditTrailToCreate.Reference_Object_Id__c = p_FieldSet.get('referenceObjId');
        } else {
            auditTrailToCreate.Reference_Object_Id__c = '-';
        }
        if (!String.isBlank(p_FieldSet.get('requestBody'))) {
            auditTrailToCreate.Request_Body__c = p_FieldSet.get('requestBody');
        } else {
            auditTrailToCreate.Request_Body__c = '-';
        }

        // DML
        insert auditTrailToCreate;

        return auditTrailToCreate;
    }

    // Create Blob of the audit Trail
    private static Blob createBlobAuditTrail (Audit_Trail__c auditTrail) {

        String guid = LoadAuditTrail(auditTrail.Id).guid__c;

        // Concatenate audit trail data as one Blob
        Blob b1 = Blob.valueOf(auditTrail.Name__c);
        Blob b2 = Blob.valueOf(auditTrail.Status__c);
        Blob b3 = Blob.valueOf(auditTrail.Account__c);
        Blob b4 = Blob.valueOf(auditTrail.X2FA_Mobile_Number__c);
        Blob b5 = Blob.valueOf(auditTrail.Contact__c);
        Blob b6 = Blob.valueOf(auditTrail.Additional_Information__c);
        Blob b7 = Blob.valueOf(auditTrail.Reference_Object_Id__c);
        Blob b8 = Blob.valueOf(auditTrail.Type__c);
        Blob b9 = Blob.valueOf(auditTrail.Username__c);
        Blob b10 = Blob.valueOf(auditTrail.Request_Body__c);
        Blob b11 = Blob.valueOf(guid);

        String combinedDataAsHex = EncodingUtil.convertToHex(b1) + EncodingUtil.convertToHex(b2) + EncodingUtil.convertToHex(b3) +
            EncodingUtil.convertToHex(b4) + EncodingUtil.convertToHex(b5) + EncodingUtil.convertToHex(b6) + 
            EncodingUtil.convertToHex(b7) + EncodingUtil.convertToHex(b8) + EncodingUtil.convertToHex(b9) + 
            EncodingUtil.convertToHex(b10) + EncodingUtil.convertToHex(b11);
        Blob combinedDataAsBlob = EncodingUtil.convertFromHex(combinedDataAsHex);
        return combinedDataAsBlob;
    }

    // This methods create the eSignature 
    private static String createSignature(Blob blobAuditTrail, Audit_Trail__c auditTrail) {
        Helper_Log logs = new Helper_Log();
        Blob signature;
              
        signature = System.Crypto.signWithCertificate(ALGORITHM_NAME_RSA, blobAuditTrail, CERTIFICATE);
        
        auditTrail.Signature__c = EncodingUtil.base64Encode(signature);

        // DML
        update auditTrail;

        return EncodingUtil.base64Encode(signature);
    }

    // This methods create the Hash
    private static String createHash(Blob blobAuditTrail, Audit_Trail__c auditTrail) {

        Blob hash = Crypto.generateDigest(ALGORITHM_NAME, blobAuditTrail);

        auditTrail.Hash__c = EncodingUtil.base64Encode(hash);

        // DML
        update auditTrail;

        return EncodingUtil.base64Encode(hash);
    }

    // This methods create and send the email with attachements
    @Future(callout=true)
    private static void sendEmail(Map<String,String> p_FieldSet, Id AuditTrailId, Map<String,String> pdfUtils) {

        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        Helper_Log logs = new Helper_Log();
        IncomlendPricing_v3_Configuration.NotificationConfiguration notification = null;
        String fileName;
        String emailTemplate = pdfUtils.get('emailTemplate');
        PageReference pageRef;
        Blob pdfBlob;

        if (!Test.isRunningTest()) {
                notification = new IncomlendPricing_v3_Configuration.NotificationConfiguration();
        }

        try{                                                         
            Id incomlendOpsOrgEmailId = [select Id
                                            from OrgWideEmailAddress
                                            where Address = :AuditTrailUtil.EMAIL_FROM
                                            order by CreatedBy.CreatedDate asc
                                            LIMIT 1].Id;
            Id invoiceEmailTemplateId = [select Id
                                            from EmailTemplate
                                            where Name = :emailTemplate
                                            order by CreatedBy.CreatedDate asc
                                            LIMIT 1].Id;
            
            // Create email
            // Render the email template with the associate reference object data mapping, if null the template should not contain any data mapping
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(invoiceEmailTemplateId, null, p_FieldSet.get('referenceObjId'));
            
            singleEmail.setOrgWideEmailAddressId(incomlendOpsOrgEmailId);
            singleEmail.setCcAddresses(new List<String>{AuditTrailUtil.EMAIL_CC});
            singleEmail.setSubject(p_FieldSet.get('type'));
                
            if (String.isNotBlank(p_FieldSet.get('email'))) {
                singleEmail.setToAddresses(new List<String>{p_FieldSet.get('email')});
            } 

            // Create Attachment                 
            // If the request Body not blank, we send an pdf attachment
            if (!String.isBlank(p_FieldSet.get('requestBody'))) {

                pageRef = Page.Signature;
                pageRef.getParameters().put('Id', AuditTrailId);
                pageRef.setRedirect(true);

                    // Tests can not handle getContent()
                    if (Test.isRunningTest()) {
                        if (String.isBlank(AuditTrailId)) {
                            CalloutException e = new CalloutException();
                            e.setMessage('Exception thrown');
                            throw e;
                        } else {
                        pdfBlob = Blob.toPdf('Email Attachment unit test is running.');
                        }
                    } else {
                        pdfBlob = pageRef.getContent();
                    }   

                fileName = pdfUtils.get('fileName');
                fileAttachment.setFileName(fileName);

                fileAttachment.setBody(pdfBlob);
                singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{fileAttachment});
            }                

            // Process email sending
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{singleEmail});  

        } catch(Exception ex){
            logs.LogLine();
            logs.Log(ex);
            logs.LogLine();
            
            if (!Test.isRunningTest()) {
            	Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
            }
        } 
    }

    // This methods send a Slack Message
    private static void sendSlackMessage(Audit_Trail__c auditTrail) {

        String v_message =' @ ' + System.now().format('HH:mm:ss') + ' - ' + auditTrail.Type__c + ' - ' 
        + auditTrail.Name__c + ' has approved the request' ; 
        SendSlackMessage.send(config.getConfig('Slack Channel Marketplace URL'), v_message); 
    }

    // This methods save the attachment sent in reference Object
    @future(callout=true)
    private static void saveAttachment(String auditTrailId, Id referenceObj, String fileName) {

        Attachment attach = new Attachment();
        PageReference pageRef;
        Blob pdfBlob;

        pageRef = Page.Signature;
        pageRef.getParameters().put('Id', auditTrailId);
        pageRef.setRedirect(true);

        // Tests can not handle getContent()
        if (Test.isRunningTest()) {
            if (String.isBlank(auditTrailId)) {
                CalloutException e = new CalloutException();
                e.setMessage('Exception thrown');
                throw e;
            } else {
                pdfBlob = Blob.toPdf('Save Attachment unit test is running.');
            }
        } else {
            pdfBlob = pageRef.getContent();
        }   

        attach.Body = pdfBlob;
        attach.Name = fileName;
        attach.IsPrivate = false;
        attach.ParentId = referenceObj;

        // DML
        if (!Test.isRunningTest()) {
            insert attach;
        }
    }
    

    // ==========
    // Services - Load Objects
    // ==========

    // This method loads an invoice
    private static Invoice_finance_deal__c LoadInvoice(id invoiceId)
    {
        Invoice_finance_deal__c result = null;

        try
        {
        // Loads the invoice
        if(invoiceId != null)
            result = [  SELECT  Id,
                                Status__c
            FROM  invoice_finance_deal__c
            WHERE  Id = :invoiceId];
        }
        catch(System.QueryException queryException)
        {
        if(queryException.getMessage() != 'List has no rows for assignment to SObject')
            throw queryException;
        }

        return result;
    }

    // This method loads an audit trail
    private static Audit_Trail__c LoadAuditTrail(id auditTrailId)
    {
        Audit_Trail__c result = null;

        try
        {
        // Loads the audit trail
        if(auditTrailId != null)
            result = [  SELECT  Id,
                                Name__c,
                                X2FA_Mobile_Number__c,
                                Account__c,
                                Additional_Information__c	,
                                Contact__c,
                                guid__c,
                                Reference_Object_Id__c,
                                Request_Body__c,
                                Status__c,
                                Type__c,
                                Username__c
            FROM  Audit_Trail__c
            WHERE  Id = :auditTrailId];
        }
        catch(System.QueryException queryException)
        {
        if(queryException.getMessage() != 'List has no rows for assignment to SObject')
            throw queryException;
        }

        return result;
    }

    // ==========
    // Services - Validation
    // ==========

    public static String checkSignature(Audit_Trail__c auditTrail) {

        Blob blobAuditTrail = createBlobAuditTrail(auditTrail);
        return createSignature(blobAuditTrail, auditTrail);
    }

    public static String checkHash(Audit_Trail__c auditTrail) {

        Blob blobAuditTrail = createBlobAuditTrail(auditTrail);
        return createHash(blobAuditTrail, auditTrail);
    }
}