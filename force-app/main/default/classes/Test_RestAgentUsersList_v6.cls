@isTest(SeeAllData=true)
private class Test_RestAgentUsersList_v6 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    ID agentId =  seedincomlenddata.SeedIncomlendAccounts();
   
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    RestAgentUsersList_v6.ReturnClass results;
    
    req.requestURI = baseUrl+'/services/apexrest/v6/agent/supplier/0010k000008v';  
    results = RestAgentUsersList_v6.doGet();
    System.assertEquals('false', results.success);
    System.assertEquals('Invalid Agent ID', results.message);
   
    req.requestURI = baseUrl+'/services/apexrest/v6/agent/supplier/'+agentId;  
    results = RestAgentUsersList_v6.doGet();
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);
    
    req.requestURI = baseUrl+'/services/apexrest/v6/agent/funder/'+agentId;  
    results = RestAgentUsersList_v6.doGet();
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);
    
    req.requestURI = baseUrl+'/services/apexrest/v6/agent/agent/'+agentId;  
    results = RestAgentUsersList_v6.doGet();
    System.assertEquals('true', results.success);
    System.assertEquals('Query executed successfully.', results.message);

  }

}