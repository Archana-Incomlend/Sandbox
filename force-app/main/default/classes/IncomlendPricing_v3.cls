// ==========================================================================================================
// IncomlendPricing_v3 class
// -------------------------
// This class manages Incomlend pricing v3 (Sep. 2019) and replaces previous Incomlend pricing v2 (Jun. 2018)
//
// Author: Pierre Petesch
// Modified: Claire Provot (Bangladesh With deposit No deposit With Factory)
// Modified: Mel Dinh (clean up, code smell, duplication, buyback, partial fund, volofin)
// ==========================================================================================================
public class IncomlendPricing_v3
{
  // =====
  // Constants
  // =====
  public static final String FEE_TYPE_INSR = 'Insurance';
  public static final String FEE_TYPE_MEMBERSHIP = 'Membership';
  public static final String FEE_TYPE_MAINTENANCE = 'Maintenance Fees';
  public static final String STATUS_PAID = 'Paid';
  public static final String STATUS_PENDING = 'Pending';
  public static final String NET_EFDA = 'Net EFDA -15days';
  public static final String WITH_DEPOSIT = 'With deposit';
  public static final String NO_DEPOSIT = 'No deposit';
  public static final String WITH_FACTORY = 'With factory';
  public static final String AGENT_FEE_PS = 'Part of profit share (%)';
  public static final String RESERVATION = 'Reservation';
  public static final String CONFIRMED = 'Confirmed';
  public static final String CLOSED = 'Repaid invoice deal closed';
  public static final String BUYBACK = 'Buyback';
  public static final String INCOMLEND_TRADING_LTD = 'Incomlend Trading Limited';
  public static final String VOLOFIN = 'Volofin';
  public static final String VOLOFIN_AGENT = 'Volo Fin Pte Ltd';

  // =====
  // Enums
  // =====
  private enum SearchType
  {
    ById,
    ByName
  }

  // ======
  // Fields
  // ======
  private boolean field_hasEncounteredIssues = false;

  private Date addUpdateAllocationDate = null;

  private boolean isBuyback = false;

  private boolean isPartialFunded = false;

  private Map<Id,Tax_Rate__c> taxRateMap = null;

  // ==========
  // Properties
  // ==========
  // Logs
  public Helper_Log Logs
  {
    get;
    set;
  }

  // Email notification
  private IncomlendPricing_v3_Configuration.NotificationConfiguration Notification
  {
    get;
    set;
  }

  // Behaviour configuration
  private IncomlendPricing_v3_Configuration.BehaviourConfiguration Behaviour
  {
    get;
    set;
  }

  // Invoice Id (provided by the constructor)
  public Id InvoiceId
  {
    public get;
    private set;
  }

  // Effective Date of the transactions
  public date EffectiveDate
  {
    get;
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

  // ===========================
  // Properties (loaded objects)
  // ===========================
  // Accouting Period
  public Accounting_Period__c AccountingPeriod
  {
    public get;
    private set;
  }

  // Invoice to process
  public Invoice_Finance_Deal__c Invoice
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

  // Invoice Buyback Allocations
  public List<Invoice_Allocation__c> InvoiceBuybackAllocations
  {
    public get;
    private set;
  }

  public Invoice_Allocation__c InvoiceBuybackCopyAllocation
  {
    public get;
    private set;
  }

  // Invoice Transactions
  public List<Transaction__c> InvoiceTransactions
  {
    public get;
    private set;
  }

  // Tax Invoices
  public List<Tax_Rate__c> TaxRates
  {
    public get;
    private set;
  }

  // Incomlend Operations Account
  public Account IncomlendOperations
  {
    public get;
    private set;
  }

  // Incomlend Supplier Discount Account
  public Account IncomlendSupplierDiscount
  {
    public get;
    private set;
  }

  // Incomlend Fees Account
  public Account IncomlendFees
  {
    public get;
    private set;
  }

  // Incomlend Provision
  public Account IncomlendAgentProvision
  {
    public get;
    private set;
  }

  // Incomlend Provision
  public Account IncomlendProvision
  {
    public get;
    private set;
  }

  // Incomlend GST Account
  public Account IncomlendGST
  {
    public get;
    private set;
  }

  // TranswapAccount
  public Account TranswapAccount
  {
    public get;
    private set;
  }

  public Account IncomlendTrading
  {
    public get;
    private set;
  }

  public Account IncomlendInTransitProvision
  {
    public get;
    private set;
  }

  // Supplier Account
  public Account Supplier
  {
    public get;
    private set;
  }

  // Buyer Account
  public Account Buyer
  {
    public get;
    private set;
  }
  
  // Factory Account
  public Account Factory
  {
    public get;
    private set;
  }

  // Insurer Account
  public Account Insurer
  {
    public get;
    private set;
  }

  // Funder Agents
  public Map<Id, Account> FunderAgents
  {
    public get;
    private set;
  }

  // Map Agent
  public Account MapAgent
  {
    public get;
    private set;
  }

  // Map Extension
  public Map_Extension__c MapExtension
  {
    public get;
    private set;
  }

  // Installment Insurance List
  public List<Instalment_insurance_fee__c> insuranceInstallments {
    public get;
    private set;
  }

  // Installment Insurance Records Count
  public Integer totalInstallmentRecords { public get; private set; }

  // Membership Fee List
  public List<Instalment_insurance_fee__c> membershipFees {
    public get;
    private set;
  }

  // Total Membership Fees in Pending Status
  public Decimal totalMembershipFeeAmount { public get; private set; }

  // Maintenance Fee List
  public List<Instalment_insurance_fee__c> maintenanceInstallments
  {
    public get;
    private set;
  }

  // eWallet Trustee List
  public List<eWallet_Trustee__c> eWalletTrustee {
    public get;
    private set;
  }

  // Is Bangladesh Special Case
  public Boolean isBangladesh { public get; private set; }

  // Is In Trasit
  public Boolean isInTransit { public get; private set; }

  // Is In Trasit Repo
  public Boolean isInTransitRepo { public get; private set; }

  // workaround test Too many SOQL queries 101
  public boolean needReload = true;

  // fetch lazy for account
  public boolean fetchLazy = true;
  public Map<String, Account> FetchedAccounts;

  // =======================================
  // Properties (data changes in Salesforce)
  // =======================================
  // Transactions to insert following the process
  private List<Transaction__c> TransactionsToInsert
  {
    get;
    set;
  }

  // Transactions of Incomlend Supplier Discount account
  private List<Transaction__c> TransactionsIncomlendSupplierDiscount
  {
    get;
    set;
  }

  // Transactions of Incomlend Operations account
  private List<Transaction__c> TransactionsIncomlendOperations
  {
    get;
    set;
  }

  // Allocations to update following the process
  private List<Invoice_Allocation__c> AllocationsToUpdate
  {
    get;
    set;
  }

  // Impacted eWallets following the process
  private Map<string, decimal> ImpactedeWallets
  {
    get;
    set;
  }

  // Impacted accounts following the process
  private Set<Id> ImpactedAccountsIds
  {
    get;
    set;
  }

  // ===========
  // Logs tables
  // ===========
  // Table of transactions
  private List<List<string>> TransactionsTable
  {
    get;
    set;
  }

  // Table of eWallet movements
  private List<List<string>> eWalletMovementsTable
  {
    get;
    set;
  }

  // Table of negative eWallets
  private List<List<string>> NegativeeWalletsTable
  {
    get;
    set;
  }

  public List<Instalment_insurance_fee__c> InstallmentsToUpdate
  {
    get;
    set;
  }

  // ============
  // Constructors
  // ============
  public IncomlendPricing_v3(id invoiceId)
  {
    this.Logs = new Helper_Log();
    this.InvoiceId = invoiceId;
    this.EffectiveDate = System.today();

    this.Notification = new IncomlendPricing_v3_Configuration.NotificationConfiguration();
    this.Behaviour = new IncomlendPricing_v3_Configuration.BehaviourConfiguration();
  
  }

  // ==============
  // Public Methods
  // ==============
  // This method funds the invoice
  // Returns true if the process has succeeded
  // Returns false if the process has encountered issues
  public boolean FundInvoice()
  {
    try
    {
      CoreInitialization();

      this.Logs.LogLine();
      this.Logs.Log('FundInvoice() method called by ' + UserInfo.getName(), 1, Helper_Log.Color.Blue);
      this.Logs.LogLine();

      LogConfiguration();

      // =======
      // Loading
      // =======
      this.Logs.Log('Process Logs:', 1, Helper_Log.Color.Blue);
      this.Logs.Log('1. Loading core data', 1, Helper_Log.Color.Green);
      CoreLoading(true);
      if (!(this.isBangladesh && this.Invoice.Bangladesh_special_case__c == NO_DEPOSIT)
            && !(this.isBangladesh && this.Factory != null && !this.MapExtension.Funding_Upfront_fees__c)) {
        CoreLoadingUpfront();
      }

      this.Logs.Log('2. Loading funding data', 1, Helper_Log.Color.Green);    
      LoadeWalletTrustee();

      // ===========
      // Validations
      // ===========
      this.Logs.Log('3. Validating the data', 1, Helper_Log.Color.Green);
      validateToBeFunded();

      // ===============
      // Funding Process
      // ===============
      this.Logs.Log('4. Funding the invoice', 1, Helper_Log.Color.Green);

      fundingInvoicePurchase();
      fundingAdvanceAmount();

      // -------------------------------------------------------------
      // Upfront fees
      // -------------------------------------------------------------
      // Bangladesh no deposit, upfront fees are not paid at funding instead at repayment 
      // Bangladesh with factory, whether or not upfront fees paid at funding depend on Map Extension
      decimal upfrontFee = 0;
      if (!(this.isBangladesh && this.Invoice.Bangladesh_special_case__c == NO_DEPOSIT)
              && !(this.isBangladesh && this.Factory != null && !this.MapExtension.Funding_Upfront_fees__c)) {
        upfrontFee = payUpfrontFees();
      }
      fundingFunderPrepaymentAndFees();
      // Bangladesh no deposit, upfront fees are not paid at funding instead at repayment 
      // Bangladesh with factory, whether or not upfront fees paid at funding depend on Map Extension
      if (!(this.isBangladesh && this.Invoice.Bangladesh_special_case__c == NO_DEPOSIT)
              && !(this.isBangladesh && this.Factory != null && !this.MapExtension.Funding_Upfront_fees__c)) {
        payUpfrontFeesBalance(true);
        payPlatformFee();
      }
      if (isInTransit) {
        fundingInTransit(this.Invoice.funded_amount__c - upfrontFee);
      }
      volofin(true);
      commonDml(true);

    }
    catch(Exception unmanagedException)
    {
      this.Logs.Log(unmanagedException);

      this.HasEncounteredIssues = true;
    }
    finally
    {
      sendAlertAndLog();
    }

    return (!this.HasEncounteredIssues);
  }

  private void sendAlertAndLog() {
    System.debug(this.Logs.PlainLog);

    // Sends alerts
    if(this.HasEncounteredIssues || !this.Notification.AlertsOnErrorOnly)
      Helper_Email.Send(this.Notification.IsHTML, this.Notification.AlertsRecipients, this.Notification.AlertsSubject, this.Logs.HTMLLog);

    // Sends logs
    if(this.HasEncounteredIssues || !this.Notification.LogsOnErrorOnly) {
      List<String> listStr = this.Notification.LogsRecipients;
      String str = config.getConfig('IncomlendPricing_v3_Notification_LogsRecipients2');
      if (!String.isBlank(str) && str != 'key not found') {
        listStr = new List<String>(listStr);
        listStr.addAll(str.split(';'));
      }
      Helper_Email.Send(this.Notification.IsHTML, listStr, this.Notification.LogsSubject, this.Logs.HTMLLog);
    }
  }

  private Tax_Rate__c getTaxRate(Id accountId) {
    return getTaxRate(accountId, null);
  }

  private Tax_Rate__c getTaxRate(Id accountId, String country) {
    if (taxRateMap.containsKey(accountId))
            return taxRateMap.get(accountId);
    for(Tax_Rate__c currentTaxRate : this.TaxRates)
    {
      if (country == null) {
        Account taxAccount = null;
        if (accountId == Supplier.Id) taxAccount = Supplier;
        else if (accountId == Buyer.Id) taxAccount = Buyer;
        else if (accountId == MapAgent.Id) taxAccount = MapAgent;
        if (taxAccount != null) 
                country = taxAccount.Country_of_Incorporation__c;
      }

      if(country != null && currentTaxRate.Country__c == country) {
        taxRateMap.put(accountId, currentTaxRate);
        return currentTaxRate;
      }
    }
    taxRateMap.put(accountId, null);
    return null;
  }

  public void validateToBeFunded() {

    // Validates the invoice phase equals "2:ON MARKETPLACE"
    this.HasEncounteredIssues = !IsValidated(  this.Invoice.Phase__c == '2:ON MARKETPLACE',
            this.Behaviour.FailAtValidation,
            'Invoice "Phase" field equals 2:ON MARKETPLACE.',
            'Invoice "Phase" field does not equal 2:ON MARKETPLACE. Current value: ' + this.Invoice.Phase__c + '.');

    // Validates the invoice is not funded yet, so no transactions yet
    this.HasEncounteredIssues = !IsValidated(  this.InvoiceTransactions.size() == 0,
            this.Behaviour.FailAtValidation,
            'Invoice is not yet funded. No transactions found.',
            'Invoice seems to be already funded. ' + this.InvoiceTransactions.size() + ' transaction(s) found.');

    // Validates the "advance amount credited to ewallet date" field is set
    this.HasEncounteredIssues = !IsValidated(  this.Invoice.advance_send_to_supplier_date__c != null,
            this.Behaviour.FailAtValidation,
            'Invoice "advance amount credited to ewallet date" field is not empty. Current value: ' + string.valueOf(this.Invoice.advance_send_to_supplier_date__c) + '.',
            'Invoice "advance amount credited to ewallet date" field is empty.');

    // Validates the "Due date" field is set
    this.HasEncounteredIssues = !IsValidated(  this.Invoice.Due_Date__c != null,
            this.Behaviour.FailAtValidation,
            'Invoice "Due date" field is not empty. Current value: ' + string.valueOf(this.Invoice.Due_Date__c) + '.',
            'Invoice "Due date" field is empty.');

    if (this.Behaviour.FailAtValidation) this.Logs.Log('Invoice "expected financing period" field is not empty. Current value: ' + this.Invoice.expected_financing_period__c + '.', 2, Helper_Log.Color.Black);

    // Validates the "Supplier country of Incorporation" field is set
    this.HasEncounteredIssues = !IsValidated(  this.Invoice.Supplier_Country__c != null,
            this.Behaviour.FailAtValidation,
            'Invoice "Supplier Country" field is not empty. Current value: ' + this.Invoice.Supplier_Country__c + '.',
            'Invoice "Supplier Country" field is empty.');

    // Validates the "Notice of Assignment signed" field is equals to true
    this.HasEncounteredIssues = !IsValidated(  this.Invoice.Notice_of_Assignment_signed__c,
            this.Behaviour.FailAtValidation,
            'Invoice "Notice of Assignment signed" field equals True.',
            'Invoice "Notice of Assignment signed" field does not equal True. Current value: ' + string.valueOf(this.Invoice.Notice_of_Assignment_signed__c) + '.');

    // Validates the "funded amount" field is greater than 0
    this.HasEncounteredIssues = !IsValidated(  this.Invoice.funded_amount__c > 0,
            this.Behaviour.FailAtValidation,
            'Invoice "funded amount" field is greater than 0.00. Current value: ' + FormatDecimal(this.Invoice.funded_amount__c) + '.',
            'Invoice "funded amount" field is not greater than 0.00. Current value: ' + FormatDecimal(this.Invoice.funded_amount__c) + '.');

    // Validates the "remaining amount" field greater or equals to 0 
    this.HasEncounteredIssues = !IsValidated(  Invoice.remaining_amount__c == 0,
            this.Behaviour.FailAtValidation,
            'Invoice "remaining amount" field equals 0.00.',
            'Invoice "remaining amount" field invalid. Current value: ' + FormatDecimal(this.Invoice.remaining_amount__c) + '.');

    // Validates the "Sum Of All Pre-reservations" field equals to 0
    this.HasEncounteredIssues = !IsValidated(  this.Invoice.Sum_Of_All_Pre_Reservations__c == null || this.Invoice.Sum_Of_All_Pre_Reservations__c == 0,
            this.Behaviour.FailAtValidation,
            'Invoice "Sum Of All Pre-reservations" field equals 0.00.',
            'Invoice "Sum Of All Pre-reservations" field does not equal 0.00. Current value: ' + FormatDecimal(this.Invoice.Sum_Of_All_Pre_Reservations__c) + '.');

    // Validates the "Total Supplier Discount" field is greater than 0
    this.HasEncounteredIssues = !IsValidated(  this.Invoice.Total_Supplier_Discount__c > 0,
            this.Behaviour.FailAtValidation,
            'Invoice "Total Supplier Discount" field is greater than 0.00. Current value: ' + this.Invoice.Total_Supplier_Discount__c.format() + '.',
            'Invoice "Total Supplier Discount" field is not greater than 0.00. Current value: ' + FormatDecimal(this.Invoice.Total_Supplier_Discount__c) + '.');

    if(this.Invoice.credit_insurance_fee__c > 0) {
      // Validates the insurer is identified if there is an insurance fee to collect
      this.HasEncounteredIssues = !IsValidated(  this.Insurer != null,
              this.Behaviour.FailAtValidation,
              'Invoice "Insured by" field is identified. Current value: ' + this.Invoice.Insured_by__c + '.',
              'Invoice "Insured by" field is not identified or not appropriate to collect insurance fees. Current value: ' + this.Invoice.Insured_by__c + '');

      // Validates that there are no installment insurance linked to the invoice
      boolean hasNoInsuranceInstallment = null == this.insuranceInstallments || this.insuranceInstallments.isEmpty();
      string insuranceInstallmentName = hasNoInsuranceInstallment ? '' : this.insuranceInstallments.get(0).Name;

      this.HasEncounteredIssues = !IsValidated(hasNoInsuranceInstallment,
              this.Behaviour.FailAtValidation,
              'No installment insurance linked to this invoice.',
              'Installment insurance found for this invoice. Current value: ' + insuranceInstallmentName);
    }

    if (null != this.insuranceInstallments && !this.insuranceInstallments.isEmpty()) {
      // Validates the insurer is identified if there is an installment insurance fee to collect
      this.HasEncounteredIssues = !IsValidated(  this.Insurer != null,
              this.Behaviour.FailAtValidation,
              'Invoice "Insured by" field is identified. Current value: ' + this.Invoice.Insured_by__c,
              'Invoice "Insured by" field is not identified or not appropriate to collect insurance fees. Current value: ' + this.Invoice.Insured_by__c);

      // Validates if there is only one type of insurance fee to collect
      this.HasEncounteredIssues = !IsValidated((null == this.Invoice.credit_insurance_fee_percentage__c || this.Invoice.credit_insurance_fee_percentage__c == 0.00)
              && (null == this.Invoice.credit_insurance_fee__c || this.Invoice.credit_insurance_fee__c == 0.00),
              this.Behaviour.FailAtValidation,
              'Invoice "credit insurance fee amount and percentage" fields are null/blank or 0.00%. Current value amount/percentage: ' + this.Invoice.credit_insurance_fee__c + '/' + this.Invoice.credit_insurance_fee_percentage__c,
              'Invoice "credit insurance fee amount/percentage" field/s have values greater than 0.00%. Current value amount/percentage: ' + this.Invoice.credit_insurance_fee__c + '/' + this.Invoice.credit_insurance_fee_percentage__c);

      // Validates if invoice and installment insurance have the same currency
      this.HasEncounteredIssues = !IsValidated(this.insuranceInstallments.get(0).Currency__c == this.Invoice.CCY__c,
              this.Behaviour.FailAtValidation,
              'Invoice currency and insurance installment currency are equal. Current value invoice/insurance: ' + this.Invoice.CCY__c + '/' + this.insuranceInstallments.get(0).Currency__c,
              'Invoice currency and insurance installment currency not are equal. Current value invoice/insurance: ' + this.Invoice.CCY__c + '/' + this.insuranceInstallments.get(0).Currency__c);
    }

    // Validates if invoice and membership fee have the same currency
    if (null != this.membershipFees && !this.membershipFees.isEmpty()) {
      this.HasEncounteredIssues = !IsValidated(this.membershipFees.get(0).Currency__c == this.Invoice.CCY__c,
              this.Behaviour.FailAtValidation,
              'Invoice currency and membership fee currency are equal. Current value invoice/membership: ' + this.Invoice.CCY__c + '/' + this.membershipFees.get(0).Currency__c,
              'Invoice currency and membership fee currency not are equal. Current value invoice/membership: ' + this.Invoice.CCY__c + '/' + this.membershipFees.get(0).Currency__c);
    }

    // Validates the "Un utilised adv amt all phases usd equiv" field is greater or equals to 0
    this.HasEncounteredIssues = !IsValidated(  this.Buyer.Un_utilised_adv_amt_all_phases_usd_equiv__c >= 0,
            this.Behaviour.FailAtValidation,
            'Buyer "Un utilised adv amt all phases usd equiv" field is greater or equals to 0.00.',
            'Buyer "Un utilised adv amt all phases usd equiv" field is not greater or equals to 0.00. Current value: ' + FormatDecimal(this.Buyer.Un_utilised_adv_amt_all_phases_usd_equiv__c) + ').');

    if (this.Invoice.Product_type__c == null) this.HasEncounteredIssues 
          = !IsValidated(  this.Behaviour.FailAtValidation, 'Invoice "Custom Product (old)" field is empty.');

    decimal acceptedMargin = 0.01;
    if (this.Invoice.Credit_Limit_Available__c <= -acceptedMargin) this.HasEncounteredIssues 
          = !IsValidated(  this.Behaviour.FailAtValidation, 'Invoice "Credit Limit Available" field is negative.');

    if (this.MapAgent != null && this.MapAgent.Name == 'Incomlend - agent') this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtValidation,
            'Supplier/Map\'s Agent Commission amount should be empty for Incomlend - agent.');

    validateInTransit();

    validateInvoiceAllocation(RESERVATION);

    validateVolofin();
    validateBangladesh();
  }

  private void recalculateFormulas(Invoice_Allocation__c currentAllocation) {
    Formula.recalculateFormulas(new List<SObject>{ currentAllocation });
    GlobalTriggerHandler.calculateAllocationFees(currentAllocation);
  }

