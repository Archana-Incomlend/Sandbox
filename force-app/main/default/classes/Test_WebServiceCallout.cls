// This test class validate WebServiceCallout apex + Account/SupplierBuyerMap/Invoice/EWallet/EWalletTrustee trigger
@isTest()
private class Test_WebServiceCallout {

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'Sample Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
	private static void callWebServiceCallout() {
        Map<String, Object> result = SeedTest.init();
        WebServiceCallout.IsNeedRunTrigger = true;

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();

        Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');

        invoice.Listing_Start__c = Date.today();
        invoice.Listing_End__c = Date.today();
        update invoice;

        WebServiceCallout.notifyInvoiceAllocationRequest('INVOICE', invoice.Name);

        // Execute Account trigger
        Account buyer = (Account)result.get('accountBuyer');
        buyer.overdue_invoice_amount_usd_equiv__c = -20;
        update buyer;

        Supplier_Buyer_Map__c supplierBuyerMap = (Supplier_Buyer_Map__c)result.get('map');
        supplierBuyerMap.map_onboarding_stage__c = '90.Onboarded';
        update supplierBuyerMap;

        WebServiceCallout.notifyInvoiceAllocationRequest('MAP', supplierBuyerMap.Id);

        String funderId = 'Funder';
        eWallet__c eWallet = (eWallet__c)result.get('walletUSD' + funderId);
        eWallet.Balance__c = 100000000;
        update eWallet;

        WebServiceCallout.notifyInvoiceAllocationRequest('EWALLET', eWallet.Name);

        eWallet_Trustee__c eWalletTrustee = (eWallet_Trustee__c)result.get('eWalletTrusteeUSD' + funderId);
        eWalletTrustee.Balance__c = 100000000; // in turn change Available_Balance__c
        update eWalletTrustee;
        // WebServiceCallout.notifyInvoiceAllocationRequest('EWALLET', eWalletTrustee.Main_eWallet__r.Name);

        // Additional test

        Incomlend_product__c incomlendProduct = (Incomlend_product__c)result.get('incomlendProductUSD');
        incomlendProduct.Name = incomlendProduct.Name + ' Reverse';
        update incomlendProduct;

        Account agent = SeedTest.createAccount(result, 'Agent', 'Agent');
        insert agent;

        User user = SeedTest.createUser(result, 'Mel');
        insert user;
        
        Account supplier = (Account)result.get('accountSupplier');
        supplier.Agent__c = agent.Id;
        supplier.Sales_Owner__c = user.Id; 
        update supplier;
        
        buyer.Sales_Owner__c = user.Id; 
        update buyer;

        supplierBuyerMap.Account_transferred_to_Incomlend__c = true;
        update supplierBuyerMap;

        Test.stopTest();

        boolean temp;
        temp = WebServiceCallout.FirstrunAfterAccount;
        temp = WebServiceCallout.FirstrunAfterAccount;
        temp = WebServiceCallout.FirstrunAfterEWallet;
        temp = WebServiceCallout.FirstrunAfterEWallet;
        temp = WebServiceCallout.FirstrunAfterInvoice;
        temp = WebServiceCallout.FirstrunAfterInvoice;
        temp = WebServiceCallout.FirstrunAfterMap;
        temp = WebServiceCallout.FirstrunAfterMap;
        temp = WebServiceCallout.FirstrunAfterEWalletTrustee;
        temp = WebServiceCallout.FirstrunAfterEWalletTrustee;
        WebServiceCallout.resetFirstRun();
    }
}