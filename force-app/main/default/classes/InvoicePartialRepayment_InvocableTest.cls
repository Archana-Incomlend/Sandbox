@isTest
private class InvoicePartialRepayment_InvocableTest {
  private static testMethod void runInvocable() {
    InvoicePartialRepayment_Invocable.InvoicePartialPaymentRequest request = new InvoicePartialRepayment_Invocable.InvoicePartialPaymentRequest();
    request.invoiceId = null;
    request.repaidAmount = 10000;
    request.dueDate = Date.today();
    request.isOverdueCapped = true;
    request.isSimulation = true;

    List<InvoicePartialRepayment_Invocable.InvoicePartialPaymentRequest> requestList = new List<InvoicePartialRepayment_Invocable.InvoicePartialPaymentRequest>();
    requestList.add(request);

    InvoicePartialRepayment_Invocable.createInvoicePartialRepaymentObjects(requestList);
  }
}