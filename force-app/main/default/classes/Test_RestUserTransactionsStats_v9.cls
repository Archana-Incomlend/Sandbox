@isTest(SeeAllData=true)
private class Test_RestUserTransactionsStats_v9 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    ID v_userAccountId = [Select Account__c from Withdrawal_Deposit__c where Type__c='70.Deposit'].get(0).Account__c;
    
     
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.DecimalMapReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/transactions/stats/user/0010k000008v';     
    v_results = RestUserTransactionsStats_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user account Id', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/transactions/stats/user/'+v_userAccountId;     
    v_results = RestUserTransactionsStats_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}