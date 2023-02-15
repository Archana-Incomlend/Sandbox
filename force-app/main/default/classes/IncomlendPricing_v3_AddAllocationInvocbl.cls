global class IncomlendPricing_v3_AddAllocationInvocbl
{
	// =================
	// Invocable Methods
	// =================
	@InvocableMethod(label='Add Update Allocation Transactions Pricing v3')
	global static List<Boolean> AddAllocationTransactions(List<CreateTransactionsRequest> requests)
	{
		List<Boolean> result = new List<Boolean>();
		for (CreateTransactionsRequest request : requests)
		{
			IncomlendPricing_v3 pricing = new IncomlendPricing_v3(request.InvoiceId);
			result.add(pricing.AddUpdateAllocation(request.addUpdateAllocationDate));
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

		@InvocableVariable(required=false)
		global Date addUpdateAllocationDate;
	}
}