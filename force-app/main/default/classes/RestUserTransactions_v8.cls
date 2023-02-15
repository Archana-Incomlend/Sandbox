@RestResource(urlMapping='/v8/transactions/user/*')

global with sharing class RestUserTransactions_v8 {
      
    @HttpGet
    global static GlobalMethods.TransactionListReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<Transaction__c> v_result = new List<Transaction__c>(); 
        
        String p_userAccountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(GlobalMethods.isValidId(p_userAccountId) == false) {
            return new GlobalMethods.TransactionListReturnClass('false','Invalid user account Id', null);
        }
      
        String v_listQuery = 'SELECT Invoice_Allocation__r.amount__c, Invoice_Finance_Deal__r.supplier_invoice_reference_number__c, Trustee_Approved__c, External_Reference_Number__c, Invoice_Allocation__r.Funder__r.Name, Effective_Date__c, notes__c, Invoice_Finance_Deal__r.Invoice_name__c, Status__c, Type__c, DebitCredit__c, CCY__c, Amount__c FROM Transaction__c WHERE Account__r.Id=:p_userAccountId ORDER BY Effective_Date__c DESC';
        v_result = database.query(v_listQuery);
        return new GlobalMethods.TransactionListReturnClass('true', 'Query executed successfully.', v_result);                
    }      
}