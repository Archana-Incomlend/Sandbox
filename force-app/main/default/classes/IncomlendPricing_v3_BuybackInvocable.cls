global class IncomlendPricing_v3_BuybackInvocable
{
	// =================
	// Invocable Methods
	// =================
	@InvocableMethod(label='Create Buyback Transactions Pricing v3')
	global static List<Boolean> CreateBuybackTransactions(List<CreateTransactionsRequest> requests)
	{
		List<Boolean> result = new List<Boolean>();
		for (CreateTransactionsRequest request : requests)
		{
			IncomlendPricing_v3 buybackProcess = new IncomlendPricing_v3(request.InvoiceId);
			result.add(buybackProcess.BuybackInvoice(request.buybackDate));
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

		@InvocableVariable(required=true)
		global Date buybackDate;
	}
}