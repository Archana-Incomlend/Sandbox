@RestResource(urlMapping='/v6.1/transactions/user/*')

global with sharing class RestUserTransactions_v6_1 {
      
    @HttpGet
    global static ReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String userId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if(RestUserLogin.isValidId(userId) == false) {
        
            return new ReturnClass('false','Invalid user ID', null);
        }
        
        Account usedData = RestUserLogin.validateUser(userId);
       
        String listQuery = 'SELECT Invoice_Allocation__r.amount__c, Trustee_Approved__c, External_Reference_Number__c, Invoice_Allocation__r.Funder__r.Name, Effective_Date__c, notes__c, Invoice_Finance_Deal__r.Invoice_name__c, Status__c, Type__c, DebitCredit__c, CCY__c, Amount__c FROM Transaction__c WHERE Account__r.Id=:userId ORDER BY Effective_Date__c DESC';
            
        List<Transaction__c> TransList = new List<Transaction__c>();  
                    
        try {
    
              TransList = database.query(listQuery);
              return new ReturnClass('true', 'Query executed successfully.', TransList);
        
            } catch (Exception e) {
              return new ReturnClass('false', e.getMessage(), null);
            }     
        
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global List<Transaction__c> records;

        global ReturnClass(String success, String message, List<Transaction__c> records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }
      
}