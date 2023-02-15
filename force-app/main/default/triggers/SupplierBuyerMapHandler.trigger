trigger SupplierBuyerMapHandler on Supplier_Buyer_Map__c (after update) {
    
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            if (WebServiceCallout.IsNeedRunTrigger && WebServiceCallout.FirstrunAfterMap) {
                for (Supplier_Buyer_Map__c supplierBuyerMap : Trigger.new) {
                    System.debug('Processing Supplier_Buyer_Map__c with Id ' + supplierBuyerMap.Id);
                    Supplier_Buyer_Map__c oldSupplierBuyerMap = Trigger.oldMap.get(supplierBuyerMap.Id);
                    Decimal oldCreditLimitAvalaible = oldSupplierBuyerMap.Credit_Limit_Avalaible__c;
                    String oldOnboardingStage = oldSupplierBuyerMap.map_onboarding_stage__c;
        
                    Decimal currentCreditLimitAvalaible = supplierBuyerMap.Credit_Limit_Avalaible__c;
                    String currentOnboardingStage = supplierBuyerMap.map_onboarding_stage__c;
                    if ((oldCreditLimitAvalaible != currentCreditLimitAvalaible)
                       || ('90.Onboarded' != oldOnboardingStage && '90.Onboarded' == currentOnboardingStage && oldOnboardingStage != currentOnboardingStage)) {
                        System.debug('Pending condition was updated');
                        WebServiceCallout.notifyInvoiceAllocationRequest('MAP', supplierBuyerMap.Id);
                    }
                }
            }                                
        }

    }
}