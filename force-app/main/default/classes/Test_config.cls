@isTest
private class Test_config{

@testSetup static void setup() 
        {
        configuration__C newc = new configuration__C();
        newc.name = 'Fq:SL?@PG[c4e>CN';
        newc.value__c = 'E@sE,]T92Vd2md_W';
        insert newc;
        }

static testmethod void test_getConfig()
        {
        string r;
        r= config.getConfig('Fq:SL?@PG[c4e>CN');
        System.assertEquals(r,'E@sE,]T92Vd2md_W');
        
        r = config.getConfig('E@sE,]T92Vd2md_W');
        System.assertEquals(r,'key not found');
        }
}