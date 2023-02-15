@RestResource(urlMapping='/v9/ewallet')

global with sharing class RestEwallet_v9 {
      
    @HttpGet
    global static GlobalMethods_v9.EwalletTrusteeListReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        //Get URL paramaters  
        String p_accountId = RestContext.request.params.get('accountId'); 
        String p_trusteeName = null;
        if (RestContext.request.params.get('trustee') != null) {
            p_trusteeName = RestContext.request.params.get('trustee');
        }
        
        //Initializing and declaring variables
        List<eWallet_Trustee__c> v_result = new List<eWallet_Trustee__c> ();
               
        //Validating map Id
        if(GlobalMethods_v9.isValidId(p_accountId) == false) {
            return new GlobalMethods_v9.EwalletTrusteeListReturnClass('false','Invalid user account Id', null);
        }
        
        //Get logged in user account Id using the email Id from header
        map<String,String> v_headers = new map<String,String>();
        v_headers = req.headers;
        String v_email = v_headers.get('email');
        if(v_email > '') {
            try{
                Id v_loggedInUserAccountId = GlobalMethods_v9.getLoggedinUserAccountId(v_email); 
                if(GlobalMethods_v9.validateUserAccess(v_loggedInUserAccountId, p_accountId) == false) {
                    return new GlobalMethods_v9.EwalletTrusteeListReturnClass('false','Logged in user does not have permission to access this content', null);
                }
            }catch(GeneralException e) {
                return new GlobalMethods_v9.EwalletTrusteeListReturnClass('false',e.getMessage(), null);
            }
        }
        
        //Run the query and return result
        String v_listQuery = 'SELECT Trustee__c, CCY__c, Repaid__c, Balance__c, Available_Balance__c, In_Progress__c, Reservations__c, Total_Discount_Earned__c, Total_Position__c, Total_Position_USD_Equiv__c, USD_Equiv_Rate__c, Deposits_Not_Processed__c, Withdrawals_Not_Processed__c, Pre_Reservations__c  FROM eWallet_Trustee__c WHERE Account__r.Id=:p_accountId';
        if(p_trusteeName != null) {
           v_listQuery = v_listQuery+' AND Trustee__c =:p_trusteeName'; 
        }
        
        v_result = database.query(v_listQuery);
        return new GlobalMethods_v9.EwalletTrusteeListReturnClass('true', 'Query executed successfully.', v_result);
    }
 
}