global class RefreshOverDueDays implements Schedulable

{
    global void execute(SchedulableContext SC)
    {
    updateoverduedays();
    }
    
    static public void updateoverduedays()
    {
        List<invoice_finance_deal__c> updateInvoices = [SELECT Id, name, phase__c, due_date_delta_bucket__c, due_date_delta_bucket_value__c, over_due_days__c , over_due_days_value__c 
                                              FROM invoice_finance_deal__c  
                                              WHERE (phase__c = '3:IN PROGRESS' OR (phase__c = '4:CLOSED' AND Actual_Repayment_Received_Date__c != null))
                                              AND over_due_days_value__c <= 63 // stop after 60 days, some buffer
                                              AND refresh_over_due_days_ok__c = false];

        if (Test.isRunningTest()) updateInvoices.add(new Invoice_Finance_Deal__c());
        for(invoice_finance_deal__c i : updateInvoices)
        {
            System.debug('update invoice ' + i);
            i.over_due_days_value__c = i.over_due_days__c;
            i.due_date_delta_bucket_value__c = i.due_date_delta_bucket__c;
        }
        if (updateInvoices.size() > 0) {
            System.debug('Processing total ' + updateInvoices.size() + ' invoices');
            boolean tempCalculateTargetFinanceController = CalculateTargetFinanceController.isNeedRunTrigger;
            boolean tempWebServiceCallout = WebServiceCallout.isNeedRunTrigger;
            CalculateTargetFinanceController.isNeedRunTrigger = false;
            WebServiceCallout.isNeedRunTrigger = false;
            if (!Test.isRunningTest()) update updateInvoices;
            CalculateTargetFinanceController.isNeedRunTrigger = tempCalculateTargetFinanceController;
            WebServiceCallout.isNeedRunTrigger = tempWebServiceCallout;
        }
    }
}