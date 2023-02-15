@isTest(SeeAllData=true)
private class test_ewallet {
    static testmethod void myTest() {
    
    
    ewallet__c ew = new ewallet__C();
    ew.ccy__c = 'XXX';
    
    account a = new account();
    a.name = 'TEST';
    insert a;
    
    ew.account__c = a.id;
    
    list<ewallet__C> ews = new list<ewallet__C>();
    ews.add(ew);
    
    ewallet.lookup(ews);
    
    
    ewallet.lookup(ews);
    
    }
    
    
    
    
    }