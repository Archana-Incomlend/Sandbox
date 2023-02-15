//===============================================================================================================
// Data quality health check.
// This schedule processes a Transactions health check of SalesForce data.
// 
// Test Class for deployment.
// 
// Author: Pierre PETESCH
//===============================================================================================================
@isTest(SeeAllData = true)
private class Test_TransactionsHealthCheck
{
	public static testMethod void RunTest()
    {
        date dateFrom = date.newInstance(date.today().year(), date.today().month(), date.today().day());
        date dateTo = date.newInstance(date.today().year(), date.today().month(), date.today().day());
        boolean sendFullLogs = false;
        List<string> fullLogsRecipients = new List<string> {'pierre@incomlend.com'};
        List<string> alertLogsRecipients = new List<string> {'pierre@incomlend.com'};

        Schedule_TransactionsHealthCheck transactionsHealthCheck = new Schedule_TransactionsHealthCheck(dateFrom, dateTo, sendFullLogs, fullLogsRecipients, alertLogsRecipients);
        transactionsHealthCheck.execute();
    }
}