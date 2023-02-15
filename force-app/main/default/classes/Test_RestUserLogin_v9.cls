@isTest
private class Test_RestUserLogin_v9 {

  static testMethod void testDoGet() {

    Map<String, Object> result = SeedTest.init(null, null, 'contact');
    String v_email = ((Contact)result.get('contactSupplier')).Email;

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    String v_env = 'dev';
        
    req.requestURI = v_baseUrl+'/services/apexrest/v9/user/login';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    
    GlobalMethods_v9.ContactReturnClass v_results;
    
    v_results = RestUserLogin_v9.doPost(v_email,'facebook', v_env);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid email', v_results.v_message);
    
    v_results = RestUserLogin_v9.doPost(v_email,'linkedin', v_env);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid email', v_results.v_message);
    
    v_results = RestUserLogin_v9.doPost(v_email,'yahoo', v_env);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid login type', v_results.v_message);
    
    v_results = RestUserLogin_v9.doPost(v_email,'google', v_env);
    System.debug('' + [SELECT min(id) id, min(account.name) name, min(account.onboarding_stage__c) onboarding_stage__c  FROM Contact WHERE google_username__c = :v_email]);
    System.debug(v_results);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
  }

}