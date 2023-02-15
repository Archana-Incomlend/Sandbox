global class IncomlendPricing_v3_PartialFundedInvocbl
{
	// =================
	// Invocable Methods
	// =================
	@InvocableMethod(label='Create PartialFunded Transactions Pricing v3')
	global static List<Boolean> CreatePartialFundedTransactions(List<CreateTransactionsRequest> requests)
	{
		List<Boolean> result = new List<Boolean>();
		for (CreateTransactionsRequest request : requests)
		{
			IncomlendPricing_v3 pricingv3 = new IncomlendPricing_v3(request.InvoiceId);
			result.add(pricingv3.PartialFundedInvoice(request.partialFundedDate));
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
		global Date partialFundedDate;
	}
}