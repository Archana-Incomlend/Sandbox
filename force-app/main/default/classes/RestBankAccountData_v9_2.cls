@RestResource(urlMapping='/v9.2/BankAccount/*')

global with sharing class RestBankAccountData_v9_2 {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String p_bankAccountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(GlobalMethods_v9.isValidId(p_bankAccountId) == false) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid bank account id')));
        } else {

            List<Bank_Account__c> v_result = new List<Bank_Account__c> ();
            String v_listQuery = 'SELECT Id, Name, Account__c, Beneficiary_Name__c, Bank_Name__c, Country__c, Address__c, Bank_Account_Number__c, IBan__c, Currency__c, SWIFT_Code__c, Incomlend_Account__c, transfer_cutoff_time__c, estimated_transfer_time__c FROM Bank_Account__c WHERE Id = :p_bankAccountId AND Active__c=true AND IsDeleted=false';
            v_result = database.query(v_listQuery);
            if (v_result.size() == 0) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid bank account id')));
            } else {
                BankAccountCustomClass bankAccount = new BankAccountCustomClass(v_result.get(0));
                res.responseBody = Blob.valueOf(JSON.serialize(bankAccount));
                res.statusCode = 200;
            }
        }
    }
}