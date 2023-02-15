@RestResource(urlMapping='/user/deposit')
global with sharing class RestUserDeposit {
      
    @HttpPost
    global static ReturnClass doPost(Id userID, String ccy, String userName, Id banckAccountId, double amount) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        if(RestUserLogin.isValidId(userId) == false) {
            return new ReturnClass('false','Invalid User ID', null);
        }       
        
        if(RestUserLogin.isValidId(banckAccountId) == false) {
            return new ReturnClass('false','Invalid Bank account ID', null);
        }
        
        if(amount == null || amount <= 0) {
            return new ReturnClass('false','Invalid amount', null);
        }
        
        if(ccy == null) {
            return new ReturnClass('false','Invalid currency', null);
        }
        
        try {

             Bank_Account__c bankDetails = [SELECT Bank_Name__c, Bank_Account_Number__c, Address__c, Beneficiary_Name__c, SWIFT_Code__c FROM Bank_Account__c WHERE Account__c = :userId AND Id=:banckAccountId];
             Transaction__c trans = new Transaction__c ();
            
             Date today  = system.today();
            
              string ap = today.year() + '-' + today.month().format().leftpad(2,'0');
             id p = [select id from accounting_period__c where Name =:ap limit 1].get(0).id;
             
             
            trans.accounting_period__c = p;   
            trans.Type__c = '70.Deposit';
            trans.Status__c = 'expected';
            trans.Amount__c = amount;
            trans.CCY__c = ccy;
            trans.Account__c = userID;
            trans.Effective_Date__c = today;
            trans.notes__c = 'Bank name : '+bankDetails.Bank_Name__c+'\n'+
                             'Account number : '+bankDetails.Bank_Account_Number__c+'\n'+
                             'Beneficiary : '+bankDetails.Beneficiary_Name__c+'\n'+
                             'Bank address : '+bankDetails.Address__c+'\n'+
                             'Account name : '+userName+'\n'+
                             'Initiated from : GUI';     
            try {
               insert trans;
               return new ReturnClass('true', 'Request for declare deposit is accepted. Please proceed to make the transfer. When we received the fund, we will credit your ewallet accordingly.', null);
            }catch (System.QueryException e) {
                return new ReturnClass('false', 'Request for declare deposit is not submitted. Please try again', null);
            }catch (System.DmlException e) {
               return new ReturnClass('false', e.getDmlMessage(0), null);
            } 
            
        } catch (Exception e) {
          return new ReturnClass('false', 'Invalid Bank account ID', null);
        }
        
        
    }
    
    
    global class ReturnClass {

        global String success;
        global String message;
        global Transaction__c records;

        global ReturnClass(String success, String message, Transaction__c records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }
      
}