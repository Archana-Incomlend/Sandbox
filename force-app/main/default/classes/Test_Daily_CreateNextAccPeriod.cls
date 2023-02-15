//===============================================================================================================
// Data quality - Create next Accounting Period.
// This schedule processes a creation of the next Accounting Period Salesforce object.
// 
// Test Class for deployment.
// 
// Author: Pierre PETESCH
//===============================================================================================================
@isTest(SeeAllData = true)
private class Test_Daily_CreateNextAccPeriod
{
	public static testMethod void RunTest()
    {
        date dateFrom = date.newInstance(date.today().year(), date.today().month(), date.today().day());
        date dateTo = date.newInstance(date.today().year(), date.today().month(), date.today().day());
        boolean sendFullLogs = false;
        List<string> fullLogsRecipients = new List<string> {'pierre@incomlend.com'};
        List<string> alertLogsRecipients = new List<string> {'pierre@incomlend.com'};

        Schedule_Daily_CreateNextAccPeriod createNextAccPeriod = new Schedule_Daily_CreateNextAccPeriod(dateFrom, dateTo, sendFullLogs, fullLogsRecipients, alertLogsRecipients);
        createNextAccPeriod.execute();
    }
}