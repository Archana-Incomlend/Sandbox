// ==========================================================================================================
// InvoiceRepayment class
// ----------------------------------------------------------------------------------------------------------
// This class manages the new invoice repayment process (August 2020)
// and will, in time, replace Incomlend pricing v3 (September 2019)
//
// Author: John dela Rosa
// ==========================================================================================================
public class InvoiceRepayment {
  // =====
  // Constants
  // =====
  private static final String FEE_TYPE_INSR = 'Insurance';
  private static final String FEE_TYPE_MEMBERSHIP = 'Membership';
  private static final String STATUS_PAID = 'Paid';
  private static final String STATUS_PENDING = 'Pending';
  private static final String NET_EFDA = 'Net EFDA -15days';
  private static final Integer DAYS_PREPAYMENT = 15;

  // =====
  // Enums
  // =====
  private enum SearchType {
    ById,
    ByName
  }

  // ======
  // Fields
  // ======
  private boolean field_hasEncounteredIssues = false;

  // ==========
  // Properties
  // ==========
  // Logs
  public Helper_Log Logs {
    public get;
    private set;
  }

  // Email notification
  private IncomlendPricing_v3_Configuration.NotificationConfiguration Notification {
    get;
    set;
  }

  // Behaviour configuration
  private IncomlendPricing_v3_Configuration.BehaviourConfiguration Behaviour {
    get;
    set;
  }

  // Invoice Id (provided by the constructor)
  public Id InvoiceId {
    public get;
    private set;
  }

  // Effective Date of the transactions
  public date EffectiveDate {
    get;
    private set;
  }

  // Indicates if the process has encountered issues
  public boolean HasEncounteredIssues {
    get {
      return field_hasEncounteredIssues;
    }

    private set {
      if (!field_hasEncounteredIssues && value) {
        field_hasEncounteredIssues = true;
      }
    }
  }

  // ===========================
  // Properties (loaded objects)
  // ===========================
  // Accouting Period
  public Accounting_Period__c AccountingPeriod {
    public get;
    private set;
  }

  // Invoice to process
  public Invoice_finance_deal__c Invoice {
    public get;
    private set;
  }

  // Invoice Allocations
  public List<Invoice_Allocation__c> InvoiceAllocations {
    public get;
    private set;
  }

  // Invoice Repayment to process
  public Invoice_Repayment__c InvoiceRepayment {
    public get;
    private set;
  }

  // Allocations Repayment
  public List<Allocation_Repayment__c> AllocationRepayments {
    public get;
    private set;
  }

  // Invoice Transactions
  public List<Transaction__c> InvoiceTransactions {
    public get;
    private set;
  }

  // Tax Invoices
  public List<Tax_Rate__c> TaxRates {
    public get;
    private set;
  }

  // Incomlend Operations Account
  public Account IncomlendOperations {
    public get;
    private set;
  }

  // Incomlend Supplier Discount Account
  public Account IncomlendSupplierDiscount {
    public get;
    private set;
  }

  // Incomlend Fees Account
  public Account IncomlendFees {
    public get;
    private set;
  }

  // Incomlend GST Account
  public Account IncomlendGST {
    public get;
    private set;
  }

  // Supplier Account
  public Account Supplier {
    public get;
    private set;
  }

  // Buyer Account
  public Account Buyer {
    public get;
    private set;
  }

  // Insurer Account
  public Account Insurer {
    public get;
    private set;
  }

  // eWallet Trustee List
  public List<eWallet_Trustee__c> eWalletsTrustee {
    public get;
    private set;
  }

  // =======================================
  // Properties (data changes in Salesforce)
  // =======================================
  // Transactions to insert following the process
  private List<Transaction__c> TransactionsToInsert {
    get;
    set;
  }

  // Transactions of Incomlend Supplier Discount account
  private List<Transaction__c> TransactionsIncomlendSupplierDiscount {
    get;
    set;
  }

  // Transactions of Incomlend Operations account
  private List<Transaction__c> TransactionsIncomlendOperations {
    get;
    set;
  }

  // Allocations to update following the process
  private List<Invoice_Allocation__c> AllocationsToUpdate {
    get;
    set;
  }

  // Allocations and Allocations Repayment Map
  private  Map<Invoice_Allocation__c, Allocation_Repayment__c> AllocationsMap {
    get;
    set;
  }

  // Impacted eWallets following the process
  private Map<string, decimal> ImpactedeWallets {
    get;
    set;
  }

  // Impacted accounts following the process
  private List<Id> ImpactedAccountsIds {
    get;
    set;
  }

  // Simulation
  private Boolean isSimulation {
        private get;
        private set;
  }

  // Gross Funder Discount Amount from Apex Class Invoice Create Repayment Objects
  private Decimal grossFunderDiscountAmount {
        private get;
        private set;
  }

  // Remaining Repaid Amount from Apex Class Invoice Create Repayment Objects
  private Decimal remainingAmount {
        private get;
        private set;
  }

  // ===========
  // Logs tables
  // ===========
  // Table of transactions
  private List<List<string>> TransactionsTable {
    get;
    set;
  }

  // Table of eWallet movements
  private List<List<string>> eWalletMovementsTable {
    get;
    set;
  }

  // Table of negative eWallets
  private List<List<string>> NegativeeWalletsTable {
    get;
    set;
  }

  // ============
  // Constructors
  // ============

  public InvoiceRepayment(  invoice_finance_deal__c invoiceFinanceDeal,
                            Map<Invoice_Allocation__c, Allocation_Repayment__c> allocationsMap,
                            Invoice_Repayment__c invoiceRepayment,
                            Decimal grossFunderDiscountAmount,
                            Decimal remainingAmount,
                            boolean isSimulation,
                            IncomlendPricing_v3_Configuration.NotificationConfiguration notification,
                            IncomlendPricing_v3_Configuration.BehaviourConfiguration behaviour,
                            Helper_Log logs
                            ) {
    this.Logs = logs;
    this.EffectiveDate = date.today();

    this.Invoice = invoiceFinanceDeal;
    this.AllocationsMap = allocationsMap;
    this.InvoiceRepayment = invoiceRepayment; 

    // Gross Funder Discount Amount for current repayment (from InvoiceCreateRepaymentObjects Class)
    this.grossFunderDiscountAmount = grossFunderDiscountAmount;

    // Remaining amount after Funders payments with interests (from InvoiceCreateRepaymentObjects Class)
    this.remainingAmount = remainingAmount;

    this.isSimulation = isSimulation;

    if (!Test.isRunningTest()) {
            this.Notification = notification;
            this.Behaviour = behaviour;
        }

    this.TransactionsToInsert = new List<Transaction__c>();
    this.AllocationsToUpdate = new List<Invoice_Allocation__c>();
    this.TransactionsIncomlendSupplierDiscount = new List<Transaction__c>();
    this.TransactionsIncomlendOperations = new List<Transaction__c>();
    this.ImpactedeWallets = new Map<string, decimal>();
  }

