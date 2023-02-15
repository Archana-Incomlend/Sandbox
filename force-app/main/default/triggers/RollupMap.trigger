trigger RollupMap on Supplier_Buyer_Map__c (before insert, before update) {

    if (Trigger.isBefore) {
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        if (Trigger.isInsert || Trigger.isUpdate){
            if (Trigger.isInsert) mapAccount = GlobalTriggerHandler.getAccountUpdateMap(Trigger.New);
            for (Supplier_Buyer_Map__c supplierBuyerMap : Trigger.New) 
            {
                if (Trigger.isInsert) GlobalTriggerHandler.insertMap(supplierBuyerMap, mapAccount);
                if (Trigger.isInsert || Trigger.isUpdate) GlobalTriggerHandler.updateMap(supplierBuyerMap);
            }
        }
        if (Trigger.isUpdate){
            SalesCommissionService.updateMapCommission(Trigger.New);
        }   
    }
}