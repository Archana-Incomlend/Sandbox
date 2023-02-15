@isTest
public class Test_configuration_update_setting {
    
    @isTest
    private static void TestConfiguration(){
        Map<String, Id> result = new Map<String,Id>();
        
        configuration__c c = new configuration__c();
        c.Name = 'IncomlendPricing_v3_Behaviour_CapEarlyPayment';
        c.value__c = '16';
        insert c;
        c.value__c = '15';
        update c;

        System.debug(Incomlend_Custom_Settings__c.getInstance());
    }

}