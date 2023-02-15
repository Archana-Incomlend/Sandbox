@isTest(SeeAllData=true)
private class Test_RestUserTransactions_v9 {

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
    GlobalMethods_v9.TransactionListReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/transactions/user'; 
    req.addParameter('accountId', '0010k000008v');
    v_results = RestUserTransactions_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid user account Id', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/transactions/user';   
    req.addParameter('accountId', v_supplierAccountId);
    v_results = RestUserTransactions_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}