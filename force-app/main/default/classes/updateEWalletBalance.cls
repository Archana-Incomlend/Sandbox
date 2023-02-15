global class updateEWalletBalance implements Database.Batchable<sObject> {
    
    private Id eWalletId;
    private String operation;
    private decimal amount;
    
    // ======
	// Fields
	// ======
	private boolean field_hasEncounteredIssues = false;
    
    // ==========
	// Properties
	// ==========
	// Logs
    public Helper_Log Logs
	{
		public get;
		private set;
	}
    
    // Email notification
	private updateEWalletBalance_Configuration.NotificationConfiguration Notification
	{
		get;
		set;
	}
    
    // Indicates if the process has encountered issues
	public boolean HasEncounteredIssues
	{
		get
		{
			return field_hasEncounteredIssues;
		}
		private set
		{
			if(!field_hasEncounteredIssues && value)
				field_hasEncounteredIssues = true;
		}
	}
	
    // ============
	// Constructors
	// ============
    global updateEWalletBalance(Id eWalletIdParam, String operationParam, decimal amountParam){
        eWalletId = eWalletIdParam;
        operation = operationParam;
        amount = amountParam;
        
        this.Logs = new Helper_Log();
        this.notification = new updateEWalletBalance_Configuration.NotificationConfiguration();
    }
    
    
	// ==============
	// Public Methods
	// ==============
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query ='SELECT Name, Balance__c, Balance_Amount_Check__c FROM eWallet__c WHERE Id = :eWalletId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<eWallet__c> scope) {
      try
	  {  
        this.Logs.LogLine();
		this.Logs.Log('update eWallet Balance batch apex called by ' + UserInfo.getName(), 1, Helper_Log.Color.Blue);
		this.Logs.LogLine();
        
        LogConfiguration();
               
        for (eWallet__c eWallet : scope) {
            this.Logs.Log('Execution:', 1, Helper_Log.Color.Blue);
            this.Logs.Log('1. Method parameters:', 1, Helper_Log.Color.Green);
	    	this.Logs.Log('eWallet ID: ' + eWallet.Name, 2, Helper_Log.Color.Black);
	    	this.Logs.Log('eWallet Balance ' + eWallet.Balance__c, 2, Helper_Log.Color.Black);
	    	this.Logs.Log('eWallet Balance check: ' + eWallet.Balance_Amount_Check__c, 2, Helper_Log.Color.Black);
        	this.Logs.Log('Amount: ' + amount, 2, Helper_Log.Color.Black);
        	this.Logs.Log('Operation: ' + operation, 2, Helper_Log.Color.Black);
            
            if (eWallet.Balance_Amount_Check__c == null) eWallet.Balance_Amount_Check__c = 0;
            if (operation == 'addition') {
            	eWallet.Balance_Amount_Check__c += amount;
                system.debug('[eWalletBalanceUpdate Batch] - update eWallet batch - Addition');
            }
            else if (operation == 'substraction') {
                eWallet.Balance_Amount_Check__c -= amount;
                system.debug('eWalletBalanceUpdate Batch] - update eWallet batch - Substraction');
            }
           
            update eWallet;
            
            this.Logs.Log('2. Method result:', 1, Helper_Log.Color.Green);
            this.Logs.Log('eWallet Balance check: ' + eWallet.Balance_Amount_Check__c, 2, Helper_Log.Color.Black);
        }
      }
      catch(Exception unmanagedException)
	  {
			this.Logs.Log(unmanagedException);
			this.HasEncounteredIssues = true;
	  }
	  finally
	  {  // Sends logs
          if(this.HasEncounteredIssues || !this.Notification.LogsOnErrorOnly) {
          	  Helper_Email.Send(this.Notification.IsHTML, this.Notification.LogsRecipients, this.Notification.LogsSubject, this.Logs.HTMLLog);
              system.debug('eWalletBalanceUpdate Batch] - Logs email sent');
          }
				
      }        
    }   

    global void finish(Database.BatchableContext BC) {
    }
    
    
    // ===============
	// Private Methods
	// ===============
	
    private void LogConfiguration()
	{
		this.Logs.Log('Configurations:', 1, Helper_Log.Color.Blue);
		this.Logs.Log('1. Notification Configuration', 1, Helper_Log.Color.Green);
		this.Logs.Log('IsHTML: ' + this.Notification.IsHTML, 2, Helper_Log.Color.Black);
		this.Logs.Log('AlertsSubject: ' + this.Notification.AlertsSubject, 2, Helper_Log.Color.Black);
		this.Logs.Log('AlertsRecipients: ' + this.Notification.AlertsRecipients, 2, Helper_Log.Color.Black);
		this.Logs.Log('AlertsOnErrorOnly: ' + string.valueOf(this.Notification.AlertsOnErrorOnly), 2, Helper_Log.Color.Black);
		this.Logs.Log('LogsSubject: ' + this.Notification.LogsSubject, 2, Helper_Log.Color.Black);
		this.Logs.Log('LogsRecipients: ' + this.Notification.LogsRecipients, 2, Helper_Log.Color.Black);
		
		this.Logs.LogLine();
	}
	

}