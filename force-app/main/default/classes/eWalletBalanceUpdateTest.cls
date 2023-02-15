@isTest(SeeAllData=true)
public class eWalletBalanceUpdateTest {

    //-------------------------------------------------
    //Test unconfirmed Transaction
    //
    //-------------------------------------------------
    @isTest static void TestTransactionExpected() {
        Test.startTest();
        
        //Test data setup
        //Get Account and eWallet details
        Account acct = [select Id, Name, USD_eWallet__c 
                        from Account 
                        where Name = 'Demo Fact. Supplier Co.'];
        system.debug('account' + acct);
        
        eWallet__c ewalletBefore = [select Id, Name, Balance__c, Balance_Amount_Check__c 
                              from eWallet__c 
                              where Account__c = :acct.Id];
        system.debug('eWallet' + ewalletBefore);
        
        RecordType record = [SELECT Id from RecordType WHERE DeveloperName='Open_Period'];
        system.debug('record type =' + record);
        
        Accounting_Period__c period = [SELECT Id from Accounting_Period__c where Name  ='2020-03'];
        system.debug('accounting period =' + period);
        
        // Perform test
        // Create Transaction with status expected
        Transaction__c trans = new Transaction__c( RecordType = record,
                                                   Account__c = acct.Id,
                                                   Effective_Date__c = Date.today(),
                                                   Accounting_Period__c = period.Id,
                                                   Status__c = 'expected',
                                                   eWallet__c = ewalletBefore.Id,
                                                   CCY__c = 'USD',
                                                   Amount__c = 5000,
                                                   Type__c = '99.Adjustment');
        insert trans;
        system.debug('insert ok');
        
        //Verify insert
        //Check that balance has not changed
        eWallet__c ewalletAfter = [select Id, Name, Balance__c, Balance_Amount_Check__c 
                                   from eWallet__c 
                                   where Account__c = :acct.Id];
        system.debug('ewalletAfter = ' + ewalletAfter);
        
        //Verify update
        //Check that balance is changed
        trans.Status__c = 'Confirmed by Finance';
        update trans;
        eWallet__c ewalletAfterUpdate = [select Id, Name, Balance__c, Balance_Amount_Check__c 
                                   from eWallet__c 
                                   where Account__c = :acct.Id];
        system.debug('ewalletAfterUpdate' + ewalletAfterUpdate);
        
        //Verify update reverse
        //Check that balance is changed
        trans.Status__c = 'Cancelled';
        update trans;
        eWallet__c ewalletAfterUpdate2 = [select Id, Name, Balance__c, Balance_Amount_Check__c 
                                   from eWallet__c 
                                   where Account__c = :acct.Id];
        system.debug('ewalletAfterUpdate2' + ewalletAfterUpdate2);
        
        // Continue test
        // Delete Transaction with status cancelled
        delete trans;
        system.debug('delete ok');
        
        //Verify delete
        //Check that balance has not changed
        eWallet__c ewalletAfterDelete = [select Id, Name, Balance__c, Balance_Amount_Check__c 
                                   from eWallet__c 
                                   where Account__c = :acct.Id];

        system.debug('ewalletAfterDelete = ' + ewalletAfterDelete);
        Test.stopTest();

        System.assertEquals(true, ewalletBefore.Balance_Amount_Check__c == ewalletAfter.Balance_Amount_Check__c);
        //System.assertEquals(true, ewalletAfterUpdate.Balance_Amount_Check__c == ewalletBefore.Balance_Amount_Check__c + 5000);
        System.assertEquals(true, ewalletAfterUpdate2.Balance_Amount_Check__c == ewalletBefore.Balance_Amount_Check__c);
        System.assertEquals(true, ewalletAfterDelete.Balance_Amount_Check__c == ewalletBefore.Balance_Amount_Check__c);
    }
    
    
    
    //-------------------------------------------------
    //Test Transaction Confirmed
    //
    //-------------------------------------------------
    @isTest static void TestTransactionConfirmed() {
        //Test data setup
        //Get Account and eWallet details
        Test.startTest();
        Account acct = [select Id, Name, USD_eWallet__c 
                        from Account 
                        where Name = 'Demo Fact. Supplier Co.'];
        
        system.debug('account' + acct);
        
        eWallet__c ewalletBefore = [select Id, Name, Balance__c, Balance_Amount_Check__c 
                              from eWallet__c 
                              where Account__c = :acct.Id];
        
        system.debug('eWallet' + ewalletBefore);
        
        RecordType record = [SELECT id from RecordType where DeveloperName  ='Open_Period'];
        Accounting_Period__c period = [SELECT Id from Accounting_Period__c where Name  ='2020-03'];
        
        // Perform test
        // Create Transaction with status expected

        Transaction__c trans = new Transaction__c( RecordType = record,
                                                   Account__c = acct.Id,
                                                   Effective_Date__c = Date.today(),
                                                   Accounting_Period__c = period.Id,
                                                   Status__c = 'Confirmed by Finance',
                                                   eWallet__c = ewalletBefore.Id,
                                                   CCY__c = 'USD',
                                                   Amount__c = 5000,
                                                   Type__c = '99.Adjustment');
        insert trans;
        
        //Verify
        //Check that balance has not changed
        eWallet__c ewalletAfter = [select Id, Name, Balance__c, Balance_Amount_Check__c 
                                   from eWallet__c 
                                   where Account__c = :acct.Id];
        system.debug('ewalletAfter' + ewalletAfter);
        
        
        // Continue test
        // Delete Transaction with status confirmed
        delete trans;
        system.debug('delete ok');
        
        //Verify delete
        //Check that balance has not changed
		eWallet__c ewalletAfterDelete = [select Id, Name, Balance__c, Balance_Amount_Check__c 
                                   from eWallet__c 
                                   where Account__c = :acct.Id];
        system.debug('ewalletAfterDelete' + ewalletAfterDelete);
        Test.stopTest();
        
        //System.assertEquals(true, ewalletAfter.Balance_Amount_Check__c == ewalletBefore.Balance_Amount_Check__c + 5000);
        System.assertEquals(true, ewalletAfterDelete.Balance_Amount_Check__c == ewalletBefore.Balance_Amount_Check__c);
        

    }

    
    

}