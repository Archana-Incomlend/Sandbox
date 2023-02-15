trigger TargetFinanceHandler on Target_financing_month__c (before insert, before update, after insert) {

    if (!CalculateTargetFinanceController.isNeedRunTrigger) return;
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            System.debug('Before Inserting target ' + CalculateTargetFinanceController.toString(Trigger.New));
            for (Target_financing_month__c targetFinance : Trigger.New) {
                List<Invoice_finance_deal__c> invoices = CalculateTargetFinanceController.invoiceToTargetFinance(new List<Target_financing_month__c> {targetFinance});
                String str = CalculateTargetFinanceController.toString(targetFinance);
                targetFinance.New_invoice_Value__c = CalculateTargetFinanceController.mapAmountStr.get(str);
                CalculateTargetFinanceController.mapAmountStr.remove(str);
                // update invoices;
                // done (can only be done) at after inserting
            }
        } else if(Trigger.isUpdate) {
            List<Target_financing_month__c> listTargetFinance = new List<Target_financing_month__c>();
            for (Target_financing_month__c targetFinance : Trigger.new) {
                Target_financing_month__c oldTargetFinance = Trigger.oldMap.get(targetFinance.Id);
                if (targetFinance.Sales__c == oldTargetFinance.Sales__c
                        && targetFinance.Start_Date__c == oldTargetFinance.Start_Date__c
                        && targetFinance.End_Date__c == oldTargetFinance.End_Date__c
                        && targetFinance.New_invoice_Value__c != -1) {
                    continue;
                }
                listTargetFinance.add(targetFinance);
            }
            System.debug('Before Updating target ' + CalculateTargetFinanceController.toString(Trigger.New) + ' ' + CalculateTargetFinanceController.toString(Trigger.Old));
            System.debug('Recalculate ' + listTargetFinance.size() + ' out of ' + Trigger.New.size());
            CalculateTargetFinanceController.invoiceToTargetFinance(listTargetFinance);
            for (Target_financing_month__c targetFinance : listTargetFinance) {
                String str = CalculateTargetFinanceController.toString(targetFinance);
                targetFinance.New_invoice_Value__c = CalculateTargetFinanceController.mapAmountStr.get(str);
                CalculateTargetFinanceController.mapAmountStr.remove(str);
                CalculateTargetFinanceController.resultStr.remove(str); // already "update updateInvoices" in Controller
            }
        } else if(Trigger.isDelete) {
        }
    } else {
        if (Trigger.isInsert) {
            System.debug('After Inserting target ' + CalculateTargetFinanceController.toString(Trigger.New));
            for (Target_financing_month__c targetFinance : Trigger.New)
            {
                String str = CalculateTargetFinanceController.toString(targetFinance);
                if (!CalculateTargetFinanceController.resultStr.containsKey(str)) continue;
                // List<Invoice_finance_deal__c> invoices = CalculateTargetFinanceController.invoiceToTargetFinance(new List<Target_financing_month__c> {targetFinance});
                List<Invoice_finance_deal__c> invoices = CalculateTargetFinanceController.resultStr.get(str);
                if (invoices == null) continue;
                System.debug('target ' + targetFinance.Name + ' total invoices ' + invoices.size());
                for (Invoice_finance_deal__c invoice : invoices) {
                    invoice.Target_financing__c = targetFinance.Id;
                }
                CalculateTargetFinanceController.isNeedRunTrigger = false;
                update invoices;
                CalculateTargetFinanceController.isNeedRunTrigger = true;
                // targetFinance.New_invoice_Value__c = CalculateTargetFinanceController.mapAmount.get(targetFinance);    
                // done (can only be done) at before inserting
            }
        } else if(Trigger.isUpdate) {
        } else if(Trigger.isDelete) {
        } else if(Trigger.isUndelete) {
        }
    }

}