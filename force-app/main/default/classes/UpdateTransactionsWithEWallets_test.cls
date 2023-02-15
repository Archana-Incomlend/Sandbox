@isTest(SeeAllData=true)
private class UpdateTransactionsWithEWallets_test {
    static testMethod void myTest() {
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    ID batchprocessid = Database.executeBatch(new UpdateTransactionsWithEWallets('XXX'));
     
    }
}