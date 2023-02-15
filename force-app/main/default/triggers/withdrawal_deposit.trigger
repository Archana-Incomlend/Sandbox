trigger withdrawal_deposit 
        on Withdrawal_Deposit__c ( after insert, after update, after delete, after undelete) {
  
  Set<Id> walletTrusteeIds = new Set<Id>();

  if (Trigger.isAfter) {
    if(Trigger.isInsert || Trigger.isUndelete) {
      RollupUtility.afterInsert(walletTrusteeIds, Trigger.New);
    } else if(Trigger.isUpdate) {
      RollupUtility.afterUpdate(walletTrusteeIds, Trigger.OldMap, Trigger.New);
    } else if(Trigger.isDelete) {
      RollupUtility.afterDelete(walletTrusteeIds, Trigger.Old);
    }
    if (walletTrusteeIds.size() > 0) RollupUtility.rollupWithdrawalDepositToeWalletTrustee(walletTrusteeIds);
  }

}