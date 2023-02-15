@isTest(SeeAllData=true)
private class Test_RestAgentUsersList_v9 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    ID v_agentAccountId =  seedincomlenddata.SeedIncomlendAccounts();
   
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.AccountListReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/agent'; 
    req.addParameter('userType', 'supplier');
    req.addParameter('accountId', '0010k000008v');
    v_results = RestAgentUsersList_v9.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid Agent ID', v_results.v_message);
   
    req.requestURI = v_baseUrl+'/services/apexrest/v9/agent';  
    req.addParameter('userType', 'supplier');
    req.addParameter('accountId', v_agentAccountId);
    v_results = RestAgentUsersList_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/agent'; 
    req.addParameter('userType', 'funder');
    req.addParameter('accountId', v_agentAccountId);
    v_results = RestAgentUsersList_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9/agent';  
    req.addParameter('userType', 'agent');
    req.addParameter('accountId', v_agentAccountId);
    v_results = RestAgentUsersList_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}