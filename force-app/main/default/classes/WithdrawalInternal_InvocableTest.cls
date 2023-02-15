@isTest
private class WithdrawalInternal_InvocableTest {
  private static testMethod void runInvocable() {
    Map<String, Object> result = new Map<String, Object>();
    String name = 'Test';
    String CCY = 'USD';
    SeedTest.createMarketPlace(result, CCY);
    SeedTest.createAccountingPeriod(result);
    Account account = SeedTest.createAccount(result, name, 'Purchaser');
    account.Name = GlobalTrigger_Invocable.ICL_OPS;
    insert account;
    Bank_Account__c bankAccount = SeedTest.createBankAccount(result, name);
    bankAccount.For_Internal_Related_Account__c = account.Id;
    insert bankAccount;
    insert SeedTest.createEWallet(result, name, CCY);
    insert SeedTest.createEWalletTrustee(result, name, CCY);
    Withdrawal_Deposit__c withdrawalDeposit = new Withdrawal_Deposit__c();
    withdrawalDeposit.Account__c = account.Id; 
    withdrawalDeposit.eWallet__c = SeedTest.getId(result, 'wallet' + CCY + name); 
    withdrawalDeposit.Type__c = '80.Withdrawal';
    withdrawalDeposit.Status__c = 'Not Processed';
    withdrawalDeposit.CCY__c = CCY;
    withdrawalDeposit.Amount__c = 10;
    withdrawalDeposit.Trustee__c = 'Amicorp Trust';
    withdrawalDeposit.Bank_Account__c = bankAccount.Id;
    withdrawalDeposit.eWallet_Trustee__c = SeedTest.getId(result, 'eWalletTrustee' + 'USD' + name);
    insert withdrawalDeposit;

    WithdrawalInternal_Invocable.WithdrawalInternalRequest request = new WithdrawalInternal_Invocable.WithdrawalInternalRequest();
    request.recordId = withdrawalDeposit.Id;
    List<WithdrawalInternal_Invocable.WithdrawalInternalRequest> requestList = new List<WithdrawalInternal_Invocable.WithdrawalInternalRequest>();
    requestList.add(request);
    
    Test.startTest();
    WithdrawalInternal_Invocable.createWithdrawalInternalObjects(requestList);
    Test.stopTest();
  }
}