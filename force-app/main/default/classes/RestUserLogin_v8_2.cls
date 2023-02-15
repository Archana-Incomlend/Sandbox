@RestResource(urlMapping='/v8.2/user/login')

global with sharing class RestUserLogin_v8_2 {
      
    @HttpPost
    global static GlobalMethods.ContactReturnClass doPost(String p_email, String p_loginType, String p_env) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<Contact> v_result = new List<Contact>();
        Map<String,String> v_filters = new Map<String,String>{
            'facebook' => 'facebook_username__c = :p_email',
            'google' => '(google_username__c = :p_email or google_username_support__c = :p_email or google_username_agent__c = :p_email)',
            'linkedin' => 'Linkedin_username__c = :p_email'
        };
        map<String,String> v_headers = new map<String,String>();
        v_headers = req.headers;
        String v_ipAddress = v_headers.get('ip');
        String v_filter; 
                
        if(v_filters.get(p_loginType) != null) {
            v_filter = v_filters.get(p_loginType);
        }else {
            return new GlobalMethods.ContactReturnClass('false','Invalid login type', null);
        }
        String v_logText = 'loginType = ' + p_loginType + '; email = ' + p_email +'; environment = '+ p_env + '; ip address = ' + v_ipAddress + '; ';
        
        String loginQuery = 'SELECT Id, account.suspended__C ,account.onboarded__c ,  Name, Account.Id, Account.RecordType.Name, Account.Name, Account.Type, Account.Sub_type__c, Email FROM Contact WHERE '+ v_filter + ' limit 1';
        v_result = database.query(loginQuery);
        
        if (v_result.size() == 0) {
            GlobalMethods.addContactLog(null, null, 'Failed login', v_logText, null);
            return new GlobalMethods.ContactReturnClass('false', 'Invalid email', null);
        }else if (v_result.get(0).account.suspended__C == true) {
            v_logText = v_logText + 'Account is Suspended;';
            GlobalMethods.addContactLog(v_result.get(0).id, null, 'Failed login', v_logText, null);
            return new GlobalMethods.ContactReturnClass('false', 'Account is Suspended', null);
        }else if (v_result.get(0).account.onboarded__c == false) {
            v_logText = v_logText + 'Account is not onboarded;';
            GlobalMethods.addContactLog(v_result.get(0).id, null, 'Failed login', v_logText, null);
            return new GlobalMethods.ContactReturnClass('false', 'Account is not onboarded', null);
        }else {
            GlobalMethods.addContactLog(v_result.get(0).id, null, 'Login', v_logText, null);
            return new GlobalMethods.ContactReturnClass('true', 'Query executed successfully.', v_result.get(0));
        }
    }       
}