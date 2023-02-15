trigger RollupTransactions on Transaction__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    Set<Id> walletTrusteeIds = new Set<Id>();
        
    //if(TransactionTriggerHandler.firstRun){ // if two trigger/flow update transaction
    //    TransactionTriggerHandler.firstRun = false;
        TransactionTriggerHandler handler = new TransactionTriggerHandler();
        // Is Before
        if(Trigger.isBefore) {
            if (Trigger.isInsert) {
                handler.beforeInsert(Trigger.New);
            }
            else if(Trigger.isUpdate) {
                handler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
            }
            else if(Trigger.isDelete) {
                //handler.beforeDelete(Trigger.oldMap);
            }
        }
        // Is After
        else {
            if(Trigger.isInsert || Trigger.isUndelete) {
                RollupUtility.afterInsert(walletTrusteeIds, Trigger.New);
                handler.afterInsert(Trigger.New);
            }
            else if(Trigger.isUpdate) {
                RollupUtility.afterUpdate(walletTrusteeIds, Trigger.OldMap, Trigger.New);
                handler.afterUpdate(Trigger.oldMap, Trigger.newMap);
            }
            else if(Trigger.isDelete) {
                RollupUtility.afterDelete(walletTrusteeIds, Trigger.Old);
                handler.afterDelete(Trigger.OldMap);
            }
        }
    //}

    If(walletTrusteeIds.size()>0){
        RollupUtility.rollupTransactionToeWalletTrustee(walletTrusteeIds);
    }
}