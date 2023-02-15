@RestResource(urlMapping='/user/bankdetails/*')
global with sharing class RestUserBankDetails {
    
    @HttpGet   
    global static ReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String userId = URLParams[URLParams.size()-1];        
                               
        if(RestUserLogin.isValidId(userId) == false) {
        
            return new ReturnClass('false','Invalid User ID', null);
        }                
        try {
            List<Bank_Account__c> result = [SELECT Bank_Name__c, Currency__c, Bank_Account_Number__c, estimated_transfer_time__c, SWIFT_Code__c FROM Bank_Account__c WHERE Account__c = :userId AND Active__c=true];
            for(Bank_Account__c bank : result) {
               bank.Bank_Account_Number__c = CreateMaskedAccount(bank.Bank_Account_Number__c);
            }
            return new ReturnClass('true', 'Query executed successfully.', result);
        }
        catch (Exception e) {
           return new ReturnClass('false', e.getMessage(), null);
        }   
       

    }
    
    global static String CreateMaskedAccount(String accNumber) {
        
        Integer numLen = accNumber.length();
        String accStr;
        if(numLen > 4) {
            for (Integer i = 0;i < (numLen-4); i++) {
                if(accStr == null) {
                    accStr = '*';
                }else {
                    accStr = accStr+'*';
                }
            }
        }else {
            accStr = '********';
        }
        
        String rem = accNumber.substring(numLen-4);
        accStr = accStr+rem;
        return accStr;
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global List<Bank_Account__c> records;

        global ReturnClass(String success, String message, List<Bank_Account__c> records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }

    
}