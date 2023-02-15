global class InvoiceAllocationCustomClass {
	public id id { get; set; }
    public String name { get; set; }
    public String funderId { get; set; }
    public String status { get; set; }
    public Datetime allocationReservationDate { get; set; }
    public Datetime allocationConfirmedDate { get; set; }
    public String currencyUnit { get; set; }
    public Decimal amount { get; set; }
    public String invoiceFinanceDealId { get; set; }
    public Decimal monthlyDiscountRate { get; set; }
    public Decimal incomlendProfitShare { get; set; }
    
    public InvoiceAllocationCustomClass(Invoice_Allocation__c invoiceAllocation) {
        this.id = invoiceAllocation.Id;
        this.name = invoiceAllocation.Name;
        this.funderId = invoiceAllocation.Funder__c;
        this.status = invoiceAllocation.Status__c;
        this.allocationReservationDate = invoiceAllocation.Allocation_Reservation_date__c;
        this.allocationConfirmedDate = invoiceAllocation.Allocation_Confirmed_Date__c;
        this.currencyUnit = invoiceAllocation.CCY__c;
        this.amount = invoiceAllocation.amount__c;
        this.invoiceFinanceDealId = invoiceAllocation.Invoice__c;
        this.monthlyDiscountRate = invoiceAllocation.Applied_MPR__c;
        this.incomlendProfitShare = invoiceAllocation.Incomlend_Profit_share__c;
	}

}