  // This method closes the invoice
  // Returns true if the process has succeeded
  // Returns false if the process has encountered issues
  public boolean repayInvoice() {
    try {
      CoreInitialization();

      this.Logs.LogLine();
      this.Logs.Log('InvoiceRepayment() method called by ' + UserInfo.getName(), 1, Helper_Log.Color.Blue);
      this.Logs.LogLine();

      // =======
      // Loading
      // =======
      this.Logs.Log('Process Logs:', 1, Helper_Log.Color.Blue);
      this.Logs.Log('1. Loading core data', 1, Helper_Log.Color.Green);
      CoreLoading();

      this.Logs.Log('2. Loading Repayment data', 1, Helper_Log.Color.Green);

      this.Logs.Log('Loading Invoice:', 2, Helper_Log.Color.Black);
      this.Logs.Log(this.Invoice.Name, 2, Helper_Log.Color.Grey);

      this.Logs.Log('Loading Invoice Repayments:', 2, Helper_Log.Color.Black);
      this.Logs.Log(this.InvoiceRepayment.Name, 2, Helper_Log.Color.Grey);

      this.Logs.Log('Loading Allocations:', 2, Helper_Log.Color.Black);
      for (Invoice_Allocation__c currentAllocation: this.AllocationsMap.keySet()) {
        this.Logs.Log(currentAllocation.Name, 2, Helper_Log.Color.Grey);
      }

      this.Logs.Log('Loading Allocation Repayments:', 2, Helper_Log.Color.Black);
      for (Allocation_Repayment__c currentAllocationRepayment: this.AllocationsMap.values()) {
        this.Logs.Log(currentAllocationRepayment.Name, 2, Helper_Log.Color.Grey);
      }

      // ===============
      // Initialization
      // ===============

      // The payment is complete if the Invoice is fully repaid by Buyer
      Boolean isPaymentComplete = this.InvoiceRepayment.Repaid_Invoice_Ratio__c == 1;

      // Sum of all Profit Share 
      Decimal IclProfitShareAmountTotal = 0;

      // Tax amount part of sum of all Profit Share
      Decimal taxAmountIclProfitShareTotal = 0;

      // ==================
      // Overdue parameters 


      // Actual Overdue period (days)
      Integer actualOverdueDays = this.Invoice.Due_Date__c.daysBetween(this.InvoiceRepayment.Due_Date__c);

      Boolean isOverdue = false;

      // Overdue period (days) capped
      Integer overdueFinancingPeriod = 0;

      if (!Test.isRunningTest()) {
        overdueFinancingPeriod = !this.InvoiceRepayment.Capped_Funder_Discount__c ? actualOverdueDays : Math.min(this.Behaviour.CapOverduePayment, actualOverdueDays);
        isOverdue = actualOverdueDays > 0 && this.Behaviour.ApplyOverduePayment;
      } else {
        overdueFinancingPeriod = !this.InvoiceRepayment.Capped_Funder_Discount__c ? actualOverdueDays : Math.min(60, actualOverdueDays);
        isOverdue = actualOverdueDays > 0;
      }

      // ==================
      // Tax Rate for Supplier

      Tax_Rate__c TaxRateSupplier = null;
      decimal TaxRateSupplierPercentage = 0;
      for(Tax_Rate__c currentTaxRate : this.TaxRates)
      {
        if(currentTaxRate.Country__c == this.Invoice.Supplier_Country__c)
        {
          TaxRateSupplier = currentTaxRate;
          TaxRateSupplierPercentage = TaxRateSupplier.Rate__c;
          break;
        }
      }

      // ===============
      // Calculations Totals
      // ===============

      // Net Funder Discount Amount for each Funder
      Decimal currentNetFunderDiscountAmount = 0;

      // Profit Share Amount for each Funder
      Decimal currentIclProfitShare = 0;

      for (Invoice_Allocation__c currentAllocation : this.AllocationsMap.keySet()) {

        Allocation_Repayment__c currentAllocationRepayment = this.AllocationsMap.get(currentAllocation);

        // Retrieve Tax Rate for each Funder
        for (Tax_Rate__c currentTaxRate : this.TaxRates) {
          Tax_Rate__c TaxRateFunder = new Tax_Rate__c();

          if (currentTaxRate.Country__c == currentAllocation.Funder__r.Country_of_Incorporation__c) 
          {
            TaxRateFunder = currentTaxRate;
          } else {
            TaxRateFunder.Rate__c = 0;
          }

          currentIclProfitShare = (currentAllocationRepayment.Net_Discount_Amount__c * (currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c)/(100-currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c))
                                            .setScale(2, RoundingMode.HALF_UP);
          taxAmountIclProfitShareTotal += (currentIclProfitShare * TaxRateFunder.Rate__c / 100)
                                            .setScale(2, RoundingMode.HALF_UP);

        }

        // Cumulate the totals
        IclProfitShareAmountTotal += currentIclProfitShare;
      }

      this.Logs.Log('4. Repay the invoice', 1, Helper_Log.Color.Green);

      // --------------------
      // 1. Buyer Repayment
      // --------------------

      if (this.InvoiceRepayment.Repaid_Amount__c > 0) 
      {
        this.Logs.Log('"03.Invoice Repayment" transactions ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.InvoiceRepayment.Repaid_Amount__c), 2, Helper_Log.Color.Black);

        // Create the debit/credit transactions from Buyer's eWallet to Incomlend Operations' eWallet
        CreateTransaction(  this.Buyer.eWallets__r[0].Id,
                this.Buyer.eWallets__r[0].Name,
                this.Buyer.Id,
                this.Buyer.Name,
                this.Invoice.CCY__c,
                this.InvoiceRepayment.Repaid_Amount__c * -1,
                '03.Invoice Repayment');
        CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
                this.IncomlendOperations.eWallets__r[0].Name,
                this.IncomlendOperations.Id,
                this.IncomlendOperations.Name,
                this.Invoice.CCY__c,
                this.InvoiceRepayment.Repaid_Amount__c,
                '03.Invoice Repayment');
      } else 
        this.Logs.Log('("03.Invoice Repayment" transactions - No Invoice Repayment)', 2, Helper_Log.Color.Grey);

      // ----------------------------
      // 2. Funder Capital Repayment
      // ----------------------------

      for (Invoice_Allocation__c currentAllocation : this.AllocationsMap.keySet()) {

        Allocation_Repayment__c currentAllocationRepayment = this.AllocationsMap.get(currentAllocation);

        if (currentAllocationRepayment.Amount__c > 0) {
          this.Logs.Log('"04.Invoice Capital Repayment" transactions ' + this.Invoice.CCY__c + ' ' + FormatDecimal(currentAllocationRepayment.Amount__c), 2, Helper_Log.Color.Black);

          // Create the debit/credit transactions from Incomlend Operations' eWallet to Funder's eWallet
          CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
                  this.IncomlendOperations.eWallets__r[0].Name,
                  this.IncomlendOperations.Id,
                  this.IncomlendOperations.Name,
                  currentAllocation.CCY__c,
                  currentAllocationRepayment.Amount__c * -1,
                  '04.Invoice Capital Repayment');
          CreateTransaction(  currentAllocation.eWallet__c,
                  currentAllocation.eWallet__r.Name,
                  currentAllocation.Funder__c,
                  currentAllocation.Funder__r.Name,
                  currentAllocation.CCY__c,
                  currentAllocationRepayment.Amount__c,
                  '04.Invoice Capital Repayment');
        } else {
          this.Logs.Log('"04.Invoice Capital Repayment - No Invoice Capital Repayment for all parties', 3, Helper_Log.Color.Grey);
        }
      }

      // ---------------------------------------
      // 4. Net Funder Discount Amount by Funders
      // ---------------------------------------

      for (Invoice_Allocation__c currentAllocation : this.AllocationsMap.keySet()) {

        Allocation_Repayment__c currentAllocationRepayment = this.AllocationsMap.get(currentAllocation);

        if (currentAllocationRepayment.Net_Discount_Amount__c > 0) {
          this.Logs.Log('Allocation Repayment: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(currentAllocationRepayment.Net_Discount_Amount__c)+ ' for ' + currentAllocation.Funder__r.Name, 2, Helper_Log.Color.Black);

          // Create the debit/credit transactions from Incomlend Operation's eWallet to Funder's eWallet
          CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                  this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                  this.IncomlendSupplierDiscount.Id,
                  this.IncomlendSupplierDiscount.Name,
                  currentAllocation.CCY__c,
                  currentAllocationRepayment.Net_Discount_Amount__c * -1,
                  '05.Invoice Discount Amount');
          CreateTransaction(  currentAllocation.eWallet__c,
                  currentAllocation.eWallet__r.Name,
                  currentAllocation.Funder__c,
                  currentAllocation.Funder__r.Name,
                  currentAllocation.CCY__c,
                  currentAllocationRepayment.Net_Discount_Amount__c,
                  '05.Invoice Discount Amount');

          // Tax Invoice for funder net discount amount
          Tax_Rate__c TaxRateFunderNFDA = null;
          for(Tax_Rate__c currentTaxRate : this.TaxRates)
          {
            if(currentTaxRate.Country__c == currentAllocation.Funder__r.Country_of_Incorporation__c)
            {
              TaxRateFunderNFDA = new Tax_Rate__c();
              TaxRateFunderNFDA = currentTaxRate;
              break;
            }
          }

          if (TaxRateFunderNFDA != null && TaxRateFunderNFDA.Rate__c > 0 && currentAllocation.Funder__r.VAT_applicable__c) 
          {
            // ---------------------------------------
            // 5. Gross Funder Discount Amount GST
            // ---------------------------------------
            decimal TaxAmountFunderGrossDiscount = (currentAllocationRepayment.Net_Discount_Amount__c / (100 - currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c) * TaxRateFunderNFDA.Rate__c).setScale(2, RoundingMode.HALF_UP);

            this.Logs.Log('"09.GST transaction" - Gross funder discount GST: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountFunderGrossDiscount), 2, Helper_Log.Color.Black);

            // Create the debit/credit transactions from Incomlend GST's eWallet to Incomlend Supplier Discount's eWallet
            CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                    this.IncomlendGST.eWallets__r[0].Name,
                    this.IncomlendGST.Id,
                    this.IncomlendGST.Name,
                    this.Invoice.CCY__c,
                    TaxAmountFunderGrossDiscount * -1,
                    '09.GST transaction');
            CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                    this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                    this.IncomlendSupplierDiscount.Id,
                    this.IncomlendSupplierDiscount.Name,
                    this.Invoice.CCY__c,
                    TaxAmountFunderGrossDiscount,
                    '09.GST transaction');

            // ---------------------------------
            // 6. Net Funder Discount Amount GST
            // ---------------------------------
            
            decimal TaxAmountFunderNetDiscount = (currentAllocationRepayment.Net_Discount_Amount__c  * TaxRateFunderNFDA.Rate__c / 100).setScale(2, RoundingMode.HALF_UP);

            this.Logs.Log('"09.GST transaction" - Net funder discount GST: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(TaxAmountFunderNetDiscount), 2, Helper_Log.Color.Black);

            // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Funder's eWallet
            CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                    this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                    this.IncomlendSupplierDiscount.Id,
                    this.IncomlendSupplierDiscount.Name,
                    currentAllocation.CCY__c,
                    TaxAmountFunderNetDiscount * -1,
                    '09.GST transaction');
            CreateTransaction(  currentAllocation.eWallet__c,
                    currentAllocation.eWallet__r.Name,
                    currentAllocation.Funder__c,
                    currentAllocation.Funder__r.Name,
                    currentAllocation.CCY__c,
                    TaxAmountFunderNetDiscount,
                    '09.GST transaction');
          } 
          else 
            this.Logs.Log('"09.GST transaction" - Funder discount GST - No GST', 3, Helper_Log.Color.Grey);
        } else {
          this.Logs.Log('"05.Invoice Discount Amount - No Net funder discount', 3, Helper_Log.Color.Grey);
        }
      }

