@isTest
private class Test_RollupUtility {

    private static testMethod void RollupUtilityTest() {
        
        Map<String, Object> result = SeedTest.init(null, null, null);
        Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');
        Supplier_Buyer_Map__c supplierBuyerMap = (Supplier_Buyer_Map__c)result.get('map');
        Invoice_Allocation__c allocation = (Invoice_Allocation__c)result.get('invAllocation');
        List<Transaction__c> listTransaction = new List<Transaction__c>();

        RollupUtility.IgnoreFirstRun = true;
        RollupUtility.rollupInvoiceToMarketplace(new Set<Id> ( new List<Id> { SeedTest.getId(result, 'marketplace' + 'USD') })); 
        System.debug(SeedTest.getId(result, 'marketplace' + 'USD'));

        invoice.Phase__c = '3:IN PROGRESS';
        invoice.Status__c = 'In progress';    
        update invoice;

        if (allocation.eWallet__c == null || allocation.eWallet_Trustee__c == null) {
            System.debug('revert once migrate flow fix ' + allocation.eWallet__c + ' ' + allocation.eWallet_Trustee__c);
            allocation.eWallet__c = SeedTest.getId(result, 'wallet' + 'USD' + 'Funder'); 
            allocation.eWallet_Trustee__c = SeedTest.getId(result, 'eWalletTrustee' + 'USD' + 'Funder');
            update allocation;
        }

        listTransaction.add(SeedTest.createTransaction(result, '', 'Funder', 'USD', -10, '01.Invoice Purchase'));
        listTransaction.add(SeedTest.createTransaction(result, '', 'Funder', 'USD', 1, '05.Invoice Discount Amount'));
        insert listTransaction;
        Map<Id, Transaction__c> oldMapTransaction = new Map<Id, Transaction__c>();
        for (Transaction__c trn : listTransaction) {
            oldMapTransaction.put(trn.Id, new Transaction__c());
        }

        List<Withdrawal_Deposit__c> listWithdrawalDeposit = new List<Withdrawal_Deposit__c>();
        for (String type : new List<String> {'70.Deposit','80.Withdrawal'}) {
            Withdrawal_Deposit__c withdrawalDeposit = new Withdrawal_Deposit__c();
            withdrawalDeposit.Account__c = SeedTest.getId(result, 'account' + 'Supplier'); 
            withdrawalDeposit.eWallet__c = SeedTest.getId(result, 'wallet' + 'USD' + 'Supplier'); 
            withdrawalDeposit.Type__c = type;
            withdrawalDeposit.Status__c = 'Not Processed';
            withdrawalDeposit.CCY__c = 'USD';
            withdrawalDeposit.Amount__c = 10;
            withdrawalDeposit.Trustee__c = 'Amicorp Trust';
            withdrawalDeposit.eWallet_Trustee__c = SeedTest.getId(result, 'eWalletTrustee' + 'USD' + 'Supplier'); // to revert
            listWithdrawalDeposit.add(withdrawalDeposit);
        }

        insert listWithdrawalDeposit;
        Map<Id, Withdrawal_Deposit__c> oldMapWithdrawalDeposit = new Map<Id, Withdrawal_Deposit__c>();
        for (Withdrawal_Deposit__c withdrawalDeposit : listWithdrawalDeposit) {
            oldMapWithdrawalDeposit.put(withdrawalDeposit.Id, new Withdrawal_Deposit__c());
        }

        Test.startTest();
        RollupUtility.isNeedRunTrigger = true;

        Set<Id> walletTrusteeIds = new Set<Id>();
        System.debug('total transactions ' + listTransaction.size());
        RollupUtility.afterInsert(walletTrusteeIds, listTransaction);
        RollupUtility.afterUpdate(walletTrusteeIds, oldMapTransaction, listTransaction);
        RollupUtility.afterDelete(walletTrusteeIds, listTransaction);
        RollupUtility.rollupTransactionToeWalletTrustee(walletTrusteeIds);

        Set<Id> mapIds = new Set<Id>();
        invoice = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Invoice_finance_deal__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Invoice_finance_deal__c WHERE Id=\'' + invoice.Id +'\'');
        List<Invoice_finance_deal__c> listInvoice = new List<Invoice_finance_deal__c>{invoice};
        Map<Id, Invoice_finance_deal__c> oldMap = new Map<Id, Invoice_finance_deal__c>();
        oldMap.put(invoice.Id, new Invoice_finance_deal__c());
        
        RollupUtility.afterInsert(mapIds, null, listInvoice);
        RollupUtility.afterUpdate(mapIds, null, oldMap, listInvoice);
        RollupUtility.afterDelete(mapIds, null, listInvoice);
        RollupUtility.rollupInvoiceToMap(mapIds);

        RollupUtility.isNeedRunTrigger = false;
        invoice.Phase__c = '1:PRE LISTING';
        invoice.Status__c = 'pending supplier review'; 
        update invoice;
        RollupUtility.isNeedRunTrigger = true;
        RollupUtility.IgnoreFirstRun = true;
        RollupUtility.rollupInvoiceToMap(mapIds);

        Set<Id> marketplaceIds = new Set<Id>();
        invoice.Phase__c = '2:ON MARKETPLACE';
        invoice.Status__c = 'On marketplace'; 
        invoice.requested_amount__c = invoice.requested_amount__c + 1;
        Formula.recalculateFormulas(new List<SObject>{ invoice });
        RollupUtility.afterInsert(null, marketplaceIds, listInvoice);
        RollupUtility.afterUpdate(null, marketplaceIds, oldMap, listInvoice);
        RollupUtility.afterDelete(null, marketplaceIds, listInvoice);
        RollupUtility.rollupInvoiceToMarketplace(marketplaceIds);

        walletTrusteeIds = new Set<Id>();
        allocation = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Invoice_Allocation__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Invoice_Allocation__c WHERE Id=\'' + allocation.Id +'\'');
        List<Invoice_Allocation__c> listInvoiceAllocation = new List<Invoice_Allocation__c>{allocation};
        Map<Id, Invoice_Allocation__c> oldMapAllocation = new Map<Id, Invoice_Allocation__c>();
        oldMapAllocation.put(allocation.Id, new Invoice_Allocation__c());
        
        RollupUtility.afterInsert(walletTrusteeIds, listInvoiceAllocation);
        RollupUtility.afterUpdate(walletTrusteeIds, oldMapAllocation, listInvoiceAllocation);
        RollupUtility.afterDelete(walletTrusteeIds, listInvoiceAllocation);
        RollupUtility.rollupAllocationToeWalletTrustee(walletTrusteeIds);

        walletTrusteeIds = new Set<Id>();
        RollupUtility.afterInsert(walletTrusteeIds, listWithdrawalDeposit);
        RollupUtility.afterUpdate(walletTrusteeIds, oldMapWithdrawalDeposit, listWithdrawalDeposit);
        RollupUtility.afterDelete(walletTrusteeIds, listWithdrawalDeposit);
        RollupUtility.rollupWithdrawalDepositToeWalletTrustee(walletTrusteeIds);

        Test.stopTest();

        RollupUtility.isNeedRunTrigger = false;
        update listTransaction;
        update listInvoiceAllocation;
        update listWithdrawalDeposit;

        delete listTransaction;
        delete listInvoiceAllocation;
        delete listWithdrawalDeposit;
        RollupUtility.resetFirstRun();

    }
}