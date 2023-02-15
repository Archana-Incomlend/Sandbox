@isTest(SeeAllData=true)
private class ClosePeriod_test {
    static testMethod void myTest() {
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    ID batchprocessid = Database.executeBatch(new closeperiod('xxxx-xx'));
     
    }
}