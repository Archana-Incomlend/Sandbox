@RestResource(urlMapping='/v9/agent')

global with sharing class RestAgentUsersList_v9 {
      
    @HttpGet
    global static GlobalMethods_v9.AccountListReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');                      
        String p_userType = RestContext.request.params.get('userType');  
        String p_agentAccountId = RestContext.request.params.get('accountId'); 
        String p_trusteeName = null;
        if (RestContext.request.params.get('trustee') != null) {
            p_trusteeName = RestContext.request.params.get('trustee');
        }
        String v_sType;   
        List<Account> v_result = new List<Account>();
                
        if(GlobalMethods_v9.isValidId(p_agentAccountId) == false) {
            return new GlobalMethods_v9.AccountListReturnClass('false','Invalid Agent ID', null);
        }
        
        String listQuery = 'SELECT Name, pct_of_funds_in_Invoices__c, EUR_eWallet__r.Balance__c, GBP_eWallet__r.Available_Balance__c, GBP_eWallet__r.Balance__c, EUR_eWallet__r.Available_Balance__c, USD_eWallet__r.Balance__c, USD_eWallet__r.Available_Balance__c, HKD_eWallet__r.Balance__c, HKD_eWallet__r.Available_Balance__c, SGD_eWallet__r.Balance__c, SGD_eWallet__r.Available_Balance__c, Sub_type__c, suspended_notes__c, Onboarding_completed_date__c, suspended__c,  Total_Position_USD_Equiv__c, onboarding_stage__C,  agent__r.name , onboarded__c FROM Account WHERE agent__r.Id=:p_agentAccountId';
        if(p_trusteeName != null) {
                listQuery = listQuery+' AND Trustee__c INCLUDES(:p_trusteeName)'; 
            }
        if(p_userType == 'agent') {
            v_sType = 'Agent';
            listQuery = listQuery+' AND Type=:v_sType';
        }else {
                if(p_userType == 'supplier') {
                    v_sType = 'Supplier';
                }else if(p_userType == 'funder') {
                    v_sType = 'Purchaser';
                }else {
                return new GlobalMethods_v9.AccountListReturnClass('false','Invalid user type', null);
             }
            listQuery = listQuery+' AND Sub_type__c=:v_sType'; 
        }
        
        v_result = database.query(listQuery);
        return new GlobalMethods_v9.AccountListReturnClass('true', 'Query executed successfully.', v_result);

    }
}