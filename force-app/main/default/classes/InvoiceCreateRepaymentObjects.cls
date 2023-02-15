// ==========================================================================================================
// InvoiceCreateRepaymentObjects class
// ----------------------------------------------------------------------------------------------------------
// This class manages the creation of new partial repayment objects:
// 1. Invoice Repayment
// 2. Allocation Repayment
//
// Author: John dela Rosa
// ==========================================================================================================
public class InvoiceCreateRepaymentObjects {
  private static final String REPAYMENT_TYPE_ONE = 'Repayment of Funders Capital only';
  private static final String REPAYMENT_TYPE_TWO = 'Repayment of Funders Capital and Discount Amount';
  private static final String REPAYMENT_TYPE_THREE = 'Repayment to all parties';
  private static final String NET_EFDA = 'Net EFDA -15days';
  // ======
  // Fields
  // ======
  private Integer errorCount {
    private get;
    private set;
  }

  private boolean hasEncounteredIssues {
    private get;
    private set;
  }

  private Id invoiceId {
    private get;
    private set;
  }

  private Decimal repaidAmount {
    private get;
    private set;
  }

  private Date dueDate {
    private get;
    private set;
  }

  private String repaymentType {
    private get;
    private set;
  }

  private Boolean isOverdueCapped {
    private get;
    private set;
  }

  private Boolean isSimulation {
    private get;
    private set;
  }

  private Decimal funderRatioNotRounded {
    private get;
    private set;
  }

  private Decimal funderAmountDue {
    private get;
    private set;
  }

  private Decimal remainingRepaidAmount {
    private get;
    private set;
  }

  // ==========
  // Properties
  // ==========
  private Helper_Log logs {
    private get;
    private set;
  }

  private IncomlendPricing_v3_Configuration.NotificationConfiguration notificationConfig {
    get;
    set;
  }

  private IncomlendPricing_v3_Configuration.BehaviourConfiguration behaviourConfig {
    get;
    set;
  }

  // ==============
  // Loaded objects
  // ==============
  private Invoice_Repayment__c existingInvoiceRepayment {
    private get;
    private set;
  }

  private Invoice_finance_deal__c invoice {
    private get;
    private set;
  }

  private List<Invoice_Allocation__c> allocations {
    private get;
    private set;
  }

  public InvoiceCreateRepaymentObjects(Id invoiceId,
      Decimal repaidAmount,
      Date dueDate,
      Boolean isOverdueCapped,
      Boolean isSimulation) {
    this.invoiceId = invoiceId;
    this.repaidAmount = repaidAmount;
    this.dueDate = dueDate;
    repaymentType = REPAYMENT_TYPE_TWO;
    this.isOverdueCapped = isOverdueCapped;
    this.isSimulation = isSimulation;
    logs = new Helper_Log();
  }

