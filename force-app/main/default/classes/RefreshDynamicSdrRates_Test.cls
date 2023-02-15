@isTest
private class RefreshDynamicSdrRates_Test {

    private class RestMock implements HttpCalloutMock {
        integer status {get; set;}
        String response {get; set;}
        
        RestMock(integer status, String response) {
            this.status = status;
            this.response = response;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(response);
            res.setStatusCode(status);
            return res;
        }
    }

    static testMethod void TestSOFR() 
    {
        Date p_Date = System.today().addDays(-1);
        String l_date = String.valueOf(p_Date);
        String jsonBody = '{"data":[{"eventCode":520,"eventDescription":"SOFR","productCode":50,"productDescription":"Reference Rates","businessId":"SOFR-' + l_date + '","postId":"084810bb-0aab-4c11-a66f-706313ceaa1c","postDt":"' + l_date + '","insertTs":"2022-06-09T07:59:14.079","origInsertTs":"2022-06-09T07:59:14.079","data":"{\"refRateType\": \"SOFR\", \"refRateDt\": \"' + l_date + '\", \"revisionIndicator\": false, \"dailyRate\": 0.76, \"ratePercentile1st\": 0.7, \"ratePercentile25th\": 0.74, \"ratePercentile75th\": 0.8, \"ratePercentile99th\": 0.95, \"tradingVolume\": 959, \"footnoteId\": 0}"}]}';
        Test.setMock(HttpCalloutMock.class, new RestMock(200, jsonBody));

        Test.startTest();
        RefreshDynamicSdrRates.isNeedRunTrigger = true;
        RefreshDynamicSdrRates.InsertNewRatesDate(p_Date, false, true, 'SOFR');

        List<Dynamic_SDR__c> actual = [SELECT Id, Type__c, Date__c FROM Dynamic_SDR__c];
        System.assertEquals(1, actual.size()); 
        Test.stopTest();
    }

    static testMethod void TestSOFRfixed() 
    {
        Date p_Date = System.today().addDays(-1);
        String l_date = String.valueOf(p_Date);
        String jsonBody = '{"resultsStrip":[{"date":"'+l_date+'","rates":{"sofrRatesFixing":[{"price":"1.73014","term":"1M"},{"price":"2.10667","term":"3M"},{"price":"2.56338","term":"6M"},{"price":"2.91374","term":"1Y"}]}}]}';
        Test.setMock(HttpCalloutMock.class, new RestMock(200, jsonBody));

        Test.startTest();
        RefreshDynamicSdrRates.isNeedRunTrigger = true;
        RefreshDynamicSdrRates.InsertNewRatesDate(p_Date, false, true, 'SOFR-F');

        List<Dynamic_SDR__c> actual = [SELECT Id, Type__c, Date__c FROM Dynamic_SDR__c];
        System.assertEquals(1, actual.size()); 
        Test.stopTest();
    }

    static testMethod void TestEuribor() 
    {
        Date p_Date = System.today().addDays(-1);
        String jsonBody = '[{"Id":2,"Data":[[' + ((DateTime)p_Date).getTime() +',0.072]]}]';
        Test.setMock(HttpCalloutMock.class, new RestMock(200, jsonBody));

        Test.startTest();
        RefreshDynamicSdrRates.isNeedRunTrigger = true;
        RefreshDynamicSdrRates.InsertNewRatesDate(p_Date, false, true, 'Euribor');

        List<Dynamic_SDR__c> actual = [SELECT Id, Type__c, Date__c FROM Dynamic_SDR__c];
        System.assertEquals(1, actual.size()); 
        Test.stopTest();
    }

    static testMethod void TestNonJson() 
    {
        Date p_Date = System.today();
        Test.setMock(HttpCalloutMock.class, new RestMock(200, '{"data":[non json]}')); // wrong format

        Test.startTest();
        RefreshDynamicSdrRates.isNeedRunTrigger = true;
        try {
            RefreshDynamicSdrRates.main();
        } catch (Exception ex) {
        }
        Test.stopTest();
    }

    static testMethod void TestDoPostAndSendToProd() 
    {
        Test.startTest();
        RefreshDynamicSdrRates.isNeedRunTrigger = true;
        try {
            Test.setMock(HttpCalloutMock.class, new RestMock(200, ''));
            insert new configuration__c[] { 
                SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_WebServiceCallout_Endpoint','http://a.nu'),
                SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_WebServiceCallout_ApiKey','a') };
            RefreshDynamicSdrRates.sendToProd(new List<Dynamic_SDR__c>());
        } catch (Exception ex) {
            System.debug(ex);
        }
        try {
            RestRequest req = new RestRequest();
            RestContext.request = req;
            RestContext.response = new RestResponse();
            req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm() + '/DynamicSdr';
            req.addParameter('str', '[]');
            RefreshDynamicSdrRates.doPost();
        } catch (Exception ex) {
            System.debug(ex);
        }
        Test.stopTest();
    }
}