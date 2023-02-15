@isTest
private class SendSlackMessageToInvoiceProcessingTest {

    static testMethod void myUnitTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        List<String> Message = new List<String>();
        message.add('test');
        SendSlackMessageToInvoiceProcessing.send(message);

    }
}