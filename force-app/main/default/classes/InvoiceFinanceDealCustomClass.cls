global class InvoiceFinanceDealCustomClass {
	public id id { get; set; }
    public String name { get; set; }
    public String supplierBuyerMapId { get; set; }
    public String phase { get; set; }
    public String supplierInvoiceReferenceNumber { get; set; }
    public String buyerPurchaseOrderReference { get; set; }
    public Decimal supplierDiscountRate { get; set; }
    public String currencyUnit { get; set; }
    public Decimal faceValue { get; set; }
    public Decimal requestedAmount { get; set; }
    public Decimal invoiceAmount { get; set; }
    public Date invoiceDate { get; set; }
    public Date dueDate { get; set; }
    public Date submittedDate { get; set; }
    public Date advanceSendToSupplierDate { get; set; }
    public Date actualRepaymentReceivedDate { get; set; }
    public Decimal repaidAmount { get; set; }
    public String incoterm { get; set; }
    public String trustee { get; set; }
    public Decimal fxRate { get; set; }
    public Decimal faceValueUSD { get; set; }
    public Decimal requestedAmountUSD { get; set; }
    public Decimal invoiceAmountUSD { get; set; }
    
    public InvoiceFinanceDealCustomClass(invoice_finance_deal__c deal) {
        this.id = deal.Id;
        this.name = deal.Name;
        this.supplierBuyerMapId = deal.Supplier_Buyer_Map__c;
        this.phase = deal.Phase__c;
        this.supplierInvoiceReferenceNumber = deal.supplier_invoice_reference_number__c;
        this.buyerPurchaseOrderReference = deal.buyer_purchase_order_reference__c;
        this.supplierDiscountRate = deal.Total_Supplier_Discount__c;
        this.currencyUnit = deal.CCY__c;
        this.faceValue = deal.Real_Face_Value__c;
        this.faceValueUSD = deal.USD_Daily_FX_Real_Value_Invoice__c;
        this.requestedAmount = deal.requested_amount__c;
        this.invoiceAmount = deal.invoice_amount__c;
        this.invoiceAmountUSD = deal.USD_Daily_FX_invoice_Amount__c;
        this.fxRate = deal.FX_conversion_rate__c;
        if (this.fxRate != null && this.fxRate == 0 && this.requestedAmount != null) {
            this.requestedAmountUSD = this.fxRate * this.requestedAmount;
        } else if (this.currencyUnit == 'USD' && this.requestedAmount != null) {
            this.requestedAmountUSD = this.requestedAmount;
        }
        this.invoiceDate = deal.Invoice_date__c;
        this.dueDate = deal.Due_Date__c;
        this.submittedDate = deal.submitted_date__c;
        this.advanceSendToSupplierDate = deal.advance_send_to_supplier_date__c;
        this.actualRepaymentReceivedDate = deal.Actual_Repayment_Received_Date__c;
        this.repaidAmount = deal.Repaid_Amount__c;
        this.incoterm = deal.Incoterm__c;
        this.trustee = deal.Trustee__c;
	}

}