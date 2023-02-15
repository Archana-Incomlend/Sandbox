public class TransactionTriggerHandler {
    public static boolean needRunTrigger = true;
    public static boolean firstRun = true;

    public static List<String> transactionTypeToCheck = new List<String>{'70.Deposit','80.Withdrawal','99.Adjustment'};

    public void beforeInsert(List<Transaction__c> newRecords) {
        beforeUpdateFXContract(null, newRecords);
    }
    
    public void beforeUpdate(Map<Id, Transaction__c> oldRecordsMap, Map<Id, Transaction__c> newRecordsMap){
        beforeupdateFXContract(oldRecordsMap, newRecordsMap.values());
    }
    
    //public void beforeDelete(Map<Id, Transaction__c> deletedRecordsMap) { }

    public void afterInsert(List<Transaction__c> newRecords) {
        updateFXContract(null, newRecords);
    }
    
    public void afterUpdate(Map<Id, Transaction__c> oldRecordsMap, Map<Id, Transaction__c> newRecordsMap){
        updateFXContract(oldRecordsMap, (List<Transaction__c>)newRecordsMap.values());
    }
    
    public void afterDelete(Map<Id, Transaction__c> deletedRecordsMap) {
        updateFXContract(deletedRecordsMap, new List<Transaction__c>());
    }
    
    //public void afterUndelete(List<Transaction__c> undeletedRecords) { afterInsert(undeletedRecords); }
    
    // Author : LuanHT
    // Modified : Mel Dinh
    // Description: if transactions use FX Contract, update remaining amount of FX Contract
    private void updateFXContract(Map<Id, Transaction__c> oldRecordsMap, List<Transaction__c> newRecords){
        if(!needRunTrigger){
            return;
        }
        if (oldRecordsMap == null){
            oldRecordsMap = new Map<Id, Transaction__c>();
        }

        // Map for getting FxContract and total amount for transaction.
        Set<Id> setFxContract = new Set<Id>();
        Set<Id> setFxContractToCheck = new Set<Id>();
        for(Transaction__c trn : newRecords) {
            Transaction__c oldTrn = oldRecordsMap.get(trn.id);
            if (transactionTypeToCheck.indexOf(trn.Type__c) != -1) {
                if( oldTrn == null 
                   ? trn.FX_Contract__c != null
                   : (trn.FX_Contract__c != oldTrn.FX_Contract__c
                      || trn.Tranche_amount__c != oldTrn.Tranche_amount__c))
                {
                    setFxContract.add(trn.FX_Contract__c);
                    setFxContractToCheck.add(trn.FX_Contract__c);
                    if (oldTrn != null) {
                        setFxContract.add(trn.FX_Contract__c);
                        setFxContractToCheck.add(oldTrn.FX_Contract__c);
                    }
                }
                continue;
            }
            if( oldTrn == null 
               ? trn.FX_Contract__c != null
               : (trn.FX_Contract__c != oldTrn.FX_Contract__c
                  || trn.Tranche_amount__c != oldTrn.Tranche_amount__c))
            {
                setFxContract.add(trn.FX_Contract__c);
                if (oldTrn != null)
                    setFxContract.add(oldTrn.FX_Contract__c);
            }
        }
        
        if(newRecords.isEmpty()){
            for(Transaction__c oldTrn : oldRecordsMap.values()) {
                if (transactionTypeToCheck.indexOf(oldTrn.Type__c) == -1) {
                    setFxContract.add(oldTrn.FX_Contract__c);
                } else if (oldTrn.FX_Contract__c != null) {
                    setFxContractToCheck.add(oldTrn.FX_Contract__c);
                    if (oldTrn.Tranche_amount__c != null) 
                        setFxContract.add(oldTrn.FX_Contract__c);
                }
            }
        }
        setFxContract.remove(null);
        setFxContractToCheck.remove(null);
        if (setFxContract.isEmpty() && setFxContractToCheck.isEmpty()) return;
       
        // Get All target Contract
        Map<String,List<FX_Contract__c>> mapFxContract = new Map<String,List<FX_Contract__c>>();
        
        for (FX_Contract__c fxContract : [SELECT Id, Name, Amount__c,
                                          Remain_amount__c, CCY_Target__c
                                          FROM FX_Contract__c
                                          WHERE ID IN: setFxContract]) 
        {
            List<FX_Contract__c> fxContractTarget = mapFxContract.get(fxContract.CCY_Target__c);
            if(fxContractTarget == null){
                fxContractTarget = new List<FX_Contract__c>();
            }
            fxContractTarget.add(fxContract);
            mapFxContract.put(fxContract.CCY_Target__c, fxContractTarget);
        }

        List<FX_Contract__c> fxContractTarget = new List<FX_Contract__c>();
        for(String ccy: mapFxContract.keySet()){
            fxContractTarget.addAll(recalculateRemainAmount(mapFxContract.get(ccy), ccy));
        }
        
        // Update FX Contract 
        if(fxContractTarget.size() > 0){
            update fxContractTarget;
        }

        setFxContractToCheck.remove(null);
        if (setFxContractToCheck.size() > 0) {
            List<Fx_Contract__c> listFxContractToCheck = recalculateSumToCheck(setFxContractToCheck);
            update listFxContractToCheck;
        }
    }
    
    private void beforeUpdateFXContract(Map<Id, Transaction__c> oldRecordsMap, List<Transaction__c> newRecords){
        if(!needRunTrigger){
            return;
        }
        if (oldRecordsMap == null)
            oldRecordsMap = new Map<Id, Transaction__c>();
        Map<Id, FX_Contract__c> fxContractMap = new Map<Id, FX_Contract__c>(
            									[SELECT Id, Tranche_Name__c, Origination_Rate__c, CCY_Target__c  
                                                 FROM Fx_Contract__c]);
        for (Transaction__c trn : newRecords) {
            if (trn.Fx_Contract__c == null && trn.Tranche_amount__c == null 
                    && trn.Tranche_amount_percentage__c == null && trn.Tranche_amount_USD__c == null) 
            {
                continue;
            }

            Transaction__c oldTrn = oldRecordsMap.get(trn.id);
            if (oldTrn != null && trn.Fx_Contract__c == oldTrn.Fx_Contract__c && trn.Tranche_amount__c == oldTrn.Tranche_amount__c 
                    && trn.Tranche_amount_percentage__c == oldTrn.Tranche_amount_percentage__c && trn.Tranche_amount_USD__c == oldTrn.Tranche_amount_USD__c) 
            {
                continue;
            }

            if (trn.FX_Contract__c != null && fxContractMap.get(trn.FX_Contract__c) != null
                && transactionTypeToCheck.indexOf(trn.Type__c) == -1 
                && trn.CCY__c != fxContractMap.get(trn.FX_Contract__c).CCY_Target__c) 
            {
                trn.Fx_Contract__c = null;
            }
            trn.Tranche_name__c = trn.FX_Contract__c != null ? fxContractMap.get(trn.FX_Contract__c).Tranche_Name__c : null;
            if (trn.FX_Contract__c == null || trn.Tranche_amount__c == null) {
                trn.Tranche_amount__c = null;
                trn.Tranche_amount_percentage__c = null;
                trn.Tranche_amount_USD__c = null;
            } else if (fxContractMap.get(trn.FX_Contract__c) != null && trn.Tranche_amount__c != null) {

                if (trn.amount__c != 0 && (trn.Tranche_amount_percentage__c == null || (oldTrn != null && oldTrn.Tranche_amount_percentage__c != null)))
                    trn.Tranche_amount_percentage__c = (trn.Tranche_amount__c / trn.amount__c * 100).setScale(2, System.RoundingMode.HALF_EVEN);
                if (trn.Tranche_amount_USD__c == null || (oldTrn != null && oldTrn.Tranche_amount_USD__c != null) ) 
                    trn.Tranche_amount_USD__c = trn.Tranche_amount__c * fxContractMap.get(trn.FX_Contract__c).Origination_Rate__c;
            } 
        }
    }

    public List<Fx_Contract__c> recalculateSumToCheck(Set<Id> setFxContractToCheck) {
        List<Fx_Contract__c> result = [SELECT Id, CCY_Target__c FROM Fx_Contract__c WHERE Id IN :setFxContractToCheck];
        Map<Id, Fx_Contract__c> fxContractMap = new Map<Id, Fx_Contract__c>(result);
        for (Fx_Contract__c fxContract : result) {
            fxContract.Sum_Deposit_Withdrawal__c = 0;
            fxContract.Sum_Deposit_Withdrawal_USD__c = 0;
        }

        List<Transaction__c> transactionList = [SELECT Id, Amount__c, FX_Contract__c, CCY__c
                                                FROM Transaction__c
                                                WHERE FX_Contract__c IN :setFxContractToCheck
                                                AND Type__c IN :transactionTypeToCheck];
        for (Transaction__c trn : transactionList) {
            Fx_Contract__c fxContract = fxContractMap.get(trn.Fx_Contract__c);
            if (trn.CCY__c == 'USD') {
                fxContract.Sum_Deposit_Withdrawal_USD__c += trn.Amount__c;
            } else if (trn.CCY__c == fxContract.CCY_Target__c) {
                fxContract.Sum_Deposit_Withdrawal__c += trn.Amount__c;
            } 
        }
        return result;
    }

    public static List<FX_Contract__c> recalculateRemainAmount(List<FX_Contract__c> fxContractList, String CCY) {
		
        Map<Id, FX_Contract__c> fxcMap = new Map<Id, FX_Contract__c>(fxContractList);
        List<Transaction__c> currentTransaction = [SELECT Id, Name, Amount__c, Tranche_amount__c, FX_Contract__c
                                                   FROM Transaction__c
                                                   WHERE FX_Contract__c IN :fxcMap.keySet() 
                                                   AND CCY__c = :CCY 
                                                   AND Tranche_amount__c != null];
        Map<Id, List<Transaction__c>> mapcurrentTransaction = new Map<Id, List<Transaction__c>>();
        for (Transaction__c tr : currentTransaction) {
            if (mapcurrentTransaction.containsKey(tr.FX_Contract__c)) {
                mapcurrentTransaction.get(tr.FX_Contract__c).add(tr);
            } else {
                List<Transaction__c> tmp = new List<Transaction__c>();
                tmp.add(tr);
                mapcurrentTransaction.put(tr.FX_Contract__c, tmp);
            }
        }

        for(FX_Contract__c fxContract : fxContractList) {
            System.debug('fxContract : ' + fxContract.Name);
            fxContract.Remain_amount__c = fxContract.Amount__c;
            if (mapcurrentTransaction.containsKey(fxContract.Id)) {           
                for (Transaction__c target : mapcurrentTransaction.get(fxContract.Id)) {
                    if(target.Tranche_amount__c != null){
                        fxContract.Remain_amount__c += target.Tranche_amount__c;
                    } else {
                        System.debug(target.Id + ' ' + fxContract.Id + ' tranche amount empty');
                    }
                }
            }
        }
        return fxContractList;
    }
}