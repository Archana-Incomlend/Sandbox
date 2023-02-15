//===============================================================================================================
// Part of the Data Extraction process.
// This schedule extracts all data regarding Seabury Data Extraction process.
// 
// Test Class for deployment.
// 
// Author: Pierre PETESCH
//===============================================================================================================
@isTest(SeeAllData = true)
private class Test_SeaburyDataExtraction
{
	public static testMethod void RunTest()
    {
        date dateFrom = date.newInstance(date.today().year(), date.today().month(), date.today().day());
        date dateTo = date.newInstance(date.today().year(), date.today().month(), date.today().day());
        boolean sendFullLogs = false;
        List<string> fullLogsRecipients = new List<string> {'pierre@incomlend.com'};
        List<string> alertLogsRecipients = new List<string> {'pierre@incomlend.com'};

        Schedule_SeaburyDataExtraction dataExtraction = new Schedule_SeaburyDataExtraction(dateFrom, dateTo, sendFullLogs, fullLogsRecipients, alertLogsRecipients);
        dataExtraction.execute();
    }
}