  public boolean createInvoicePartialRepaymentObjects() {
    try {
      logs.LogLine();
      logs.Log('createInvoicePartialRepaymentObjects() method called by ' + UserInfo.getName(), 1, Helper_Log.Color.Blue);
      logs.LogLine();

      coreInitialization();
      
      logs.Log('Process Logs:', 1, Helper_Log.Color.Blue);
      logs.Log('1. Loading core data', 1, Helper_Log.Color.Green);
      coreLoading();
      
      logs.Log('3. Validating the data', 1, Helper_Log.Color.Green);
      Boolean failAtValidation = Test.isRunningTest() ? false : behaviourConfig.FailAtValidation;
      validateObjectFields(failAtValidation);

      if (errorCount == 0) {
        logs.Log('1. Creating Invoice Repayment Object', 1, Helper_Log.Color.Green);
        Integer overDueDays = invoice.Due_Date__c.daysBetween(dueDate);
        Integer expectedFinancingPeriod = invoice.advance_send_to_supplier_date__c.daysBetween(invoice.Expected_Payment_Date__c) + 1;
        Decimal remainingFundedAmount = invoice.funded_amount__c - invoice.Repaid_Funded_Amount__c;
        Invoice_Repayment__c invoiceRepayment = initializeInvoiceRepayment();

        List<Allocation_Repayment__c> allocationRepayments = new List<Allocation_Repayment__c>();
        Map<Invoice_Allocation__c, Allocation_Repayment__c> allocationRepaymentMap = new Map<Invoice_Allocation__c, Allocation_Repayment__c>();
        Decimal overdueGrossFunderDiscountAmount = 0;

        for (Invoice_Allocation__c allocation : allocations) {
          Allocation_Repayment__c allocationRepayment = initializeAllocationRepayment(allocation);
          overdueGrossFunderDiscountAmount += computeOverdueGrossFunderDiscountAmountOnRemainingCapital(allocation,
              overDueDays, expectedFinancingPeriod);
          allocationRepaymentMap.put(allocation, allocationRepayment);
        }

        overdueGrossFunderDiscountAmount = REPAYMENT_TYPE_TWO == repaymentType ? overdueGrossFunderDiscountAmount : 0;
        setOtherInvoiceRepaymentFields(invoiceRepayment, remainingFundedAmount, overdueGrossFunderDiscountAmount, overDueDays);
        logInvoiceRepaymentObject(invoiceRepayment, overDueDays);
        overdueGrossFunderDiscountAmount = overdueGrossFunderDiscountAmount.setScale(2, RoundingMode.HALF_UP);

        logs.Log('2. Overdue Gross Discount Amount: ' + formatDecimal(overdueGrossFunderDiscountAmount), 1, Helper_Log.Color.Green);
        logs.Log('3. Creating Allocation Repayments Object', 1, Helper_Log.Color.Green);
        for (Invoice_Allocation__c allocation : allocationRepaymentMap.keySet()) {
          Allocation_Repayment__c allocationRepayment = allocationRepaymentMap.get(allocation);
          allocationRepayment.Net_Discount_Amount__c = computeNetFunderDiscountAmount(allocation,
              invoiceRepayment, overDueDays, allocationRepayment, expectedFinancingPeriod);
          allocationRepayments.add(allocationRepayment);
          logAllocationRepaymentObject(allocationRepayment);
        }

        if (!isSimulation) {
          insert invoiceRepayment;

          for (Allocation_Repayment__c allocationRepayment: allocationRepayments) {
            allocationRepayment.Invoice_Repayment__c = invoiceRepayment.Id;
          }

          insert allocationRepayments;
        }

        InvoiceRepayment invoiceRepaymentApex = new InvoiceRepayment(invoice,
            allocationRepaymentMap, invoiceRepayment,
            (overdueGrossFunderDiscountAmount * funderRatioNotRounded).setScale(2, RoundingMode.HALF_UP),
            remainingRepaidAmount,
            isSimulation, notificationConfig, behaviourConfig, logs);

        invoiceRepaymentApex.repayInvoice();
        hasEncounteredIssues = false;
      } else {
        hasEncounteredIssues = true;
      }
    } catch(Exception unmanagedException) {
      logs.Log(unmanagedException);
      hasEncounteredIssues = true;
    } finally {
      if (!Test.isRunningTest()) {
        if (hasEncounteredIssues) {
          Helper_Email.Send(notificationConfig.IsHTML, notificationConfig.AlertsRecipients, notificationConfig.AlertsSubject, logs.HTMLLog);
          Helper_Email.Send(notificationConfig.IsHTML, notificationConfig.LogsRecipients, notificationConfig.LogsSubject, logs.HTMLLog);
        }
      }

      System.debug(this.Logs.PlainLog);
    }

    return !hasEncounteredIssues;
  }

  private void coreInitialization() {
    errorCount = 0;
    hasEncounteredIssues = false;
    funderRatioNotRounded = 0;
    funderAmountDue = 0;
    remainingRepaidAmount = 0;

    if (!Test.isRunningTest()) {
      notificationConfig = new IncomlendPricing_v3_Configuration.NotificationConfiguration();
      behaviourConfig = new IncomlendPricing_v3_Configuration.BehaviourConfiguration();
      logConfiguration();
    }

    logs.LogLine();
  }

