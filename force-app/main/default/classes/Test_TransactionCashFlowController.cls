@IsTest
public class Test_TransactionCashFlowController {
    
    @isTest
    private static void TestInit(){
        Map<String, Object> result = SeedTest.init(null, null, 'funded repaid');
        insert SeedTest.createConfiguration('Tranche_Account_For_Fx_Contract','ZAW;Funder');
        
        Test.startTest();
        TransactionCashFlowController controller = new TransactionCashFlowController();
        controller.getItems();
        Test.stopTest();
        
    }
    
    @isTest
    private static void TestInitEUR(){
        Map<String, Object> result = SeedTest.init(null, 'EUR', 'funded repaid');
        insert SeedTest.createConfiguration('Tranche_Account_For_Fx_Contract','ZAW;Funder');

        Test.startTest();
        TransactionCashFlowController controller = new TransactionCashFlowController();
        Test.stopTest();
    }

    @isTest
    private static void TestInitGBP(){
        Map<String, Object> result = SeedTest.init(null, 'GBP', 'funded repaid');
        insert SeedTest.createConfiguration('Tranche_Account_For_Fx_Contract','ZAW;Funder');

        Test.startTest();
        TransactionCashFlowController controller = new TransactionCashFlowController();
        Test.stopTest();
    }

    @isTest
    private static void TestSearchNoResult(){
        TransactionCashFlowController controller = new TransactionCashFlowController();
        Test.startTest();
        controller.search();
        Test.stopTest();
    }
    
    @isTest
    private static void TestSearchNoAccount(){
        insert SeedTest.createConfiguration('Tranche_Account_For_Fx_Contract','ZAW;Funder');
        TransactionCashFlowController controller = new TransactionCashFlowController();
        controller.accountName = '';
        Test.startTest();
        controller.search();
        Test.stopTest();
    }
    
    @isTest
    private static void TestSearchNoDate(){
        insert SeedTest.createConfiguration('Tranche_Account_For_Fx_Contract','ZAW;Funder');
        TransactionCashFlowController controller = new TransactionCashFlowController();
        controller.minDate = null;
        Test.startTest();
        controller.search();
        Test.stopTest();
    }
    
    @isTest
    private static void TestOther(){
        insert SeedTest.createConfiguration('Tranche_Account_For_Fx_Contract','ZAW;Funder');
        TransactionCashFlowController controller = new TransactionCashFlowController();
        Test.startTest();
        controller.getprv();
        controller.getnxt();
        controller.nextPage();
        controller.prvPage();
        controller.firstPage();
        // controller.endPage();
        Test.stopTest();
    }
}