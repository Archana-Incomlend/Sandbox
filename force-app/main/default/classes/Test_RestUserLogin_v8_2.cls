@isTest(SeeAllData=true)
private class Test_RestUserLogin_v8_2 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String v_email= 'testsupplier@gmail.com';
    seedincomlenddata.seedContactAll(v_email);
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    String v_env = 'dev';
        
    req.requestURI = v_baseUrl+'/services/apexrest/v8.2/user/login';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    
    GlobalMethods.ContactReturnClass v_results;
    
    v_results = RestUserLogin_v8_2.doPost(v_email,'facebook', v_env);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid email', v_results.v_message);
    
    v_results = RestUserLogin_v8_2.doPost(v_email,'linkedin', v_env);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid email', v_results.v_message);
    
    v_results = RestUserLogin_v8_2.doPost(v_email,'yahoo', v_env);
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid login type', v_results.v_message);
    
    v_results = RestUserLogin_v8_2.doPost(v_email,'google', v_env);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
  }

}