trigger EWalletTrusteeHandler on eWallet_Trustee__c (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            if (WebServiceCallout.IsNeedRunTrigger) {
                for (eWallet_Trustee__c eWalletTrustee : Trigger.new) {
                    System.debug('Processing eWallet_Trustee__c with Id ' + eWalletTrustee.Id);
                    eWallet_Trustee__c oldEWalletTrustee = Trigger.oldMap.get(eWalletTrustee.Id);
                    Decimal oldBalance = oldEWalletTrustee.Available_Balance__c;
                    Decimal currentBalance = eWalletTrustee.Available_Balance__c;
                    if (oldBalance != currentBalance) {
                        System.debug('Value of Available_Balance__c was changed');
                        WebServiceCallout.notifyInvoiceAllocationRequest('EWALLET', eWalletTrustee.Main_eWallet__r.Name);
                    }
                }
            }
        }
    }
}