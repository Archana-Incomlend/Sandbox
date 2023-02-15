@isTest
private class Test_RollupMap {
    

    private static testMethod void RollupMapTest() {
        
        Map<String, Object> result = SeedTest.init(null, null, 'agent-supplier');
        Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');
        Account accountAgent = (Account)result.get('accountAgentSupplier');
        Supplier_Buyer_Map__c supplierBuyerMap = (Supplier_Buyer_Map__c)result.get('map');

        update supplierBuyerMap;
        update invoice;

        Supplier_Buyer_Map__c actual = [SELECT ID, Account_Agent__c FROM Supplier_Buyer_Map__c LIMIT 1];
        System.assertEquals(accountAgent.Id, actual.Account_Agent__c);
    }
}