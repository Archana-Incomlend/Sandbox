@RestResource(urlMapping='/v7.1/marketplace/*')

global with sharing class RestMarketplaceStats_v7_1 {
      
    @HttpGet
    global static GlobalMethods.StringMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        map<String,String> v_result = new Map<String,String>();
        
        String p_marketplaceId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if(GlobalMethods.isValidId(p_marketplaceId) == false) {
           return new GlobalMethods.StringMapReturnClass('false','Invalid Marketplace Id', null);
        }
        
        List<Marketplace__c> v_marketplaceData = [SELECT Name, All_Time_Invoice_Value__c, number_of_defaults__c, days_with_no_defaults__c, all_time_average_discount_rate__c, All_time_funded_Amount__c, all_time_average_invoice_value__c, currency_symbol__c FROM Marketplace__c WHERE Id = :p_marketplaceId];
        if (v_marketplaceData.size() == 0) {
            return new GlobalMethods.StringMapReturnClass('false','Invalid Marketplace Id', null);
        }else {
            v_result.put('Name', String.valueOf(v_marketplaceData.get(0).Name));
            v_result.put('All_Time_Invoice_Value__c', String.valueOf(v_marketplaceData.get(0).All_Time_Invoice_Value__c));
            v_result.put('number_of_defaults__c', String.valueOf(v_marketplaceData.get(0).number_of_defaults__c));
            v_result.put('days_with_no_defaults__c', String.valueOf(v_marketplaceData.get(0).days_with_no_defaults__c));
            v_result.put('all_time_average_discount_rate__c', String.valueOf(v_marketplaceData.get(0).all_time_average_discount_rate__c));
            v_result.put('All_time_funded_Amount__c', String.valueOf(v_marketplaceData.get(0).All_time_funded_Amount__c));
            v_result.put('all_time_average_invoice_value__c', String.valueOf(v_marketplaceData.get(0).all_time_average_invoice_value__c));
            v_result.put('currency_symbol__c', String.valueOf(v_marketplaceData.get(0).currency_symbol__c));
        }
        for(AggregateResult ar : [SELECT phase__C phase, SUM(remaining_amount__c)totalRemaining, SUM(funded_amount__c)totalFunded FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__r.Marketplace__r.Id=:p_marketplaceId GROUP BY phase__C]) {
            String v_phase = (string)(ar.get('phase'));
            v_phase = v_phase.replace(' ', '_');
            v_phase = v_phase.replace(':', '_');
            String v_totalRemaining = String.valueOf(ar.get('totalRemaining'));
            String v_totalFunded = String.valueOf(ar.get('totalFunded'));
            
            v_result.put(v_phase+'_totalRemaining', v_totalRemaining);
            v_result.put(v_phase+'_totalFunded', v_totalFunded);
        }
        return new GlobalMethods.StringMapReturnClass('true', 'Query executed successfully.', v_result);
    }
}