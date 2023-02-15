global class BankAccountCustomClass {
	public id id { get; set; }
    public String name { get; set; }
    public String accountId { get; set; }
    public String beneficiaryName { get; set; }
    public String bankName { get; set; }
    public String country { get; set; }
    public String address { get; set; }
    public String bankAccountNumber { get; set; }
    public String iban { get; set; }
    public String currencyUnit { get; set; }
    public String swiftCode { get; set; }
    public String incomlendAccount { get; set; }
    public String transferCutoffTime { get; set; }
    public Decimal estimatedTransferTime { get; set; }
    
    public BankAccountCustomClass(Bank_Account__c bankAccount) {
        this.id = bankAccount.Id;
        this.name = bankAccount.Name;
        this.accountId = bankAccount.Account__c;
        this.beneficiaryName = bankAccount.Beneficiary_Name__c;
        this.bankName = bankAccount.Bank_Name__c;
        this.country = bankAccount.Country__c;
        this.address = bankAccount.Address__c;
        this.bankAccountNumber = bankAccount.Bank_Account_Number__c;
        this.iban = bankAccount.IBan__c;
        this.currencyUnit = bankAccount.Currency__c;
        this.swiftCode = bankAccount.SWIFT_Code__c;
        this.incomlendAccount = bankAccount.Incomlend_Account__c;
        this.transferCutoffTime = bankAccount.transfer_cutoff_time__c;
        this.estimatedTransferTime = bankAccount.estimated_transfer_time__c;
	}

}