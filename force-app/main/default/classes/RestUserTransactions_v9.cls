@RestResource(urlMapping='/v9/transactions/user')

global with sharing class RestUserTransactions_v9 {
      
    @HttpGet
    global static GlobalMethods_v9.TransactionListReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<Transaction__c> v_result = new List<Transaction__c>(); 
        
        //Get URL paramaters  
        String p_userAccountId = RestContext.request.params.get('accountId'); 
        String p_trusteeName = null;
        if (RestContext.request.params.get('trustee') != null) {
            p_trusteeName = RestContext.request.params.get('trustee');
        }
        
        if(GlobalMethods_v9.isValidId(p_userAccountId) == false) {
            return new GlobalMethods_v9.TransactionListReturnClass('false','Invalid user account Id', null);
        }
      
        String v_listQuery = 'SELECT Invoice_Allocation__r.amount__c, Invoice_Finance_Deal__r.supplier_invoice_reference_number__c, Trustee_Approved__c, External_Reference_Number__c, Invoice_Allocation__r.Funder__r.Name, Effective_Date__c, notes__c, Invoice_Finance_Deal__r.Invoice_name__c, Status__c, Type__c, DebitCredit__c, CCY__c, Amount__c FROM Transaction__c WHERE Account__r.Id=:p_userAccountId';
        if(p_trusteeName != null) {
           v_listQuery = v_listQuery+' AND Trustee__c =:p_trusteeName ORDER BY Effective_Date__c DESC'; 
        } else {
           v_listQuery = v_listQuery+' ORDER BY Effective_Date__c DESC'; 
        }
        
        v_result = database.query(v_listQuery);
        return new GlobalMethods_v9.TransactionListReturnClass('true', 'Query executed successfully.', v_result);                
    }      
}