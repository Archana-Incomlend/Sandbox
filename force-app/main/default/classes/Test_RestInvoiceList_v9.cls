@isTest
private class Test_RestInvoiceList_v9 {
    
    static testMethod void testDoGet() {
        Map<String, Object> result = SeedTest.init();
        Id marketPlaceId = SeedTest.getId(result, 'marketplaceUSD'); 
        Id supplierId = SeedTest.getId(result, 'accountSupplier');
        Id buyerId = SeedTest.getId(result, 'accountBuyer');
        Id mapId = SeedTest.getId(result, 'map');

        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        GlobalMethods_v9.InvoiceListReturnClass v_results;
        
        req.requestURI = v_baseUrl+'/services/apexrest/v9/invoices';
        req.addParameter('marketplace', marketPlaceId);
        req.addParameter('phase', 'onmarketplace');
        req.addParameter('ccy', 'USD');
        req.addParameter('supplierAccountId', '');
        req.addParameter('buyerAccountId', '');
        req.addParameter('overdue','');
        req.addParameter('passthrough','');
        req.addParameter('supplierApprovalStatus','');
        req.addParameter('trustee','Amicorp Trust');

        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);        

        // test on prelisting
        req.addParameter('phase', 'prelisting');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);        
        req.addParameter('phase', 'onmarketplace');

        // test secondary marketplace
        req.addParameter('secondaryMarketplace', 'true');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        req.addParameter('secondaryMarketplace', '');

        // start supplier 
        req.addParameter('supplierAccountId', supplierId);

        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);

        req.addParameter('mapId', mapId);
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        req.addParameter('mapId', '');

        //testDoGetFailInvalidSupplierUser
        req.addParameter('supplierAccountId', '0010T00000IubCd');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('false', v_results.v_success);
        System.assertEquals('Invalid user', v_results.v_message);
        req.addParameter('supplierAccountId', supplierId);

        //testDoGetFailInvalidSupplierUserId
        req.addParameter('supplierAccountId', supplierId + 'test');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('false', v_results.v_success);
        System.assertEquals('Invalid user ID', v_results.v_message);
        req.addParameter('supplierAccountId', supplierId);

        req.addParameter('supplierAccountId', '');
        // end supplier 
        

        //start buyer 
        req.addParameter('buyerAccountId', buyerId);

        //testDoGetBuyer        
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);

        req.addParameter('mapId', mapId);
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        req.addParameter('mapId', '');

        //testDoGetFailInvalidBuyerUser
        req.addParameter('buyerAccountId', '0010T00000GeXFu');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('false', v_results.v_success);
        System.assertEquals('Invalid user', v_results.v_message);
        req.addParameter('buyerAccountId', supplierId);

        //testDoGetFailInvalidBuyerUserId
        req.addParameter('buyerAccountId', supplierId + 'test');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('false', v_results.v_success);
        System.assertEquals('Invalid user ID', v_results.v_message);
        req.addParameter('buyerAccountId', supplierId);

        req.addParameter('buyerAccountId', '');
        //end buyer
        
        // testDoGetOnyWithMap
        req.addParameter('mapId', mapId);
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        req.addParameter('mapId', '');

        //testDoGetFailInvalidMap
        
        req.addParameter('mapId', mapId + 'test');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('false', v_results.v_success);
        System.assertEquals('Invalid supplier buyer map Id', v_results.v_message);
        req.addParameter('mapId', '');

        // testDoGetFailInvalidMarketPlace
        
        req.addParameter('marketplace', marketPlaceId + 'test');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('false', v_results.v_success);
        System.assertEquals('Invalid marketplace Id', v_results.v_message);
        req.addParameter('marketplace', marketPlaceId);
        
        //testDoGetOnyWithMarketPlace

        // test overdue
        req.addParameter('phase', 'inprogress');
        req.addParameter('overdue','true');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        req.addParameter('phase', 'onmarketplace');
        req.addParameter('overdue','');

        // test passthrough
        req.addParameter('phase', 'closed');
        req.addParameter('passthrough','true');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        req.addParameter('phase', 'onmarketplace');
        req.addParameter('passthrough','');

        //testDoGetFailInvalidCurrency
        req.addParameter('ccy', 'VietNamDong');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('false', v_results.v_success);
        System.assertEquals('Invalid currency', v_results.v_message);
        req.addParameter('ccy', 'USD');

        // testDoGetFailInvalidPhase
        req.addParameter('phase', 'onmarketplaceSomeWhere');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('false', v_results.v_success);
        System.assertEquals('Invalid phase', v_results.v_message);
        req.addParameter('phase', 'onmarketplace');

        //testDoGetOther
        //

        req.addParameter('overdue', 'false');
        req.addParameter('passthrough', 'false');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        req.addParameter('overdue', '');
        req.addParameter('passthrough', '');

        req.addParameter('supplierApprovalStatus', 'Approved');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        req.addParameter('supplierApprovalStatus', '');

        req.addParameter('supplierApprovalStatus', 'anythingButApproved');
        v_results = RestInvoiceList_v9.doGet();
        System.assertEquals('true', v_results.v_success);
        System.assertEquals('Query executed successfully.', v_results.v_message);
        req.addParameter('supplierApprovalStatus', '');

        Test.stopTest();

    }
}