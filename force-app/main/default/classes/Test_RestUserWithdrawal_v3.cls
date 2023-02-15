@isTest(SeeAllData=true)
private class Test_RestUserWithdrawal_v3 {

  static {
    // setup test data  
  }

  static testMethod void testDoPost() {
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    Id banckAccountId;
    Boolean acceptPartialBid;
    Double amount;
    String ccy;
            
    ID AgentID;
    AgentID = seedincomlenddata.SeedIncomlendAccounts();
    Account result = RestUserWithdrawal_v3.validateUserNew(AgentID);
   
    ID USDMarketplace;
    USDMarketplace = seedincomlenddata.SeedProducts();
    ID funderID = seedincomlenddata.SeedTestFunderAccounts(AgentID, USDMarketplace);
    seedincomlenddata.createTransactions(funderID, '70.Deposit');
    banckAccountId = seedincomlenddata.makeBankAcccountFunder(funderID);
    amount = 1000;
           
    req.requestURI = baseUrl+'/v3/user/withdrawal';  
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    
    ccy = 'USD';
    RestUserWithdrawal_v3.ReturnClass results1 = RestUserWithdrawal_v3.doPost(funderID, ccy, banckAccountId, amount);
    
    ccy = 'EUR';
    RestUserWithdrawal_v3.ReturnClass results2 = RestUserWithdrawal_v3.doPost(funderID, ccy, banckAccountId, amount);
    
    ccy = 'HKD';
    RestUserWithdrawal_v3.ReturnClass results3 = RestUserWithdrawal_v3.doPost(funderID, ccy, banckAccountId, amount);
    
    ccy = 'SGD';
    RestUserWithdrawal_v3.ReturnClass results4 = RestUserWithdrawal_v3.doPost(funderID, ccy, banckAccountId, amount);
    
    ccy = 'XXX';
    RestUserWithdrawal_v3.ReturnClass results = RestUserWithdrawal_v3.doPost(funderID, ccy, banckAccountId, amount);
    
    System.assertEquals('true', results.success);
    System.assertEquals('Request for withdrawal is accepted', results.message);

  }

}