global class IncomlendPricing_v3_ClosingInvocable
{
	// =================
	// Invocable Methods
	// =================    
	@InvocableMethod(label='Create Closing Transactions Pricing v3')
	global static List<Boolean> CreateClosingTransactions(List<CreateTransactionsRequest> requests)
	{
		List<Boolean> result = new List<Boolean>();
		for (CreateTransactionsRequest request : requests)
		{
			IncomlendPricing_v3 fundingProcess = new IncomlendPricing_v3(request.InvoiceId);
			result.add(fundingProcess.CloseInvoice());
		}
		return result;
	}
    
    // =======
    // Classes
    // =======
	global class CreateTransactionsRequest
	{
		@InvocableVariable(required=true)
		global ID invoiceId;
	}
}