  private void logConfiguration() {
    logs.Log('Configurations:', 1, Helper_Log.Color.Blue);
    logs.Log('1. Notification Configuration', 1, Helper_Log.Color.Green);
    logs.Log('IsHTML: ' + notificationConfig.IsHTML, 2, Helper_Log.Color.Black);
    logs.Log('AlertsSubject: ' + notificationConfig.AlertsSubject, 2, Helper_Log.Color.Black);
    logs.Log('AlertsRecipients: ' + notificationConfig.AlertsRecipients, 2, Helper_Log.Color.Black);
    logs.Log('AlertsOnErrorOnly: ' + String.valueOf(notificationConfig.AlertsOnErrorOnly), 2, Helper_Log.Color.Black);
    logs.Log('LogsSubject: ' + notificationConfig.LogsSubject, 2, Helper_Log.Color.Black);
    logs.Log('LogsRecipients: ' + notificationConfig.LogsRecipients, 2, Helper_Log.Color.Black);
    logs.Log('LogsOnErrorOnly: ' + String.valueOf(notificationConfig.LogsOnErrorOnly), 2, Helper_Log.Color.Black);
    logs.Log('2. Behaviour Configuration', 1, Helper_Log.Color.Green);
    logs.Log('IsSimulation: ' + String.valueOf(isSimulation), 2, Helper_Log.Color.Black);
    logs.Log('FailAtValidation: ' + String.valueOf(behaviourConfig.FailAtValidation), 2, Helper_Log.Color.Black);
    logs.Log('FailAtNegativeeWallets: ' + String.valueOf(behaviourConfig.FailAtNegativeeWallets), 2, Helper_Log.Color.Black);
    logs.Log('FailAtRelatedTransactions: ' + String.valueOf(behaviourConfig.FailAtRelatedTransactions), 2, Helper_Log.Color.Black);
    logs.Log('FailAtIncomlendBalance: ' + String.valueOf(behaviourConfig.FailAtIncomlendBalance), 2, Helper_Log.Color.Black);
    logs.Log('ApplyEarlyPayment: ' + String.valueOf(behaviourConfig.ApplyEarlyPayment), 2, Helper_Log.Color.Black);
    logs.Log('ApplyOverduePayment: ' + String.valueOf(behaviourConfig.ApplyOverduePayment), 2, Helper_Log.Color.Black);
    logs.Log('CapEarlyPayment: ' + String.valueOf(behaviourConfig.CapEarlyPayment), 2, Helper_Log.Color.Black);
    logs.Log('CapOverduePayment: ' + String.valueOf(behaviourConfig.CapOverduePayment), 2, Helper_Log.Color.Black);

    if (behaviourConfig.InsuranceCompanies.size() > 0) {
      for (String value : behaviourConfig.InsuranceCompanies.keySet()) {
        logs.Log('InsuranceCompanies: ' + behaviourConfig.InsuranceCompanies.get(value), 3, Helper_Log.Color.Grey);
      }
    }
  }

  private void coreLoading() {
    loadInvoiceRepayment();
    loadInvoice();
    loadAllocations();
  }

  private void loadInvoiceRepayment() {
    logs.Log('Loading existing invoice repayment: ' + invoiceId, 2, Helper_Log.Color.Black);
    
    try {
      if (invoiceId != null) {
        existingInvoiceRepayment = [SELECT Id,
                                      Invoice_Finance_Deal__c,
                                      Name,
                                      Status__c
                                    FROM Invoice_Repayment__c
                                    WHERE Invoice_Finance_Deal__c = :invoiceId
                                    AND Status__c != 'Paid'
                                    AND Status__c != 'Cancelled'];
      }
    } catch(System.QueryException queryException) {
      if (queryException.getMessage() != 'List has no rows for assignment to SObject') {
        throw queryException;
      } else {
        existingInvoiceRepayment = null;
      }
    }
  }

