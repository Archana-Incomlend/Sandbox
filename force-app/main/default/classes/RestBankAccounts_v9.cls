@RestResource(urlMapping='/v9/bankaccount/*')

global with sharing class RestBankAccounts_v9 {
    
    @HttpGet   
    global static GlobalMethods_v9.BankAccountListReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
        String p_userAccountId = URLParams[URLParams.size()-1];        
                               
        if(GlobalMethods_v9.isValidId(p_userAccountId) == false) {
            return new GlobalMethods_v9.BankAccountListReturnClass('false','Invalid User account id', null);
        }  
                      
        List<Bank_Account__c> v_result = [SELECT Bank_Name__c, Currency__c, Bank_Account_Number__c,	Address__c,	Beneficiary_Name__c, estimated_transfer_time__c, SWIFT_Code__c FROM Bank_Account__c WHERE Account__c = :p_userAccountId AND Active__c=true];
        for(Bank_Account__c v_bankAccount : v_result) {
            v_bankAccount.Bank_Account_Number__c = GlobalMethods_v9.createMaskedAccountNumber(v_bankAccount.Bank_Account_Number__c);
        }
        return new GlobalMethods_v9.BankAccountListReturnClass('true', 'Query executed successfully.', v_result);   
    }
}