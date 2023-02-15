@RestResource(urlMapping='/v9.2/Transaction/*')

global with sharing class RestTransactionData_v9_2 {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String p_transactionId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(GlobalMethods_v9.isValidId(p_transactionId) == false) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid transaction id')));
        } else {

            List<Transaction__c> v_result = new List<Transaction__c>();
            String v_listQuery = 'SELECT Id, Name, CreatedDate, Effective_Date__c, Type__c, CCY__c, Amount__c, Status__c, Trustee__c, eWallet_Trustee__c, notes__c, Invoice_Finance_Deal__c, Account__c, Related_Transaction__c, Amount_SGD_equiv__c, FX_rate_conversion__c, FX_USD_Rate_Daily__c '
            + ' FROM Transaction__c WHERE Id = :p_transactionId AND IsDeleted = false';
            v_result = database.query(v_listQuery);
            if (v_result.size() == 0) {
                res.statusCode = 400;
            	res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid transaction id')));
            } else {
                TransactionCustomClass trans = new TransactionCustomClass(v_result.get(0));
                res.responseBody = Blob.valueOf(JSON.serialize(trans));
                res.statusCode = 200;
            }
        }
    }
}