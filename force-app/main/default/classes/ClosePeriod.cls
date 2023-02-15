global class ClosePeriod implements Database.Batchable<sObject>
{
global final String query;
global final id RT  = [select id , name from recordtype where name = 'Closed Period'].get(0).id;

    global ClosePeriod (string p_period) {
        query = 'select RecordTypeid, id , accounting_period__c, effective_date__c from Transaction__c where accounting_period_calculated__c = \'' + p_period + '\'';
     //   RT = [select id , name from recordtype where name = 'Closed Period'].get(0).id;
   }
     

global Database.querylocator start(Database.BatchableContext BC){
  return Database.getQueryLocator(query);
  }


   public void execute(Database.BatchableContext BC, List<Transaction__c> Transactions)
   {
         for(Transaction__c t : Transactions ) 
         { 
         t.RecordTypeid = RT;
         }
         update Transactions;
   }
   
   global void finish(Database.BatchableContext BC){
    }
   
}