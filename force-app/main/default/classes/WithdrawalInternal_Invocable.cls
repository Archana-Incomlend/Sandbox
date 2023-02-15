public class WithdrawalInternal_Invocable {

  public static String WITHDRAWAL_DEPOSIT_SELECT_STR = 'SELECT Id, Name, CCY__c, Account__c, Bank_Account__c, Amount__c, Actual_Amount__c, Type__c, Trustee__c FROM Withdrawal_Deposit__c ';
  public static String BANK_ACCOUNT_SELECT_STR = 'SELECT Id, Name, Account__c, For_Internal_Related_Account__c FROM Bank_Account__c ';

  @InvocableMethod(label = 'Create Transactions Withdrawal Internal')
  public static void createWithdrawalInternalObjects(List<WithdrawalInternalRequest> requests) {
    Helper_Log Logs = new Helper_Log();
    boolean sendEmail = false;
    Exception ex = null;
    for (WithdrawalInternalRequest request : requests) {
      try {
        if (!createWithdrawalInternalTransactions(request, Logs)) sendEmail = true;
      } catch (Exception unmanagedException) {
        System.debug(unmanagedException);
        Logs.Log(unmanagedException);
        sendEmail = true;
        ex = new GeneralException(unmanagedException.getMessage());
      }
    }
    if (sendEmail) GlobalTriggerHandler.OutError('Create Transactions Withdrawal Internal fail', Logs);
    if (ex != null) throw ex;
  }

  public static boolean createWithdrawalInternalTransactions(WithdrawalInternalRequest request, Helper_Log Logs) {
    log(Logs, 'Create Transactions Withdrawal Internal called by ' + UserInfo.getName());
    log(Logs, 'Loading withdrawal deposit: ' + (request.withdrawalDeposit == null ? '' + request.recordId : request.withdrawalDeposit.Name));
    if (request.withdrawalDeposit == null) {
      String recordId = request.recordId;
      if (recordId == null) throw new GeneralException('Input missing recordId');
      request.withdrawalDeposit = Database.query(WITHDRAWAL_DEPOSIT_SELECT_STR + 'WHERE Id = :recordId' );
    }
    if (request.withdrawalDeposit.Type__c != '80.Withdrawal') throw new GeneralException('Type not supported, only withdrawal supported');

    if (request.bankAccount == null) {
      String recordId = request.withdrawalDeposit.Bank_Account__c;
      if (recordId == null) throw new GeneralException('Input missing bank account');
      request.bankAccount = Database.query(BANK_ACCOUNT_SELECT_STR + 'WHERE Id = :recordId' );
    }
    if (request.bankAccount.For_Internal_Related_Account__c == null) throw new GeneralException('Bank account is not internal, "For Internal Related Account" field is not set');

    if (request.Actual_Amount == null && request.withdrawalDeposit.Actual_Amount__c != null) request.Actual_Amount = request.withdrawalDeposit.Actual_Amount__c;
    if (request.Actual_Amount == null && request.withdrawalDeposit.Amount__c != null) request.Actual_Amount = request.withdrawalDeposit.Amount__c;
    if (request.Effective_Date_Screen == null) request.Effective_Date_Screen = System.today();
    Decimal amount = request.Actual_Amount;// * (withdrawalDeposit.Type__c == '80.Withdrawal' ? 1 : -1);
    Date effectiveDate = request.Effective_Date_Screen;
    log(Logs, 'For Internal transactions ' + request.Actual_Amount + ' ' + request.Effective_Date_Screen) ;
    
    GlobalTrigger_Invocable.init();
    Id fromAccountId = request.withdrawalDeposit.Account__c;
    Id toAccountId = request.bankAccount.For_Internal_Related_Account__c;
    List<Id> listId = new List<Id> { fromAccountId, toAccountId };
      
    String trustee = request.withdrawalDeposit.Trustee__c;
    String ccy = request.withdrawalDeposit.CCY__c;
    String condition = 'Account__c IN :listId';
    condition = GlobalTrigger_Invocable.EWALLETTRUSTEE_SELECT_STR + 'WHERE ' + condition;
    System.debug('queryString: ' + condition);

    List<eWallet_Trustee__c> listEWalletTrustee = Database.query(condition + ' AND CCY__c = :ccy AND Trustee__c = :trustee ');
    Map<String, eWallet_Trustee__c> mapObj = new Map<String, eWallet_Trustee__c>();
    for (eWallet_Trustee__c eWalletTrustee : listEWalletTrustee) {
      mapObj.put(eWalletTrustee.Account__c, eWalletTrustee);
    }

    if (mapObj.get(fromAccountId) == null) throw new GeneralException('No eWalletTrustee for account with same CCY and Trustee ' + fromAccountId);
    if (mapObj.get(toAccountId) == null) throw new GeneralException('No eWalletTrustee for related account with same CCY and Trustee ' + toAccountId);

    List<Transaction__c> listTransaction = new List<Transaction__c>();
    System.debug('ImpactedAccountsIds ' + ' ' + fromAccountId + ' ' + toAccountId + ' ' + mapObj.keySet());
    if (!mapObj.containsKey(fromAccountId)) throw new GeneralException('Insufficient data for Account ' + fromAccountId);
    if (!mapObj.containsKey(toAccountId)) throw new GeneralException('Insufficient data for Related Account Id ' + toAccountId);

    String type1 = request.withdrawalDeposit.Type__c;
    String type2 = request.withdrawalDeposit.Type__c == '80.Withdrawal' ? '70.Deposit' : '80.Withdrawal';
    eWallet_Trustee__c eWalletTrustee;
    Id accountingPeriodId = Accounting_Period.lookup(effectiveDate);

    eWalletTrustee = mapObj.get(fromAccountId);
    Transaction__c fromTransaction = GlobalTrigger_Invocable.CreateTransaction(fromAccountId, eWalletTrustee.Main_eWallet__c, eWalletTrustee.Id, -amount, effectiveDate, accountingPeriodId, type1, trustee, ccy, null, null, mapObj);
    fromTransaction.Withdrawal_Deposit__c = request.recordId;
    listTransaction.add(fromTransaction);

    eWalletTrustee = mapObj.get(toAccountId);
    Transaction__c toTransaction = GlobalTrigger_Invocable.CreateTransaction(toAccountId, eWalletTrustee.Main_eWallet__c, eWalletTrustee.Id, amount, effectiveDate, accountingPeriodId, type2, trustee, ccy, null, null, mapObj);
    listTransaction.add(toTransaction);
    
    log(Logs, 'Created transactions:');
    for (Transaction__c trn : listTransaction) log(Logs, GlobalTrigger_Invocable.toString(trn, mapObj, null));

    Withdrawal_Deposit__c withdrawal = new Withdrawal_Deposit__c();
    withdrawal.Id = request.withdrawalDeposit.Id;
    withdrawal.Status__c = 'Processed';

    Withdrawal_Deposit__c deposit = new Withdrawal_Deposit__c();
    deposit.Account__c = toAccountId;
    deposit.CCY__c = ccy;
    deposit.Type__c = '70.Deposit';
    deposit.Amount__c = amount;
    deposit.Trustee__c = trustee;
    deposit.Status__c = 'Processed';
    eWalletTrustee = mapObj.get(toAccountId);
    deposit.eWallet__c = eWalletTrustee.Main_eWallet__c;
    deposit.eWallet_Trustee__c = eWalletTrustee.Id;

    SavePoint savePoint = Database.setSavepoint();
    try {
      insert listTransaction;
      update withdrawal;
      insert deposit;
      toTransaction.Withdrawal_Deposit__c = deposit.Id;
      update toTransaction;
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

  public class WithdrawalInternalRequest {
    @InvocableVariable(required=true)
    public ID recordId;

    @InvocableVariable(required=false)
    public Withdrawal_Deposit__c withdrawalDeposit;

    @InvocableVariable(required=false)
    public Bank_Account__c bankAccount;

    @InvocableVariable(required=false)
    public Decimal Actual_Amount;

    @InvocableVariable(required=false)
    public Date Effective_Date_Screen;
  }
}