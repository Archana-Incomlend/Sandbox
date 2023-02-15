@isTest(SeeAllData=true)
private class Test_RestUserBankDetails {

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    ID userID =  SeedIncomlendData.makeBankAccount();

    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.requestURI = baseUrl+'/services/apexrest/user/bankdetails/'+userID;  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
        
    RestUserBankDetails.ReturnClass results = RestUserBankDetails.doGet();
    
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}