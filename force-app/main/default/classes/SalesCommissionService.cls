public class SalesCommissionService {

    public static boolean needRunTrigger = true;
    public static boolean IsNeedRunTrigger
    {
      public get  // to enable trigger during test set it to null
      {
        return Test.isRunningTest() ? needRunTrigger == null : needRunTrigger == true;
      }
      public set
      {
          if (value) needRunTrigger = Test.isRunningTest() ? null : true;
          else needRunTrigger = false;
      }
    }

    // ======
    // Fields
    // ======
    private boolean field_hasEncounteredIssues = false;

    // ==========
    // Properties
    // ==========
    // Invoice to process
    public Invoice_finance_deal__c Invoice {
        public get;
        private set;
    }
    // Logs
    public Helper_Log Logs
    {
        public get;
        private set;
    }

    //===========================================================================================================
    // Properties (loaded objects)
    //===========================================================================================================
    // Incomlend SupplierBuyerMap
    public Supplier_Buyer_Map__c SupplierBuyerMap
    {
        public get;
        private set;
    }

    // Invoice Allocations
    public List<Invoice_Allocation__c> InvoiceAllocations
    {
        public get;
        private set;
    }

    // Indicates if the process has encountered issues
    public boolean HasEncounteredIssues
    {
        get
        {
        return field_hasEncounteredIssues;
        }
        private set
        {
        if(field_hasEncounteredIssues || value)
            field_hasEncounteredIssues = true;
        }
    }
    // =======================================
    // Properties (data changes in Salesforce)
    // =======================================
    // Sales/Funding Commission to insert/update during proccess
    public List<Sales_Commission__c> SalesCommissions
    {
        public get;
        private set;
    }

    // ============
    // Constructors
    // ============
    public SalesCommissionService(Invoice_finance_deal__c invoice)
    {
        this.Logs = new Helper_Log();
        this.Invoice = invoice;

    }

    // ==============
    // Public Methods
    // ==============

    public static void updateMapCommission(List<Supplier_Buyer_Map__c> listMap) {
        if (!isNeedRunTrigger) return;

        for (Supplier_Buyer_Map__c supplierBuyerMap : listMap)
        {
            if (supplierBuyerMap.First_Invoice_Funded__c == null) continue;
            integer key = getKey(supplierBuyerMap);
            if (key != null) {
                supplierBuyerMap.Pct_Com_Owner__c = SalesCommissionUtils.PCT_COM_SALES_CONFIG.get(0);
                supplierBuyerMap.Pct_Com_Head_Sales__c = SalesCommissionUtils.PCT_COM_MANAGER_CONFIG.get(0);    
            }
        }
    }

    public static integer getKey(Supplier_Buyer_Map__c supplierBuyerMap) {
        if (supplierBuyerMap.Age_of_the_map__c == null) return null;
        double ageMapAfter = supplierBuyerMap.Age_of_the_map__c;
        if (ageMapAfter > 3 && !supplierBuyerMap.Account_transferred_to_Incomlend__c) {
            return 0;
        } else if (supplierBuyerMap.Account_transferred_to_Incomlend__c){
            return 0;
        } else {
            for (integer key : SalesCommissionUtils.PCT_COM_SALES_CONFIG.keySet()) {
                if (ageMapAfter == key) {
                    return key;
                }  
            }    
        }
        return null;
    }

    // This method create a sales commission
    // Returns true if the process has succeeded
    // Returns false if the process has encountered issues
    public boolean createSalesCommission()
    {
        if (!isNeedRunTrigger) return true;
        try
        {
            this.Logs.Log('Sales Commissions', 1, Helper_Log.Color.Black);

            // =======
            // Loading
            // =======
            LoadSupplierBuyerMap();
            LoadInvoiceAllocations();
            
            // Sale/Funding Commission initialize
            this.SalesCommissions = new List<Sales_Commission__c>();
            LoadSalesCommissions();

            if (this.SalesCommissions.size() == 0)
                createSalesOwnerCommission(false);

            if (this.SalesCommissions.size() <= 1)
                createFundingOwnerCommission(false);

        }
        catch(Exception unmanagedException)
        {
            this.Logs.Log(unmanagedException);
            this.HasEncounteredIssues = true;
        }
        finally
        {
            System.debug(this.Logs.PlainLog);
        }

        return (!this.HasEncounteredIssues);

    }

    private void createSalesOwnerCommission(Boolean createAtRepayment) 
    {
        this.Logs.Log('Creating sales owner commission', 2, Helper_Log.Color.Grey);

        // =========== 
        // Origination
        // ===========

        Sales_Commission__c salesOwnerCommission = new Sales_Commission__c();
        this.SalesCommissions.add(salesOwnerCommission);
        salesOwnerCommission.Type__c = 'Sales Owner';

        // Set Relationships
        salesOwnerCommission.Invoice_Finance_Deal__c = this.Invoice.Id;
        salesOwnerCommission.Funding_Sales_Owner_1__c = this.SupplierBuyerMap.Sales_Owner_1__c;
        salesOwnerCommission.Funding_Sales_Owner_2__c = this.SupplierBuyerMap.Sales_Owner_2__c;

        // Set Percentage
        salesOwnerCommission.pct_Com_Funding__c = SalesCommissionUtils.PCT_COM_FUNDING;
        integer key = getKey(this.SupplierBuyerMap);
        salesOwnerCommission.Pct_Com_Owner__c = SalesCommissionUtils.PCT_COM_SALES_CONFIG.get(0);
        salesOwnerCommission.Pct_Com_Head_Sales__c = SalesCommissionUtils.PCT_COM_MANAGER_CONFIG.get(0);    

        salesOwnerCommission.pct_Owner_1__c = SalesCommissionUtils.PCT_OWNER_1;
        salesOwnerCommission.Agent_Percentage_Portion__c = 100;
        if (this.SupplierBuyerMap.Value_of_agent_s_fee__c > 5) {
             salesOwnerCommission.Agent_Percentage_Portion__c = SalesCommissionUtils.HIGH_PCT_AGENT_PORTION_CONFIG;
        }
        for (integer key2 : SalesCommissionUtils.PCT_AGENT_PORTION_CONFIG.keySet()) {
            if (this.SupplierBuyerMap.Value_of_agent_s_fee__c == key2) {
                salesOwnerCommission.Agent_Percentage_Portion__c = SalesCommissionUtils.PCT_AGENT_PORTION_CONFIG.get(key2);
                break;
            }
        }

        // Set Dates
        salesOwnerCommission.Funding_Date__c = this.Invoice.advance_send_to_supplier_date__c;

        // DML
        insert salesOwnerCommission;

    }

    private void createFundingOwnerCommission(Boolean createAtRepayment) 
    {
        // ======= 
        // Funding
        // =======
        for(Invoice_Allocation__c currentAllocation : this.InvoiceAllocations)
        {

            // Funding Sales Owner
            List<String> excludeAccountNameList = new List<String>{
                'INCOMLEND CAPITAL PTE. LTD.',
                'Incomlend Pte Ltd',
                'SHELFORD S.C.A SICAV-RAIF - Sub-Fund INCOMLEND',
                'Fasanara Securitisation S.A. - Compartment W'};  
            if (currentAllocation.Funder__r.Sales_Owner__c != null && currentAllocation.Funder__r.Pay_Commission__c == true
                && !excludeAccountNameList.contains(currentAllocation.Funder__r.Name)) 
            {
                this.Logs.Log('Creating funding owner commission ' + currentAllocation.Name + ' ' + currentAllocation.Funder__r.Name, 1, Helper_Log.Color.Green);
                Sales_Commission__c currentCommission = new Sales_Commission__c();
                this.SalesCommissions.add(currentCommission);
                currentCommission.Type__c = 'Funding Owner';
    
                // Set Relationships
                currentCommission.Invoice_Finance_Deal__c = this.Invoice.Id;
                currentCommission.Invoice_Allocation__c = currentAllocation.Id;
                currentCommission.Funding_Sales_Owner_1__c = currentAllocation.Funder__r.Sales_Owner__c;
    
                // Set Percentage
                currentCommission.pct_Com_Funding__c = 0;
                currentCommission.pct_Com_Owner__c = 0;
                if (currentAllocation.Funder__r.Agent__c == null || currentAllocation.Funder__r.Agent__r.Name == 'Incomlend - agent' || currentAllocation.Funder_Agent_Commission_Amount__c == 0) {
                    currentCommission.pct_Com_Owner__c = getCommissionOwner(currentAllocation);
                } else {
                    currentCommission.pct_Com_Owner__c = SalesCommissionUtils.PCT_COM_FUNDER_CONFIG.get(0);
                }

                currentCommission.pct_Owner_1__c = 100;
                currentCommission.Agent_Percentage_Portion__c = 100;
    
                // Set Dates
                currentCommission.Funding_Date__c = this.Invoice.advance_send_to_supplier_date__c;
    
                // DML
                if (currentCommission.pct_Com_Owner__c != null && currentCommission.pct_Com_Owner__c > 0) {
                    insert currentCommission;
                }
            }

        }
    }

    // This method update a sales commission
    // Returns true if the process has succeeded
    // Returns false if the process has encountered issues
    public boolean updateSalesCommission()
    {
        if (!isNeedRunTrigger) return true;
        try
        {
            this.Logs.Log('Sales Commissions', 1, Helper_Log.Color.Black);

            
            // =======
            // Loading
            // =======
            LoadSupplierBuyerMap();
            LoadInvoiceAllocations();
            Map<Id, Invoice_Allocation__c> allocationMap = new Map<Id, Invoice_Allocation__c>(this.InvoiceAllocations);
            LoadSalesCommissions();
            
            //Creation of sales commission if not exist at repayment
            if (this.SalesCommissions.size() == 0) {
                createSalesOwnerCommission(true);
                LoadSalesCommissions();
            }
            if (this.SalesCommissions.size() <= 1) {
                createFundingOwnerCommission(true);
                LoadSalesCommissions();
            }

            // Set Dates
            for (Sales_Commission__c currentCommission : this.SalesCommissions) {
                if (currentCommission.Invoice_Allocation__c == null) {
                    this.Logs.Log('Updating sales owner commission ', 2, Helper_Log.Color.Grey);
                    currentCommission.Repayment_Sales_Owner_1__c = this.SupplierBuyerMap.Sales_Owner_1__c;
                    currentCommission.Repayment_Sales_Owner_2__c = this.SupplierBuyerMap.Sales_Owner_2__c;
                    currentCommission.Head_Sales__c = this.SupplierBuyerMap.Head_Sales__c;
                } else {
                    this.Logs.Log('Updating funding owner commission ' + currentCommission.Invoice_Allocation__c, 2, Helper_Log.Color.Grey);
                    currentCommission.Repayment_Sales_Owner_1__c = currentCommission.Invoice_Allocation__r.Funder__r.Sales_Owner__c;
                    Invoice_Allocation__c currentAllocation = allocationMap.get(currentCommission.Invoice_Allocation__c);
                    if (currentAllocation.Funder__r.Agent__c == null || currentAllocation.Funder__r.Agent__r.Name == 'Incomlend - agent' || currentAllocation.Funder_Agent_Commission_Amount__c == 0) {
                        currentCommission.pct_Com_Owner__c = getCommissionOwner(currentAllocation);
                    }
                }
                currentCommission.Repayment_Date__c = this.Invoice.Actual_Repayment_Received_Date__c;
                
                // DML
                update currentCommission;
            }

        }
        catch(Exception unmanagedException)
        {
            this.Logs.Log(unmanagedException);
            this.HasEncounteredIssues = true;
        }
        finally
        {
            System.debug(this.Logs.PlainLog);
        }
    
        return (!this.HasEncounteredIssues);

    }

    private decimal getCommissionOwner(Invoice_Allocation__c currentAllocation) {
        double ageFunderAfter = 0;
        Date today = this.Invoice.Actual_Repayment_Received_Date__c;
        Date firstSalesCommissionDate = currentAllocation.Funder__r.purchaser_first_date_sales_commission__c;
        if (firstSalesCommissionDate == null || today == null) {
            currentAllocation.Funder__r.purchaser_first_date_sales_commission__c = today;
            update currentAllocation.Funder__r;
            ageFunderAfter = 1;
        } else {
            ageFunderAfter = Math.Floor(firstSalesCommissionDate.daysBetween(today)/365) + 1;
            if (ageFunderAfter <= 0) ageFunderAfter = 1;
            if (ageFunderAfter > 3) {
                ageFunderAfter = 3;
            }
        }
        this.Logs.Log('Age ' + ageFunderAfter + ', ' + today + ' and ' + firstSalesCommissionDate, 2, Helper_Log.Color.Grey);
        for (integer key : SalesCommissionUtils.PCT_COM_FUNDER_CONFIG.keySet()) {

            // System.debug('ageFunderAfter: '+ageFunderAfter+'----key: '+key);
            if (ageFunderAfter == key) {
                return SalesCommissionUtils.PCT_COM_FUNDER_CONFIG.get(key);
            }
        }
        return null;
    }

    // ==============
    // Private Methods
    // ==============

    // This methods loads a supplier buyer map, based on its Id
    private void LoadSupplierBuyerMap()
    {
        this.Logs.Log('Loading Map"' + this.Invoice.Supplier_Buyer_Map__c + '"', 3, Helper_Log.Color.Grey);

        // Loads the account
        this.SupplierBuyerMap = LoadSupplierBuyerMap(this.Invoice.Supplier_Buyer_Map__c);

        // Validates the account
        if(this.SupplierBuyerMap == null) {
            throw new SalesCommissionService_Exception('Map (Id: "' + this.Invoice.Supplier_Buyer_Map__c + '") has not been found.');
        }
    }

    // This methods loads a supplier buyer map
    private Supplier_Buyer_Map__c LoadSupplierBuyerMap(Id supplierBuyerMapId)
    {
        Supplier_Buyer_Map__c result = new Supplier_Buyer_Map__c();

        try
        {
            // Loads the map
            if(supplierBuyerMapId != null)
                result = [  SELECT  Id,
                    Pct_Owner_1__c,
                    Pct_Owner_2__c,
                    pct_Com_Head_Sales__c,
                    Pct_Com_Owner__c,
                    Sales_Owner_1__c,
                    Sales_Owner_2__c,
                    Head_Sales__c,
                    Value_of_agent_s_fee__c,
                    Age_of_the_map__c,
                    First_Invoice_Funded__c,
                    Account_transferred_to_Incomlend__c
                FROM  Supplier_Buyer_Map__c
                WHERE (  Id = :SupplierBuyerMapId)];
        }
        catch(System.QueryException queryException)
        {
            if(queryException.getMessage() != 'List has no rows for assignment to SObject')
                throw queryException;
        }

        return result;
    }

    // This methods loads sales commissions, based on invoice Id
    private void LoadSalesCommissions()
    {
        this.Logs.Log('Loading Sales Commission for Invoice ID "' + this.Invoice.Id + '"', 3, Helper_Log.Color.Grey);

        // Loads the Sales Commission
        this.SalesCommissions = LoadSalesCommissions(this.Invoice.Id);

    }

    // This methods loads a supplier buyer map
    private List<Sales_Commission__c> LoadSalesCommissions(Id invoiceId)
    {
        List<Sales_Commission__c> result = new List<Sales_Commission__c>();

        // Loads the map
        if(invoiceId != null)
            result = [  SELECT  Id,
                      pct_Owner_1__c,
                      Invoice_Finance_Deal__c,
                      Invoice_Allocation__c,
                      Invoice_Allocation__r.Funder__r.Sales_Owner__c
            FROM  Sales_Commission__c
            WHERE (  Invoice_Finance_Deal__c = :invoiceId)];
        
        return result;
    }


    // This method loads and validates the invoice allocations to process
    private void LoadInvoiceAllocations()
    {
        this.Logs.Log('Loading Invoice Allocations for Invoice ID "' + this.Invoice.Id + '"', 3, Helper_Log.Color.Grey);
        
        this.InvoiceAllocations = LoadInvoiceAllocations(this.Invoice.Id);
        for(Invoice_Allocation__c currentAllocation : this.InvoiceAllocations)
        {
            this.Logs.Log('Invoice ' + currentAllocation.Name, 3, Helper_Log.Color.Grey);
        }

        // Validates the invoice allocations
        if(this.InvoiceAllocations.size() == 0)
            throw new SalesCommissionService_Exception('Invoice ID "' + this.Invoice.Id + '") has no allocations.');
    }

    // This method loads all allocations of an invoice
    private List<Invoice_Allocation__c> LoadInvoiceAllocations(id invoiceId)
    {
        List<Invoice_Allocation__c> result = new List<Invoice_Allocation__c>();

        // Loads the invoice allocations
        if(invoiceId != null) {
            result = [  SELECT  Id,
                amount__c,
                funder__c,
                Funder__r.Sales_Owner__c,
                Funder__r.Agent__c,
                Funder__r.Agent__r.Name,
                Funder__r.Name,
                Funder__r.purchaser_first_date_sales_commission__c,
                Funder__r.Pay_Commission__c,
                Funder_Agent_Commission_Amount__c,
                Name,
                Status__c
            FROM  Invoice_Allocation__c
            WHERE Invoice__c = :invoiceId
            AND   Status__c != 'Canceled'];
        }

        return result;
    }

    // ==============
    // Exception
    // ==============
    public class SalesCommissionService_Exception extends Exception {

    }

}