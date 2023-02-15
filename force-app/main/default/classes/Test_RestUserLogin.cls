@isTest(SeeAllData=true)
private class Test_RestUserLogin {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String email= 'testsupplier@gmail.com';
    seedincomlenddata.seedContactAll(email);
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
    req.requestURI = baseUrl+'/services/apexrest/user/login';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    
    ID userId ='a0qO00000095KfK';
    Account result = RestUserLogin.validateUser(userId);
    Boolean isValid = RestUserLogin.isValidId(userId);
    
    String loginType= 'facebook';
    RestUserLogin.ReturnClass results1 = RestUserLogin.doPost(email,loginType);
    
    loginType= 'linkedin';
    RestUserLogin.ReturnClass results2 = RestUserLogin.doPost(email,loginType);
    
    loginType= 'yahoo';
    RestUserLogin.ReturnClass results3 = RestUserLogin.doPost(email,loginType);
    
    loginType= 'google';   
        
    RestUserLogin.ReturnClass results = RestUserLogin.doPost(email,loginType);
    
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}