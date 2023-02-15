@isTest
private class InvoicePassthrough_InvocableTest {
  private static testMethod void runInvocable() {
    Map<String, Object> result = SeedTest.init(null, null, null);//'passthrough');
    Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
    invoice.Phase__c = '3:IN PROGRESS';
    invoice.Status__c = 'In progress';    
    invoice.platform_fee_fixed__c = 30;
    update invoice;

    InvoicePassthrough_Invocable.InvoicePassthroughRequest request = new InvoicePassthrough_Invocable.InvoicePassthroughRequest();
    request.invoiceId = invoice.Id;
    List<InvoicePassthrough_Invocable.InvoicePassthroughRequest> requestList = new List<InvoicePassthrough_Invocable.InvoicePassthroughRequest>();
    requestList.add(request);

    Test.startTest();
    InvoicePassthrough_Invocable.createInvoicePassthroughObjects(requestList);
    Test.stopTest();
  }
}