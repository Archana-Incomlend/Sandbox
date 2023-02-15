@isTest
private class GlobalTrigger_InvocableTest {

  private static testMethod void runInvocable() {
      
    List<GlobalTrigger_Invocable.GlobalTriggerInvocableRequest> requestList = new List<GlobalTrigger_Invocable.GlobalTriggerInvocableRequest>();
    
    GlobalTrigger_Invocable.GlobalTriggerInvocableRequest request = null;
    request = new GlobalTrigger_Invocable.GlobalTriggerInvocableRequest();
    request.module = 'Unknown';
    requestList.add(request);

    request = new GlobalTrigger_Invocable.GlobalTriggerInvocableRequest();
    request.module = 'CreditLimitController';
    request.submodule = 'get';
    request.Id1 = '00Q0T000002Nd4p';
    requestList.add(request);

    request = new GlobalTrigger_Invocable.GlobalTriggerInvocableRequest();
    request.module = 'CreditLimitController';
    request.Id1 = '00Q0T000002Nd4p';
    requestList.add(request);

    request = new GlobalTrigger_Invocable.GlobalTriggerInvocableRequest();
    request.module = 'CreditLimitController';
    request.Id1 = null;
    requestList.add(request);

    request = new GlobalTrigger_Invocable.GlobalTriggerInvocableRequest();
    request.module = 'ListViewController';
    request.submodule = 'DownloadAttachment';
    request.str1 = '0012800000zy3U0';
    requestList.add(request);

    request = new GlobalTrigger_Invocable.GlobalTriggerInvocableRequest();
    RestIntermediateDeploymentFix_v9.needRunTrigger = false;
    request.module = 'IntermediateFix';
    request.submodule = 'bypass';
    request.str1 = '';
    request.date1 = Date.today();
    request.date2 = Date.today();
    request.has1 = true;
    request.has2 = false;
    requestList.add(request);

    request = new GlobalTrigger_Invocable.GlobalTriggerInvocableRequest();
    request.module = 'TargetFinance';
    request.submodule = 'New';
    request.str1 = 'a1k0T0000024C0H';
    requestList.add(request);

    // request = new GlobalTrigger_Invocable.GlobalTriggerInvocableRequest();
    // request.module = 'unknown';
    // request.str1 = 'test';
    // request.str2 = 'test';
    // request.str3 = 'test';
    // request.id1 = '00Q0T000002Nd4p';
    // request.id2 = '0012800000zy3U0';
    // request.date1 = Date.today();
    // request.date2 = Date.today();
    // request.has1 = false;
    // request.has2 = false;
    // requestList.add(request);

    GlobalTrigger_Invocable.runModule(requestList);
  }

  private static testMethod void runScheduler() {
    MI__c mi = new MI__c();
    insert mi;

    Savepoint sv = Database.setSavepoint();
    Accounting_Period__c accountingPeriod = new Accounting_Period__c();
    accountingPeriod.Name = '2022-01';
    accountingPeriod.Start_Date__c = Date.newInstance(2022, 01, 01);
    accountingPeriod.End_Date__c = Date.newInstance(2022, 01, 31);
    accountingPeriod.MI__c = mi.Id;
    insert accountingPeriod;
    GlobalTrigger_Invocable.createNextAccountingPeriod();
    Database.rollback(sv);
    
    accountingPeriod = new Accounting_Period__c();
    accountingPeriod.Name = '2022-Q1';
    accountingPeriod.Start_Date__c = Date.newInstance(2022, 01, 01);
    accountingPeriod.End_Date__c = Date.newInstance(2022, 03, 31);
    accountingPeriod.MI__c = mi.Id;
    insert accountingPeriod;
    GlobalTrigger_Invocable.createNextAccountingPeriod();

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    req.httpMethod = 'PUT';  
    RestContext.request = req;
    RestContext.response = res;
    req.requestURI = v_baseUrl+'/v9/GlobalTrigger/';
    GlobalTrigger_Invocable.doPut();

  }

  private static testMethod void CreateTransaction() {
    MI__c mi = new MI__c();
    insert mi;

    Accounting_Period__c accountingPeriod = new Accounting_Period__c();
    accountingPeriod.Name = 'Today';
    accountingPeriod.Start_Date__c = System.today();
    accountingPeriod.End_Date__c = System.today();
    accountingPeriod.MI__c = mi.Id;
    insert accountingPeriod;

    Invoice_Finance_Deal__c invoice = new Invoice_Finance_Deal__c();
    invoice.Id = 'a090T000002UoAU'; // random
    invoice.Trustee__c = 'Amicorp Trust';
    invoice.CCY__c = 'USD';
    GlobalTrigger_Invocable.init();
    List<Id> listTest = GlobalTrigger_Invocable.INTERNAL_ACCOUNT.values();
    listTest.add(invoice.Id_Buyer__c);
    listTest.add(invoice.Id_Supplier__c);

    String trustee = invoice.Trustee__c;
    String ccy = invoice.CCY__c;
    List<eWallet_Trustee__c> listEWalletTrustee = Database.query(GlobalTrigger_Invocable.EWALLETTRUSTEE_SELECT_STR + 'WHERE Account__c IN :listTest AND CCY__c = :ccy AND Trustee__c = :trustee ');
    Map<String, eWallet_Trustee__c> mapObj = new Map<String, eWallet_Trustee__c>();
    for (eWallet_Trustee__c eWalletTrustee : listEWalletTrustee) {
      mapObj.put(eWalletTrustee.Account__c, eWalletTrustee);
    }

    Id fromAccountId = GlobalTrigger_Invocable.INTERNAL_ACCOUNT.get(GlobalTrigger_Invocable.ICL_ISD);
    Id toAccountId = GlobalTrigger_Invocable.INTERNAL_ACCOUNT.get(GlobalTrigger_Invocable.ICL_FEE);
    eWallet_Trustee__c eWalletTrustee = new eWallet_Trustee__c();
    eWalletTrustee.Main_eWallet__c = 'a010I00001aMwsiQAC'; // random
    mapObj.put(fromAccountId, eWalletTrustee);    
    mapObj.put(toAccountId, eWalletTrustee);    
    List<Transaction__c> listTransaction = GlobalTrigger_Invocable.createDoubleTransaction(fromAccountId, toAccountId, 10.0, System.today(), accountingPeriod.Id, '06.Transaction Fee', invoice, null, mapObj);

    GlobalTrigger_Invocable.updateRelatedTransaction(listTransaction);

    GlobalTrigger_Invocable.log(new Helper_Log(), 'abc');
    GlobalTrigger_Invocable.toString(new Transaction__c(), new Map<String, eWallet_Trustee__c>(), '010234');
  }

}