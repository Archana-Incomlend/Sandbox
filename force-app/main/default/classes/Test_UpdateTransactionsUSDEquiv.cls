//===============================================================================================================
// Data quality - Update of Transactions 'Amount USD Equiv Daily FX' field.
// This schedule processes an update of Transactions of SalesForce data 'Amount USD Equiv Daily FX' field.
// 
// Test Class for deployment.
// 
// Author: Pierre PETESCH
//===============================================================================================================
@isTest(SeeAllData = true)
private class Test_UpdateTransactionsUSDEquiv
{
	public static testMethod void RunTest()
    {
        date dateFrom = date.newInstance(date.today().year(), date.today().month(), date.today().day());
        date dateTo = date.newInstance(date.today().year(), date.today().month(), date.today().day());
        boolean sendFullLogs = false;
        List<string> fullLogsRecipients = new List<string> {'pierre@incomlend.com'};
        List<string> alertLogsRecipients = new List<string> {'pierre@incomlend.com'};
        List<string> currencies = new List<string> {'USD'};

        Schedule_UpdateTransactionsUSDEquiv updateTransactionsUSDEquiv = new Schedule_UpdateTransactionsUSDEquiv(dateFrom, dateTo, sendFullLogs, fullLogsRecipients, alertLogsRecipients);
        updateTransactionsUSDEquiv.execute();
    }
}