@isTest
private class InvoiceCreateRepaymentObjectsTest {
  private static Map<String, Object> setup() {
    Map<String, Object> result = SeedTest.init(null, null, 'funded', 1000000, 0.77);

    Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');
    invoice.Due_Date__c = Date.today().addMonths(-3);
    invoice.Expected_Payment_Date__c = Date.today().addMonths(-3);
    invoice.advance_send_to_supplier_date__c = Date.today().addMonths(-6);
    invoice.Overdue_sSupplier_discount_rate__c = 0.83;
    invoice.Total_Supplier_Discount__c = 0.77;
    invoice.discount_rate__c = 0.75;
    update invoice;

    Invoice_Allocation__c allocationOne = (Invoice_Allocation__c)result.get('invAllocation');
    allocationOne.Applied_Funder_Discount_Profit_Share_Pct__c = 10.00;
    allocationOne.Applied_MPR__c = 0.75;
    allocationOne.amount__c = 450000;
    update allocationOne;

    Invoice_Allocation__c allocationTwo = allocationOne.clone(false, false, false, false);
    allocationTwo.Id = null;
    allocationTwo.Applied_Funder_Discount_Profit_Share_Pct__c = 10.00;
    allocationTwo.Applied_MPR__c = 0.75;
    allocationTwo.amount__c = 200000;
    allocationTwo.Funder_prepayment__c = 'Net EFDA -15days';
    insert allocationTwo;

    Invoice_Allocation__c allocationThree = allocationOne.clone(false, false, false, false);
    allocationThree.Id = null;
    allocationThree.Applied_Funder_Discount_Profit_Share_Pct__c = 10.00;
    allocationThree.Applied_MPR__c = 0.75;
    allocationThree.amount__c = 150000;
    allocationThree.Invoice__c = invoice.Id;
    allocationThree.Funder_prepayment__c = 'Net EFDA -15days';
    insert allocationThree;

    Invoice_Allocation__c allocationFour = allocationOne.clone(false, false, false, false);
    allocationFour.Id = null;
    allocationFour.Applied_Funder_Discount_Profit_Share_Pct__c = 10.00;
    allocationFour.Applied_MPR__c = 0.75;
    allocationFour.amount__c = 100000;
    allocationFour.Funder_prepayment__c = 'Net EFDA -15days';
    insert allocationFour;

    return result;
  }

  private static testMethod void overdueCappedRepaymentSuccess() {
    Map<String, Object> result = setup();
    Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');
    Id invoiceId = invoice.Id;

    InvoiceCreateRepaymentObjects invoiceCreateRepaymentObjects = new InvoiceCreateRepaymentObjects(
        invoiceId,
        450000,
        Date.today().addDays(120),
        true,
        true);

    boolean isCreatedSuccessfully = invoiceCreateRepaymentObjects.createInvoicePartialRepaymentObjects();
    System.assertEquals(true, isCreatedSuccessfully);
  }

  private static testMethod void overdueNotCappedRepaymentSuccess() {
    Map<String, Object> result = setup();
    Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');
    Id invoiceId = invoice.Id;

    InvoiceCreateRepaymentObjects invoiceCreateRepaymentObjects = new InvoiceCreateRepaymentObjects(
        invoiceId,
        450000,
        Date.today().addDays(120),
        false,
        true);

    boolean isCreatedSuccessfully = invoiceCreateRepaymentObjects.createInvoicePartialRepaymentObjects();
    System.assertEquals(true, isCreatedSuccessfully);
  }

  private static testMethod void notSimulationRepaymentSuccess() {
    Map<String, Object> result = setup();
    Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');
    Id invoiceId = invoice.Id;

    InvoiceCreateRepaymentObjects invoiceCreateRepaymentObjects = new InvoiceCreateRepaymentObjects(
        invoiceId,
        450000,
        Date.today().addDays(120),
        true,
        false);

    boolean isCreatedSuccessfully = invoiceCreateRepaymentObjects.createInvoicePartialRepaymentObjects();
    System.assertEquals(true, isCreatedSuccessfully);
  }

  private static testMethod void fullRepaymentSuccess() {
    Map<String, Object> result = setup();
    Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');
    Id invoiceId = invoice.Id;

    InvoiceCreateRepaymentObjects invoiceCreateRepaymentObjects = new InvoiceCreateRepaymentObjects(
        invoiceId,
        1000000,
        Date.today().addDays(120),
        true,
        false);

    boolean isCreatedSuccessfully = invoiceCreateRepaymentObjects.createInvoicePartialRepaymentObjects();
    System.assertEquals(true, isCreatedSuccessfully);
  }

