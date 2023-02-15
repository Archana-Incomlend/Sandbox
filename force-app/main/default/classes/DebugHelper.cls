//===============================================================================================================
// This class contains helping methods to handle debugging operations
// Author: Pierre PETESCH
//===============================================================================================================
public class DebugHelper
{
    //===========================================================================================================
    // Class Fields
    //===========================================================================================================
    private boolean field_isActive;
    private boolean field_isHTML;
    private string field_fullLog = '';

    //===========================================================================================================
    // Class Properties
    //===========================================================================================================    
    public boolean IsActive
    {
        public get
        {
            return field_isActive;
        }
        public set
        {
            field_isActive = value;
        }
    }
    
    public boolean IsHTML
    {
        public get
        {
            return field_isHTML;
        }
        public set
        {
            field_isHTML = value;
        }
    }
    
    public string FullLog
    {
        public get
        {
            return field_fullLog;
        }
    }
    
    //===========================================================================================================
    // Class Constructors
    //===========================================================================================================
    public DebugHelper()
    {
        this.IsActive = true;
        this.IsHTML = true;
    }
    
    public DebugHelper(boolean isActive, boolean isHTML)
    {
        this.IsActive = isActive;
        this.IsHTML = isHTML;
    }
    
    //===========================================================================================================
    // Class Methods (external)
    //===========================================================================================================
    public void Debug(string message)
    {
        Debug(message, false, false, false);
    }
    
    public void Debug(string message, boolean bold, boolean italic, boolean underline)
    {
        if(message != null && IsActive)
        {
            string output = '';
            
            if(IsHTML)
            {
                string prefix = '';
				string postfix = '';
                    
                if(message.length() > 0)
                {
                    prefix = '<p>';
                    postfix = '</p>';
                    
                    if(bold)
                    {
                        prefix = prefix + '<b>';
                        postfix = '</b>' + postfix;
                    }
                    if(italic)
                    {
                        prefix = prefix + '<i>';
                        postfix = '</i>' + postfix;
                    }
                    if(underline)
                    {
                        prefix = prefix + '<u>';
                        postfix = '</u>' + postfix;
                    }
                }
                else
                    message = '<br>';
                
                output = string.format('{0}{1}{2}', new string[] {prefix, message, postfix});
            }
            else
                output = message;

            if(IsHTML)
                field_fullLog = field_fullLog + output;
            else
            	field_fullLog = field_fullLog + '\n' + output;
            
            system.debug(output);
        }
    }
    
    public void Debug(Exception raisedException)
    {
		Debug(raisedException, 0);
    }
    
    public boolean SendLogs(List<string> recipients, string subject)
    {
        return EmailHelper.SendEmail(IsHTML, recipients, subject, FullLog);
    }
	
    //===========================================================================================================
    // Class Methods (internal)
    //===========================================================================================================    
	private void Debug(Exception raisedException, integer level)
    {
        if(raisedException != null)
        {
            string prefix = '';
            for(integer i = 0; i < level; i++)
                if(isHTML)
                	prefix = prefix + '&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;&nbsp;';
            	else
                    prefix = prefix + '   •   ';
            
            //Inner exception
            Exception innerException = raisedException.getCause();
            
            //Stack Trace
            string stackTrace = raisedException.getStackTraceString();
            if(stackTrace == '()\n' || stackTrace == '()' || stackTrace == '()\nCaused by\n()') //Empty Strack Trace
                stackTrace = null;
            
            //Logging
            Debug('');
            if(level == 0)
            {
                Debug('****************************************************************************************************************');
                Debug('An error occured', true, false, false);
                Debug('****************************************************************************************************************');
            }
            else
                Debug(string.format('{0}Inner Exception {1}:', new string[] {prefix, string.valueof(level)}), true, false, false);

            Debug(string.format('{0}Type: \'\'{1}\'\'', new string[] {prefix, raisedException.getTypeName()}));
            Debug(string.format('{0}Message: \'\'{1}\'\'', new string[] {prefix, raisedException.getMessage()}));
            Debug(string.format('{0}Line Number: \'\'{1}\'\'', new string[] {prefix, string.valueof(raisedException.getLineNumber())}));
			if(stackTrace != null)
                Debug(string.format('{0}Stack Trace: \'\'{1}\'\'', new string[] {prefix, stackTrace}));
            else
                Debug(string.format('{0}Stack Trace: /', new string[] {prefix}));
			if(innerException != null)
                Debug(string.format('{0}Inner Exception: \'\'{1}\'\'', new string[] {prefix, innerException.getTypeName()}));
            else
                Debug(string.format('{0}Inner Exception: /', new string[] {prefix}));
            
            //Recursive call in case of inner exception
			if(innerException != null)
                Debug(innerException, level + 1);
            
			if(level == 0)
            	Debug('****************************************************************************************************************');
			Debug('');
        }
    }
}