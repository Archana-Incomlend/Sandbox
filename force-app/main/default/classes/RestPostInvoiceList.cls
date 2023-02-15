//===============================================================================================================
// Part of the Batch Invoice Process
// This class defines the POST controller and service logic regarding the process of inserting multiple invoices Objects at once.
// 
// Author: Claire PROVOT
// Modify: Mel Dinh (avoid duplicate submission)
//===============================================================================================================
@RestResource(urlMapping='/v9/invoices/*')

global with sharing class RestPostInvoiceList {

    @HttpPost
    global static GlobalMethods.InvoiceListReturnClass doPost(String invoiceListStr) {

        //===========================================================================================================
        // Logs config
        //===========================================================================================================
        IncomlendPricing_v3_Configuration.NotificationConfiguration notification = null;
        if (!Test.isRunningTest()) {
                notification = new IncomlendPricing_v3_Configuration.NotificationConfiguration();
        }
        Helper_Log logs = new Helper_Log();

        //===========================================================================================================
        // Fields
        //===========================================================================================================
        List <Invoice_Finance_Deal__c> v_result = new List <Invoice_Finance_Deal__c> ();
        List<Id> invoiceIdList = new List<Id>();


        logs.LogLine();
        logs.LogLine();
        logs.Log('RestPostInvoiceList() method called by ' + UserInfo.getName(), 1, Helper_Log.Color.Blue);
        logs.LogLine();
        logs.LogLine();

        logs.LogLine();
        logs.LogLine();
        logs.Log('Raw parameters :' + invoiceListStr, 2, Helper_Log.Color.Black);
        logs.LogLine();
        logs.LogLine();

        if (String.isBlank(invoiceListStr))
            return new GlobalMethods.InvoiceListReturnClass('false', 'Input is empty', null);

        // Deserialization
        List<Invoice_Finance_Deal__c> invoiceList = new List<Invoice_Finance_Deal__c>();
        try {
            invoiceList = (List<Invoice_Finance_Deal__c>)JSON.deserialize(invoiceListStr, List<Invoice_Finance_Deal__c>.Class);
        } catch (Exception ex) {
            return new GlobalMethods.InvoiceListReturnClass('false', 'Input has invalid format', null);
        }
        if (invoiceList.size() == 0)
            return new GlobalMethods.InvoiceListReturnClass('false', 'Invoice list is empty', null);

        try {

            String cachedInvoiceListStr = config.getConfig('Marketplace_Cached_Invoice_List_Str');
            String invoiceListHashStr = GlobalTriggerHandler.getHash(invoiceListStr); // data value too large
            if (cachedInvoiceListStr != null && cachedInvoiceListStr != 'key not found' && invoiceListHashStr == cachedInvoiceListStr) {
                return new GlobalMethods.InvoiceListReturnClass('true', 'Duplicate request, please wait for original request to be completed', null);
            }
            
            // DML
            insert invoiceList;
            
            GlobalTriggerHandler.setConfig('Marketplace_Cached_Invoice_List_Str', invoiceListHashStr);

            // Access the ids by obtaining from each invoice in the collection
            for(Invoice_Finance_Deal__c invoice : invoiceList)
            {

                // Call flow
                // Do not call flow for first one which is auto launched by flow trigger
                if (invoiceIdList.size() > 0) {
                    Map<String, Object> params = new Map<String, Object>();
                    params.put('invoiceID', invoice.Id);
                    logs.LogLine();
                    logs.Log('Calling Flow Send slack for invoice change :' + invoice.Id, 2, Helper_Log.Color.Green);
                    Flow.Interview.send_slack_for_invoice_phase_change flow = new Flow.Interview.send_slack_for_invoice_phase_change(params);
                    flow.start();
                }

                invoiceIdList.add(invoice.Id);
            }

            logs.LogLine();
            logs.LogLine();
            logs.LogLine();
            logs.Log('New Invoice Id list :' + invoiceIdList, 2, Helper_Log.Color.Green);
            logs.LogLine();
            logs.LogLine();
            logs.LogLine();

            v_result = [SELECT Id, Name, supplier_invoice_reference_number__c FROM Invoice_Finance_Deal__c WHERE Id IN :invoiceIdList];

        } catch(Exception unmanagedException)
        {
            logs.Log('Exception :' + unmanagedException, 2, Helper_Log.Color.Red);

        }
        /*finally
        {
            // Sends logs for sandbox only
            //Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
        }*/

        // Return results
        if (v_result.size() == 0) {
            return new GlobalMethods.InvoiceListReturnClass('false','No Invoice created', null);
        } else if (v_result.size() < invoiceList.size()) {
            return new GlobalMethods.InvoiceListReturnClass('false','Upload incomplete', null);
        } else {
            return new GlobalMethods.InvoiceListReturnClass('true','Query executed successfully.', v_result);
        } 
    }
}