  private void loadInvoice() {
    logs.Log('Loading invoice: ' + invoiceId, 2, Helper_Log.Color.Black);
    invoice = loadInvoice(invoiceId);

    if (invoice == null) {
      throw new InvoiceCreateRepaymentObjectsException('Invoice (Id: "' + invoiceId + '") has not been found.');
    } else if (invoice.Name == null || invoice.Name.Length() == 0) {
      throw new InvoiceCreateRepaymentObjectsException('Invoice (Id: "' + invoiceId + '") has no Name.');
    } else if (invoice.Supplier_Buyer_Map__c == null || invoice.Supplier_Buyer_Map__r.Name == null) {
      throw new InvoiceCreateRepaymentObjectsException('Invoice (Name: "' + invoice.Name + '") has no Supplier Buyer Map.');
    } else if (invoice.Supplier_Buyer_Map__r.Supplier__c == null) {
      throw new InvoiceCreateRepaymentObjectsException('Invoice (Name: "' + invoice.Name + '") has no Supplier account defined into the Supplier Buyer Map (Name: "' + invoice.Supplier_Buyer_Map__r.Name + '").');
    } else if (invoice.Supplier_Buyer_Map__r.Buyer__c == null) {
      throw new InvoiceCreateRepaymentObjectsException('Invoice (Name: "' + invoice.Name + '") has no Buyer account defined into the Supplier Buyer Map (Name: "' + invoice.Supplier_Buyer_Map__r.Name + '").');
    } else if (invoice.Marketplace_link__c == null) {
      throw new InvoiceCreateRepaymentObjectsException('Invoice (Name: "' + invoice.Name + '") has no "Marketplace link" value.');
    } else if (invoice.Marketplace_link__r.FX_Rate_for_MI__c == null || invoice.Marketplace_link__r.FX_Rate_for_MI__r.rate__c == null) {
      throw new InvoiceCreateRepaymentObjectsException('Invoice (Name: "' + invoice.Name + '") has no FX rate in the "Marketplace link" value.');
    } else {
      if (invoice.Repaid_Amount__c == null) {
        invoice.Repaid_Amount__c = 0;
      }

      if (invoice.Repaid_Funded_Amount__c == null) {
        invoice.Repaid_Funded_Amount__c = 0;
      }

      if (invoice.Repaid_Supplier_Balance_Amount__c == null) {
        invoice.Repaid_Supplier_Balance_Amount__c = 0;
      }

      if (invoice.Repaid_Supplier_Discount_Amount__c == null) {
        invoice.Repaid_Supplier_Discount_Amount__c = 0;
      }

      if (invoice.Overdue_Transaction_fees_Net__c == null) {
        invoice.Overdue_Transaction_fees_Net__c = 0;
      }

      logs.Log(invoice.Name, 3, Helper_Log.Color.Grey);
    }
  }

  private Invoice_finance_deal__c loadInvoice(id invoiceId) {
    Invoice_finance_deal__c result = null;

    try {
      if (invoiceId != null) {
        result = [SELECT Id,
                    advance_send_to_supplier_date__c,
                    Amount_Overdue__c,
                    CCY__c,
                    discount_rate__c,
                    Due_Date__c,
                    Expected_Payment_Date__c,
                    funded_amount__c,
                    invoice_amount__c,
                    Marketplace_link__c,
                    Marketplace_link__r.FX_Rate_for_MI__c,
                    Marketplace_link__r.FX_Rate_for_MI__r.rate__c,
                    Name,
                    over_due_days__c,
                    Overdue_Transaction_fees_Net__c,
                    Overdue_Supplier_discount_rate__c,
                    Phase__c,
                    Real_Face_Value__c,
                    Repaid_Amount__c,
                    Repaid_Funded_Amount__c,
                    Repaid_Supplier_Balance_Amount__c,
                    Repaid_Supplier_Discount_Amount__c,
                    Status__c,
                    Supplier_Buyer_Map__c,
                    Supplier_Buyer_Map__r.Buyer__c,
                    Supplier_Buyer_Map__r.Name,
                    Supplier_Buyer_Map__r.Supplier__c,
                    Supplier_Country__c,
                    Tolerance_overdue_days__c,
                    Total_Supplier_Discount__c,
                    Trustee__c
                  FROM invoice_finance_deal__c
                  WHERE Id = :invoiceId];
      }
    } catch(System.QueryException queryException) {
      if (queryException.getMessage() != 'List has no rows for assignment to SObject') {
        throw queryException;
      }
    }

    return result;
  }

  private void loadAllocations() {
    logs.Log('Loading invoice allocations:', 2, Helper_Log.Color.Black);

    allocations = loadAllocations(invoiceId);

    if (allocations == null || allocations.size() == 0) {
      throw new InvoiceCreateRepaymentObjectsException('Invoice (Name: "' + this.Invoice.Name + '") has no allocations.');
    } else {
      for (Invoice_Allocation__c currentAllocation : allocations) {
        if (currentAllocation.Name == null || currentAllocation.Name.Length() == 0) {
          throw new InvoiceCreateRepaymentObjectsException('Allocation (Id: "' + currentAllocation.Id + '") has no Name.');
        } else if(currentAllocation.eWallet__c == null) {
          throw new InvoiceCreateRepaymentObjectsException('Allocation (Name: "' + currentAllocation.Name + '") has no "' + currentAllocation.CCY__c + '"" eWallet.');
        } else {
          if (currentAllocation.Repaid_Amount__c == null) {
            currentAllocation.Repaid_Amount__c = 0;
          }

          if (currentAllocation.Repaid_Discount_Amount__c == null) {
            currentAllocation.Repaid_Discount_Amount__c = 0;
          }
        }

        logs.Log(currentAllocation.Name, 3, Helper_Log.Color.Grey);
      }
    }
  }

