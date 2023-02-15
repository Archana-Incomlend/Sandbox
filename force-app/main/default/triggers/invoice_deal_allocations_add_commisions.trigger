trigger invoice_deal_allocations_add_commisions 
        on Invoice_Allocation__c (before insert, before update, after insert, after update, after delete, after undelete) {
  
  Set<Id> walletTrusteeIds = new Set<Id>();

  if (Trigger.isBefore) {
    if (Trigger.isInsert || Trigger.isUpdate) {
      for (Invoice_Allocation__c a : Trigger.new) {
        if (Trigger.isUpdate) {
          Invoice_Allocation__c oldA = Trigger.oldMap.get(a.Id);
          if (a.Discount__c == oldA.Discount__c
              && a.Funder_Agent_Commision_Percentage__c == oldA.Funder_Agent_Commision_Percentage__c
              && a.Funder_Agent_Commission_Type__c == oldA.Funder_Agent_Commission_Type__c
              && a.Expected_finance_period_buyback_capped__c == oldA.Expected_finance_period_buyback_capped__c
              && a.Applied_Funder_Discount_Profit_Share_Pct__c == oldA.Applied_Funder_Discount_Profit_Share_Pct__c
              && a.funder_agent__c == oldA.funder_agent__c) {
            continue;
          } 
        }
        GlobalTriggerHandler.calculateAllocationFees(a);
      }
      for (Invoice_Allocation__c a : Trigger.new) {
        if (a.Status__c == 'Canceled') continue;
        GlobalTriggerHandler.updateAllocation(a);
      }
    }
  }

  if (Trigger.isAfter) {
    try {
    if(Trigger.isInsert || Trigger.isUndelete) {
      RollupUtility.afterInsert(walletTrusteeIds, Trigger.New);
    } else if(Trigger.isUpdate) {
      RollupUtility.afterUpdate(walletTrusteeIds, Trigger.OldMap, Trigger.New);
    } else if(Trigger.isDelete) {
      RollupUtility.afterDelete(walletTrusteeIds, Trigger.Old);
    }
    } catch (Exception e) {Helper_Log Logs = new Helper_Log(); Logs.log(e); GlobalTriggerHandler.OutError('Rollup reservation allocation trustee error', Logs);} 
    if (walletTrusteeIds.size() > 0) RollupUtility.rollupAllocationToeWalletTrustee(walletTrusteeIds);
    // else if (Trigger.isUpdate && Trigger.Old[0].Status__c == 'Reservation') GlobalTriggerHandler.sendEmail(GlobalTriggerHandler.getEmailToSendException(), 'Rollup reservation allocation trustee no manual', '');
  }

}