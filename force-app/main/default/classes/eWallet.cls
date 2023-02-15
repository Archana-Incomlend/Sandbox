public class eWallet
{
    
    @InvocableMethod
    public static list<id> lookup(list<Ewallet__c> ew)
    {
        list<id> ews = new list<id>();
        ews.add(lookup(ew.get(0).ccy__c, ew.get(0).account__c) );
        return ews;
    }

   public static ID lookup(string p_ccy, id p_account)
       {
       list<Ewallet__c> ews = new list<Ewallet__c>();       
       ews = [select id from eWallet__c where account__c=:p_account and ccy__c =:p_ccy];
       if (ews.isEmpty())
       {
       return create(p_ccy, P_account);
       }
       else
       {
       return ews.get(0).id;
       }
       
       }
   
   public static ID create(string p_ccy, id p_account)
        {           
         ewallet__c ew = new ewallet__c();
         ew.account__c = p_account;
         ew.ccy__c = p_ccy;
         
         string v_platformAccount = 'Platform - ' + p_ccy;
         ew.bank_account__c = [select id from bank_account__c where name =:v_platformAccount].get(0).id;
         ew.Marketplace_for_FX__c = [select id from marketplace__c where currency__c =:p_ccy].get(0).id;
         insert ew;
         
         account a = [select id , EUR_eWallet__c, XXX_eWallet__c  , HKD_eWallet__c , SGD_eWallet__c , USD_eWallet__c  from account where id=:p_account].get(0);
         
         if      (p_ccy == 'USD') {a.USD_eWallet__c = ew.id;}
         else if (p_ccy == 'SGD') {a.SGD_eWallet__c = ew.id;}
         else if (p_ccy == 'HKD') {a.HKD_eWallet__c = ew.id;}
         else if (p_ccy == 'EUR') {a.EUR_eWallet__c = ew.id;}
         else if (p_ccy == 'XXX') {a.XXX_eWallet__c = ew.id;}
         update a;
         
         return ew.id;
        }
}