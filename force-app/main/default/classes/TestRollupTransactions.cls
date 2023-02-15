@IsTest
public class TestRollupTransactions {
    Public static TestMethod void Test1(){
        Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        
        Account supplier = new Account();
        supplier.Name = 'Test Company';
        supplier.RecordTypeId = supplierRecordTypeId;
        insert supplier;
        
        Bank_Account__c bankAcc = new Bank_Account__c();
        bankAcc.Name = 'TestBankAccount';
        bankAcc.Account__c = supplier.Id;
        bankAcc.Currency__c = 'SGD';
        bankAcc.Bank_Account_Number__c = '123456789';
        bankAcc.Bank_Name__c = 'DBS';
        bankAcc.SWIFT_Code__c = 'DBS-001';
        bankAcc.Country__c = 'Singapore';
        bankAcc.Beneficiary_Name__c = 'TestBeneficiary';
        bankAcc.transfer_cutoff_time__c = '18:00';
        insert bankAcc;
        
        FX_Rates__c fxRate = new FX_Rates__c();
        fxRate.from_currency__c = 'SGD';
        fxRate.to_currency__c = 'USD';
        fxRate.date__c = system.today();
        fxRate.rate__c = 1;
        insert fxRate;
        
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Currency__c = 'SGD';
        marketPlace.Name = 'Test Marketplace';
        marketPlace.currency_symbol__c = 'SG$';
        marketPlace.minimum_purchase_amount__c = 100;
        marketPlace.FX_Rate_for_MI__c = fxRate.Id;
        insert marketPlace;
            
        eWallet__c wallet = new eWallet__c();
        wallet.Account__c = supplier.Id;
        wallet.Bank_Account__c = bankAcc.Id;
        wallet.CCY__c = 'SGD';
        wallet.Marketplace_for_FX__c = marketPlace.Id;
        insert wallet;
        
        eWallet_Trustee__c trustee = new eWallet_Trustee__c();
        trustee.Account__c = supplier.Id;
        trustee.CCY__c = 'SGD';
        trustee.Main_eWallet__c = wallet.Id;
        trustee.Marketplace_for_FX__c = marketPlace.Id;
        insert trustee;
        
        Accounting_Period__c accPeriod = new Accounting_Period__c();
        accPeriod.Name = 'TestAccountingPeriod';
        accPeriod.Start_Date__c = system.today();
        accPeriod.End_Date__c = system.today() + 365;
        insert accPeriod;
        
        Id openPeriodTransactionRecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('Open Period').getRecordTypeId();
        
        FX_Contract__c fxContract = new FX_Contract__c();
        fxContract.CCY_Target__c = 'SGD';
        fxContract.Amount__c = 1000;
        fxContract.Origination_Date__c = System.today();
        fxContract.Origination_Rate__c = 1.37;
        insert fxContract;

        FX_Contract__c fxContract2 = new FX_Contract__c();
        fxContract2.CCY_Target__c = 'SGD';
        fxContract2.Amount__c = 1000;
        fxContract2.Origination_Date__c = System.today();
        fxContract2.Origination_Rate__c = 1.39;
        insert fxContract2;
        
        Transaction__c tran = new Transaction__c();
        tran.Account__c = supplier.Id;
        tran.Accounting_Period__c = accPeriod.Id;
        tran.Amount__c = 100;
        tran.eWallet__c = wallet.Id;
        tran.eWallet_Trustee__c = trustee.Id;
        tran.CCY__c = 'SGD';
        tran.Effective_Date__c = system.today();
        tran.Type__c = '05.Invoice Discount Amount';
        tran.Status__c = 'Confirmed by operations';
        insert tran;
        
        tran.Amount__c = 200;
        update tran;

        TransactionTriggerHandler handler = new TransactionTriggerHandler();
        
        tran.FX_Contract__c = fxContract.Id;
        tran.Amount__c = 100;
        tran.Tranche_amount__c = 100;
        update tran;
        
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.debug('remain amount fx contract ' + fxContract.Remain_amount__c);
        System.assertEquals(1100, fxContract.Remain_amount__c);

        tran.Tranche_amount__c = 70;
        update tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1070, fxContract.Remain_amount__c);

