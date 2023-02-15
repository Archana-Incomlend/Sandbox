//===============================================================================================================
// This class contains testing use cases for EmailHelper class
// Author: Pierre PETESCH
//===============================================================================================================
@isTest(SeeAllData = true)
private class Test_EmailHelper
{
	public static testMethod void SendEmail_Test()
    {
        boolean isHTML = true;
        List<string> recipients = new List<string> {'pierre@incomlend.com'};
		string subject = 'EmailHelper.SendEmail() test';
        string body = '<p>Email body</p>';
		boolean result = false;
        
        result = EmailHelper.SendEmail(isHTML, recipients, subject, body);
        system.assertEquals(true, result);
    }
}