@isTest
public class CalculateFXContractControllerTest {
    
    private static Map<String, Object> init() {
        Map<String, Object> result = SeedTest.init(null, 'EUR', null);
        CalculateFXContractController.isNeedRunTrigger = true;

        insert SeedTest.createConfiguration('Tranche_Account_For_Fx_Contract','ZAW;Funder');
        
        List<FX_Contract__c> listContract = new List<FX_Contract__c>();
        FX_Contract__c contract1 = new FX_Contract__c();
        contract1.Amount__c = 1600;
        contract1.CCY_Origination__c = 'USD';
        contract1.CCY_Target__c = 'EUR';
        contract1.Origination_Rate__c = 1.98987;
        contract1.Origination_Date__c = Date.newInstance(2021, 07, 14);
        listContract.add(contract1);
        
        FX_Contract__c contract2 = new FX_Contract__c();
        contract2.Amount__c = 500;
        contract2.CCY_Origination__c = 'USD';
        contract2.CCY_Target__c = 'EUR';
        contract2.Origination_Rate__c = 1.98987;
        contract2.Origination_Date__c = Date.newInstance(2021, 07, 14);
        listContract.add(contract2);
        
        FX_Contract__c contract3 = new FX_Contract__c();
        contract3.Amount__c = 5000;
        contract3.CCY_Origination__c = 'USD';
        contract3.CCY_Target__c = 'EUR';
        contract3.Origination_Rate__c = 1.98987;
        contract3.Origination_Date__c = Date.newInstance(2021, 07, 14);
        listContract.add(contract3);
        
        insert listContract;

        result.put('contract1', contract1);
        result.put('contract2', contract2);
        result.put('contract3', contract3);

        return result;
    }
    
