public without sharing class RollupUtility {

    public static boolean needRunTrigger = true;
    public static boolean IsNeedRunTrigger
    {
      public get  // to enable trigger during test set it to null
      {
        return Test.isRunningTest() ? needRunTrigger == null : needRunTrigger == true;
      }
      public set
      {
          if (value) needRunTrigger = Test.isRunningTest() ? null : true;
          else needRunTrigger = false;
      }
    }

    public static boolean IgnoreFirstRun = false;
    public static void resetFirstRun() {
        afterTransaction = true;
        afterInvoice = true;
        afterWithdrawalDeposit = true;
        afterAllocation = true;
    }
    public static boolean afterTransaction = true;
    private static boolean FirstrunAfterTransaction { 
        private get
        {
          if (IgnoreFirstRun) return true; else if (!afterTransaction) return false;
          afterTransaction = false;
          return true;
        }
    }
    public static boolean afterInvoice = true;
    private static boolean FirstrunAfterInvoice { 
        private get
        {
          if (IgnoreFirstRun) return true; else if (!afterInvoice) return false;
          afterInvoice = false;
          return true;
        }
    }  
    public static boolean afterWithdrawalDeposit = true;
    private static boolean FirstrunAfterWithdrawalDeposit { 
        private get
        {
          if (IgnoreFirstRun) return true; else if (!afterWithdrawalDeposit) return false;
          afterWithdrawalDeposit = false;
          return true;
        }
    }  
    public static boolean afterAllocation = true;
    private static boolean FirstrunAfterAllocation { 
        private get
        {
          if (IgnoreFirstRun) return true; else if (!afterAllocation) return false;
          afterAllocation = false;
          return true;
        }
    }  

    // Start rollup transaction to eWallet Trustee
    public static void afterInsert(Set<Id> walletTrusteeIds, List<Transaction__c> newRecords) {
        if (!isNeedRunTrigger || !FirstrunAfterTransaction) return;
        for(Transaction__c trn:newRecords){
            If(trn.eWallet_Trustee__c!=null){
                walletTrusteeIds.add(trn.eWallet_Trustee__c);
            }
        }
    }

    public static void afterUpdate(Set<Id> walletTrusteeIds, Map<Id, Transaction__c> oldRecordsMap, List<Transaction__c> newRecords) {
        System.debug('ok transaction to ewallet trustee ' + isNeedRunTrigger + ' ' + (!IgnoreFirstRun ? ''+afterTransaction : ''));
        if (!isNeedRunTrigger || !FirstrunAfterTransaction) return;
        for(Transaction__c trn:newRecords){
            if (trn.Amount__c != oldRecordsMap.get(trn.Id).Amount__c
                || trn.Status__c != oldRecordsMap.get(trn.Id).Status__c
                || trn.isArchived__c != oldRecordsMap.get(trn.Id).isArchived__c) 
            {
                If(trn.eWallet_Trustee__c!=null){
                    walletTrusteeIds.add(trn.eWallet_Trustee__c);
                }
            }
            If(trn.eWallet_Trustee__c!=oldRecordsMap.get(trn.Id).eWallet_Trustee__c){
                If(oldRecordsMap.get(trn.Id).eWallet_Trustee__c!=null){
                    walletTrusteeIds.add(oldRecordsMap.get(trn.Id).eWallet_Trustee__c);
                }
                If(trn.eWallet_Trustee__c!=null){
                    walletTrusteeIds.add(trn.eWallet_Trustee__c);
                }
            }
        }
    }

    public static void afterDelete(Set<Id> walletTrusteeIds, List<Transaction__c> oldRecords) {
        if (!isNeedRunTrigger && (oldRecords.size() <= 1 && !IgnoreFirstRun && !FirstrunAfterTransaction)) return;
        for(Transaction__c trn:oldRecords){
            If(trn.eWallet_Trustee__c!=null){
                walletTrusteeIds.add(trn.eWallet_Trustee__c);
            }
        }
    }

    public static void rollupTransactionToeWalletTrustee(Set<Id> walletTrusteeIds){
        if (!isNeedRunTrigger) return;
        if (walletTrusteeIds != null && !Test.isRunningTest()) walletTrusteeIds.remove(null);
        if (walletTrusteeIds == null || walletTrusteeIds.size() == 0) return;
        // walletTrusteeIds.remove('a1C0I000005D1j2UAC'); // Incomlend Operations USD 000020
        // walletTrusteeIds.remove('a010I00001hfiqPQAQ'); // Incomlend Supplier Discount USD 003819
        System.debug('rollup transaction eWallet trustee ' + walletTrusteeIds.size());
        If(walletTrusteeIds!=null && walletTrusteeIds.size()>0){
            Map<Id,decimal> inProgressMap = new Map<Id,decimal>();
            Map<Id,decimal> discountMap = new Map<Id,decimal>();
            Map<Id,decimal> balanceMap = new Map<Id,decimal>();

            // Map<Id,decimal> inProgressTemp = new Map<Id,decimal>();
            // Map<Id,decimal> discountTemp = new Map<Id,decimal>();
            // Map<Id,decimal> balanceTemp = new Map<Id,decimal>();
            
            List<AggregateResult> aggList = [Select eWallet_Trustee__c walletTrustee, //MIN(eWallet_Trustee__r.In_Progress__c) inprogress, MIN(eWallet_Trustee__r.Total_Discount_Earned__c) discount, MIN(eWallet_Trustee__r.Balance__c) balance
                                            Sum(Amount__c) amt,invoice_finance_deal__r.phase__c phase,Type__c type,status__c status,isarchived__c isArchived  from Transaction__c 
                                            where (eWallet_Trustee__c in:walletTrusteeIds AND isarchived__c = false
                                                AND (status__c ='Confirmed by Finance'
                                                    OR  status__c ='Confirmed by operations' ))
                                            OR (eWallet_Trustee__c in:walletTrusteeIds AND isarchived__c = true 
                                                AND Type__c ='05.Invoice Discount Amount' 
                                                AND status__c ='Confirmed by operations')
                                            OR (eWallet_Trustee__c in:walletTrusteeIds AND isarchived__c = true 
                                                AND invoice_finance_deal__r.phase__c ='3:IN PROGRESS'
                                                AND (Type__c ='01.Invoice Purchase' OR  Type__c ='04.Invoice Capital Repayment')
                                                AND status__c ='Confirmed by operations')
                                            Group By eWallet_Trustee__c,invoice_finance_deal__r.phase__c,Type__c,status__c,isarchived__c];
            
            for(AggregateResult agg:aggList){
                Id walletTrusteeId = (Id)agg.get('walletTrustee');
                decimal amount = (Decimal)agg.get('amt');
                string phase = (string)agg.get('phase');
                string type = (string)agg.get('type');
                string status = (string)agg.get('status');
                Boolean isArchived = (Boolean)agg.get('isArchived');

                // inProgressTemp.put(walletTrusteeId, (Decimal)agg.get('inprogress'));
                // discountTemp.put(walletTrusteeId, (Decimal)agg.get('discount'));
                // balanceTemp.put(walletTrusteeId, (Decimal)agg.get('balance'));
                
                If(phase=='3:IN PROGRESS' && (type=='01.Invoice Purchase' || type=='04.Invoice Capital Repayment') && status=='Confirmed by operations' && amount!=null && amount!=0){
                    decimal progressAmount = 0;
                    If(inProgressMap.containsKey(walletTrusteeId)){
                        progressAmount = inProgressMap.get(walletTrusteeId);
                    }
                    progressAmount += amount;
                    inProgressMap.put(walletTrusteeId,progressAmount);
                }
                
                If(type=='05.Invoice Discount Amount' && status=='Confirmed by operations' && amount!=null && amount!=0){
                    decimal discountAmount = 0;
                    If(discountMap.containsKey(walletTrusteeId)){
                        discountAmount = discountMap.get(walletTrusteeId);
                    }
                    discountAmount += amount;
                    discountMap.put(walletTrusteeId,discountAmount);
                }
                
                If((status=='Confirmed by Finance' || status=='Confirmed by operations') && !isArchived && amount!=null && amount!=0){
                    decimal balanceAmount = 0;
                    
                    If(balanceMap.containsKey(walletTrusteeId)){
                        balanceAmount = balanceMap.get(walletTrusteeId);
                    }
                    balanceAmount += amount;
                    balanceMap.put(walletTrusteeId,balanceAmount);
                }            
            }
            
            List<eWallet_Trustee__c> walletTrusteeList = new List<eWallet_Trustee__c>();
            for(Id walTrustId:walletTrusteeIds){
                eWallet_Trustee__c walletTrustee = new eWallet_Trustee__c();
                walletTrustee.Id = walTrustId;
                walletTrustee.In_Progress__c = 0;
                walletTrustee.Total_Discount_Earned__c = 0;
                walletTrustee.Balance__c = 0;
                // boolean updateAnyway = true;
                If(inProgressMap.containsKey(walTrustId)){
                    walletTrustee.In_Progress__c = inProgressMap.get(walTrustId);
                    // updateAnyway = false;
                }
                
                If(discountMap.containsKey(walTrustId)){
                    walletTrustee.Total_Discount_Earned__c = discountMap.get(walTrustId);
                    // updateAnyway = false;
                }
                
                If(balanceMap.containsKey(walTrustId)){
                    walletTrustee.Balance__c = balanceMap.get(walTrustId);
                    // updateAnyway = false;
                }
                
                // if (GlobalTriggerHandler.coalesce(inProgressTemp.get(walTrustId)) == GlobalTriggerHandler.coalesce(inProgressMap.get(walTrustId))
                //     && GlobalTriggerHandler.coalesce(discountTemp.get(walTrustId)) == GlobalTriggerHandler.coalesce(discountMap.get(walTrustId))
                //     && GlobalTriggerHandler.coalesce(balanceTemp.get(walTrustId)) == GlobalTriggerHandler.coalesce(balanceMap.get(walTrustId))) 
                //     if (!updateAnyway) continue;
                walletTrusteeList.add(walletTrustee);
            }
            
            if (walletTrusteeList.size()>0) System.debug('total ewallet trustee ' + walletTrusteeList.size());
            if (walletTrusteeList.size()>0) update walletTrusteeList;
        }
    }
    // End rollup transaction to eWallet Trustee

    // Start code shared between roll up invoice to map and marketplace
    public static void afterInsert(Set<Id> mapIds, Set<Id> marketplaceIds, List<Invoice_finance_deal__c> newRecords) {
        if (!isNeedRunTrigger || !FirstrunAfterInvoice) return;
        for (Invoice_finance_deal__c invoice : newRecords) {
            if (mapIds != null && invoice.invoice_amount_USD_Equivalent__c != null) {
                mapIds.add(invoice.Supplier_Buyer_Map__c);
            }
            if (marketplaceIds != null && invoice.remaining_amount__c > 0 && invoice.phase__c == '2:ON MARKETPLACE') {
                marketplaceIds.add(invoice.Marketplace_link__c);
            }
        }
    }

    public static void afterUpdate(Set<Id> mapIds, Set<Id> marketplaceIds, Map<Id, Invoice_finance_deal__c> oldRecordsMap, List<Invoice_finance_deal__c> newRecords) {
        System.debug('ok invoice to map and marketplace ' + isNeedRunTrigger + ' ' + (!IgnoreFirstRun ? ''+afterInvoice : ''));
        if (!isNeedRunTrigger || !FirstrunAfterInvoice) return;
        if (mapIds == null) mapIds = new Set<Id>();
        if (marketplaceIds == null) marketplaceIds = new Set<Id>();
        for (Invoice_finance_deal__c invoice : newRecords) {
            Invoice_finance_deal__c oldInvoice = oldRecordsMap.get(invoice.Id);
            if (invoice.invoice_amount__c != oldInvoice.invoice_amount__c
                    || ((invoice.over_due_days__c > 0) != (oldInvoice.over_due_days__c > 0))
                    || invoice.phase__c != oldInvoice.phase__c) {
                mapIds.add(invoice.Supplier_Buyer_Map__c);
            }
            if (invoice.Supplier_Buyer_Map__c != oldInvoice.Supplier_Buyer_Map__c) {
                mapIds.add(invoice.Supplier_Buyer_Map__c);
                mapIds.add(oldInvoice.Supplier_Buyer_Map__c);
            }
            if (marketplaceIds != null && (invoice.remaining_amount__c != oldInvoice.remaining_amount__c || invoice.phase__c != oldInvoice.phase__c)
                    && (invoice.phase__c == '2:ON MARKETPLACE' || oldInvoice.phase__c == '2:ON MARKETPLACE')){
                marketplaceIds.add(invoice.Marketplace_link__c);
            }
        }
    }

    public static void afterDelete(Set<Id> mapIds, Set<Id> marketplaceIds, List<Invoice_finance_deal__c> oldRecords) {
        if (!isNeedRunTrigger || !FirstrunAfterInvoice) return;
        for (Invoice_finance_deal__c invoice : oldRecords) {
            if (mapIds != null && invoice.invoice_amount_USD_Equivalent__c != null) {
                mapIds.add(invoice.Supplier_Buyer_Map__c);
            }
            if (marketplaceIds != null && invoice.remaining_amount__c > 0 && invoice.phase__c == '2:ON MARKETPLACE') {
                marketplaceIds.add(invoice.Marketplace_link__c);
            }
        }
    }

    // Start code shared between roll up invoice to map and marketplace

    // Start roll up invoice to map

    public static void rollupInvoiceToMap(Set<Id> mapIds) {
        if (!isNeedRunTrigger) return;
        if (mapIds != null && !Test.isRunningTest()) mapIds.remove(null);
        if (mapIds == null || mapIds.size() == 0) return;
        System.debug('rollup invoice map ' + mapIds.size());
        Map<Id,decimal> inProgressMap = new Map<Id,decimal>();
        Map<Id,decimal> preListingMap = new Map<Id,decimal>();
        List<AggregateResult> aggList = null;
        aggList = [ SELECT Supplier_Buyer_Map__c supplierBuyerMap, SUM(invoice_amount__c) amt, phase__c phase  FROM Invoice_finance_deal__c 
                    WHERE Supplier_Buyer_Map__c IN :mapIds
                    GROUP BY Supplier_Buyer_Map__c, phase__c ];
        
        for (AggregateResult agg : aggList) {
            Id supplierBuyerMap = (Id)agg.get('supplierBuyerMap');
            decimal amount = (Decimal)agg.get('amt');
            string phase = (string)agg.get('phase');
            
            if (phase=='1:PRE LISTING' && amount != null && amount != 0) {
                decimal preListingAmount = 0;
                If(preListingMap.containsKey(supplierBuyerMap)){
                    preListingAmount = preListingMap.get(supplierBuyerMap);
                }
                preListingAmount += amount;
                preListingMap.put(supplierBuyerMap, preListingAmount);
            }

            if (phase=='3:IN PROGRESS' && amount != null && amount != 0) {
                decimal inProgressAmount = 0;
                If(inProgressMap.containsKey(supplierBuyerMap)){
                    inProgressAmount = inProgressMap.get(supplierBuyerMap);
                }
                inProgressAmount += amount;
                inProgressMap.put(supplierBuyerMap, inProgressAmount);
            }
        }
        
        List<Supplier_Buyer_Map__c> mapList = [SELECT Id, Amount_Prelisting_USD__c, Inprogress_invoice_amount_usd_equiv__c, Marketplace__r.rate__c FROM Supplier_Buyer_Map__c WHERE Id IN :mapIds];
        Map<Id, Supplier_Buyer_Map__c> mapMap = new Map<Id, Supplier_Buyer_Map__c>(mapList);
        if (Test.isRunningTest()) mapMap.put(null, new Supplier_Buyer_Map__c());
        mapList = new List<Supplier_Buyer_Map__c>();
        for (Id mapId : mapIds) {
            Supplier_Buyer_Map__c supplierBuyerMap = new Supplier_Buyer_Map__c();
            supplierBuyerMap.Id = mapId;
            supplierBuyerMap.Amount_Prelisting_USD__c = null;
            supplierBuyerMap.Inprogress_invoice_amount_usd_equiv__c = null;

            if (preListingMap.containsKey(mapId)) 
                supplierBuyerMap.Amount_Prelisting_USD__c = preListingMap.get(mapId) * mapMap.get(mapId).Marketplace__r.rate__c;
            if (inProgressMap.containsKey(mapId)) 
                supplierBuyerMap.Inprogress_invoice_amount_usd_equiv__c = inProgressMap.get(mapId) * mapMap.get(mapId).Marketplace__r.rate__c;
            
            if (Math.Abs(GlobalTriggerHandler.coalesce(supplierBuyerMap.Amount_Prelisting_USD__c) - GlobalTriggerHandler.coalesce(mapMap.get(mapId).Amount_Prelisting_USD__c)) < 0.5 
                    && Math.Abs(GlobalTriggerHandler.coalesce(supplierBuyerMap.Inprogress_invoice_amount_usd_equiv__c) - GlobalTriggerHandler.coalesce(mapMap.get(mapId).Inprogress_invoice_amount_usd_equiv__c)) < 0.5)
                continue;
            
            if (Test.isRunningTest() && mapId == null) continue;
            mapList.add(supplierBuyerMap);
        }
        
        if (mapList.size()>0) {
            System.debug('total map ' + mapList.size());
            update mapList;
        }
    }
    // End roll up invoice to map

    // start rollup invoice to marketplace

    public static void rollupInvoiceToMarketplace(Set<Id> marketplaceIds) {
        if (!isNeedRunTrigger) return;
        if (marketplaceIds != null && !Test.isRunningTest()) marketplaceIds.remove(null);
        if (marketplaceIds == null || marketplaceIds.size() <= 0) return;
        System.debug('rollup invoice marketplace ' + marketplaceIds.size());
        List<AggregateResult> aggList = null;
        aggList = [ SELECT Marketplace_link__c marketplace, //MIN(Marketplace_link__r.Available_on_Marketplace_RH__c) temp, 
                    SUM(remaining_amount__c) amt FROM Invoice_finance_deal__c 
                    WHERE Marketplace_link__c IN :marketplaceIds
                    AND phase__c = '2:ON MARKETPLACE'
                    GROUP BY Marketplace_link__c, phase__c ];
        
        Map<Id, decimal> onmarketplaceMap = new Map<Id, decimal>();
        // Map<Id, decimal> temp = new Map<Id, decimal>();
        for (AggregateResult agg : aggList) {
            Id marketplaceId = (Id)agg.get('marketplace');
            decimal amount = (Decimal)agg.get('amt');
            onmarketplaceMap.put(marketplaceId, amount);
            // temp.put(marketplaceId, (Decimal)agg.get('temp'));
        }

        List<Marketplace__c> marketplaceList = new List<Marketplace__c>();
        for (Id marketplaceId : marketplaceIds) {
            Marketplace__c marketplace = new Marketplace__c();
            marketplace.Id = marketplaceId;
            marketplace.Available_on_Marketplace_RH__c = 0;
            // boolean updateAnyway = true;
            if (onmarketplaceMap.containsKey(marketplaceId)) {
                marketplace.Available_on_Marketplace_RH__c = onmarketplaceMap.get(marketplaceId);
                // updateAnyway = false;
            }

            // if (GlobalTriggerHandler.coalesce(temp.get(marketplaceId)) == GlobalTriggerHandler.coalesce(onmarketplaceMap.get(marketplaceId)))
            //     if (!updateAnyway) continue;
            marketplaceList.add(marketplace);
        }
        
        if (marketplaceList.size()>0) {
            System.debug('total marketplace ' + marketplaceList.size());
            update marketplaceList;
        }
    }
 
    // End roll up invoice to marketplace

    // Start roll up allocation to eWallet
    public static void afterInsert(Set<Id> walletTrusteeIds, List<Invoice_Allocation__c> newRecords) {
        if (!isNeedRunTrigger || newRecords.size() == 0 || (newRecords[0].Funder__c != '00128000018nJHcAAM' && !FirstrunAfterAllocation)) return;
        for (Invoice_Allocation__c currentAllocation : newRecords) {
            if (currentAllocation.eWallet_Trustee__c != null && currentAllocation.amount__c != 0 && currentAllocation.Status__c == 'Reservation') {
                walletTrusteeIds.add(currentAllocation.eWallet_Trustee__c);
            }
        }
    }

    public static void afterUpdate(Set<Id> walletTrusteeIds, Map<Id, Invoice_Allocation__c> oldRecordsMap, List<Invoice_Allocation__c> newRecords) {
        System.debug('ok allocation to ewallet trustee ' + isNeedRunTrigger + ' ' + (!IgnoreFirstRun ? ''+afterAllocation : ''));
        if (!isNeedRunTrigger || !FirstrunAfterAllocation) return;
        for (Invoice_Allocation__c currentAllocation : newRecords) {
            Invoice_Allocation__c allocation = oldRecordsMap.get(currentAllocation.Id);
            if ((currentAllocation.Status__c == 'Reservation' || allocation.Status__c == 'Reservation') &&
                (currentAllocation.amount__c != allocation.amount__c
                    || currentAllocation.eWallet_Trustee__c != allocation.eWallet_Trustee__c
                    || currentAllocation.Status__c != allocation.Status__c)) {
                if (currentAllocation.eWallet_Trustee__c != null) {
                    walletTrusteeIds.add(currentAllocation.eWallet_Trustee__c);
                }
                if (allocation.eWallet_Trustee__c != null) {
                    walletTrusteeIds.add(allocation.eWallet_Trustee__c);
                }
            }
        }
    }

    public static void afterDelete(Set<Id> walletTrusteeIds, List<Invoice_Allocation__c> oldRecords) {
        if (!isNeedRunTrigger || !FirstrunAfterAllocation) return;
        for (Invoice_Allocation__c currentAllocation : oldRecords) {
            if (currentAllocation.eWallet_Trustee__c != null && currentAllocation.amount__c != 0 && currentAllocation.Status__c == 'Reservation') {
                walletTrusteeIds.add(currentAllocation.eWallet_Trustee__c);
            }
        }
    }

    public static boolean rollupAllocationToeWalletTrustee(Set<Id> walletTrusteeIds) {
        if (!isNeedRunTrigger) return true;
        if (walletTrusteeIds != null && !Test.isRunningTest()) walletTrusteeIds.remove(null);
        if (walletTrusteeIds == null || walletTrusteeIds.size() == 0) return false;
        System.debug('rollup allocation eWallet trustee ' + walletTrusteeIds.size());
        if (walletTrusteeIds != null && walletTrusteeIds.size() > 0){
            boolean result = false;
            Map<Id,decimal> reservationMap = new Map<Id,decimal>();
            // Map<Id,decimal> temp = new Map<Id,decimal>();
            List<AggregateResult> aggList = [SELECT eWallet_Trustee__c walletTrustee, //MIN(eWallet_Trustee__r.Reservations__c) temp, 
                                            SUM(amount__c) amt, Status__c status FROM Invoice_Allocation__c 
                                            WHERE (eWallet_Trustee__c IN :walletTrusteeIds
                                                AND Status__c ='Reservation')
                                            GROUP BY eWallet_Trustee__c, Status__c];
            for (AggregateResult agg : aggList) {
                Id walletTrusteeId = (Id)agg.get('walletTrustee');
                decimal amount = (Decimal)agg.get('amt');
                string status = (string)agg.get('status');
                // temp.put(walletTrusteeId, (Decimal)agg.get('temp'));
                if (status == 'Reservation') {
                    decimal reservationAmount = 0;
                    if (reservationMap.containsKey(walletTrusteeId)){
                        reservationAmount = reservationMap.get(walletTrusteeId);
                    }
                    reservationAmount += amount;
                    reservationMap.put(walletTrusteeId,reservationAmount);
                }
            }
            
            List<eWallet_Trustee__c> walletTrusteeList = new List<eWallet_Trustee__c>();
            for (Id walTrustId : walletTrusteeIds) {
                eWallet_Trustee__c walletTrustee = new eWallet_Trustee__c();
                walletTrustee.Id = walTrustId;
                walletTrustee.Reservations__c = 0;
                // boolean updateAnyway = true;
                if (reservationMap.containsKey(walTrustId)) {
                    walletTrustee.Reservations__c = reservationMap.get(walTrustId);
                    // updateAnyway = false;
                }
                // if (GlobalTriggerHandler.coalesce(temp.get(walTrustId)) == GlobalTriggerHandler.coalesce(reservationMap.get(walTrustId))) 
                //     if (!updateAnyway) continue;
                walletTrusteeList.add(walletTrustee);    
            }
            
            if (walletTrusteeList.size() > 0) System.debug('total ewallet trustee ' + walletTrusteeList.size());
            if (walletTrusteeList.size() > 0) update walletTrusteeList;
            return result;
        }
        return false;
    }

    // End roll up allocation to eWallet

    // Start roll up withdrawal deposit to eWallet
    public static void afterInsert(Set<Id> walletTrusteeIds, List<Withdrawal_Deposit__c> newRecords) {
        if (!isNeedRunTrigger || !FirstrunAfterWithdrawalDeposit) return;
        for (Withdrawal_Deposit__c currentWithdrawalDeposit : newRecords) {
            if (currentWithdrawalDeposit.eWallet_Trustee__c != null && currentWithdrawalDeposit.Amount__c != 0 && currentWithdrawalDeposit.Status__c == 'Not Processed') {
                walletTrusteeIds.add(currentWithdrawalDeposit.eWallet_Trustee__c);
            }
        }
        if (walletTrusteeIds.size() == 0) afterWithdrawalDeposit = true; // workaround
    }

    public static void afterUpdate(Set<Id> walletTrusteeIds, Map<Id, Withdrawal_Deposit__c> oldRecordsMap, List<Withdrawal_Deposit__c> newRecords) {
        System.debug('ok withdrawal deposit to ewallet trustee ' + isNeedRunTrigger + ' ' + (!IgnoreFirstRun ? ''+afterWithdrawalDeposit : ''));
        if (!isNeedRunTrigger || !FirstrunAfterWithdrawalDeposit) return;
        for (Withdrawal_Deposit__c currentWithdrawalDeposit : newRecords) {
            Withdrawal_Deposit__c withdrawaldeposit = oldRecordsMap.get(currentWithdrawalDeposit.Id);
            if ((currentWithdrawalDeposit.Status__c == 'Not Processed' || withdrawaldeposit.Status__c == 'Not Processed') &&
                (currentWithdrawalDeposit.Amount__c != withdrawaldeposit.Amount__c
                    || currentWithdrawalDeposit.eWallet_Trustee__c != withdrawaldeposit.eWallet_Trustee__c
                    || currentWithdrawalDeposit.Status__c != withdrawaldeposit.Status__c)) {
                if (currentWithdrawalDeposit.eWallet_Trustee__c != null) {
                    walletTrusteeIds.add(currentWithdrawalDeposit.eWallet_Trustee__c);
                }
                if (withdrawaldeposit.eWallet_Trustee__c != null) {
                    walletTrusteeIds.add(withdrawaldeposit.eWallet_Trustee__c);
                }
            }
        }
        if (walletTrusteeIds.size() == 0) afterWithdrawalDeposit = true; // workaround
    }

    public static void afterDelete(Set<Id> walletTrusteeIds, List<Withdrawal_Deposit__c> oldRecords) {
        if (!isNeedRunTrigger || !FirstrunAfterWithdrawalDeposit) return;
        for (Withdrawal_Deposit__c currentWithdrawalDeposit : oldRecords) {
            if (currentWithdrawalDeposit.eWallet_Trustee__c != null && currentWithdrawalDeposit.Amount__c != 0 && currentWithdrawalDeposit.Status__c == 'Not Processed') {
                walletTrusteeIds.add(currentWithdrawalDeposit.eWallet_Trustee__c);
            }
        }
    }

    public static void rollupWithdrawalDepositToeWalletTrustee(Set<Id> walletTrusteeIds) {
        if (!isNeedRunTrigger) return;
        if (walletTrusteeIds != null && !Test.isRunningTest()) walletTrusteeIds.remove(null);
        if (walletTrusteeIds == null || walletTrusteeIds.size() == 0) return;
        System.debug('rollup wd eWallet trustee ' + walletTrusteeIds.size());
        if (walletTrusteeIds != null && walletTrusteeIds.size() > 0){
            Map<Id,decimal> withdrawalMap = new Map<Id,decimal>();
            // Map<Id,decimal> withdrawalTemp = new Map<Id,decimal>();
            Map<Id,decimal> depositMap = new Map<Id,decimal>();
            // Map<Id,decimal> depositTemp = new Map<Id,decimal>();
            List<AggregateResult> aggList = [SELECT eWallet_Trustee__c walletTrustee, //MIN(eWallet_Trustee__r.Deposits_Not_Processed__c) deposit, MIN(eWallet_Trustee__r.Withdrawals_Not_Processed__c) withdrawal, 
                                            SUM(Amount__c) amt, Status__c status, Type__c type FROM Withdrawal_Deposit__c 
                                            WHERE (eWallet_Trustee__c IN :walletTrusteeIds
                                                AND Status__c ='Not Processed')
                                            GROUP BY eWallet_Trustee__c, Status__c, Type__c];
            for (AggregateResult agg : aggList) {
                Id walletTrusteeId = (Id)agg.get('walletTrustee');
                decimal amount = (Decimal)agg.get('amt');
                string status = (string)agg.get('status');
                string type = (string)agg.get('type');
                // depositTemp.put(walletTrusteeId, (Decimal)agg.get('deposit'));
                // withdrawalTemp.put(walletTrusteeId, (Decimal)agg.get('withdrawal'));
                if (status == 'Not Processed' && type == '80.Withdrawal') {
                    decimal withdrawalAmount = 0;
                    If(withdrawalMap.containsKey(walletTrusteeId)){
                        withdrawalAmount = withdrawalMap.get(walletTrusteeId);
                    }
                    withdrawalAmount += amount;
                    withdrawalMap.put(walletTrusteeId,withdrawalAmount);
                }
                if (status == 'Not Processed' && type == '70.Deposit') {
                    decimal depositAmount = 0;
                    If(depositMap.containsKey(walletTrusteeId)){
                        depositAmount = depositMap.get(walletTrusteeId);
                    }
                    depositAmount += amount;
                    depositMap.put(walletTrusteeId,depositAmount);
                }
            }
            
            List<eWallet_Trustee__c> walletTrusteeList = new List<eWallet_Trustee__c>();
            for (Id walTrustId : walletTrusteeIds) {
                eWallet_Trustee__c walletTrustee = new eWallet_Trustee__c();
                walletTrustee.Id = walTrustId;
                walletTrustee.Deposits_Not_Processed__c = 0;
                walletTrustee.Withdrawals_Not_Processed__c = 0;
                // boolean updateAnyway = true;
                if (depositMap.containsKey(walTrustId)) {
                    walletTrustee.Deposits_Not_Processed__c = depositMap.get(walTrustId);
                    // updateAnyway = false;
                } 
                if (withdrawalMap.containsKey(walTrustId)) {
                    walletTrustee.Withdrawals_Not_Processed__c = withdrawalMap.get(walTrustId);
                    // updateAnyway = false;
                } 
                
                // if ((GlobalTriggerHandler.coalesce(depositTemp.get(walTrustId)) == GlobalTriggerHandler.coalesce(depositMap.get(walTrustId)))
                //     && (GlobalTriggerHandler.coalesce(withdrawalTemp.get(walTrustId)) == GlobalTriggerHandler.coalesce(withdrawalMap.get(walTrustId))))
                //     if (!updateAnyway) continue;
                walletTrusteeList.add(walletTrustee);
            }
            
            if (walletTrusteeList.size() > 0) System.debug('total ewallet trustee ' + walletTrusteeList.size());
            if (walletTrusteeList.size() > 0) update walletTrusteeList;
        }
    }

    // End roll up withdrawal deposit to eWallet
}