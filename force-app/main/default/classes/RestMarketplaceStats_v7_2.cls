@RestResource(urlMapping='/v7.2/marketplace/*')

global with sharing class RestMarketplaceStats_v7_2 {
      
    @HttpGet
    global static GlobalMethods.StringMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        map<String,String> v_result = new Map<String,String>();
        
        String p_marketplaceId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Decimal v_allTimeAverageDiscountRate = 0;
        Decimal v_allTimeAverageInvoiceValue = 0;
        
        if(GlobalMethods.isValidId(p_marketplaceId) == false) {
           return new GlobalMethods.StringMapReturnClass('false','Invalid Marketplace Id', null);
        }
        
        List<Marketplace__c> v_marketplaceData = [SELECT Name, number_of_defaults__c, days_with_no_defaults__c, currency_symbol__c FROM Marketplace__c WHERE Id = :p_marketplaceId];
        if (v_marketplaceData.size() == 0) {
            return new GlobalMethods.StringMapReturnClass('false','Invalid Marketplace Id', null);
        }else {
            v_result.put('Name', String.valueOf(v_marketplaceData.get(0).Name));
            v_result.put('number_of_defaults__c', String.valueOf(v_marketplaceData.get(0).number_of_defaults__c));
            v_result.put('days_with_no_defaults__c', String.valueOf(v_marketplaceData.get(0).days_with_no_defaults__c));
            v_result.put('currency_symbol__c', String.valueOf(v_marketplaceData.get(0).currency_symbol__c));
        }
        
        for(AggregateResult ar : [SELECT SUM(invoice_amount__c )allTimeInvoiceValue, SUM(discount_rate__c )discountrateSum, COUNT(Id)allTimeInvoiceCount FROM invoice_finance_deal__c WHERE Marketplace_link__c=:p_marketplaceId AND phase__C IN ('2:ON MARKETPLACE', '3:IN PROGRESS', '4:CLOSED')]) {
            Decimal v_allTimeInvoiceCount =  (Decimal)(ar.get('allTimeInvoiceCount'));
            if(v_allTimeInvoiceCount != 0) {
                v_allTimeAverageDiscountRate = (((Decimal)(ar.get('discountrateSum')))/v_allTimeInvoiceCount).setscale(2);
                v_allTimeAverageInvoiceValue = (((Decimal)(ar.get('allTimeInvoiceValue')))/v_allTimeInvoiceCount).setscale(2);
            }
            v_result.put('allTimeAverageDiscountRate', String.valueOf(v_allTimeAverageDiscountRate));
            v_result.put('allTimeAverageInvoiceValue', String.valueOf(v_allTimeAverageInvoiceValue));
            v_result.put('allTimeInvoiceValue', String.valueOf(ar.get('allTimeInvoiceValue')));
            v_result.put('discountrateSum', String.valueOf(ar.get('discountrateSum')));
            v_result.put('allTimeInvoiceCount', String.valueOf(ar.get('allTimeInvoiceCount')));
        }
        
        for(AggregateResult ar : [SELECT SUM(funded_amount__c )allTimeFundedAmount FROM invoice_finance_deal__c WHERE Marketplace_link__c=:p_marketplaceId AND phase__C IN ('3:IN PROGRESS', '4:CLOSED')]) {
            v_result.put('allTimeFundedAmount', String.valueOf(ar.get('allTimeFundedAmount')));
        }        
               
        for(AggregateResult ar : [SELECT phase__C phase, SUM(remaining_amount__c)totalRemaining, SUM(funded_amount__c)totalFunded FROM invoice_finance_deal__c WHERE Marketplace_link__c=:p_marketplaceId GROUP BY phase__C]) {
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