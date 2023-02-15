@isTest
private class IncomlendPricing_v3_Buyback_Test
{
    private static @testSetup void setup() {
        SeedTest.initConfiguration();
    }
    
    // @isTest
    // private static void TestInvocable() {
    //     Map<String, Object> result = SeedTest.init();
    //     Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');

    //     Test.startTest();
    //     IncomlendPricing_v3_BuybackInvocable.CreateTransactionsRequest buybackRequest = new IncomlendPricing_v3_BuybackInvocable.CreateTransactionsRequest();
    //     buybackRequest.InvoiceId = invoice.Id;
    //     buybackRequest.buybackDate = System.today();
	// 	List<IncomlendPricing_v3_BuybackInvocable.CreateTransactionsRequest> buybackRequests = new List<IncomlendPricing_v3_BuybackInvocable.CreateTransactionsRequest> {buybackRequest};
	// 	IncomlendPricing_v3_BuybackInvocable.CreateBuybackTransactions(buybackRequests);
    //     Test.stopTest();
    // }

    @isTest
    private static void TestDoPostBuyback()
    {
    
        Decimal amount = 1000;
        Map<String, Object> result = SeedTest.init('', 'USD', 'agent-funder profitshare funded', amount, null);
        Decimal funded = amount * 0.9;
        Decimal buybacked = funded * 0.7;
        
        User user = SeedTest.createUser(result, 'Mel');
        insert user;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        Invoice_Finance_Deal__c invoice = SeedTest.getInvoice(SeedTest.getId(result, 'invoice'));
        System.assert(invoice != null);
        System.assertEquals('3:IN PROGRESS', invoice.Phase__c);
        // Invoice_Allocation__c buybackAllocation = (Invoice_Allocation__c)result.get('invAllocation');
        Invoice_Allocation__c buybackAllocation = SeedTest.getInvoiceAllocation(SeedTest.getId(result, 'invoice'))[0];
        System.assert(buybackAllocation != null);
        System.debug('Invoice detail ' + Pattern.compile('(.{200})').matcher(JSON.serialize(invoice)).replaceAll('$1\n'));
        System.debug('Allocation detail ' + Pattern.compile('(.{200})').matcher(JSON.serialize(buybackAllocation)).replaceAll('$1\n'));
        
        System.runAs(user){
            
            for (String name :result.keySet()) {
                if (name.indexOf('transaction') == 0) {
                    Transaction__c trn = (Transaction__c)result.get(name);
                    System.debug('Transaction detail ' + trn);
                } else if (name.indexOf('account') == -1 && name.indexOf('bankAccount') == -1 && name.indexOf('wallet') == -1 && name.indexOf('eWalletTrustee') == -1 
                        && name.indexOf('rate') == -1 && name.indexOf('marketplace') == -1 && name.indexOf('incomlendProduct') == -1 && name.indexOf('mProduct') == -1 ) {
                    if (name != 'invoice' && name != 'invAllocation')
                        System.debug(name + ' ' + result.get(name));
                }
            }
            List<configuration__c> listConfiguration = new List<configuration__c>();
            listConfiguration.add(SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_FailAtNegativeeWallets', 'false'));
            listConfiguration.add(SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_IsSimulation', 'true'));
            upsert listConfiguration Name;

            buybackAllocation.Status__c = 'Buyback';
            update buybackAllocation;
            String funderId = 'FunderNew';
            insert SeedTest.createAccount(result, funderId, 'Purchaser');
            insert SeedTest.createBankAccount(result, funderId);
            insert SeedTest.createEWallet(result, funderId, 'USD');
            insert SeedTest.createEWalletTrustee(result, funderId, 'USD');
            insert SeedTest.createTransaction(result, null, funderId, 'USD', buybacked, null);

            Invoice_Allocation__c reservationAllocation = SeedTest.createInvoiceAllocation(result, 'New', '', funderId, 'USD', buybacked, '');
            insert reservationAllocation;

            Test.startTest();

            IncomlendPricing_v3 pricing = new IncomlendPricing_v3(invoice.Id);

            try { 
                Date buybackDate = System.today().addDays(5);
                pricing.BuybackInvoice(buybackDate); 
            } catch (Exception ex) { 
                System.debug('An error occured'); 
                System.debug(ex); 
            }
            
            Test.stopTest();
            
        }
    }
    
    // @isTest
    // private static void TestDoPostHack()
    // {
    //     // Code coverage hack pricing_v3
    //     IncomlendPricing_v3.IncomlendPricing_v3_CoverageHack hack = new IncomlendPricing_v3.IncomlendPricing_v3_CoverageHack();
    //     hack.Hack1();
    // }
    
}