@RestResource(urlMapping='/v9/withdrawaldeposit')

global with sharing class RestWithdrawalDeposit_v9 {
      
    @HttpPost
    global static GlobalMethods_v9.WithdrawalDepositReturnClass doPost(String p_type, Id p_loggedinUserAccountID, String p_ccy,  Id p_bankAccountId, double p_amount, String p_notes, String p_trustee) {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ID v_loggedInUserAccountId;
        string v_type;
        String v_message;
        String v_slackMessage;
        Bank_Account__c v_bankDetails;
        
        map<String,String> v_headers = new map<String,String>();
        Map<String,String> v_types = new Map<String,String>{
            'deposit' => '70.Deposit',
            'withdrawal' => '80.Withdrawal'
        };    
        Map<String,String> v_messages = new Map<String,String>{
            'deposit' => 'Request for declare deposit is accepted. Please proceed to make the transfer. When we received the fund, we will credit your ewallet accordingly.',
            'withdrawal' => 'Request for withdrawal is accepted'
        };
        Map<String,String> v_slackOption = new Map<String,String>{
            'deposit' => ':champagne:. ',
            'withdrawal' => ''// ':hankey:. '
        };
        
        //Get logged in user account Id using the email Id from header
        v_headers = req.headers;
        String v_email = v_headers.get('email');
        String v_ipAddress = v_headers.get('ip');
        
        if(v_email > '') {
            try{
                v_loggedInUserAccountId = GlobalMethods_v9.getLoggedinUserAccountId(v_email); 
            }catch(GeneralException e) {
                return new GlobalMethods_v9.WithdrawalDepositReturnClass('false',e.getMessage(), null);
            }
        }else {       
            if(RestUserLogin.isValidId(p_loggedinUserAccountID) == false) {
                return new GlobalMethods_v9.WithdrawalDepositReturnClass('false','Invalid User ID', null);
            }else {
                v_loggedInUserAccountId = p_loggedinUserAccountID;
            }
        }
        
        p_notes = p_notes+'\n Logged in user email : '+v_email+'\n'+
                    'Logged in user IP address : '+v_ipAddress+'\n'+
                    'Requested date : '+String.valueOf(system.now()); 
                
        if(p_amount == null || p_amount <= 0) {
            return new GlobalMethods_v9.WithdrawalDepositReturnClass('false','Invalid amount', null);
        }
        
        if(GlobalMethods_v9.isvalidCurrency(p_ccy) == false) {
            return new GlobalMethods_v9.WithdrawalDepositReturnClass('false','Invalid currency', null);
        }   
        if(p_trustee == null || p_trustee == '') {
            return new GlobalMethods_v9.WithdrawalDepositReturnClass('false','Invalid trustee', null);
        } 
        try {
            v_bankDetails = [SELECT account__r.name, account__r.Sub_type__c, Bank_Name__c, Bank_Account_Number__c, Address__c, Beneficiary_Name__c, SWIFT_Code__c FROM Bank_Account__c WHERE Account__c = :v_loggedInUserAccountId AND Id=:p_bankAccountId];
        } catch (Exception e) {
          return new GlobalMethods_v9.WithdrawalDepositReturnClass('false', 'Invalid Bank account ID or Bank Account is not for logged in user', null);
        }  
        
         if(v_types.get(p_type) != null) {
            v_type = v_types.get(p_type);
            v_message = v_messages.get(p_type);
        }else {
            return new GlobalMethods_v9.WithdrawalDepositReturnClass('false','Invalid type', null);
        }
        
        v_slackMessage = p_type.capitalize() + ': ';
        if(v_bankDetails.account__r.Sub_type__c != 'Supplier') {
            v_slackMessage = v_slackMessage + v_slackOption.get(p_type);
        }
        
        v_slackMessage = v_slackMessage + v_bankDetails.account__r.name + '(' + v_bankDetails.account__r.Sub_type__c + ').  Amount: ' + p_ccy + ' ' + p_amount.intvalue() +'.'+ '\nStatus:  Not Processed'; 
        
        Withdrawal_Deposit__c wd = new Withdrawal_Deposit__c ();
 
        wd.type__c = v_type;
        wd.Status__c = 'Not Processed';
        wd.Amount__c = p_amount;
        wd.CCY__c = p_ccy;
        wd.Account__c = v_loggedInUserAccountId;
        wd.Bank_Account__c = p_bankAccountId;
        wd.Confirm_receipt__c = p_notes;
        wd.ewallet__c = ewallet.lookup(p_ccy, v_loggedInUserAccountId);
        wd.Trustee__c = p_trustee;
            
        try {
            insert wd;
            SendSlackMessage.send(config.getConfig('Slack Finance Channel URL'), v_slackMessage); 
            return new GlobalMethods_v9.WithdrawalDepositReturnClass('true', v_message, null);
        }catch (System.Exception e) {
               return new GlobalMethods_v9.WithdrawalDepositReturnClass('false', e.getMessage(), null);
        } 
    }
      
}