  private List<Invoice_Allocation__c> loadAllocations(id invoiceId) {
    List<Invoice_Allocation__c> result = new List<Invoice_Allocation__c>();

    try {
      if (invoiceId != null) {
        result = [SELECT Id,
                    amount__c,
                    Applied_Funder_Discount_Profit_Share_Pct__c,
                    Applied_MPR__c,
                    CCY__c,
                    eWallet__c,
                    eWallet__r.Name,
                    Funder__c,
                    Funder__r.Country_of_Incorporation__c,
                    Funder__r.Name,
                    Funder__r.VAT_applicable__c,
                    Funder_prepayment__c,
                    Name,
                    Net_Funder_discount_amount_expected__c,
                    Repaid_Amount__c,
                    Repaid_Discount_Amount__c,
                    Status__c
                  FROM Invoice_Allocation__c
                  WHERE Invoice__c = :invoiceId
                  AND Status__c != 'Canceled'];
      }
    } catch(System.QueryException queryException) {
      if (queryException.getMessage() != 'List has no rows for assignment to SObject') {
        throw queryException;
      }
    }

    return result;
  }

  private void validateObjectFields(Boolean failAtValidation) {
    isValidated(existingInvoiceRepayment == null,
              failAtValidation,
              'No active repayment agreement for this invoice.',
              'An existing repayment agreement for this invoice.');
      
    isValidated(invoice.Phase__c == '3:IN PROGRESS',
              failAtValidation,
              'Invoice "Phase" field equals 3:IN PROGRESS.',
              'Invoice "Phase" field does not equal 3:IN PROGRESS. Current value: ' + invoice.Phase__c + '.');

    isValidated(invoice.Supplier_Country__c != null,
              failAtValidation,
              'Invoice "Supplier Country" field is not empty. Current value: ' + invoice.Supplier_Country__c + '.',
              'Invoice "Supplier Country" field is empty.');

    isValidated(invoice.funded_amount__c > 0,
              failAtValidation,
              'Field "funded amount" is greater than 0.00: Current value: ' + formatDecimal(invoice.funded_amount__c) + '"',
              'Field "funded amount" is not greater than 0.00: Current value: ' + formatDecimal(invoice.funded_amount__c) + '"');

    isValidated(invoice.invoice_amount__c > 0,
              failAtValidation,
              'Field "invoice amount" is greater than 0.00: Current value: ' + formatDecimal(invoice.invoice_amount__c) + '"',
              'Field "invoice amount" is not greater than 0.00: Current value: ' + formatDecimal(invoice.invoice_amount__c) + '"');

    isValidated(invoice.Real_Face_Value__c > 0,
              failAtValidation,
              'Field "invoice amount" is greater than 0.00: Current value: ' + formatDecimal(invoice.Real_Face_Value__c) + '"',
              'Field "invoice amount" is not greater than 0.00: Current value: ' + formatDecimal(invoice.Real_Face_Value__c) + '"');

    isValidated(invoice.Tolerance_overdue_days__c != null,
              failAtValidation,
              'Invoice "Tolerance overdue days" field is not empty. Current value: ' + formatDecimal(invoice.Tolerance_overdue_days__c) + '.',
              'Invoice "Tolerance overdue days" field is empty.');
      
    isValidated(invoice.Total_Supplier_Discount__c != null,
              failAtValidation,
              'Invoice "Expected Supplier Discount Rate" field is not empty. Current value: ' + formatDecimal(invoice.Total_Supplier_Discount__c) + '.',
              'Invoice "Expected Supplier Discount Rate" field is empty.');

    isValidated(invoice.Overdue_Supplier_discount_rate__c != null,
              failAtValidation,
              'Invoice "Overdue Supplier Discount Rate" field is not empty. Current value: ' + formatDecimal(invoice.Overdue_Supplier_discount_rate__c) + '.',
              'Invoice "Overdue Supplier Discount Rate" field is empty.');

    isValidated(invoice.advance_send_to_supplier_date__c != null,
              failAtValidation,
              'Invoice "advance amount credited to ewallet date" field is not empty. Current value: ' + String.valueOf(invoice.advance_send_to_supplier_date__c) + '.',
              'Invoice "advance amount credited to ewallet date" field is empty.');

    isValidated(invoice.Expected_Payment_Date__c != null,
              failAtValidation,
              'Invoice "Expected Payment Date" field is not empty. Current value: ' + String.valueOf(invoice.Expected_Payment_Date__c) + '.',
              'Invoice "Expected Payment Date" field is empty.');

    isValidated(invoice.discount_rate__c != null,
              failAtValidation,
              'Invoice "Funder Discount Rate Weighted Average" field is not empty. Current value: ' + formatDecimal(invoice.discount_rate__c) + '.',
              'Invoice "Funder Discount Rate Weighted Average" field is empty.');

    for (Invoice_Allocation__c currentAllocation : allocations) {
      isValidated(currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c != null,
              failAtValidation,
              'Invoice allocation ' + currentAllocation.Name + ' "Applied Funder Discount Profit Share Pct" field is not empty. Current value: ' + FormatDecimal(currentAllocation.Applied_Funder_Discount_Profit_Share_Pct__c) + '.',
              'Invoice allocation ' + currentAllocation.Name + ' "Applied Funder Discount Profit Share Pct" field is empty.');

      isValidated(currentAllocation.Funder__r.Country_of_Incorporation__c != null,
              failAtValidation,
              'Funder Account ' + currentAllocation.Funder__r.Name + ' "Country of Incorporation" field is not empty. Current value: ' + currentAllocation.Funder__r.Country_of_Incorporation__c + '.',
              'Funder Account ' + currentAllocation.Funder__r.Name + ' "Country of Incorporation" field is empty.');

      isValidated(currentAllocation.Status__c == 'Confirmed' || currentAllocation.Status__c == 'Repaid invoice deal closed',
              failAtValidation,
              'Allocation "Status" field equals Confirmed or Repaid.',
              'Allocation "Status" field does not equal Confirmed or Repaid. Current value: ' + currentAllocation.Status__c + '.');
        
      isValidated(currentAllocation.Applied_MPR__c > 0,
              failAtValidation,
              'Invoice allocation "Funder discount rate" field is greater than 0.00. Current value: ' + FormatDecimal(currentAllocation.Applied_MPR__c) + '.',
              'Invoice allocation "Funder discount rate" field is not greater than 0.00. Current value: ' + FormatDecimal(currentAllocation.Applied_MPR__c) + '.');
    }
  }

