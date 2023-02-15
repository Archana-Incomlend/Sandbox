global class IncomlendPricing_v3_FundingInvocable
{
	// =================
	// Invocable Methods
	// =================
	@InvocableMethod(label='Create Funding Transactions Pricing v3')
	global static List<Boolean> CreateFundingTransactions(List<CreateTransactionsRequest> requests)
	{
		List<Boolean> result = new List<Boolean>();
		for (CreateTransactionsRequest request : requests)
		{
			IncomlendPricing_v3 fundingProcess = new IncomlendPricing_v3(request.InvoiceId);
			result.add(fundingProcess.FundInvoice());
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