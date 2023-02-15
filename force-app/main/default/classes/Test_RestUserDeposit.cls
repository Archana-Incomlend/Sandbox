@isTest(SeeAllData=true)
private class Test_RestUserDeposit {

  static {
    // setup test data  
  }

  static testMethod void testDoPost() {

   Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    Id banckAccountId;
    Double amount;
    String ccy;
    String userName;
            
    ID AgentID;
    AgentID = seedincomlenddata.SeedIncomlendAccounts();
      
    ID USDMarketplace;
    USDMarketplace = seedincomlenddata.SeedProducts();
    ID funderID = seedincomlenddata.SeedTestFunderAccounts(AgentID, USDMarketplace);
    banckAccountId = seedincomlenddata.makeBankAcccountFunder(funderID);
    amount = 1000;
    ccy = 'USD';
    userName = 'Mr John';
        
    req.requestURI = baseUrl+'/user/deposit';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;

    RestUserDeposit.ReturnClass results = RestUserDeposit.doPost(funderID, ccy, userName, banckAccountId, amount);
    System.assertEquals('true', results.success);
    //System.assertEquals('Request for declare deposit is accepted. Please proceed to make the transfer. When we received the fund, we will credit your ewallet accordingly.', results.message);

  }

}