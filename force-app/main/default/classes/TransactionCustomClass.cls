global class TransactionCustomClass {
	public id id { get; set; }
    public String name { get; set; }
    public Datetime creationDate { get; set; }
    public Date effectiveDate { get; set; }
    public String type { get; set; }
    public String currencyUnit { get; set; }
    public Decimal amount { get; set; }
    public String status { get; set; }
    public String trustee { get; set; }
    public String eWalletTrusteeId { get; set; }
    public String notes { get; set; }
    public String invoiceFinanceDealId { get; set; }
    public String accountId { get; set; }
    public String collatedTransactionId { get; set; }
    public Decimal amountSGD { get; set; }
    public Decimal fxRate { get; set; }
    public Decimal amountUSD { get; set; }
    
    public TransactionCustomClass(Transaction__c tran) {
        this.id = tran.Id;
        this.name = tran.Name;
        this.creationDate = tran.CreatedDate;
        this.effectiveDate = tran.Effective_Date__c;
        this.type = tran.Type__c;
        this.currencyUnit = tran.CCY__c;
        this.amount = tran.Amount__c;
        this.status = tran.Status__c;
        this.trustee = tran.Trustee__c;
        this.eWalletTrusteeId = tran.eWallet_Trustee__c;
        this.notes = tran.notes__c;
        this.invoiceFinanceDealId = tran.Invoice_Finance_Deal__c;
        this.accountId = tran.Account__c;
        this.collatedTransactionId = tran.Related_Transaction__c;
        this.amountSGD = tran.Amount_SGD_equiv__c;
        this.fxRate = tran.FX_rate_conversion__c;
        this.amountUSD = tran.FX_USD_Rate_Daily__c;
	}

}