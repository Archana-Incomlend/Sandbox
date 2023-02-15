@RestResource(urlMapping='/v3/user/withdrawal')

global with sharing class RestUserWithdrawal_v3 {
      
    @HttpPost
    global static ReturnClass doPost(Id userID, String ccy, Id banckAccountId, double amount) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        double availableEwallet;
        
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
        
        Account usedData = validateUserNew(userId);
        if(ccy == 'USD') {
            availableEwallet = usedData.USD_Available_eWallet__c;
        }else if(ccy == 'SGD') {
            availableEwallet = usedData.SGD_Available_eWallet__c;
        }else if(ccy == 'HKD') {
            availableEwallet = usedData.HKD_Available_eWallet__c;
        }else if(ccy == 'EUR') {
            availableEwallet = usedData.EUR_available_eWallet__c;
        }else if(ccy == 'XXX') {
            availableEwallet = usedData.XXX_available_eWallet__c;
        }
        
        if(amount > availableEwallet) {
            return new ReturnClass('false', 'You do not have enough '+ccy+' available ewallet balance. Your current balance is '+availableEwallet, null);
        }
        
        try {

             Bank_Account__c bankDetails = [SELECT Bank_Name__c, Bank_Account_Number__c, Address__c, Beneficiary_Name__c, SWIFT_Code__c FROM Bank_Account__c WHERE Account__c = :userId AND Id=:banckAccountId];
             Transaction__c trans = new Transaction__c ();
            
             Date today  = system.today();
             
             string ap = today.year() + '-' + today.month().format().leftpad(2,'0');
             id p = [select id from accounting_period__c where Name =:ap limit 1].get(0).id;
             
             
            trans.accounting_period__c = p;   
            trans.Type__c = '80.Withdrawal';
            trans.Status__c = 'Requested';
            trans.Amount__c = -amount;
            trans.CCY__c = ccy;
            trans.Account__c = userID;
            trans.Effective_Date__c = today;
            trans.notes__c = 'Bank name : '+bankDetails.Bank_Name__c+'\n'+
                             'Account number : '+bankDetails.Bank_Account_Number__c+'\n'+
                             'Beneficiary : '+bankDetails.Beneficiary_Name__c+'\n'+
                             'Bank address : '+bankDetails.Address__c+'\n'+
                             'Swift code : '+bankDetails.SWIFT_Code__c+'\n'+
                             'Initiated from : GUI';  
                                
            try {
               insert trans;
               return new ReturnClass('true', 'Request for withdrawal is accepted', null);
            }catch (System.QueryException e) {
                return new ReturnClass('false', 'Request for withdrawal is not submitted. Please try again', null);
            }catch (System.DmlException e) {
               return new ReturnClass('false', e.getDmlMessage(0), null);
            } 
            
        } catch (Exception e) {
          return new ReturnClass('false', 'Invalid Bank account ID', null);
        }
        
        
    }
    
    global static Account validateUserNew(id userId) {
        
        Account result = new Account();
        
        try {
          result = [SELECT Id, Name, Primary_Contact__r.Id,  Type, Sub_type__c, XXX_Available_eWallet__c, EUR_available_eWallet__c, USD_Available_eWallet__c, SGD_Available_eWallet__c, HKD_Available_eWallet__c FROM Account WHERE Id = :userId];
          return result;
    
        } catch (Exception e) {
          return result;
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