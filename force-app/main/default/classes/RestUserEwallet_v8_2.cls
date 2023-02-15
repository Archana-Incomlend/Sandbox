@RestResource(urlMapping='/v8.2/ewallet')

global with sharing class RestUserEwallet_v8_2 {
      
    @HttpGet
    global static GlobalMethods.EwalletListReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        //Get URL paramaters  
        String p_accountId = RestContext.request.params.get('accountId'); 
        
        //Initializing and declaring variables
        List<eWallet__c> v_result = new List<eWallet__c> ();
               
        //Validating map Id
        if(GlobalMethods.isValidId(p_accountId) == false) {
            return new GlobalMethods.EwalletListReturnClass('false','Invalid user account Id', null);
        }
        
        //Get logged in user account Id using the email Id from header
        map<String,String> v_headers = new map<String,String>();
        v_headers = req.headers;
        String v_email = v_headers.get('email');
        if(v_email > '') {
            try{
                Id v_loggedInUserAccountId = GlobalMethods.getLoggedinUserAccountId(v_email); 
                if(GlobalMethods.validateUserAccess(v_loggedInUserAccountId, p_accountId) == false) {
                    return new GlobalMethods.EwalletListReturnClass('false','Logged in user does not have permission to access this content', null);
                }
            }catch(GeneralException e) {
                return new GlobalMethods.EwalletListReturnClass('false',e.getMessage(), null);
            }
        }
        
        //Run the query and return result
        String v_listQuery = 'SELECT CCY__c, Repaid__c, Balance__c, Available_Balance__c, In_Progress__c, Reservations__c, Total_Discount_Earned__c, Total_Position__c, Total_Position_USD_Equiv__c, USD_Equiv_Rate__c, Deposits_Not_Processed__c, Withdrawals_Not_Processed__c  FROM eWallet__c WHERE Account__r.Id=:p_accountId';
        v_result = database.query(v_listQuery);
        return new GlobalMethods.EwalletListReturnClass('true', 'Query executed successfully.', v_result);
    }
 
}