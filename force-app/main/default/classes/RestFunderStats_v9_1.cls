@RestResource(urlMapping='/v9.1/funder/stats/*')

global with sharing class RestFunderStats_v9_1 {
    
    @HttpGet   
    global static GlobalMethods_v9.DecimalMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
        String p_userAccountId = URLParams[URLParams.size()-1];        
        String p_ccy = URLParams[URLParams.size()-2];
        
        map<String,Decimal> v_result = new Map<String,Decimal>();
                
        if(GlobalMethods_v9.isvalidCurrency(p_ccy) == false) {
            return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid currency', null);
        }
        if(GlobalMethods_v9.isValidId(p_userAccountId) == false) {
            return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid User Account Id', null);
        }  
        
        GlobalMethods_v9.AccountReturnClass v_userData = GlobalMethods_v9.getUserData(p_userAccountId);
        if(v_userData.v_success == 'true' && v_userData.v_records.Type == 'Customer' && v_userData.v_records.Sub_type__c == 'Purchaser') {              
                           
            GlobalMethods_v9.AccountReturnClass v_userWalletData = GlobalMethods_v9.getUserWalletData(p_userAccountId);
            
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
            
            AggregateResult[] v_groupedResults3 = [SELECT SUM(funder_discount_amount__c)closedDiscountTotal, SUM(amount__c)closedAllocationTotal, SUM(Total_commission__c)totalFunderCommission FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND CCY__c=:p_ccy AND Status__c IN ('Repaid invoice deal closed') AND Invoice__r.phase__C IN ('4:CLOSED')];
            for(AggregateResult ar : v_groupedResults3){
                Decimal v_roi = (Decimal)(0);
                if((Decimal)(ar.get('closedDiscountTotal')) != null && (Decimal)(ar.get('closedAllocationTotal')) != null) {
                    v_roi = (((Decimal) ar.get('closedDiscountTotal')/(Decimal) ar.get('closedAllocationTotal')).setScale(4))*100;
                }
                v_result.put('roi', v_roi);
                v_result.put('closedAllocationTotal', (Decimal)(ar.get('closedAllocationTotal')));
                v_result.put('totalFunderCommission', (Decimal)(ar.get('totalFunderCommission')));
            }
               
            return new GlobalMethods_v9.DecimalMapReturnClass('true', 'Query executed successfully.', v_result);
        
        }else {
            return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid User', null);
        }
    }

}