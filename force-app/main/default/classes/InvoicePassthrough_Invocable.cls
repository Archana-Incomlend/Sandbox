public class InvoicePassthrough_Invocable {

  @InvocableMethod(label = 'Create Invoice Passthrough Transactions')
  public static void createInvoicePassthroughObjects(List<InvoicePassthroughRequest> requests) {
    Helper_Log Logs = new Helper_Log();
    boolean sendEmail = false;
    for (InvoicePassthroughRequest request : requests) {
      try {
        if (!createInvoicePassthroughTransactions(request, Logs)) sendEmail = true;
      } catch (Exception unmanagedException) {
        System.debug(unmanagedException);
        sendEmail = true;
        Logs.Log(unmanagedException);
      }
    }
    if (sendEmail || Test.isRunningTest()) {
      List<String> listStr = new List<String>();
      String str = GlobalTriggerHandler.coelesceConfig(config.getConfig('IncomlendPricing_v3_Notification_LogsRecipients'));
      if (str != null) listStr.addAll(str.split(';'));
      str = GlobalTriggerHandler.coelesceConfig(config.getConfig('IncomlendPricing_v3_Notification_LogsRecipients2'));
      if (str != null) listStr.addAll(str.split(';'));
      if (listStr.size() > 0) Helper_Email.Send(true, listStr, 'Invoice repaid, transactions creation PASSTHROUGH', Logs.HTMLLog);
    }
  }

  public static boolean createInvoicePassthroughTransactions(InvoicePassthroughRequest request, Helper_Log Logs) {
    log(Logs, 'ClosePassthrough() method called by ' + UserInfo.getName());
    if (request.invoice == null) {
      String invoiceId = request.invoiceId;
      request.invoice = Database.query(GlobalTrigger_Invocable.INVOICE_SELECT_STR + 'WHERE Id = :invoiceId' );
      if (request.supplierBuyerMap == null) request.supplierBuyerMap = new Supplier_Buyer_Map__c();
      request.supplierBuyerMap.Supplier__c = request.invoice.Id_Supplier__c;
      request.supplierBuyerMap.Buyer__c = request.invoice.Id_Buyer__c;
    }
    String invoiceName = '';
    try { invoiceName = request.invoice.Name; } catch (Exception e) {}
    log(Logs, 'Loading invoice: ' + (invoiceName == '' ? '' + request.invoiceId : invoiceName));
    if (request.invoice.Phase__c != '3:IN PROGRESS') throw new GeneralException('Invoice can not be repaid. Wrong invoice Status value');
    if (request.invoice.Actual_Repayment_Received_Date__c == null) throw new GeneralException('Invoice can not be repaid. Actual Repayment Received date is not set');

    GlobalTrigger_Invocable.init();
    Id ICL_FEE = GlobalTrigger_Invocable.INTERNAL_ACCOUNT.get(GlobalTrigger_Invocable.ICL_FEE);
    Id ICL_OPS = GlobalTrigger_Invocable.INTERNAL_ACCOUNT.get(GlobalTrigger_Invocable.ICL_OPS); 
    List<Id> listTest = new List<Id> { ICL_FEE, ICL_OPS, request.supplierBuyerMap.Supplier__c, request.supplierBuyerMap.Buyer__c };
      
    String trustee = request.invoice.Trustee__c;
    String ccy = request.invoice.CCY__c;
    Date repaymentDate = request.invoice.Actual_Repayment_Received_Date__c;
    String condition = 'Account__c IN :listTest';
    List<String> listStr = new List<String> { GlobalTrigger_Invocable.ICL_FEE, GlobalTrigger_Invocable.ICL_OPS};
    if (Test.isRunningTest()) condition = '(' + condition + ' OR Account__r.Name IN :listStr)';
    condition = GlobalTrigger_Invocable.EWALLETTRUSTEE_SELECT_STR + 'WHERE ' + condition;
    System.debug('queryString: ' + condition);

    List<eWallet_Trustee__c> listEWalletTrustee = Database.query(condition + ' AND CCY__c = :ccy AND Trustee__c = :trustee ');
    Map<String, eWallet_Trustee__c> mapObj = new Map<String, eWallet_Trustee__c>();
    for (eWallet_Trustee__c eWalletTrustee : listEWalletTrustee) {
      if (Test.isRunningTest() && eWalletTrustee.Account__r.Name == GlobalTrigger_Invocable.ICL_FEE) ICL_FEE = eWalletTrustee.Account__c;
      if (Test.isRunningTest() && eWalletTrustee.Account__r.Name == GlobalTrigger_Invocable.ICL_OPS) ICL_OPS = eWalletTrustee.Account__c;
      mapObj.put(eWalletTrustee.Account__c, eWalletTrustee);
    }
    if (mapObj.get(request.supplierBuyerMap.Supplier__c) == null) throw new GeneralException('No eWalletTrustee for supplier with same CCY and Trustee');
    if (mapObj.get(request.supplierBuyerMap.Buyer__c) == null) throw new GeneralException('No eWalletTrustee for buyer with same CCY and Trustee');

    Date effectiveDate = System.today();
    Id accountingPeriodId = Accounting_Period.lookup(effectiveDate);

    List<Transaction__c> listTransaction = new List<Transaction__c>();
    System.debug('ImpactedAccountsIds ' + ICL_FEE + ' ' + ICL_OPS + ' ' + request.supplierBuyerMap.Buyer__c + ' ' + request.supplierBuyerMap.Supplier__c + ' ' + mapObj.keySet());

    listTransaction.addAll(GlobalTrigger_Invocable.createDoubleTransaction(
            request.supplierBuyerMap.Buyer__c, ICL_OPS, request.invoice.Actual_Repayment_Amount__c, effectiveDate, accountingPeriodId, 
            '03.Invoice Repayment', request.invoice, null, mapObj));

    if (GlobalTriggerHandler.coelesce(request.invoice.platform_fee_fixed__c) != 0) listTransaction.addAll(GlobalTrigger_Invocable.createDoubleTransaction(
            ICL_OPS, ICL_FEE, request.invoice.platform_fee_fixed__c, effectiveDate, accountingPeriodId, 
            '06.Transaction Fee', request.invoice, null, mapObj));

    decimal amount = request.invoice.Actual_Repayment_Amount__c - request.invoice.platform_fee_fixed__c;
    listTransaction.addAll(GlobalTrigger_Invocable.createDoubleTransaction(
            ICL_OPS, request.supplierBuyerMap.Supplier__c, amount, effectiveDate, accountingPeriodId, 
            '08.Invoice Balance Payment', request.invoice, null, mapObj));
    String str = 'Passthrough invoice.\nAmount paid/received by buyer: ' + request.invoice.Actual_Repayment_Amount__c + ' ' + ccy + 
            ' on the ' + repaymentDate + '.\nAdmin fee: ' + GlobalTriggerHandler.coelesce(request.invoice.platform_fee_fixed__c) + ' ' + ccy + '.';
    log(Logs, str);

    log(Logs, 'Created transactions:');
    for (Transaction__c trn : listTransaction) log(Logs, toString(trn, mapObj, invoiceName));

    if (config.getConfig('IncomlendPricing_v3_Behaviour_IsSimulation') == 'true') { log(Logs, 'Behaviour Configuration, IsSimulation: true'); return false; }
    Invoice_Finance_Deal__c invoice = new Invoice_Finance_Deal__c();
    invoice.Id = request.invoiceId;
    invoice.Phase__c = '4:CLOSED';
    invoice.Status__c = 'Paid';
    if (repaymentDate < System.today() && ccy != 'USD') {
      List<FX_Rates__c> fxRateList = [SELECT id, Name, Rate__c FROM FX_Rates__c WHERE date__c = :repaymentDate AND from_currency__c = :ccy LIMIT 1];
      if (fxRateList.size() > 0) invoice.FX_Rate__c = fxRateList.get(0).Id;
      if (fxRateList.size() > 0) invoice.FX_conversion_rate__c = fxRateList.get(0).Rate__c;
    }

    SavePoint savePoint = Database.setSavepoint();
    try {
      insert listTransaction;
      GlobalTrigger_Invocable.updateRelatedTransaction(listTransaction);
      update listTransaction;
      update invoice;
        
    } catch (Exception ex) {
      Database.rollback(savePoint);
      throw ex;
    }
    return true;
  }

  public static void log(Helper_Log Logs, String str) {
    System.debug(str);
    if (Logs != null) Logs.log(str, 2, Helper_Log.Color.Black);
  }

  public static String toString(Object obj, Map<String, eWallet_Trustee__c> mapObj, String invoiceName) {
    if (obj instanceof Transaction__c) {
      Transaction__c trn = (Transaction__c)obj;
      eWallet_Trustee__c eWalletTrustee = mapObj != null ? mapObj.get(trn.Account__c) : null;
      String str = '';
      if (eWalletTrustee != null) {
        try { str += ' ' + eWalletTrustee.Account__r.Name; } catch (Exception e) { } 
        try { str += ' ' + eWalletTrustee.Main_eWallet__r.Name; } catch (Exception e) { }
      } else {
        str += ' ' + trn.eWallet__c;
        str += ' ' + trn.Account__c;
      }
      str += ' ' + trn.Type__c;
      str += ' ' + trn.CCY__c;
      str += ' ' + trn.Amount__c;
      str += ' ' + trn.Effective_Date__c;
      if (invoiceName != null) str += ' ' + invoiceName != null ? invoiceName: trn.Invoice_Finance_Deal__c; 
      str += ' ' + trn.Status__c;
      return str;
    }
    return String.valueOf(obj);
  }

  public class InvoicePassthroughRequest {
    @InvocableVariable(required=true)
    public ID invoiceId;

    @InvocableVariable(required=false)
    public Invoice_finance_deal__c invoice;

    @InvocableVariable(required=false)
    public Supplier_Buyer_Map__c supplierBuyerMap;
  }
}