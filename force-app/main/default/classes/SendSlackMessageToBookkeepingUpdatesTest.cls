@isTest
private class SendSlackMessageToBookkeepingUpdatesTest {

    static testMethod void myUnitTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        List<String> Message = new List<String>();
        message.add('test');
        SendSlackMessageToBookkeepingUpdates.send(message);

    }
}