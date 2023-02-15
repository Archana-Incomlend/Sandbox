trigger SendInvoiceTrigger on Tax_Invoice__c (after insert) {
    Set<Id> newIdSet = Trigger.newMap.keySet();
    List<Tax_Invoice__c> newInvoiceList = [select Id,
                                                  Email__c,
                                                  Original_Invoice_Number__c,
                                                  Invoice_Reference_Number__c
                                           from Tax_Invoice__c
                                           where Id in :newIdSet];
    
	for (Tax_Invoice__c invoice : newInvoiceList) {
        String emailAddress = invoice.Email__c;
        
        if (InvoiceUtil.isRunningInSandbox) {
            emailAddress = String.isBlank(emailAddress) || !emailAddress.contains(InvoiceUtil.YOPMAIL) ? InvoiceUtil.TEST_EMAIL_TO : emailAddress;
        } else {
            emailAddress = String.isBlank(emailAddress) ? '' : emailAddress;
        }
        
        SendAttachmentHandler.sendAttachment(emailAddress, invoice.Id, invoice.Original_Invoice_Number__c, invoice.Invoice_Reference_Number__c);
        
        if (Test.isRunningTest()) {
            SendAttachmentHandler.sendAttachment(InvoiceUtil.TEST_EMAIL_TO, null, invoice.Original_Invoice_Number__c, invoice.Invoice_Reference_Number__c);
        }
    }
}