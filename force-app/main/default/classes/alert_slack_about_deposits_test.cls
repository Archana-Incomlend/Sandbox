@isTest(SeeAllData=true)
private class alert_slack_about_deposits_test {
    static testMethod void myTest() {
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
     Id USDMarketplace = seedincomlenddata.SeedProducts();
    
     transaction__c t = new Transaction__c();
     account a = [select id from account where sub_type__C = 'purchaser' limit 1];
     
     Accounting_Period__c ap = new Accounting_Period__c();
     ap.Name = 'Test Accounting Period';
     ap.Start_Date__c = date.today().addMonths(-1);
     ap.End_Date__c = date.today().addMonths(2);
     insert ap;
     Id apId = ap.Id;
        
     Bank_Account__c ba = new Bank_Account__c();
     ba.Account__c = a.id;
     ba.Beneficiary_Name__c = 'coddle';
     ba.Bank_Account_Number__c = '121215554455';
     ba.Currency__c = 'XXX';
     ba.Purpose__c = 'Bank Account for USD withdrawals1';
     ba.Incomlend_Account__c = 'Customer';
     ba.SWIFT_Code__c = 'SF44545';
     ba.Bank_Name__c = 'HSBC1';
     ba.Address__c = 'HSBC, Hong Kong';        
     ba.Country__c = 'Hong Kong';
     ba.estimated_transfer_time__c = 1;
     ba.transfer_cutoff_time__c = '5pm';        

     insert ba;
     id bankAccountId = ba.id;
        
     eWallet__c ewallet = new eWallet__c();
     ewallet.Account__c = a.id;
     ewallet.Bank_Account__c = bankAccountId;
     ewallet.CCY__c = 'XXX';
     ewallet.Marketplace_for_FX__c = USDMarketplace;
     
     insert ewallet;
     id ewalletId = ewallet.id;
    
     Date today  = system.today();
     t.account__c = a.id;
     t.type__C = '70.Deposit';
     t.ccy__c = 'XXX';
     t.effective_date__c = today;
     t.amount__c = 1000;
     t.status__c = 'Expected';
     t.accounting_period__c = apId;
     t.eWallet__c = ewalletId;
     
     insert t;
     
     t.status__c = 'Confirmed by Finance';
     update t;
     delete t;  //cos of the temp tjhing where i made trigger on delete to stop it firing.
    }
}