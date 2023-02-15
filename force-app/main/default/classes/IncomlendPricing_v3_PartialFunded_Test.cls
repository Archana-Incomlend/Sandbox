@isTest
private class IncomlendPricing_v3_PartialFunded_Test
{
    private static @testSetup void setup() {
        SeedTest.initConfiguration();
    }
    
    // @isTest
    // private static void TestInvocable() {
    //     Map<String, Object> result = SeedTest.init();
    //     Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');

    //     Test.startTest();
    //     IncomlendPricing_v3_PartialFundedInvocbl.CreateTransactionsRequest partialfundedRequest = new IncomlendPricing_v3_PartialFundedInvocbl.CreateTransactionsRequest();
    //     partialfundedRequest.InvoiceId = invoice.Id;
    //     partialfundedRequest.partialfundedDate = System.today();
	// 	List<IncomlendPricing_v3_PartialFundedInvocbl.CreateTransactionsRequest> partialfundedRequests = new List<IncomlendPricing_v3_PartialFundedInvocbl.CreateTransactionsRequest> {partialfundedRequest};
	// 	IncomlendPricing_v3_PartialFundedInvocbl.CreatePartialFundedTransactions(partialfundedRequests);
    //     Test.stopTest();
    // }

    @isTest
    private static void TestDoPostPartialFunded()
    {
    
        Decimal amount = 10000;
        Map<String, Object> result = SeedTest.init(null, null, null, amount, null);
        Decimal funded = amount * 0.9;
        Decimal partialfunded = funded * 0.7;
        
        User user = SeedTest.createUser(result, 'Mel');
        insert user;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        Invoice_Finance_Deal__c invoice = SeedTest.getInvoice(SeedTest.getId(result, 'invoice'));
        System.assert(invoice != null);
        System.debug('Invoice detail ' + Pattern.compile('(.{200})').matcher(JSON.serialize(invoice)).replaceAll('$1\n'));
        // Invoice_Allocation__c partialfundedAllocation = (Invoice_Allocation__c)result.get('invAllocation');
        Invoice_Allocation__c partialfundedAllocation = SeedTest.getInvoiceAllocation(SeedTest.getId(result, 'invoice'))[0];
        System.assert(partialfundedAllocation != null);
        partialfundedAllocation.amount__c = partialfunded;
        update partialfundedAllocation;
        
        List<configuration__c> listConfiguration = new List<configuration__c>();
        listConfiguration.add(SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_IsSimulation', 'true'));
        upsert listConfiguration Name;

        System.runAs(user){
            
            Test.startTest();

            IncomlendPricing_v3 pricing = new IncomlendPricing_v3(invoice.Id);

            try { 
                pricing.PartialFundedInvoice(System.today()); 
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