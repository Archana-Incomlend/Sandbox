trigger InvoiceFinanceDealHandler on invoice_finance_deal__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger.isBefore) {
        Map<Id, Supplier_Buyer_Map__c> mapMap = new Map<Id, Supplier_Buyer_Map__c>();
        if (Trigger.isInsert || Trigger.isUpdate) {
            mapMap = GlobalTriggerHandler.getMapUpdateInvoice(Trigger.New);

            for (Invoice_finance_deal__c invoice : Trigger.New) 
            {
                Supplier_Buyer_Map__c supplierBuyerMap = mapMap.get(invoice.Supplier_Buyer_Map__c);
                Invoice_finance_deal__c oldInvoice = Trigger.oldMap == null ? null : Trigger.oldMap.get(invoice.Id);
                GlobalTriggerHandler.updateInvoice(invoice, oldInvoice, supplierBuyerMap);
                if (Trigger.isInsert)
                    GlobalTriggerHandler.insertInvoice(invoice, supplierBuyerMap);
            }    
        }
        if (CalculateTargetFinanceController.isNeedRunTrigger) {
            
            if(Trigger.isInsert) {
                Map<Id, Invoice_finance_deal__c> mapNew = new Map<Id, Invoice_finance_deal__c>();
                for (Invoice_finance_deal__c invoice : Trigger.New) 
                {
                    if (invoice.first_deal_for_map__c && 
                            invoice.Funded_Date_Auto__c != null &&
                            invoice.Map_Sales_Owner__c != null)
                        mapNew.put(invoice.Id, invoice);
                }

                System.debug('Before Inserting invoice ' + CalculateTargetFinanceController.toString(mapNew.values()));
                CalculateTargetFinanceController.beforeInsert(mapNew.values());
            } else if(Trigger.isUpdate) {
                Map<Id, Invoice_finance_deal__c> mapNew = new Map<Id, Invoice_finance_deal__c>();
                Map<Id, Invoice_finance_deal__c> mapOld = new Map<Id, Invoice_finance_deal__c>();
                for (Invoice_finance_deal__c invoice : Trigger.New) 
                {

                    invoice_finance_deal__c oldInvoice = Trigger.oldMap.get(invoice.Id);
                    if (invoice.Target_financing__c == oldInvoice.Target_financing__c
                            && invoice.Sales_Owner__c == oldInvoice.Sales_Owner__c // workaround formula field trigger detect
                            && invoice.Map_Sales_Owner__c == oldInvoice.Map_Sales_Owner__c
                            && invoice.Funded_Date__c == oldInvoice.Funded_Date__c && invoice.advance_send_to_supplier_date__c == oldInvoice.advance_send_to_supplier_date__c // workaround formula field trigger detect
                            && invoice.Funded_Date_Auto__c == oldInvoice.Funded_Date_Auto__c
                            && invoice.first_deal_for_map__c == oldInvoice.first_deal_for_map__c 
                            )
                        continue;
                    mapNew.put(invoice.Id, invoice);
                    mapOld.put(invoice.Id, oldInvoice);
                }

                if (mapNew.size() > 0) {
                    System.debug('Before Updating invoice ' + CalculateTargetFinanceController.toString(mapNew.values()) + ' ' + CalculateTargetFinanceController.toString(mapOld.values()));
                    CalculateTargetFinanceController.beforeUpdate(mapOld, mapNew);    
                } 
            } else if(Trigger.isDelete) {

                Map<Id, Invoice_finance_deal__c> mapOld = new Map<Id, Invoice_finance_deal__c>();
                for (Invoice_finance_deal__c oldInvoice : Trigger.Old) 
                {
                    if (oldInvoice.Target_financing__c == null) continue;
                    mapOld.put(oldInvoice.Id, oldInvoice);
                }

                if (mapOld.size() > 0) {
                    System.debug('Before Deleting invoice ' + CalculateTargetFinanceController.toString(mapOld));
                    CalculateTargetFinanceController.beforeDelete(mapOld);
                } 
            }    
            
        }
    } else if (Trigger.isAfter) {
        Set<Id> mapIds = new Set<Id>();
        Set<Id> marketplaceIds = new Set<Id>();
        if (Trigger.isInsert) {
            RollupUtility.afterInsert(mapIds, marketplaceIds, Trigger.New);
        } else if (Trigger.isUpdate) {
            RollupUtility.afterUpdate(mapIds, marketplaceIds, Trigger.OldMap, Trigger.New);
            if (WebServiceCallout.isNeedRunTrigger && WebServiceCallout.FirstrunAfterInvoice) {
                for (invoice_finance_deal__c deal : Trigger.new) {

                    System.debug('Processing invoice_finance_deal__c with Id ' + deal.Id);
                    invoice_finance_deal__c oldDeal = Trigger.oldMap.get(deal.Id);
                    Boolean oldReady = oldDeal.Invoice_ready_for_Posting__c;
                    Datetime oldListingStart = oldDeal.Listing_Start__c;
                    Datetime oldListingEnd = oldDeal.Listing_End__c;
                    String oldPhase = oldDeal.Phase__c;
                    Datetime oldBuyerAcknowledgmentDate = oldDeal.Buyer_acknowledgment_date__c;
        
                    Boolean currentReady = deal.Invoice_ready_for_Posting__c;
                    Datetime currentListingStart = deal.Listing_Start__c;
                    Datetime currentListingEnd = deal.Listing_End__c;
                    String currentPhase = deal.Phase__c;
                    Datetime currentBuyerAcknowledgmentDate = deal.Buyer_acknowledgment_date__c;
        
                    if (oldPhase != '9:CANCELLED' && currentPhase == '9:CANCELLED') {
                        System.debug('The invoice was cancelled with Id ' + deal.Id);
                        WebServiceCallout.notifyInvoiceAllocationRequest('INVOICE_CANCEL', deal.Name);
                    } else if (oldPhase == '1:PRE LISTING' && currentPhase == '2:ON MARKETPLACE') {
                        if (currentListingStart != null) {
                            System.debug('The phase was updated from 1:PRE LISTING to 2:ON MARKETPLACE: ' + deal.Id);
                            WebServiceCallout.notifyInvoiceAllocationRequest('INVOICE', 'UPDATE_PHASE_ON_MARKETPLACE_' + deal.Name);
                        }
                    }
        
                    if (oldBuyerAcknowledgmentDate == null && currentBuyerAcknowledgmentDate != null) {
                        System.debug('Buyer acknowledgment asked date is updated: ' + deal.Id);
                        WebServiceCallout.notifyInvoiceAllocationRequest('INVOICE', 'UPDATE_BUYER_ACKNOWLEDGMENT_ASKED_DATE_' + deal.Name);
                    }
        
                    if ((!oldReady && currentReady)
                        || (currentListingStart != null && currentListingEnd != null && (oldListingStart == null || oldListingEnd == null))) {
                        System.debug('Pending condition was updated');
                        WebServiceCallout.notifyInvoiceAllocationRequest('INVOICE', deal.Name);
                    }
                }    
            }
            if (CalculateTargetFinanceController.isNeedRunTrigger) {
                
                System.debug('After Updating invoice');
                CalculateTargetFinanceController.afterUpdate(Trigger.oldMap, Trigger.newMap);    
                
            }
        } else if (Trigger.isDelete) {
            RollupUtility.afterDelete(mapIds, marketplaceIds, Trigger.Old);
        }
        if (mapIds.size() > 0) {
            RollupUtility.rollupInvoiceToMap(mapIds);
        }
        if (marketplaceIds.size() > 0) {
            RollupUtility.rollupInvoiceToMarketplace(marketplaceIds);
        }
    }  
}