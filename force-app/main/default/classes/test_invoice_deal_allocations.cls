@isTest(SeeAllData=true)
private class test_invoice_deal_allocations {
    static testmethod void myTest() {
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
       id invoice = seedIncomlendData.makeInvoice(1);
       
       Invoice_Allocation__c a = new Invoice_Allocation__c();
        a.Invoice__c = invoice;
       
        a.amount__c = 1000 ;
        a.CCY__c = 'XXX';
        a.Status__c = 'Reservation';
        a.Allocation_Reservation_date__c =  date.today();
        
      
         List<Account> accts = [SELECT Id FROM Account where Sub_type__c ='Purchaser' AND USD_Available_eWallet__c > 1000];
         a.Funder__c = accts[0].id;
   
        a.ewallet__c = ewallet.lookup(a.CCY__c, a.Funder__c);
      
        insert a;
       }
}