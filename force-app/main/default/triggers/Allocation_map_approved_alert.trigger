trigger Allocation_map_approved_alert on Invoice_Allocation__c (before insert) {

    // List Invoice parent Ids
    List<Id> invoiceIds = new List<Id>();
    for (Invoice_Allocation__c a : Trigger.new) {
        invoiceIds.add(a.Invoice__c);
    }
    // Get the list of Invoices parent
    List<Invoice_Finance_Deal__c> invoices = [
            		SELECT Supplier_Buyer_Map__r.Id
            		FROM Invoice_Finance_Deal__c
            		WHERE Id IN :invoiceIds
  					];

    // List Maps parent of Invoices Ids
    List<Id> mapIds = new List<Id>();
    for (Invoice_Finance_Deal__c i : invoices) {
        mapIds.add(i.Supplier_Buyer_Map__r.Id);
    }
    // Get the list of Maps parent of Invoices
    List<Supplier_Buyer_Map__c> supplierBuyerMaps = [
                    SELECT Id, map_onboarding_stage__c
                    FROM Supplier_Buyer_Map__c 
                    WHERE Id IN :mapIds
                    ];

    // Check the status of the Maps
    Boolean errorFlag = false;
    for (Supplier_Buyer_Map__c currentMap : supplierBuyerMaps) {       
        if ( currentMap.map_onboarding_stage__c != '90.Onboarded') {
            errorFlag = true;
        }
    }
    //Display the error message
    for(Invoice_Allocation__c alloc : Trigger.new) {
        if (errorFlag) {
            alloc.addError('Map Status is not Onboarded');
        }
    }
}