      // ------------------------
      // 10. Profit Share Total
      // ------------------------

      if (IclProfitShareAmountTotal > 0) {
        this.Logs.Log('"052.discount amount fees - Incomlend Profit Share Total: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(IclProfitShareAmountTotal), 2, Helper_Log.Color.Black);

        // Create the debit/credit transactions from Incomlend Supplier Discount' eWallet to Incomlend Fees' eWallet
        CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                this.IncomlendSupplierDiscount.Id,
                this.IncomlendSupplierDiscount.Name,
                this.Invoice.CCY__c,
                IclProfitShareAmountTotal * -1,
                '052.discount amount fees');
        CreateTransaction(  this.IncomlendFees.eWallets__r[0].Id,
                this.IncomlendFees.eWallets__r[0].Name,
                this.IncomlendFees.Id,
                this.IncomlendFees.Name,
                this.Invoice.CCY__c,
                IclProfitShareAmountTotal,
                '052.discount amount fees');    
      }
      else 
        this.Logs.Log('"052.discount amount fees" - No Incomlend Profit Share Total', 3, Helper_Log.Color.Grey);

      // ------------------------
      // 11. Profit Share Total GST
      // ------------------------
      
      if (taxAmountIclProfitShareTotal > 0) {
        this.Logs.Log('"09.GST transaction - Incomlend Profit Share Total GST: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(taxAmountIclProfitShareTotal), 2, Helper_Log.Color.Black);

        // Create the debit/credit transactions from Incomlend Supplier Discount' eWallet to Incomlend GST's eWallet
            CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                    this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                    this.IncomlendSupplierDiscount.Id,
                    this.IncomlendSupplierDiscount.Name,
                    this.Invoice.CCY__c,
                    taxAmountIclProfitShareTotal * -1,
                    '09.GST transaction');
            CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                    this.IncomlendGST.eWallets__r[0].Name,
                    this.IncomlendGST.Id,
                    this.IncomlendGST.Name,
                    this.Invoice.CCY__c,
                    taxAmountIclProfitShareTotal,
                    '09.GST transaction');
      }
      else 
        this.Logs.Log('"09.GST transaction" - No Incomlend Profit Share Total GST', 3, Helper_Log.Color.Grey);

      // Create Tax invoice funder profit share - even if tax rate is null
      for (Invoice_Allocation__c currentAllocation : this.AllocationsMap.keySet()) {

        Allocation_Repayment__c currentAllocationRepayment = this.AllocationsMap.get(currentAllocation);

        // Tax Invoice for Funder profit sharing
        decimal TaxRateFunderPercentage = 0;
        for(Tax_Rate__c currentTaxRate : this.TaxRates)
        {
          Tax_Rate__c TaxRateFunder = new Tax_Rate__c();

          if(currentTaxRate.Country__c == currentAllocation.Funder__r.Country_of_Incorporation__c)
          {
            TaxRateFunder = currentTaxRate;
            TaxRateFunderPercentage = TaxRateFunder.Rate__c;
            break;
          }
        }
        
        currentIclProfitShare = (currentAllocationRepayment.Net_Discount_Amount__c * (currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c)/(100-currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c))
                                          .setScale(2, RoundingMode.HALF_UP);

        if (currentIclProfitShare > 0) {
          Map<InvoiceUtil.Description, Decimal> amountExclGSTMap = new Map<InvoiceUtil.Description, Decimal>();
          amountExclGSTMap.put(InvoiceUtil.Description.FUNDER_PROFIT_SHARE, currentIclProfitShare);

          // Amounts that are not subjected to tax
          Map<InvoiceUtil.Description, Decimal> amountNoTaxMap = new Map<InvoiceUtil.Description, Decimal>();

          CreateInvoice_v1 TaxInvoiceFunderSharing =
                  new CreateInvoice_v1(    currentAllocation.Funder__c,
                          this.Invoice,
                          currentAllocation,
                          amountExclGSTMap,
                          TaxRateFunderPercentage,
                          amountNoTaxMap,
                          InvoiceUtil.RecordType.FUNDER,
                          InvoiceUtil.ActionType.Repaid,
                          false,
                          this.Notification,
                          this.isSimulation);

          TaxInvoiceFunderSharing.createInvoice();
        }
      }
        
      // ------------------------
      // 17. Supplier Discount Amount Overdue
      // ------------------------

      if (isOverdue && this.InvoiceRepayment.Supplier_Discount_Amount__c > 0) {

        this.Logs.Log('"062.Transaction Fees overdue" - Overdue Supplier Discount Amount transaction ' + this.Invoice.CCY__c + ' ' + this.InvoiceRepayment.Supplier_Discount_Amount__c, 2, Helper_Log.Color.Black);

        // Create the debit/credit transactions from Incomlend Operations' eWallet to Incomlend Supplier Discount's eWallet
        // Amount overdue = Overdue Supplier Discount Amount
        CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
                this.IncomlendOperations.eWallets__r[0].Name,
                this.IncomlendOperations.Id,
                this.IncomlendOperations.Name,
                this.Invoice.CCY__c,
                this.InvoiceRepayment.Supplier_Discount_Amount__c * -1,
                '062.Transaction Fees overdue');
        CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                this.IncomlendSupplierDiscount.Id,
                this.IncomlendSupplierDiscount.Name,
                this.Invoice.CCY__c,
                this.InvoiceRepayment.Supplier_Discount_Amount__c,
                '062.Transaction Fees overdue');

        // ------------------------
        // 18. Supplier Discount Amount Overdue GST
        // ------------------------

        // Tax Rate for Supplier Discount Amount for overdue
        if (TaxRateSupplier != null && TaxRateSupplierPercentage > 0) 
        {
          Decimal TaxAmountSupplierOverdue = (this.InvoiceRepayment.Supplier_Discount_Amount__c 
                                              * TaxRateSupplierPercentage / 100)
                                              .setScale(2, RoundingMode.HALF_UP);

          this.Logs.Log('"09.GST transaction" - Supplier Overdue GST: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountSupplierOverdue), 2, Helper_Log.Color.Black);

          // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Supplier's eWallet
          CreateTransaction(  this.Supplier.eWallets__r[0].Id,
                  this.Supplier.eWallets__r[0].Name,
                  this.Supplier.Id,
                  this.Supplier.Name,
                  this.Invoice.CCY__c,
                  TaxAmountSupplierOverdue * -1,
                  '09.GST transaction');
          CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                  this.IncomlendGST.eWallets__r[0].Name,
                  this.IncomlendGST.Id,
                  this.IncomlendGST.Name,
                  this.Invoice.CCY__c,
                  TaxAmountSupplierOverdue,
                  '09.GST transaction');
        }

        // Create Tax invoice supplier discount amount overdue - even if tax rate is null
        // Supplier discount amount + insurance amount List
        Map<InvoiceUtil.Description, Decimal> amountExclGSTMap = new Map<InvoiceUtil.Description, Decimal>();
        amountExclGSTMap.put(InvoiceUtil.Description.SUPPLIER_DISCOUNT_AMOUNT_OVERDUE, this.InvoiceRepayment.Supplier_Discount_Amount__c);

        // Amounts that are not subjected to tax
        Map<InvoiceUtil.Description, Decimal> amountNoTaxMap = new Map<InvoiceUtil.Description, Decimal>();

        CreateInvoice_v1 TaxInvoiceSupplierDiscount =
                new CreateInvoice_v1 (this.Supplier.Id,
                        this.Invoice,
                        null,
                        amountExclGSTMap,
                        TaxRateSupplierPercentage,
                        amountNoTaxMap,
                        InvoiceUtil.RecordType.SUPPLIER,
                        InvoiceUtil.ActionType.Repaid,
                        false,
                        this.Notification,
                        this.isSimulation);

        TaxInvoiceSupplierDiscount.createInvoice();

      } else {
        this.Logs.Log('("062.Transaction Fees overdue - No Overdue or No supplier discount amount remaining)', 2, Helper_Log.Color.Grey);
      }

      // ------------------
      // 19. Transaction Fees Overdue
      // ------------------

      Decimal netITF = this.InvoiceRepayment.Supplier_Discount_Amount__c - this.grossFunderDiscountAmount;
      if (netITF > 0)
      {

      this.Logs.Log('"062.Transaction Fees overdue " Transaction fees Overdue: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(netITF), 2, Helper_Log.Color.Black);

      // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend Fees' eWallet
      CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
              this.IncomlendSupplierDiscount.eWallets__r[0].Name,
              this.IncomlendSupplierDiscount.Id,
              this.IncomlendSupplierDiscount.Name,
              this.Invoice.CCY__c,
              netITF * -1,
              '062.Transaction Fees overdue');
      CreateTransaction(  this.IncomlendFees.eWallets__r[0].Id,
              this.IncomlendFees.eWallets__r[0].Name,
              this.IncomlendFees.Id,
              this.IncomlendFees.Name,
              this.Invoice.CCY__c,
              netITF,
              '062.Transaction Fees overdue');

      } else {
        netITF = 0;
        this.Logs.Log('("062.Transaction Fees overdue - No Overdue or No transactions fees amount remaining)', 2, Helper_Log.Color.Grey);
      }

      // --------------------------
      // 20. Invoice Balance Payment
      // --------------------------

      Decimal supplierBalance = (this.remainingAmount - netITF).setScale(2, RoundingMode.HALF_UP);

      if(supplierBalance > 0)
      {
        this.Logs.Log('"08.Invoice Balance Payment" - Remaining Balance ' + this.Invoice.CCY__c + ' ' + FormatDecimal(supplierBalance), 2, Helper_Log.Color.Black);

        // Create the debit/credit transactions from Incomlend Operations' eWallet to Supplier's eWallet
        CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
                this.IncomlendOperations.eWallets__r[0].Name,
                this.IncomlendOperations.Id,
                this.IncomlendOperations.Name,
                this.Invoice.CCY__c,
                supplierBalance * -1,
                '08.Invoice Balance Payment');
        CreateTransaction(  this.Supplier.eWallets__r[0].Id,
                this.Supplier.eWallets__r[0].Name,
                this.Supplier.Id,
                this.Supplier.Name,
                this.Invoice.CCY__c,
                supplierBalance,
                '08.Invoice Balance Payment');
      }
      else
              this.Logs.Log('("08.Invoice Balance Payment - No Remaining Balance)', 2, Helper_Log.Color.Grey);
      

      // ===========
      // LOGS
      // ===========

      // Logs the transactions
      this.Logs.LogLine();
      this.Logs.Log('Created transactions:', 1, Helper_Log.Color.Blue);
      this.Logs.Log(this.TransactionsTable);
      this.Logs.LogLine();

      // Logs the eWallet movements
      this.Logs.Log('eWallet movements:', 1, Helper_Log.Color.Blue);
      this.Logs.Log(this.eWalletMovementsTable);
      this.Logs.LogLine();

      // Validates that no eWallet is negative
      boolean hasNegativeeWallets = false;
      for (string currenteWallet : this.ImpactedeWallets.keySet()) {
        decimal balance = this.ImpactedeWallets.get(currenteWallet);
        if (balance < 0) {
          this.NegativeeWalletsTable.add(new List<string> {currenteWallet, FormatDecimal(balance)});
          hasNegativeeWallets = true;
        }
      }

      if (hasNegativeeWallets && this.Invoice.Overdue_Transaction_fees_Net__c == 0) {
        // Logs the negative eWallets
        this.Logs.Log('Negative eWallets:', 1, Helper_Log.Color.Blue);
        this.Logs.Log(this.NegativeeWalletsTable);
        this.Logs.LogLine();

        if (!Test.isRunningTest() && this.Behaviour.FailAtNegativeeWallets) {
          throw new IncomlendPricing_v3_Exception('Process aborted because one or more eWallets are about to be negative.');
        } else {
          this.Logs.Log('One or more eWallets are about to be negative.', 1, Helper_Log.Color.Red);
          this.HasEncounteredIssues = true;
        }
      }

      // Validates that Incomlend Internal Accounts (Supplier Discount and Operations) are null
      if (isPaymentComplete) {
        boolean isNotNullIncomlendSupplierDiscount = false;
        decimal IncomlendSupplierDiscountBalance = 0;

        boolean isNotNullIncomlendOperations = false;
        decimal IncomlendOperationsBalance = 0;

        // Collect all transactions for this invoice
        this.TransactionsIncomlendSupplierDiscount.addAll(LoadInvoiceTransactions(this.Invoice.id, this.IncomlendSupplierDiscount.Id));
        this.TransactionsIncomlendOperations.addAll(LoadInvoiceTransactions(this.Invoice.id, this.IncomlendOperations.Id));
        for (Transaction__c currentTransaction : this.TransactionsToInsert) {
          if (currentTransaction.Account__c == this.IncomlendSupplierDiscount.Id) {
            this.TransactionsIncomlendSupplierDiscount.add(currentTransaction);
          }

          if (currentTransaction.Account__c == this.IncomlendOperations.Id) {
            this.TransactionsIncomlendOperations.add(currentTransaction);
          }
        }

        // Check the Balance Incomlend Supplier Discount
        for (Transaction__c currentTransaction : this.TransactionsIncomlendSupplierDiscount) {
          IncomlendSupplierDiscountBalance = IncomlendSupplierDiscountBalance + currentTransaction.Amount__c;
        }
        // Marging accepted
        if (IncomlendSupplierDiscountBalance >= 1 || IncomlendSupplierDiscountBalance <= -1) {
          isNotNullIncomlendSupplierDiscount = true;
        }

        if (isNotNullIncomlendSupplierDiscount) {
          // Logs the incorrect balance
          this.Logs.Log('Incomlend Supplier Discount Balance: ' + IncomlendSupplierDiscountBalance + ' ' + this.Invoice.CCY__c, 1, Helper_Log.Color.Red);
          this.Logs.LogLine();

          if (!Test.isRunningTest() && this.Behaviour.FailAtIncomlendBalance) {
            throw new IncomlendPricing_v3_Exception('Process aborted because Incomlend Supplier Discount Balance is not null.');
          } else {
            this.Logs.Log('Incomlend Supplier Discount Balance is not null.', 1, Helper_Log.Color.Red);
          }
        }

        // Check the Balance Incomlend Operations
        for (Transaction__c currentTransaction : this.TransactionsIncomlendOperations) {
          IncomlendOperationsBalance = IncomlendOperationsBalance + currentTransaction.Amount__c;
        }
        // Marging accepted
        if (IncomlendOperationsBalance >= 1 || IncomlendOperationsBalance <= -1)  {
          isNotNullIncomlendOperations = true;
        }

        if (isNotNullIncomlendOperations) {
          // Logs the incorrect balance
          this.Logs.Log('Incomlend Operations Balance: ' + IncomlendOperationsBalance + ' ' + this.Invoice.CCY__c, 1, Helper_Log.Color.Red);
          this.Logs.LogLine();

          if (!Test.isRunningTest() && this.Behaviour.FailAtIncomlendBalance) {
            throw new IncomlendPricing_v3_Exception('Process aborted because Incomlend Operations Balance is not null');
          } else {
            this.Logs.Log('Incomlend Operations Balance is not null.', 1, Helper_Log.Color.Red);
          }
        }
      }

      // ===========
      // DML Updates
      // ===========
      if (!this.isSimulation) {
        // Update Invoice
        this.Invoice.Repaid_Amount__c += this.InvoiceRepayment.Repaid_Amount__c;
        this.Invoice.Repaid_Funded_Amount__c += this.InvoiceRepayment.Funder_Amount__c;
        if (supplierBalance > 0) {
          this.Invoice.Repaid_Supplier_Balance_Amount__c += supplierBalance;
        }

        this.Invoice.Repaid_Supplier_Discount_Amount__c += this.InvoiceRepayment.Supplier_Discount_Amount__c;
        this.Invoice.Overdue_Transaction_fees_Net__c += Math.min(this.InvoiceRepayment.Repaid_Amount__c, this.InvoiceRepayment.Remaining_Invoice_Amount__c) * actualOverdueDays * this.Invoice.Overdue_Supplier_discount_rate__c/100/30 
                                                        - this.InvoiceRepayment.Supplier_Discount_Amount__c;
        
        if (isPaymentComplete) {
          this.Invoice.Phase__c = '4:CLOSED';
          this.Invoice.Status__c = 'Paid';

          SalesCommissionService salesCommissionService = new SalesCommissionService(this.Invoice);
          if(!salesCommissionService.updateSalesCommission()) {
            this.Logs.Log('Pricing failed to update Sales Commission.', 1, Helper_Log.Color.Red);
            this.HasEncounteredIssues = true;
      }
        }
        update this.Invoice;
        
        // Updates the existing allocations
        // Update the current allocation
          for (Invoice_Allocation__c currentAllocation: this.AllocationsMap.keySet()) {
            Allocation_Repayment__c currentAllocationRepayment = this.AllocationsMap.get(currentAllocation);
            currentAllocation.Repaid_Amount__c += currentAllocationRepayment.Amount__c;
            currentAllocation.Repaid_Discount_Amount__c += currentAllocationRepayment.Net_Discount_Amount__c;
            // Close the allocation if the funder is fully repaid
            if (currentAllocation.Repaid_Amount__c == currentAllocation.amount__c) {
            currentAllocation.Status__c = 'Repaid invoice deal closed';
            }
            this.AllocationsToUpdate.add(currentAllocation);
        }
        update this.AllocationsToUpdate;

        // Creates the new transactions
        insert this.TransactionsToInsert;

        // Updates the new transactions to link them together (Related_Transaction__c field)
        Integer transactionsCount = this.TransactionsToInsert.size();
        if (math.mod(transactionsCount, 2) == 0) {
          for (Integer i = 0; i < transactionsCount / 2 ;i++) {
            this.TransactionsToInsert[2 * i].Related_Transaction__c = this.TransactionsToInsert[ 2 * i + 1].Id;
            this.TransactionsToInsert[2 * i + 1].Related_Transaction__c = this.TransactionsToInsert[2 * i].Id;
          }
          update this.TransactionsToInsert;
        } else {
          if (!Test.isRunningTest() && this.Behaviour.FailAtRelatedTransactions) {
            throw new IncomlendPricing_v3_Exception('Number of created transactions is odd, which is not supposed to happen.');
          } else {
            this.Logs.Log('Number of created transactions is odd, which is not supposed to happen.', 1, Helper_Log.Color.Red);
            this.HasEncounteredIssues = true;
          }
        }

        // Update Invoice Repayment
        this.InvoiceRepayment.Status__c = 'Paid';
        update this.InvoiceRepayment;

        // Update Allocations Repayment
        for (Allocation_Repayment__c currentAllocationRepayment : this.AllocationsMap.values()) {
          currentAllocationRepayment.Status__c = 'Paid';

        }
        update this.AllocationsMap.values();
      }

      this.HasEncounteredIssues = false;
    } catch(Exception unmanagedException) {
      this.Logs.Log(unmanagedException);
      this.HasEncounteredIssues = true;
    } finally {
      // Sends alerts
      if (!Test.isRunningTest()) {
        if (this.HasEncounteredIssues || !this.Notification.AlertsOnErrorOnly) {
          Helper_Email.Send(this.Notification.IsHTML, this.Notification.AlertsRecipients, this.Notification.AlertsSubject, this.Logs.HTMLLog);
        }

        // Sends logs
        if (this.HasEncounteredIssues || !this.Notification.LogsOnErrorOnly) {
          Helper_Email.Send(this.Notification.IsHTML, this.Notification.LogsRecipients, this.Notification.LogsSubject, this.Logs.HTMLLog);
        }
      }

      system.debug(this.Logs.PlainLog);
    }

    return !this.HasEncounteredIssues;
  }

  // ===============
  // Private Methods
  // ===============
  // This method initializes a funding or a closing process
  private void CoreInitialization()
  {
    if (this.Logs == null) {
      this.Logs = new Helper_Log();
    }

    this.HasEncounteredIssues = false;
    this.TransactionsToInsert = new List<Transaction__c>();
    this.AllocationsToUpdate = new List<Invoice_Allocation__c>();
    this.TransactionsIncomlendSupplierDiscount = new List<Transaction__c>();
    this.TransactionsIncomlendOperations = new List<Transaction__c>();
    this.ImpactedeWallets = new Map<string, decimal>();
    this.ImpactedAccountsIds = new List<Id>();
    this.eWalletsTrustee = new List<eWallet_Trustee__c>();
    this.TransactionsTable = new List<List<string>>();
    this.TransactionsTable.add(new List<string> {'eWallet', 'Account', 'Type', 'CCY', 'Amount', 'Effective Date', 'Allocation', 'Invoice', 'Status'});
    this.eWalletMovementsTable = new List<List<string>>();
    this.eWalletMovementsTable.add(new List<string> {'eWallet and Account', 'Old Balance', 'Movement', 'New Balance'});
    this.NegativeeWalletsTable = new List<List<string>>();
    this.NegativeeWalletsTable.add(new List<string> {'eWallet', 'Balance'});
  }

  // This method loads the necessary objects to both funding and closing processes
  private void CoreLoading()
  {
    // Various objects
    LoadAccountingPeriod();
    LoadInvoiceTransactions();
    LoadTaxRates();

    this.Logs.Log('Loading accounts:', 2, Helper_Log.Color.Black);

    this.IncomlendOperations = LoadAccount((string)'Incomlend Operations');
    this.IncomlendSupplierDiscount = LoadAccount((string)'Incomlend - Supplier Discount');
    this.IncomlendGST = LoadAccount((string)'Incomlend GST');
    this.IncomlendFees = LoadAccount((string)'Incomlend - fees');
    this.Supplier = LoadAccount((Id)this.Invoice.Supplier_Buyer_Map__r.Supplier__c);
    this.Buyer = LoadAccount((ID)this.Invoice.Supplier_Buyer_Map__r.Buyer__c);

    // Put all accounts Id in a list
    this.ImpactedAccountsIds.add(this.IncomlendOperations.Id);
    this.ImpactedAccountsIds.add(this.IncomlendSupplierDiscount.Id);
    this.ImpactedAccountsIds.add(this.IncomlendGST.Id);
    this.ImpactedAccountsIds.add(this.IncomlendFees.Id);
    this.ImpactedAccountsIds.add(this.Supplier.Id);
    this.ImpactedAccountsIds.add(this.Buyer.Id);
    for (Invoice_Allocation__c currentAllocation: this.AllocationsMap.keySet()) {
      this.ImpactedAccountsIds.add(currentAllocation.Funder__c);
    }
    LoadeWalletsTrustee();
  }

  // This method loads and validates the accounting period
  private void LoadAccountingPeriod()
  {
    this.Logs.Log('Loading accounting period: ' + string.valueOf(this.EffectiveDate), 2, Helper_Log.Color.Black);

    this.AccountingPeriod = LoadAccountingPeriod(this.EffectiveDate);

    // Validates the accounting period
    if(this.AccountingPeriod == null)
      throw new IncomlendPricing_v3_Exception('Accounting Period (Date: "' + string.valueOf(this.EffectiveDate) + '") has not been found.');
    else if (this.AccountingPeriod.Name == null || this.AccountingPeriod.Name.Length() == 0)
      throw new IncomlendPricing_v3_Exception('Accounting Period (Date: "' + string.valueOf(this.EffectiveDate) + '") has no Name.');
    else
            this.Logs.Log(this.AccountingPeriod.Name, 3, Helper_Log.Color.Grey);
  }

  // This method loads an accounting period
  private Accounting_Period__c LoadAccountingPeriod(date effectiveDate)
  {
    Id accountingPeriodId;

    // Loads the accounting period
    try
    {
      accountingPeriodId = Accounting_Period.lookup(effectiveDate);
    }
    catch(Exception unmanagedException)
    {
      throw new IncomlendPricing_v3_Exception('Accounting Period (Date: "' + string.valueOf(effectiveDate) + '") has not been found.');
    }

    Accounting_Period__c result = null;
    try
    {
      if(accountingPeriodId != null)
        result = [  SELECT  Id,
                Name
        FROM  Accounting_Period__c
        WHERE  Id = :accountingPeriodId];
    }
    catch(System.QueryException queryException)
    {
      if(queryException.getMessage() != 'List has no rows for assignment to SObject')
        throw queryException;
    }

    return result;
  }

  // This method loads and validates the tax invoice to process
  private void LoadTaxRates()
  {

    this.TaxRates = LoadTaxRatesRequest();

    // Validates the invoice allocations
    if(this.TaxRates == null || this.TaxRates.size() == 0)
      this.Logs.Log('(No existing tax rates)', 3, Helper_Log.Color.Grey);
    else
    {
      for(Tax_Rate__c currentTaxRate : this.TaxRates)
      {
        if (currentTaxRate.Country__c == null)
          throw new IncomlendPricing_v3_Exception('Tax Rate (Id: "' + currentTaxRate.Id + '") has no Country.');
        else if(currentTaxRate.Rate__c == null)
          throw new IncomlendPricing_v3_Exception('Tax Rate (Id: "' + currentTaxRate.Id + '") has no Rate.');
      }
    }
  }

  // This method loads all tax invoices of an invoice
  private List<Tax_Rate__c> LoadTaxRatesRequest()
  {
    List<Tax_Rate__c> result = new List<Tax_Rate__c>();

    try
    {
      // Loads the tax invoices
      result = [  SELECT  Id,
              Country__c,
              Rate__c
      FROM  Tax_Rate__c];
    }
    catch(System.QueryException queryException)
    {
      if(queryException.getMessage() != 'List has no rows for assignment to SObject')
        throw queryException;
    }

    return result;
  }
  // This method loads and validates the invoice transactions to process
  private void LoadInvoiceTransactions()
  {
    this.Logs.Log('Loading invoice transactions:', 2, Helper_Log.Color.Black);

    this.InvoiceTransactions = LoadInvoiceTransactions(this.InvoiceId);

    if(this.InvoiceTransactions != null && this.InvoiceTransactions.size() > 0)
    {
      for(Transaction__c currentTransaction : this.InvoiceTransactions)
        this.Logs.Log(currentTransaction.Name, 3, Helper_Log.Color.Grey);
    }
    else
            this.Logs.Log('(No existing transactions)', 3, Helper_Log.Color.Grey);
  }

  // This method loads all transactions of an invoice
  private List<Transaction__c> LoadInvoiceTransactions(id invoiceId)
  {
    List<Transaction__c> result = new List<Transaction__c>();

    try
    {
      // Loads the invoice transactions
      if(invoiceId != null)
        result = [  SELECT  Id,
                Name,
                Status__c,
                Type__c
        FROM  Transaction__c
        WHERE  Invoice_Finance_Deal__c = :invoiceId
        AND    Status__c != 'Cancelled'];
    }
    catch(System.QueryException queryException)
    {
      if(queryException.getMessage() != 'List has no rows for assignment to SObject')
        throw queryException;
    }

    return result;
  }

  // This method loads all transactions of an invoice, filter by account Id
  private List<Transaction__c> LoadInvoiceTransactions(id invoiceId, id accountId)
  {
    List<Transaction__c> result = new List<Transaction__c>();

    try
    {
      // Loads the invoice transactions
      if(invoiceId != null)
        result = [  SELECT  Id,
                Account__c,
                Amount__c,
                Name,
                Status__c,
                Type__c
        FROM  Transaction__c
        WHERE  Invoice_Finance_Deal__c = :invoiceId
        AND 	 Account__c = :accountId
        AND    Status__c != 'Cancelled'];
    }
    catch(System.QueryException queryException)
    {
      if(queryException.getMessage() != 'List has no rows for assignment to SObject')
        throw queryException;
    }

    return result;
  }

  // This methods loads an account, based on its Name
  private Account LoadAccount(string accountName)
  {
    this.Logs.Log('Loading "' + accountName + '"', 3, Helper_Log.Color.Grey);

    // Loads the account
    Account account = LoadAccount(accountName, SearchType.ByName);

    // Validates the account
    if(account == null)
      throw new IncomlendPricing_v3_Exception('Account (Name: "' + accountName + '") has not been found.');
    if (account.Name == null || account.Name.Length() == 0)
      throw new IncomlendPricing_v3_Exception('Account (Id: "' + account.Id + '") has no Name.');
    else if(account.eWallets__r != null && account.eWallets__r.size() != 1)
      throw new IncomlendPricing_v3_Exception('Account (Name: "' + account.Name + '") has no "' + this.Invoice.CCY__c + '" eWallet.');
    else
    {
      updateeWalletBalance(account.eWallets__r[0].Name + ' - ' + account.eWallets__r[0].Account__r.Name, account.eWallets__r[0].Balance__c);
      return account;
    }
  }

  // This methods loads an account, based on its Id
  private Account LoadAccount(Id accountId)
  {
    this.Logs.Log('Loading "' + accountId + '"', 3, Helper_Log.Color.Grey);

    // Loads the account
    Account account = LoadAccount(accountId, SearchType.ById);

    // Validates the account
    if(account == null)
      throw new IncomlendPricing_v3_Exception('Account (Id: "' + accountId + '") has not been found.');
    if (account.Name == null || account.Name.Length() == 0)
      throw new IncomlendPricing_v3_Exception('Account (Id: "' + account.Id + '") has no Name.');
    else if(account.eWallets__r != null && account.eWallets__r.size() != 1)
      throw new IncomlendPricing_v3_Exception('Account (Name: "' + account.Name + '") has no "' + this.Invoice.CCY__c + '"" eWallet.');
    else
    {
      updateeWalletBalance(account.eWallets__r[0].Name + ' - ' + account.eWallets__r[0].Account__r.Name, account.eWallets__r[0].Balance__c);
      this.Logs.Log('Account name: ' + account.Name, 4, Helper_Log.Color.Grey);
      return account;
    }
  }

  // This methods loads an account
  private Account LoadAccount(object key, SearchType type)
  {
    Account result = null;
    id accountId = null;
    if(type == SearchType.ById)
      accountId = id.valueOf(string.valueOf(key));
    string accountName = null;
    if(type == SearchType.ByName)
      accountName = string.valueOf(key);

    try
    {
      // Loads the account
      if(key != null && type != null)
        result = [  SELECT  Id,
                Agent__c,
                Country_of_Incorporation__c,
                Insured_Loss_USD_Equiv__c,
                Name,
                Un_utilised_adv_amt_all_phases_usd_equiv__c,
                VAT_applicable__c,
        (  SELECT  Id,
                Name,
                CCY__C,
                Balance__c,
                Account__r.Name
        FROM  eWallets__r
        WHERE  CCY__C = :this.Invoice.CCY__c)
        FROM  Account
        WHERE (  Id = :accountId)
        OR (  Name = :accountName)];
    }
    catch(System.QueryException queryException)
    {
      if(queryException.getMessage() != 'List has no rows for assignment to SObject')
        throw queryException;
    }

    return result;
  }

  // This method loads and validates the eWallet Trustee to process
  private void LoadeWalletsTrustee()
  {
    // Load the eWallets trustee List
    this.eWalletsTrustee = LoadeWalletsTrustee(this.ImpactedAccountsIds, this.Invoice);

    // Validates the account Ids list and the invoice
    if(this.Invoice == null)
      throw new IncomlendPricing_v3_Exception('Invoice (Id: "' + this.Invoice.Id + '") has not been found.');
    if (this.Invoice.CCY__C == null)
      throw new IncomlendPricing_v3_Exception('Invoice (Id: "' + account.Id + '") has no currency.');
    else if(this.Invoice.Trustee__C == null)
      throw new IncomlendPricing_v3_Exception('Invoice (Id: "' + account.Id + '") has no trustee.');
    else if(this.ImpactedAccountsIds == null)
      throw new IncomlendPricing_v3_Exception('Accounts Ids not found');
  }

  // This method loads all eWallets trustee of all accounts
  private List<eWallet_Trustee__c> LoadeWalletsTrustee(List<Id> accountsIds, Invoice_Finance_Deal__c invoice)
  {
    List<eWallet_Trustee__c> result = new List<eWallet_Trustee__c>();

    try
    {
      // Loads the eWallet trustee
      if(invoice != null)
        result = [SELECT id,
                Account__c,
                CCY__c,
                Trustee__c
        FROM eWallet_Trustee__c
        WHERE Account__c IN :accountsIds
        AND CCY__c = :invoice.CCY__c
        AND Trustee__c = :invoice.Trustee__c];
    }
    catch(System.QueryException queryException)
    {
      if(queryException.getMessage() != 'List has no rows for assignment to SObject')
        throw queryException;
    }

    return result;
  }

  // This method instanciates a new transaction
  private Transaction__c CreateTransaction(id eWalletId, string eWalletName, id accountId, string accountName, string ccy, decimal amount, string type)
  {
    return CreateTransaction(eWalletId, eWalletName, accountId, accountName, ccy, amount, type, null, null);
  }

  private Transaction__c CreateTransaction(id eWalletId, string eWalletName, id accountId, string accountName, string ccy, decimal amount, string type, id allocationId, string allocationName)
  {
    Transaction__c newTransaction = new Transaction__c();
    newTransaction.accounting_period__c = this.AccountingPeriod.Id;
    newTransaction.eWallet__c = eWalletId;
    newTransaction.account__c = accountId;
    newTransaction.ccy__c = ccy;
    newTransaction.Amount__c = amount;
    newTransaction.effective_date__c = this.EffectiveDate;
    newTransaction.status__c = 'Confirmed by operations';
    newTransaction.type__c = type;
    newTransaction.Invoice_Allocation__c = allocationId;
    newTransaction.Invoice_Finance_Deal__c = this.Invoice.Id;
    newTransaction.Trustee__c = this.Invoice.Trustee__c;

    newTransaction.eWallet_Trustee__c = filtereWalletTrustee(accountId);

    this.TransactionsToInsert.add(newTransaction);
    this.TransactionsTable.add(new List<string> {  eWalletName,
            accountName,
            type,
            ccy,
            FormatDecimal(amount),
            string.valueOf(this.EffectiveDate),
            (allocationName != null ? allocationName : ''),
            this.Invoice.Name,
            newTransaction.status__c});
    updateeWalletBalance(eWalletName + ' - ' + accountName, amount);

    return newTransaction;
  }

  // This method tracks the balance evolution of the impacted eWallets
  private void UpdateeWalletBalance(string eWalletName, decimal amount)
  {
    decimal oldBalance = this.ImpactedeWallets.get(eWalletName);
    decimal newBalance;

    if(oldBalance != null)
      newBalance = oldBalance + amount;
    else
            newBalance = amount;

    this.ImpactedeWallets.put(eWalletName, newBalance);

    if(oldBalance != null) // If oldBalance == null => Initialisation of the balance, it's not a movement
      this.eWalletMovementsTable.add(new List<string> {eWalletName, FormatDecimal(oldBalance), FormatDecimal(amount), FormatDecimal(newBalance)});
  }

  // This method formats a decimal to a string
  private string FormatDecimal(decimal amount)
  {
    if(amount == null)
      return '';

    string strAmount = string.valueOf(amount);
    string separator = '.';

    if(strAmount.contains(','))
      separator = ',';
    else if(strAmount.indexOf(separator) == -1)
      strAmount = strAmount + '.00';

    strAmount = strAmount.substring(0, strAmount.indexOf(separator));

    if(amount - Decimal.valueOf(strAmount) == 0)
      return string.valueOf(amount.format()) + separator + '00';
    else
            return string.valueOf(amount.format());
  }

  // This methods return a eWallet Id trustee by account Id from ImpactedeWalletTrustee list
  private Id filtereWalletTrustee(Id accountId)
  {
    eWallet_Trustee__c selectedeWalletTrustee = new eWallet_Trustee__c();
    for (eWallet_Trustee__c currenteWalletTrustee: this.eWalletsTrustee) {
      if (currenteWalletTrustee.Account__c == accountId) {
        selectedeWalletTrustee = currenteWalletTrustee;
        break;
      }
    }
    if (selectedeWalletTrustee == null)
      throw new IncomlendPricing_v3_Exception('Account (Id: "' + accountId + '") has no eWallet trustee.');

    return selectedeWalletTrustee.Id;
  }

  // =======
  // Classes
  // =======
  public class IncomlendPricing_v3_Exception extends Exception {}
}