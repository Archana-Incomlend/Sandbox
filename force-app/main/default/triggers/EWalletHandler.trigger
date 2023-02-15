trigger EWalletHandler on eWallet__c (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            if (WebServiceCallout.IsNeedRunTrigger && WebServiceCallout.FirstrunAfterEWallet) {
                for (eWallet__c eWallet : Trigger.new) {
                    System.debug('Processing eWallet__c with Id ' + eWallet.Id);
                    
                    eWallet__c oldEWallet = Trigger.oldMap.get(eWallet.Id);
                    if (eWallet.Balance_Rollup__c > oldEWallet.Balance_Rollup__c // eWallet.Balance_Rollup__c != oldEWallet.Balance_Rollup__c
                        || eWallet.Reservation_Rollup__c != oldEWallet.Reservation_Rollup__c
                        || eWallet.Withdrawals_Not_Processed__c != oldEWallet.Withdrawals_Not_Processed__c) {
                        System.debug('Pending condition was updated');
                        if (eWallet.Name == null) System.debug('Name is empty'); else
                        WebServiceCallout.notifyInvoiceAllocationRequest('EWALLET', eWallet.Name);
                    }
                }
            
            }
        }
    }
}