    @isTest
    private static void TestInitNotsimulator(){
        
 
        Map<String, Object> result = init();
        String CCY = 'EUR';

        FX_Contract__c targetContract1 = (Fx_Contract__c)result.get('contract1');
        FX_Contract__c targetContract2 = (Fx_Contract__c)result.get('contract2');
        FX_Contract__c targetContract3 = (Fx_Contract__c)result.get('contract3');

        List<Transaction__c> listTransaction = new List<Transaction__c>();
        
        Transaction__c Transaction12 = SeedTest.createTransaction(result, '', 'Funder', CCY, -2000, '01.Invoice Purchase');
        Transaction12.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        listTransaction.add(Transaction12);

        Transaction__c Transaction2 = SeedTest.createTransaction(result, '', 'Funder', CCY, 2000, '04.Invoice Capital Repayment');
        Transaction2.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        listTransaction.add(Transaction2);
        
        Transaction__c Transaction3 = SeedTest.createTransaction(result, '', 'Funder', CCY, -500, '01.Invoice Purchase (Tr)');
        Transaction3.Tranche_amount__c = -100;
        Transaction3.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        Transaction3.FX_Contract__c = targetContract1.Id;
        listTransaction.add(Transaction3);

        Transaction__c Transaction1 = SeedTest.createTransaction(result, '', 'Funder', CCY, -2000, '01.Invoice Purchase');
        Transaction1.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        listTransaction.add(Transaction1);

        
        insert listTransaction;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(targetContract1);        
        //Test
        Test.startTest();
        PageReference pageRef = Page.CalculateFXContract; 
        pageRef.getParameters().put('recordID', String.valueOf(targetContract1.Id));
        Test.setCurrentPage(pageRef);
        CalculateFXContractController dmfce = new CalculateFXContractController(stdController);
        dmfce.getunSelectedValues();
        dmfce.getSelectedValues();
        dmfce.rightselected.clear();
        dmfce.rightselected.add(targetContract1.Name + ' ' + targetContract1.Tranche_Name__c + ' (Amount = ' + targetContract1.Amount__c + ', remain ' +  + targetContract1.Remain_amount__c + ')');
        dmfce.unselectclick();
        dmfce.leftselected.clear();
        dmfce.leftselected.add(targetContract1.Name + ' ' + targetContract1.Tranche_Name__c + ' (Amount = ' + targetContract1.Amount__c + ', remain ' +  + targetContract1.Remain_amount__c + ')');
        dmfce.leftselected.add(targetContract2.Name + ' ' + targetContract2.Tranche_Name__c + ' (Amount = ' + targetContract2.Amount__c + ', remain ' +  + targetContract2.Remain_amount__c + ')');
        dmfce.leftselected.add(targetContract3.Name + ' ' + targetContract3.Tranche_Name__c + ' (Amount = ' + targetContract3.Amount__c + ', remain ' +  + targetContract3.Remain_amount__c + ')');
        dmfce.selectclick();
        dmfce.isSimulation = false;
        dmfce.minDate = Date.newInstance(2010, 01, 01);
        dmfce.maxDate = Date.newInstance(2040, 01, 01);
        dmfce.execute();
        dmfce.recalculateRemainAmount();

        delete listTransaction;
        dmfce.recalculateRemainAmount();

        listTransaction.clear();
        Transaction__c Transaction4 = SeedTest.createTransaction(result, '', 'Funder', CCY, 2000, '04.Invoice Capital Repayment');
        Transaction4.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        listTransaction.add(Transaction4);

        Transaction__c Transaction5 = SeedTest.createTransaction(result, '', 'Funder', CCY, 100, '05.Invoice Discount Amount');
        Transaction5.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        listTransaction.add(Transaction5);

        Transaction__c Transaction6 = SeedTest.createTransaction(result, '', 'Funder', CCY, -8000, '01.Invoice Purchase');
        Transaction6.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        listTransaction.add(Transaction6);
        
        insert listTransaction;
        
        dmfce.execute();
 
        dmfce.unlink();
 
        delete [SELECT Id FROM Transaction__c];
        
        listTransaction.clear();
        Transaction__c Transaction7 = SeedTest.createTransaction(result, '', 'Funder', CCY, -2000, '01.Invoice Purchase');
        Transaction7.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        Transaction7.Tranche_Amount__c = -1600;
        Transaction7.Tranche_Amount_Percentage__c = 80;
        Transaction7.FX_Contract__c = targetContract1.Id;
        listTransaction.add(Transaction7);
        
        insert listTransaction;
        listTransaction.clear();

        Transaction__c Transaction8 = SeedTest.createTransaction(result, '', 'Funder', CCY, 0, '01.Invoice Purchase (Tr)');
        Transaction8.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        Transaction8.Tranche_Amount__c = -400;
        Transaction8.Tranche_Amount_Percentage__c = 20;
        Transaction8.Related_Tranche_Transaction__c = Transaction7.Id;
        Transaction8.FX_Contract__c = targetContract1.Id;
        listTransaction.add(Transaction8);

        Transaction__c Transaction9 = SeedTest.createTransaction(result, '', 'Funder', CCY, 2000, '04.Invoice Capital Repayment');
        Transaction9.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        listTransaction.add(Transaction9);
        
        insert listTransaction;
        
        dmfce.execute();
        dmfce.close();
        Test.stopTest();
    }

    @isTest
    private static void TestRollOver(){
        
 
        Map<String, Object> result = init();
        String CCY = 'EUR';

        FX_Contract__c targetContract1 = (Fx_Contract__c)result.get('contract1');
        FX_Contract__c targetContract2 = (Fx_Contract__c)result.get('contract2');
        FX_Contract__c targetContract3 = (Fx_Contract__c)result.get('contract3');

        List<Transaction__c> listTransaction = new List<Transaction__c>();
        
        Transaction__c Transaction1 = SeedTest.createTransaction(result, '', 'Funder', CCY, -4000, '01.Invoice Purchase');
        Transaction1.Invoice_Allocation__c = SeedTest.getId(result, 'invAllocation');
        listTransaction.add(Transaction1);

        insert listTransaction;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(targetContract1);        
        //Test
        Test.startTest();
        CalculateFXContractController dmfce = new CalculateFXContractController('' + SeedTest.getId(result, 'invoice'), null, CCY, true);
        dmfce.execute();

        Test.stopTest();
    }

