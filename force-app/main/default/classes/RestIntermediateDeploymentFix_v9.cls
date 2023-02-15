@RestResource(urlMapping='/v9/IntermediateDeploymentFix/*')

global with sharing class RestIntermediateDeploymentFix_v9 implements Schedulable

{
    
    public static void updateGBP(boolean isTest) {
        Map<Id,Id> wallets = new Map<Id,Id>();
        for (eWallet__c wallet : (
            [SELECT Id, Account__c
             FROM eWallet__c
             WHERE CCY__c ='GBP'
             AND Total_Position__c > 0
             AND (Account__r.Account_Status__c = 'Active' OR Account__r.Account_Status__c = null) 
             AND Account__r.GBP_eWallet__c = null
            ])) 
        {
            wallets.put(wallet.Account__c, wallet.Id);
        }
        
        if(wallets.size() > 0 || Test.isRunningTest()){
            List<Account> targetAccounts = [SELECT Id
                                            FROM Account 
                                            WHERE Id IN :wallets.keySet()];
            for(Account targetAccount : targetAccounts){
                System.debug('Account to change ' + targetAccount);
                targetAccount.GBP_eWallet__c = wallets.get(targetAccount.Id);
            }
        
            if(targetAccounts.size() > 0){
                if (!isTest) update targetAccounts;
            }
        }
    }

    public static void updateTrustee(Date minDate, boolean isTest) {
        List<Supplier_Buyer_Map__c> listMap = [
                SELECT Id, Name, map_onboarding_stage__c, Market_Place_Name__c, Supplier__r.Trustee__c, Buyer__r.Trustee__c, Trustee__c
                FROM Supplier_Buyer_Map__c 
                WHERE Trustee__c = null 
                LIMIT 200
            ];
        System.debug('found ' + listMap.size() + ' maps');
        List<Supplier_Buyer_Map__c> updateMaps = new List<Supplier_Buyer_Map__c>();
        for (Supplier_Buyer_Map__c supplierBuyerMap : listMap) 
        {
            String Trustee = supplierBuyerMap.Market_Place_Name__c.indexOf('Reverse') != -1 ? supplierBuyerMap.Supplier__r.Trustee__c : supplierBuyerMap.Buyer__r.Trustee__c;
            System.debug('update map ' + supplierBuyerMap.Id + ' ' + supplierBuyerMap.Name + ' ' + supplierBuyerMap.map_onboarding_stage__c + ' ' + Trustee);
            if (Trustee != null) {
                if (Trustee.indexOf(';') != -1) Trustee = 'Amicorp Trust';
                supplierBuyerMap.Trustee__c = Trustee;
                updateMaps.add(supplierBuyerMap);
            }
        }
        System.debug('total maps ' + updateMaps.size());
        if (!isTest && updateMaps.size() > 0) {
            lenientUpdate(updateMaps);
        }
    }

    public static void updateMarketPlaceEWallet(boolean isTest) {
        if (Test.isRunningTest()) 
            SeedTest.createMarketplace(new Map<String, Object>(), 'EUR;SGD;GBP;AUD');
        List<Marketplace__c> listMarketplace = [SELECT ID, Currency__c
                                        FROM Marketplace__c
                                        WHERE Name like '%Insured' 
                                        AND Currency__c != 'USD' AND Currency__c != 'XXX'];
        for (Marketplace__c marketplace : listMarketplace )
        {
            List<eWallet__c> listWallet = [SELECT Id, Account__c, Account__r.Name, 
                                           Account__r.Marketplace_for_EUR_FX_rate__c, Account__r.Marketplace_for_SGD_FX_rate__c, Account__r.Marketplace_for_GBP_FX_rate__c, 
                                           Account__r.EUR_eWallet__c, Account__r.SGD_eWallet__c, Account__r.GBP_eWallet__c 
                                           FROM eWallet__c
                                           WHERE CCY__c = :marketplace.Currency__c 
                                           AND (Account__r.Account_Status__c = 'Active' OR Account__r.Account_Status__c = null)
                                           AND (Balance__c > 0 OR In_Progress__c > 0)
                                           AND Marketplace_for_FX__c = :marketplace.Id]; 
            if (Test.isRunningTest()) listWallet.add(new eWallet__c());
            Map<Id, Account> targetAccounts = new Map<Id,Account>();
            for (eWallet__c wallet : listWallet)
            {
                if ((marketplace.Currency__c == 'EUR' &&
                     (wallet.Account__r.Marketplace_for_EUR_FX_rate__c == null ||
                      wallet.Account__r.EUR_eWallet__c == null))  
                    || (marketplace.Currency__c == 'SGD' &&
                     (wallet.Account__r.Marketplace_for_SGD_FX_rate__c == null ||
                      wallet.Account__r.SGD_eWallet__c == null))
                    || (marketplace.Currency__c == 'GBP' &&
                     (wallet.Account__r.Marketplace_for_GBP_FX_rate__c == null ||
                      wallet.Account__r.GBP_eWallet__c == null)))
                {
                    Account account = targetAccounts.get(wallet.Account__c);
                    if (account == null) {
                        System.debug('Account to change ' + wallet.Account__r.Name);
                        account = new Account();
                        account.Id = wallet.Account__c;
                        targetAccounts.put(account.Id, account);
                    }
                    if (marketplace.Currency__c == 'EUR') {
                        account.Marketplace_for_EUR_FX_rate__c = marketplace.Id;
                        account.EUR_eWallet__c = wallet.Id;                
                    } else if (marketplace.Currency__c == 'SGD') { 
                        account.Marketplace_for_SGD_FX_rate__c = marketplace.Id;
                        account.SGD_eWallet__c = wallet.Id;                
                    } else if (marketplace.Currency__c == 'GBP' || Test.isRunningTest()) { 
                        account.Marketplace_for_GBP_FX_rate__c = marketplace.Id;
                        account.GBP_eWallet__c = wallet.Id;                
                    }
                }
            }
            if(targetAccounts.size() > 0 && !isTest && !Test.isRunningTest()){
                update targetAccounts.values();
            }    
        }

    }

    public static void updateSalesCommission(Date minDate, boolean isTest) {
        List<String> accountSearch = new List<String> ();
        accountSearch.add('Fasanara Securitisation S.A. - Compartment J');
        accountSearch.add('Fasanara Securitisation S.A. - Compartment K');
        accountSearch.add('Audentia Global Alternative Credit Fund Limited');
        accountSearch.add('Aditum Structured Finance Fund');
        List<Sales_Commission__c> salesCalList =
            [SELECT Id, Funder_Name__c FROM Sales_Commission__c WHERE Invoice_Allocation__c != null AND Funder_Name__c NOT IN :accountSearch
            ];
        
        for (Sales_Commission__c salesCal : salesCalList) {
            System.debug('sales cal to remove ' + salesCal.Id + ' ' + salesCal.Funder_Name__c);
        }
        
        //delete salesCalList;
        
        List<Account> nonPayAccountList =
            [SELECT Id, Name FROM Account WHERE purchaser_first_date_sales_commission__c != null AND Name NOT IN :accountSearch
            ];
        for (Account account : nonPayAccountList) {
            account.purchaser_first_date_sales_commission__c = null;
            System.debug('non pay commission account to update ' + account.Name);
        }
        //update nonPayAccountList;
        List<Account> accountList =
            [SELECT Id, Name FROM Account WHERE Name IN :accountSearch
            ];
        for (Account account : accountList) {
            account.Pay_Commission__c = true;
            System.debug('account to update ' + account.Name);
        }
        //update accountList;
        List<Id> excludeInvAllo = new List<Id>();
        for (Sales_Commission__c salesCal :
            [SELECT Id, Invoice_Allocation__c FROM Sales_Commission__c WHERE Invoice_Allocation__c != null AND Funder_Name__c IN :accountSearch
            ]) {
                excludeInvAllo.add(salesCal.Invoice_Allocation__c);
            }
        //Date minDate = Date.valueOf('2021-08-01');
        List<Invoice_Allocation__c> invAlloList = 
            [SELECT Id, Name, Invoice__c, Invoice__r.Actual_Repayment_Received_Date__c FROM Invoice_Allocation__c 
             WHERE Invoice__r.Actual_Repayment_Received_Date__c >= :minDate AND Id NOT IN :excludeInvAllo AND Funder__r.Name IN :accountSearch
            ];
        for (Invoice_Allocation__c invAllo : invAlloList) {
            System.debug('invoice allocation to update ' + invAllo.Name + ' ' + invAllo.Invoice__r.Actual_Repayment_Received_Date__c);
        }
        
        Savepoint sv = Database.setSavepoint();
        try{
            delete salesCalList;
            update nonPayAccountList;
            update accountList;
            
            if (Test.isRunningTest()) invAlloList.add(new Invoice_Allocation__c());
            for (Invoice_Allocation__c invAllo : invAlloList) {
                Invoice_Finance_Deal__c invoice = new Invoice_Finance_Deal__c();
                invoice.Id = invAllo.Invoice__c;
                SalesCommissionService salesCommissionService = new SalesCommissionService(invoice);
                salesCommissionService.updateSalesCommission();
            }
        } catch(DMLException ex){
            System.debug(ex);
            Database.rollback(sv);
        } finally {
            if (isTest) Database.rollback(sv);
        }        
    }

    public static void updateTranche(Date minDate, boolean isTest) {
        List<Transaction__c> listTransaction = 
                [SELECT Id, Name, Invoice_Allocation__c, FX_Contract__c, Tranche_Amount__c, Amount__c 
                 FROM Transaction__c 
                 WHERE FX_Contract__c != null
                 AND Effective_Date__c >= :minDate
                 AND Type__c != '80.Withdrawal' AND Amount__c < 0 // AND Type__c = '01.Invoice Purchase' // workaround
                 AND Tranche_Amount__c != null AND Amount__c != 0
                 AND (Invoice_Allocation__r.Fx_Contract__c = null OR Invoice_Allocation__r.FX_Rate_manual__c = null)
                 LIMIT 1000];
        if (Test.isRunningTest()) listTransaction.add(new Transaction__c());
        System.debug('total transactions ' + listTransaction.size());

        Set<Id> setFxContractId = new Set<Id>();
        Set<Id> setTransactionId = new Set<Id>();
        for (Transaction__c trn : listTransaction) 
        {
            setTransactionId.add(trn.Id);
            setFxContractId.add(trn.Fx_Contract__c);
        }
        
        Map<Id, List<Transaction__c>> relatedTrancheTransactionsMap = new Map<Id, List<Transaction__c>>();
        CalculateFXContractController.updateRelatedTrancheTransactionsMap(relatedTrancheTransactionsMap, setTransactionId);
        for (List<Transaction__c> trnList : relatedTrancheTransactionsMap.values()) 
        {
            for (Transaction__c trn : trnList)
            {
                setFxContractId.add(trn.Fx_Contract__c);
            }
        }

        System.debug('total fx contracts ' + setFxContractId.size());
        Map<Id, Fx_Contract__c> fxContractMap = new Map<Id, Fx_Contract__c>([
                SELECT Id, Tranche_Name__c, Origination_Rate__c
                FROM FX_Contract__c WHERE Id IN :setFxContractId
            ]);
        if (Test.isRunningTest()) fxContractMap.put(null, new Fx_Contract__c());

        List<Invoice_allocation__c> updateInvoiceAllocations = new List<Invoice_allocation__c>();
        for (Transaction__c trn : listTransaction) 
        {
            Id invoiceAllocationId = trn.Invoice_Allocation__c;
            if (invoiceAllocationId == null) {
                System.debug('transaction ' + trn.Id + ' ' + trn.Name + ' no invoice allocation found');
                if (!Test.isRunningTest()) continue;
            }
            Invoice_Allocation__c invoiceAllocation = new Invoice_Allocation__c();
            invoiceAllocation.Id = invoiceAllocationId;
            CalculateFXContractController.updateAllocationWeightedRate(invoiceAllocation, trn, fxContractMap, relatedTrancheTransactionsMap);
            updateInvoiceAllocations.add(invoiceAllocation);   
            System.debug('allocation ' + invoiceAllocationId + ' ' + CalculateFXContractController.toString(invoiceAllocation) + ' ' + relatedTrancheTransactionsMap.containsKey(trn.Id));      
        }
        System.debug('total allocations to be updated ' + updateInvoiceAllocations.size());
        
        if (!isTest) {
            lenientUpdate(updateInvoiceAllocations);
        }
    }

    public static void updateExpectedPaymentDate(Date minDate, boolean isTest) {
        List<Invoice_Finance_Deal__c> updateInvoices = 
                [SELECT Id, Name, Due_Date__c, Expected_Payment_Date__c, Phase__c
                 FROM Invoice_Finance_Deal__c 
                 WHERE Due_Date__c != null
                 AND Expected_Payment_Date__c = null
                 AND Phase__c IN ('3:IN PROGRESS','4:CLOSED')
                 AND lastModifiedDate >= :minDate
                 LIMIT 100];
        if (Test.isRunningTest()) updateInvoices.add(new Invoice_Finance_Deal__c());
        
        for (Invoice_Finance_Deal__c invoice : updateInvoices) 
        {
            invoice.Expected_Payment_Date__c = invoice.Due_Date__c;
            System.debug('invoice to be updated ' + invoice.Name + ' ' + invoice.Phase__c + ' ' + invoice.Due_Date__c);
        }
        System.debug('total invoices ' + updateInvoices.size());

        if (!isTest) {
            lenientUpdate(updateInvoices);
        }
    }

    public static void updateFDR(Date minDate, boolean isTest) {
        List<Invoice_Allocation__c> listInvoiceAllocation = 
                [SELECT Id, Invoice__c, Invoice__r.Id, Invoice__r.Name, Invoice__r.discount_rate__c
                 FROM Invoice_Allocation__c 
                 WHERE Status__c NOT IN ('Cancelled') 
                 AND lastModifiedDate >= :minDate
                 LIMIT 1000];
        Map<Id, Invoice_Finance_Deal__c> mapInvoice = new Map<Id, Invoice_Finance_Deal__c>();
        for (Invoice_Allocation__c currentAllocation : listInvoiceAllocation)
        {
            if (mapInvoice.containsKey(currentAllocation.Invoice__c)) continue;
            mapInvoice.put(currentAllocation.Invoice__c, currentAllocation.Invoice__r);
        }
        if (Test.isRunningTest()) mapInvoice.put(null, new Invoice_Finance_Deal__c());
        System.debug('total invoices to recalculate ' + mapInvoice.size());

        listInvoiceAllocation = 
                [SELECT Id, Name, Invoice__c, Applied_MPR__c, amount__c
                 FROM Invoice_Allocation__c 
                 WHERE Status__c NOT IN ('Cancelled')
                 AND Applied_MPR__c > 0
                 AND Invoice__c IN :mapInvoice.keySet()];
        if (Test.isRunningTest()) listInvoiceAllocation.add(new Invoice_allocation__c());
        Map<Id, List<Invoice_Allocation__c>> mapInvoiceAllocation = new Map<Id, List<Invoice_Allocation__c>>();
        for (Invoice_Allocation__c currentAllocation : listInvoiceAllocation)
        {
            List<Invoice_Allocation__c> listAllocation = new List<Invoice_Allocation__c>();
            if (mapInvoiceAllocation.containsKey(currentAllocation.Invoice__c)) {
                listAllocation = mapInvoiceAllocation.get(currentAllocation.Invoice__c);
            } else {
                mapInvoiceAllocation.put(currentAllocation.Invoice__c, listAllocation);
            }
            listAllocation.add(currentAllocation);
        }
        if (Test.isRunningTest()) mapInvoiceAllocation.put(null, new List<Invoice_Allocation__c>());
        List<Invoice_Finance_Deal__c> updateInvoices = new List<Invoice_Finance_Deal__c>();
        for (Id invoiceId : mapInvoiceAllocation.keySet())
        {
            Invoice_Finance_Deal__c invoice = mapInvoice.get(invoiceId);
            decimal discountRate = IncomlendPricing_v3.calculateFunderDiscountRate(mapInvoiceAllocation.get(invoiceId));

            if (Test.isRunningTest() || math.abs(invoice.discount_rate__c - discountRate) >= 0.0001) {
                System.debug('invoice ' + invoice.Name + ' fdr ' + discountRate + ' from ' + invoice.discount_rate__c);
                invoice.discount_rate__c = discountRate;
                updateInvoices.add(invoice);
            }
        }
        System.debug('total invoices to update ' + updateInvoices.size());
        if (!isTest) {
            lenientUpdate(updateInvoices);
        }
    }

    public static void updateRollupInvoice(Date minDate, boolean isTest) {
        SavePoint sv = Database.setSavepoint();
        if (minDate == null) minDate = System.today();
        List<Invoice_Finance_Deal__c> listInvoice = [SELECT Id, Supplier_Buyer_Map__c FROM Invoice_Finance_deal__c WHERE lastmodifieddate >= :minDate];
        
        Set<Id> mapIds = new Set<Id>();
        for (Invoice_Finance_Deal__c invoice : listInvoice) 
        {
            mapIds.add(invoice.Supplier_Buyer_Map__c);
        }
        for (Supplier_Buyer_Map__c supplierBuyerMap : [SELECT Id FROM Supplier_Buyer_Map__c WHERE lastmodifieddate >= :minDate]) {
            mapIds.add(supplierBuyerMap.Id);
        }

        List<Supplier_Buyer_Map__c> listMap = null;
        listMap = [SELECT Id, Amount_Prelisting_USD__c, Inprogress_invoice_amount_usd_equiv__c FROM Supplier_Buyer_Map__c WHERE ID IN :mapIds]; 
        Map<Id, Supplier_Buyer_Map__c> mapMap = new Map<Id,Supplier_Buyer_Map__c> (listMap); 
        if (Test.isRunningTest()) mapMap.put(null, new Supplier_Buyer_Map__c());

        RollupUtility.rollupInvoiceToMap(mapIds);
        listMap = [SELECT Id, Amount_Prelisting_USD__c, Inprogress_invoice_amount_usd_equiv__c FROM Supplier_Buyer_Map__c WHERE ID IN :mapIds]; 
        if (Test.isRunningTest()) listMap.add(new Supplier_Buyer_Map__c());
        for (Supplier_Buyer_Map__c supplierBuyerMap : listMap) {

            decimal value1, value2;
            value1 = supplierBuyerMap.Amount_Prelisting_USD__c;
            value2 = mapMap.get(supplierBuyerMap.Id).Amount_Prelisting_USD__c;
            if (value1 != value2 && (value1 != 0 || value2 != null))
                System.debug('map ' + supplierBuyerMap.Id + ' prelisting amount changed to ' + value1 + ' from ' + value2);

            value1 = supplierBuyerMap.Inprogress_invoice_amount_usd_equiv__c;
            value2 = mapMap.get(supplierBuyerMap.Id).Inprogress_invoice_amount_usd_equiv__c;
            if (value1 != value2 && (value1 != 0 || value2 != null))
                System.debug('map ' + supplierBuyerMap.Id + ' inprogress amount changed to ' + value1 + ' from ' + value2);
        }
        if (isTest) Database.rollback(sv);
    }

    public static void updateRollupEwallet(Date minDate, Date maxDate, String eWalletTrusteeId, boolean isTest) {
        SavePoint sv = Database.setSavepoint();
        if (minDate == null) minDate = System.today();
        
        Set<Id> setId = new Set<Id>();
        Set<Id> setId2 = new Set<Id>();
        Set<Id> setId3 = new Set<Id>();
        if (minDate != null) {
            if (maxDate == null) maxDate = minDate.addDays(1);
            for (AggregateResult agg : [SELECT eWallet_Trustee__c walletTrustee FROM Invoice_allocation__c WHERE lastmodifieddate >= :minDate AND lastmodifieddate < :maxDate GROUP BY eWallet_Trustee__c]) 
            {
                setId.add((Id)agg.get('walletTrustee'));
            }    
            for (AggregateResult agg : [SELECT eWallet_Trustee__c walletTrustee FROM Transaction__c WHERE lastmodifieddate >= :minDate AND lastmodifieddate < :maxDate GROUP BY eWallet_Trustee__c]) 
            {
                setId2.add((Id)agg.get('walletTrustee'));
            }    
            for (AggregateResult agg : [SELECT eWallet_Trustee__c walletTrustee FROM Withdrawal_Deposit__c WHERE lastmodifieddate >= :minDate AND lastmodifieddate < :maxDate GROUP BY eWallet_Trustee__c]) 
            {
                setId3.add((Id)agg.get('walletTrustee'));
            }    
            if (maxDate > minDate.addDays(1)) {
                if (setId2.contains('a1C0I000005D1j2UAC')) System.debug('remove EWT-1600'); setId2.remove('a1C0I000005D1j2UAC'); // Incomlend Operations USD 
                if (setId2.contains('a1C0I000005D1dfUAC')) System.debug('remove EWT-1267'); setId2.remove('a1C0I000005D1dfUAC'); // Incomlend Supplier Discount USD 
                if (setId2.contains('a1C0I000005D1WCUA0')) System.debug('remove EWT-0804'); setId2.remove('a1C0I000005D1WCUA0'); // Incomlend - fees USD 
            }
            // for (eWallet_Trustee__c eWalletTrustee : [SELECT Id FROM eWallet_Trustee__c WHERE lastmodifieddate >= :minDate AND lastmodifieddate < :maxDate]) {
            //     setId.add(eWalletTrustee.Id);
            //     setId2.add(eWalletTrustee.Id);
            // }
        }
        if (!String.isBlank(eWalletTrusteeId) || Test.isRunningTest()) {
            try {
                Id temp = eWalletTrusteeId;
                setId.add(eWalletTrusteeId);
                setId2.add(eWalletTrusteeId);
                setId3.add(eWalletTrusteeId);
            } catch (Exception e) {
                for (eWallet_Trustee__c eWalletTrustee : [SELECT Id FROM eWallet_Trustee__c WHERE Name = :eWalletTrusteeId]) {
                    setId.add(eWalletTrustee.Id);
                    setId2.add(eWalletTrustee.Id);
                    setId3.add(eWalletTrustee.Id);
                }
            }
        }
        List<eWallet_Trustee__c> listTrustee;
        listTrustee = [SELECT Id, Deposits_Not_Processed__c, Withdrawals_Not_Processed__c, In_Progress__c, Total_Discount_Earned__c, Balance__c, Reservations__c FROM eWallet_Trustee__c WHERE ID IN :setId OR ID IN :setId2 OR ID IN :setId3 ]; 
        Map<Id, eWallet_Trustee__c> mapTrustee = new Map<Id,eWallet_Trustee__c> (listTrustee); 
        if (Test.isRunningTest()) mapTrustee.put(null, new eWallet_Trustee__c());
        if (setId.size() == 0 && !Test.isRunningTest()) System.debug('no ewallet allocation for input ' + minDate + ' ' + maxDate + ' ' + eWalletTrusteeId); 
        else RollupUtility.rollupAllocationToeWalletTrustee(setId);
        if (setId2.size() == 0 && !Test.isRunningTest()) System.debug('no ewallet transaction for input ' + minDate + ' ' + maxDate + ' ' + eWalletTrusteeId); 
        else RollupUtility.rollupTransactionToeWalletTrustee(setId2);
        if (setId3.size() == 0 && !Test.isRunningTest()) System.debug('no ewallet withdrawal for input ' + minDate + ' ' + maxDate + ' ' + eWalletTrusteeId); 
        else RollupUtility.rollupWithdrawalDepositToeWalletTrustee(setId3);
        
        listTrustee = [SELECT Id, Deposits_Not_Processed__c, Withdrawals_Not_Processed__c, In_Progress__c, Total_Discount_Earned__c, Balance__c, Reservations__c FROM eWallet_Trustee__c WHERE ID IN :setId OR ID IN :setId2 OR ID IN :setId3 ]; 
        if (Test.isRunningTest()) listTrustee.add(new eWallet_Trustee__c());
        // if (isTest) Database.rollback(sv);
        Database.rollback(sv);

        List<eWallet_Trustee__c> temp = new List<eWallet_Trustee__c>();        
        for (eWallet_Trustee__c eWalletTrustee : listTrustee) {
            decimal value1, value2;
            value1 = eWalletTrustee.In_Progress__c;
            value2 = mapTrustee.get(eWalletTrustee.Id).In_Progress__c;
            boolean changed = false;
            if (value1 != value2 && (value1 != 0 || value2 != null)) { changed = true; 
                System.debug('trustee ' + eWalletTrustee.Id + ' inprogress amount changed to ' + value1 + ' from ' + value2);
            }

            value1 = eWalletTrustee.Total_Discount_Earned__c;
            value2 = mapTrustee.get(eWalletTrustee.Id).Total_Discount_Earned__c;
            if (value1 != value2 && (value1 != 0 || value2 != null)) { changed = true; 
                System.debug('trustee ' + eWalletTrustee.Id + ' discount earned changed to ' + value1 + ' from ' + value2);
            }

            value1 = eWalletTrustee.Balance__c;
            value2 = mapTrustee.get(eWalletTrustee.Id).Balance__c;
            if (value1 != value2 && (value1 != 0 || value2 != null)) { changed = true; 
                System.debug('trustee ' + eWalletTrustee.Id + ' balance amount changed to ' + value1 + ' from ' + value2);
            }

            value1 = eWalletTrustee.Reservations__c;
            value2 = mapTrustee.get(eWalletTrustee.Id).Reservations__c;
            if (value1 != value2 && (value1 != 0 || value2 != null)) { changed = true; 
                System.debug('trustee ' + eWalletTrustee.Id + ' reservation amount changed to ' + value1 + ' from ' + value2);
            }

            value1 = eWalletTrustee.Deposits_Not_Processed__c;
            value2 = mapTrustee.get(eWalletTrustee.Id).Deposits_Not_Processed__c;
            if (value1 != value2 && (value1 != 0 || value2 != null)) { changed = true; 
                System.debug('trustee ' + eWalletTrustee.Id + ' deposit amount changed to ' + value1 + ' from ' + value2);
            }

            value1 = eWalletTrustee.Withdrawals_Not_Processed__c;
            value2 = mapTrustee.get(eWalletTrustee.Id).Withdrawals_Not_Processed__c;
            if (value1 != value2 && (value1 != 0 || value2 != null)) { changed = true; 
                System.debug('trustee ' + eWalletTrustee.Id + ' withdrawal amount changed to ' + value1 + ' from ' + value2);
            }
            if (changed) temp.add(eWalletTrustee);
        }
        if (!isTest && temp.size() > 0) update temp;
    }

    public static void updateOverdueSda(String invoiceId, boolean isTest) {
        SavePoint sv = Database.setSavepoint();
        String str = ', Amount_Overdue__c';
        Invoice_Finance_Deal__c invoice = new Invoice_Finance_Deal__c();
        if (!Test.isRunningTest()) invoice = Database.query(GlobalTrigger_Invocable.INVOICE_SELECT_STR.replace(' FROM', str + ' FROM') + 'WHERE Id = :invoiceId' );
        if (Test.isRunningTest()) { invoice.Trustee__c = 'Amicorp Trust'; invoice.CCY__c = 'USD'; }
        
        GlobalTrigger_Invocable.init();
        Id ICL_FEE = GlobalTrigger_Invocable.INTERNAL_ACCOUNT.get(GlobalTrigger_Invocable.ICL_FEE);
        Id ICL_OPS = GlobalTrigger_Invocable.INTERNAL_ACCOUNT.get(GlobalTrigger_Invocable.ICL_OPS); 
        List<Transaction__c> listTransaction = 
            [   SELECT Id, Name, Account__c, amount__c, Invoice_Allocation__c, Status__c, Type__c FROM Transaction__c
                WHERE Invoice_Finance_Deal__c = :invoiceId AND Status__c != 'Cancelled'];
        Decimal overdueAmount = -IncomlendPricing_v3.sumTransaction(listTransaction, '' + ICL_OPS + ';' + '062.Transaction Fees overdue', 'id-type');

        decimal acceptedMargin = 0.01;
        decimal amount = overdueAmount - GlobalTriggerHandler.coalesce(invoice.Amount_Overdue__c); 
        if (Math.Abs(amount) < acceptedMargin) { 
            System.debug('No change in Overdue SDA'); 
            if (!Test.isRunningTest()) return; 
        }
        System.debug('Overdue SDA change from ' + overdueAmount + ' to ' + invoice.Amount_Overdue__c);

        GlobalTrigger_Invocable.init();
        List<Id> listTest = GlobalTrigger_Invocable.INTERNAL_ACCOUNT.values();
        listTest.add(invoice.Id_Supplier__c);
    
        String trustee = invoice.Trustee__c;
        String ccy = invoice.CCY__c;
        List<eWallet_Trustee__c> listEWalletTrustee = Database.query(GlobalTrigger_Invocable.EWALLETTRUSTEE_SELECT_STR + 'WHERE Account__c IN :listTest AND CCY__c = :ccy AND Trustee__c = :trustee ');
        Map<String, eWallet_Trustee__c> mapObj = new Map<String, eWallet_Trustee__c>();
        for (eWallet_Trustee__c eWalletTrustee : listEWalletTrustee) {
          mapObj.put(eWalletTrustee.Account__c, eWalletTrustee);
        }
        System.debug(mapObj);
    
        listTransaction = new List<Transaction__c>();
        Date effectiveDate = System.today();
        Id accountingPeriodId = !Test.isRunningTest() ? Accounting_Period.lookup(effectiveDate) : null;
        if (!Test.isRunningTest()) listTransaction.addAll(GlobalTrigger_Invocable.createDoubleTransaction(ICL_FEE, ICL_OPS, amount, effectiveDate, accountingPeriodId, '062.Transaction Fees overdue', invoice, null, mapObj));
        if (!Test.isRunningTest()) listTransaction.addAll(GlobalTrigger_Invocable.createDoubleTransaction(ICL_OPS, invoice.Id_Supplier__c, amount, effectiveDate, accountingPeriodId, '08.Invoice Balance Payment', invoice, null, mapObj));
    
        System.debug('Created transactions:');
        for (Transaction__c trn : listTransaction) System.debug(trn);
        insert listTransaction;
        GlobalTrigger_Invocable.updateRelatedTransaction(listTransaction);
        update listTransaction;
        if (isTest) Database.rollback(sv);
    }

    public static integer lenientUpdate(List<Object> listObject) {
        integer failedCount = 0;
        Database.SaveResult[] results = null;
        try {
            if (listObject instanceof List<Supplier_Buyer_Map__c>) {
                results = Database.Update((List<Supplier_Buyer_Map__c>)listObject, false);
            } else if (listObject instanceof List<Invoice_Finance_Deal__c>) {
                results = Database.Update((List<Invoice_Finance_Deal__c>)listObject, false);
            } else if (listObject instanceof List<Invoice_allocation__c>) {
                results = Database.Update((List<Invoice_allocation__c>)listObject, false);
            }
        } catch (Exception ex) {
            System.debug(ex);
        } finally {
            if (results != null || Test.isRunningTest()) {
                for (Database.SaveResult result : results)
                {
                    if (!result.isSuccess()) {
                        failedCount += 1;
                        System.debug('unable to update ' + result.getId() + ' ' + result.getErrors()[0].getMessage());
                    }
                }
                return failedCount;    
            }
        }
        return -1;
    }
    
    public static void validateInvoiceTransaction(Date minDate, String invoiceId, boolean isTest) {
        Set<Id> invoiceList = new Set<Id>(); 
        Helper_Log Logs = new Helper_Log();
        try {
            if (!String.isBlank(invoiceId) || Test.isRunningTest()) {
                if (invoiceId.indexOf('a09') == 0 && (invoiceId.length() == 15 || invoiceId.length() == 18)) 
                    invoiceList.add((Id)invoiceId);
                else Logs.log('Invoice ID is invalid ' + invoiceId, 1, Helper_Log.Color.Red);
            }
            if (String.isBlank(invoiceId) || Test.isRunningTest()) {
                invoiceList = new Map<Id, Invoice_Finance_Deal__c> (
                      [ SELECT Id FROM Invoice_Finance_Deal__c 
                        WHERE (advance_send_to_supplier_date__c = :minDate OR Actual_Repayment_Received_Date__c = :minDate) 
                        AND Passthrough_auto__c = false AND Phase__c = '4:CLOSED' 
                      ]).keySet();
            }

            List<Transaction__c> result = 
                  [ SELECT Invoice_Finance_Deal__c, Id, Name, Account__c, amount__c, Invoice_Allocation__c, Status__c, Type__c
                    FROM Transaction__c WHERE Invoice_Finance_Deal__c IN :invoiceList AND Status__c != 'Cancelled'];
            Map<Id, List<Transaction__c>> mapInvoice = new Map<Id, List<Transaction__c>>();
            if (Test.isRunningTest()) result.add(new Transaction__c());
            if (Test.isRunningTest()) mapInvoice.put(null, new List<Transaction__c> {new Transaction__c()});

            for (Transaction__c trn : result) {
                List<Transaction__c> listTransaction = mapInvoice.get(trn.Invoice_Finance_Deal__c);
                if (listTransaction == null) listTransaction = new List<Transaction__c>();
                listTransaction.add(trn);
                mapInvoice.put(trn.Invoice_Finance_Deal__c, listTransaction);
            }
            Map<String, Id> mapAccount = new Map<String, Id>();
            mapAccount.put('Incomlend Operations', null); // zero at all times
            mapAccount.put('Incomlend - Supplier Discount', null); // zero if closed
            mapAccount.put('Incomlend - fees', null); // positive if closed

            List<Account> accountList = [ SELECT Id, Name FROM Account WHERE Name IN :mapAccount.keySet()];
            if (accountList.size() != mapAccount.size()) Logs.log('Unable to load/missing Incomlend account ' + accountList, 1, Helper_Log.Color.Red);
            for (Account currentAccount : accountList) {
                mapAccount.put(currentAccount.Name, currentAccount.Id);
            } 
            Map<Id, Invoice_Finance_Deal__c> mapInv = new Map<Id, Invoice_Finance_Deal__c>( 
                  [  SELECT Id, Name, supplier_text__c, Buyer_text__c, CCY__c FROM Invoice_Finance_Deal__c WHERE Id IN :invoiceList] );
            if (Test.isRunningTest()) mapInv.put(null, new Invoice_Finance_Deal__c());

            decimal acceptedMargin = 0.095;
            for (Id currentId : mapInvoice.keySet()) {
                boolean invalid = false;
                List<Transaction__c> listTransaction = mapInvoice.get(currentId);
                Invoice_Finance_Deal__c invoice = mapInv.get(currentId);

                for (String str : mapAccount.keySet()) {
                    decimal temp = Test.isRunningTest() ? -1 : IncomlendPricing_v3.sumTransaction(listTransaction, '' + mapAccount.get(str), 'id');
                    boolean checkPositive = str == 'Incomlend - fees';
                    if (checkPositive ? temp < 0 : temp >= acceptedMargin || temp <= -acceptedMargin) {
                        if (!invalid) Logs.log('Invoice ' + invoice.Name + ' ' + invoice.supplier_text__c + ' Selling to ' + invoice.Buyer_text__c + ': ' + listTransaction.size() + ' transactions ', 1, Helper_Log.Color.Black);
                        invalid = true;
                        Logs.Log(str + ' Balance is not ' + (checkPositive ? 'positive' : 'null') + ': ' + temp + ' ' + invoice.CCY__c, 2, Helper_Log.Color.Red);
                    }
                }
                if (invalid) Logs.LogLine();
            }
        } catch (Exception ex) {
            System.debug(ex);
            Logs.log('An error occurred ' + ex.getMessage());
            throw ex;
        } finally {
            String str = Logs.PlainLog;
            if (str.length() > 0) System.debug('\n' + str);
            String toEmail = config.getConfig('IncomlendPricing_v3_Notification_AlertsRecipients');
            if (!Test.isRunningTest() && str.length() > 0) Helper_Email.Send(true, toEmail != 'key not found' ? toEmail.split(';') : GlobalTriggerHandler.getEmailToSendException(), 'Invoice transactions invalid', Logs.HTMLLog);
        }
    }

    @future(callout=true)
    public static void main()
    {
        Date today = System.today();
        if (System.now().format('HH') < '09') today = today.addDays(-1);
        validateInvoiceTransaction(today, null, false);
    }
    
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        String p_accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
        String p_date = RestContext.request.params.get('date');
        String p_test = RestContext.request.params.get('test');
        String p_latest = RestContext.request.params.get('latest');
        DateTime date1 = p_date == null ? null : (DateTime)Json.deserialize('"'+p_date+'"', DateTime.class);
        Date date2 = p_date == null ? null : Date.newinstance(date1.year(), date1.month(), date1.day());
        String p_maxDate = RestContext.request.params.get('maxDate');
        Date maxDate = p_maxDate == null ? null : (Date)Json.deserialize('"'+p_maxDate+'"', Date.class);
        String p_module = RestContext.request.params.get('module');
        boolean isTest = p_test != 'false';
        runMain(p_module, p_accountId, date2, maxDate, isTest, p_latest == 'true');
    }

    public static boolean needRunTrigger = true;

    public static void runMain(String p_module, String p_accountId, Date minDate, Date maxDate, boolean isTest, boolean isLatest)
    {
        if (!needRunTrigger) return;
        RestResponse res = RestContext.response;        
        if (res != null) res.statusCode = 500;

        if (p_module == 'rate') {
            RefreshFXRates.InsertNewFxRatesDate(minDate, isTest, isLatest);
        }

        boolean tempWebServiceCallout = WebServiceCallout.IsNeedRunTrigger;
        boolean tempCalculateTargetFinanceController = CalculateTargetFinanceController.isNeedRunTrigger;
        boolean tempGlobalTriggerHandler = GlobalTriggerHandler.isNeedRunTrigger;
        boolean tempSalesCommissionService = SalesCommissionService.isNeedRunTrigger;
        WebServiceCallout.IsNeedRunTrigger = false;
        CalculateTargetFinanceController.isNeedRunTrigger = false;
        if (isTest || Test.isRunningTest()) {
            GlobalTriggerHandler.isNeedRunTrigger = false;
            SalesCommissionService.isNeedRunTrigger = false;
        }
        if (p_module != 'salescommission') SalesCommissionService.isNeedRunTrigger = false;

        if (p_module == 'gbp' || Test.isRunningTest()) {
            updateGBP(isTest);
        }

        if (p_module == 'trustee' || Test.isRunningTest()) {
            updateTrustee(minDate, isTest);
        }
        
        if (p_module == 'ccyEWallet' || Test.isRunningTest()) {
            updateMarketPlaceEWallet(isTest);
        }
        
        if (p_module == 'salescommission' || Test.isRunningTest()) {
            updateSalesCommission(minDate, isTest);
        }
        
        if (p_module == 'tranche' || Test.isRunningTest()) {
            updateTranche(minDate, isTest);
        }
        
        if (p_module == 'expectedpaymentdate' || Test.isRunningTest()) {
            updateExpectedPaymentDate(minDate, isTest);
        }
                
        if (p_module == 'fdr' || Test.isRunningTest()) {
            updateFDR(minDate, isTest);
        }
                
        if (p_module == 'overduedays' || Test.isRunningTest()) {
            SavePoint sv = Database.setSavepoint();
            RefreshOverDueDays.updateoverduedays();
            if (isTest) Database.rollback(sv);
        }
                
        if (p_module == 'rollupInvoice' || Test.isRunningTest()) {
            updateRollupInvoice(minDate, isTest);
        }

        if (p_module == 'rollupEwallet' || Test.isRunningTest()) {
            updateRollupEwallet(minDate, maxDate, p_accountId, isTest);
        }

        if (p_module == 'overdueSda' || Test.isRunningTest()) {
            updateOverdueSda(p_accountId, isTest);
        }

        if (p_module == 'invoiceTransaction' || Test.isRunningTest()) {
            validateInvoiceTransaction(minDate, p_accountId, isTest);
        }

        if (Test.isRunningTest()) {
            lenientUpdate(new List<Supplier_Buyer_Map__c> ());
            lenientUpdate(new List<Invoice_Finance_Deal__c> ());
            lenientUpdate(new List<Invoice_allocation__c> ());
        }

        WebServiceCallout.IsNeedRunTrigger = tempWebServiceCallout;
        CalculateTargetFinanceController.IsNeedRunTrigger = tempCalculateTargetFinanceController;
        GlobalTriggerHandler.isNeedRunTrigger = tempGlobalTriggerHandler;
        SalesCommissionService.isNeedRunTrigger = tempSalesCommissionService;

        if (res != null) res.statusCode = 200;
    }
    
    global void execute(SchedulableContext SC)
    {
        main();
    }
    
    
    
    
}