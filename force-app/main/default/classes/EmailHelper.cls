//===============================================================================================================
// This class contains helping methods to send emails
// Author: Pierre PETESCH
//===============================================================================================================
public class EmailHelper
{
	//===========================================================================================================
    // Class Methods
    //===========================================================================================================
	public static boolean SendEmail(boolean isHTML, List<string> recipients, string subject, string body)
    {
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        emailMessage.toaddresses = recipients;
		emailMessage.subject = subject;
        if(isHTML)
        	emailMessage.htmlbody = body;
        else
            emailMessage.plaintextbody = body;
        
        Messaging.SingleEmailMessage[] emailMessages = new List<Messaging.SingleEmailMessage> {emailMessage};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessages);
        
        for(Messaging.SendEmailResult result : results)
            if(!result.success)
            	return false;
        
        return true;
    }
}