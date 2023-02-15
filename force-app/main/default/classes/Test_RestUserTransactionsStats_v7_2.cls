@isTest(SeeAllData=true)
private class Test_RestUserTransactionsStats_v7_2 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    ID userAccountId = [Select Account__c from Withdrawal_Deposit__c where Type__c='70.Deposit'].get(0).Account__c;
    
     
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    RestUserTransactionsStats_v7_2.ReturnClass results;
    
    req.requestURI = baseUrl+'/services/apexrest/v7.2/transactions/stats/user/0010k000008v';     
    results = RestUserTransactionsStats_v7_2.doGet();
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid user account Id', results.message);
    
    req.requestURI = baseUrl+'/services/apexrest/v7.2/transactions/stats/user/'+userAccountId;     
    results = RestUserTransactionsStats_v7_2.doGet();
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}