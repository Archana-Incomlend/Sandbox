global class EWalletTrusteeCustomClass {
	public id id { get; set; }
    public String name { get; set; }
    public String accountId { get; set; }
    public String currencyUnit { get; set; }
    public Decimal balance { get; set; }
    public String trustee { get; set; }
    
    public EWalletTrusteeCustomClass(eWallet_Trustee__c eWallet) {
        this.id = eWallet.Id;
        this.name = eWallet.Name;
        this.accountId = eWallet.Account__c;
        this.currencyUnit = eWallet.CCY__c;
        this.balance = eWallet.Balance__c;
        this.trustee = eWallet.Trustee__c;
	}

}