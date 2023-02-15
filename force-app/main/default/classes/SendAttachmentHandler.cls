public class SendAttachmentHandler {
    //Uncomment annotation when you want to test email and PDF formatting without going to the whole invoicing flow
    //Open EmailAttachment.vfp and add &Id=XXXXXXXXX to the end of the preview URL
    //XXXXXXXXX is the tax invoice id
    //@RemoteAction
    @Future(callout=true)
    public static void sendAttachment(String emailAddress, Id objectId, String originalInvoiceId, String invoiceReferenceNumber) {
        Blob pdfBlob;
        Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
        Helper_Log logs = new Helper_Log();
        IncomlendPricing_v3_Configuration.NotificationConfiguration notification = null;
        
        if (!Test.isRunningTest()) {
        	notification = new IncomlendPricing_v3_Configuration.NotificationConfiguration();
        }
        
        PageReference pageRef;
        String fileName;
        
        try {
            if (String.isBlank(originalInvoiceId)) {
                pageRef = Page.IncomlendInvoice;
                fileName = InvoiceUtil.TAX_INVOICE;
            } else {
                pageRef = Page.IncomlendCreditNote;
                fileName = InvoiceUtil.CREDIT_NOTE;
            }
            
            pageRef.getParameters().put(InvoiceUtil.PARAM_ID, objectId);
            pageRef.setRedirect(true);
            
            if (Test.isRunningTest()) {
                if (String.isBlank(objectId)) {
                    CalloutException e = new CalloutException();
                    e.setMessage('Exception thrown');
                    throw e;
                } else {
                    pdfBlob = Blob.toPdf('Email Attachment unit test is running.');
                }
            } else {
                pdfBlob = pageRef.getContent();
            }
            
            fileAttachment.setFileName(fileName);
            fileAttachment.setBody(pdfBlob);
            
            Id incomlendOpsOrgEmailId = [select Id
                                         from OrgWideEmailAddress
                                         where Address = :InvoiceUtil.EMAIL_FROM
                                         order by CreatedBy.CreatedDate asc
                                         LIMIT 1].Id;
            Id invoiceEmailTemplateId = [select Id
                                         from EmailTemplate
                                         where Name = :InvoiceUtil.EMAIL_TEMPLATE
                                         order by CreatedBy.CreatedDate asc
                                         LIMIT 1].Id;
            
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(invoiceEmailTemplateId, null, null);
            singleEmail.setOrgWideEmailAddressId(incomlendOpsOrgEmailId);
            singleEmail.setCcAddresses(new List<String>{InvoiceUtil.EMAIL_CC});
            singleEmail.setSubject(InvoiceUtil.EMAIL_SUBJECT + invoiceReferenceNumber);
            
            if (String.isNotBlank(emailAddress)) {
                singleEmail.setToAddresses(new List<String>{emailAddress});
            }
            
            singleEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{fileAttachment});
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
}