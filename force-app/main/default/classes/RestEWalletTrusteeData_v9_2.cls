@RestResource(urlMapping='/v9.2/EWalletTrustee/*')

global with sharing class RestEWalletTrusteeData_v9_2 {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String p_eWalletTrusteeId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(GlobalMethods_v9.isValidId(p_eWalletTrusteeId) == false) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid eWallet trustee id')));
        } else {

            List<eWallet_Trustee__c> v_result = new List<eWallet_Trustee__c>();
            String v_listQuery = 'SELECT Id, Name, Account__c, CCY__c, Balance__c, Trustee__c FROM eWallet_Trustee__c WHERE Id = :p_eWalletTrusteeId AND IsDeleted = false';
            v_result = database.query(v_listQuery);
            if (v_result.size() == 0) {
            	res.statusCode = 400;
            	res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid eWallet trustee id')));
            } else {
                EWalletTrusteeCustomClass eWallet = new EWalletTrusteeCustomClass(v_result.get(0));
                res.responseBody = Blob.valueOf(JSON.serialize(eWallet));
                res.statusCode = 200;
            }
        }
    }
}