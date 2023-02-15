@isTest
public class GlobalTriggerHandlerTest {
    
    static testMethod void myTest() {
        boolean temp = GlobalTriggerHandler.isNeedRunTrigger;
        GlobalTriggerHandler.isNeedRunTrigger = false;
        
        Map<String, Object> result = SeedTest.init(null, null, null);
        Account buyer = (Account)result.get('accountBuyer');
        Account supplier = (Account)result.get('accountSupplier');
        Account funder = (Account)result.get('accountFunder');
        Invoice_allocation__c allocation = (Invoice_allocation__c)result.get('invAllocation');
        Invoice_finance_deal__c invoice = (Invoice_finance_deal__c)result.get('invoice');
        Supplier_Buyer_Map__c supplierBuyerMap = (Supplier_Buyer_Map__c)result.get('map');
 
        Account accountAgent = SeedTest.createAccount(result, 'Agent', 'Agent');
        insert accountAgent;

        User user = SeedTest.createUser(result, 'Mel');
        insert user;

        supplierBuyerMap.Insurance_Premium_Logic__c = 'Invoice based';
        supplierBuyerMap.Insurance_cost_for_Supplier__c = 0.3;
        supplierBuyerMap.Agent_s_fee_type__c = null;
        supplierBuyerMap.Value_of_agent_s_fee__c = null;
        update supplierBuyerMap;

        List<Account> listAccount = new List<Account>(); 
        buyer.Insured_by__c = 'Atradius';
        listAccount.add(buyer);
        supplier.Agent__c = accountAgent.Id;
        supplier.Sales_Owner__c = user.Id;
        listAccount.add(supplier);
        funder.Agent__c = accountAgent.Id;
        listAccount.add(funder);
        update listAccount;

        accountAgent.Account_Agent_s_Type__c = 'Fixed';
        accountAgent.Value_of_agent_s_fee__c = 3;
        update accountAgent;
        
        Dynamic_SDR__c dynamicSdr = new Dynamic_SDR__c();
        dynamicSdr.Type__c = 'SOFR';
        dynamicSdr.SOFR_Rate_Fixing__c = 2;
        insert dynamicSdr;

        Test.startTest();
        GlobalTriggerHandler.isNeedRunTrigger = true;

        Map<Id, Account> mapAccount = GlobalTriggerHandler.getAccountUpdateMap(new List<Supplier_Buyer_Map__c> { supplierBuyerMap });
        supplierBuyerMap = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Supplier_Buyer_Map__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Supplier_Buyer_Map__c');
        supplierBuyerMap.Trustee__c = null;
        GlobalTriggerHandler.insertMap(supplierBuyerMap, mapAccount);
        GlobalTriggerHandler.updateMap(supplierBuyerMap);

        GlobalTriggerHandler.updateAllocation(allocation);
        //allocation = [SELECT FIELDS(ALL) FROM Invoice_allocation__c]; 
        allocation = Database.query('SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Invoice_allocation__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Invoice_allocation__c');
        GlobalTriggerHandler.calculateAllocationFees(allocation);
        allocation.Applied_Funder_Discount_Profit_Share_Pct__c = null;
        allocation.Applied_MPR__c = null;
        GlobalTriggerHandler.calculateAllocationFees(allocation);

        GlobalTriggerHandler.isNeedRunTrigger = false;
        update supplierBuyerMap;
        invoice.Phase__c = '4:CLOSED';
        invoice.Status__c = 'Paid';
        update invoice; // to update map's First_Invoice_Funded__c
        GlobalTriggerHandler.isNeedRunTrigger = true;
        Map<Id, Supplier_Buyer_Map__c> mapMap = GlobalTriggerHandler.getMapUpdateInvoice(new List<Invoice_finance_deal__c> { invoice });
        Invoice_finance_deal__c oldInvoice = null;
        invoice.Insured_by__c = null;
        invoice.Incomlend_product_del__c = null;
        invoice.FX_Rate__c = SeedTest.getId(result, 'rateUSD');
        GlobalTriggerHandler.insertInvoice(invoice, mapMap.get(supplierBuyerMap.Id));
        GlobalTriggerHandler.calculateExpectedPaymentDate(invoice, oldInvoice, supplierBuyerMap);
        GlobalTriggerHandler.updateInvoice(invoice, oldInvoice, mapMap.get(supplierBuyerMap.Id));

        supplierBuyerMap.Floating_Rate_Margin__c = 10;
        supplierBuyerMap.Funding_Spread__c = 1.6;
        GlobalTriggerHandler.updateFloatingRate(invoice, supplierBuyerMap);

        Test.stopTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        insert new configuration__c[] { 
            SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_WebServiceCallout_Endpoint','http://a.nu'),
            SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_WebServiceCallout_ApiKey','a'),
            SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_Notification_Endpoint','http://a.nu'),
            SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_Notification_ApiKey','a'),
            SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_Notification_Atradius','a@slack.com') };
        GlobalTriggerHandler.sendEmail(new List<String>{'mel.k@yopmail.com'}, 'test', 'error occur');
        GlobalTriggerHandler.getConfiguration('notificationAtradius');
        GlobalTriggerHandler.getConfiguration('salesforceEndpoint');
        GlobalTriggerHandler.getConfiguration('salesforceApiKey');

        GlobalTriggerHandler.OutError('test', new Helper_Log());

        System.debug('Atradius_Last_Full_Scan = ' + GlobalTriggerHandler.getMetadataSetting('Atradius_Last_Full_Scan', DateTime.class));
        GlobalTriggerHandler.putMetadataSetting('Atradius_Last_Full_Scan', DateTime.now());

        GlobalTriggerHandler.setConfigFuture('IncomlendPricing_v3_Behaviour_Notification_Atradius','b@slack.com');
        GlobalTriggerHandler.getHash('abc');

        System.debug(GlobalTriggerHandler.getBaseUrl());
        GlobalTriggerHandler.coalesce((Date)null, (Date)null);
        GlobalTriggerHandler.coalesce((integer)null);
        GlobalTriggerHandler.coalesce((integer)null, 0);
        GlobalTriggerHandler.coalesce((decimal)null);
        GlobalTriggerHandler.coalesce((decimal)null, 0.0);
        GlobalTriggerHandler.coalesce((string)null);
        GlobalTriggerHandler.coalesce((string)null, '');
        GlobalTriggerHandler.getHtmlBody('abc');
    }
}