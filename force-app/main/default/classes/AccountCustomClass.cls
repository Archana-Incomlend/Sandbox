global class AccountCustomClass {
	public id id { get; set; }
    public String name { get; set; }
    public String companyRegistrationNumber { get; set; }
    public String onboardingStage { get; set; }
    public String type { get; set; }
    public String subType { get; set; }
    public String countryOfIncorporation { get; set; }
    public Decimal yearOfIncorporation { get; set; }
    public AddressCustomClass billingAddress { get; set; }
    public AddressCustomClass shippingAddress { get; set; }
    public String sector { get; set; }
    public String goodsAndServices { get; set; }
    public String insuredByc { get; set; }
    public Decimal annualRevenue { get; set; }
    public Double numberOfEmployees { get; set; }
    public Decimal creditLimitedProvidedByInsurer { get; set; }
    public Decimal totalCreditLimitFromIncomlend { get; set; }
    public String salesOwner { get; set; }
    public List<String> trustee { get; set; }
    public List<eWalletCustomClass> eWallet {get;set;}
    public appliedMPRCustomClass appliedMPR {get;set;}
    public appliedFunderDiscountProfitCustomClass appliedFunderDiscountProfit {get;set;}
    
    public AccountCustomClass(Account account, String fieldSetType) {
        this.id = account.Id;
        this.name = account.Name;
        this.subType = account.Sub_type__c;
        this.companyRegistrationNumber = account.Company_registration_number__c;
        this.onboardingStage = account.onboarding_stage__c;
        this.type = account.Type;
        this.countryOfIncorporation = account.Country_of_Incorporation__c;
        this.yearOfIncorporation = account.Year_of_incorporation__c;
        this.billingAddress = account.BillingAddress != null ? new AddressCustomClass(account.BillingAddress) : null;
        this.shippingAddress = account.ShippingAddress != null ? new AddressCustomClass(account.ShippingAddress) : null;
        this.sector = account.Sector__c;
        this.goodsAndServices = (account.Goods_and_Services_new__c != null) ? account.Goods_and_Services_new__c : account.Goods_or_Services_Offered__c;
        this.insuredByc = account.Insured_by__c;
        this.annualRevenue = account.AnnualRevenue;
        this.numberOfEmployees = account.NumberOfEmployees;
        this.creditLimitedProvidedByInsurer = account.Credit_Limited_Provided_by_Insurer__c;
        this.totalCreditLimitFromIncomlend = account.Total_CL_Limit_from_Incomlend__c;
        this.salesOwner = account.Sales_Owner__r.Name;
        if (account.Trustee__c != null && account.Trustee__c != '') {
            this.trustee = account.Trustee__c.split(';');
        }

        this.eWallet = new List<eWalletCustomClass>();
        for (eWallet__c eWalletRec : account.eWallets__r) {
            this.eWallet.add(new eWalletCustomClass(eWalletRec));
        }
        
        // Applied MPR
        this.appliedMPR = new appliedMPRCustomClass();
        this.appliedMPR.Gross_Funder_Discount_Rate_EUR = account.Gross_Funder_Discount_Rate_EUR__c;
        this.appliedMPR.Gross_Funder_Discount_Rate_GBP = account.Gross_Funder_Discount_Rate_GBP__c;
        this.appliedMPR.Gross_Funder_Discount_Rate_HKD = account.Gross_Funder_Discount_Rate_HKD__c;
        this.appliedMPR.Gross_Funder_Discount_Rate_SGD = account.Gross_Funder_Discount_Rate_SGD__c;
        this.appliedMPR.Gross_Funder_Discount_Rate_USD = account.Gross_Funder_Discount_Rate_USD__c;
        
        // Applied Funder Discount Profit Share Pct
        this.appliedFunderDiscountProfit = new appliedFunderDiscountProfitCustomClass();
        this.appliedFunderDiscountProfit.Discount_Profit_Share_Percent_EUR = account.Discount_Profit_Share_Percent_EUR__c;
        this.appliedFunderDiscountProfit.Discount_Profit_Share_Percent_GBP = account.Discount_Profit_Share_Percent_GBP__c;
        this.appliedFunderDiscountProfit.Discount_Profit_Share_Percent_HKD = account.Discount_Profit_Share_Percent_HKD__c;
        this.appliedFunderDiscountProfit.Discount_Profit_Share_Percent_SGD = account.Discount_Profit_Share_Percent_SGD__c;
        this.appliedFunderDiscountProfit.Discount_Profit_Share_Percent_USD = account.Discount_Profit_Share_Percent_USD__c;
	}

    public class eWalletCustomClass {
        public String eWalletId { get; set; }
        public String CCY { get; set; }

        public eWalletCustomClass(){}
        public eWalletCustomClass(eWallet__c eWalletRec) {
            this.eWalletId = eWalletRec.name;
            this.CCY = eWalletRec.CCY__c;
        }
    }
    
    public class appliedMPRCustomClass{
        public Decimal Gross_Funder_Discount_Rate_EUR { get; set; }
        public Decimal Gross_Funder_Discount_Rate_GBP { get; set; }
        public Decimal Gross_Funder_Discount_Rate_HKD { get; set; }
        public Decimal Gross_Funder_Discount_Rate_SGD { get; set; }
        public Decimal Gross_Funder_Discount_Rate_USD { get; set; }
        
        public appliedMPRCustomClass(){}
    }
    
    public class appliedFunderDiscountProfitCustomClass{
        public Decimal Discount_Profit_Share_Percent_EUR { get; set; }
        public Decimal Discount_Profit_Share_Percent_GBP { get; set; }
        public Decimal Discount_Profit_Share_Percent_HKD { get; set; }
        public Decimal Discount_Profit_Share_Percent_SGD { get; set; }
        public Decimal Discount_Profit_Share_Percent_USD { get; set; }
        
        public appliedFunderDiscountProfitCustomClass(){}
    }
    // Update for ITM-1194 end
}