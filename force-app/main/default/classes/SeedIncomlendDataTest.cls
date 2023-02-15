@isTest(SeeAllData=true)
public class SeedIncomlendDataTest {
    static testmethod void myTestMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       
        SeedIncomlendData.makeinvoice(1);
        ID v_supplierAccountId = seedincomlenddata.seedAll();
        Supplier_Buyer_Map__c[] maps = [SELECT Id, Name FROM Supplier_Buyer_Map__c WHERE Supplier__r.Name IN ('Incomlend - Test Fees', 'Incomlend Test Operations', 'Euler Hermes Test', 'Incomlend - Test Agent', 'Mom & Pop SME Test', 'Big Buyer International Test', 'Mr Deep Pockets Test')]; 
        try {
            delete maps;
        } catch (DmlException e) {
           
        }
        Account[] doomedAccts = [SELECT Id, Name FROM Account WHERE Name IN ('Incomlend - Test Fees', 'Incomlend Test Operations', 'Euler Hermes Test', 'Incomlend - Test Agent', 'Mom & Pop SME Test', 'Big Buyer International Test', 'Mr Deep Pockets Test')]; 
        try {
            delete doomedAccts;
        } catch (DmlException e) {
           
        }
        
        ID v_userAccountId =  SeedIncomlendData.makeBankAccount();
        maps = [SELECT Id, Name FROM Supplier_Buyer_Map__c WHERE Supplier__r.Name IN ('Incomlend - Test Fees', 'Incomlend Test Operations', 'Euler Hermes Test', 'Incomlend - Test Agent', 'Mom & Pop SME Test', 'Big Buyer International Test', 'Mr Deep Pockets Test')]; 
        try {
            delete maps;
        } catch (DmlException e) {
           
        }
        doomedAccts = doomedAccts = [SELECT Id, Name FROM Account WHERE Name IN ('Incomlend - Test Fees', 'Incomlend Test Operations', 'Euler Hermes Test', 'Incomlend - Test Agent', 'Mom & Pop SME Test', 'Big Buyer International Test', 'Mr Deep Pockets Test')]; 
        try {
            delete doomedAccts;
        } catch (DmlException e) {
           
        }
        
        String v_email= 'testsupplier1@gmail.com';
        seedincomlenddata.seedContactAll(v_email);
         maps = [SELECT Id, Name FROM Supplier_Buyer_Map__c WHERE Supplier__r.Name IN ('Incomlend - Test Fees', 'Incomlend Test Operations', 'Euler Hermes Test', 'Incomlend - Test Agent', 'Mom & Pop SME Test', 'Big Buyer International Test', 'Mr Deep Pockets Test')]; 
        try {
            delete maps;
        } catch (DmlException e) {
           
        }
        doomedAccts = doomedAccts = [SELECT Id, Name FROM Account WHERE Name IN ('Incomlend - Test Fees', 'Incomlend Test Operations', 'Euler Hermes Test', 'Incomlend - Test Agent', 'Mom & Pop SME Test', 'Big Buyer International Test', 'Mr Deep Pockets Test')]; 
        try {
            delete doomedAccts;
        } catch (DmlException e) {
           
        }
        
        ID v_agentAccountId = seedincomlenddata.SeedIncomlendAccounts();
        ID v_USDMarketplace = seedincomlenddata.SeedProducts();
        ID v_supplierAccountId1 = seedincomlenddata.SeedTestAccounts(v_agentAccountId, v_USDMarketplace); 
        ID v_userContactId = seedincomlenddata.createSupplierContact(v_supplierAccountId1);        
        ID v_invoiceID = seedincomlenddata.makeInvoiceSupplier(1, v_supplierAccountId1);
        ID v_xxxInvoiceID = seedincomlenddata.makeXXXInvoice(v_supplierAccountId1);
        ID v_funderAccountId = seedincomlenddata.SeedTestFunderAccounts(v_agentAccountId, v_USDMarketplace);
        Id v_banckAccountId = seedincomlenddata.makeBankAcccountFunder(v_funderAccountId);

           
        seedincomlenddata.createTransactions(v_agentAccountId, '061.Agent Commission on Transaction Fee');
        seedincomlenddata.createTransactions(v_agentAccountId, '051.Agent Commission on Discount Amount');
        seedincomlenddata.makeAllocation(v_supplierAccountId1, v_funderAccountId);
        
        ID v_contactId = seedincomlenddata.createFunderContact(v_funderAccountId);
    }
}