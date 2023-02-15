@isTest()
public class CreditLimitControllerTest {

    private static Lead setup() {

        Lead testLead = new Lead();
		testLead.Salutation = 'Mr.';
        testLead.FirstName = 'Test';
        testLead.LastName = 'Lead';
        testLead.Street = 'st';
        testLead.City = 'ct';
        testLead.State = '';
        testLead.PostalCode = '68135';
        testLead.Status ='Credit Limit Approved from Risk';
        testLead.Company = 'COMPANY LTD';
        testLead.Country = 'United States';
        testLead.Email = 'mel.k@yopmail.com';
        testLead.Title = 'Director';
        testLead.Decision__c = null;
        testLead.Atradius_Cover_Id__c = null;
        testLead.RecordTypeId = '0120I000000OcVvQAK';
        
        insert testLead;

        insert new configuration__c[] { SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_WebServiceCallout_Endpoint','http://a.nu'),
            SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_WebServiceCallout_ApiKey','a') };

        return testLead;
    }

    @isTest
	private static void testPut() {

        Lead testLead = setup();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();

        CreditLimitController.IsNeedRunTrigger = true;

        CreditLimitController.log(new Helper_Log(), 'test');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = v_baseUrl+'/v9/CreditLimit/' + testLead.Id;
        CreditLimitController.doPut();
        System.assertEquals(200, res.statusCode);
        

        CreditLimitController.toString(new List<Lead> {testLead});

        CreditLimitController.execute('' + testLead.Id);

        testLead.Credit_Limit_Request_Approved__c = true;
        update testLead;

        Test.stopTest();
    }

    @isTest
	private static void testGet() {

        Lead testLead = setup();
        testLead.Atradius_Id__c = 'test';
        testLead.Atradius_Cover_Id__c = 'test';
        update testLead;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();

        CreditLimitController.IsNeedRunTrigger = true;

        CreditLimitController.log(new Helper_Log(), 'test');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        req.httpMethod = 'GET';  
        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = v_baseUrl+'/v9/CreditLimit/';
        CreditLimitController.doGet();
        System.assertEquals(200, res.statusCode);

        Test.stopTest();

    }
}