  private Invoice_Repayment__c initializeInvoiceRepayment() {
    Invoice_Repayment__c invoiceRepayment = new Invoice_Repayment__c();
    invoiceRepayment.Invoice_Finance_Deal__c = invoiceId;
    invoiceRepayment.Due_Date__c = dueDate;
    invoiceRepayment.Capped_Funder_Discount__c = isOverdueCapped;
    invoiceRepayment.Remaining_Invoice_Face_Value_Amount__c = invoice.Real_Face_Value__c - invoice.Repaid_Amount__c;
    invoiceRepayment.Repaid_Amount__c = repaidAmount;
    invoiceRepayment.Remaining_Invoice_Amount__c = invoice.Repaid_Amount__c >= invoice.invoice_amount__c ? 0 : invoice.invoice_amount__c - invoice.Repaid_Amount__c;
    invoiceRepayment.Repaid_Invoice_Ratio__c = computeRatio(invoiceRepayment.Remaining_Invoice_Face_Value_Amount__c);

    return invoiceRepayment;
  }

  private Allocation_Repayment__c initializeAllocationRepayment(Invoice_Allocation__c allocation) {
    Allocation_Repayment__c allocationRepayment = new Allocation_Repayment__c();
    allocationRepayment.Invoice_Allocation__c = allocation.Id;

    Decimal remainingAllocationAmount = allocation.amount__c - allocation.Repaid_Amount__c;
    allocationRepayment.Amount__c = remainingAllocationAmount > 0 ? remainingAllocationAmount : 0;
    return allocationRepayment;
  }

  private String formatDecimal(Decimal amount) {
    if (amount == null) {
      return '';
    }

    String strAmount = String.valueOf(amount);
    String separator = '.';

    if (strAmount.contains(',')) {
      separator = ',';
    } else if (strAmount.indexOf(separator) == -1) {
      strAmount = strAmount + '.00';
    }

    strAmount = strAmount.substring(0, strAmount.indexOf(separator));

    if (amount - Decimal.valueOf(strAmount) == 0) {
      return String.valueOf(amount.format()) + separator + '00';
    } else {
      return String.valueOf(amount.format());
    }
  }

