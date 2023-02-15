@isTest(SeeAllData=true)
private class Test_RestBuyerList_v9 {

  static {
    // setup test data  
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    GlobalMethods_v9.AccountListReturnClass v_results;
    
    ID v_supplierAccountId =  seedincomlenddata.seedAll();
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
   
    req.requestURI = v_baseUrl+'/services/apexrest/v9/buyerslist';     
    v_results = RestBuyerList_v9.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}