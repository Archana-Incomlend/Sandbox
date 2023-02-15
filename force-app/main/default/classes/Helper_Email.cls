//===============================================================================================================
// This class contains helping methods to send emails.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class Helper_Email
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private boolean field_isHTML;
    private List<string> field_toAddresses;
    private List<string> field_ccAddresses;
    private List<string> field_bccAddresses;
    private string field_subject;
    private string field_body;
    private List<Attachment> field_attachments;
    
    //===========================================================================================================
    // Properties
    //===========================================================================================================
    public boolean IsHTML
    {
        get {return field_isHTML;}
        set {field_isHTML = value;}
    }
    
    public List<string> ToAddresses
    {
        get {return field_toAddresses;}
        set {field_toAddresses = value;}
    }
    
    public List<string> CCAddresses
    {
        get {return field_ccAddresses;}
        set {field_ccAddresses = value;}
    }
    
    public List<string> BCCAddresses
    {
        get {return field_bccAddresses;}
        set {field_bccAddresses = value;}
    }
    
    public string Subject
    {
        get {return field_subject;}
        set {field_subject = value;}
    }
    
    public string Body
    {
        get {return field_body;}
        set {field_body = value;}
    }
    
    public List<Attachment> Attachments
    {
        get {return field_attachments;}
        set {field_attachments = value;}
    }
    
    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public Helper_Email()
    {
        this.IsHTML = false;
        this.ToAddresses = new List<string>();
        this.CCAddresses = new List<string>();
        this.BCCAddresses = new List<string>();
        this.Subject = '';
        this.Body = '';
        this.Attachments = new List<Attachment>();
    }
    
    public Helper_Email(boolean isHTML, List<string> toAddresses, string subject, string body)
    {
        this();
        
		this.IsHTML = isHTML;
        this.ToAddresses = toAddresses;
        this.Subject = subject;
        this.Body = body;
    }
    
    public Helper_Email(boolean isHTML, List<string> toAddresses, string subject, string body, List<Attachment> attachments)
    {
        this();
        
		this.IsHTML = isHTML;
        this.ToAddresses = toAddresses;
        this.Subject = subject;
        this.Body = body;
        this.Attachments = attachments;
    }
    
	//===========================================================================================================
    // Methods
    //===========================================================================================================
    public void Send()
    {
        Helper_Email.Send(this);
    }
    
    public static void Send(Helper_Email email)
    {
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();

		if(email == null)
            throw new Helper_EmailException('\'Helper_Email\' object is null.');
        if(email.ToAddresses == null || email.ToAddresses.size() == 0)
            throw new Helper_EmailException('No \'To\' addresses found.');
        
        emailMessage.toaddresses = email.ToAddresses;
		emailMessage.ccaddresses = email.CCAddresses;
        emailMessage.bccaddresses = email.BCCAddresses;
		emailMessage.subject = email.Subject;
        if(email.IsHTML)
        	emailMessage.htmlbody = email.Body;
        else
            emailMessage.plaintextbody = email.Body;
        
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
        for(Attachment attachment : email.Attachments)
        {
            Messaging.EmailFileAttachment attachmentFile = new Messaging.EmailFileAttachment();
            attachmentFile.setFileName(attachment.Filename);
			attachmentFile.setBody(attachment.Content);
            fileAttachments.add(attachmentFile);            
        }
        emailMessage.setFileAttachments(fileAttachments);
        
        Messaging.SingleEmailMessage[] emailMessages = new List<Messaging.SingleEmailMessage> {emailMessage};
        Messaging.sendEmail(emailMessages);
    }
    
    public static void Send(boolean isHTML, List<string> toAddresses, string subject, string body)
    {
        Send(new Helper_Email(isHTML, toAddresses, subject, body));
    }
    
    public static void Send(boolean isHTML, List<string> toAddresses, string subject, string body, List<Attachment> attachments)
    {
        Send(new Helper_Email(isHTML, toAddresses, subject, body, attachments));
    }
    
    //===========================================================================================================
    // Classes
    //===========================================================================================================
    public class Attachment
    {
        //=======================================================================================================
        // Fields
        //=======================================================================================================
        private string field_filename;
        private blob field_content;
        
        //=======================================================================================================
        // Properties
        //=======================================================================================================
        public string Filename
        {
            get {return field_filename;}
            private set {field_filename = value;}
        }
        
        public blob Content
        {
            get {return field_content;}
            private set {field_content = value;}
        }
        
        //=======================================================================================================
        // Constructors
        //=======================================================================================================
        public Attachment(string filename, blob content)
        {
            this.Filename = filename;
            this.Content = content;
        }
    }
    
    public class Helper_EmailException extends Exception {}
}