  private static testMethod void noRemainingAmountSuccess() {
    Map<String, Object> result = setup();
    Invoice_finance_deal__c updatedInvoice = (Invoice_finance_deal__c)result.get('invoice');

    updatedInvoice.Repaid_Funded_Amount__c = 1000000;
    updatedInvoice.Repaid_Amount__c = 1000000;
    update updatedInvoice;

    InvoiceCreateRepaymentObjects invoiceCreateRepaymentObjects = new InvoiceCreateRepaymentObjects(
        updatedInvoice.Id,
        450000,
        Date.today().addDays(120),
        true,
        false);

    boolean isCreatedSuccessfully = invoiceCreateRepaymentObjects.createInvoicePartialRepaymentObjects();
    System.assertEquals(true, isCreatedSuccessfully);
  }

  private static testMethod void nullInvoice() {
    InvoiceCreateRepaymentObjects invoiceCreateRepaymentObjects = new InvoiceCreateRepaymentObjects(
        'a09p0000007Y2yS',
        450000,
        Date.today().addDays(120),
        true,
        true);

    boolean isCreatedSuccessfully = invoiceCreateRepaymentObjects.createInvoicePartialRepaymentObjects();
    System.assertEquals(false, isCreatedSuccessfully);
  }

  private static testMethod void noAllocation() {
    Map<String, Object> result = SeedTest.init(null, null, 'funded', 1000000, 0.77);
                    
    invoice_finance_deal__c invoiceNoAlloc = (Invoice_finance_deal__c)result.get('invoice');
    invoiceNoAlloc.Due_Date__c = Date.today().addMonths(-3);
    invoiceNoAlloc.Expected_Payment_Date__c = Date.today().addMonths(-3);
    invoiceNoAlloc.advance_send_to_supplier_date__c = Date.today().addMonths(-6);
    invoiceNoAlloc.Overdue_sSupplier_discount_rate__c = 0.83;
    invoiceNoAlloc.discount_rate__c = 0;
    update invoiceNoAlloc;

    Invoice_Allocation__c allocation = (Invoice_Allocation__c)result.get('invAllocation');
    delete allocation;

    Id invoiceId = invoiceNoAlloc.Id;

    InvoiceCreateRepaymentObjects invoiceCreateRepaymentObjects = new InvoiceCreateRepaymentObjects(
        invoiceId,
        450000,
        Date.today().addDays(120),
        true,
        true);

    boolean isCreatedSuccessfully = invoiceCreateRepaymentObjects.createInvoicePartialRepaymentObjects();
    System.assertEquals(false, isCreatedSuccessfully);
  }

  private static testMethod void noMarketPlace() {
    Map<String, Object> result = setUp();
    invoice_finance_deal__c updatedInvoice = (Invoice_finance_deal__c)result.get('invoice');
    updatedInvoice.Marketplace_link__c = null;
    update updatedInvoice;

    InvoiceCreateRepaymentObjects invoiceCreateRepaymentObjects = new InvoiceCreateRepaymentObjects(
        updatedInvoice.Id,
        450000,
        Date.today().addDays(120),
        true,
        true);

    boolean isCreatedSuccessfully = invoiceCreateRepaymentObjects.createInvoicePartialRepaymentObjects();
    System.assertEquals(false, isCreatedSuccessfully);
  }

  private static testMethod void invoiceWithActiveRepayment() {
    Map<String, Object> result = setUp();
    invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');
    Id invoiceId = invoice.Id;

    Invoice_Repayment__c invoiceRepayment = new Invoice_Repayment__c();
    invoiceRepayment.Invoice_Finance_Deal__c = invoiceId;
    invoiceRepayment.Repaid_Amount__c = 100000;
    invoiceRepayment.Due_Date__c = Date.today();
    invoiceRepayment.Capped_Funder_Discount__c = true;
    invoiceRepayment.Remaining_Invoice_Face_Value_Amount__c = 0;
    invoiceRepayment.Remaining_Invoice_Amount__c = 0;
    invoiceRepayment.Supplier_Discount_Amount__c = 0;
    invoiceRepayment.Status__c = 'Pending';
    insert invoiceRepayment;

    InvoiceCreateRepaymentObjects invoiceCreateRepaymentObjects = new InvoiceCreateRepaymentObjects(
        invoiceId,
        450000,
        Date.today().addDays(120),
        true,
        true);

    boolean isCreatedSuccessfully = invoiceCreateRepaymentObjects.createInvoicePartialRepaymentObjects();
    System.assertEquals(false, isCreatedSuccessfully);
  }
}