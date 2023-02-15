//===============================================================================================================
// This class contains testing use cases for DebugHelper class
// Author: Pierre PETESCH
//===============================================================================================================
@isTest(SeeAllData = true)
private class Test_RefreshAmountUSDEquivDailyFX
{
	public static testMethod void RefreshAccountingPeriod_Test()
    {
        string accountingPeriodName;
        List<string> currencies;
        boolean sendEmailLogs;
        List<string> recipients;
        
        // Test 1
        
        accountingPeriodName = '2018-02';
        currencies = new List<string> {'USD', 'SGD', 'HKD', 'EUR', 'GBP'};
        sendEmailLogs = true;
        //recipients = new List<string> {'michel@incomlend.com', 'pierre@incomlend.com'};
        recipients = new List<string> {'pierre@incomlend.com'};
        
        integer result = RefreshAmountUSDEquivDailyFX.RefreshAccountingPeriod(accountingPeriodName, currencies, sendEmailLogs, recipients);
        //system.assertEquals(true, (result > 0));
    }
}