global class UpdateTransactionsWithEWallets implements Database.Batchable<sObject>
{
global String query;

    global UpdateTransactionsWithEWallets(string ccy) {
        query = 'select Effective_Date__c ,accounting_period__c,  ewallet__c, ccy__c, account__c from Transaction__c where (ewallet__c = null or accounting_period__c = null)';
            if (ccy > '' ){
        query = query + ' and ccy__c =\'' + ccy + '\' '  ;
        }
        system.debug(query);
   }
     

global Database.querylocator start(Database.BatchableContext BC){
  return Database.getQueryLocator(query);
  }

   public void execute(Database.BatchableContext BC, List<Transaction__c> Transactions)
   {
        for(Transaction__c  t : Transactions){
        
        if (t.ewallet__c == null){
           List<ewallet__c > ewa = [select id from ewallet__c where account__C =:t.account__c and ccy__c =:t.ccy__c  limit 1];
             if (ewa.isEmpty())
                {
                ewallet__c newEW = new ewallet__c();
                newew.ccy__c = t.ccy__c;
                newew.account__c = t.account__c;
               newew.bank_account__c = [select id from bank_account__c where currency__C = :t.ccy__c and name like '%Platform%' ].get(0).Id;
                newew.Marketplace_for_FX__c = [select id from marketplace__c where currency__c = :t.ccy__c and default_marketplace__c  = true].get(0).id;
                insert newew;
                t.ewallet__C = newew.id;
                }
            else {t.ewallet__C = ewa.get(0).Id;}  
          }
            
           
             if (t.accounting_period__c == null){
            string ap = (t.Effective_Date__c).year() + '-' + t.Effective_Date__c.month().format().leftpad(2,'0');
             
             id p = [select id from accounting_period__c where Name =:ap limit 1].get(0).id;
           t.accounting_period__c = p;
             
             } 
             
            }     
    update Transactions;  
   }
   
   global void finish(Database.BatchableContext BC){
    }
   
}