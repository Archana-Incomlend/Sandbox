@isTest
private class RefreshOverDueDays_test {
    static testMethod void myTest() {
        Map<String, Object> result = SeedTest.init(null, null, ' funded overdue');
        Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        invoice.Actual_Repayment_Received_Date__c = invoice.Due_Date__c.addDays(12);
        invoice.over_due_days_value__c = 55;
        update invoice;
        RefreshOverDueDays.updateoverduedays();
     
    }
}