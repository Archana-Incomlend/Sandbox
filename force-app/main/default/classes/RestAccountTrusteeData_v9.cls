@RestResource(urlMapping='/v9/trusteeList/*')

global with sharing class RestAccountTrusteeData_v9 {

@HttpGet
    global static GlobalMethods_v9.AccountReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List <Account> v_result = new List <Account> ();
        String p_accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        //Get logged in user account Id using the email Id from header
        map<String,String> v_headers = new map<String,String>();
        v_headers = req.headers;
        String v_email = v_headers.get('email');
        if(v_email > '') {
            try{
                Id v_loggedInUserAccountId = GlobalMethods_v9.getLoggedinUserAccountId(v_email); 
            }catch(GeneralException e) {
                return new GlobalMethods_v9.AccountReturnClass('false',e.getMessage(), null);
            }
        }
        
        
        if(GlobalMethods_v9.isValidId(p_accountId) == false) {
           return new GlobalMethods_v9.AccountReturnClass('false','Invalid account id', null);
        }
        
        v_result = [SELECT Trustee__c FROM Account WHERE Id = :p_accountId];
        if (v_result.size() == 0) {
            return new GlobalMethods_v9.AccountReturnClass('false','Invalid account Id', null);
        }else {
            return new GlobalMethods_v9.AccountReturnClass('true','Query executed successfully.', v_result.get(0));
        } 
    } 
}