  private void isValidated(Boolean validationCondition,
      Boolean validationBehaviourCondition,
      String validatedMessage,
      String errorMessage) {
    if (!validationCondition) {
      if (validationBehaviourCondition) {
        throw new InvoiceCreateRepaymentObjectsException(errorMessage);
      } else {
        logs.Log(errorMessage, 2, Helper_Log.Color.Red);
        errorCount++;
      }
    }
    
    logs.Log(validatedMessage, 2, Helper_Log.Color.Black);
  }

  private Decimal computeAccruedOverdueSupplierDiscountNetAmount(Integer overDueDays,
      Decimal remainingAmount,
      Decimal remainingInvoiceAmount,
      Decimal overdueGrossFunderDiscountAmount) {
    if (remainingInvoiceAmount <= 0) {
      return 0;
    }

    Decimal supplierDiscount = overDueDays > invoice.Tolerance_overdue_days__c ?
        invoice.Overdue_Supplier_discount_rate__c : invoice.Total_Supplier_Discount__c;
    Decimal amountToBeUsed = Math.min(remainingInvoiceAmount, repaidAmount);
    Decimal accruedOverdueSupplierDiscountAmount = (overDueDays * amountToBeUsed * supplierDiscount / 100 / 30);
    accruedOverdueSupplierDiscountAmount = accruedOverdueSupplierDiscountAmount > 0 ? accruedOverdueSupplierDiscountAmount : 0;

    if (REPAYMENT_TYPE_TWO == repaymentType) {
      remainingRepaidAmount = repaidAmount - remainingAmount;
      remainingRepaidAmount = remainingRepaidAmount < 0 ? 0 : remainingRepaidAmount;
      Decimal prorataOverdueGrossFunderDiscountAmount = overdueGrossFunderDiscountAmount * funderRatioNotRounded;
      return computeTotalOverdueSupplierDiscountAmount(accruedOverdueSupplierDiscountAmount,
          remainingAmount, prorataOverdueGrossFunderDiscountAmount);
    } else {
      return accruedOverdueSupplierDiscountAmount.setScale(2, RoundingMode.HALF_UP);
    }
  }

  private Decimal computeTotalOverdueSupplierDiscountAmount(Decimal accruedOverdueSupplierDiscountAmount,
      Decimal remainingAmount,
      Decimal prorataOverdueGrossFunderDiscountAmount) {
    Decimal incomlendTransactionFee = accruedOverdueSupplierDiscountAmount + invoice.Overdue_Transaction_fees_Net__c - prorataOverdueGrossFunderDiscountAmount;
    return (Math.min(incomlendTransactionFee, remainingRepaidAmount) + prorataOverdueGrossFunderDiscountAmount).setScale(2, RoundingMode.HALF_UP);
  }

  private void logInvoiceRepaymentObject(Invoice_Repayment__c invoiceRepayment, Integer overDueDays) {
    logs.Log('Repaid Amount: ' + formatDecimal(repaidAmount), 2, Helper_Log.Color.Black);
    logs.Log('Due Date: ' + invoiceRepayment.Due_Date__c, 2, Helper_Log.Color.Black);
    logs.Log('Is Overdue Capped: ' + String.valueOf(invoiceRepayment.Capped_Funder_Discount__c), 2, Helper_Log.Color.Black);
    logs.Log('Remaining Invoice Face Value Amount: ' + formatDecimal(invoiceRepayment.Remaining_Invoice_Face_Value_Amount__c), 2, Helper_Log.Color.Black);
    logs.Log('Remaining Invoice Amount: ' + formatDecimal(invoiceRepayment.Remaining_Invoice_Amount__c), 2, Helper_Log.Color.Black);
    logs.Log('Funder Amount: ' + formatDecimal(invoiceRepayment.Funder_Amount__c), 2, Helper_Log.Color.Black);
    logs.Log('Funder Amount Due: ' + formatDecimal(funderAmountDue), 2, Helper_Log.Color.Black);
    logs.Log('Supplier Discount Amount: ' + formatDecimal(invoiceRepayment.Supplier_Discount_Amount__c), 2, Helper_Log.Color.Black);
    logs.Log('Overdue Days: ' + formatDecimal(overDueDays), 2, Helper_Log.Color.Black);
    logs.Log('Repaid Ratio: ' + formatDecimal(invoiceRepayment.Repaid_Invoice_Ratio__c), 2, Helper_Log.Color.Black);
    logs.Log('Rounded Funder Amount Ratio: ' + formatDecimal(invoiceRepayment.Funder_Amount_Ratio__c), 2, Helper_Log.Color.Black);
    logs.Log('Remaining Repaid Amount: ' + formatDecimal(remainingRepaidAmount), 2, Helper_Log.Color.Black);
  }