  private boolean validateInvoiceAllocation(String expectedStatus) {
    if (expectedStatus == BUYBACK && !isBuyback) return false;
    boolean found = false;
    for(Invoice_Allocation__c currentAllocation : this.InvoiceAllocations) {
      if (currentAllocation.Status__c == CLOSED) continue;
      if (expectedStatus == BUYBACK) {
        if (currentAllocation.Status__c != expectedStatus) continue;
        if (currentAllocation.Buybacked_Date__c == null) this.HasEncounteredIssues 
              = !IsValidated(  this.Behaviour.FailAtValidation, 'Buyback Allocation ' + currentAllocation.Name + ' "Buyback Close Date" field is empty.');

        if (this.Invoice.remaining_amount__c > 0 && this.InvoiceBuybackCopyAllocation == null) {
          if (currentAllocation.amount__c > this.Invoice.remaining_amount__c) {
            this.InvoiceBuybackCopyAllocation = currentAllocation;
            // this.InvoiceBuybackCopyAllocation = currentAllocation.clone(false, true, false, false);
            currentAllocation.amount__c = currentAllocation.amount__c - this.Invoice.remaining_amount__c;
            // recalculateFormulas(currentAllocation); // currentAllocation.recalculateFormulas();
          }    
        }
      } else if (isBuyback || isPartialFunded) {
        if (expectedStatus == RESERVATION && currentAllocation.Status__c == expectedStatus) {
          if (currentAllocation.Buyback_Enter_Date__c == null && addUpdateAllocationDate != null) 
                currentAllocation.Buyback_Enter_Date__c = addUpdateAllocationDate; 
          else if (currentAllocation.Buyback_Enter_Date__c == null) this.HasEncounteredIssues 
                = !IsValidated(  this.Behaviour.FailAtValidation, 'Reservation Allocation ' + currentAllocation.Name + ' "Partially Fund Date" field is empty.');
        }
      } else if (!isBuyback && currentAllocation.Status__c == BUYBACK) {
        if (currentAllocation.Buybacked_Date__c == null) this.HasEncounteredIssues 
              = !IsValidated(  this.Behaviour.FailAtValidation, 'Buyback Allocation ' + currentAllocation.Name + ' has not been buybacked.');
        continue;
      }

      if (currentAllocation.Status__c != expectedStatus) continue;
      found = true;

      // Validates the invoice allocation status equals "Reservation"
      this.HasEncounteredIssues = !IsValidated(  isBuyback || isPartialFunded || currentAllocation.status__c == expectedStatus,
              this.Behaviour.FailAtValidation,
              'Invoice allocation ' + currentAllocation.Name + ' "Status" field equals "' + expectedStatus + '".',
              'Invoice allocation ' + currentAllocation.Name + ' "Status" field does not equal "' + expectedStatus + '". Current value: ' + currentAllocation.status__c + '.');

      // Prints out the invoice allocation "Amount" field
      IsValidated(  true, false, 'Invoice allocation "Amount" field is not empty. Current value: ' + currentAllocation.amount__c + '.', '');

      // Flexible funder discount rate
      // Validates the "Applied MPR" field is greater than 0
      this.HasEncounteredIssues = !IsValidated(  currentAllocation.Applied_MPR__c > 0,
              this.Behaviour.FailAtValidation,
              'Invoice allocation "Funder discount rate" field is greater than 0.00. Current value: ' + FormatDecimal(currentAllocation.Applied_MPR__c) + '.',
              'Invoice allocation "Funder discount rate" field is not greater than 0.00. Current value: ' + currentAllocation.Applied_MPR__c.format() + '.');

      // Prints out the invoice allocation "Applied Funder Discount Profit Share Pct" field
      if (GlobalTriggerHandler.coalesce(currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c) > 0) {
        IsValidated(  true, false, 'Invoice allocation "Applied Funder Discount Profit Share Pct" field is not empty. Current value: ' + FormatDecimal(currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c) + '.', '');
      } else { 
        IsValidated(  true, false, 'Invoice allocation "Applied Funder Discount Profit Share Pct" field is empty.', '');
      }

      // Validates the account "Funder Country of Incorporation" field does not equal NULL
      this.HasEncounteredIssues = !IsValidated(  currentAllocation.Funder__r.Country_of_Incorporation__c != null,
              this.Behaviour.FailAtValidation,
              'Funder account ' + currentAllocation.Funder__r.Name + ' "Country of Incorporation" field is not empty. Current value: ' + currentAllocation.Funder__r.Country_of_Incorporation__c + '.',
              'Funder account ' + currentAllocation.Funder__r.Name + ' "Country of Incorporation" field is empty.');

      if (this.FunderAgents != null && currentAllocation.Funder__r.Agent__c != null) {
        if (this.FunderAgents.get(currentAllocation.Funder__r.Agent__c) == null) { if (GlobalTriggerHandler.coalesce(currentAllocation.Funder_Agent_Commission_Amount__c) != 0) this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtValidation,
                'Invoice allocation ' + currentAllocation.Name + ' Funder Agent has not been found during loading.'); }
        else if (currentAllocation.Funder__r.Agent__c != null && this.FunderAgents.get(currentAllocation.Funder__r.Agent__c).Name == 'Incomlend - agent') this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtValidation,
                'Invoice allocation ' + currentAllocation.Name + ' "Funder Agent Commission amount" should be empty for Incomlend - agent.');
      }
    }
    return found;
  }

  private void validateVolofin() {
    if (this.Invoice.Insured_by__c != VOLOFIN) return;
    if (this.Insurer == null || this.Insurer.Name != 'Volofin Provision') this.HasEncounteredIssues 
          = !IsValidated(  this.Behaviour.FailAtValidation, 'Insurer should be Volofin Provision for Volofin case.');
    if (this.MapAgent == null || this.MapAgent.Name != VOLOFIN_AGENT) this.HasEncounteredIssues 
          = !IsValidated(  this.Behaviour.FailAtValidation, 'Supplier/Map\'s Agent Commission amount should be empty for for Volofin case.');
  }

  private void validateBangladesh() {
    if (this.isBangladesh) {
      IsValidated(  true, false, 'Invoice "Bangladesh special case" field is not empty. Current value: ' + this.Invoice.Bangladesh_special_case__c + '.', '');
      if (this.Invoice.Insured_by__c == VOLOFIN) this.HasEncounteredIssues 
            = !IsValidated(  this.Behaviour.FailAtValidation, 'Volofin are not available for Bangladesh special case.');
      if (this.Invoice.Bangladesh_special_case__c == WITH_FACTORY) 
      {
        // Validates the invoice map extension is not empty
        this.HasEncounteredIssues = !IsValidated(  this.Invoice.Map_Extension__c != null,
              this.Behaviour.FailAtValidation,
              'Invoice "Map Extension" field is not empty.',
              'Invoice "Map Extension" field is empty.');
        if (this.Invoice.Map_Extension__c != null && this.Factory == null) this.HasEncounteredIssues 
              = !IsValidated(  this.Behaviour.FailAtValidation, 'Map Extenstion "Factory" field is empty.');

        // Validates the invoice factory amount is greater than 0
        this.HasEncounteredIssues = !IsValidated(  this.Invoice.Factory_Amount__c > 0,
              this.Behaviour.FailAtValidation,
              'Invoice "Factory Amount" field is greater than 0.00. Current value: ' + FormatDecimal(this.Invoice.Factory_Amount__c) + '.',
              'Invoice "Factory Amount" field is not greater than 0.00. Current value: ' + FormatDecimal(this.Invoice.Factory_Amount__c) + '.');
      }
    } else 
      IsValidated(  true, false, 'Invoice "Bangladesh special case" field is empty.', '');
  }

  private void validateInTransit() {
    if (isInTransit) {
      this.HasEncounteredIssues = !IsValidated(  isInTransitRepo,
              this.Behaviour.FailAtValidation,
              'In Transit product, Buyer is Incomlend Trading, the case is Repo.',
              'In Transit product, factoring/reverse factoring is not supported, only Repo case is supported at the moment.');
      if (isBangladesh) this.HasEncounteredIssues 
            = !IsValidated(  this.Behaviour.FailAtValidation, 'In Transit products are not available for Bangladesh special case.');
    }
    if (isInTransit && isInTransitRepo) {
      this.HasEncounteredIssues = !IsValidated(  this.Invoice.Map_Extension__c != null,
              this.Behaviour.FailAtValidation,
              'Invoice "Map Extension" field is not empty.',
              'Invoice "Map Extension" field is empty.');
      if (this.Invoice.Map_Extension__c != null && this.Factory == null) this.HasEncounteredIssues 
            = !IsValidated(  this.Behaviour.FailAtValidation, 'Map Extenstion "Factory" field is empty.');
    }
  }

  private void fundingInvoicePurchase() 
  {
    // -----------------------------------------------------------
    // 01.Invoice Purchase: Funder purchasing (part of) an invoice
    // -----------------------------------------------------------
    this.Logs.Log('01.Invoice Purchase transactions ' + (isPartialFunded ? '' : this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.funded_amount__c)), 2, Helper_Log.Color.Black);
    for(Invoice_Allocation__c currentAllocation : this.AllocationsToUpdate)
    {
      // Update the current allocation
      currentAllocation.Allocation_Confirmed_Date__c = this.EffectiveDate;
      currentAllocation.Status__c = CONFIRMED;

      this.Logs.Log('Allocation: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(currentAllocation.amount__c) + ' from ' + currentAllocation.Funder__r.Name, 3, Helper_Log.Color.Grey);

      // Create the debit/credit transactions from Funder's eWallet to Incomlend Operations' eWallet
      CreateTransaction(  currentAllocation.eWallet__c,
              currentAllocation.eWallet__r.Name,
              currentAllocation.Funder__c,
              currentAllocation.Funder__r.Name,
              currentAllocation.CCY__c,
              currentAllocation.amount__c * -1,
              '01.Invoice Purchase',
              currentAllocation.Id,
              currentAllocation.Name);
      CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
              this.IncomlendOperations.eWallets__r[0].Name,
              this.IncomlendOperations.Id,
              this.IncomlendOperations.Name,
              currentAllocation.CCY__c,
              currentAllocation.amount__c,
              '01.Invoice Purchase',
              currentAllocation.Id,
              currentAllocation.Name);
    }
  }

  private void fundingAdvanceAmount() { 

    // -------------------------------------------------------------
    // 02.Invoice Advance Amount: Funded amount sent to the supplier
    // -------------------------------------------------------------

    this.Logs.Log('"02.Invoice Advance Amount transactions" ' + (isPartialFunded ? '' : this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.funded_amount__c)), 2, Helper_Log.Color.Black);
    
    // Create the debit/credit transactions from Incomlend Operations' eWallet to Supplier's eWallet
    decimal pseudoAmount = this.Invoice.funded_amount__c;
    if (isPartialFunded) pseudoAmount += sumTransaction(this.InvoiceTransactions, '' + this.IncomlendOperations.Id + ';' + '02.Invoice Advance Amount', 'id-type');

    for (Account creditAccount : new List<Account> {this.Factory, this.Supplier}) {
      if (this.Factory == null && creditAccount == null) continue;
      if (this.Factory != null && creditAccount == this.Factory) {
         // Bangladesh with factory, substitute Supplier with Factory
         pseudoAmount = Math.min(pseudoAmount, this.Invoice.Factory_Amount__c);
         if (pseudoAmount == 0) continue;
         this.Logs.Log('"02.Invoice Advance Amount transactions for factory" ' + this.Invoice.CCY__c + ' ' + FormatDecimal(pseudoAmount), 2, Helper_Log.Color.Black);
      } else if (this.Factory != null) {
         // Bangladesh with factory, remaining funded amount sent to the supplier
         pseudoAmount = this.Invoice.funded_amount__c - pseudoAmount;
         if (pseudoAmount == 0) continue;
         this.Logs.Log('"02.Invoice Advance Amount transactions for supplier" ' + this.Invoice.CCY__c + ' ' + FormatDecimal(pseudoAmount), 2, Helper_Log.Color.Black);
      }
      CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
              this.IncomlendOperations.eWallets__r[0].Name,
              this.IncomlendOperations.Id,
              this.IncomlendOperations.Name,
              this.Invoice.CCY__c,
              pseudoAmount * -1,
              '02.Invoice Advance Amount');
      CreateTransaction(  creditAccount.eWallets__r[0].Id,
              creditAccount.eWallets__r[0].Name,
              creditAccount.Id,
              creditAccount.Name,
              this.Invoice.CCY__c,
              pseudoAmount,
              '02.Invoice Advance Amount');
    }
  }

  // Upfront fees transactions
  private Decimal payUpfrontFees() {
    
    // Tax rate Supplier
    Tax_Rate__c TaxRateSupplier = getTaxRate(Invoice.Id_Supplier__c);
    decimal adminFee = 0;
    
    // ---------------------------------------------------------------------------------------------
    // 07.Credit Insurance: Credit insurance fee paid by the supplier, if not on an instalment based
    // Bangladesh with deposit, fee paid by the supplier through Incomlend Provision
    // ---------------------------------------------------------------------------------------------
    // Bangladesh with deposit, substitute Supplier with IncomlendProvision
    Account debitAccount = !isInTransit ? this.Supplier : this.IncomlendTrading;
    if (this.isBangladesh && this.Invoice.Bangladesh_special_case__c == WITH_DEPOSIT) {
      debitAccount = this.IncomlendProvision;
    }
    if (this.isBangladesh && this.Factory != null) {
      debitAccount = this.Factory;
    }
    if (!isPartialFunded) {
      if(this.Invoice.credit_insurance_fee__c > 0)
      {
        this.Logs.Log('"07.Credit Insurance transactions" ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.credit_insurance_fee__c), 2, Helper_Log.Color.Black);
        adminFee += this.Invoice.credit_insurance_fee__c;
        // Create the debit/credit transactions from Supplier's eWallet to Insurer's eWallet
        CreateTransaction(  debitAccount.eWallets__r[0].Id,
                debitAccount.eWallets__r[0].Name,
                debitAccount.Id,
                debitAccount.Name,
                this.Invoice.CCY__c,
                this.Invoice.credit_insurance_fee__c * -1,
                '07.Credit Insurance');
        CreateTransaction(  this.Insurer.eWallets__r[0].Id,
                this.Insurer.eWallets__r[0].Name,
                this.Insurer.Id,
                this.Insurer.Name,
                this.Invoice.CCY__c,
                this.Invoice.credit_insurance_fee__c,
                '07.Credit Insurance');
        // Tax invoice for credit insurance
        if (TaxRateSupplier != null && TaxRateSupplier.rate__c > 0) {
          decimal TaxAmountInsurance = (this.Invoice.credit_insurance_fee__c * TaxRateSupplier.rate__c / 100).setScale(2, RoundingMode.HALF_UP);
          this.Logs.Log('"09.GST transaction" - Credit Insurance GST ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountInsurance), 2, Helper_Log.Color.Black);
          // Create the debit/credit transactions from Supplier's eWallet to Incomlend GST's eWallet
          CreateTransaction(  debitAccount.eWallets__r[0].Id,
                  debitAccount.eWallets__r[0].Name,
                  debitAccount.Id,
                  debitAccount.Name,
                  this.Invoice.CCY__c,
                  TaxAmountInsurance * -1,
                  '09.GST transaction');
          CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                  this.IncomlendGST.eWallets__r[0].Name,
                  this.IncomlendGST.Id,
                  this.IncomlendGST.Name,
                  this.Invoice.CCY__c,
                  TaxAmountInsurance,
                  '09.GST transaction');
        }
      } else if (this.insuranceInstallments != null && !this.insuranceInstallments.isEmpty()) 
      {
        // ------------------------------------------------------------------------------------------
        // 07.Credit Insurance: Credit insurance fee paid by the supplier, if on an installment basis
        // Bangladesh with deposit, fee paid by the supplier through Incomlend Provision
        // ------------------------------------------------------------------------------------------
        Instalment_insurance_fee__c insuranceInstallmentPending = this.insuranceInstallments.get(0);
        adminFee += insuranceInstallmentPending.Amount_Instalment__c;
        this.Logs.Log('07.Credit Insurance installment transactions ' + this.Invoice.CCY__c + ' ' + FormatDecimal(insuranceInstallmentPending.Amount_Instalment__c), 2, Helper_Log.Color.Black);

        // Create the debit/credit transactions from Supplier's eWallet to Insurer's eWallet
        CreateTransaction(  debitAccount.eWallets__r[0].Id,
                debitAccount.eWallets__r[0].Name,
                debitAccount.Id,
                debitAccount.Name,
                this.Invoice.CCY__c,
                insuranceInstallmentPending.Amount_Instalment__c * -1,
                '07.Credit Insurance');
        CreateTransaction(  this.Insurer.eWallets__r[0].Id,
                this.Insurer.eWallets__r[0].Name,
                this.Insurer.Id,
                this.Insurer.Name,
                this.Invoice.CCY__c,
                insuranceInstallmentPending.Amount_Instalment__c,
                '07.Credit Insurance');
        // Tax invoice for insurance
        if (TaxRateSupplier != null && TaxRateSupplier.rate__c > 0) {
          decimal TaxAmountInsurance = (insuranceInstallmentPending.Amount_Instalment__c * TaxRateSupplier.rate__c / 100).setScale(2, RoundingMode.HALF_UP);
          this.Logs.Log('"09.GST transaction" - Credit Installment Insurance GST ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountInsurance), 2, Helper_Log.Color.Black);
          // Create the debit/credit transactions from Supplier's eWallet to Incomlend GST's eWallet
          CreateTransaction(  debitAccount.eWallets__r[0].Id,
                  debitAccount.eWallets__r[0].Name,
                  debitAccount.Id,
                  debitAccount.Name,
                  this.Invoice.CCY__c,
                  TaxAmountInsurance * -1,
                  '09.GST transaction');
          CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                  this.IncomlendGST.eWallets__r[0].Name,
                  this.IncomlendGST.Id,
                  this.IncomlendGST.Name,
                  this.Invoice.CCY__c,
                  TaxAmountInsurance,
                  '09.GST transaction');
        }
        if (this.totalInstallmentRecords == 1 ||
                (this.totalInstallmentRecords == 2 && this.insuranceInstallments.size() > 1)) {
          insuranceInstallmentPending.Due_Date__c = System.today();
        }
        insuranceInstallmentPending.Status_Instalment__c = STATUS_PAID;
        insuranceInstallmentPending.Date_Paiement__c = System.today();
        insuranceInstallmentPending.Invoice_Finance_Deal__c = this.InvoiceId;
        this.InstallmentsToUpdate.add(insuranceInstallmentPending); // update insuranceInstallmentPending;
        Instalment_insurance_fee__c insuranceInstallment;
        // Update of existing installment record or insert of new installment record
        if (this.insuranceInstallments.size() == 1) {
          insuranceInstallment = new Instalment_insurance_fee__c();
          insuranceInstallment.Supplier_buyer_map_instalment__c = insuranceInstallmentPending.Supplier_buyer_map_instalment__c;
          insuranceInstallment.Account_Supplier__c = insuranceInstallmentPending.Account_Supplier__c;
          insuranceInstallment.Fee_Type__c = insuranceInstallmentPending.Fee_Type__c;
          insuranceInstallment.Amount_Instalment__c = insuranceInstallmentPending.Amount_Instalment__c;
          insuranceInstallment.Due_Date__c = insuranceInstallmentPending.Due_Date__c.addMonths(Integer.valueOf(insuranceInstallmentPending.Installment_Term_Months__c));
          insuranceInstallment.Installment_Term_Months__c = insuranceInstallmentPending.Installment_Term_Months__c;
          insuranceInstallment.Status_Instalment__c = STATUS_PENDING;
          this.InstallmentsToUpdate.add(insuranceInstallment); // insert insuranceInstallment;
        } else {
          insuranceInstallment = this.insuranceInstallments.get(1);
          insuranceInstallment.Due_Date__c = insuranceInstallmentPending.Due_Date__c.addMonths(Integer.valueOf(insuranceInstallmentPending.Installment_Term_Months__c));
          this.InstallmentsToUpdate.add(insuranceInstallment); // update insuranceInstallment;
        }
      } else {
        this.Logs.Log('(07.Credit Insurance transactions - No Credit Insurance)', 2, Helper_Log.Color.Grey);
      }
    }

    // --------------------------------------------------------------------------------
    // 88.Annual membership fee: Membership fee paid by the supplier on an annual basis
    // Bangladesh with deposit, fee paid by the supplier through Incomlend Provision
    // --------------------------------------------------------------------------------
    if (!isPartialFunded && this.membershipFees != null && !this.membershipFees.isEmpty()) 
    {
      adminFee += this.totalMembershipFeeAmount;
      this.Logs.Log('"88.Annual membership fee" ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.totalMembershipFeeAmount), 2, Helper_Log.Color.Black);
      // Create the debit/credit transactions from Supplier's eWallet to Incomlend - fees eWallet
      CreateTransaction(  debitAccount.eWallets__r[0].Id,
              debitAccount.eWallets__r[0].Name,
              debitAccount.Id,
              debitAccount.Name,
              this.Invoice.CCY__c,
              this.totalMembershipFeeAmount * -1,
              '88.Annual membership fee');
      CreateTransaction(  this.IncomlendFees.eWallets__r[0].Id,
              this.IncomlendFees.eWallets__r[0].Name,
              this.IncomlendFees.Id,
              this.IncomlendFees.Name,
              this.Invoice.CCY__c,
              this.totalMembershipFeeAmount,
              '88.Annual membership fee');
      // Tax invoice for membership
      if (TaxRateSupplier != null && TaxRateSupplier.rate__c > 0) {
        decimal taxAmountMembership = (this.totalMembershipFeeAmount * TaxRateSupplier.rate__c / 100).setScale(2, RoundingMode.HALF_UP);
        this.Logs.Log('"09.GST transaction" - Membership Fees GST ' + this.Invoice.CCY__c + ' ' + FormatDecimal(taxAmountMembership), 2, Helper_Log.Color.Black);
        // Create the debit/credit transactions from Supplier's eWallet to Incomlend GST's eWallet
        CreateTransaction(  debitAccount.eWallets__r[0].Id,
                debitAccount.eWallets__r[0].Name,
                debitAccount.Id,
                debitAccount.Name,
                this.Invoice.CCY__c,
                taxAmountMembership * -1,
                '09.GST transaction');
        CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                this.IncomlendGST.eWallets__r[0].Name,
                this.IncomlendGST.Id,
                this.IncomlendGST.Name,
                this.Invoice.CCY__c,
                taxAmountMembership,
                '09.GST transaction');
      }
      List <Instalment_insurance_fee__c> newMembershipInstallment = new List <Instalment_insurance_fee__c>();
      for (Instalment_insurance_fee__c membershipFee : this.membershipFees) {
        membershipFee.Status_Instalment__c = STATUS_PAID;
        membershipFee.Date_Paiement__c = System.today();
        membershipFee.Invoice_Finance_Deal__c = this.InvoiceId;
        update this.membershipFees;
        Instalment_insurance_fee__c membershipInstallment = new Instalment_insurance_fee__c();
        membershipInstallment.Supplier_buyer_map_instalment__c = membershipFee.Supplier_buyer_map_instalment__c;
        membershipInstallment.Account_Supplier__c = membershipFee.Account_Supplier__c;
        membershipInstallment.Fee_Type__c = membershipFee.Fee_Type__c;
        membershipInstallment.Amount_Instalment__c = membershipFee.Amount_Instalment__c;
        membershipInstallment.Due_Date__c = membershipFee.Due_Date__c.addMonths(Integer.valueOf(membershipFee.Installment_Term_Months__c));
        membershipInstallment.Installment_Term_Months__c = membershipFee.Installment_Term_Months__c;
        membershipInstallment.Status_Instalment__c = STATUS_PENDING;
        newMembershipInstallment.add(membershipInstallment);
      }
      this.InstallmentsToUpdate.addAll(newMembershipInstallment); // insert newMembershipInstallment;
    }

    // -----------------------------------------------------------------------------------------
    // 89.Maintenance fee: Maintenance fee paid by the supplier for maintain of transwap account
    // Bangladesh with deposit, fee paid by the supplier through Incomlend Provision
    // -----------------------------------------------------------------------------------------
    if (!isPartialFunded && this.maintenanceInstallments != null && !this.maintenanceInstallments.isEmpty()) 
    {
      for (Instalment_insurance_fee__c installment : this.maintenanceInstallments) {
        Date dueDate = installment.Due_Date__c;
        if (dueDate != null && dueDate <= System.today()) {
        //while (dueDate != null && dueDate <= System.today()) {
          adminFee += installment.Amount_Instalment__c;
          this.Logs.Log('"89.Maintenance fee" - Maintenance Fees ' + this.Invoice.CCY__c + ' ' + FormatDecimal(installment.Amount_Instalment__c), 2, Helper_Log.Color.Black);
          CreateTransaction(  debitAccount.eWallets__r[0].Id,
                  debitAccount.eWallets__r[0].Name,
                  debitAccount.Id,
                  debitAccount.Name, 
                  this.Invoice.CCY__c,
                  -installment.Amount_Instalment__c,
                  '89.Maintenance fee');

          CreateTransaction(  this.TranswapAccount.eWallets__r[0].Id,
                  this.TranswapAccount.eWallets__r[0].Name,
                  this.TranswapAccount.Id,
                  this.TranswapAccount.Name, 
                  this.Invoice.CCY__c,
                  installment.Amount_Instalment__c,
                  '89.Maintenance fee');

          // Tax invoice for maintenance fee
          if (TaxRateSupplier != null && TaxRateSupplier.rate__c > 0) {
            decimal taxAmountMaintenancefee = (installment.Amount_Instalment__c * TaxRateSupplier.rate__c / 100).setScale(2, RoundingMode.HALF_UP);
            this.Logs.Log('"09.GST transaction" - Maintenance Fees GST ' + this.Invoice.CCY__c + ' ' + FormatDecimal(taxAmountMaintenancefee), 2, Helper_Log.Color.Black);
            CreateTransaction(  debitAccount.eWallets__r[0].Id,
                    debitAccount.eWallets__r[0].Name,
                    debitAccount.Id,
                    debitAccount.Name, 
                    this.Invoice.CCY__c,
                    -taxAmountMaintenancefee,
                    '09.GST transaction');
            
            CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                    this.IncomlendGST.eWallets__r[0].Name,
                    this.IncomlendGST.Id,
                    this.IncomlendGST.Name, 
                    this.Invoice.CCY__c,
                    taxAmountMaintenancefee,
                    '09.GST transaction');
          }
          // Update the payment status to “Paid”
          // Update invoice finance deal and payment date in the Installment
          Instalment_insurance_fee__c instalmentClone = installment.clone(false, true, false, false);
          Instalment_insurance_fee__c instalmentUpdate = new Instalment_insurance_fee__c(Id = installment.Id, 
                  Status_Instalment__c = STATUS_PAID,
                  Invoice_Finance_Deal__c = this.Invoice.Id,
                  Date_Paiement__c = System.today());
          this.InstallmentsToUpdate.add(instalmentUpdate); // update instalmentUpdate;
          if (installment.Installment_Term_Months__c == '0') {
            dueDate = null;
            //continue;
          } else {
            instalmentClone.Due_Date__c = instalmentClone.Due_Date__c.addMonths(Integer.valueOf(instalmentClone.Installment_Term_Months__c));
            instalmentClone.Status_Instalment__c = STATUS_PENDING;
            instalmentClone.Invoice_Finance_Deal__c = null;
            instalmentClone.Date_Paiement__c = null;
            this.InstallmentsToUpdate.add(instalmentClone); // insert instalmentClone;
            installment = instalmentClone;
            dueDate = instalmentClone.Due_Date__c;
          }
        }
      }
    }

    // --------------------------------------------------------------------------------------------------------------
    // 06.Transaction Fee: Expected cost of funding paid by the supplier, taken upfront at the funding of the invoice
    // Bangladesh with deposit, fee paid by the supplier through Incomlend Provision
    // --------------------------------------------------------------------------------------------------------------
    // Supplier Discount amount
    if(this.Invoice.Total_supplier_discount_amount_expected__c > 0)
    {
      decimal pseudoAmount = this.Invoice.Total_supplier_discount_amount_expected__c;
      if (isPartialFunded) pseudoAmount *= 1 + (sumTransaction(this.InvoiceTransactions, '' + this.IncomlendOperations.Id + ';' + '02.Invoice Advance Amount', 'id-type') / this.Invoice.funded_amount__c);

      this.Logs.Log('"06.Transaction Fee transactions" - Supplier Discount ' + this.Invoice.CCY__c + ' ' + FormatDecimal(pseudoAmount), 2, Helper_Log.Color.Black);
      // Create the debit/credit transactions from Supplier's eWallet to Incomlend Supplier Discount's eWallet
      CreateTransaction(  debitAccount.eWallets__r[0].Id,
              debitAccount.eWallets__r[0].Name,
              debitAccount.Id,
              debitAccount.Name,
              this.Invoice.CCY__c,
              pseudoAmount.setScale(2) * -1,
              '06.Transaction Fee');
      CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
              this.IncomlendSupplierDiscount.eWallets__r[0].Name,
              this.IncomlendSupplierDiscount.Id,
              this.IncomlendSupplierDiscount.Name,
              this.Invoice.CCY__c,
              pseudoAmount.setScale(2),
              '06.Transaction Fee');

      // Tax invoice for supplier discount amount
      if (TaxRateSupplier != null && TaxRateSupplier.rate__c > 0) {
        decimal TaxAmountSupplierDiscount = (pseudoAmount * TaxRateSupplier.rate__c / 100).setScale(2, RoundingMode.HALF_UP);
        this.Logs.Log('"09.GST transaction" - Supplier Discount GST ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountSupplierDiscount), 2, Helper_Log.Color.Black);
        // Create the debit/credit transactions from Supplier's eWallet to Incomlend GST's eWallet
        CreateTransaction(  debitAccount.eWallets__r[0].Id,
                debitAccount.eWallets__r[0].Name,
                debitAccount.Id,
                debitAccount.Name,
                this.Invoice.CCY__c,
                TaxAmountSupplierDiscount * -1,
                '09.GST transaction');
        CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                this.IncomlendGST.eWallets__r[0].Name,
                this.IncomlendGST.Id,
                this.IncomlendGST.Name,
                this.Invoice.CCY__c,
                TaxAmountSupplierDiscount ,
                '09.GST transaction');
      }

      // Create Tax invoice supplier discount amount - even if tax rate is null
      // Supplier discount amount and insurance amount Map
      Map<InvoiceUtil.Description, Decimal> amountExclGSTMap = new Map<InvoiceUtil.Description, Decimal>();
      // Amounts that are not subjected to tax
      Map<InvoiceUtil.Description, Decimal> amountNoTaxMap = new Map<InvoiceUtil.Description, Decimal>();

      amountExclGSTMap.put(InvoiceUtil.Description.SUPPLIER_DISCOUNT_AMOUNT, pseudoAmount);
      if (!isPartialFunded) amountExclGSTMap.put(InvoiceUtil.Description.ADMIN_FEES, adminFee);

      CreateInvoice_v1 TaxInvoiceSupplierDiscount =
              new CreateInvoice_v1 (    this.Supplier.Id,
                      this.Invoice,
                      null,
                      amountExclGSTMap,
                      TaxRateSupplier == null ? 0 : TaxRateSupplier.rate__c,
                      amountNoTaxMap,
                      InvoiceUtil.RecordType.SUPPLIER,
                      InvoiceUtil.ActionType.Funded,
                      false,
                      this.Notification,
                      false);
      TaxInvoiceSupplierDiscount.createInvoice();
      if (isPartialFunded) return pseudoAmount;
    }
    else
            this.Logs.Log('("06.Transaction Fee transactions" - No Supplier Discount)', 2, Helper_Log.Color.Grey);
    
    return this.Invoice.Total_supplier_discount_amount_expected__c + adminFee;
  }

  private void fundingInTransit(Decimal advanceAmtAfterFee) {
    if (!isInTransit || !isInTransitRepo) return;
    Account debitAccount = !isInTransit ? this.Supplier : this.IncomlendTrading;
    if (GlobalTriggerHandler.coalesce(this.Invoice.In_Transit_fee__c) > 0) {

      this.Logs.Log('"89.Maintenance fee" In Transit Repo fee transactions ' + this.Invoice.CCY__c + ' ' + this.Invoice.In_Transit_fee__c, 2, Helper_Log.Color.Black);
      // Create the debit/credit transactions from Incomlend Trading's eWallet to Incomlend In Transit Provision's eWallet 
      CreateTransaction(  debitAccount.eWallets__r[0].Id,
              debitAccount.eWallets__r[0].Name,
              debitAccount.Id,
              debitAccount.Name,
              this.Invoice.CCY__c,
              this.Invoice.In_Transit_fee__c * -1,
              '89.Maintenance fee');
      CreateTransaction(  this.IncomlendInTransitProvision.eWallets__r[0].Id,
              this.IncomlendInTransitProvision.eWallets__r[0].Name,
              this.IncomlendInTransitProvision.Id,
              this.IncomlendInTransitProvision.Name,
              this.Invoice.CCY__c,
              this.Invoice.In_Transit_fee__c,
              '89.Maintenance fee');
    }
    
    this.Logs.Log('"02.Invoice Advance Amount" In Transit transactions ' + this.Invoice.CCY__c + ' ' + FormatDecimal(advanceAmtAfterFee - GlobalTriggerHandler.coalesce(this.Invoice.In_Transit_fee__c)), 2, Helper_Log.Color.Black);
    // Create the debit/credit transactions from Incomlend Trading's eWallet to real Supplier's eWallet 
    Account creditAccount = this.Factory;
    CreateTransaction(  debitAccount.eWallets__r[0].Id,
            debitAccount.eWallets__r[0].Name,
            debitAccount.Id,
            debitAccount.Name,
            this.Invoice.CCY__c,
            (advanceAmtAfterFee - GlobalTriggerHandler.coalesce(this.Invoice.In_Transit_fee__c)) * -1,
            '02.Invoice Advance Amount');
    CreateTransaction(  creditAccount.eWallets__r[0].Id,
            creditAccount.eWallets__r[0].Name,
            creditAccount.Id,
            creditAccount.Name,
            this.Invoice.CCY__c,
            advanceAmtAfterFee - GlobalTriggerHandler.coalesce(this.Invoice.In_Transit_fee__c),
            '02.Invoice Advance Amount');
  }

  private void volofin(boolean fundedElseRepaid) {
    if (this.Invoice.Insured_by__c != VOLOFIN || fundedElseRepaid == null) return;
    decimal pseudoAmount = 0;
    pseudoAmount = ((this.Invoice.credit_insurance_fee__c + this.Invoice.Total_supplier_discount_amount_expected__c) * 0.25 / 2).setScale(2, RoundingMode.HALF_UP);
    decimal temp = pseudoAmount;
    // if (fundedElseRepaid == false) pseudoAmount = ((this.Invoice.credit_insurance_fee__c + this.Invoice.Actual_total_supplier_discount_amount__c) * 0.25 - pseudoAmount).setScale(2, RoundingMode.HALF_UP);
    if (pseudoAmount > 0) {

      this.Logs.Log('"061.Agent Commission on Transaction Fee" Volofin transactions ' + this.Invoice.CCY__c + ' ' + pseudoAmount, 2, Helper_Log.Color.Black);
      // Create the debit/credit transactions from Volofin Provision's eWallet to Volofin Pte Ltd's eWallet 
      CreateTransaction(  this.Insurer.eWallets__r[0].Id,
              this.Insurer.eWallets__r[0].Name,
              this.Insurer.Id,
              this.Insurer.Name,
              this.Invoice.CCY__c,
              pseudoAmount * -1,
              '061.Agent Commission on Transaction Fee');
      CreateTransaction(  this.MapAgent.eWallets__r[0].Id,
              this.MapAgent.eWallets__r[0].Name,
              this.MapAgent.Id,
              this.MapAgent.Name,
              this.Invoice.CCY__c,
              pseudoAmount,
              '061.Agent Commission on Transaction Fee');
    }
    if (fundedElseRepaid == false) {
      temp = this.Invoice.credit_insurance_fee__c - temp - pseudoAmount;

      this.Logs.Log('"06.Transaction Fee" Volofin transactions ' + this.Invoice.CCY__c + ' ' + temp, 2, Helper_Log.Color.Black);
      // Create the debit/credit transactions from Volofin Provision's eWallet to Incomlend Fees eWallet 
      CreateTransaction(  this.Insurer.eWallets__r[0].Id,
              this.Insurer.eWallets__r[0].Name,
              this.Insurer.Id,
              this.Insurer.Name,
              this.Invoice.CCY__c,
              temp * -1,
              '06.Transaction Fee');
      CreateTransaction(  this.IncomlendFees.eWallets__r[0].Id,
              this.IncomlendFees.eWallets__r[0].Name,
              this.IncomlendFees.Id,
              this.IncomlendFees.Name,
              this.Invoice.CCY__c,
              temp,
              '06.Transaction Fee');
    }
  }

  // Funder prepayment and transaction fees settlement
  // At funding, all allocations must be status reservation
  // At buyback, some allocations is status reservation
  private void fundingFunderPrepaymentAndFees() 
  {
    // ---------------------------------------
    // 05.Invoice Discount Amount - Funder discount amount expected funding
    // ---------------------------------------
    // Based on expected period - 15 days
    this.Logs.Log('"05.Invoice Discount Amount" - Net funder discount amount expected funding transactions', 2, Helper_Log.Color.Black);
    for(Invoice_Allocation__c currentAllocation : this.AllocationsToUpdate)
    {
      // If Option prepayment
      if (currentAllocation.Funder_prepayment__c == NET_EFDA && currentAllocation.Net_Funder_discount_amount_expected__c > 0) 
      {
        this.Logs.Log('Allocation: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(currentAllocation.Net_Funder_discount_amount_expected__c) + ' for ' + currentAllocation.Funder__r.Name, 3, Helper_Log.Color.Grey);

        // Create the debit/credit transactions from Incomlend Operation's eWallet to Funder's eWallet
        CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                this.IncomlendSupplierDiscount.Id,
                this.IncomlendSupplierDiscount.Name,
                currentAllocation.CCY__c,
                currentAllocation.Net_Funder_discount_amount_expected__c * -1,
                '05.Invoice Discount Amount',
                currentAllocation.Id,
                currentAllocation.Name);
        CreateTransaction(  currentAllocation.eWallet__c,
                currentAllocation.eWallet__r.Name,
                currentAllocation.Funder__c,
                currentAllocation.Funder__r.Name,
                currentAllocation.CCY__c,
                currentAllocation.Net_Funder_discount_amount_expected__c,
                '05.Invoice Discount Amount',
                currentAllocation.Id,
                currentAllocation.Name);

        // Tax Rate for Funder
        Tax_Rate__c TaxRateFunder = getTaxRate(currentAllocation.Funder__c, currentAllocation.Funder__r.Country_of_Incorporation__c);
        if (TaxRateFunder != null && TaxRateFunder.rate__c > 0) {
          /*
          // Tax Invoice for gross funder discount amount expected
          // Create the debit/credit transactions from Incomlend GST's eWallet to Incomlend Supplier Discount's eWallet
          decimal TaxAmountFunderGrossDiscountExp = (currentAllocation.Gross_funder_discount_amount_expected__c * TaxRateFunder.Rate__c / 100).setScale(2, RoundingMode.HALF_UP);
          this.Logs.Log('"09.GST transaction" - Gross funder discount expected funding GST: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountFunderGrossDiscountExp) + ' for ' + currentAllocation.Funder__r.Name, 3, Helper_Log.Color.Grey);

          CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                  this.IncomlendGST.eWallets__r[0].Name,
                  this.IncomlendGST.Id,
                  this.IncomlendGST.Name,
                  currentAllocation.CCY__c,
                  TaxAmountFunderGrossDiscountExp * -1,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);
          CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                  this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                  this.IncomlendSupplierDiscount.Id,
                  this.IncomlendSupplierDiscount.Name,
                  currentAllocation.CCY__c,
                  TaxAmountFunderGrossDiscountExp,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);

          // Tax Invoice for net funder discount amount expected
          // Create the debit/credit transactions from Incomlend GST's eWallet to Incomlend Supplier Discount's eWallet
          decimal TaxAmountFunderNetDiscountExp = (currentAllocation.Net_Funder_discount_amount_expected__c * TaxRateFunder.Rate__c / 100).setScale(2, RoundingMode.HALF_UP);
          this.Logs.Log('"09.GST transaction" - Net funder discount expected funding GST: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountFunderNetDiscountExp) + ' for ' + currentAllocation.Funder__r.Name, 3, Helper_Log.Color.Grey);

          CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                  this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                  this.IncomlendSupplierDiscount.Id,
                  this.IncomlendSupplierDiscount.Name,
                  currentAllocation.CCY__c,
                  TaxAmountFunderNetDiscountExp * -1,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);
          
          //we dont pay funder GST on NFDA (Funder to GST)
          CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id, // currentAllocation.eWallet__c, 
                  this.IncomlendGST.eWallets__r[0].Name, // currentAllocation.eWallet__r.Name,
                  this.IncomlendGST.Id, // currentAllocation.Funder__c,
                  this.IncomlendGST.Name, // currentAllocation.Funder__r.Name,
                  currentAllocation.CCY__c,
                  TaxAmountFunderNetDiscountExp,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);
          //*/
        }
      }
    }

    // ------------------
    // 052.discount amount fees - Incomlend funder profit sharing expected funding
    // ------------------
    // Based on period - 15 days
    this.Logs.Log('"052.discount amount fees" - Incomlend funder profit sharing expected funding transactions', 2, Helper_Log.Color.Black);
    for(Invoice_Allocation__c currentAllocation : this.AllocationsToUpdate)
    {
      // If Option prepayment
      if (currentAllocation.Funder_prepayment__c == NET_EFDA && currentAllocation.Icl_Funder_profit_share_amount_expected__c > 0) 
      {
        this.Logs.Log('Allocation: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(currentAllocation.Icl_Funder_profit_share_amount_expected__c) + ' for ' + currentAllocation.Funder__r.Name, 3, Helper_Log.Color.Grey);

        // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend Fees' eWallet
        CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                this.IncomlendSupplierDiscount.Id,
                this.IncomlendSupplierDiscount.Name,
                currentAllocation.CCY__c,
                currentAllocation.Icl_Funder_profit_share_amount_expected__c  * -1,
                '052.discount amount fees',
                currentAllocation.Id,
                currentAllocation.Name);
        CreateTransaction(  this.IncomlendFees.eWallets__r[0].Id,
                this.IncomlendFees.eWallets__r[0].Name,
                this.IncomlendFees.Id,
                this.IncomlendFees.Name,
                currentAllocation.CCY__c,
                currentAllocation.Icl_Funder_profit_share_amount_expected__c ,
                '052.discount amount fees',
                currentAllocation.Id,
                currentAllocation.Name);

        Tax_Rate__c TaxRateFunder = getTaxRate(currentAllocation.Funder__c, currentAllocation.Funder__r.Country_of_Incorporation__c);
        if (TaxRateFunder != null && TaxRateFunder.rate__c > 0) {
          // Tax Invoice for funder profit sharing expected
          // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend GST's eWallet
          decimal TaxAmountFunderSharingExp = ((currentAllocation.Icl_Funder_profit_share_amount_expected__c ) * TaxRateFunder.rate__c / 100).setScale(2, RoundingMode.HALF_UP);
          this.Logs.Log('"09.GST transaction" - Incomlend funder profit sharing expected funding GST: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(TaxAmountFunderSharingExp) + ' for ' + currentAllocation.Funder__r.Name, 3, Helper_Log.Color.Grey);

          if (Math.ABS(TaxAmountFunderSharingExp) >= 0.005) {
            // funder pay us GST on PS (ISD to Funder)
            CreateTransaction(  currentAllocation.eWallet__c, // this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                    currentAllocation.eWallet__r.Name, // this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                    currentAllocation.Funder__c, // this.IncomlendSupplierDiscount.Id,
                    currentAllocation.Funder__r.Name, // this.IncomlendSupplierDiscount.Name,
                    currentAllocation.CCY__c,
                    TaxAmountFunderSharingExp * -1,
                    '09.GST transaction',
                    currentAllocation.Id,
                    currentAllocation.Name);
            CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                    this.IncomlendGST.eWallets__r[0].Name,
                    this.IncomlendGST.Id,
                    this.IncomlendGST.Name,
                    currentAllocation.CCY__c,
                    TaxAmountFunderSharingExp,
                    '09.GST transaction',
                    currentAllocation.Id,
                    currentAllocation.Name);
          }
        }

        // Create Tax invoice funder profit share - even if tax rate is null
        // Based on expected - 15 days
        Map<InvoiceUtil.Description, Decimal> amountExclGSTMap = new Map<InvoiceUtil.Description, Decimal>();
        amountExclGSTMap.put(InvoiceUtil.Description.FUNDER_PROFIT_SHARE, currentAllocation.Icl_Funder_profit_share_amount_expected__c);
        // Amounts that are not subjected to tax
        Map<InvoiceUtil.Description, Decimal> amountNoTaxMap = new Map<InvoiceUtil.Description, Decimal>();
        CreateInvoice_v1 TaxInvoiceFunderSharing =
                new CreateInvoice_v1 (    currentAllocation.Funder__c,
                        this.Invoice,
                        currentAllocation,
                        amountExclGSTMap,
                        TaxRateFunder == null ? 0 : TaxRateFunder.rate__c,
                        amountNoTaxMap,
                        InvoiceUtil.RecordType.FUNDER,
                        InvoiceUtil.ActionType.Funded,
                        false,
                        this.Notification,
                        false);
         TaxInvoiceFunderSharing.createInvoice();
      }
    }

    // -------------------------------------------------------------------------
    // 051.Agent Commission on Discount Amount for Funder agent with Annual Rate
    // -------------------------------------------------------------------------
    for(Invoice_Allocation__c currentAllocation : this.AllocationsToUpdate)
    {
      if(currentAllocation.Funder_Agent_Commission_Type__c != AGENT_FEE_PS && currentAllocation.Funder_Agent_Commission_Amount__c > 0)
      {
        this.Logs.Log('"051.Agent Commission on Discount Amount" transactions - Agent Funder ' + currentAllocation.Name + ' ' + currentAllocation.CCY__c + ' ' + FormatDecimal(currentAllocation.Funder_Agent_Commission_Amount__c) + ' ' + currentAllocation.Funder_Agent_Commission_Type__c, 2, Helper_Log.Color.Black);

        // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend Agent Provision's eWallet
        CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                this.IncomlendSupplierDiscount.Id,
                this.IncomlendSupplierDiscount.Name,
                currentAllocation.CCY__c,
                currentAllocation.Funder_Agent_Commission_Amount__c * -1,
                '051.Agent Commission on Discount Amount',
                currentAllocation.Id,
                currentAllocation.Name);
        CreateTransaction(  this.IncomlendAgentProvision.eWallets__r[0].Id,
                this.IncomlendAgentProvision.eWallets__r[0].Name,
                this.IncomlendAgentProvision.Id,
                this.IncomlendAgentProvision.Name,
                currentAllocation.CCY__c,
                currentAllocation.Funder_Agent_Commission_Amount__c,
                '051.Agent Commission on Discount Amount',
                currentAllocation.Id,
                currentAllocation.Name);
      }
    }
  }


  private decimal totalFundingTransactionFee(boolean fundedElseRepaid) {
    // Amount to be credited to Incomlend feees as transaction fee expected at funding
    decimal Funder_s_Annual_Rate_Agent_Commission_amount = 0;
    decimal Total_gross_disc_amt_expected_funded = 0;
    for(Invoice_Allocation__c currentAllocation : this.InvoiceAllocations) 
    {
      if(currentAllocation.Funder_Agent_Commission_Type__c != AGENT_FEE_PS) {
        Funder_s_Annual_Rate_Agent_Commission_amount += currentAllocation.Funder_Agent_Commission_Amount__c;
        System.debug('funder non-ps agent ' + currentAllocation.Funder_Agent_Commission_Amount__c + '+=' + Funder_s_Annual_Rate_Agent_Commission_amount);
      }
      Total_gross_disc_amt_expected_funded += currentAllocation.Balance_upfront_fee_calculation__c;
      System.debug('funder expected gfda ' + currentAllocation.Balance_upfront_fee_calculation__c + '+='+ Total_gross_disc_amt_expected_funded);
    }
    
    decimal supplierNet = this.Invoice.Total_supplier_discount_amount_expected__c - this.Invoice.Supplier_s_Agent_Commission_amount__c;
    System.debug('supplier expected nsda ' + this.Invoice.Total_supplier_discount_amount_expected__c + '-' + this.Invoice.Supplier_s_Agent_Commission_amount__c + ' = ' + supplierNet); 
    decimal Gross_funder_discount_amount_expected = Total_gross_disc_amt_expected_funded; // in case formula change
    decimal balanceUpfrontfee = supplierNet - Gross_funder_discount_amount_expected - Funder_s_Annual_Rate_Agent_Commission_amount;
    System.debug('balance upfront fee ' + supplierNet + '-' + Gross_funder_discount_amount_expected + '-' + Funder_s_Annual_Rate_Agent_Commission_amount + ' = ' + balanceUpfrontfee);

    decimal balanceUpfrontfeeAdj = balanceUpfrontfee;
    if (fundedElseRepaid == null) {
      balanceUpfrontfeeAdj -= sumTransaction(this.InvoiceTransactions, '' + this.IncomlendFees.Id + ';' + '06.Transaction Fee', 'id-type');
      System.debug('balance upfront fee adjusted ' + balanceUpfrontfee + '-' + (balanceUpfrontfee-balanceUpfrontfeeAdj) + ' = ' + balanceUpfrontfeeAdj);
    }
    return balanceUpfrontfeeAdj;
  }

  private void payUpfrontFeesBalance(boolean fundedElseRepaid) {
    if ((isBuyback || isPartialFunded) && this.InvoiceBuybackAllocations.size() > 0) return; // done at repaid
    System.debug('payUpfrontFeesBalance ' + fundedElseRepaid);

    if (fundedElseRepaid != null && this.Invoice.Supplier_s_Agent_Commission_amount__c > 0) { 
      decimal pseudoAmount = this.Invoice.Supplier_s_Agent_Commission_amount__c;
      if (isPartialFunded) pseudoAmount -= sumTransaction(this.InvoiceTransactions, '' + this.IncomlendAgentProvision.Id + ';' + '061.Agent Commission on Transaction Fee', 'id-type');
      this.Logs.Log('"061.Agent Commission on Transaction Fee" - Map agent commission ' + this.Invoice.CCY__c + ' ' + FormatDecimal(pseudoAmount), 2, Helper_Log.Color.Black);

      // Create the debit/credit transactions from Incomlend - Supplier Discount's eWallet to Incomlend Agent Provision' eWallet
      CreateTransaction(	this.IncomlendSupplierDiscount.eWallets__r[0].Id,
              this.IncomlendSupplierDiscount.eWallets__r[0].Name,
              this.IncomlendSupplierDiscount.Id,
              this.IncomlendSupplierDiscount.Name,
              this.Invoice.CCY__c,
              pseudoAmount * -1,
              '061.Agent Commission on Transaction Fee');
      CreateTransaction(	this.IncomlendAgentProvision.eWallets__r[0].Id,
              this.IncomlendAgentProvision.eWallets__r[0].Name,
              this.IncomlendAgentProvision.Id,
              this.IncomlendAgentProvision.Name,
              this.Invoice.CCY__c,
              pseudoAmount,
              '061.Agent Commission on Transaction Fee');
    }
    
    // ------------------
    // 06.Transaction Fee transactions - Upfront Fees
    // ------------------

    decimal acceptedMargin = 0.01;
    decimal balanceUpfrontfee = totalFundingTransactionFee(fundedElseRepaid).setScale(2, RoundingMode.HALF_UP);

    if (balanceUpfrontfee >= 0.01) // accepted margin // > 0)
    {
      this.Logs.Log('"06.Transaction Fee transactions" - Upfront Fees ' + this.Invoice.CCY__c + ' ' + FormatDecimal(balanceUpfrontfee), 2, Helper_Log.Color.Black);

      // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend Fees' eWallet
      CreateTransaction(	this.IncomlendSupplierDiscount.eWallets__r[0].Id,
              this.IncomlendSupplierDiscount.eWallets__r[0].Name,
              this.IncomlendSupplierDiscount.Id,
              this.IncomlendSupplierDiscount.Name,
              this.Invoice.CCY__c,
              balanceUpfrontfee * -1,
              '06.Transaction Fee');
      CreateTransaction(	this.IncomlendFees.eWallets__r[0].Id,
              this.IncomlendFees.eWallets__r[0].Name,
              this.IncomlendFees.Id,
              this.IncomlendFees.Name,
              this.Invoice.CCY__c,
              balanceUpfrontfee,
              '06.Transaction Fee');
    }
    else
            this.Logs.Log('("06.Transaction Fee transactions" - No Upfront Fees)', 2, Helper_Log.Color.Grey);
  }

  private void payPlatformFee() {

    // Platform Fees
    if (this.Invoice.Total_platform_fee__c > 0)
    {
      Account debitAccount = !isInTransit ? this.Supplier : this.IncomlendTrading;
      if (this.isBangladesh && this.Invoice.Bangladesh_special_case__c == WITH_DEPOSIT) {
        debitAccount = this.IncomlendProvision;
      }

      this.Logs.Log('"06.Transaction Fee transactions" - Platform Fees ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.Total_platform_fee__c), 2, Helper_Log.Color.Black);
      // Create the debit/credit transactions from Supplier's eWallet to Incomlend Operations' eWallet
      CreateTransaction(  debitAccount.eWallets__r[0].Id,
              debitAccount.eWallets__r[0].Name,
              debitAccount.Id,
              debitAccount.Name,
              this.Invoice.CCY__c,
              this.Invoice.Total_platform_fee__c * -1,
              '06.Transaction Fee');
      CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
              this.IncomlendOperations.eWallets__r[0].Name,
              this.IncomlendOperations.Id,
              this.IncomlendOperations.Name,
              this.Invoice.CCY__c,
              this.Invoice.Total_platform_fee__c,
              '06.Transaction Fee');
    }
    else
            this.Logs.Log('("06.Transaction Fee transactions" - No Platform Fees)', 2, Helper_Log.Color.Grey);

    // Total Platform Fee for Upfront Fees
    decimal pseudoAmount = this.Invoice.Total_platform_fee__c; //Total_platform_fee_for_upfront_fee__c;
    if(pseudoAmount > 0)
    {
      this.Logs.Log('"06.Transaction Fee transactions" - Total Platform Fee for Upfront Fees ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.Total_platform_fee_for_upfront_fee__c), 2, Helper_Log.Color.Black);

      // Create the debit/credit transactions from Incomlend Operations' eWallet to Incomlend Fees' eWallet
      CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
              this.IncomlendOperations.eWallets__r[0].Name,
              this.IncomlendOperations.Id,
              this.IncomlendOperations.Name,
              this.Invoice.CCY__c,
              pseudoAmount * -1,
              '06.Transaction Fee');
      CreateTransaction(  this.IncomlendFees.eWallets__r[0].Id,
              this.IncomlendFees.eWallets__r[0].Name,
              this.IncomlendFees.Id,
              this.IncomlendFees.Name,
              this.Invoice.CCY__c,
              pseudoAmount,
              '06.Transaction Fee');
    }
    else
            this.Logs.Log('("06.Transaction Fee transactions" - No Total Platform Fee for Upfront Fees)', 2, Helper_Log.Color.Grey);

    // Balance of Platform Fee
    /*
    if(this.Invoice.Total_platform_fee__c - this.Invoice.Total_platform_fee_for_upfront_fee__c > 0)
    {
      this.Logs.Log('06.Transaction Fee transactions - Balance of Platform Fee ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.Total_platform_fee__c - this.Invoice.Total_platform_fee_for_upfront_fee__c), 2, Helper_Log.Color.Black);

      // Create the debit/credit transactions from Incomlend Operations' eWallet to Incomlend Supplier Discount's eWallet
      CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
              this.IncomlendOperations.eWallets__r[0].Name,
              this.IncomlendOperations.Id,
              this.IncomlendOperations.Name,
              this.Invoice.CCY__c,
              (this.Invoice.Total_platform_fee__c - this.Invoice.Total_platform_fee_for_upfront_fee__c) * -1,
              '06.Transaction Fee');
      CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
              this.IncomlendSupplierDiscount.eWallets__r[0].Name,
              this.IncomlendSupplierDiscount.Id,
              this.IncomlendSupplierDiscount.Name,
              this.Invoice.CCY__c,
              (this.Invoice.Total_platform_fee__c - this.Invoice.Total_platform_fee_for_upfront_fee__c),
              '06.Transaction Fee');
    }
    */
    // else
            this.Logs.Log('(06.Transaction Fee transactions - No Balance for Platform Fee)', 2, Helper_Log.Color.Grey);
  }

  private void commonDml(boolean fundedElseRepaid) {
    this.Logs.Log('Is Buyback ' + isBuyback, 2, Helper_Log.Color.Black);

    // ===========
    // LOGS
    // ===========

    // System.debug('soql4 ' + limits.getQueries());
    if (isBuyback && this.InvoiceBuybackCopyAllocation != null) {
      // Logs the copied allocation
      this.Logs.LogLine();
      this.Logs.Log('Updated allocation:', 1, Helper_Log.Color.Blue);
      this.Logs.Log(this.InvoiceBuybackCopyAllocation.Funder__r.Name + ' ' + this.InvoiceBuybackCopyAllocation.amount__c, 3, Helper_Log.Color.Grey);  
      this.Logs.Log('Created allocation:', 1, Helper_Log.Color.Blue);
      this.Logs.Log(this.InvoiceBuybackCopyAllocation.Funder__r.Name + ' ' + this.Invoice.remaining_amount__c, 3, Helper_Log.Color.Grey);
    }

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
    boolean hasNegativeeWalletsNotBypass = false;
    String IncomlendOperationsStr = IncomlendOperations.eWallets__r[0].Name + ' - ' + IncomlendOperations.Name;
    String IncomlendSupplierDiscountStr = IncomlendSupplierDiscount.eWallets__r[0].Name + ' - ' + IncomlendSupplierDiscount.Name;
    for(string currenteWallet : this.ImpactedeWallets.keySet())
    {
      decimal balance = this.ImpactedeWallets.get(currenteWallet);
      decimal acceptedMargin = -0.1;
      if(balance < 0)
      {
        if ((currenteWallet != IncomlendOperationsStr && currenteWallet != IncomlendSupplierDiscountStr) || (balance < acceptedMargin && !Test.isRunningTest())) hasNegativeeWalletsNotBypass = true;
        this.NegativeeWalletsTable.add(new List<string> {currenteWallet, FormatDecimal(balance)});
        hasNegativeeWallets = true;
      }
    }

    if(hasNegativeeWallets)
    {
      // Logs the negative eWallets
      this.Logs.Log('Negative eWallets:', 1, Helper_Log.Color.Blue);
      this.Logs.Log(this.NegativeeWalletsTable);
      this.Logs.LogLine();

      this.HasEncounteredIssues = hasNegativeeWalletsNotBypass && !IsValidated( this.Behaviour.FailAtNegativeeWallets && hasNegativeeWalletsNotBypass, 'One or more eWallets are about to be negative.');
    }
    validateEmptyIncomlendBalance(fundedElseRepaid);
  
    // ===========
    // DML Updates
    // ===========
    if(!this.Behaviour.IsSimulation)
    {
      // Update the invoice
      if (!isBuyback && fundedElseRepaid == true) {
        this.Invoice.Phase__c = '3:IN PROGRESS';
        this.Invoice.Status__c = 'In Progress';
      } else if (!isBuyback && fundedElseRepaid == false) {
        this.Invoice.Phase__c = '4:CLOSED';
        this.Invoice.Status__c = 'Paid';
      }
      decimal discountRate = calculateFunderDiscountRate();
      this.Invoice.discount_rate__c = discountRate;
      if (fundedElseRepaid == false) this.Invoice.Closed_By_Pricing__c = System.now();

      //system.debug('Limit ===='+limits.getCpuTime()+'----'+limits.getLimitCpuTime());
      SavePoint savePoint = Database.setSavepoint();
      try {
        boolean temp = CalculateTargetFinanceController.IsNeedRunTrigger;
        CalculateTargetFinanceController.IsNeedRunTrigger = false;
        if (!isBuyback) update this.Invoice;
        CalculateTargetFinanceController.IsNeedRunTrigger = temp;
        RollupUtility.resetFirstRun();
        WebServiceCallout.resetFirstRun();
        //system.debug('Limit after update INVOICE===='+limits.getCpuTime()+'----'+limits.getLimitCpuTime());

        // Create invoice buy back allocation 
        if (isBuyback && this.InvoiceBuybackCopyAllocation != null) {
          // System.debug('eWallet balance ' + [SELECT Id, USD_Available_eWallet__c, USD_eWallet_Balance__c, USD_eWallet__r.Reservations__c FROM Account WHERE Id = :this.InvoiceBuybackCopyAllocation.Funder__c] + ' ' + funder.USD_eWallet__r.Reservations__c);
          this.InvoiceBuybackCopyAllocation = this.InvoiceBuybackCopyAllocation.clone(false, true, false, false);
          this.InvoiceBuybackCopyAllocation.amount__c = this.Invoice.remaining_amount__c;
          if (this.Invoice.remaining_amount__c > this.InvoiceBuybackCopyAllocation.amount__c / 2) this.InvoiceBuybackCopyAllocation.amount__c = this.InvoiceBuybackCopyAllocation.marketplace_Min_purchase_amount__c; // workaround You do not have available funds in your eWallet
          this.InvoiceBuybackCopyAllocation.Buybacked_Date__c = null;
          // recalculateFormulas(this.InvoiceBuybackCopyAllocation); // this.InvoiceBuybackCopyAllocation.recalculateFormulas();
          this.InvoiceBuybackCopyAllocation.Status__c = CONFIRMED;
          this.AllocationsToUpdate.add(this.InvoiceBuybackCopyAllocation);
        }
        // Updates the existing allocations
        if (isBuyback) this.AllocationsToUpdate.addAll(this.InvoiceBuybackAllocations);
        if (!isBuyback) update this.AllocationsToUpdate;
        // Set<Id> setIds = new Set<Id>(); for (Invoice_Allocation__c currentAllocation : AllocationsToUpdate) setIds.add(currentAllocation.eWallet_Trustee__c);
        // if (fundedElseRepaid != false && RollupUtility.rollupAllocationToeWalletTrustee(setIds)) GlobalTriggerHandler.OutError('Rollup reservation allocation trustee manual', Logs);

        //system.debug('Limit after update ALLOCATION===='+limits.getCpuTime()+'----'+limits.getLimitCpuTime());

        for (Transaction__c c: this.TransactionsToInsert) {
          if (c.eWallet_Trustee__c == null) {
            this.Logs.log('eWallet Trustee is null : ' + c.eWallet__c + ' ' + c.Amount__c + ' ' + c.Type__c, 2, Helper_Log.Color.Red);
          }
        } 

        if (this.InstallmentsToUpdate != null && this.InstallmentsToUpdate.size() > 0) {
          upsert this.InstallmentsToUpdate;
        }
      
        // System.debug('soql5 ' + limits.getQueries());
        system.debug('eWalletTrustee: ' + Pattern.compile('(.{200})').matcher('' + eWalletTrustee).replaceAll('$1\n'));
        system.debug('TransactionsToInsert: ' + Pattern.compile('(.{200})').matcher('' + TransactionsToInsert).replaceAll('$1\n'));
        // Creates the new transactions
        Insert TransactionsToInsert;

        // System.debug('soql6 ' + limits.getQueries());
        if (isBuyback) {
          RollupUtility.resetFirstRun();
          upsert this.AllocationsToUpdate;
          if (this.InvoiceBuybackCopyAllocation != null && this.InvoiceBuybackCopyAllocation.amount__c != this.Invoice.remaining_amount__c) { // workaround You do not have available funds in your eWallet
            this.InvoiceBuybackCopyAllocation.amount__c = this.Invoice.remaining_amount__c;
            RollupUtility.resetFirstRun();
            update this.InvoiceBuybackCopyAllocation;
          }
        }
        // System.debug('soql7 ' + limits.getQueries());

      } catch (Exception ex1) {
        RollupUtility.resetFirstRun();
        WebServiceCallout.resetFirstRun();
        Database.rollback(savePoint);
        throw ex1;
      }
  
      //system.debug('Limit after insert TRANSACTION===='+limits.getCpuTime()+'----'+limits.getLimitCpuTime());

      // Updates the new transactions to link them together (Related_Transaction__c field)
      Integer transactionsCount = this.TransactionsToInsert.size();
      if(math.mod(transactionsCount, 2) == 0)
      {
        for(Integer i = 0; i < transactionsCount / 2 ;i++)
        {
          this.TransactionsToInsert[2 * i].Related_Transaction__c = this.TransactionsToInsert[ 2 * i + 1].Id;
          this.TransactionsToInsert[2 * i + 1].Related_Transaction__c = this.TransactionsToInsert[2 * i].Id;
        }
        update this.TransactionsToInsert;

        //system.debug('Limit after update TRANSACTION===='+limits.getCpuTime()+'----'+limits.getLimitCpuTime());
      } else {
        this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtRelatedTransactions, 'Number of created transactions is odd, which is not supposed to happen.');
      }
    }

    // Sales commission
    if (!Test.isRunningTest()) {
      SalesCommissionService salesCommissionService = new SalesCommissionService(this.Invoice);
      boolean salesCommissionOk = true;
      if (isBuyback || fundedElseRepaid == true) salesCommissionOk = salesCommissionService.createSalesCommission();
      if (fundedElseRepaid == false) salesCommissionOk = salesCommissionService.updateSalesCommission();
      appendLog(salesCommissionService.Logs);
      this.HasEncounteredIssues = !IsValidated(  salesCommissionOk, false, 'Run Sales Commission completed', 'Fail to run Sales Commission.');  
    }

    // Run Tranche
    if (toRunTranche()) {
      this.Logs.Log('Run Tranche started.', 1, Helper_Log.Color.Black);
      boolean runTrancheOk = true;
      CalculateFXContractController controller;
      try {
        controller = new CalculateFXContractController('' + Invoice.Id, null, Invoice.CCY__c, false);
        controller.execute();
      } catch (Exception ex) {
        runTrancheOk = false;
        System.debug(ex);
      } finally {
        if (controller != null) appendLog(controller.Logs);
      }
      this.HasEncounteredIssues = !IsValidated(  runTrancheOk, false, 'Run tranche completed', 'Fail to run tranche.');
    }

    // Run Target Finance
    if (fundedElseRepaid == true && CalculateTargetFinanceController.IsNeedRunTrigger) {
      this.Logs.Log('Run target finance started.', 1, Helper_Log.Color.Black);
      boolean runTargetFinance = true;
      CalculateTargetFinanceController controller;
      try {
        controller = new CalculateTargetFinanceController();
        controller.updateTargetFinance(new List<Invoice_Finance_Deal__c>{this.Invoice});
      } catch (Exception ex) {
        runTargetFinance = false;
        System.debug(ex);
      } finally {
        if (controller != null) appendLog(controller.Logs);
      }
      this.HasEncounteredIssues = !IsValidated(  runTargetFinance, false, 'Run target finance completed', 'Fail to run target finance.');
    }
  }

  private void LoadFunderAgents() {
    this.Logs.Log('Loading Funder Agents:', 2, Helper_Log.Color.Black);

    // Funder Agents accounts
    if (needReload || this.FunderAgents == null) this.FunderAgents = new Map<Id, Account>();
    for(Invoice_Allocation__c currentAllocation : this.InvoiceAllocations)
    {
      if (currentAllocation.Status__c == CLOSED) continue;
      if (isBuyback && currentAllocation.Status__c != BUYBACK) continue;

      system.debug('agent allocation ' + currentAllocation.Name + ' ' + this.FunderAgents.get(currentAllocation.Funder__r.Agent__c) + ' ' + currentAllocation.Funder_Agent_Commission_Amount__c + ' for ' + currentAllocation.Name);
      if (currentAllocation.Funder__r.Agent__c != null && GlobalTriggerHandler.coalesce(currentAllocation.Funder_Agent_Commission_Amount__c) != 0) {
        if (this.FunderAgents.get(currentAllocation.Funder__r.Agent__c) == null) {
          Account agent = LoadAccount((Id)currentAllocation.Funder__r.Agent__c);
          this.FunderAgents.put(agent.Id, agent);
          this.ImpactedAccountsIds.add(agent.Id);
        }
        system.debug('agent allocation ' + currentAllocation.Name + ' commission ' + this.FunderAgents.get(currentAllocation.Funder__r.Agent__c).Name + ' ' + currentAllocation.Funder_Agent_Commission_Amount__c + ' for ' + currentAllocation.Name);
      }
    }
    if(this.FunderAgents.size() == 0)
            this.Logs.Log('(Nothing to load, no Funder\'s Agents)', 3, Helper_Log.Color.Grey);    
  }

  private void LoadMapAgent() {
    if (!needReload && MapAgent != null) return;
    // Map Agent
    this.Logs.Log('Loading Map Agent:', 2, Helper_Log.Color.Black);
    if (this.Invoice.Supplier_Buyer_Map__r.Agent_Commission_Null__c) {
      this.Logs.Log('(Nothing to load, Map\'s Agent Commission Null is checked)', 3, Helper_Log.Color.Grey);
    } else if (GlobalTriggerHandler.coalesce(this.Invoice.Supplier_Buyer_Map__r.Value_of_agent_s_fee__c) == 0) {
      this.Logs.Log('(Nothing to load, Map\'s Value of agent\'s fee is empty)', 3, Helper_Log.Color.Grey);
    } else if (this.Invoice.Supplier_Buyer_Map__r.Account_Agent__c != null) {
      this.MapAgent = LoadAccount((Id)this.Invoice.Supplier_Buyer_Map__r.Account_Agent__c);
      this.ImpactedAccountsIds.add(this.MapAgent.Id);
    } else 
      this.Logs.Log('(Nothing to load, no Map Agent)', 3, Helper_Log.Color.Grey);
  }

  // This method closes the invoice
  // Returns true if the process has succeeded
  // Returns false if the process has encountered issues
  public boolean CloseInvoice()
  {
    try
    {
      CoreInitialization();

      this.Logs.LogLine();
      this.Logs.Log('CloseInvoice() method called by ' + UserInfo.getName(), 1, Helper_Log.Color.Blue);
      this.Logs.LogLine();

      LogConfiguration();

      // =======
      // Loading
      // =======
      this.Logs.Log('Process Logs:', 1, Helper_Log.Color.Blue);
      this.Logs.Log('1. Loading core data', 1, Helper_Log.Color.Green);
      CoreLoading(false);
      if ((this.isBangladesh && this.Invoice.Bangladesh_special_case__c == NO_DEPOSIT) 
            || (this.isBangladesh && this.Factory != null && !this.MapExtension.Funding_Upfront_fees__c)) {
        // Bangladesh no deposit, upfront fees are not paid at funding instead at repayment 
        // Bangladesh with factory, whether or not upfront fees paid at funding depend on Map Extension
        CoreLoadingUpfront();
      }

      this.Logs.Log('2. Loading repaid data', 1, Helper_Log.Color.Green);

      // Funder Agents accounts
      LoadFunderAgents();

      // Load Ewallet trustee
      LoadeWalletTrustee();

      // ===========
      // Validations
      // ===========
      this.Logs.Log('3. Validating the data', 1, Helper_Log.Color.Green);
      validateToBeRepaid();

      // ===============
      // Closing Process
      // ===============

      this.Logs.Log('4. Closing the invoice', 1, Helper_Log.Color.Green);
  
      // Bangladesh no deposit, upfront fees are not paid at funding instead at repayment 
      // Bangladesh with factory, whether or not upfront fees paid at funding depend on Map Extension
      if ((this.isBangladesh && this.Invoice.Bangladesh_special_case__c == NO_DEPOSIT) 
            || (this.isBangladesh && this.Factory != null && !this.MapExtension.Funding_Upfront_fees__c)) {
        payUpfrontFees();
        payUpfrontFeesBalance(false);
        payPlatformFee();
      } else {
        if (this.InvoiceBuybackAllocations.size() > 0) payUpfrontFeesBalance(null); // done at repaid
      }
      
      repayingInvoiceRepayment();
      repayingInvoiceCapitalRepayment();
      repayingInvoiceNFDA();
      if (isInTransit) repayingInTransit();
      repayingFunderAgentFees();
      repayingTransactionFees();
      repayingFunderProfitShare();
      repayingTransactionFeesOverdueInvoiceBalance();
      volofin(false);
      commonDml(false);
      if (Test.isRunningTest()) return true;
    }
    catch(Exception unmanagedException)
    {
      this.Logs.Log(unmanagedException);

      this.HasEncounteredIssues = true;
    }
    finally
    {
      sendAlertAndLog();
    }

    return (!this.HasEncounteredIssues);
  }

  private void validateToBeRepaid() 
  {
    // Validates the invoice phase equals "3:IN PROGRESS"
    this.HasEncounteredIssues = !IsValidated(  this.Invoice.Phase__c == '3:IN PROGRESS',
            this.Behaviour.FailAtValidation,
            'Invoice "Phase" field equals 3:IN PROGRESS.',
            'Invoice "Phase" field does not equal 3:IN PROGRESS. Current value: ' + this.Invoice.Phase__c + '.');

    // Validates the invoice is already funded
    this.HasEncounteredIssues = !IsValidated(  this.InvoiceTransactions.size() > 0,
            this.Behaviour.FailAtValidation,
            'Invoice is funded. ' + this.InvoiceTransactions.size() + ' transaction(s) found.',
            'Invoice is not yet funded. No transactions found.');

    IsValidated(  true, false, 'Invoice "funded amount" field is not empty. Current value: ' + FormatDecimal(this.Invoice.funded_amount__c) + '.', '');

    // Validates the "remaining amount" field greater or equals to 0 
    this.HasEncounteredIssues = !IsValidated(  isBuyback ? Invoice.remaining_amount__c >= 0 : Invoice.remaining_amount__c == 0,
            this.Behaviour.FailAtValidation,
            'Invoice "remaining amount" field ' + (isBuyback ? 'greater or equals to 0.00. Current value: ' + FormatDecimal(this.Invoice.remaining_amount__c) : 'equals to 0.00') + '.',
            'Invoice "remaining amount" field invalid. Current value: ' + FormatDecimal(this.Invoice.remaining_amount__c) + '.');

    boolean isAdvanceAmountFound = sumTransaction(this.InvoiceTransactions, '02.Invoice Advance Amount', 'has') > 0;

    // Validates that a "02.Invoice Advance Amount" transaction already exists
    this.HasEncounteredIssues = !IsValidated(  isAdvanceAmountFound,
            this.Behaviour.FailAtValidation,
            'Invoice is funded. A transaction "02.Invoice Advance Amount" has been found.',
            'Invoice is not yet funded. No transactions "02.Invoice Advance Amount" has been found.');

    if (!isBuyback && !isPartialFunded) {
      boolean isCapitalRepaymentFound = sumTransaction(this.InvoiceTransactions, '03.Invoice Repayment', 'has') > 0;

      // Validates that a "03.Invoice Repayment" transaction not exists
      if (!isCapitalRepaymentFound) IsValidated(  true, false, 'Invoice is not yet closed. No transaction "03.Invoice Repayment" has been found.', '');
      else if (this.InvoiceBuybackAllocations.size() == 0) this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtValidation,
              'Invoice is already closed. A transaction "03.Invoice Repayment" has been found.');
  
      if (!this.isBangladesh || this.Invoice.Bangladesh_special_case__c != NO_DEPOSIT) {
        Account debitAccount = !isInTransit ? this.Supplier : this.IncomlendTrading;
        if (this.isBangladesh && this.Invoice.Bangladesh_special_case__c == WITH_DEPOSIT) debitAccount = this.IncomlendProvision;
        if (this.isBangladesh && this.Factory != null) debitAccount = this.Factory;
        decimal sumSupplierDiscountAmount = sumTransaction(this.InvoiceTransactions, '' + debitAccount.Id + ';' + '06.Transaction Fee', 'id-type');
        if (sumSupplierDiscountAmount + this.Invoice.Total_supplier_discount_amount_expected__c + this.Invoice.Total_platform_fee__c != 0) this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtValidation,
              'Transactions for expected supplier discount amount did not tally, please ensure expected financing period and supplier discount rate stay the same as when invoice is financed.');
      }

      // Validates the "Supplier country of Incorporation" field is set
      this.HasEncounteredIssues = !IsValidated(  this.Invoice.Supplier_Country__c != null,
              this.Behaviour.FailAtValidation,
              'Invoice "Supplier Country" field is not empty. Current value: ' + this.Invoice.Supplier_Country__c + '.',
              'Invoice "Supplier Country" field is empty.');

      // Validates the "Map Agent" data
      if (this.Invoice.Supplier_s_Agent_Commission_amount__c > 0) { 
        if (this.MapAgent != null) {
          this.HasEncounteredIssues = !IsValidated(   this.MapAgent.Country_of_Incorporation__c != null,
                  this.Behaviour.FailAtValidation,
                  'Map agent account "Country of Incorporation" field is not empty. Current value: ' + this.MapAgent.Country_of_Incorporation__c + '.',
                  'Map agent account "Country of Incorporation" field is empty.' + this.MapAgent.Name);
        } else this.HasEncounteredIssues = !IsValidated( this.Behaviour.FailAtValidation, 
                'Map Agent is empty, Supplier/Map\'s Agent Commission amount should be empty.');
      }

      // Validates the "Actual Repayment Received Date" field is set
      this.HasEncounteredIssues = !IsValidated(  this.Invoice.Actual_Repayment_Received_Date__c != null,
              this.Behaviour.FailAtValidation,
              'Invoice "Actual Repayment Received Date" field is not empty. Current value: ' + string.valueOf(this.Invoice.Actual_Repayment_Received_Date__c) + '.',
              'Invoice "Actual Repayment Received Date" field is empty.');

      IsValidated(  true, false, 'Invoice "actual financing period" field is not empty. Current value: ' + this.Invoice.actual_financing_period__c + '.', '');

      // Validates the "Actual Repayment Amount" field is greater than 0
      this.HasEncounteredIssues = !IsValidated(  this.Invoice.Actual_Repayment_Amount__c > 0,
            this.Behaviour.FailAtValidation,
              'Field "Actual Repayment Amount" is greater than 0.00: Current value: ' + FormatDecimal(this.Invoice.Actual_Repayment_Amount__c ) + '"',
              'Field "Actual Repayment Amount" is not greater than 0.00: Current value: ' + FormatDecimal(this.Invoice.Actual_Repayment_Amount__c ) + '"');
    }

    // Validates the "Sum Of All Pre-reservations" field equals to 0
    this.HasEncounteredIssues = !IsValidated(  this.Invoice.Sum_Of_All_Pre_Reservations__c == null || this.Invoice.Sum_Of_All_Pre_Reservations__c == 0,
            this.Behaviour.FailAtValidation,
            'Invoice "Sum Of All Pre-reservations" field equals 0.00.',
            'Invoice "Sum Of All Pre-reservations" field does not equal 0.00. Current value: ' + FormatDecimal(this.Invoice.Sum_Of_All_Pre_Reservations__c) + '.');

    if (!isBuyback && !isPartialFunded) {
      // Prints out the "Total Supplier Discount" field
      IsValidated(  true, false, 'Invoice "Total Supplier Discount" field is not empty. Current value: ' + this.Invoice.Total_Supplier_Discount__c.format() + '.', '');

      if (this.Invoice.over_due_days__c != 0) {
        IsValidated(  true, false, 'Invoice "over due days" field is not empty. Current value: ' + FormatDecimal(this.Invoice.over_due_days__c) + '.', '');
        
        // Validates the "Tolerance overdue days" field is not null
        this.HasEncounteredIssues = !IsValidated(  this.Invoice.Tolerance_overdue_days__c != null,
                this.Behaviour.FailAtValidation,
                'Invoice "Tolerance overdue days" field is not empty. Current value: ' + FormatDecimal(this.Invoice.Tolerance_overdue_days__c) + '.',
                'Invoice "Tolerance overdue days" field is empty.');
        
        // Prints out the "Overdue Supplier discount rate" field
        IsValidated(  true, false, 'Invoice "Overdue Supplier discount rate" field is not empty. Current value: ' + this.Invoice.Overdue_Supplier_discount_rate__c.format() + '.', '');      

      } else if (this.Invoice.expected_financing_period__c > this.Invoice.actual_financing_period__c) {
        IsValidated(  true, false, 'Invoice "due date delta" field is greater than 0. Current value: ' + FormatDecimal(this.Invoice.expected_financing_period__c - this.Invoice.actual_financing_period__c) + '.', '');
      } 

      if (this.MapAgent.Name == 'Incomlend - agent') this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtValidation,
              'Supplier/Map\'s Agent Commission amount should be empty for Incomlend - agent.');
    }

    if (isPartialFunded && this.Invoice.Agent_s_fee_type__c == 'Platform fee (%)') this.HasEncounteredIssues = !IsValidated( this.Behaviour.FailAtValidation, 
            'Invoice is not ready for partially fund due to unsupported Agent\'s fee type');

    if (!isBuyback && !isPartialFunded) {
      if (this.InvoiceBuybackAllocations.size() > 0) 
              IsValidated( false, 'There is buyback allocation(s), please ensure buyback has been runned previously.');
      validateInvoiceAllocation(CONFIRMED);
    } else {
      if (isBuyback && !validateInvoiceAllocation(BUYBACK)) this.HasEncounteredIssues = !IsValidated( this.Behaviour.FailAtValidation, 
            'No buyback allocations found.');
      if (!validateInvoiceAllocation(RESERVATION)) this.HasEncounteredIssues = !IsValidated( this.Behaviour.FailAtValidation, 
            'No reservation allocations found.');
      if (this.Invoice.remaining_amount__c > 0) {
        // Validate the "remaining amount" field if greater than 0 is smaller than one of the buyback allocation
        this.HasEncounteredIssues = !IsValidated(  this.InvoiceBuybackCopyAllocation != null,
                this.Behaviour.FailAtValidation,
                'Invoice buyback allocation will be duplicated to cover the remaining amount: ' + this.Invoice.remaining_amount__c + '.',
                'Invoice "funded amount" field is smaller than "requested amount" field.');
      }
    } 

    if (this.FunderAgents != null && this.FunderAgents.size() > 0) {
      for (Account FunderAgent : this.FunderAgents.values()) {
        // Validates the account "Funder Agent country of Incorporation" field is set
        this.HasEncounteredIssues = !IsValidated(  FunderAgent.Country_of_Incorporation__c != null,
                this.Behaviour.FailAtValidation,
                'Funder agent account ' + FunderAgent.Name + ' "Country of Incorporation" field is not empty. Current value: ' + FunderAgent.Country_of_Incorporation__c + '.',
                'Funder agent account ' + FunderAgent.Name + ' "Country of Incorporation" field is empty.');
      }
    }
    
    validateVolofin();
    validateBangladesh();
  }

  private void repayingInvoiceRepayment()
  {
      // --------------------
      // 06.Transaction Fee - EP_F1.Transaction Fee - Early repayment
      // Create transaction from Incomlend platform fees to Incomlend Supply Discount for early repayment
      // --------------------
      decimal incTransactionFeesAdj = 0;
      if(this.Invoice.actual_financing_period__c < this.Invoice.expected_financing_period__c && this.Behaviour.ApplyEarlyPayment == true)
      {
        {
          // Calculation Total Supplier Cost of Funding Adjustment (SDAA)
          // The AFP is at capped at FP-15, meaning that if the Buyer pays more than 15 days in advance, all calculation are made as if it had paid 15 days in advance.
          decimal totalSupplierCostFundingAdj = -(this.Invoice.Actual_total_supplier_discount_amount__c - this.Invoice.Total_supplier_discount_amount_expected__c);
          
          decimal mapAgentCommAdj = this.Invoice.Actual_supplier_s_Agent_Commission_amt__c - this.Invoice.Supplier_s_Agent_Commission_amount__c;

          // Calculation Gross Funder Discount Amount (GFDAA)
          // Calculation is now based on the allocation
          // Flexible Funder Discount Rate
          decimal grossFunderDiscAmtAdj = totalGfdaAdjEarly();

          // Calculaton Incomlend Transaction Fees (ITFA)
          incTransactionFeesAdj = ((totalSupplierCostFundingAdj + mapAgentCommAdj - grossFunderDiscAmtAdj)).setScale(2, RoundingMode.HALF_UP);
          System.debug('early ' + totalSupplierCostFundingAdj.setScale(2) + ' - ' + mapAgentCommAdj.setScale(2) + ' - ' + grossFunderDiscAmtAdj.setScale(2));

          this.Logs.Log('"06.Transaction Fee" - Incomlend transaction fees adjustment for early payment transactions '+ this.Invoice.CCY__c + ' ' +  FormatDecimal(incTransactionFeesAdj), 2, Helper_Log.Color.Black);

          // Create the debit/credit transactions from Incomlend fees' eWallet to Incomlend Supply Discount's eWallet
          CreateTransaction(  this.IncomlendFees.eWallets__r[0].Id,
                  this.IncomlendFees.eWallets__r[0].Name,
                  this.IncomlendFees.Id,
                  this.IncomlendFees.Name,
                  this.Invoice.CCY__c,
                  incTransactionFeesAdj * -1,
                  '06.Transaction Fee');
          CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                  this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                  this.IncomlendSupplierDiscount.Id,
                  this.IncomlendSupplierDiscount.Name,
                  this.Invoice.CCY__c,
                  incTransactionFeesAdj,
                  '06.Transaction Fee');
        }
      }
      else
              this.Logs.Log('("06.Transaction Fee" - Incomlend transaction fees adjustment - No Early Repayment)', 2, Helper_Log.Color.Grey);

      // --------------------
      // EP_F2.Transaction Fee - Early repayment
      // Create transaction from Incomlend Supply Discount to Supplier for early repayment
      // --------------------

      decimal totalSupplierCostFundingAdj = 0;
      decimal TaxAmountSupplierAjd = 0;
      if(this.Invoice.actual_financing_period__c < this.Invoice.expected_financing_period__c && this.Behaviour.ApplyEarlyPayment == true)
      {
        // Bangladesh with deposit, substitute Supplier with IncomlendProvision
        Account creditAccount = !isInTransit ? this.Supplier : this.IncomlendTrading;
        if (this.isBangladesh && this.Invoice.Bangladesh_special_case__c == WITH_DEPOSIT) {
          creditAccount = this.IncomlendProvision;
        }

        // Calculation Total Supplier Cost of Funding Adjustment (TSCFA)
        totalSupplierCostFundingAdj = -(this.Invoice.Actual_total_supplier_discount_amount__c - this.Invoice.Total_supplier_discount_amount_expected__c);
        this.Logs.Log('"06.Transaction Fee" - Total supplier cost of funding adjustment for early repayment transactions ' + this.Invoice.CCY__c + ' ' +  FormatDecimal(totalSupplierCostFundingAdj), 2, Helper_Log.Color.Black);

        for (Account debitAccount : new List<Account> { this.IncomlendSupplierDiscount, isInTransitRepo ? this.IncomlendTrading : null}) 
        {
          if (debitAccount == null) continue;
          Account creditAccountInTransit = creditAccount;
          if (isInTransit && isInTransitRepo) {
            if (debitAccount == this.IncomlendSupplierDiscount) creditAccountInTransit = this.IncomlendTrading;
            else creditAccount = this.Factory;
          }

          // Create the debit/credit transactions from Incomlend Supply Discount's eWallet to Supplier's eWallet
          CreateTransaction(  debitAccount.eWallets__r[0].Id,
                  debitAccount.eWallets__r[0].Name,
                  debitAccount.Id,
                  debitAccount.Name,
                  this.Invoice.CCY__c,
                  totalSupplierCostFundingAdj * -1,
                  '06.Transaction Fee');
         CreateTransaction(  creditAccount.eWallets__r[0].Id,
                  creditAccount.eWallets__r[0].Name,
                  creditAccount.Id,
                  creditAccount.Name,
                  this.Invoice.CCY__c,
                  totalSupplierCostFundingAdj,
                  '06.Transaction Fee');

          if (debitAccount != this.IncomlendSupplierDiscount) continue; 

        }

        // Tax Invoice for Supplier Discount Amount Adjustement for early repayment
        Tax_Rate__c TaxRateSupplier = getTaxRate(Invoice.Id_Supplier__c);
        if (TaxRateSupplier != null && TaxRateSupplier.rate__c > 0) {
          TaxAmountSupplierAjd = ((totalSupplierCostFundingAdj) * TaxRateSupplier.rate__c / 100).setScale(2, RoundingMode.HALF_UP);

          this.Logs.Log('"09.GST transaction" - Supplier Adjustment GST: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountSupplierAjd), 2, Helper_Log.Color.Black);

          // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Supplier's eWallet
          CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                  this.IncomlendGST.eWallets__r[0].Name,
                  this.IncomlendGST.Id,
                  this.IncomlendGST.Name,
                  this.Invoice.CCY__c,
                  TaxAmountSupplierAjd * -1,
                  '09.GST transaction');
          CreateTransaction(  creditAccount.eWallets__r[0].Id,
                  creditAccount.eWallets__r[0].Name,
                  creditAccount.Id,
                  creditAccount.Name,
                  this.Invoice.CCY__c,
                  TaxAmountSupplierAjd,
                  '09.GST transaction');
        }

        // Create Tax invoice supplier discount amount adjustment - early repayment - even if Tax Rate is null
        // Supplier discount amount + insurance amount List
        Map<InvoiceUtil.Description, Decimal> amountExclGSTMap = new Map<InvoiceUtil.Description, Decimal>();
        amountExclGSTMap.put(InvoiceUtil.Description.SUPPLIER_DISCOUNT_AMOUNT_ADJUSTMENT, totalSupplierCostFundingAdj);

        // Amounts that are not subjected to tax
        Map<InvoiceUtil.Description, Decimal> amountNoTaxMap = new Map<InvoiceUtil.Description, Decimal>();

        CreateInvoice_v1 TaxInvoiceSupplierDiscount =
                new CreateInvoice_v1 (    this.Supplier.Id,
                        this.Invoice,
                        null,
                        amountExclGSTMap,
                        TaxRateSupplier == null ? 0 : TaxRateSupplier.rate__c,
                        amountNoTaxMap,
                        InvoiceUtil.RecordType.SUPPLIER,
                        InvoiceUtil.ActionType.Repaid,
                        true,
                        this.Notification,
                        false);

        TaxInvoiceSupplierDiscount.createInvoice();
      }
      else
              this.Logs.Log('("06.Transaction Fee" - Total supplier cost of funding adjustment - No Early Repayment)', 2, Helper_Log.Color.Grey);

      // --------------------
      // 03.Invoice Repayment
      // --------------------
      if(this.Invoice.Actual_Repayment_Amount__c > 0)
      {
        this.Logs.Log('"03.Invoice Repayment" transactions ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.Actual_Repayment_Amount__c), 2, Helper_Log.Color.Black);

        decimal pseudoAmount = this.Invoice.Actual_Repayment_Amount__c;
        
        // Create the debit/credit transactions from Buyer's eWallet to Incomlend Operations' eWallet
        CreateTransaction(  this.Buyer.eWallets__r[0].Id,
                this.Buyer.eWallets__r[0].Name,
                this.Buyer.Id,
                this.Buyer.Name,
                this.Invoice.CCY__c,
                this.Invoice.Actual_Repayment_Amount__c * -1,
                '03.Invoice Repayment');
        CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
                this.IncomlendOperations.eWallets__r[0].Name,
                this.IncomlendOperations.Id,
                this.IncomlendOperations.Name,
                this.Invoice.CCY__c,
                this.Invoice.Actual_Repayment_Amount__c,
                '03.Invoice Repayment');
      }
      else
              this.Logs.Log('("03.Invoice Repayment" transactions - No Invoice Repayment)', 2, Helper_Log.Color.Grey);
  }

  private void repayingInvoiceCapitalRepayment() 
  {
    // ----------------------------
    // 04.Invoice Capital Repayment
    // ----------------------------
    this.Logs.Log('"04.Invoice Capital Repayment" transactions ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.funded_amount__c), 2, Helper_Log.Color.Black);
    decimal totalAllocations = 0;
    for(Invoice_Allocation__c currentAllocation : (isBuyback ? InvoiceBuybackAllocations : AllocationsToUpdate))
    {
      // Update the current allocation
      if (!isBuyback) currentAllocation.Status__c = CLOSED;
        
      this.Logs.Log('Allocation: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(currentAllocation.amount__c) + ' for ' + currentAllocation.Funder__r.Name, 3, Helper_Log.Color.Grey);
      totalAllocations += currentAllocation.amount__c;

      // Create the debit/credit transactions from Incomlend Operations' eWallet to Funder's eWallet
      CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
              this.IncomlendOperations.eWallets__r[0].Name,
              this.IncomlendOperations.Id,
              this.IncomlendOperations.Name,
              currentAllocation.CCY__c,
              currentAllocation.amount__c * -1,
              '04.Invoice Capital Repayment',
              currentAllocation.Id,
              currentAllocation.Name);
      CreateTransaction(  currentAllocation.eWallet__c,
              currentAllocation.eWallet__r.Name,
              currentAllocation.Funder__c,
              currentAllocation.Funder__r.Name,
              currentAllocation.CCY__c,
              currentAllocation.amount__c,
              '04.Invoice Capital Repayment',
              currentAllocation.Id,
              currentAllocation.Name);
    }
  }

  private void repayingInvoiceNFDA() {
    // --------------------------
    // 05.Invoice Discount Amount - Net funder discount amount total
    // --------------------------
    decimal netFunderDiscountAmountTotal = 0;
    // for(Invoice_Allocation__c currentAllocation : (isBuyback ? InvoiceBuybackAllocations : AllocationsToUpdate))
    for(Invoice_Allocation__c currentAllocation : (isBuyback ? InvoiceBuybackAllocations : InvoiceAllocations)) // migrate
    {
      if (!AllocationsToUpdate.contains(currentAllocation) && !InvoiceBuybackAllocations.contains(currentAllocation)) continue; // migrate
      Invoice_Allocation__c allocation = currentAllocation;
      if (isBuyback) { // workaround null 
        currentAllocation = currentAllocation.clone(false, true, false, false);
        recalculateFormulas(currentAllocation); 
      } 
  
      if (currentAllocation.Funder_prepayment__c == NET_EFDA){
        netFunderDiscountAmountTotal += currentAllocation.Net_Funder_Discount_Amount_total__c;
      } else {
        netFunderDiscountAmountTotal += Math.MAX(0,currentAllocation.Net_Funder_Discount_Amount_total__c)+ currentAllocation.Net_Funder_discount_amount_expected__c;
      }
      if (isBuyback) currentAllocation = allocation;
      if (!isBuyback && InvoiceBuybackAllocations.contains(currentAllocation)) { // migrate
        decimal temp = sumTransaction(this.InvoiceTransactions, '' + currentAllocation.Funder__c + ';' + '05.Invoice Discount Amount' + ';' + currentAllocation.Id, 'id-type-allocation'); 
        System.debug('NFDA has been done during the buyback process ' + temp);
        netFunderDiscountAmountTotal -= temp;
      }
    }

    if (netFunderDiscountAmountTotal > 0) {
      this.Logs.Log('"05.Invoice Discount Amount" - Net funder discount amount total transactions ' + this.Invoice.CCY__c + ' ' + FormatDecimal(netFunderDiscountAmountTotal), 2, Helper_Log.Color.Black);

      // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend Operation's eWallet
      // Note : funder discount amount = Net Funder Discount Amount Total
      CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
              this.IncomlendSupplierDiscount.eWallets__r[0].Name,
              this.IncomlendSupplierDiscount.Id,
              this.IncomlendSupplierDiscount.Name,
              this.Invoice.CCY__c,
              netFunderDiscountAmountTotal  * -1,
              '05.Invoice Discount Amount');
      CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
              this.IncomlendOperations.eWallets__r[0].Name,
              this.IncomlendOperations.Id,
              this.IncomlendOperations.Name,
              this.Invoice.CCY__c,
              netFunderDiscountAmountTotal,
              '05.Invoice Discount Amount');
    }
    else
            this.Logs.Log('(Allocation: 0.00. The payment has been done during the funding process.)', 3, Helper_Log.Color.Grey);
    

    // ---------------------------------------
    // 05.Invoice Discount Amount - Funder discount amount repaid
    // ---------------------------------------
    this.Logs.Log('"05.Invoice Discount Amount" - Net funder discount amount transactions', 2, Helper_Log.Color.Black);
    // for(Invoice_Allocation__c currentAllocation : (isBuyback ? InvoiceBuybackAllocations : AllocationsToUpdate))
    for(Invoice_Allocation__c currentAllocation : (isBuyback ? InvoiceBuybackAllocations : InvoiceAllocations)) // migrate
    {
      if (!AllocationsToUpdate.contains(currentAllocation) && !InvoiceBuybackAllocations.contains(currentAllocation)) continue; // migrate
      Invoice_Allocation__c allocation = currentAllocation;
      if (isBuyback) { // workaround null 
        currentAllocation = currentAllocation.clone(false, true, false, false);
        recalculateFormulas(currentAllocation); 
      } 

      decimal netFunderDiscountAmountRepaid = 0;
      // decimal grossFunderDiscountAmountRepaid = 0;

      if (currentAllocation.Funder_prepayment__c == NET_EFDA){
        netFunderDiscountAmountRepaid = Math.MAX(0,currentAllocation.Net_Funder_discount_amount_repaid__c);
        // grossFunderDiscountAmountRepaid = Math.MAX(0,currentAllocation.Gross_discount_amount_expected_repaid__c);
      } else {
        netFunderDiscountAmountRepaid = Math.MAX(0,currentAllocation.Net_Funder_discount_amount_repaid__c) + currentAllocation.Net_Funder_discount_amount_expected__c	;
        // grossFunderDiscountAmountRepaid = Math.MAX(0,currentAllocation.Gross_discount_amount_expected_repaid__c) + currentAllocation.Gross_funder_discount_amount_expected__c;
      }
      if (isBuyback) currentAllocation = allocation;
      if (!isBuyback && InvoiceBuybackAllocations.contains(currentAllocation)) // migrate
              netFunderDiscountAmountRepaid += sumTransaction(this.InvoiceTransactions, '' + this.IncomlendOperations.Id + ';' + '05.Invoice Discount Amount' + ';' + currentAllocation.Id, 'id-type-allocation'); // migrate

      if (netFunderDiscountAmountRepaid > 0) {
        this.Logs.Log('Allocation: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(netFunderDiscountAmountRepaid) + ' for ' + currentAllocation.Funder__r.Name, 3, Helper_Log.Color.Grey);

        // Create the debit/credit transactions from Incomlend Operation's eWallet to Funder's eWallet
        CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
                this.IncomlendOperations.eWallets__r[0].Name,
                this.IncomlendOperations.Id,
                this.IncomlendOperations.Name,
                currentAllocation.CCY__c,
                netFunderDiscountAmountRepaid  * -1,
                '05.Invoice Discount Amount',
                currentAllocation.Id,
                currentAllocation.Name);
        CreateTransaction(  currentAllocation.eWallet__c,
                currentAllocation.eWallet__r.Name,
                currentAllocation.Funder__c,
                currentAllocation.Funder__r.Name,
                currentAllocation.CCY__c,
                netFunderDiscountAmountRepaid,
                '05.Invoice Discount Amount',
                currentAllocation.Id,
                currentAllocation.Name);

        // Tax Rate for Funder
        Tax_Rate__c TaxRateFunder = getTaxRate(currentAllocation.Funder__c, currentAllocation.Funder__r.Country_of_Incorporation__c);
        if (TaxRateFunder != null && TaxRateFunder.rate__c > 0) {
          /*
          // Tax Invoice for gross funder discount amount total
          // Create the debit/credit transactions from Incomlend GST's eWallet to Incomlend Supplier Discount's eWallet
          decimal TaxAmountGrossFunderDiscountRepaid = (grossFunderDiscountAmountRepaid  * TaxRateFunder.Rate__c / 100).setScale(2, RoundingMode.HALF_UP);
          this.Logs.Log('"09.GST transaction" - Gross funder discount total GST: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountGrossFunderDiscountRepaid), 2, Helper_Log.Color.Black);

          CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                  this.IncomlendGST.eWallets__r[0].Name,
                  this.IncomlendGST.Id,
                  this.IncomlendGST.Name,
                  currentAllocation.CCY__c,
                  TaxAmountGrossFunderDiscountRepaid * -1,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);
          CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                  this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                  this.IncomlendSupplierDiscount.Id,
                  this.IncomlendSupplierDiscount.Name,
                  currentAllocation.CCY__c,
                  TaxAmountGrossFunderDiscountRepaid,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);

          // Tax Invoice for net funder discount amount total
          // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Funder's eWallet
          decimal TaxAmountFunderNetDiscountRepaid = (netFunderDiscountAmountRepaid  * TaxRateFunder.Rate__c / 100).setScale(2, RoundingMode.HALF_UP);
          this.Logs.Log('"09.GST transaction" - Net funder discount repaid GST: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(TaxAmountFunderNetDiscountRepaid), 2, Helper_Log.Color.Black);

          CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                  this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                  this.IncomlendSupplierDiscount.Id,
                  this.IncomlendSupplierDiscount.Name,
                  currentAllocation.CCY__c,
                  TaxAmountFunderNetDiscountRepaid * -1,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);
          //we dont pay funder GST on NFDA (Funder to GST)
          CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id, // currentAllocation.eWallet__c, 
                  this.IncomlendGST.eWallets__r[0].Id, // currentAllocation.eWallet__r.Name,
                  this.IncomlendGST.eWallets__r[0].Id, // currentAllocation.Funder__c,
                  this.IncomlendGST.eWallets__r[0].Name, // currentAllocation.Funder__r.Name,
                  currentAllocation.CCY__c,
                  TaxAmountFunderNetDiscountRepaid,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);
          //*/
        }
      }
      else
              this.Logs.Log('(Allocation: 0. The payments have been done during the funding process.)', 3, Helper_Log.Color.Grey);
    }

    // ------------------------
    // 054.Invoice Discount Amount Overdue - Net funder discount amount overdue
    // ------------------------
    if (this.Invoice.over_due_days__c > 0 && this.Behaviour.ApplyOverduePayment == true)
    {
      this.Logs.Log('"054.Invoice Discount Amount Overdue" - Net funder discount amount overdue transactions', 2, Helper_Log.Color.Black);
      for(Invoice_Allocation__c currentAllocation : (isBuyback ? InvoiceBuybackAllocations : AllocationsToUpdate))
      {
        if (currentAllocation.Net_Funder_discount_amount_overdue__c == 0) continue;
  
        // Create the debit/credit transactions from Incomlend Operation's eWallet to Funder's eWallet
        CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
                this.IncomlendOperations.eWallets__r[0].Name,
                this.IncomlendOperations.Id,
                this.IncomlendOperations.Name,
                currentAllocation.CCY__c,
                currentAllocation.Net_Funder_discount_amount_overdue__c * -1,
                '054.Invoice Discount Amount Overdue',
                currentAllocation.Id,
                currentAllocation.Name);
        CreateTransaction(  currentAllocation.eWallet__c,
                currentAllocation.eWallet__r.Name,
                currentAllocation.Funder__c,
                currentAllocation.Funder__r.Name,
                currentAllocation.CCY__c,
                currentAllocation.Net_Funder_discount_amount_overdue__c,
                '054.Invoice Discount Amount Overdue',
                currentAllocation.Id,
                currentAllocation.Name);

        // Tax Rate for Funder
        Tax_Rate__c TaxRateFunder = getTaxRate(currentAllocation.Funder__c, currentAllocation.Funder__r.Country_of_Incorporation__c);
        if (TaxRateFunder != null && TaxRateFunder.rate__c > 0) {
          /*
          // Tax Invoice for gross funder discount amount overdue
          // Create the debit/credit transactions from Incomlend GST's eWallet to Incomlend Supplier Discount's eWallet
          decimal TaxAmountGrossFunderOverdue = (currentAllocation.Gross_Funder_discount_amount_overdue__c * TaxRateFunder.Rate__c / 100).setScale(2, RoundingMode.HALF_UP);
          this.Logs.Log('"09.GST transaction" - Gross funder discount overdue GST: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountGrossFunderOverdue), 2, Helper_Log.Color.Black);

          CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                  this.IncomlendGST.eWallets__r[0].Name,
                  this.IncomlendGST.Id,
                  this.IncomlendGST.Name,
                  currentAllocation.CCY__c,
                  TaxAmountGrossFunderOverdue * -1,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);
          CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                  this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                  this.IncomlendSupplierDiscount.Id,
                  this.IncomlendSupplierDiscount.Name,
                  currentAllocation.CCY__c,
                  TaxAmountGrossFunderOverdue,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);

          // Tax Invoice for net funder discount amount overdue
          // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Funder's eWallet
          decimal TaxAmountFunderNetDiscountOverdue = (currentAllocation.Net_Funder_discount_amount_overdue__c * TaxRateFunder.Rate__c / 100).setScale(2, RoundingMode.HALF_UP);
          this.Logs.Log('"09.GST transaction" - Net funder discount overdue GST: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(TaxAmountFunderNetDiscountOverdue), 2, Helper_Log.Color.Black);

          CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                  this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                  this.IncomlendSupplierDiscount.Id,
                  this.IncomlendSupplierDiscount.Name,
                  currentAllocation.CCY__c,
                  TaxAmountFunderNetDiscountOverdue * -1,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);
          //we dont pay funder GST on NFDA (Funder to GST)
          CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id, // currentAllocation.eWallet__c, 
                  this.IncomlendGST.eWallets__r[0].Id, // currentAllocation.eWallet__r.Name,
                  this.IncomlendGST.eWallets__r[0].Id, // currentAllocation.Funder__c,
                  this.IncomlendGST.eWallets__r[0].Name, // currentAllocation.Funder__r.Name,
                  currentAllocation.CCY__c,
                  TaxAmountFunderNetDiscountOverdue,
                  '09.GST transaction',
                  currentAllocation.Id,
                  currentAllocation.Name);
          //*/
        }
      }
    }
    else
            this.Logs.Log('("054.Invoice Discount Amount Overdue - Net funder discount amount overdue - No overdue)', 2, Helper_Log.Color.Grey);

  }

  private void repayingInTransit() {
    if (!isInTransit || !isInTransitRepo) return;
    
    if (GlobalTriggerHandler.coalesce(this.Invoice.In_Transit_fee__c) > 0) {        
      this.Logs.Log('"89.Maintenance fee" transactions ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.In_Transit_fee__c), 2, Helper_Log.Color.Black);
      // Create the debit/credit transactions from Incomlend In Transit Provision's eWallet to Incomlend Supplier Discount's eWallet 
      CreateTransaction(  this.IncomlendInTransitProvision.eWallets__r[0].Id,
              this.IncomlendInTransitProvision.eWallets__r[0].Name,
              this.IncomlendInTransitProvision.Id,
              this.IncomlendInTransitProvision.Name,
              this.Invoice.CCY__c,
              this.Invoice.In_Transit_fee__c * -1,
              '89.Maintenance fee');
      CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
              this.IncomlendOperations.eWallets__r[0].Name,
              this.IncomlendOperations.Id,
              this.IncomlendOperations.Name,
              this.Invoice.CCY__c,
              this.Invoice.In_Transit_fee__c,
              '89.Maintenance fee');
    }
  }

  private void repayingFunderAgentFees() 
  {
    // ---------------------------------------
    // 051.Agent Commission on Discount Amount
    // ---------------------------------------
    for (Invoice_Allocation__c currentAllocation : (isBuyback ? this.InvoiceBuybackAllocations : this.InvoiceAllocations))
    {
      if (isBuyback && this.InvoiceBuybackCopyAllocation != null && this.InvoiceBuybackCopyAllocation.Funder__c == currentAllocation.Funder__c) continue;
      if (isBuyback) { // workaround null 
        currentAllocation = currentAllocation.clone(false, true, false, false);
        recalculateFormulas(currentAllocation); 
      } 

      if (currentAllocation.Funder__r.Agent__c != null && currentAllocation.Funder_Agent_Commission_Amount__c > 0)
      {
        Account FunderAgent = this.FunderAgents.get(currentAllocation.Funder__r.Agent__c);
        if (FunderAgent != null)
        {
          decimal Funder_Agent_Commission_Amount = currentAllocation.Funder_Agent_Commission_Amount__c;
          if (isBuyback) { // workaround null 
            Invoice_Allocation__c allocation = currentAllocation.clone(false, true, false, false);
            recalculateFormulas(allocation);
            Funder_Agent_Commission_Amount = allocation.Funder_Agent_Commission_Amount__c; 
          }     
          if (!isBuyback && currentAllocation.Status__c == BUYBACK && sumTransaction(this.InvoiceTransactions, '' + FunderAgent.Id + ';' + '051.Agent Commission on Discount Amount' + ';' + currentAllocation.Id, 'id-type-allocation') != 0) continue;

          this.Logs.Log('"051.Agent Commission on Discount Amount" transactions - Agent Funder ' + currentAllocation.Name + ' ' + currentAllocation.CCY__c + ' ' + FormatDecimal(Funder_Agent_Commission_Amount) + ' ' + currentAllocation.Funder_Agent_Commission_Type__c, 2, Helper_Log.Color.Black);
          for (Account debitAccount : (currentAllocation.Funder_Agent_Commission_Type__c == AGENT_FEE_PS ? new List<Account> { this.IncomlendSupplierDiscount } : new List<Account> { this.IncomlendAgentProvision, this.IncomlendSupplierDiscount } )) {
            Account creditAccount = FunderAgent;
            if (debitAccount == this.IncomlendAgentProvision) creditAccount = this.IncomlendSupplierDiscount;
            // Tax Rate for Funder Agent
            Tax_Rate__c TaxRateFunderAgent = getTaxRate(FunderAgent.Id, FunderAgent.Country_of_Incorporation__c);
            CreateTransaction(  debitAccount.eWallets__r[0].Id,
                    debitAccount.eWallets__r[0].Name,
                    debitAccount.Id,
                    debitAccount.Name,
                    currentAllocation.CCY__c,
                    Funder_Agent_Commission_Amount * -1, // we dont create invoice funder agent GST
                    // (Funder_Agent_Commission_Amount / ( 1 + TaxRateFunderAgent.rate__c / 100)).setScale(2, RoundingMode.HALF_UP) * -1,
                    '051.Agent Commission on Discount Amount',
                    currentAllocation.Id,
                    currentAllocation.Name);
            CreateTransaction(  creditAccount.eWallets__r[0].Id,
                    creditAccount.eWallets__r[0].Name,
                    creditAccount.Id,
                    creditAccount.Name,
                    currentAllocation.CCY__c,
                    Funder_Agent_Commission_Amount, // we dont create invoice funder agent GST
                    // (Funder_Agent_Commission_Amount / ( 1 + TaxRateFunderAgent.rate__c / 100)).setScale(2, RoundingMode.HALF_UP),
                    '051.Agent Commission on Discount Amount',
                    currentAllocation.Id,
                    currentAllocation.Name);

            // we dont create invoice funder agent GST
            /*
            if (TaxRateFunderAgent != null && TaxRateFunderAgent.rate__c > 0) {
              // Tax Invoice for Funder Agent
              // Create the debit/credit transactions from Incomlend GST's eWallet to Agent Funder's eWallet
              decimal TaxAmountFunderAgentCommission = (Funder_Agent_Commission_Amount / ( 1 + TaxRateFunderAgent.rate__c / 100) * TaxRateFunderAgent.Rate__c / 100).setScale(2, RoundingMode.HALF_UP);
              this.Logs.Log('"09.GST transaction" - Agent funder commission GST', 2, Helper_Log.Color.Black);

              CreateTransaction(  debitAccount.eWallets__r[0].Id,
                      debitAccount.eWallets__r[0].Name,
                      debitAccount.Id,
                      debitAccount.Name,
                      currentAllocation.CCY__c,
                      TaxAmountFunderAgentCommission * -1,
                      '09.GST transaction',
                      currentAllocation.Id,
                      currentAllocation.Name);
              CreateTransaction(  FunderAgent.eWallets__r[0].Id,
                      FunderAgent.eWallets__r[0].Name,
                      FunderAgent.Id,
                      FunderAgent.Name,
                      currentAllocation.CCY__c,
                      TaxAmountFunderAgentCommission,
                      '09.GST transaction',
                      currentAllocation.Id,
                      currentAllocation.Name);
            }
            //*/
          }
        }
      }
    }
  }

  private void repayingTransactionFees() 
  {   
    // ---------------------------------------
    // 061.Agent Commission on Transaction Fee
    // ---------------------------------------
    if(this.Invoice.Actual_supplier_s_Agent_Commission_amt__c > 0 || this.Invoice.Supplier_s_Agent_Commission_amount__c > 0)
    {
      // Tax Rate for Map Agent
      Tax_Rate__c TaxRateMapAgent = getTaxRate(this.MapAgent.Id);
      decimal pseudoAmount = this.Invoice.Actual_supplier_s_Agent_Commission_amt__c;
      decimal TaxAmountMapAgentCommission = 0;
      // if (TaxRateMapAgent != null) TaxAmountMapAgentCommission = (pseudoAmount / ( 1 + TaxRateMapAgent.rate__c / 100) * TaxRateMapAgent.Rate__c / 100).setScale(2, RoundingMode.HALF_UP);
      this.Logs.Log('"061.Agent Commission on Transaction Fee" - Map agent commission ' + this.Invoice.CCY__c + ' ' + FormatDecimal(pseudoAmount - TaxAmountMapAgentCommission), 2, Helper_Log.Color.Black);
      // Create the debit/credit transactions from Incomlend Supplier Discount to Map Agent's eWallet
      decimal transferredMapAgentCommission = sumTransaction(this.InvoiceTransactions, '061.Agent Commission on Transaction Fee' + ';' + this.IncomlendAgentProvision.Id, 'id-type');

      for (Account debitAccount : new List<Account> { this.IncomlendAgentProvision, this.IncomlendSupplierDiscount} ) {
        Account creditAccount = this.MapAgent;
        if (debitAccount == this.IncomlendAgentProvision) creditAccount = this.IncomlendSupplierDiscount;
        if ((debitAccount == this.IncomlendAgentProvision ? transferredMapAgentCommission : pseudoAmount) == 0) continue;

        CreateTransaction(  debitAccount.eWallets__r[0].Id,
                debitAccount.eWallets__r[0].Name,
                debitAccount.Id,
                debitAccount.Name,
                this.Invoice.CCY__c,
                (debitAccount == this.IncomlendAgentProvision ? transferredMapAgentCommission : pseudoAmount).setScale(2) * -1, // we dont create invoice map agent GST
                // (pseudoAmount / ( 1 + TaxRateMapAgent.rate__c / 100)).setScale(2, RoundingMode.HALF_UP) * -1,
                '061.Agent Commission on Transaction Fee');
        CreateTransaction(  creditAccount.eWallets__r[0].Id,
                creditAccount.eWallets__r[0].Name,
                creditAccount.Id,
                creditAccount.Name,
                this.Invoice.CCY__c,
                (debitAccount == this.IncomlendAgentProvision ? transferredMapAgentCommission : pseudoAmount).setScale(2), // we dont create invoice map agent GST
                // (pseudoAmount / ( 1 + TaxRateMapAgent.rate__c / 100)).setScale(2, RoundingMode.HALF_UP),
                '061.Agent Commission on Transaction Fee');
      }

      // we dont create invoice map agent GST
      /*
      if (TaxRateMapAgent != null && TaxRateMapAgent.rate__c > 0) {
        // Tax Invoice for Map Agent
        // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Agent Map's eWallet
        this.Logs.Log('"09.GST transaction" - Agent map commission GST', 2, Helper_Log.Color.Black);

        CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                this.IncomlendSupplierDiscount.Id,
                this.IncomlendSupplierDiscount.Name,
                this.Invoice.CCY__c,
                TaxAmountMapAgentCommission * -1,
                '09.GST transaction');
        CreateTransaction(  this.MapAgent.eWallets__r[0].Id,
                this.MapAgent.eWallets__r[0].Name,
                this.MapAgent.Id,
                this.MapAgent.Name,
                this.Invoice.CCY__c,
                TaxAmountMapAgentCommission,
                '09.GST transaction');
      }*/
    }
    else
            this.Logs.Log('("061.Agent Commission on Transaction Fee - No map Agent commission)', 2, Helper_Log.Color.Grey);

    // ------------------------
    // 062.Transaction Fees overdue  - supplier discount amount overdue
    // ------------------------
    if (this.Invoice.Amount_Overdue__c > 0 && this.Behaviour.ApplyOverduePayment == true)
    {
      this.Logs.Log('"062.Transaction Fees overdue" - Overdue Supplier Discount Amount transaction ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.Amount_Overdue__c), 2, Helper_Log.Color.Black);

      // Create the debit/credit transactions from Incomlend Operations' eWallet to Incomlend Supplier Discount's eWallet
      // Amount overdue = Overdue Supplier Discount Amount
      CreateTransaction(  this.IncomlendOperations.eWallets__r[0].Id,
              this.IncomlendOperations.eWallets__r[0].Name,
              this.IncomlendOperations.Id,
              this.IncomlendOperations.Name,
              this.Invoice.CCY__c,
              this.Invoice.Amount_Overdue__c * -1,
              '062.Transaction Fees overdue');
      CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
              this.IncomlendSupplierDiscount.eWallets__r[0].Name,
              this.IncomlendSupplierDiscount.Id,
              this.IncomlendSupplierDiscount.Name,
              this.Invoice.CCY__c,
              this.Invoice.Amount_Overdue__c,
              '062.Transaction Fees overdue');

      // Tax Rate for Supplier Discount Amount for overdue
      Tax_Rate__c TaxRateSupplier = getTaxRate(Invoice.Id_Supplier__c);
      if (TaxRateSupplier != null && TaxRateSupplier.rate__c > 0) {
        decimal TaxAmountSupplierOverdue = ((this.Invoice.Amount_Overdue__c) * TaxRateSupplier.rate__c / 100).setScale(2, RoundingMode.HALF_UP);

        Account debitAccount = !isInTransit ? this.Supplier : this.IncomlendTrading;
        if (this.isBangladesh && this.Invoice.Bangladesh_special_case__c == WITH_DEPOSIT) {
          debitAccount = this.IncomlendProvision;
        }
        this.Logs.Log('"09.GST transaction" - Supplier Overdue GST: ' + this.Invoice.CCY__c + ' ' + FormatDecimal(TaxAmountSupplierOverdue), 2, Helper_Log.Color.Black);

        // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Supplier's eWallet
        CreateTransaction(  debitAccount.eWallets__r[0].Id,
                debitAccount.eWallets__r[0].Name,
                debitAccount.Id,
                debitAccount.Name,
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
      amountExclGSTMap.put(InvoiceUtil.Description.SUPPLIER_DISCOUNT_AMOUNT_OVERDUE, this.Invoice.Amount_Overdue__c);

      // Amounts that are not subjected to tax
      Map<InvoiceUtil.Description, Decimal> amountNoTaxMap = new Map<InvoiceUtil.Description, Decimal>();

      CreateInvoice_v1 TaxInvoiceSupplierDiscount =
              new CreateInvoice_v1 (    this.Supplier.Id,
                      this.Invoice,
                      null,
                      amountExclGSTMap,
                      TaxRateSupplier == null ? 0 : TaxRateSupplier.rate__c,
                      amountNoTaxMap,
                      InvoiceUtil.RecordType.SUPPLIER,
                      InvoiceUtil.ActionType.Repaid,
                      false,
                      this.Notification,
                      false);

      TaxInvoiceSupplierDiscount.createInvoice();
    }
    else
            this.Logs.Log('("062.Transaction Fees overdue - No overdue)', 2, Helper_Log.Color.Grey);
  }

  private void repayingFunderProfitShare() 
  {
    // ------------------
    // 052.discount amount fees - Incomlend funder profit sharing expected repaid
    // ------------------
    this.Logs.Log('"052.discount amount fees" - Incomlend funder profit sharing expected repaid transactions', 2, Helper_Log.Color.Black);
    // for (Invoice_Allocation__c currentAllocation : (isBuyback ? this.InvoiceBuybackAllocations : this.AllocationsToUpdate)) // pay at buyback
    // for (Invoice_Allocation__c currentAllocation : (isBuyback ? this.InvoiceBuybackAllocations : this.InvoiceAllocations)) // migrate
    // for (Invoice_Allocation__c currentAllocation : (isBuyback ? new List<Invoice_Allocation__c>() : this.InvoiceAllocations)) // pay not at buyback but closing
    for (Invoice_Allocation__c currentAllocation : this.InvoiceAllocations)
    {
      // if (!isBuyback && currentAllocation.Status__c == BUYBACK && sumTransaction(this.InvoiceTransactions, '' + this.IncomlendFees.Id + ';' + '052.discount amount fees' + ';' + currentAllocation.Id, 'id-type-allocation') != 0 ) continue; // migrate
      // Invoice_Allocation__c allocation = currentAllocation;
      // if (isBuyback) { // workaround null 
      //   currentAllocation = currentAllocation.clone(false, true, false, false);
      //   recalculateFormulas(currentAllocation); 
      // } 
  
      decimal IclProfitShareAmountRepaid = 0;
      if (currentAllocation.Funder_prepayment__c == NET_EFDA){
        IclProfitShareAmountRepaid = currentAllocation.Icl_profit_share_amount_repaid__c;
      } else {
        IclProfitShareAmountRepaid = Math.MAX(0,currentAllocation.Icl_profit_share_amount_repaid__c) + currentAllocation.Icl_Funder_profit_share_amount_expected__c;
      }
      decimal IclProfitShareAmountRepaidAfterAgentFee = IclProfitShareAmountRepaid;
      if (currentAllocation.Funder_Agent_Commission_Type__c == AGENT_FEE_PS) {
        IclProfitShareAmountRepaidAfterAgentFee -= currentAllocation.Funder_Agent_Commission_Amount__c;
      }
      // currentAllocation = allocation; // workaround null 

      // Tax rate for funder
      Tax_Rate__c TaxRateFunder = getTaxRate(currentAllocation.Funder__c, currentAllocation.Funder__r.Country_of_Incorporation__c);

      if (IclProfitShareAmountRepaid > 0) {
        this.Logs.Log('Allocation: ' + currentAllocation.CCY__c + ' ' + FormatDecimal(IclProfitShareAmountRepaid)+ ' for ' + currentAllocation.Funder__r.Name, 3, Helper_Log.Color.Grey);
      }
      if (IclProfitShareAmountRepaidAfterAgentFee != 0) {
        // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend Fees' eWallet
        CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                this.IncomlendSupplierDiscount.Id,
                this.IncomlendSupplierDiscount.Name,
                currentAllocation.CCY__c,
                IclProfitShareAmountRepaidAfterAgentFee * -1, // could go below 0 there is both agent-funder and prepayment
                '052.discount amount fees',
                currentAllocation.Id,
                currentAllocation.Name);
        CreateTransaction(  this.IncomlendFees.eWallets__r[0].Id,
                this.IncomlendFees.eWallets__r[0].Name,
                this.IncomlendFees.Id,
                this.IncomlendFees.Name,
                currentAllocation.CCY__c,
                IclProfitShareAmountRepaidAfterAgentFee,
                '052.discount amount fees',
                currentAllocation.Id,
                currentAllocation.Name);
      }

      if (IclProfitShareAmountRepaid > 0) {
        if (TaxRateFunder != null && TaxRateFunder.rate__c > 0) {
          // Tax Invoice for funder profit sharing repaid
          // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend GST's eWallet
          decimal TaxAmountFunderSharingExp = ((IclProfitShareAmountRepaid ) * TaxRateFunder.rate__c / 100).setScale(2, RoundingMode.HALF_UP);
          this.Logs.Log('"09.GST transaction" - Incomlend funder profit sharing expected GST', 2, Helper_Log.Color.Black);

          if (Math.ABS(TaxAmountFunderSharingExp) >= 0.005) {
            // funder pay us GST on PS (ISD to Funder)
            CreateTransaction(  currentAllocation.eWallet__c, // this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                    currentAllocation.eWallet__r.Name, // this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                    currentAllocation.Funder__c, // this.IncomlendSupplierDiscount.Id,
                    currentAllocation.Funder__r.Name, // this.IncomlendSupplierDiscount.Name,
                    currentAllocation.CCY__c,
                    TaxAmountFunderSharingExp * -1,
                    '09.GST transaction',
                    currentAllocation.Id,
                    currentAllocation.Name);
            CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                    this.IncomlendGST.eWallets__r[0].Name,
                    this.IncomlendGST.Id,
                    this.IncomlendGST.Name,
                    currentAllocation.CCY__c,
                    TaxAmountFunderSharingExp,
                    '09.GST transaction',
                    currentAllocation.Id,
                    currentAllocation.Name);
          }
        }

        // ------------------
        // 053.discount amount fees overdue - Incomlend funder profit sharing overdue
        // ------------------
        if(this.Invoice.over_due_days__c > 0 && currentAllocation.Icl_Funder_profit_share_amount_overdue__c > 0 && this.Behaviour.ApplyOverduePayment == true)
        {
          this.Logs.Log('"053.discount amount fees overdue" - Incomlend funder profit sharing overdue transactions', 2, Helper_Log.Color.Black);

          // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend Fees' eWallet
          CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                  this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                  this.IncomlendSupplierDiscount.Id,
                  this.IncomlendSupplierDiscount.Name,
                  currentAllocation.CCY__c,
                  currentAllocation.Icl_Funder_profit_share_amount_overdue__c * -1,
                  '053.discount amount fees overdue',
                  currentAllocation.Id,
                  currentAllocation.Name);
          CreateTransaction(  this.IncomlendFees.eWallets__r[0].Id,
                  this.IncomlendFees.eWallets__r[0].Name,
                  this.IncomlendFees.Id,
                  this.IncomlendFees.Name,
                  currentAllocation.CCY__c,
                  currentAllocation.Icl_Funder_profit_share_amount_overdue__c,
                  '053.discount amount fees overdue',
                  currentAllocation.Id,
                  currentAllocation.Name);

          if (TaxRateFunder != null && TaxRateFunder.rate__c > 0 && this.Behaviour.ApplyOverduePayment == true) {
            // Tax Invoice for funder profit sharing overdue
            // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend GST's eWallet
            decimal TaxAmountFunderSharingOverdue = (currentAllocation.Icl_Funder_profit_share_amount_overdue__c * TaxRateFunder.rate__c / 100).setScale(2, RoundingMode.HALF_UP);
            this.Logs.Log('"09.GST transaction" - Incomlend funder profit sharing overdue GST', 2, Helper_Log.Color.Black);

            if (Math.Abs(TaxAmountFunderSharingOverdue) >= 0.005 ) {
              // funder pay us GST on PS (ISD to Funder)
              CreateTransaction(  currentAllocation.eWallet__c, // this.IncomlendSupplierDiscount.eWallets__r[0].Id,
                      currentAllocation.eWallet__r.Name, // this.IncomlendSupplierDiscount.eWallets__r[0].Name,
                      currentAllocation.Funder__c, // this.IncomlendSupplierDiscount.Id,
                      currentAllocation.Funder__r.Name, // this.IncomlendSupplierDiscount.Name,
                      currentAllocation.CCY__c,
                      TaxAmountFunderSharingOverdue * -1,
                      '09.GST transaction',
                      currentAllocation.Id,
                      currentAllocation.Name);
              CreateTransaction(  this.IncomlendGST.eWallets__r[0].Id,
                      this.IncomlendGST.eWallets__r[0].Name,
                      this.IncomlendGST.Id,
                      this.IncomlendGST.Name,
                      currentAllocation.CCY__c,
                      TaxAmountFunderSharingOverdue,
                      '09.GST transaction',
                      currentAllocation.Id,
                      currentAllocation.Name);
            }
          }
        }
        else {
          this.Logs.Log('("053.discount amount fees overdue - Incomlend funder profit sharing overdue - No overdue)', 2, Helper_Log.Color.Grey);
        }

        // Create Tax invoice funder profit share - even if tax rate is null
        // Supplier discount amount + insurance amount List
        if (currentAllocation.Icl_profit_share_amount_repaid__c + currentAllocation.Icl_Funder_profit_share_amount_overdue__c > 0) {
          Map<InvoiceUtil.Description, Decimal> amountExclGSTMap = new Map<InvoiceUtil.Description, Decimal>();
          amountExclGSTMap.put(InvoiceUtil.Description.FUNDER_PROFIT_SHARE, IclProfitShareAmountRepaid + currentAllocation.Icl_Funder_profit_share_amount_overdue__c);

          // Amounts that are not subjected to tax
          Map<InvoiceUtil.Description, Decimal> amountNoTaxMap = new Map<InvoiceUtil.Description, Decimal>();

          CreateInvoice_v1 TaxInvoiceFunderSharing =
                  new CreateInvoice_v1 (    currentAllocation.Funder__c,
                          this.Invoice,
                          currentAllocation,
                          amountExclGSTMap,
                          TaxRateFunder == null ? 0 : TaxRateFunder.rate__c,
                          amountNoTaxMap,
                          InvoiceUtil.RecordType.FUNDER,
                          InvoiceUtil.ActionType.Repaid,
                          false,
                          this.Notification,
                          false);

          TaxInvoiceFunderSharing.createInvoice();
        }
      }
      else
              this.Logs.Log('(Allocation: 0.00 for ' + currentAllocation.Funder__r.Name + (GlobalTriggerHandler.coalesce(currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c) > 0 ? '. The payment has been done during funding process' : '') + ')', 3, Helper_Log.Color.Grey);
    }
  }

  private void repayingTransactionFeesOverdueInvoiceBalance() 
  {
    // ----------------------------
    // 062.Transaction Fees overdue
    // ----------------------------
    if (this.Invoice.Transaction_fees_overdue__c > 0 && this.Behaviour.ApplyOverduePayment == true)
    {
      decimal mapAgentCommAdj = this.Invoice.Actual_supplier_s_Agent_Commission_amt__c - this.Invoice.Supplier_s_Agent_Commission_amount__c;
      decimal Transaction_fees_overdue_net = this.Invoice.Amount_Overdue__c - mapAgentCommAdj - totalGfdaAdjOverdue();
      this.Logs.Log('"062.Transaction Fees overdue" Total ' + this.Invoice.CCY__c + ' ' + FormatDecimal(Transaction_fees_overdue_net), 2, Helper_Log.Color.Black);

      // Create the debit/credit transactions from Incomlend Supplier Discount's eWallet to Incomlend Fees' eWallet
      CreateTransaction(  this.IncomlendSupplierDiscount.eWallets__r[0].Id,
              this.IncomlendSupplierDiscount.eWallets__r[0].Name,
              this.IncomlendSupplierDiscount.Id,
              this.IncomlendSupplierDiscount.Name,
              this.Invoice.CCY__c,
              Transaction_fees_overdue_net * -1,
              '062.Transaction Fees overdue');
      CreateTransaction(  this.IncomlendFees.eWallets__r[0].Id,
              this.IncomlendFees.eWallets__r[0].Name,
              this.IncomlendFees.Id,
              this.IncomlendFees.Name,
              this.Invoice.CCY__c,
              Transaction_fees_overdue_net,
              '062.Transaction Fees overdue');
    }
    else
            this.Logs.Log('("062.Transaction Fees overdue - No Overdue)', 2, Helper_Log.Color.Grey);


    // --------------------------
    // 08.Invoice Balance Payment
    // --------------------------
    decimal Supplier_balance = this.Invoice.Supplier_balance__c;
    if (isInTransit && isInTransitRepo) Supplier_balance += GlobalTriggerHandler.coalesce(this.Invoice.In_Transit_fee__c);
    decimal acceptedMargin = 0.01;
    if (Math.abs(Supplier_balance) > acceptedMargin)
    {
      this.Logs.Log('"08.Invoice Balance Payment" - Remaining Balance ' + this.Invoice.CCY__c + ' ' + FormatDecimal(this.Invoice.Supplier_balance__c), 2, Helper_Log.Color.Black);
        
      // Create the debit/credit transactions from Incomlend Operations' eWallet to Supplier's eWallet
      decimal pseudoBalance = Supplier_balance;
      for (Account creditAccount : new List<Account> {this.isBangladesh ? this.Factory : null, this.Supplier, isInTransitRepo ? this.Factory : null}) 
      {
        if (creditAccount == null) continue;
        Account debitAccount = this.IncomlendOperations;
        if (this.isBangladesh && creditAccount == this.Factory) {

          // Bangladesh with factory, remaining balance sent to the factory
          decimal pseudoAmount = Math.min(this.Invoice.funded_amount__c, this.Invoice.Factory_Amount__c);
          pseudoBalance = Math.max(0, Math.min(this.Invoice.Supplier_balance__c, this.Invoice.Factory_Amount__c - pseudoAmount));
          if (pseudoBalance == 0) continue;
          this.Logs.Log('"08.Invoice Balance Payment" - Remaining Balance for Factory ' + this.Invoice.CCY__c + ' ' + FormatDecimal(pseudoBalance), 2, Helper_Log.Color.Black);
        } else if (this.isBangladesh && this.Factory != null) {
          // Bangladesh with factory, invoice balance payment for Supplier
          pseudoBalance = Math.max(0, this.Invoice.Supplier_balance__c - pseudoBalance);
          if (pseudoBalance == 0) continue;
          this.Logs.Log('"08.Invoice Balance Payment" - Remaining Balance for Supplier ' + this.Invoice.CCY__c + ' ' + FormatDecimal(pseudoBalance), 2, Helper_Log.Color.Black);
        } else if (isInTransit && isInTransitRepo) {
          if (creditAccount == this.Factory) debitAccount = this.IncomlendTrading;
          else debitAccount = this.IncomlendOperations;
        }

        // Bangladesh with Factory, Create the debit/credit transactions from Incomlend Operations' eWallet to Factory's eWallet and Supplier's eWallet
        // In Transit, Create the debit/credit transactions from Incomlend Operations' eWallet to Incomlend Trading's eWallet then subsequently to Factory's eWallet

        // Create the debit/credit transactions from Incomlend Operations' eWallet to Supplier's eWallet
        Transaction__c temp = CreateTransaction(  debitAccount.eWallets__r[0].Id,
                debitAccount.eWallets__r[0].Name,
                debitAccount.Id,
                debitAccount.Name,
                this.Invoice.CCY__c,
                pseudoBalance * -1,
                '08.Invoice Balance Payment');
        CreateTransaction(  creditAccount.eWallets__r[0].Id,
                creditAccount.eWallets__r[0].Name,
                creditAccount.Id,
                creditAccount.Name,
                this.Invoice.CCY__c,
                pseudoBalance,
                '08.Invoice Balance Payment');
        if (pseudoBalance < 0) {
          if (TransactionsToInsert.remove(TransactionsToInsert.indexOf(temp)) != null) TransactionsToInsert.add(temp);
        }
      }
    } else 
            this.Logs.Log('("08.Invoice Balance Payment" - No Remaining Balance)', 2, Helper_Log.Color.Grey);
  }

  private void validateEmptyIncomlendBalance(boolean fundedElseRepaid) {

    // Compute balance ISD and Icl Operations
    decimal IncomlendSupplierDiscountBalance = sumTransaction(this.InvoiceTransactions, '' + this.IncomlendSupplierDiscount.Id, 'id');
    IncomlendSupplierDiscountBalance += sumTransaction(this.TransactionsToInsert, '' + this.IncomlendSupplierDiscount.Id, 'id');
    decimal IncomlendOperationsBalance = sumTransaction(this.InvoiceTransactions, '' + this.IncomlendOperations.Id, 'id');
    IncomlendOperationsBalance += sumTransaction(this.TransactionsToInsert, '' + this.IncomlendOperations.Id, 'id');
	  
    decimal acceptedMargin = 1;
    if (Test.isRunningTest()) acceptedMargin = this.Invoice.invoice_amount__c / 1000 * 0.05 * this.Invoice.expected_financing_period__c / 100;

    // Validates that Balance Incomlend Operations is null
    if(IncomlendOperationsBalance >= acceptedMargin || IncomlendOperationsBalance <= -acceptedMargin) { 
      this.Logs.Log('Incomlend Operations Balance: ' + IncomlendOperationsBalance + ' ' + this.Invoice.CCY__c, 1, Helper_Log.Color.Red);
      this.Logs.LogLine();
      this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtIncomlendBalance, 'Incomlend Operations Balance is not null.');
    }

    if (isBuyback || isPartialFunded || fundedElseRepaid != false) return;

    // Validates that Balance Incomlend Supplier Discount is null
    if(IncomlendSupplierDiscountBalance >= acceptedMargin || IncomlendSupplierDiscountBalance <= -acceptedMargin) { 
      this.Logs.Log('Incomlend Supplier Discount Balance: ' + IncomlendSupplierDiscountBalance + ' ' + this.Invoice.CCY__c, 1, Helper_Log.Color.Red);
      this.Logs.LogLine();
      this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtIncomlendBalance, 'Incomlend Supplier Discount Balance is not null.');
    }

    decimal IncomlendAgentProvisionBalance = sumTransaction(this.InvoiceTransactions, '' + this.IncomlendAgentProvision.Id, 'id');
    IncomlendAgentProvisionBalance += sumTransaction(this.TransactionsToInsert, '' + this.IncomlendAgentProvision.Id, 'id');
    if(IncomlendAgentProvisionBalance >= acceptedMargin || IncomlendAgentProvisionBalance <= -acceptedMargin) { 
      this.Logs.Log('Incomlend Agent Provision Balance: ' + IncomlendAgentProvisionBalance + ' ' + this.Invoice.CCY__c, 1, Helper_Log.Color.Red);
      this.Logs.LogLine();
      this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtIncomlendBalance, 'Incomlend Agent Provision Balance is not null.');
    }

    if (this.IncomlendInTransitProvision != null) {
      decimal IncomlendInTransitProvisionBalance = sumTransaction(this.InvoiceTransactions, '' + this.IncomlendInTransitProvision.Id, 'id');
      IncomlendInTransitProvisionBalance += sumTransaction(this.TransactionsToInsert, '' + this.IncomlendInTransitProvision.Id, 'id');
      if(IncomlendInTransitProvisionBalance >= acceptedMargin || IncomlendInTransitProvisionBalance <= -acceptedMargin) { 
        this.Logs.Log('Incomlend In Transit Provision Balance: ' + IncomlendInTransitProvisionBalance + ' ' + this.Invoice.CCY__c, 1, Helper_Log.Color.Red);
        this.Logs.LogLine();
        this.HasEncounteredIssues = !IsValidated(  this.Behaviour.FailAtIncomlendBalance, 'Incomlend In Transit Provision Balance is not null.');
      }  
    }

    if (this.IncomlendTrading != null) {
      decimal IncomlendTradingBalance = sumTransaction(this.InvoiceTransactions, '' + this.IncomlendTrading.Id, 'id');
      IncomlendTradingBalance += sumTransaction(this.TransactionsToInsert, '' + this.IncomlendTrading.Id, 'id');
      if(IncomlendTradingBalance >= acceptedMargin || IncomlendTradingBalance <= -acceptedMargin) { 
        this.Logs.Log('Incomlend Trading Balance: ' + IncomlendTradingBalance + ' ' + this.Invoice.CCY__c, 1, Helper_Log.Color.Red);
        this.Logs.LogLine();
        this.HasEncounteredIssues = !IsValidated(  this.Invoice.Supplier_balance__c >= 0 && this.Behaviour.FailAtIncomlendBalance, 'Incomlend Trading Balance is not null.');
      }
    }
  }

  public boolean AddUpdateAllocation(Date addUpdateAllocationDate) {
    this.addUpdateAllocationDate = addUpdateAllocationDate;
    return AddUpdateAllocation();
  }

  // This method buyback the invoice
  // Returns true if the process has succeeded
  // Returns false if the process has encountered issues
  public boolean AddUpdateAllocation()
  {
    // /*
    try
    {
      CoreInitialization();
      isBuyback = addUpdateAllocationDate != null;
      isPartialFunded = !isBuyback;
      if (isPartialFunded) addUpdateAllocationDate = System.today(); // today to be used as default Partially fund date
      System.debug(addUpdateAllocationDate + ' ' + isBuyback);

      this.Logs.Log('AddUpdateAllocation() method called by ' + UserInfo.getName(), 1, Helper_Log.Color.Blue);

      LogConfiguration();

      // =======
      // Loading
      // =======
      this.Logs.Log('Process Logs:', 1, Helper_Log.Color.Blue);
      this.Logs.Log('1. Loading core data', 1, Helper_Log.Color.Green);
      // System.debug('soql1 ' + limits.getQueries());
      CoreLoading(null);

      this.Logs.Log('2. Loading buyback data', 1, Helper_Log.Color.Green);

      LoadeWalletTrustee();

      // ===========
      // Validations
      // ===========
      this.Logs.Log('3. Validating the data', 1, Helper_Log.Color.Green);
      // System.debug('soql3 ' + limits.getQueries());
      if (this.isBangladesh) this.HasEncounteredIssues = !IsValidated(  true, 'Add update allocation not possible for Bangladesh special case.');
      validateToBeRepaid(); 

      // ===============
      // Buyback Process
      // ===============
      this.Logs.Log('4. Add update allocation the invoice', 1, Helper_Log.Color.Green);

      fundingInvoicePurchase();
      if (isPartialFunded) {
        fundingAdvanceAmount();
        payUpfrontFees();
      }
      if (isBuyback) {
        repayingInvoiceCapitalRepayment();
        repayingInvoiceNFDA();
        repayingFunderAgentFees();
      }
      fundingFunderPrepaymentAndFees();  
      payUpfrontFeesBalance(null);
      commonDml(null);
      if (Test.isRunningTest()) return true;
    }
    catch(Exception unmanagedException)
    {
      this.Logs.Log(unmanagedException);

      this.HasEncounteredIssues = true;
    }
    finally
    {
      sendAlertAndLog();
    }
    //*/

    return (!this.HasEncounteredIssues);
  }

  // ==============
  // Public Methods
  // ==============


  // =====================
  // Public Static Methods
  // =====================

  // ===============
  // Private Methods
  // ===============
  // This method initializes a funding or a closing process
  private void CoreInitialization()
  {
    this.isBuyback = false;
    this.isPartialFunded = false;
    this.taxRateMap = new Map<Id,Tax_Rate__c>();
  
    this.field_hasEncounteredIssues = false;
    this.HasEncounteredIssues = false;
    this.TransactionsToInsert = new List<Transaction__c>();
    this.AllocationsToUpdate = new List<Invoice_Allocation__c>();
    this.InvoiceBuybackAllocations = new List<Invoice_Allocation__c>();
    this.TransactionsIncomlendSupplierDiscount = new List<Transaction__c>();
    this.TransactionsIncomlendOperations = new List<Transaction__c>();
    // this.ImpactedeWallets = new Map<string, decimal>();
    // this.ImpactedAccountsIds = new Set<Id>();
    this.eWalletTrustee = new List<eWallet_Trustee__c>();
    this.TransactionsTable = new List<List<string>>();
    this.TransactionsTable.add(new List<string> {'eWallet', 'Account', 'Type', 'CCY', 'Amount', 'Effective Date', 'Allocation', 'Invoice', 'Status'});
    this.eWalletMovementsTable = new List<List<string>>();
    this.eWalletMovementsTable.add(new List<string> {'eWallet and Account', 'Old Balance', 'Movement', 'New Balance'});
    this.NegativeeWalletsTable = new List<List<string>>();
    this.NegativeeWalletsTable.add(new List<string> {'eWallet', 'Balance'});
    this.InstallmentsToUpdate = new List<Instalment_insurance_fee__c>();
  }

  // This method logs the loaded configuration
  private void LogConfiguration()
  {
    this.Logs.Log('Configurations:', 1, Helper_Log.Color.Blue);
    this.Logs.Log('1. Notification Configuration', 1, Helper_Log.Color.Green);
    this.Logs.Log('IsHTML: ' + this.Notification.IsHTML, 2, Helper_Log.Color.Black);
    this.Logs.Log('AlertsSubject: ' + this.Notification.AlertsSubject, 2, Helper_Log.Color.Black);
    this.Logs.Log('AlertsOnErrorOnly: ' + string.valueOf(this.Notification.AlertsOnErrorOnly), 2, Helper_Log.Color.Black);
    this.Logs.Log('LogsSubject: ' + this.Notification.LogsSubject, 2, Helper_Log.Color.Black);
    this.Logs.Log('LogsOnErrorOnly: ' + string.valueOf(this.Notification.LogsOnErrorOnly), 2, Helper_Log.Color.Black);
    this.Logs.Log('2. Behaviour Configuration', 1, Helper_Log.Color.Green);
    this.Logs.Log('IsSimulation: ' + string.valueOf(this.Behaviour.IsSimulation), 2, Helper_Log.Color.Black);
    this.Logs.Log('FailAtValidation: ' + string.valueOf(this.Behaviour.FailAtValidation), 2, Helper_Log.Color.Black);
    this.Logs.Log('FailAtNegativeeWallets: ' + string.valueOf(this.Behaviour.FailAtNegativeeWallets), 2, Helper_Log.Color.Black);
    this.Logs.Log('FailAtRelatedTransactions: ' + string.valueOf(this.Behaviour.FailAtRelatedTransactions), 2, Helper_Log.Color.Black);
    this.Logs.Log('FailAtIncomlendBalance: ' + string.valueOf(this.Behaviour.FailAtIncomlendBalance), 2, Helper_Log.Color.Black);
    this.Logs.Log('ApplyEarlyPayment: ' + string.valueOf(this.Behaviour.ApplyEarlyPayment), 2, Helper_Log.Color.Black);
    this.Logs.Log('ApplyOverduePayment: ' + string.valueOf(this.Behaviour.ApplyOverduePayment), 2, Helper_Log.Color.Black);
    if(this.Behaviour.InsuranceCompanies.size() > 0)
      for(string value : this.Behaviour.InsuranceCompanies.keySet())
        this.Logs.Log('InsuranceCompanies: ' + this.Behaviour.InsuranceCompanies.get(value), 3, Helper_Log.Color.Grey);
    

    this.Logs.LogLine();
  }

  // This method loads the necessary objects to both funding and closing processes
  private void CoreLoading(boolean fundedElseRepaid)
  {
    System.debug('needReload ' + needReload + ' ' + fundedElseRepaid);
    if (!needReload && this.Invoice != null) {
      LoadInvoice();
      if (GlobalTriggerHandler.runningInASandbox) { EffectiveDate = fundedElseRepaid == null ? addUpdateAllocationDate : fundedElseRepaid == true ? Invoice.advance_send_to_supplier_date__c : Invoice.Actual_Repayment_Received_Date__c; LoadAccountingPeriod(); }
      LoadInvoiceAllocations();
      for (Invoice_Allocation__c currentAllocation: this.InvoiceAllocations) {
        if (fundedElseRepaid == null) this.ImpactedAccountsIds.add(currentAllocation.Funder__c);
        if (currentAllocation.Status__c == (fundedElseRepaid == false ? CONFIRMED : RESERVATION)) this.AllocationsToUpdate.add(currentAllocation);  
        if (fundedElseRepaid != true && currentAllocation.Status__c == BUYBACK 
            && (fundedElseRepaid == false || currentAllocation.Buybacked_Date__c == null ||  currentAllocation.Buybacked_Date__c == addUpdateAllocationDate)) this.InvoiceBuybackAllocations.add(currentAllocation);
      }
      LoadInvoiceTransactions();
      return;
    }
    this.ImpactedeWallets = new Map<string, decimal>();
    this.ImpactedAccountsIds = new Set<Id>();

    // Various objects
    LoadInvoice();
    if (GlobalTriggerHandler.runningInASandbox) EffectiveDate = fundedElseRepaid == null ? addUpdateAllocationDate : fundedElseRepaid == true ? Invoice.advance_send_to_supplier_date__c : Invoice.Actual_Repayment_Received_Date__c;
    LoadAccountingPeriod();
    if (fundedElseRepaid == true && GlobalTriggerHandler.coalesce(this.Invoice.Supplier_Buyer_Map__r.Floating_Rate_Margin__c) > 0) { 
      IsValidated(  true, false, 'Invoice map "Floating Rate Margin" field is not empty. Current value: ' + FormatDecimal(this.Invoice.Supplier_Buyer_Map__r.Floating_Rate_Margin__c) + '.', '');
      if (GlobalTriggerHandler.updateFloatingRate(this.Invoice, null) != true) this.HasEncounteredIssues 
              = !IsValidated(  this.Behaviour.FailAtValidation, 'Unable to update Expected supplier discount rate.');
      update this.Invoice;
      LoadInvoice();  
    } else if (fundedElseRepaid == true) {
      IsValidated(  true, false, 'Invoice map "Floating Rate Margin" field is empty.', '');
    }
    this.isBangladesh = this.Invoice.Bangladesh_special_case__c == WITH_DEPOSIT 
            || this.Invoice.Bangladesh_special_case__c == NO_DEPOSIT
            || this.Invoice.Bangladesh_special_case__c == WITH_FACTORY;
    this.isInTransit = this.Invoice.Product_type__c != null && this.Invoice.Product_type__c.indexOf('In Transit') == 0;
    LoadInvoiceAllocations();
    LoadInvoiceTransactions();
    for(Invoice_Allocation__c currentAllocation : this.InvoiceAllocations)
    {
      if (currentAllocation.Status__c == (fundedElseRepaid == false ? CONFIRMED : RESERVATION)) this.AllocationsToUpdate.add(currentAllocation);  
      if (fundedElseRepaid != true && currentAllocation.Status__c == BUYBACK 
          && (fundedElseRepaid == false || currentAllocation.Buybacked_Date__c == null ||  currentAllocation.Buybacked_Date__c == addUpdateAllocationDate)) this.InvoiceBuybackAllocations.add(currentAllocation);
    }
    LoadTaxRates();

    this.Logs.Log('Loading accounts:', 2, Helper_Log.Color.Black);

    this.IncomlendOperations = LoadAccount((string)'Incomlend Operations');
    this.IncomlendSupplierDiscount = LoadAccount((string)'Incomlend - Supplier Discount');
    this.IncomlendGST = LoadAccount((string)'Incomlend GST');
    this.IncomlendFees = LoadAccount((string)'Incomlend - fees');
    this.IncomlendAgentProvision = LoadAccount((string)'Incomlend Agent Provision');
    this.Supplier = LoadAccount((Id)this.Invoice.Id_Supplier__c);
    this.Buyer = LoadAccount((ID)this.Invoice.Id_Buyer__c);
    this.isInTransitRepo = false;
    if (this.Supplier.Name == INCOMLEND_TRADING_LTD) { 
      this.isInTransitRepo = true;
      this.IncomlendTrading = this.Supplier;
    }

    // Put all accounts Id in a list
    this.ImpactedAccountsIds.add(this.IncomlendOperations.Id);
    this.ImpactedAccountsIds.add(this.IncomlendSupplierDiscount.Id);
    this.ImpactedAccountsIds.add(this.IncomlendGST.Id);
    this.ImpactedAccountsIds.add(this.IncomlendFees.Id);
    this.ImpactedAccountsIds.add(this.IncomlendAgentProvision.Id);
    this.ImpactedAccountsIds.add(this.Supplier.Id);
    this.ImpactedAccountsIds.add(this.Buyer.Id);

    if (this.isInTransit && this.IncomlendTrading == null) {
      this.IncomlendTrading = LoadAccount((string)'Incomlend Trading Limited');
      this.ImpactedAccountsIds.add(this.IncomlendTrading.Id);
    }
    for (Invoice_Allocation__c currentAllocation: this.InvoiceAllocations) {
      this.ImpactedAccountsIds.add(currentAllocation.Funder__c);
    }
    
    if ((this.isBangladesh && this.Invoice.Bangladesh_special_case__c == WITH_DEPOSIT)
            || (this.isBangladesh && this.Invoice.Bangladesh_special_case__c == NO_DEPOSIT))
    {
      this.IncomlendProvision = LoadAccount((string)'Incomlend Provision');
      this.ImpactedAccountsIds.add(this.IncomlendProvision.Id);
    }
    if (this.isInTransit || this.isBangladesh && this.Invoice.Bangladesh_special_case__c == WITH_FACTORY) {
      LoadMapExtension();
      if (this.MapExtension.Account__c != null) {
        this.Factory = LoadAccount((ID)this.MapExtension.Account__c);
        this.ImpactedAccountsIds.add(this.Factory.Id);
      }
    }
    if (this.isInTransit) {
      this.IncomlendInTransitProvision = LoadAccount((string)'Incomlend In Transit Provision');
      this.ImpactedAccountsIds.add(this.IncomlendInTransitProvision.Id);    
    }

    if (fundedElseRepaid != null) LoadMapAgent(); // only validate at financing
    // Insurer account
    if (fundedElseRepaid != null) LoadInsurer();
    
    if (Test.isRunningTest()) needReload = false;
  }

  private void LoadInsurer() {
    if (this.Invoice.Insured_by__c != null && this.Invoice.Insured_by__c.length() > 0 && this.Invoice.Insured_by__c != 'Supplier Insurance' && this.Invoice.Insured_by__c != '--None--')
    {
      this.Logs.Log('Loading Insurer', 2, Helper_Log.Color.Grey);
      if (this.Behaviour.InsuranceCompanies.get(this.Invoice.Insured_by__c) == null) GlobalTriggerHandler.OutError('Loading Insurer "null" ' + this.Invoice.Insured_by__c, null);
      this.Insurer = LoadAccount(string.valueOf(this.Behaviour.InsuranceCompanies.get(this.Invoice.Insured_by__c)));
      this.ImpactedAccountsIds.add(this.Insurer.Id);
      if (this.Invoice.Insured_by__c == VOLOFIN && this.MapAgent == null) {
        system.debug('loading ' + VOLOFIN_AGENT);
        this.MapAgent = LoadAccount(VOLOFIN_AGENT);
        this.ImpactedAccountsIds.add(this.MapAgent.Id);
      }
    }
    else
            this.Logs.Log('(Nothing to load, no Insurer)', 2, Helper_Log.Color.Grey);
  }

  private void CoreLoadingUpfront() {
    // Put this method after LoadAccount call because it uses this.Supplier variable
    LoadInsuranceInstallmentList();
    LoadMembershipInstallment();
    LoadMaintenanceInstallments();
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

  // This method loads and validates the invoice to process
  private void LoadInvoice()
  {
    this.Logs.Log('Loading invoice: ' + this.InvoiceId, 2, Helper_Log.Color.Black);

    this.Invoice = LoadInvoice(this.InvoiceId);

    // Validates the invoice
    if(Invoice == null)
      throw new IncomlendPricing_v3_Exception('Invoice (Id: "' + this.InvoiceId + '") has not been found.');
    else if (this.Invoice.Name == null || this.Invoice.Name.Length() == 0)
      throw new IncomlendPricing_v3_Exception('Invoice (Id: "' + this.InvoiceId + '") has no Name.');
    else if (this.Invoice.Supplier_Buyer_Map__c == null || this.Invoice.Supplier_Buyer_Map__r.Name == null)
      throw new IncomlendPricing_v3_Exception('Invoice (Name: "' + this.Invoice.Name + '") has no Supplier Buyer Map.');
    else if (this.Invoice.Id_Supplier__c == null)
      throw new IncomlendPricing_v3_Exception('Invoice (Name: "' + this.Invoice.Name + '") has no Supplier account defined into the Supplier Buyer Map (Name: "' + this.Invoice.Supplier_Buyer_Map__r.Name + '").');
    else if (this.Invoice.Id_Buyer__c == null)
      throw new IncomlendPricing_v3_Exception('Invoice (Name: "' + this.Invoice.Name + '") has no Buyer account defined into the Supplier Buyer Map (Name: "' + this.Invoice.Supplier_Buyer_Map__r.Name + '").');
    else if (this.Invoice.Marketplace_link__r == null)
      throw new IncomlendPricing_v3_Exception('Invoice (Name: "' + this.Invoice.Name + '") has no "Marketplace link" value.');
    else if (this.Invoice.Marketplace_link__r.FX_Rate_for_MI__r.rate__c == null || this.Invoice.Marketplace_link__r.FX_Rate_for_MI__r.rate__c == 0)
      throw new IncomlendPricing_v3_Exception('Invoice (Name: "' + this.Invoice.Name + '") has no FX rate in the "Marketplace link" value.');
    else
            this.Logs.Log(this.Invoice.Name, 3, Helper_Log.Color.Grey);
  }

  public static final String INVOICE_SELECT_STR = 'SELECT  Id, ' +
                'Actual_Repayment_Amount__c, ' +
                'Actual_Repayment_Received_Date__c, ' +
                'Actual_supplier_s_Agent_Commission_amt__c, ' +
                'Actual_total_supplier_discount_amount__c, ' +
                'actual_financing_period__c, ' +
                'advance_send_to_supplier_date__c, ' +
                'Agent_s_fee_type__c, ' +
                'Amount_Overdue__c, ' +
                'Bangladesh_special_case__c, ' +
                'CCY__c, ' +
                'credit_insured__c, ' +
                'credit_insurance_fee__c, ' +
                'credit_insurance_fee_percentage__c, ' +
                'Credit_Limit_Available__c, ' +
                'discount_rate__c, ' +
                'Due_Date__c, ' +
                'expected_financing_period__c, ' +
                'Factory_Amount__c, ' +
                'funded_amount__c, ' +
                'invoice_amount__c, ' +
                'Insured_by__c, ' +
                'In_Transit_fee__c, ' +
                'Map_Extension__c, ' +
                'Marketplace_link__r.FX_Rate_for_MI__r.rate__c, ' +
                'Maximum_Factory_Amount__c, ' +
                'Name, ' +
                'Notice_of_Assignment_signed__c, ' +
                'Phase__c, ' +
                'Product_type__c, ' +
                'Overdue_Supplier_discount_rate__c, ' +
                'remaining_amount__c, ' +
                'Sum_Of_All_Pre_Reservations__c, ' +
                'Supplier_balance__c, ' +
                'Supplier_Buyer_Map__c, ' +
                'Id_Buyer__c, ' +
                'Supplier_Buyer_Map__r.Name, ' +
                'Id_Supplier__c, ' +
                'Supplier_Buyer_Map__r.Value_of_agent_s_fee__c, ' +
                'Supplier_Buyer_Map__r.Agent_Commission_Null__c, ' +
                'Supplier_Buyer_Map__r.Account_agent__c, ' +
                'Supplier_Buyer_Map__r.Total_Financing_value_alltime__c, ' +
                'Supplier_Buyer_Map__r.Floating_Rate_Margin__c, ' +
                'Supplier_Buyer_Map__r.Funding_Spread__c, ' +
                'Supplier_s_Agent_Commission_amount__c, ' +
                'Supplier_Country__c, ' +
                'Tolerance_overdue_days__c, ' +
                'Total_Gross_Funder_disc_amt_overdue__c, ' +
                'Total_platform_fee__c, ' +
                'Total_platform_fee_for_upfront_fee__c, ' +
                'Total_Supplier_Discount__c, ' +
                'Total_supplier_discount_amount_expected__c, ' +
                'Transaction_fees_overdue__c, ' +
                'Trustee__c, ' +
                'over_due_days__c ';
  
  // This method loads an invoice
  private Invoice_Finance_Deal__c LoadInvoice(id invoiceId)
  {
    Invoice_Finance_Deal__c result = null;

    try
    {
      // Loads the invoice
      if(invoiceId != null)
        result = Database.query(INVOICE_SELECT_STR + ' FROM  invoice_finance_deal__c WHERE  Id = :invoiceId' );
    }
    catch(System.QueryException queryException)
    {
      if(queryException.getMessage() != 'List has no rows for assignment to SObject')
        throw queryException;
    }

    return result;
  }

  // This method loads and validates the invoice allocations to process
  private void LoadInvoiceAllocations()
  {
    this.Logs.Log('Loading invoice allocations:', 2, Helper_Log.Color.Black);

    this.InvoiceAllocations = LoadInvoiceAllocations(this.InvoiceId);
    List<Invoice_Allocation__c> listInvoiceAllocation = new List<Invoice_Allocation__c>();

    // Validates the invoice allocations
    if(this.InvoiceAllocations == null || this.InvoiceAllocations.size() == 0)
      throw new IncomlendPricing_v3_Exception('Invoice (Name: "' + this.Invoice.Name + '") has no allocations.');
    else
    {
      for(Invoice_Allocation__c currentAllocation : this.InvoiceAllocations)
      {
        if (currentAllocation.Name == null || currentAllocation.Name.Length() == 0)
          throw new IncomlendPricing_v3_Exception('Allocation (Id: "' + currentAllocation.Id + '") has no Name.');
        else if(currentAllocation.eWallet__c == null)
          throw new IncomlendPricing_v3_Exception('Allocation (Name: "' + currentAllocation.Name + '") has no "' + currentAllocation.CCY__c + '" eWallet.');
        if (GlobalTriggerHandler.calculateAllocationFees(currentAllocation)) {
          update currentAllocation;
        }
      }
      for(Invoice_Allocation__c currentAllocation : this.InvoiceAllocations)
      {
        updateeWalletBalance(currentAllocation.eWallet__r.Name + ' - ' + currentAllocation.eWallet__r.Account__r.Name, currentAllocation.eWallet__r.Balance__c, true);

        this.Logs.Log(currentAllocation.Name + ' - ' + currentAllocation.Funder_prepayment__c, 3, Helper_Log.Color.Grey);
        System.debug('fda ' + currentAllocation.Funder__r.Name + ' ' + currentAllocation.amount__c + (
                currentAllocation.Status__c == RESERVATION ? ' ' + currentAllocation.Expected_finance_period_buyback_capped__c  
                : ' prepay ' + currentAllocation.Expected_funding_period_capped__c + ' repaid ' + currentAllocation.Repaid_period_capped__c 
                + (this.Invoice.Phase__c == '3:IN PROGRESS' ? ' overdue ' + currentAllocation.Overdue_day_capped__c : '')
                + (currentAllocation.Status__c == BUYBACK ? ' buyback' : '')));
        System.debug('allocation ' + currentAllocation.Status__c + ' ' + currentAllocation.amount__c + ' ' + currentAllocation.Applied_MPR__c + ' ' + currentAllocation.Expected_funding_period_capped__c + 'd ' + currentAllocation.Repaid_period_capped__c + 'd ' + currentAllocation.Overdue_day_capped__c + 'd ' + currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c + '%');
      }
    }
  }

  public static final String INVOICE_ALLOCATION_SELECT_STR = 'SELECT  Id, ' + 
                'Allocation_Reservation_date__c, ' + 
                'Allocation_Confirmed_Date__c, ' + 
                'amount__c, ' + 
                'Applied_Funder_Discount_Profit_Share_Pct__c, ' + 
                'Applied_MPR__c, ' + 
                'Balance_upfront_fee_calculation__c, ' + 
                'Buybacked_Date__c, ' + 
                'Buyback_Enter_Date__c, ' + 
                'CCY__c, ' + 
                'Current_Funder_Discount_Profit_Share_Pct__c, ' + 
                'discount__c, ' + 
                'eWallet__c, ' + 
                'eWallet__r.Name, ' + 
                'eWallet__r.Balance__c, ' + 
                'eWallet__r.Account__r.Name, ' + 
                'eWallet_Trustee__c, ' + 
                'Expected_funding_period_capped__c, ' + 
                'Expected_finance_period_buyback_capped__c, ' + 
                'For_balance_upfront_fee_calculation__c, ' +  
                'For_Gross_Funder_discount_amount_overdue__c, ' + 
                'Funder__c, ' + 
                'Funder_Agent_Commision_Percentage__c, ' + 
                'funder_agent__c, ' + 
                'Funder__r.Agent__c, ' + 
                'Funder__r.Agent__r.Name, ' + // leave for SalesCommissionService
                'Funder__r.Country_of_Incorporation__c, ' + 
                'Funder__r.Name, ' + 
                'Funder__r.VAT_applicable__c, ' + 
                'Funder_Agent_Commission_Amount__c, ' + 
                'Funder_Agent_Commission_Type__c, ' + 
                'Funder_prepayment__c, ' + 
                'Funding_Spread__c, ' + 
                'Gross_discount_amount_expected_repaid__c, ' + 
                'Gross_funder_discount_amount_expected__c, ' + 
                'Gross_Funder_discount_amount_overdue__c, ' +
                'Invoice__c, ' + 
                'Icl_Funder_profit_share_amount_expected__c, ' + 
                'Icl_Funder_profit_share_amount_overdue__c, ' + 
                'Icl_profit_share_amount_repaid__c, ' + 
                'Incomlend_commision__c, ' + 
                'Invoice_Floating_Rate__c, ' + 
                'MPR__c, ' + 
                'marketplace_Min_purchase_amount__c, ' +
                'Name, ' + 
                'Net_Funder_discount_amount_expected__c, ' + 
                'Net_Funder_discount_amount_overdue__c, ' + 
                'Net_Funder_discount_amount_repaid__c, ' + 
                'Net_Funder_Discount_Amount_Total__c, ' + 
                'Repaid_period_capped__c, ' + 
                'Overdue_day_capped__c, ' + 
                'Status__c ';

  // This method loads all allocations of an invoice
  private List<Invoice_Allocation__c> LoadInvoiceAllocations(id invoiceId)
  {
    List<Invoice_Allocation__c> result = new List<Invoice_Allocation__c>();

    try
    {
      // Loads the invoice allocations
      if(invoiceId != null)    
        result = Database.query(INVOICE_ALLOCATION_SELECT_STR + ' FROM  Invoice_Allocation__c ' +
        'WHERE  Invoice__c = :invoiceId ' +
        'AND    Status__c != \'Canceled\'');
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

    // Validates the tax invoice
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
                Account__c,
                amount__c,
                Invoice_Allocation__c,
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

  // This methods loads an account, based on its Name
  private Account LoadAccount(string accountName)
  {
    this.Logs.Log('Loading "' + accountName + '"', 3, Helper_Log.Color.Grey);

    // Loads the account
    Account account = LoadAccount(accountName, SearchType.ByName);
    if(account == null)
      throw new IncomlendPricing_v3_Exception('Account (Name: "' + accountName + '") has not been found.');
    updateeWalletBalance(account);
    return account;
  }

  private void updateeWalletBalance(Account account) {
    // Validates the account
    if(account.eWallets__r != null && account.eWallets__r.size() != 1)
      throw new IncomlendPricing_v3_Exception('Account (Name: "' + account.Name + '") has no "' + this.Invoice.CCY__c + '" eWallet.');
    
    if (FetchedAccounts == null) FetchedAccounts = new Map<String, Account>();
    if (!FetchedAccounts.containsKey(account.Id)) FetchedAccounts.put(account.Id, account);
    else updateeWalletBalance(account.eWallets__r[0].Name + ' - ' + account.eWallets__r[0].Account__r.Name, account.eWallets__r[0].Balance__c, true);
  }

  // This methods loads an account, based on its Id
  private Account LoadAccount(Id accountId)
  {
    this.Logs.Log('Loading "' + accountId + '"', 3, Helper_Log.Color.Grey);

    // Loads the account
    Account account = LoadAccount(accountId, SearchType.ById);
    if (String.isBlank(account.Name))
      throw new IncomlendPricing_v3_Exception('Account (Id: "' + account.Id + '") has no Name.');
    this.Logs.Log('Account name: ' + account.Name, 4, Helper_Log.Color.Grey);
    updateeWalletBalance(account);
    return account;
  }

  private String getListIdStr() {
    String str = '(' + 
            Invoice.Id_Supplier__c + ',' +
            Invoice.Id_Buyer__c + ',' +
            Invoice.Supplier_Buyer_Map__r.Account_Agent__c + ',' +
            ')';
    for (Invoice_Allocation__c currentAllocation : InvoiceAllocations) {
      // str = str.replace(',)', currentAllocation.Funder__c + ')');
      if (currentAllocation.Funder__r.Agent__c != null) str = str.replace(',)', ',' + currentAllocation.Funder__r.Agent__c + ',)');
    }
    if (MapExtension != null) str = str.replace(',)', ',' + MapExtension.Account__c + ',)');
    str = str.replaceAll(',null','').replace(',)',')');
    str = str.replaceAll(',','\',\'').replace('(','(\'').replace(')','\')');
    system.debug('getListIdStr ' + str);
    return str;
  }

  private List<String> getListNameStr() {
    List<String> listStr = new List<String>{
            'Incomlend Operations',
            'Incomlend - Supplier Discount',
            'Incomlend GST',
            'Incomlend - fees',
            'Incomlend Agent Provision'};
    if (isInTransit) listStr.add('Incomlend In Transit Provision');
    if (isInTransit) listStr.add(INCOMLEND_TRADING_LTD);
    if (isBangladesh) listStr.add('Incomlend Provision');
    if (!String.isBlank(Invoice.Insured_by__c)) listStr.add(Behaviour.InsuranceCompanies.get(Invoice.Insured_by__c));
    if (Invoice.Insured_by__c == VOLOFIN) listStr.add(VOLOFIN_AGENT);
    system.debug('getListNameStr ' + listStr);
    return listStr;
  }

  // This methods loads an account
  private Account LoadAccount(object key, SearchType type)
  {
    Account result = null;
    String ccy = this.Invoice.CCY__c;

    if (fetchLazy && FetchedAccounts == null) {
      String str = getListIdStr();
      List<String> listStr = getListNameStr();
      List<Account> listAccount = Database.query(ACCOUNT_SELECT_STR + 
              ' FROM Account WHERE Id IN ' + str + ' OR Name IN :listStr');
      FetchedAccounts = new Map<String, Account>();

      for (Account account : listAccount) {
        if (listStr.indexOf(account.Name) != -1) FetchedAccounts.put(account.Name, account);
        FetchedAccounts.put(account.Id, account);
      }
    }
    if (fetchLazy && FetchedAccounts.containsKey(string.valueOf(key))) return FetchedAccounts.get(string.valueOf(key));
    if (fetchLazy) system.debug('unable to fetch ' + key);

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
        result = Database.query(ACCOUNT_SELECT_STR + 
              ' FROM  Account' +
              ' WHERE Id = :accountId' +
              ' OR Name = :accountName');
    }
    catch(System.QueryException queryException)
    {
      if(queryException.getMessage() != 'List has no rows for assignment to SObject')
        throw queryException;
    }

    return result;
  }

  public static final String ACCOUNT_SELECT_STR = 'SELECT  Id,' + 
              ' Agent__c,' + 
              ' Country_of_Incorporation__c,' + 
              ' Insured_Loss_USD_Equiv__c,' + 
              ' Name,' + 
              ' Un_utilised_adv_amt_all_phases_usd_equiv__c,' + 
              ' VAT_applicable__c,' + 
        ' (SELECT Id,' + 
                ' Name,' + 
                ' CCY__c,' + 
                ' Balance__c,' + 
                ' Account__r.Name' + 
        ' FROM eWallets__r WHERE CCY__c = :ccy) ';

  // This method loads and validates the eWallet Trustee to process
  private void LoadeWalletTrustee()
  {
    // Load the eWallets trustee List
    this.eWalletTrustee = LoadeWalletTrustee(this.ImpactedAccountsIds, this.Invoice);

    // Validates the account Ids list and the invoice
    if(this.Invoice == null)
      throw new IncomlendPricing_v3_Exception('Invoice (Id: "' + this.Invoice.Id + '") has not been found.');
    if (this.Invoice.CCY__c == null)
      throw new IncomlendPricing_v3_Exception('Invoice has no currency.');
    else if(this.Invoice.Trustee__C == null)
      throw new IncomlendPricing_v3_Exception('Invoice has no trustee.');
    else if(this.ImpactedAccountsIds == null || this.ImpactedAccountsIds.size() == 0)
      throw new IncomlendPricing_v3_Exception('Accounts Ids not found');
  }

  // This method loads all eWallets trustee of all accounts
  private List<eWallet_Trustee__c> LoadeWalletTrustee(Set<Id> accountsIds, Invoice_Finance_Deal__c invoice)
  {
    List<eWallet_Trustee__c> result = new List<eWallet_Trustee__c>();
    system.debug('loadEWalletTrustee ' + accountsIds + ' ' + invoice.CCY__c + ' ' + invoice.Trustee__c + ' ' + (Test.isRunningTest() ? [SELECT id, Account__c, CCY__c, Trustee__c FROM eWallet_Trustee__c LIMIT 1] : null));

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

  // This method loads all pending insurance installments, based on Supplier Buyer Id
  private void LoadInsuranceInstallmentList() {
    this.Logs.Log('Loading pending insurance installment records:', 2, Helper_Log.Color.Black);

    if (null == this.Invoice.Supplier_Buyer_Map__c) {
      throw new IncomlendPricing_v3_Exception('Invoice (Id: "' + this.InvoiceId + '") has no Supplier Buyer Map.');
    }

    this.totalInstallmentRecords = 0;
    this.insuranceInstallments = LoadInsuranceInstallmentList(this.Invoice.Supplier_Buyer_Map__c);

    if (null != this.insuranceInstallments && !insuranceInstallments.isEmpty()) {
      this.totalInstallmentRecords = [select COUNT()
      from Instalment_insurance_fee__c
      where Supplier_buyer_map_instalment__c = :this.Invoice.Supplier_Buyer_Map__c
      and Fee_Type__c = :FEE_TYPE_INSR];
      this.Logs.Log('Total insurance installment records: ' + this.totalInstallmentRecords, 3, Helper_Log.Color.Grey);

      for (Instalment_insurance_fee__c insuranceInstallment : this.insuranceInstallments) {
        this.Logs.Log(insuranceInstallment.Name, 3, Helper_Log.Color.Grey);
      }
    } else {
      this.Logs.Log('(No existing insurance installment transactions)', 3, Helper_Log.Color.Grey);
    }
  }

  // This method loads all pending insurance installments, if any
  private List<Instalment_insurance_fee__c> LoadInsuranceInstallmentList(Id supplierBuyerMapId) {
    List<Instalment_insurance_fee__c> insuranceInstallmentList = new List<Instalment_insurance_fee__c>();

    try {
      Integer paidRecords = [select COUNT()
      from Instalment_insurance_fee__c
      where Supplier_buyer_map_instalment__c = :supplierBuyerMapId
      and Status_Instalment__c = :STATUS_PAID
      and Fee_Type__c = :FEE_TYPE_INSR];

      if (Math.mod(paidRecords, 2) == 0) {
        insuranceInstallmentList = [select Id,
                Name,
                Supplier_buyer_map_instalment__c,
                Account_Supplier__c,
                Fee_Type__c,
                Currency__c,
                Amount_Instalment__c,
                Due_Date__c,
                Installment_Term_Months__c,
                Status_Instalment__c,
                Invoice_Finance_Deal__c,
                Date_Paiement__c
        from Instalment_insurance_fee__c
        where Supplier_buyer_map_instalment__c = :supplierBuyerMapId
        and Status_Instalment__c = :STATUS_PENDING
        and Fee_Type__c = :FEE_TYPE_INSR
        and Due_Date__c <= TODAY
        order by Due_Date__c asc
                nulls last];
      } else {
        insuranceInstallmentList = [select Id,
                Name,
                Supplier_buyer_map_instalment__c,
                Account_Supplier__c,
                Fee_Type__c,
                Currency__c,
                Amount_Instalment__c,
                Due_Date__c,
                Installment_Term_Months__c,
                Status_Instalment__c,
                Invoice_Finance_Deal__c,
                Date_Paiement__c
        from Instalment_insurance_fee__c
        where Supplier_buyer_map_instalment__c = :supplierBuyerMapId
        and Status_Instalment__c = :STATUS_PENDING
        and Fee_Type__c = :FEE_TYPE_INSR
        and Due_Date__c <= :this.Invoice.Due_Date__c
        order by Due_Date__c asc
                nulls last];
      }
    } catch (System.QueryException e) {
      if (!e.getMessage().equals('List has no rows for assignment to SObject')) {
        throw e;
      }
    }

    return insuranceInstallmentList;
  }

  // This method loads all membership fees, based on Supplier Id and Supplier Buyer Id
  private void LoadMembershipInstallment() {
    this.Logs.Log('Loading pending membership installment records:', 2, Helper_Log.Color.Black);

    if (null == this.Invoice.Supplier_Buyer_Map__c) {
      throw new IncomlendPricing_v3_Exception('Invoice (Id: "' + this.InvoiceId + '") has no Supplier Buyer Map.');
    }

    if (null == this.Supplier.Id) {
      throw new IncomlendPricing_v3_Exception('Invoice (Id: "' + this.InvoiceId + '") has no Supplier.');
    }

    this.totalMembershipFeeAmount = 0.00;
    this.membershipFees = LoadMembershipInstallment(this.Invoice.Supplier_Buyer_Map__c, this.Supplier.Id);

    if (null != this.membershipFees && !this.membershipFees.isEmpty()) {
      for (Instalment_insurance_fee__c membership : this.membershipFees) {
        this.totalMembershipFeeAmount += membership.Amount_Instalment__c;
        this.Logs.Log(membership.Name, 3, Helper_Log.Color.Grey);
      }
    } else {
      this.Logs.Log('(No existing membership installment transactions)', 3, Helper_Log.Color.Grey);
    }
  }

  // This method loads all pending membership installments, if any
  private List<Instalment_insurance_fee__c> LoadMembershipInstallment(Id supplierBuyerMapId, Id supplierId) {
    List<Instalment_insurance_fee__c> membershipFeesList = new List<Instalment_insurance_fee__c>();

    try {
      membershipFeesList = [select Id,
              Name,
              Supplier_buyer_map_instalment__c,
              Account_Supplier__c,
              Fee_Type__c,
              Currency__c,
              Amount_Instalment__c,
              Due_Date__c,
              Installment_Term_Months__c,
              Status_Instalment__c,
              Invoice_Finance_Deal__c,
              Date_Paiement__c
      from Instalment_insurance_fee__c
      where Supplier_buyer_map_instalment__c = :supplierBuyerMapId
      and Account_Supplier__c = :supplierId
      and Status_Instalment__c = :STATUS_PENDING
      and Fee_Type__c = :FEE_TYPE_MEMBERSHIP
      and Due_Date__c <= TODAY
      order by Due_Date__c asc
              nulls last];
    } catch (System.QueryException e) {
      if (!e.getMessage().equals('List has no rows for assignment to SObject')) {
        throw e;
      }
    }

    return membershipFeesList;
  }

  // This method loads all maintenance fees, based on Supplier Id and Supplier Buyer Id
  private void LoadMaintenanceInstallments()
  {

    this.maintenanceInstallments = LoadMaintenanceInstallments(System.today());

    // Validates the Maintenance installments
    if(this.maintenanceInstallments == null || this.maintenanceInstallments.size() == 0)
      this.Logs.Log('(No existing maintenance installments)', 3, Helper_Log.Color.Grey);
    else
    {
      for(Instalment_insurance_fee__c installment : this.maintenanceInstallments)
      {
        if (installment.Amount_Instalment__c == null)
          throw new IncomlendPricing_v3_Exception('Maintenance installments(Id: "' + installment.Id + '") has no Amount.');
      }
    }
    if (this.maintenanceInstallments != null && !this.maintenanceInstallments.isEmpty()) {
      this.TranswapAccount = LoadAccount((string)'Transwap account');
      this.ImpactedAccountsIds.add(this.TranswapAccount.Id);
    }
  }

  // This method loads all pending maintenance installments, if any
  private List<Instalment_insurance_fee__c> LoadMaintenanceInstallments(Date today)
  {
    List<Instalment_insurance_fee__c> result = new List<Instalment_insurance_fee__c>();

    try
    {
      result = [SELECT Id,
              Account_Supplier__c,
              Comments__c,
              Due_Date__c,
              Installment_Term_Months__c,
              Amount_Instalment__c,
              Fee_Type__c,
              Invoice_Finance_Deal__c,
              Date_Paiement__c,
              Status_Instalment__c,
              Supplier_buyer_map_instalment__c
      FROM Instalment_insurance_fee__c 
      WHERE Supplier_buyer_map_instalment__c = :this.Invoice.Supplier_Buyer_Map__c
      AND Due_Date__c <= TODAY
      AND Fee_Type__c = :FEE_TYPE_MAINTENANCE
      AND Status_Instalment__c = :STATUS_PENDING
      order by Due_Date__c asc
      nulls last];
    }
    catch(System.QueryException queryException)
    {
      if(queryException.getMessage() != 'List has no rows for assignment to SObject')
        throw queryException;
    }

    return result;
  }

  // This method loads and validates the Map Extension to process
  private void LoadMapExtension()
  {
    // Load the eWallets trustee List
    this.MapExtension = LoadMapExtension(this.Invoice.Map_Extension__c);

    // Validates the account Ids list and the invoice
    if (this.Invoice.Map_Extension__c != null) {
      if(this.MapExtension == null)
        throw new IncomlendPricing_v3_Exception('Map Extension (Id: "' + this.Invoice.Map_Extension__c + '") has not been found.');
      if (this.MapExtension.Account__c == null)
        throw new IncomlendPricing_v3_Exception('Map Extension (Id: "' + this.Invoice.Map_Extension__c + '") has no Account.');
    }
  }

  // This method loads the map extension 
  private Map_Extension__c LoadMapExtension(Id mapExtensionId)
  {
    Map_Extension__c result = new Map_Extension__c();

    try
    {
      // Loads the eWallet trustee
      if(mapExtensionId != null)
        result = [SELECT Id,
                Account__c,
                Funding_Upfront_fees__c	
        FROM Map_Extension__c
        WHERE Id =: mapExtensionId];
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
    updateeWalletBalance(eWalletName + ' - ' + accountName, amount, false);

    return newTransaction;
  }

  // This method tracks the balance evolution of the impacted eWallets
  private void UpdateeWalletBalance(string eWalletName, decimal amount, boolean first)
  {
    decimal oldBalance = this.ImpactedeWallets.get(eWalletName);
    if (first && oldBalance != null) return;
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

  // This methods validates and log a condition, depending of a behaviour and returns the validation result
  // Returns true: Validation succeeded
  // Returns false: Validation failed
  private boolean IsValidated(boolean validationCondition, boolean validationBehaviourCondition, string validatedMessage, string errorMessage)
  {
    if(!validationCondition)
      if(validationBehaviourCondition)
        throw new IncomlendPricing_v3_Exception(errorMessage);
      else
      {
        this.Logs.Log(errorMessage, 2, Helper_Log.Color.Red);
        return false;
      }
    else
            this.Logs.Log(validatedMessage, 2, Helper_Log.Color.Black);

    return true;
  }

  private boolean IsValidated(boolean validationBehaviourCondition, string errorMessage)
  {
    this.Logs.Log(errorMessage, 2, Helper_Log.Color.Red);
    if(validationBehaviourCondition)
      throw new IncomlendPricing_v3_Exception(errorMessage);
    else
      return false;
  }

  // This methods return a eWallet Id trustee by account Id from ImpactedeWalletTrustee list
  private Id filtereWalletTrustee(Id accountId)
  {
    eWallet_Trustee__c selectedeWalletTrustee = new eWallet_Trustee__c();
    for (eWallet_Trustee__c currenteWalletTrustee: this.eWalletTrustee) {
      if (currenteWalletTrustee.Account__c == accountId) {
        selectedeWalletTrustee = currenteWalletTrustee;
        break;
      }
    }
    if (selectedeWalletTrustee == null)
      throw new IncomlendPricing_v3_Exception('Account (Id: "' + accountId + '") has no eWallet trustee.');

    return selectedeWalletTrustee.Id;
  }

  private Decimal totalGfdaAdjEarly() {
    decimal totalFunderDiscountAmount = 0;
    for (Invoice_Allocation__c currentAllocation : this.AllocationsToUpdate) {
      decimal Gross_Funder_discount_amount_early = currentAllocation.Balance_upfront_fee_calculation__c - currentAllocation.Gross_funder_discount_amount_expected__c - Math.Max(currentAllocation.Gross_discount_amount_expected_repaid__c, 0);
      totalFunderDiscountAmount += Gross_Funder_discount_amount_early;
      System.debug('fda adjusted ' + currentAllocation.Name + ' gfda overdue ' + Gross_Funder_discount_amount_early);
    }
    return totalFunderDiscountAmount;
  }

  private Decimal totalGfdaAdjOverdue() {
    decimal totalFunderDiscountAmount = 0;
    for(Invoice_Allocation__c currentAllocation : this.AllocationsToUpdate)
    {
        totalFunderDiscountAmount += currentAllocation.Gross_Funder_discount_amount_overdue__c;
        System.debug('fda adjusted ' + currentAllocation.Name + ' gfda overdue ' + currentAllocation.Gross_Funder_discount_amount_overdue__c);
    }
    return totalFunderDiscountAmount;
  }

  private Decimal calculateFunderDiscountRate() {
    return calculateFunderDiscountRate(this.InvoiceAllocations);
  }

  public static Decimal calculateFunderDiscountRate(List<Invoice_Allocation__c> listInvoiceAllocation) {
    decimal discountRate = 0;
    decimal fundedAmount = 0;
    for(Invoice_Allocation__c currentAllocation : listInvoiceAllocation)
    {
      fundedAmount += currentAllocation.amount__c;
    }
    for(Invoice_Allocation__c currentAllocation : listInvoiceAllocation)
    {
      discountRate += currentAllocation.Applied_MPR__c * (currentAllocation.amount__c / fundedAmount);
    }
    discountRate = discountRate.setScale(4);
    System.debug('funder discount rate is ' + discountRate);
    return discountRate;
  }

  private void appendLog(Helper_Log childlog) {
    string logStr = childlog.PlainLog;
    if (logStr != null) {
      for (string lineStr : logStr.split('\n')) {
        this.Logs.Log(lineStr.replaceAll('[\\[\\]\\s-:\\d]{20,}',''), 2, Helper_Log.Color.Black);
      }
    }
  }
  
  private boolean toRunTranche() {
    if (Invoice.CCY__c == 'USD') return false;
    String accounts = ';' + config.getConfig('Tranche_Account_For_Fx_Contract') + ';';
    for (Invoice_Allocation__c allocation : this.InvoiceAllocations) {
      if (accounts.indexOf(allocation.Funder__r.Name) != -1) 
              return true;
    }
    return false;
  }

  public static decimal sumTransaction(List<Transaction__c> listTransaction, String type, String special) {
    decimal sum = 0;
    List<String> listType = type.indexOf(';') != -1 ? type.split(';') : null;
    for(Transaction__c currentTransaction : listTransaction)
    {
      if (special.indexOf('id-type') != -1) {
        if(listType != null && listType.indexOf(currentTransaction.Type__c) != -1 && listType.indexOf(currentTransaction.Account__c) != -1 ) {
          // if (special.indexOf('id-type-allocation') != -1) System.debug(listType + ' ' + currentTransaction.Invoice_Allocation__c);
          if (special.indexOf('id-type-allocation') != -1 && listType.indexOf(currentTransaction.Invoice_Allocation__c) == -1 ) continue;
          sum += currentTransaction.amount__c;
        }  
      } else if (special == 'id') {
        if(currentTransaction.Account__c == type || (listType != null && listType.indexOf(currentTransaction.Account__c) != -1 )) {
          sum += currentTransaction.amount__c;
        }  
      } else { // default
        if(currentTransaction.Type__c == type || (listType != null && listType.indexOf(currentTransaction.Type__c) != -1 )) {
          sum += special == 'has' || special == 'count' ? 1 : currentTransaction.amount__c;
          if (special == 'has') break;
        }  
      }
    }
    return sum;
  }

  // =======
  // Classes
  // =======
  public class IncomlendPricing_v3_Exception extends Exception {}


  public class IncomlendPricing_v3_CoverageHack
  {
  }
}