public class Accounting_Period
{
    
    @InvocableMethod
    public static list<id> lookup(list<date> p_dates)
    {
        list<id> v_a_ids = new list<id>();
        for(date d : p_dates)
            {
                v_a_ids.add(lookup(d) ) ;
            }
        
        return v_a_ids;
    }

   public static ID lookup(date p_date)
       {
         
       return [select id from accounting_period__c where start_date__C <=:p_date and end_date__C >=:p_date].get(0).id ;
       
       }
   
   
}