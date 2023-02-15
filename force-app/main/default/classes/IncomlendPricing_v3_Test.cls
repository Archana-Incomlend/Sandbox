@isTest
private class IncomlendPricing_v3_Test
{
    public static boolean bypassFailFast = false;

    private static @testSetup void setup() {
        SeedTest.initConfiguration();
    }
    
    private static void executePricing(Map<String, Object> result, boolean repaidSimulation, String special) {
        User user = SeedTest.createUser(result, 'Mel');
        insert user;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        String invoiceId = SeedTest.getId(result, 'invoice');
        Invoice_Finance_Deal__c invoice = SeedTest.getInvoice(invoiceId);
        System.assert(invoice != null);
        //System.debug('Response Invoice ' + invoice);
        System.debug('Response Invoice ' + Pattern.compile('(.{200})').matcher(JSON.serialize(invoice)).replaceAll('$1\n'));

        for (Invoice_Allocation__c allocation : SeedTest.getInvoiceAllocation(invoiceId)) {
            // System.debug('Response Allocation ' + allocation);
            System.debug('Response Allocation ' + Pattern.compile('(.{200})').matcher(JSON.serialize(allocation)).replaceAll('$1\n'));
        }
        
        System.runAs(user){
            IncomlendPricing_v3 pricing = new IncomlendPricing_v3(invoiceId);
            if (special != null) pricing.Logs.log('params ' + special, 1, Helper_Log.Color.Black);
            
            Test.startTest();
            RollupUtility.isNeedRunTrigger = true;
            boolean fundSuccess = pricing.FundInvoice();
            if (bypassFailFast && !fundSuccess) { Test.stopTest(); return; }
            RollupUtility.isNeedRunTrigger = false;
            invoice = [SELECT ID, Phase__c From Invoice_Finance_Deal__c WHERE Id =: invoiceId];
            System.assertEquals('3:IN PROGRESS', invoice.Phase__c);
            
            if (repaidSimulation) {
                //  issue with too many SOQL
                upsert SeedTest.createConfiguration('IncomlendPricing_v3_Behaviour_IsSimulation', 'true') Name;
            }
            if (special.indexOf('buyback') != -1 || special.indexOf('partial-fund') != -1 ) addUpdateAllocation(result, special, pricing);
            boolean success = false;
            RollupUtility.isNeedRunTrigger = true;
            pricing.Logs = new Helper_Log(); // pricing = new IncomlendPricing_v3(invoiceId);
            success = pricing.CloseInvoice(); 
            System.debug('invoice ' + Pattern.compile('(.{200})').matcher(JSON.serialize(pricing.Invoice)).replaceAll('$1\n'));
            RollupUtility.isNeedRunTrigger = false;
            if ((!bypassFailFast || success) && special.indexOf('+') == -1) {
                if (!repaidSimulation) {
                    invoice = [SELECT ID, Phase__c From Invoice_Finance_Deal__c WHERE Id =: invoiceId];
                    System.assertEquals('4:CLOSED', invoice.Phase__c);
                } else {
                    System.assert(success);
                }
            }
            
            Test.stopTest();   
        }
    }

    private static void addUpdateAllocation(Map<String, Object> result, String special, IncomlendPricing_v3 pricing) {
        System.debug('Seed add update allocation');
        Date addUpdateAllocationDate = SeedTest.addUpdateAllocation(result, special);
        pricing.Logs = new Helper_Log();
        RollupUtility.isNeedRunTrigger = true;
        boolean success = pricing.AddUpdateAllocation(addUpdateAllocationDate); 
        RollupUtility.isNeedRunTrigger = false;
        if (pricing.InvoiceBuybackCopyAllocation != null) {
            // System.debug('buyback copy Allocation ' + pricing.InvoiceBuybackCopyAllocation);
            System.debug('buyback copy allocation ' + Pattern.compile('(.{200})').matcher(JSON.serialize(pricing.InvoiceBuybackCopyAllocation)).replaceAll('$1\n'));
        }
        if (!bypassFailFast) System.assert(success);
    }

