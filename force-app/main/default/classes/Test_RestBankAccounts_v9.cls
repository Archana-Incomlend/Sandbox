@isTest(SeeAllData=true)
private class Test_RestBankAccounts_v9 {

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    ID v_userAccountId =  SeedIncomlendData.makeBankAccount();
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.BankAccountListReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/user/bankdetails/0010k000008v';      
    v_results = RestBankAccounts_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid User account id', v_results.v_message);
        
    req.requestURI = v_baseUrl+'/services/apexrest/v9/user/bankdetails/'+v_userAccountId;      
    v_results = RestBankAccounts_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}