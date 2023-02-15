@isTest
private class Pageable_Test {

    static testMethod void myTest1() {
        Pageable objPage = new Pageable();
        Integer intIndex = objPage.PageIndex;
        Integer intOffset = objPage.Offset;
        integer intLNumber = objPage.LNumber;
        Integer intUNumber = objPage.UNumber;
        Boolean blnAllowMoveNext = objPage.AllowMoveNext;
        Boolean blnAllowMovePrev = objPage.AllowMovePrev;
        objPage.getRecordCount();
        objPage.movePrev();
        objPage.moveNext();
        objPage.moveLast();
        objPage.moveFirst();
    }
}