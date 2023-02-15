@isTest
private class RefreshFXRates_test {
    static testMethod void Test_HKD() 
    {
        String CCY = 'EUR';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(CCY));
        
        Map<String, Object> result = new Map<String,Object>();

        // Market Place
        SeedTest.createMarketPlace(result, 'USD');

        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = SeedTest.getId(result, 'rateUSD');
        marketPlace.latest_to_usd_rate__c = 1;
        marketPlace.currency_symbol__c = '$';
        marketPlace.Currency__c = CCY;
        marketPlace.minimum_purchase_amount__c = 1;
        insert marketPlace;

        Test.startTest();
        RefreshFXRates.isNeedRunTrigger = true;
        RefreshFXRates.InsertNewFxRatesDate(System.today(), false, true);

        FX_Rates__c actual = [SELECT rate__c,to_currency__c,from_currency__c,date__c FROM FX_Rates__c WHERE from_currency__c =:CCY ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
        System.assertEquals(0.1, actual.rate__c); // from MockHttpResponseGenerator
        System.assertEquals('USD', actual.to_currency__c);
        System.assertEquals(CCY, actual.from_currency__c);
        
        RefreshFxRates.OutLog('Error', new List<FX_Rates__c> {actual}, 'errorMessage');
        Test.stopTest();
    }
}