    @isTest
    private static void TestDoPost()
    { 
        String special = '';
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    public static String[] listTest = new String[] { 
        // 'installment-insurance installment-membership tax'
        // ,'installment-maintenance credit-insurance tax'
        // ,'agent-funder-360 agent-supplier platform-fee'
        // ,'profitshare prepayment tax'
        // // ,'profitshare early'
        // ,'profitshare agent-funder agent-supplier early past-cap prepayment'
        // // ,'profitshare overdue'
        // ,'profitshare agent-funder agent-supplier overdue past-cap prepayment'
        // ,'early agent-supplier profitshare tax'
        // ,'overdue profitshare agent-funder tax'
        // // ,'no-deposit'
        // ,'no-deposit early'
        // // ,'with-deposit'
        // ,'with-deposit overdue past-cap'
        // // ,'with-factory'
        // ,'with-factory upfront overdue'
        // ,'volofin early'
        // ,'in-transit overdue'
        // ,'profitshare agent-funder buyback-partial'
        // ,'profitshare agent-funder partial-fund'
    };

    @isTest
    private static void TestDoPost0()
    {
        if (listTest.size() < 1 + 0) return;
        String special = listTest.get(0);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost1()
    {
        if (listTest.size() < 1 + 1) return;
        String special = listTest.get(1);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost2()
    {
        if (listTest.size() < 1 + 2) return;
        String special = listTest.get(2);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost3()
    {
        if (listTest.size() < 1 + 3) return;
        String special = listTest.get(3);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost4()
    {
        if (listTest.size() < 1 + 4) return;
        String special = listTest.get(4);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost5()
    {
        if (listTest.size() < 1 + 5) return;
        String special = listTest.get(5);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost6()
    {
        if (listTest.size() < 1 + 6) return;
        String special = listTest.get(6);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost7()
    {
        if (listTest.size() < 1 + 7) return;
        String special = listTest.get(7);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost8()
    {
        if (listTest.size() < 1 + 8) return;
        String special = listTest.get(8);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost9()
    {
        if (listTest.size() < 1 + 9) return;
        String special = listTest.get(9);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost10()
    {
        if (listTest.size() < 1 + 10) return;
        String special = listTest.get(10);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost11()
    {
        if (listTest.size() < 1 + 11) return;
        String special = listTest.get(11);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost12()
    {
        if (listTest.size() < 1 + 12) return;
        String special = listTest.get(12);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost13()
    {
        if (listTest.size() < 1 + 13) return;
        String special = listTest.get(13);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost14()
    {
        if (listTest.size() < 1 + 14) return;
        String special = listTest.get(14);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost15()
    {
        if (listTest.size() < 1 + 15) return;
        String special = listTest.get(15);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost16()
    {
        if (listTest.size() < 1 + 16) return;
        String special = listTest.get(16);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost17()
    {
        if (listTest.size() < 1 + 17) return;
        String special = listTest.get(17);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost18()
    {
        if (listTest.size() < 1 + 18) return;
        String special = listTest.get(18);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    @isTest
    private static void TestDoPost19()
    {
        if (listTest.size() < 1 + 19) return;
        String special = listTest.get(19);
        Map<String, Object> result = SeedTest.init(null, null, special);  
        executePricing(result, true, special);
    }

    // @isTest
    // private static void TestInvocable() {
    //     Test.startTest();
    //     String invoiceId = 'a090T000002UoAU'; // random, method will try catch not found error, as long as past coverage
    //     IncomlendPricing_v3_FundingInvocable.CreateTransactionsRequest fundingRequest = new IncomlendPricing_v3_FundingInvocable.CreateTransactionsRequest();
    //     fundingRequest.InvoiceId = invoiceId;
    //  List<IncomlendPricing_v3_FundingInvocable.CreateTransactionsRequest> fundingRequests = new List<IncomlendPricing_v3_FundingInvocable.CreateTransactionsRequest> {fundingRequest};
    //  IncomlendPricing_v3_FundingInvocable.CreateFundingTransactions(fundingRequests);
        
    //     IncomlendPricing_v3_AddAllocationInvocbl.CreateTransactionsRequest updateRequest = new IncomlendPricing_v3_AddAllocationInvocbl.CreateTransactionsRequest();
    //     updateRequest.InvoiceId = invoiceId;
    //  List<IncomlendPricing_v3_AddAllocationInvocbl.CreateTransactionsRequest> updateRequests = new List<IncomlendPricing_v3_AddAllocationInvocbl.CreateTransactionsRequest> {updateRequest};
    //  IncomlendPricing_v3_AddAllocationInvocbl.AddAllocationTransactions(updateRequests);
        
    //     IncomlendPricing_v3_ClosingInvocable.CreateTransactionsRequest closingRequest = new IncomlendPricing_v3_ClosingInvocable.CreateTransactionsRequest();
    //     closingRequest.InvoiceId = invoiceId;
    //  List<IncomlendPricing_v3_ClosingInvocable.CreateTransactionsRequest> closingRequests = new List<IncomlendPricing_v3_ClosingInvocable.CreateTransactionsRequest> {closingRequest};
    //  IncomlendPricing_v3_ClosingInvocable.CreateClosingTransactions(closingRequests);
    //     Test.stopTest();
    // }

    // @isTest
    // private static void TestDoPostMockProd()
    // {
    //     // 017938 017804 018601 018228 018608 018377 019123 018898-buyback
    //     String special = '';
    //     Map<String, Object> result = SeedTest.init(null, null, special);
    //     executePricing(result, true, special); 
    // }

}