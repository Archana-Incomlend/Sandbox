@isTest(SeeAllData=true)
private class Test_RestInvoiceData_v9
{
	static
    {
		// setup test data  
	}

	static testMethod void testDoGet()
    {        
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		
		String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

        //###################################################################################################
        // Seeding process
        //###################################################################################################
        ID v_supplierAccountId;
        ID v_userContactId;
        ID v_invoiceID;
        
        try
        {
			v_supplierAccountId = seedincomlenddata.seedAll();
        	v_userContactId = seedincomlenddata.createSupplierContact(v_supplierAccountId);
        	v_invoiceID = seedincomlenddata.makeInvoiceBuyer(1, v_supplierAccountId);
        }
        catch(DmlException managedException)
        {
            v_invoiceID = 'a090I00000uBWEi';
        }
		
        //###################################################################################################
        // Testing process
		//###################################################################################################
        req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		GlobalMethods_v9.InvoiceReturnClass v_results;
		
		req.requestURI = v_baseUrl+'/services/apexrest/v9/invoice/0010k000008v';
		v_results = RestInvoiceData_v9.doGet();
		System.assertEquals('false', v_results.v_success);
		System.assertEquals('Invalid invoice id', v_results.v_message);
		
		req.requestURI = v_baseUrl+'/services/apexrest/v9/invoice/' + v_invoiceID;
		v_results = RestInvoiceData_v9.doGet();
		System.assertEquals('true', v_results.v_success);
		System.assertEquals('Query executed successfully.', v_results.v_message);
		
		req.addHeader('email', 'test@test.com');
		req.requestURI = v_baseUrl+'/services/apexrest/v9/invoice/' + v_invoiceID;
		v_results = RestInvoiceData_v9.doGet();
		System.assertEquals('false', v_results.v_success);
		System.assertEquals('Invalid Email Id', v_results.v_message);
	}
}