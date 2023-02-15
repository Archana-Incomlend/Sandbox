@isTest
public class CalculateTargetFinanceControllerTest {
    
    private static Map<String, Object> init() {
        Map<String, Object> result = SeedTest.init(null, null, 'funded');

        CalculateTargetFinanceController.isNeedRunTrigger = true;
        GlobalTriggerHandler.IsNeedRunTrigger = true; // keep Sales_Owner__c utd
        
        User user = SeedTest.createUser(result, 'Mel');
        insert user;

        Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        Account supplier = (Account)result.get('accountSupplier');
        supplier.Sales_Owner__c = user.Id; 
        update supplier;
        update (Supplier_Buyer_Map__c)result.get('map');
        
        Target_financing_month__c targetFinance = new Target_financing_month__c();
        result.put('targetFinance', targetFinance);
        targetFinance.Sales__c = user.Id;
        targetFinance.Start_Date__c = System.today();
        targetFinance.End_Date__c = System.today();

        return result;
    }
    
    @isTest
    private static void TestCalculateSingleInsertInvoiceFirst(){
 
        Map<String,Object> result = init();
        Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        Target_financing_month__c targetFinance = (Target_financing_month__c)result.get('targetFinance');
        List<Target_financing_month__c> listTargetFinance = new List<Target_financing_month__c> { targetFinance };

        Test.startTest();
        
        update invoice;
        insert targetFinance;

        Test.stopTest();
        decimal expectedAmount = [SELECT advanced_amount__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].advanced_amount__c;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(targetFinance.Id, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
    }

    @isTest
    private static void TestCalculateSingleInsertTargetFinanceFirst(){
 
        Map<String,Object> result = init();
        Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        Target_financing_month__c targetFinance = (Target_financing_month__c)result.get('targetFinance');
        List<Target_financing_month__c> listTargetFinance = new List<Target_financing_month__c> { targetFinance };


        Test.startTest();
        
        Id userId = targetFinance.Sales__c;
        targetFinance.Sales__c = null;
        insert targetFinance;
        System.assertEquals(0, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
     
        targetFinance.Sales__c = userId;
        update targetFinance;

        decimal expectedAmount = [SELECT advanced_amount__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].advanced_amount__c;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(targetFinance.Id, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
    }

    @isTest
    private static void TestCalculateInvoiceTrigger(){
 
        Map<String,Object> result = init();
        Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        Target_financing_month__c targetFinance = (Target_financing_month__c)result.get('targetFinance');

        Test.startTest();
        
        update invoice;
        insert targetFinance;

        decimal expectedAmount = [SELECT advanced_amount__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].advanced_amount__c;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(targetFinance.Id, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
   
        invoice.advance_send_to_supplier_date__c = System.today().addDays(-1);
        update invoice;
        System.assertEquals(0, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);

        invoice.advance_send_to_supplier_date__c = System.today();
        update invoice;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);

        // invoice.Sales_Owner__c = null;
        Account supplier = (Account)result.get('accountSupplier');
        supplier.Sales_Owner__c = null; 
        update supplier;
        update (Supplier_Buyer_Map__c)result.get('map');
        update invoice;
        System.assertEquals(0, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);

        // invoice.Sales_Owner__c = targetFinance.Sales__c;
        supplier.Sales_Owner__c = targetFinance.Sales__c; 
        update supplier;
        update (Supplier_Buyer_Map__c)result.get('map');
        update invoice;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        
        Invoice_Finance_Deal__c invoiceNew = SeedTest.createInvoice(result, 'New', '', 'USD', 800, 'funded'); 
        invoiceNew.Sales_Owner__c = targetFinance.Sales__c;
        insert invoiceNew;
        decimal expectedAmountNew = [SELECT advanced_amount__c FROM Invoice_finance_deal__c WHERE Id = :invoiceNew.Id].advanced_amount__c;
        System.assertEquals(expectedAmount + expectedAmountNew, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);

        delete invoiceNew;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        Test.stopTest();
        
    }

    @isTest
    private static void TestCalculateAllocationTrigger(){
 
        Map<String,Object> result = init();
        Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        Target_financing_month__c targetFinance = (Target_financing_month__c)result.get('targetFinance');
        
        Test.startTest();
        
        insert targetFinance;
        decimal expectedAmount = [SELECT advanced_amount__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].advanced_amount__c;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(targetFinance.Id, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
   
        expectedAmount = expectedAmount * 0.5;
        Invoice_Allocation__c allocation = (Invoice_Allocation__c) result.get('invAllocation');
        allocation.amount__c = allocation.amount__c * 0.5;
        update allocation; 
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);

        delete allocation;
        System.assertEquals(0, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);

        undelete allocation;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);

        decimal newAllocationAmount = allocation.amount__c;
        expectedAmount = expectedAmount * 2;
        String funderId = 'FunderNew';
        insert SeedTest.createAccount(result, funderId, 'Purchaser');
        insert SeedTest.createBankAccount(result, funderId);
        insert SeedTest.createEWallet(result, funderId, 'USD');
        insert SeedTest.createEWalletTrustee(result, funderId, 'USD');
        insert SeedTest.createTransaction(result, null, funderId, 'USD', newAllocationAmount, null);

        Invoice_Allocation__c allocationNew = SeedTest.createInvoiceAllocation(result, 'New', '', funderId, 'USD', newAllocationAmount, '');
        insert allocationNew;

        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        Test.stopTest();
        
    }
    
    @isTest
    private static void TestCalculateTargetFinanceTrigger(){
 
        Map<String,Object> result = init();
        Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        Target_financing_month__c targetFinance = (Target_financing_month__c)result.get('targetFinance');
        List<Target_financing_month__c> listTargetFinance = new List<Target_financing_month__c> { targetFinance };

        Test.startTest();
        
        update invoice;
        insert targetFinance;
        decimal expectedAmount = [SELECT advanced_amount__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].advanced_amount__c;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(targetFinance.Id, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
        
        Id userId = targetFinance.Sales__c;
        targetFinance.Sales__c = null;
        update targetFinance;
        System.assertEquals(0, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(null, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
        
        targetFinance.Sales__c = userId;
        update targetFinance;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(targetFinance.Id, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
        
        targetFinance.Start_Date__c = System.today().addDays(1);
        update targetFinance;
        System.assertEquals(0, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(null, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
        
        targetFinance.Start_Date__c = System.today();
        update targetFinance;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(targetFinance.Id, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
        
        targetFinance.End_Date__c = System.today().addDays(-1);
        update targetFinance;
        System.assertEquals(0, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(null, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
        
        targetFinance.End_Date__c = System.today();
        update targetFinance;
        System.assertEquals(expectedAmount, [SELECT New_invoice_Value__c FROM Target_financing_month__c WHERE Id = :targetFinance.Id].New_invoice_Value__c);
        System.assertEquals(targetFinance.Id, [SELECT Target_financing__c FROM Invoice_finance_deal__c WHERE Id = :invoice.Id].Target_financing__c);
        

        Test.stopTest();
    }
}