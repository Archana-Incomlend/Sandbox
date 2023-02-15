trigger AccountHandler on Account (before insert, after update) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      for (Account account : Trigger.new) {
        account.purchaser_first_date_sales_commission__c = null;
      }
    }
  }
  if (Trigger.isAfter) {
    if (Trigger.isUpdate) {
      System.debug('limits ' + Limits.getQueries() + ' soql ' + Limits.getDMLStatements() + ' dml ' + Limits.getCallouts() + ' co ' + Limits.getCpuTime() + ' cpu ' + Limits.getHeapSize() + ' heap');
      if (WebServiceCallout.IsNeedRunTrigger && WebServiceCallout.FirstrunAfterAccount) {
        for (Account account : Trigger.new) 
        {
          String accountId = account.Id;
          System.debug('Processing Account with Id ' + accountId);
          Account oldAccount = Trigger.oldMap.get(accountId);
    
          if (account.prelisting_requested_amount_usd_equiv__c == oldAccount.prelisting_requested_amount_usd_equiv__c
              && account.prelisting_reqstd_amt_approv_buye_usd_eq__c == oldAccount.prelisting_reqstd_amt_approv_buye_usd_eq__c
              && account.Marketplace_Requested_amount_usd_equiv__c == oldAccount.Marketplace_Requested_amount_usd_equiv__c
              && account.Inprogress_advanced_amount_usd_equiv__c == oldAccount.Inprogress_advanced_amount_usd_equiv__c
              && account.Un_utilised_adv_amt_all_phases_usd_equiv__c == oldAccount.Un_utilised_adv_amt_all_phases_usd_equiv__c
              && account.Un_utilised_adv_amt_inc_prel_app_usd_eq__c == oldAccount.Un_utilised_adv_amt_inc_prel_app_usd_eq__c
              && account.Un_utilised_adv_amt_mrk_place_usd_equiv__c == oldAccount.Un_utilised_adv_amt_mrk_place_usd_equiv__c
              && account.Un_utilised_advanced_amount_usd_equiv__c == oldAccount.Un_utilised_advanced_amount_usd_equiv__c
              && account.Credit_Limit_Rem_all_phases_usd_equiv__c == oldAccount.Credit_Limit_Rem_all_phases_usd_equiv__c
              && account.CL_Rem_inc_prelst_buyer_conf_usd_eq__c == oldAccount.CL_Rem_inc_prelst_buyer_conf_usd_eq__c
              && account.Credit_Limit_Remain_inc_mrkplc_usd_equiv__c == oldAccount.Credit_Limit_Remain_inc_mrkplc_usd_equiv__c
              && account.Credit_Limit_Remaining_usd_equiv__c == oldAccount.Credit_Limit_Remaining_usd_equiv__c
              && account.Inprogress_invoice_amount_usd_equiv__c == oldAccount.Inprogress_invoice_amount_usd_equiv__c
              && account.overdue_invoice_amount_usd_equiv__c == oldAccount.overdue_invoice_amount_usd_equiv__c)
            continue;
    
          if (GlobalMethods_v9.doesAccountHaveDebitOnCreditLimitExposure(oldAccount)
              && !GlobalMethods_v9.doesAccountHaveDebitOnCreditLimitExposure(account)) 
          {
            System.debug('Pending condition was updated');
            String v_listQuery = 'SELECT Id FROM Supplier_Buyer_Map__c WHERE Buyer__c = :accountId';
            List<Supplier_Buyer_Map__c> v_result = database.query(v_listQuery);
            for (Supplier_Buyer_Map__c v_map : v_result) {
              WebServiceCallout.notifyInvoiceAllocationRequest('MAP', v_map.Id);
            }
          }
        }
      }
    }
  }
}