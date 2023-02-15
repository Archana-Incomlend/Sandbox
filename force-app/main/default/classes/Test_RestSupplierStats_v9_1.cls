@isTest(SeeAllData=true)
private class Test_RestSupplierStats_v9_1 {

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
    GlobalMethods_v9.DecimalMapReturnClass v_results;
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9.1/supplier/stats/USD/0010k000008v';
    v_results = RestSupplierStats_v9_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid User ID', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9.1/supplier/stats/AAA/'+v_supplierAccountId;
    v_results = RestSupplierStats_v9_1.doGet();
    System.assertEquals('false', v_results.v_success);
    System.assertEquals('Invalid currency', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9.1/supplier/stats/USD/'+v_supplierAccountId;
    v_results = RestSupplierStats_v9_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
    
    req.requestURI = v_baseUrl+'/services/apexrest/v9.1/supplier/stats/all/'+v_supplierAccountId;
    v_results = RestSupplierStats_v9_1.doGet();
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);

  }

}