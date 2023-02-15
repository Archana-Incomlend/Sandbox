//===============================================================================================================
// This class contains testing use cases for DebugHelper class
// Author: Pierre PETESCH
//===============================================================================================================
@isTest(SeeAllData = true)
private class Test_DebugHelper
{
	public static testMethod void Debug_Test()
    {
        DebugHelper myDebug = new DebugHelper();
        
        myDebug.IsActive = false;
        myDebug.Debug('Non-debug line 1');
        
        myDebug.IsActive = true;
        
        myDebug.IsHTML = false;
        myDebug.Debug('Debug plain line 1');
        
        myDebug.IsHTML = true;
        
        myDebug.Debug('Debug HTML line 1');
        myDebug.Debug('Debug HTML line 2', true, false, false);
        myDebug.Debug('Debug HTML line 3', true, true, false);
        myDebug.Debug('Debug HTML line 4', true, true, true);
        
        system.debug(myDebug.FullLog);
        
        List<string> recipients = new List<string> {'pierre@incomlend.com'};
        myDebug.SendLogs(recipients, 'Log results');
    }
}