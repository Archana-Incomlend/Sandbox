@isTest
private class RefreshInprogress_test {
    static testMethod void myTest() {
        Map<String, Object> result = SeedTest.init(null, null, 'funded');
        Invoice_allocation__c allocation = (Invoice_allocation__c)result.get('invAllocation');    
        allocation.Buyer_name_value__c = 'abc';
        update allocation;
        RefreshInprogress.updateInprogresss();
    }
}