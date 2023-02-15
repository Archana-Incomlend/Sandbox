@isTest(SeeAllData=true)
private class Test_RestUserTransactions_v8 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    ID v_supplierAccountId =  seedincomlenddata.seedAll();
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
     
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.TransactionListReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v8/transactions/user/0010k000008v';     
    v_results = RestUserTransactions_v8.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user account Id', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v8/transactions/user/'+v_supplierAccountId;     
    v_results = RestUserTransactions_v8.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}