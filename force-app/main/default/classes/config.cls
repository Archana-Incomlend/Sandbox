public class config
{
   public static string getConfig(string pkey)
        {           
         configuration__c[] c =  [select value__c from configuration__c where name = :pkey];
         if (c.size() == 0)
             {return 'key not found';}
         else {return c.get(0).value__c;}
        }
}