@RestResource(urlMapping='/v6/agent/*')

global with sharing class RestAgentUsersList_v6{
      
    @HttpGet
    global static ReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String agentId = URLParams[URLParams.size()-1];        
        String userType = URLParams[URLParams.size()-2];  
                
        if(RestUserLogin.isValidId(agentId) == false) {
            return new ReturnClass('false','Invalid Agent ID', null);
        }
        
        String listQuery = 'SELECT Name, pct_of_funds_in_Invoices__c, EUR_eWallet_balance__c , EUR_available_eWallet__c , USD_eWallet_balance__c , USD_available_eWallet__c, HKD_eWallet_balance__c , HKD_available_eWallet__c, SGD_eWallet_balance__c , SGD_available_eWallet__c, Sub_type__c, suspended_notes__c, Onboarding_completed_date__c, suspended__c,  Total_Position_USD_Equiv__c, onboarding_stage__C,  agent__r.name , onboarded__c FROM Account WHERE agent__r.Id=:agentId';
        String sType;  
        
        if(userType == 'agent') {
            sType = 'Agent';
            listQuery = listQuery+' AND Type=:sType';
        }else {
                if(userType == 'supplier') {
                    sType = 'Supplier';
                }else if(userType == 'funder') {
                    sType = 'Purchaser';
                }else {
                return new ReturnClass('false','Invalid user type', null);
             }
            listQuery = listQuery+' AND Sub_type__c=:sType'; 
        }
          
        List<Account> acccList = new List<Account>();
                    
        try {
    
            acccList = database.query(listQuery);
            return new ReturnClass('true', 'Query executed successfully.', acccList);
        
            } catch (Exception e) {
              return new ReturnClass('false', e.getMessage(), null);
         }
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global List<Account> records;

        global ReturnClass(String success, String message, List<Account> records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }
      
}