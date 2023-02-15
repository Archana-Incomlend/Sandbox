trigger eWalletBalanceUpdate on Transaction__c (after insert, after update, before delete) {

    private String operation = 'no_operation';
    private Transaction__c thisTrans;
    public  Helper_Log Logs;
    private updateEWalletBalance_Configuration.NotificationConfiguration Notification;
    private boolean hasException = false;
    
    logs = new Helper_Log();
    notification = new updateEWalletBalance_Configuration.NotificationConfiguration();

    system.debug('[eWalletBalanceUpdate]- AlertsRecipients: ' + notification.logsRecipients );
    
    try {
        logs.LogLine();
        logs.Log('update eWallet Balance batch apex called by ' + UserInfo.getName(), 1, Helper_Log.Color.Blue);
        logs.LogLine();
        
        logs.Log('Configurations:', 1, Helper_Log.Color.Blue);
        logs.Log('1. Notification Configuration', 1, Helper_Log.Color.Green);
        logs.Log('IsHTML: ' + notification.IsHTML, 2, Helper_Log.Color.Black);
        logs.Log('AlertsSubject: ' + notification.AlertsSubject, 2, Helper_Log.Color.Black);
        logs.Log('AlertsRecipients: ' + notification.AlertsRecipients, 2, Helper_Log.Color.Black);
        logs.Log('AlertsOnErrorOnly: ' + string.valueOf(notification.AlertsOnErrorOnly), 2, Helper_Log.Color.Black);
        logs.Log('LogsSubject: ' + notification.LogsSubject, 2, Helper_Log.Color.Black);
        logs.Log('LogsRecipients: ' + notification.LogsRecipients, 2, Helper_Log.Color.Black);
        
        if (Trigger.isDelete) {
            system.debug('[eWalletBalanceUpdate]- start isDelete');
            for (Transaction__c trans : Trigger.old) {
                if (trans.Status__c == 'Confirmed by operations' || trans.Status__c == 'Confirmed by Finance'){
                    thisTrans = trans;
                    operation = 'substraction';
                }
            }
        }
        else {
            system.debug('[eWalletBalanceUpdate]- start isInsert or isUpdate');
            for (Transaction__c trans : Trigger.new) {
                if (Trigger.isInsert && (trans.Status__c == 'Confirmed by operations' || trans.Status__c == 'Confirmed by Finance')){
                    thisTrans = trans;
                    operation = 'addition';
                }
                else if (Trigger.isUpdate) {
                    system.debug('[eWalletBalanceUpdate]- start isUpdate');
                    switch on Trigger.oldMap.get(trans.Id).Status__c {
                        when 'Confirmed by operations', 'Confirmed by Finance' {
                            switch on Trigger.newMap.get(trans.Id).Status__c {
                                when 'Confirmed by operations', 'Confirmed by Finance' {
                                    // do nothing
                                }
                                when 'expected', 'Cancelled', 'Requested', '*** error ***' {
                                    thisTrans = trans;
                                    operation = 'substraction';       
                        }}}
                        
                        when 'expected', 'Cancelled', 'Requested', '*** error ***' {
                            switch on Trigger.newMap.get(trans.Id).Status__c {
                                when 'Confirmed by operations', 'Confirmed by Finance' {
                                    thisTrans = trans;
                                    operation = 'addition';
                                }
                                when 'expected', 'Cancelled', 'Requested', '*** error ***' {
                                    // do nothing
                        }}}
                }}        
        }}
        
        this.Logs.Log('Execution:', 1, Helper_Log.Color.Blue);
        this.Logs.Log('1. Method parameters:', 1, Helper_Log.Color.Green);
        this.Logs.Log('Operation: ' + operation, 2, Helper_Log.Color.Black);
        
        if (operation != 'no_operation'){

            List<eWallet__c> scope = [SELECT Name, Balance__c, Balance_Amount_Check__c FROM eWallet__c WHERE Id = :thisTrans.eWallet__c FOR UPDATE];
                    
            for (eWallet__c eWallet : scope) {
                this.Logs.Log('eWallet ID: ' + eWallet.Name, 2, Helper_Log.Color.Black);
                this.Logs.Log('eWallet Balance ' + eWallet.Balance__c, 2, Helper_Log.Color.Black);
                this.Logs.Log('eWallet Balance check: ' + eWallet.Balance_Amount_Check__c, 2, Helper_Log.Color.Black);
                this.Logs.Log('Amount: ' + thisTrans.Amount__c, 2, Helper_Log.Color.Black);

                system.debug('[eWalletBalanceUpdate]- update eWallet ' +  eWallet.Name);
                system.debug('[eWalletBalanceUpdate]- balance ' +  eWallet.Balance__c);
                system.debug('[eWalletBalanceUpdate]- balance check before ' +  eWallet.Balance_Amount_Check__c);
                if (eWallet.Balance_Amount_Check__c == null) eWallet.Balance_Amount_Check__c = 0;
                if (operation == 'addition') {
                    eWallet.Balance_Amount_Check__c += thisTrans.Amount__c;
                    system.debug('[eWalletBalanceUpdate Batch] - update eWallet batch - Addition de '+ thisTrans.Amount__c );
                }
                else if (operation == 'substraction') {
                    eWallet.Balance_Amount_Check__c -= thisTrans.Amount__c;
                    system.debug('eWalletBalanceUpdate Batch] - update eWallet batch - Substraction de '+ thisTrans.Amount__c);
                }
                system.debug('[eWalletBalanceUpdate]- balance check after ' +  eWallet.Balance_Amount_Check__c);    
                update eWallet;
                logs.Log('2. Method result:', 1, Helper_Log.Color.Green);
                logs.Log('eWallet Balance check: ' + eWallet.Balance_Amount_Check__c, 2, Helper_Log.Color.Black);
                system.debug('[eWalletBalanceUpdate]- eWallet updated');
             }
         }
    }
    catch(Exception unmanagedException) {
        logs.Log(unmanagedException);
        hasException = true;
        system.debug('[eWalletBalanceUpdate]- Exception');
    }
    finally {
        system.debug('[eWalletBalanceUpdate]- Finally !');
        //if (hasException) 
            Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
    }
}