        fxContract.Remain_amount__c = null;
        update tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1070, fxContract.Remain_amount__c);
        
        tran.FX_Contract__c = null;
        tran.Tranche_amount__c = 0;
        update tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1000, fxContract.Remain_amount__c);
        
        tran.FX_Contract__c = fxContract.Id;
        tran.Tranche_amount__c = 30;
        update tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1030, fxContract.Remain_amount__c);
        
        delete tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1000, fxContract.Remain_amount__c);
        
        undelete tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1030, fxContract.Remain_amount__c);

    }
    
    Public static TestMethod void Test2(){
        Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        
        Account supplier = new Account();
        supplier.Name = 'Test Company';
        supplier.RecordTypeId = supplierRecordTypeId;
        insert supplier;
        
        Bank_Account__c bankAcc = new Bank_Account__c();
        bankAcc.Name = 'TestBankAccount';
        bankAcc.Account__c = supplier.Id;
        bankAcc.Currency__c = 'SGD';
        bankAcc.Bank_Account_Number__c = '123456789';
        bankAcc.Bank_Name__c = 'DBS';
        bankAcc.SWIFT_Code__c = 'DBS-001';
        bankAcc.Country__c = 'Singapore';
        bankAcc.Beneficiary_Name__c = 'TestBeneficiary';
        bankAcc.transfer_cutoff_time__c = '18:00';
        insert bankAcc;
        
        FX_Rates__c fxRate = new FX_Rates__c();
        fxRate.from_currency__c = 'SGD';
        fxRate.to_currency__c = 'USD';
        fxRate.date__c = system.today();
        fxRate.rate__c = 1;
        insert fxRate;
        
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Currency__c = 'SGD';
        marketPlace.Name = 'Test Marketplace';
        marketPlace.currency_symbol__c = 'SG$';
        marketPlace.minimum_purchase_amount__c = 100;
        marketPlace.FX_Rate_for_MI__c = fxRate.Id;
        insert marketPlace;
            
        eWallet__c wallet = new eWallet__c();
        wallet.Account__c = supplier.Id;
        wallet.Bank_Account__c = bankAcc.Id;
        wallet.CCY__c = 'SGD';
        wallet.Marketplace_for_FX__c = marketPlace.Id;
        insert wallet;
        
        eWallet_Trustee__c trustee = new eWallet_Trustee__c();
        trustee.Account__c = supplier.Id;
        trustee.CCY__c = 'SGD';
        trustee.Main_eWallet__c = wallet.Id;
        trustee.Marketplace_for_FX__c = marketPlace.Id;
        insert trustee;
        
        Accounting_Period__c accPeriod = new Accounting_Period__c();
        accPeriod.Name = 'TestAccountingPeriod';
        accPeriod.Start_Date__c = system.today();
        accPeriod.End_Date__c = system.today() + 365;
        insert accPeriod;
        
        Id openPeriodTransactionRecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('Open Period').getRecordTypeId();
        
        FX_Contract__c fxContract = new FX_Contract__c();
        fxContract.CCY_Target__c = 'SGD';
        fxContract.Amount__c = 1000;
        fxContract.Origination_Date__c = System.today();
        fxContract.Origination_Rate__c = 1.37;
        insert fxContract;

        FX_Contract__c fxContract2 = new FX_Contract__c();
        fxContract2.CCY_Target__c = 'SGD';
        fxContract2.Amount__c = 1000;
        fxContract2.Origination_Date__c = System.today();
        fxContract2.Origination_Rate__c = 1.39;
        insert fxContract2;
        
        Transaction__c tran = new Transaction__c();
        tran.Account__c = supplier.Id;
        tran.Accounting_Period__c = accPeriod.Id;
        tran.Amount__c = 100;
        tran.eWallet__c = wallet.Id;
        tran.eWallet_Trustee__c = trustee.Id;
        tran.CCY__c = 'SGD';
        tran.Effective_Date__c = system.today();
        tran.Type__c = '05.Invoice Discount Amount';
        tran.Status__c = 'Confirmed by operations';
        insert tran;
        
		tran.Amount__c = 200;
        tran.Tranche_amount__c = 30;
        tran.FX_Contract__c = fxContract2.Id;
        update tran;
        fxContract2 = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract2.Id];
        System.assertEquals(1030, fxContract2.Remain_amount__c);

        tran.FX_Contract__c = fxContract.Id;
        tran.Tranche_amount__c = 70;
        update tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1070, fxContract.Remain_amount__c);
        fxContract2 = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract2.Id];
        System.assertEquals(1000, fxContract2.Remain_amount__c);
        
        delete tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1000, fxContract.Remain_amount__c);
        
        undelete tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1070, fxContract.Remain_amount__c);

		tran.Id = null;
        tran.FX_Contract__c = fxContract.Id;
        tran.Type__c = '70.Deposit';
        tran.Amount__c = 90;
        tran.Tranche_amount__c = null;
        insert tran;
        fxContract = [SELECT Id, Sum_Deposit_Withdrawal__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(90, fxContract.Sum_Deposit_Withdrawal__c);
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1070, fxContract.Remain_amount__c);

        tran.Tranche_amount__c = 90;
        update tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1160, fxContract.Remain_amount__c);
        
        tran.Tranche_amount__c = null;
        update tran;
        fxContract = [SELECT Id, Remain_amount__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(1070, fxContract.Remain_amount__c);
        
        eWallet__c walletUSD = new eWallet__c();
        walletUSD.Account__c = supplier.Id;
        walletUSD.Bank_Account__c = bankAcc.Id;
        walletUSD.CCY__c = 'USD';
        walletUSD.Marketplace_for_FX__c = marketPlace.Id;
        insert walletUSD;
        
        eWallet_Trustee__c trusteeUSD = new eWallet_Trustee__c();
        trusteeUSD.Account__c = supplier.Id;
        trusteeUSD.CCY__c = 'USD';
        trusteeUSD.Main_eWallet__c = walletUSD.Id;
        trusteeUSD.Marketplace_for_FX__c = marketPlace.Id;
        insert trusteeUSD;
        
		tran = new Transaction__c();
        tran.Account__c = supplier.Id;
        tran.Accounting_Period__c = accPeriod.Id;
        tran.Effective_Date__c = system.today();
        tran.Status__c = 'Confirmed by Operations';
        tran.FX_Contract__c = fxContract.Id;
        tran.Type__c = '80.Withdrawal';
        tran.Amount__c = -80;
        tran.CCY__c = 'USD';
        tran.eWallet__c = walletUSD.Id;
        tran.eWallet_Trustee__c = trusteeUSD.Id;
        insert tran;
        fxContract = [SELECT Id, Sum_Deposit_Withdrawal_USD__c FROM FX_Contract__c WHERE Id = :fxContract.Id];
        System.assertEquals(-80, fxContract.Sum_Deposit_Withdrawal_USD__c);
       
    }
}