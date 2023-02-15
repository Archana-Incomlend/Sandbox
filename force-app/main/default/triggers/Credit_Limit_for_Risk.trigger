trigger Credit_Limit_for_Risk on Supplier_Buyer_Map__c (after insert, after update) {
    for( Id mapId : Trigger.newMap.keySet() )
{
    // Do the trigger on when this field is changed
  if( null == Trigger.oldMap || (Trigger.oldMap.get( mapId ).CL_Incomlend_for_this_Map__c  != Trigger.newMap.get( mapId ).CL_Incomlend_for_this_Map__c))
  {
     //Get buyer account details   
     //Sum of credit limit of buyer in all maps   
      Decimal v_result = 0;
      
      AggregateResult[] total_CL_allocated_to_Map = [SELECT Id, SUM(CL_USD_Incomlend_for_this_Map__c)total_CL 
                                           FROM Supplier_Buyer_Map__c 
                                           WHERE Buyer__c = :Trigger.newMap.get( mapId ).Buyer__c 
                                           AND isDeleted = false 
                                           AND general_status_map__c = 'Active'
                                           GROUP BY Id
                                           ];   
      
      for(AggregateResult ar : total_CL_allocated_to_Map){
            v_result += (Decimal)ar.get('total_CL');
        }
      
      // Credit limit of buyer from incomlend limit
      Decimal credit_limit_from_incomlend = [SELECT id, Credit_Limit_from_Incomlend_USD__c
                				FROM Account
                				WHERE id = :Trigger.newMap.get( mapId ).Buyer__c
                				LIMIT 1].Credit_Limit_from_Incomlend_USD__c;
      
     //Display the error message
      if ( v_result > credit_limit_from_incomlend ) {
          Trigger.newMap.get( mapId ).addError(' Risk: Credit Limit breached');
      }
  }
}
}