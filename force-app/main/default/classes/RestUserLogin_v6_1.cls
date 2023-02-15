@RestResource(urlMapping='/v6.1/user/login')
global with sharing class RestUserLogin_v6_1 {
      
    @HttpPost
    global static ReturnClass doPost(String email, String loginType, String env) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Contact result = new Contact();
        
        String loginQuery = 'SELECT Id, Name, Account.Id, Account.RecordType.Name, Account.Name, Account.Type, Account.Sub_type__c, Email FROM Contact where account.suspended__C = false and account.onboarded__c = true ' ;
        
        if(loginType == 'facebook') {
            loginQuery = loginQuery+' AND facebook_username__c = :email'; 
        }else if(loginType == 'google') {
            loginQuery = loginQuery+' AND (google_username__c = :email or google_username_support__c = :email or google_username_agent__c = :email) limit 1'; 
        }else if(loginType == 'linkedin') {
            loginQuery = loginQuery+' AND Linkedin_username__c = :email'; 
        }else {
            return new ReturnClass('false', 'Invalid login type', null);
        }
                        
        try {

         result = database.query(loginQuery);
          
         contact_log__c newlog = new contact_log__c();
         newlog.date__c = System.now();
         newlog.contact__c = result.id;
         newlog.action__C = 'Login';
         newlog.extra_info__C = 'loginType = ' + loginType + '; email = ' + email +'; environment = '+env+ ';';
         insert newLog;
          
          return new ReturnClass('true', 'Query executed successfully.', result);
    
        } catch (Exception e) {
        
           contact_log__c newlog = new contact_log__c();
           newlog.date__c = System.now();
           newlog.action__C = 'Failed login ';
           newlog.extra_info__C = 'loginType = ' + loginType + '; email = ' + email +'; environment = '+env+ ';';
           insert newLog;
          
          return new ReturnClass('false', e.getMessage(), null);
        }
    }
        
    global static Account validateUser(id userId) {
        
        Account result = new Account();
        
        try {

          result = [SELECT Id, Name, Primary_Contact__r.Id,  Type, Sub_type__c, EUR_available_eWallet__c, USD_Available_eWallet__c, SGD_Available_eWallet__c, HKD_Available_eWallet__c FROM Account WHERE Id = :userId];
          return result;
    
        } catch (Exception e) {
          return result;
        }
    
    }
    
    global static Boolean isValidId(String strId) {
        Boolean isValid = (strId InstanceOf ID) ? true : false ;
        return isValid ;
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global Contact records;

        global ReturnClass(String success, String message, Contact records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }
      
}