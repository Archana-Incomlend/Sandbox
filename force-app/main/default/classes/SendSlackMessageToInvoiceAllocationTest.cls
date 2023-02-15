@isTest
private class SendSlackMessageToInvoiceAllocationTest {

    static testMethod void myUnitTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        List<String> Message = new List<String>();
        message.add('test');
        SendSlackMessageToInvoiceAllocation.send(message);

    }
}