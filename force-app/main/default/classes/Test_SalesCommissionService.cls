@isTest
private class Test_SalesCommissionService {
    private static @testSetup void setup() {
    }

    private static testMethod void salesCommissionTest() {
        Map<String, Object> result = SeedTest.init(null, null, 'funded');
        Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');
        Supplier_Buyer_Map__c supplierBuyerMap = (Supplier_Buyer_Map__c)result.get('map');
        
        List<Sales_Commission__c> listSaleCommissions = [ SELECT Id FROM Sales_Commission__c WHERE Invoice_Finance_Deal__c = :invoice.id];
        delete listSaleCommissions;
        System.debug('total sales commissions deleted ' + listSaleCommissions.size());

        User user = SeedTest.createUser(result, 'Mel');
        insert user;

        Account supplier = (Account)result.get('accountSupplier');
        supplier.Sales_Owner__c = user.Id; 
        update supplier;
        // supplierBuyerMap.Value_of_agent_s_fee__c = 1;
        update supplierBuyerMap;
        
        Account funder = (Account)result.get('accountFunder');
        funder.Sales_Owner__c = user.Id;
        funder.Pay_Commission__c = true;
        update funder; 
        
        Test.startTest();
        
        SalesCommissionService.isNeedRunTrigger = true;
        SalesCommissionService.updateMapCommission(new List<Supplier_Buyer_Map__c> { supplierBuyerMap });

        SalesCommissionService SalesCommissionService = new SalesCommissionService(invoice);
        boolean isCreatedSuccessfully = SalesCommissionService.createSalesCommission();
        System.assertEquals(true, isCreatedSuccessfully);

        SalesCommissionService updateSalesCommissionService = new SalesCommissionService(invoice);
        boolean isUpdatedSuccessfully = updateSalesCommissionService.updateSalesCommission();
        System.assertEquals(true, isUpdatedSuccessfully);

        Test.stopTest();
    
    }

}