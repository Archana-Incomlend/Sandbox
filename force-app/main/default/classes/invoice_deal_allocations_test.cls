@isTest
private class invoice_deal_allocations_test {
    static testmethod void myTest() {
        
        Map<String, Object> result = SeedTest.init();
        Invoice_Allocation__c a = (Invoice_allocation__c)result.get('invAllocation');
        a.Status__c = 'Confirmed';
        update a;
    }
}