@isTest(SeeAllData=true)
private class test_Accounting_Period {
    static testmethod void myTest() {
    
    
    Accounting_Period__c ap = new Accounting_Period__C();
    ap.name = '2099-11';
    
    ap.start_date__C = date.newinstance(2099, 11, 1);
    ap.end_date__C = date.newinstance(2099, 11, 31);
    insert ap;
    
    list<date> ds = new list<date>();
    ds.add(date.newinstance(2099, 11, 17) );
    
    Accounting_Period.lookup(ds);
    
    
    }
    
    
    
    
    }