    @isTest
    private static void TestUnlink(){
        Map<String, Object> result = init();
        String CCY = 'EUR';

        FX_Contract__c targetContract1 = (Fx_Contract__c)result.get('contract1');
        FX_Contract__c targetContract2 = (Fx_Contract__c)result.get('contract2');
        FX_Contract__c targetContract3 = (Fx_Contract__c)result.get('contract3');

        delete [SELECT Id FROM Transaction__c];
        List<Transaction__c> listTransaction = new List<Transaction__c>();

        ApexPages.StandardController stdController = new ApexPages.StandardController(targetContract1);        
        //Test
        Test.startTest();
        PageReference pageRef = Page.CalculateFXContract; 
        pageRef.getParameters().put('recordID', String.valueOf(targetContract1.Id));
        Test.setCurrentPage(pageRef);
        CalculateFXContractController dmfce = new CalculateFXContractController(stdController);
        dmfce.getunSelectedValues();
        dmfce.getSelectedValues();
        dmfce.rightselected.clear();
        dmfce.rightselected.add(targetContract1.Name + ' ' + targetContract1.Tranche_Name__c + ' (Amount = ' + targetContract1.Amount__c + ', remain ' +  + targetContract1.Remain_amount__c + ')');
        dmfce.unselectclick();
        dmfce.leftselected.clear();
        dmfce.leftselected.add(targetContract1.Name + ' ' + targetContract1.Tranche_Name__c + ' (Amount = ' + targetContract1.Amount__c + ', remain ' +  + targetContract1.Remain_amount__c + ')');
        dmfce.leftselected.add(targetContract2.Name + ' ' + targetContract2.Tranche_Name__c + ' (Amount = ' + targetContract2.Amount__c + ', remain ' +  + targetContract2.Remain_amount__c + ')');
        dmfce.leftselected.add(targetContract3.Name + ' ' + targetContract3.Tranche_Name__c + ' (Amount = ' + targetContract3.Amount__c + ', remain ' +  + targetContract3.Remain_amount__c + ')');
        dmfce.selectclick();
        dmfce.isSimulation = false;
        dmfce.minDate = Date.newInstance(2010, 01, 01);
        dmfce.maxDate = Date.newInstance(2040, 01, 01);
        
        delete [SELECT Id FROM Transaction__c];
        listTransaction.clear();
        Transaction__c Transaction10 = SeedTest.createTransaction(result, '', 'Funder', CCY, -2000, '01.Invoice Purchase');
        Transaction10.Tranche_Amount__c = -2000;
        Transaction10.FX_Contract__c = targetContract1.Id;
        listTransaction.add(Transaction10);
        insert listTransaction;
	
        
        dmfce.unlink();
        
        dmfce.close();

        Invoice_Allocation__c allocation = (Invoice_Allocation__c)result.get('invAllocation');
        CalculateFXContractController.toRunTranche(CCY, new List<Invoice_Allocation__c> {allocation});
        Test.stopTest();
    }
    
    @isTest
    private static void TestInitFailAccount(){
        CalculateFXContractController.isNeedRunTrigger = true;
        FX_Contract__c contract = new FX_Contract__c();
        contract.Amount__c = 100000000;
        contract.CCY_Origination__c = 'USD';
        contract.CCY_Target__c = 'EUR';
        contract.Origination_Rate__c = 1.98987;
        contract.Origination_Date__c = Date.newInstance(2021, 07, 14);
        
        insert contract;

        insert SeedTest.createConfiguration('Tranche_Account_For_Fx_Contract','ZAW;Funder');
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(contract);
        
        //Test
        Test.startTest();
        PageReference pageRef = Page.CalculateFXContract; 
        pageRef.getParameters().put('recordID', String.valueOf(contract.Id));
        Test.setCurrentPage(pageRef);
        CalculateFXContractController dmfce = new CalculateFXContractController(stdController);
        dmfce.execute();
        Test.stopTest();
    }
      
}