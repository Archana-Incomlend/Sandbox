global class SupplierBuyerMapCustomClass {
	public id id { get; set; }
    public String name { get; set; }
    public String supplierId { get; set; }
    public String buyerdId { get; set; }
    public String marketplaceId { get; set; }
    public List<String> sector { get; set; }
    public List<String> goodsAndServices { get; set; }
    public List<String> trustee { get; set; }
    public String mapOnboardingStage { get; set; }
    public String geographicalZone { get; set; }
    public String mapSalesOwner { get; set; }
    public Decimal creditLimitProvidedByInsurer { get; set; }
    public Decimal creditLimitIncomlend { get; set; }
    public Date creditInsuranceCoverageStartingDate { get; set; }
    public Decimal creditLimitAvailable { get; set; }
    
    public SupplierBuyerMapCustomClass(Supplier_Buyer_Map__c supplierBuyerMap) {
        this.id = supplierBuyerMap.Id;
        this.name = supplierBuyerMap.Name;
        this.supplierId = supplierBuyerMap.Supplier__c;
        this.buyerdId = supplierBuyerMap.Buyer__c;
        this.marketplaceId = supplierBuyerMap.Marketplace__c;
        if (supplierBuyerMap.Sector__c != null && supplierBuyerMap.Sector__c != '') {
        	this.sector = supplierBuyerMap.Sector__c.split(';');
        }
        if (supplierBuyerMap.Goods_and_Services_new__c != null && supplierBuyerMap.Goods_and_Services_new__c != '') {
        	this.goodsAndServices = supplierBuyerMap.Goods_and_Services_new__c.split(';');
        }
        if (supplierBuyerMap.Trustee__c != null && supplierBuyerMap.Trustee__c != '') {
            this.trustee = supplierBuyerMap.Trustee__c.split(';');
        }
        this.mapOnboardingStage = supplierBuyerMap.map_onboarding_stage__c;
        this.geographicalZone = supplierBuyerMap.Geographical_zone__c;
        this.mapSalesOwner = supplierBuyerMap.Map_Sales_Owner__c;
        this.creditLimitProvidedByInsurer = supplierBuyerMap.Credit_Limit_Provided_by_Insurer__c;
        this.creditLimitIncomlend = supplierBuyerMap.CL_USD_Incomlend_for_this_Map__c;
        this.creditInsuranceCoverageStartingDate = supplierBuyerMap.Credit_Insurance_Coverage_Starting_Date__c;
        this.creditLimitAvailable = supplierBuyerMap.CL_USD_Available_for_this_Map__c;
	}

}