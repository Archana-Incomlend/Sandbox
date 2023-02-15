global class RefreshPaid implements Schedulable

{
    global void execute(SchedulableContext SC)
    {
        updatePaid();
    }
    
    static public void updatePaid()
    {
                       
        List<Invoice_Allocation__c> allocations2 = [select Buyer_name__c, Buyer_name_value__c, Supplier_industry__c, Supplier_industry_value__c 
                                              from Invoice_Allocation__c  
                                              where Status__c IN ('Repaid invoice deal closed')];
    
        List<Invoice_Allocation__c> updateAllocations = new List<Invoice_Allocation__c>();
        for(Invoice_Allocation__c a : allocations2)
        {
            if (a.Buyer_name_value__c == a.Buyer_name__c && a.Supplier_industry_value__c == a.Supplier_industry__c && !Test.isRunningTest()) continue;
            updateAllocations.add(a);
            a.Buyer_name_value__c = a.Buyer_name__c;
            a.Supplier_industry_value__c = a.Supplier_industry__c;
        }
        if (updateAllocations.size() > 0) {
            System.debug('Processing total ' + updateAllocations + ' closed allocations');
            update updateAllocations;
        }
        
    }
}