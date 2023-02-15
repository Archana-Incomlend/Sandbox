trigger alert_slack_about_deposits 
        on Transaction__c (after delete ) { // temp solution to stop it firing cos deleting apex in live painful
        
        
        if (1==0) {
        
        
    string slackURL;
    string message;
    for (Transaction__c a : Trigger.new) {
       if (     (a.type__c == '70.Deposit'  || a.type__c == '80.Withdrawal' ) 
                   && ( Trigger.isInsert  || (    
                                               Trigger.isUpdate
                                                       &&  (
                                                             ( a.status__c == 'Confirmed by Finance' && Trigger.oldmap.get(a.id).status__c !='Confirmed by Finance' )
                                                              || 
                                                             (Trigger.isUpdate && a.trustee_approved__c  && Trigger.oldmap.get(a.id).trustee_approved__c  == false ) 
                                                             )
                                                 )
                               ) 
           )
           
          {      
                account myaccount = [select name, Sub_type__c from account where id = :a.account__c];
                message = 'Transaction: ' + a.id + '\n' + a.type__c + '. ';
                if (a.type__c == '70.Deposit' ) { message = message + ':champagne:. '; }
                if (a.type__c == '80.Withdrawal' && myaccount.Sub_type__c == 'purchaser' ) { message = message + ':hankey:. '; } 
                                
                
                String l_amount = String.valueOf(a.amount__c.format());
                
                 message = message + myAccount.name + '(' + myaccount.Sub_type__c + ').  Amount: ' + a.ccy__C + ' ' + l_amount +'.';
  
                if (Trigger.isInsert) 
                {   message = message + '\nStatus: ' + a.status__c;   }
                
                  
                if (Trigger.isUpdate ) 
                {   message = message + '\n*Status: ' + a.status__c + '*'; 
                        if  (a.trustee_approved__c) {
                        message = message + '. *(trustee approved)*'; 
                        }
                }

                          
 
                if (a.status__c != 'Requested' && a.status__c != 'Expected' && a.notes__c > '' && ( Trigger.isInsert || (Trigger.isUpdate && (a.notes__c <> Trigger.oldmap.get(a.id).notes__c))) )   { message = message + '\n' + a.notes__c;   } 
    
     }
     
      if (message > '' ) {    slackURL = config.getConfig('Slack Finance Channel URL');
                              SendSlackMessage.send(slackURL, message);   }
      
     } 
     
     
     
     }
}