global class InvoicePartialRepayment_Invocable {
  @InvocableMethod(label = 'Create Invoice Repayment Objects')
  global static void createInvoicePartialRepaymentObjects(List<InvoicePartialPaymentRequest> requests) {
    for (InvoicePartialPaymentRequest request : requests) {
	  InvoiceCreateRepaymentObjects invoiceCreateRepaymentObjects = new InvoiceCreateRepaymentObjects(request.InvoiceId,
	      request.repaidAmount, request.dueDate, request.isOverdueCapped, request.isSimulation);
      invoiceCreateRepaymentObjects.createInvoicePartialRepaymentObjects();
	}
  }
    
  global class InvoicePartialPaymentRequest {
	@InvocableVariable(required=true)
	global ID invoiceId;

	@InvocableVariable(required=true)
	global Decimal repaidAmount;

	@InvocableVariable(required=true)
	global Date dueDate;

	@InvocableVariable(required=true)
	global Boolean isOverdueCapped;

	@InvocableVariable(required=true)
	global Boolean isSimulation;
  }
}