public without sharing class CalculateTargetFinanceController {

    public static boolean IsRunInPricing = false;

    public static boolean needRunTrigger = true;
    public static boolean IsNeedRunTrigger
    {
      public get  // to enable trigger during test set it to null
      {
        return Test.isRunningTest() ? needRunTrigger == null : needRunTrigger == true;
      }
      public set
      {
          if (value) needRunTrigger = Test.isRunningTest() ? null : true;
          else needRunTrigger = false;
      }
    }

    public static boolean firstRun = true;
    public static Map<String, List<Invoice_finance_deal__c>> resultStr = new Map<String, List<Invoice_finance_deal__c>>();
    public static Map<String, Decimal> mapAmountStr = new Map<String, Decimal> ();
    public static Set<Id> setInvoiceId = new Set<Id>();

    public Helper_Log Logs = new Helper_Log();

    @InvocableMethod(label='invoiceToTargetFinance' Description='Method to recalculate Target Finance' Category='Target')
    public static List<Invoice_finance_deal__c> invoiceToTargetFinance(List<Target_financing_month__c> targetFinanceList){
        if (!IsNeedRunTrigger || targetFinanceList == null || targetFinanceList.size() == 0){
            return new List<Invoice_finance_deal__c>();
        }
        return updateNewTargetFinance(targetFinanceList, null);
    }

    public static List<Invoice_finance_deal__c> updateNewTargetFinance(List<Target_financing_month__c> targetFinanceList, String str) {
        if (targetFinanceList == null) {
            String[] strList = new String[] { str };
            if (str.indexOf(';') != -1) strList = str.split(';');
            targetFinanceList = [   SELECT Id, Name, Sales__c, Start_Date__c, End_Date__c
                                    FROM Target_financing_month__c WHERE Id IN :strList ];
        }
        Savepoint sv = Database.setSavepoint();
        try {
            List<Invoice_finance_deal__c> updateInvoices = new List<Invoice_finance_deal__c>();
            CalculateTargetFinanceController handler = new CalculateTargetFinanceController();
            Map<Target_financing_month__c, List<Invoice_finance_deal__c>> result = handler.recalculateAmount(targetFinanceList, updateInvoices, true);
            if (updateInvoices.size() > 0) {
                isNeedRunTrigger = false;
                update updateInvoices;
                isNeedRunTrigger = true;
            }
            return result.get(targetFinanceList[0]); // max support one newly inserted target finance
        } catch (Exception ex) {
            if (Test.isRunningTest()) throw ex;
            System.debug('An error occured'); 
            System.debug(ex);
            Database.rollback(sv);
            return null;
        }
    }

    public static boolean hasNoChange(Invoice_Finance_Deal__c invoice, Invoice_Finance_Deal__c oldInvoice) {
        if (oldInvoice == null) 
            return (invoice.Target_financing__c == null
                    && invoice.Map_Sales_Owner__c == null
                    && invoice.Funded_Date_Auto__c == null
                    && invoice.USD_Daily_FX_Advance_Amount__c == null);
        return (invoice.Target_financing__c == oldInvoice.Target_financing__c
                && invoice.Sales_Owner__c == oldInvoice.Sales_Owner__c // workaround formula field trigger detect
                && invoice.Map_Sales_Owner__c == oldInvoice.Map_Sales_Owner__c
                && invoice.Funded_Date__c == oldInvoice.Funded_Date__c && invoice.advance_send_to_supplier_date__c == oldInvoice.advance_send_to_supplier_date__c // workaround formula field trigger detect
                && invoice.Funded_Date_Auto__c == oldInvoice.Funded_Date_Auto__c
                && invoice.funded_amount__c == oldInvoice.funded_amount__c // workaround formula field trigger detect
                && invoice.USD_Daily_FX_Advance_Amount__c == oldInvoice.USD_Daily_FX_Advance_Amount__c
                && invoice.first_deal_for_map__c == oldInvoice.first_deal_for_map__c);
    }

    public static void beforeInsert(List<Invoice_finance_deal__c> newRecords) { 
        CalculateTargetFinanceController handler = new CalculateTargetFinanceController();
        handler.updateTargetFinance(null, newRecords);
    }
    
    public static void beforeUpdate(Map<Id, Invoice_finance_deal__c> oldRecordsMap, Map<Id, Invoice_finance_deal__c> newRecordsMap){ 
        CalculateTargetFinanceController handler = new CalculateTargetFinanceController();
        handler.updateTargetFinance(oldRecordsMap, newRecordsMap.values());
    }
    
    public static void beforeDelete(Map<Id, Invoice_finance_deal__c> deletedRecordsMap) { 
        CalculateTargetFinanceController handler = new CalculateTargetFinanceController();
        handler.updateTargetFinance(deletedRecordsMap, new List<Invoice_finance_deal__c>());
    }

    // public static void afterInsert(List<Invoice_finance_deal__c> newRecords) {
    // }
    
    public static void afterUpdate(Map<Id, Invoice_finance_deal__c> oldRecordsMap, Map<Id, Invoice_finance_deal__c> newRecordsMap){
        if (!isNeedRunTrigger) return;
        setInvoiceId.clear();
        for (Invoice_finance_deal__c invoice : newRecordsMap.values()) 
        {
            Invoice_finance_deal__c oldInvoice = oldRecordsMap.get(invoice.id);
            if (!hasNoChange(invoice, oldInvoice)) setInvoiceId.add(invoice.Id);
        }
        if (setInvoiceId.size() > 0) {
            CalculateTargetFinanceController handler = new CalculateTargetFinanceController();
            handler.updateTargetFinance(null, null);
        }
    }
    
    // public static void afterDelete(Map<Id, Invoice_finance_deal__c> deletedRecordsMap) {
    // }

    public static void afterTriggerAllocation() {
        CalculateTargetFinanceController handler = new CalculateTargetFinanceController();
        handler.updateTargetFinance(null, null);
    }
    
    public void updateTargetFinance(List<Invoice_finance_deal__c> listInvoice) {
        if (!IsRunInPricing) {
            log('Target finance has been called by invoice trigger');
            return;
        }
        updateTargetFinancing(new Map<Id, Invoice_finance_deal__c>(), listInvoice);
        boolean temp = needRunTrigger;
        needRunTrigger = false;
        update listInvoice;
        needRunTrigger = temp;
    }

    private void log(String str) {
        System.debug(str);
        this.Logs.Log(str, 2, Helper_Log.Color.Grey);
    }

    private void updateTargetFinance(Map<Id, Invoice_finance_deal__c> oldRecordsMap, List<Invoice_finance_deal__c> newRecords){
        if (!isNeedRunTrigger) return;
        try {
            List<Target_financing_month__c> targetFinanceList = null;
            targetFinanceList = updateTargetFinancing(oldRecordsMap, newRecords);
            if (targetFinanceList != null && targetFinanceList.size() > 0) {
                isNeedRunTrigger = false;
                update targetFinanceList;
                isNeedRunTrigger = true;    
            }
        } catch (Exception ex) {
            if (Test.isRunningTest()) { 
                throw ex; // exit
            }
            log('An error occured ' + ex.getMessage()); 
            System.debug(ex);
        }
    }

    private List<Target_financing_month__c> updateTargetFinancing(Map<Id, Invoice_finance_deal__c> oldRecordsMap, List<Invoice_finance_deal__c> newRecords){
        boolean isTriggerAfter = false;
        if (newRecords == null) {
            if (setInvoiceId.size() == 0) return null;
            isTriggerAfter = true;
            
            newRecords = [  SELECT Id, Name, Map_Sales_Owner__c, Sales_Owner__c, advance_send_to_supplier_date__c, Funded_Date__c, Funded_Date_Auto__c, USD_Daily_FX_Advance_Amount__c, Target_financing__c, first_deal_for_map__c
                            FROM Invoice_finance_deal__c WHERE Id IN :setInvoiceId ];
            oldRecordsMap = new Map<Id, Invoice_finance_deal__c>(newRecords);
            System.debug('invoices with allocation to be updated ' + newRecords.size());
        } 
        if (oldRecordsMap == null){
            oldRecordsMap = new Map<Id, Invoice_finance_deal__c>();
        }

        // Map<Id, Date> mapSalesMinDate= new Map<Id, Date>();
        // Map<Id, Date> mapSalesMaxDate= new Map<Id, Date>();
        Map<String, Date> mapSalesMinDate= new Map<String, Date>();
        Map<String, Date> mapSalesMaxDate= new Map<String, Date>();
        Set<Id> setTargetFinance = new Set<Id>();
        List<Invoice_finance_deal__c> updateInvoices = new List<Invoice_finance_deal__c>();

        // Find range of target finance list
        for (Invoice_finance_deal__c invoice : newRecords) 
        {
            if (isTriggerAfter) {
                setTargetFinance.add(invoice.Target_financing__c);
                continue;
            }
            Invoice_finance_deal__c oldInvoice = oldRecordsMap.get(invoice.id);
            if (invoice.advance_send_to_supplier_date__c != null) {
                if ( oldInvoice == null 
                   ? invoice.first_deal_for_map__c && invoice.USD_Daily_FX_Advance_Amount__c > 0 && invoice.Map_Sales_Owner__c != null
                   : !hasNoChange(invoice, oldInvoice))
                {
                    updateInvoices.add(invoice);
                    if (invoice.Target_financing__c == null) {
                        if (mapSalesMinDate.containsKey(invoice.Map_Sales_Owner__c)) {
                            if (invoice.Funded_Date_Auto__c < mapSalesMinDate.get(invoice.Map_Sales_Owner__c)) {
                                mapSalesMinDate.put(invoice.Map_Sales_Owner__c, invoice.Funded_Date_Auto__c);
                            }
                            if (invoice.Funded_Date_Auto__c > mapSalesMaxDate.get(invoice.Map_Sales_Owner__c)) {
                                mapSalesMaxDate.put(invoice.Map_Sales_Owner__c, invoice.Funded_Date_Auto__c);                                
                            }
                        } else {
                            mapSalesMinDate.put(invoice.Map_Sales_Owner__c, invoice.Funded_Date_Auto__c);
                            mapSalesMaxDate.put(invoice.Map_Sales_Owner__c, invoice.Funded_Date_Auto__c);
                        }

                    } else {
                        setTargetFinance.add(invoice.Target_financing__c);
                    }
                    if (oldInvoice != null) {
                        setTargetFinance.add(oldInvoice.Target_financing__c);
                    }
                }
            }
            System.debug('invoice to update ' + (updateInvoices.indexOf(invoice) != -1) + ' ' + toString(invoice) + ' ' + toString(oldInvoice));
        }
        if (updateInvoices.size() > 0) {
            log('total invoices to update ' + toString(updateInvoices));
        }
        if (mapSalesMinDate.size() > 0) {
            // for (Id fullname : mapSalesMinDate.keySet()) 
            for (String fullname : mapSalesMinDate.keySet()) 
            {
                System.debug('Looking for target finance for sales ' + fullname + ' between ' + mapSalesMinDate.get(fullname) + ' and ' + mapSalesMaxDate.get(fullname));
                for (Target_financing_month__c targetFinance :
                        [SELECT Id
                         FROM Target_financing_month__c 
                         WHERE Sales__c = :fullname 
                         AND Start_Date__c >= :mapSalesMinDate.get(fullname) 
                         AND End_Date__c <= :mapSalesMaxDate.get(fullname)]) 
                {
                    setTargetFinance.add(targetFinance.Id);
                } 
            }
        }

        if (newRecords.isEmpty()){
            for (Invoice_finance_deal__c oldInvoice : oldRecordsMap.values()) 
            {
                setTargetFinance.add(oldInvoice.Target_financing__c);
            }
        }
        setTargetFinance.remove(null);
        log('Total target finance to be updated ' + setTargetFinance.size());
        if (setTargetFinance.isEmpty()) return new List<Target_financing_month__c>();

        List<Target_financing_month__c> targetFinanceList = [SELECT Id, Name, Sales__c, Start_Date__c, End_Date__c
                                                             FROM Target_financing_month__c
                                                             WHERE Id IN :setTargetFinance ];
        Map<Id, Target_financing_month__c> targetFinanceMap = new Map<Id, Target_financing_month__c>(targetFinanceList);
        Map<Target_financing_month__c, Decimal> mapAmount = new Map<Target_financing_month__c, Decimal> ();
        for (Target_financing_month__c targetFinance : targetFinanceList) 
        {
            mapAmount.put(targetFinance, 0);
        }

        if (isTriggerAfter) {
            recalculateAmount(targetFinanceList, null, false, null);
            return targetFinanceList;
        }

        // Update new amount
        for (Invoice_finance_deal__c invoice : updateInvoices) 
        {
            Invoice_finance_deal__c oldInvoice = oldRecordsMap.get(invoice.id);
            Id temp = invoice.Target_financing__c;
            if (invoice.Target_financing__c == null || (oldInvoice != null && oldInvoice.Target_financing__c != null)) {
                invoice.Target_financing__c = null;
                for (Target_financing_month__c targetFinance : targetFinanceList) {
                    boolean isCorrect = invoice.Map_Sales_Owner__c == targetFinance.Sales__c
                            && invoice.Funded_Date_Auto__c >= targetFinance.Start_Date__c
                            && invoice.Funded_Date_Auto__c <= targetFinance.End_Date__c;
                    if (isCorrect) {
                        invoice.Target_financing__c = targetFinance.Id;
                        break;
                    }
                }
            }
            if (oldInvoice != null && oldInvoice.Target_financing__c != invoice.Target_financing__c) {
                System.debug('invoice ' + invoice.Name + ' target finance' + (temp == invoice.Target_financing__c?' force':'') 
                        + ' changed from ' + oldInvoice.Target_financing__c + ' to ' + invoice.Target_financing__c);
            } else if (oldInvoice != null && invoice.USD_Daily_FX_Advance_Amount__c == oldInvoice.USD_Daily_FX_Advance_Amount__c) {
                continue;
            }
            if (invoice.Target_financing__c != null) {
                Target_financing_month__c targetFinance = targetFinanceMap.get(invoice.Target_financing__c);
                mapAmount.put(targetFinance, mapAmount.get(targetFinance) + invoice.USD_Daily_FX_Advance_Amount__c);
            }
            if (oldInvoice != null && oldInvoice.Target_financing__c != null) {
                Target_financing_month__c targetFinance = targetFinanceMap.get(oldInvoice.Target_financing__c);
                mapAmount.put(targetFinance, mapAmount.get(targetFinance) - oldInvoice.USD_Daily_FX_Advance_Amount__c);
            }
        }
        if (newRecords.isEmpty()){
            for (Invoice_finance_deal__c oldInvoice : oldRecordsMap.values()) 
            {
                Target_financing_month__c targetFinance = targetFinanceMap.get(oldInvoice.Target_financing__c);
                mapAmount.put(targetFinance, mapAmount.get(targetFinance) - oldInvoice.USD_Daily_FX_Advance_Amount__c);
                // oldInvoice.Target_financing__c = null;
            }
        }

        for (Target_financing_month__c targetFinance : targetFinanceList) 
        {
            if (mapAmount.get(targetFinance) != 0) {
                log('target amount ' + targetFinance.Name + ' ' + mapAmount.get(targetFinance));
            }
        }
        recalculateAmount(targetFinanceList, null, false, mapAmount);

        return targetFinanceList;
    }

    private Map<Target_financing_month__c, List<Invoice_finance_deal__c>> recalculateAmount(List<Target_financing_month__c> targetFinanceList, List<Invoice_finance_deal__c> updateInvoices, boolean fromInvocable) {
        return recalculateAmount(targetFinanceList, updateInvoices, fromInvocable, null);
    }

    private Map<Target_financing_month__c, List<Invoice_finance_deal__c>> recalculateAmount(List<Target_financing_month__c> targetFinanceList, List<Invoice_finance_deal__c> updateInvoices, boolean fromInvocable, Map<Target_financing_month__c, Decimal> mapAmount) {
		
        Map<Id, Target_financing_month__c> targetFinanceMap = new Map<Id, Target_financing_month__c>();
        Map<Target_financing_month__c, List<Invoice_finance_deal__c>> result = new Map<Target_financing_month__c, List<Invoice_finance_deal__c>>();
        if (mapAmount == null) {
            mapAmount = new Map<Target_financing_month__c, Decimal> ();
        }

        for (Target_financing_month__c targetFinance : targetFinanceList) 
        {
            System.debug('target financing ' + targetFinance.Name + ' ' + toString(targetFinance) + ' ' + fromInvocable);
            result.put(targetFinance, new List<Invoice_finance_deal__c>());
            if (mapAmount.get(targetFinance) == null) {
                mapAmount.put(targetFinance, 0);
            }
            if (targetFinance.Id != null) {
                targetFinanceMap.put(targetFinance.Id, targetFinance);
            }
        }
        
        List<Invoice_finance_deal__c> currentInvoices = [   SELECT Id, Name, Map_Sales_Owner__c, Sales_Owner__c, advance_send_to_supplier_date__c, Funded_Date__c, Funded_Date_Auto__c, USD_Daily_FX_Advance_Amount__c, Target_financing__c, first_deal_for_map__c
                                                            FROM Invoice_finance_deal__c
                                                            WHERE Target_financing__c IN :targetFinanceMap.keySet()];
        for (Invoice_finance_deal__c invoice : currentInvoices) {
            Target_financing_month__c targetFinance = targetFinanceMap.get(invoice.Target_financing__c);
            boolean stayCorrect = invoice.first_deal_for_map__c
                    && invoice.Map_Sales_Owner__c == targetFinance.Sales__c
                    && invoice.Funded_Date_Auto__c >= targetFinance.Start_Date__c
                    && invoice.Funded_Date_Auto__c <= targetFinance.End_Date__c;
            if (stayCorrect || updateInvoices == null) {
                if (!stayCorrect) log('invoice ' + invoice.Name + ' discrepancy target ' + targetFinanceMap.get(invoice.Target_financing__c).Name);
                addInvoice(targetFinanceMap.get(invoice.Target_financing__c), invoice, mapAmount, result);
            } else {
                System.debug('pull invoice ' + targetFinance.Name + ' ' + toString(invoice));
                invoice.Target_financing__c = null;
                updateInvoices.add(invoice);
            }
        }

        if (updateInvoices != null) {
            for (Target_financing_month__c targetFinance : targetFinanceList) 
            {
                List<Invoice_finance_deal__c> invoiceList = [ SELECT Id, Name, Map_Sales_Owner__c, Sales_Owner__c, advance_send_to_supplier_date__c, Funded_Date__c, Funded_Date_Auto__c, USD_Daily_FX_Advance_Amount__c, Target_financing__c, first_deal_for_map__c
                                                              FROM Invoice_finance_deal__c
                                                              WHERE Target_financing__c = null
                                                              AND Map_Sales_Owner__c = :targetFinance.Sales__c
                                                              AND Funded_Date_Auto__c >= :targetFinance.Start_Date__c
                                                              AND Funded_Date_Auto__c <= :targetFinance.End_Date__c];

                for (Invoice_finance_deal__c invoice : invoiceList) 
                {
                    System.debug('push invoice ' + targetFinance.Name + ' ' + toString(invoice));
                    addInvoice(targetFinance, invoice, mapAmount, result);
                    if (targetFinance.Id != null) {
                        invoice.Target_financing__c = targetFinance.Id;
                        updateInvoices.add(invoice);
                    }
                }
            }
        }
        
        if (updateInvoices != null && updateInvoices.size() > 0) {
            log('Total invoices to be updated ' + updateInvoices.size());
        } 
        for (Target_financing_month__c targetFinance : targetFinanceList) 
        {
            targetFinance.New_invoice_Value__c = mapAmount.get(targetFinance);
            if (fromInvocable) {
                mapAmountStr.put(toString(targetFinance), mapAmount.get(targetFinance));
                if (result.get(targetFinance) != null && result.get(targetFinance).size() != 0)
                    resultStr.put(toString(targetFinance), result.get(targetFinance));
            }
            log('target ' + targetFinance.Name + ' amount ' + mapAmount.get(targetFinance) + (fromInvocable ? ' total' : ' other ') + ' invoices ' + (result.get(targetFinance) == null ? 0 : result.get(targetFinance).size()));
        }
        return result;
    }

    private void addInvoice(Target_financing_month__c targetFinance, Invoice_finance_deal__c invoice, Map<Target_financing_month__c, Decimal> mapAmount, Map<Target_financing_month__c, List<Invoice_finance_deal__c>> result) {
        if (invoice.USD_Daily_FX_Advance_Amount__c == null || invoice.USD_Daily_FX_Advance_Amount__c == 0) {
            log('invoice ' + invoice.Name + ' target ' + targetFinance.Name + ' USD Daily FX Advance Amount empty');
            return;
        }
        if (mapAmount.get(targetFinance) == null) {
            mapAmount.put(targetFinance, 0);
        }

        mapAmount.put(targetFinance, mapAmount.get(targetFinance) + invoice.USD_Daily_FX_Advance_Amount__c);
        
        result.get(targetFinance).add(invoice);
    }

    public static String toString(Object obj) {
        if (obj instanceof List<Object>) {
            String str = '';
            List<Object> listObj = (List<Object>)obj;
            if (listObj.size() > 3) return 'total ' + listObj.size(); 
            for (Object item : listObj) 
            {
                str += ', ' + toString(item);
            } 
            str = '{' + str.substring(str.indexOf(', ') + 1) + ' }';
            return str;
        } else if (obj instanceof Target_financing_month__c) {
            Target_financing_month__c targetFinance = (Target_financing_month__c)obj;
            return targetFinance.Sales__c + ' ' + targetFinance.Sales__c + ' ' + targetFinance.Start_Date__c + ' ' + targetFinance.End_Date__c;
        } else if (obj instanceof Invoice_finance_deal__c) {
            Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)obj;
            return invoice.Id + ' ' + invoice.Name + ' ' + invoice.Map_Sales_Owner__c + ' ' + invoice.Sales_Owner__c+ ' ' + invoice.Funded_Date_Auto__c + ' ' + invoice.advance_send_to_supplier_date__c + ' ' + invoice.USD_Daily_FX_Advance_Amount__c;
        } else if (obj instanceof Invoice_Allocation__c) {
            Invoice_Allocation__c a = (Invoice_Allocation__c)obj;
            return a.Name + ' ' + a.FunderInvoiceUniqueID__c + ' ' + a.amount__c;
        }
        return String.valueOf(obj);
    }

}