@RestResource(urlMapping='/v8.2/funder/stats/*')

global with sharing class RestFunderStats_v8_2 {
    
    @HttpGet   
    global static GlobalMethods.DecimalMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
        String p_userAccountId = URLParams[URLParams.size()-1];        
        String p_ccy = URLParams[URLParams.size()-2];
        
        map<String,Decimal> v_result = new Map<String,Decimal>();
                
        if(GlobalMethods.isvalidCurrency(p_ccy) == false) {
            return new GlobalMethods.DecimalMapReturnClass('false','Invalid currency', null);
        }
        if(GlobalMethods.isValidId(p_userAccountId) == false) {
            return new GlobalMethods.DecimalMapReturnClass('false','Invalid User Account Id', null);
        }  
        
        GlobalMethods.AccountReturnClass v_userData = GlobalMethods.getUserData(p_userAccountId);
        if(v_userData.v_success == 'true' && v_userData.v_records.Type == 'Customer' && v_userData.v_records.Sub_type__c == 'Purchaser') {              
                           
            GlobalMethods.AccountReturnClass v_userWalletData = GlobalMethods.getUserWalletData(p_userAccountId);
            
            v_result.put('discount_profit_share_percent__c', (Decimal)(v_userData.v_records.discount_profit_share_percent__c));
                
            AggregateResult[] v_groupedResults = [SELECT SUM(funder_discount_amount__c )remainingDiscountTotal FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND Status__c ='Confirmed' AND CCY__c=:p_ccy AND Invoice__r.phase__C = '3:IN PROGRESS'];
            for(AggregateResult ar : v_groupedResults){
                v_result.put('remainingDiscountTotal', (Decimal)(ar.get('remainingDiscountTotal')));
            }
               
            AggregateResult[] v_groupedResults1 = [SELECT SUM(amount__c)inProgreesAllocationTotal FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND CCY__c=:p_ccy AND Status__c IN ('Confirmed') AND Invoice__r.phase__C IN ('3:IN PROGRESS')];
            for(AggregateResult ar : v_groupedResults1){
                v_result.put('inProgreesAllocationTotal', (Decimal)(ar.get('inProgreesAllocationTotal')));
            }
            
            AggregateResult[] v_groupedResults2 = [SELECT SUM(amount__c)onMarketplaceAllocationTotal FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND CCY__c=:p_ccy AND Status__c IN ('Reservation') AND Invoice__r.phase__C IN ('2:ON MARKETPLACE')];
            for(AggregateResult ar : v_groupedResults2){
                v_result.put('onMarketplaceAllocationTotal', (Decimal)(ar.get('onMarketplaceAllocationTotal')));
            }
            
            AggregateResult[] v_groupedResults3 = [SELECT SUM(amount__c)closedAllocationTotal, SUM(Total_commission__c)totalFunderCommission FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND CCY__c=:p_ccy AND Status__c IN ('Repaid invoice deal closed') AND Invoice__r.phase__C IN ('4:CLOSED')];
            for(AggregateResult ar : v_groupedResults3){
                v_result.put('closedAllocationTotal', (Decimal)(ar.get('closedAllocationTotal')));
                v_result.put('totalFunderCommission', (Decimal)(ar.get('totalFunderCommission')));
            }
               
            return new GlobalMethods.DecimalMapReturnClass('true', 'Query executed successfully.', v_result);
        
        }else {
            return new GlobalMethods.DecimalMapReturnClass('false','Invalid User', null);
        }
    }

}