  private Decimal computeRatio(Decimal remainingAmount) {
    if (remainingAmount > 0) {
      if (repaidAmount >= remainingAmount) {
        funderRatioNotRounded = 1;
        return 1;
      } else {
        Decimal ratio = repaidAmount / remainingAmount;
        funderRatioNotRounded = ratio;
        return ratio.setScale(2, RoundingMode.HALF_UP);
      }
    } else {
      funderRatioNotRounded = 0;
      return 0;
    }
  }

  private void setOtherInvoiceRepaymentFields(Invoice_Repayment__c InvoiceRepayment,
      Decimal remainingFundedAmount,
      Decimal overdueGrossFunderDiscountAmount,
      Integer overDueDays) {
    Decimal remainingAmount = 0;
    
    if (REPAYMENT_TYPE_TWO == repaymentType) {
      remainingAmount = remainingFundedAmount + overdueGrossFunderDiscountAmount;
    } else {
      remainingAmount = invoiceRepayment.Remaining_Invoice_Amount__c;
    }

    remainingAmount = remainingAmount > 0 ? remainingAmount.setScale(2, RoundingMode.HALF_UP) : 0;
    funderAmountDue = remainingAmount;
    
    invoiceRepayment.Funder_Amount_Ratio__c = computeRatio(remainingAmount);
    invoiceRepayment.Funder_Amount__c = ((remainingAmount - overdueGrossFunderDiscountAmount) * funderRatioNotRounded).setScale(2, RoundingMode.HALF_UP);
    invoiceRepayment.Supplier_Discount_Amount__c = computeAccruedOverdueSupplierDiscountNetAmount(
        overDueDays, remainingAmount, invoiceRepayment.Remaining_Invoice_Amount__c, overdueGrossFunderDiscountAmount);
  }

  private Decimal computeOverdueGrossFunderDiscountAmountOnRemainingCapital(
      Invoice_Allocation__c allocation,
      Integer overDueDays,
      Integer expectedFinancingPeriod) {
    Integer capOverdueDays = 60;

    if (!Test.isRunningTest()) {
      capOverdueDays = behaviourConfig.CapOverduePayment;
    }

    Integer financingPeriod = !isOverdueCapped ? overDueDays : Math.min(capOverdueDays, overDueDays);
    return (allocation.amount__c - allocation.Repaid_Amount__c) * financingPeriod * allocation.Applied_MPR__c / 100 / 30;
  }

  private Decimal computeNetFunderDiscountAmount(Invoice_Allocation__c allocation,
      Invoice_Repayment__c invoiceRepayment,
      Integer overDueDays,
      Allocation_Repayment__c allocationRepayment,
      Integer expectedFinancingPeriod) {
    Decimal remainingAllocationAmount = allocation.amount__c - allocation.Repaid_Amount__c;
    Integer capOverdueDays = 60;

    if (!Test.isRunningTest()) {
      capOverdueDays = behaviourConfig.CapOverduePayment;
    }

    Integer financingPeriod = !isOverdueCapped ? overDueDays : Math.min(capOverdueDays, overDueDays);

    if (NET_EFDA == allocation.Funder_prepayment__c) {
      financingPeriod = financingPeriod + 15;
    } else {
      financingPeriod = financingPeriod + expectedFinancingPeriod;
    }

    allocationRepayment.Amount__c = remainingAllocationAmount > 0 ? (remainingAllocationAmount * funderRatioNotRounded).setScale(2, RoundingMode.HALF_UP) : 0;
    return invoiceRepayment.Remaining_Invoice_Amount__c <= 0 || funderRatioNotRounded == 0 ? 0 :
        (allocationRepayment.Amount__c * financingPeriod * allocation.Applied_MPR__c / 100 / 30 *
            (1 - (allocation.Applied_Funder_Discount_Profit_Share_Pct__c / 100))).setScale(2, RoundingMode.HALF_UP);
  }

  private void logAllocationRepaymentObject(Allocation_Repayment__c allocationRepayment) {
    logs.Log('Amount: ' + formatDecimal(allocationRepayment.Amount__c), 2, Helper_Log.Color.Black);
    logs.Log('Net Discount Amount: ' + formatDecimal(allocationRepayment.Net_Discount_Amount__c), 2, Helper_Log.Color.Black);
  }

  public class InvoiceCreateRepaymentObjectsException extends Exception {

  }
}