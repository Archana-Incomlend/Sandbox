public class InvoiceFeesController_v1 {
    public List<Tax_Invoice_Fee_Breakdown__c> invoiceFeesList {
        get;
        private set;
    }
    
    public InvoiceFeesController_v1(ApexPages.StandardController standardController) {
        Helper_Log logs = new Helper_Log();
        IncomlendPricing_v3_Configuration.NotificationConfiguration notification = null;
        
        if (!Test.isRunningTest()) {
        	notification = new IncomlendPricing_v3_Configuration.NotificationConfiguration();
        }
        
        Tax_Invoice__c invoice;
        Id invoiceId;
        
        try {
            invoice = (Tax_Invoice__c) standardController.getRecord();
            invoiceId = invoice.Id;
            invoiceFeesList = [select Description__c,
                                      Unit_Price__c,
                                      Amount_Excl_GST__c,
                                      Quantity__c
                               from Tax_Invoice_Fee_Breakdown__c
                               where Tax_Invoice__c = :invoiceId];
        } catch (Exception e) {
            logs.LogLine();
            logs.Log('Tax Invoice: ' + invoice, 1, Helper_Log.Color.Blue);
            logs.Log('Tax Invoice Id: ' + invoiceId, 1, Helper_Log.Color.Blue);
            logs.Log('Tax Invoice Fees: ' + invoiceFeesList, 1, Helper_Log.Color.Blue);
            logs.Log(e);
            logs.LogLine();
            
            if (!Test.isRunningTest()) {
            	Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
            }
        }
    }
}