@isTest(SeeAllData=true)
private class Test_RestUserLogin_v6_1 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String email= 'testsupplier@gmail.com';
    seedincomlenddata.seedContactAll(email);
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
    req.requestURI = baseUrl+'/services/apexrest/v6.1/user/login';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    String env = 'test';
    
    ID userId ='a0qO00000095KfK';
    Account result = RestUserLogin_v6_1.validateUser(userId);
    Boolean isValid = RestUserLogin_v6_1.isValidId(userId);
    
    String loginType= 'facebook';
    RestUserLogin_v6_1.ReturnClass results1 = RestUserLogin_v6_1.doPost(email,loginType, env);
    
    loginType= 'linkedin';
    RestUserLogin_v6_1.ReturnClass results2 = RestUserLogin_v6_1.doPost(email,loginType, env);
    
    loginType= 'yahoo';
    RestUserLogin_v6_1.ReturnClass results3 = RestUserLogin_v6_1.doPost(email,loginType, env);
    
    loginType= 'google';   
        
    RestUserLogin_v6_1.ReturnClass results = RestUserLogin_v6_1.doPost(email,loginType, env);
    
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}