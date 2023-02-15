@isTest
public class Test_PopulateFxRateController {

    static testMethod void Test_Populate() {
        String CCY = 'EUR';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(CCY));

        Map<String, Object> result = SeedTest.init(null, CCY, null); 
        Invoice_Finance_Deal__c invoiceNew = SeedTest.createInvoice(result, 'New', '', CCY, 1000, 'passthrough repaid'); 
        invoiceNew.Actual_Repayment_Received_Date__c = System.today();
        invoiceNew.advance_send_to_supplier_date__c = null;
        insert invoiceNew;
        FX_Rates__c rate = (FX_Rates__c)result.get('rate' + CCY);
        System.debug(rate);
        rate.date__c = System.today();
        update rate;
        

        Test.startTest();
        // for Populate
        RefreshFXRates.isNeedRunTrigger = true;
        PopulateInvoiceFxRateController.fxRateToInvoice(new List<FX_Rates__c>{rate});
        PopulateTransactionFxRateController.fxRateToTransaction(new List<FX_Rates__c>{rate});

        Test.stopTest();
    }


}