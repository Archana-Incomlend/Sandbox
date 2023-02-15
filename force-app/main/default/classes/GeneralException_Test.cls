@isTest(seeAllData = false) 
private class GeneralException_Test{
    private static testmethod void loggerTest(){
        Test.startTest();
        try {
             throw new GeneralException('test');
             }catch (Exception ex) {
                 System.debug('Exception');
             }
        Test.stopTest();
    }
}