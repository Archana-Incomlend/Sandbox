@RestResource(urlMapping='/v9.2/funder/stats')

global with sharing class RestFunderStats_v9_2 {
    
    @HttpGet   
    global static GlobalMethods_v9.DecimalMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
        String p_userAccountId = RestContext.request.params.get('funderAccountId'); 
        String p_ccy = RestContext.request.params.get('ccy');
        String p_trusteeName = null;
        if (RestContext.request.params.get('trustee') != null) {
            p_trusteeName = RestContext.request.params.get('trustee');
        }
        
        map<String,Decimal> v_result = new Map<String,Decimal>();
        Decimal v_availableEwallet;
        Decimal v_utilization = 0;
        Decimal v_inProgreesAllocationTotal;
        Decimal v_allTimeAllocationTotal = 0;
        Decimal v_allTimeUtilization = 0;
        Decimal v_allTimeDeposit = 0;
        Decimal v_allTimeWithdrawal = 0;
                
        if(GlobalMethods_v9.isvalidCurrency(p_ccy) == false) {
            return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid currency', null);
        }
        if(GlobalMethods_v9.isValidId(p_userAccountId) == false) {
            return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid User Account Id', null);
        }  
        
        GlobalMethods_v9.AccountReturnClass v_userData = GlobalMethods_v9.getUserData(p_userAccountId);
        if(v_userData.v_success == 'true' && v_userData.v_records.Type == 'Customer' && v_userData.v_records.Sub_type__c == 'Purchaser') {              
                           
            GlobalMethods_v9.AccountReturnClass v_userWalletData = GlobalMethods_v9.getUserWalletData(p_userAccountId);
            
            try {
                v_availableEwallet = GlobalMethods_v9.getAvailableEwallet(p_userAccountId, p_ccy);
            } catch(GeneralException e) {
                return new GlobalMethods_v9.DecimalMapReturnClass('false',e.getMessage(), null);
            } 
            
            v_result.put('discount_profit_share_percent__c', (Decimal)(v_userData.v_records.discount_profit_share_percent__c));
            
            String v_statsQuery = 'SELECT SUM(funder_discount_amount__c )remainingDiscountTotal FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND Status__c IN (\'Confirmed\') AND CCY__c=:p_ccy AND Invoice__r.phase__C IN (\'3:IN PROGRESS\')';
            
            if(p_trusteeName != null) {
                v_statsQuery = v_statsQuery+' AND Trustee__c =:p_trusteeName';  
            }
            AggregateResult[] v_groupedResults =  database.query(v_statsQuery);
            for(AggregateResult ar : v_groupedResults){
                v_result.put('remainingDiscountTotal', (Decimal)(ar.get('remainingDiscountTotal')));
            }
            
            String v_statsQuery1 = 'SELECT SUM(amount__c)inProgreesAllocationTotal FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND CCY__c=:p_ccy AND Status__c IN (\'Confirmed\') AND Invoice__r.phase__C IN (\'3:IN PROGRESS\')';
            
            if(p_trusteeName != null) {
                v_statsQuery1 = v_statsQuery1+' AND Trustee__c =:p_trusteeName';  
            }
            AggregateResult[] v_groupedResults1 = database.query(v_statsQuery1);
            for(AggregateResult ar : v_groupedResults1){
                if((Decimal)(ar.get('inProgreesAllocationTotal')) != null) {
                     v_inProgreesAllocationTotal = (Decimal)(ar.get('inProgreesAllocationTotal'));
                     v_utilization = (v_inProgreesAllocationTotal/(v_inProgreesAllocationTotal+v_availableEwallet)).setScale(2)*100;
                }
                v_result.put('currentUtilization', v_utilization);
                v_result.put('inProgreesAllocationTotal', (Decimal)(ar.get('inProgreesAllocationTotal')));
            }
            
            String v_statsQuery2 = 'SELECT SUM(amount__c)onMarketplaceAllocationTotal FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND CCY__c=:p_ccy AND Status__c IN (\'Reservation\') AND Invoice__r.phase__C IN (\'2:ON MARKETPLACE\')';
            
            if(p_trusteeName != null) {
                v_statsQuery2 = v_statsQuery2+' AND Trustee__c =:p_trusteeName';  
            }
                
            AggregateResult[] v_groupedResults2 = database.query(v_statsQuery2);
            for(AggregateResult ar : v_groupedResults2){
                v_result.put('onMarketplaceAllocationTotal', (Decimal)(ar.get('onMarketplaceAllocationTotal')));
            }
            
            String v_statsQuery3 = 'SELECT SUM(funder_discount_amount__c)closedDiscountTotal, SUM(amount__c)closedAllocationTotal, SUM(Total_commission__c)totalFunderCommission FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND CCY__c=:p_ccy AND Status__c IN (\'Repaid invoice deal closed\') AND Invoice__r.phase__C IN (\'4:CLOSED\')';
            
            if(p_trusteeName != null) {
                v_statsQuery3 = v_statsQuery3+' AND Trustee__c =:p_trusteeName';  
            }
            AggregateResult[] v_groupedResults3 = database.query(v_statsQuery3);
            for(AggregateResult ar : v_groupedResults3){
                Decimal v_roi = (Decimal)(0);
                if((Decimal)(ar.get('closedDiscountTotal')) != null && (Decimal)(ar.get('closedAllocationTotal')) != null) {
                    v_roi = (((Decimal) ar.get('closedDiscountTotal')/(Decimal) ar.get('closedAllocationTotal'))*100).setScale(2);
                }
                v_result.put('roi', v_roi);
                v_result.put('closedAllocationTotal', (Decimal)(ar.get('closedAllocationTotal')));
                v_result.put('totalFunderCommission', (Decimal)(ar.get('totalFunderCommission')));
            }
            
            String v_statsQuery4 = 'SELECT SUM(amount__c)allTimeAllocationTotal FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND CCY__c=:p_ccy AND Status__c IN (\'Confirmed\', \'Repaid invoice deal closed\') AND Invoice__r.phase__C IN (\'2:ON MARKETPLACE\', \'3:IN PROGRESS\', \'4:CLOSED\')';
                
            if(p_trusteeName != null) {
                v_statsQuery4 = v_statsQuery4+' AND Trustee__c =:p_trusteeName';  
            }    
            AggregateResult[] v_groupedResults4 = database.query(v_statsQuery4);
            for(AggregateResult ar : v_groupedResults4){
                if((Decimal)(ar.get('allTimeAllocationTotal')) != null) {
                    v_allTimeAllocationTotal =  (Decimal)(ar.get('allTimeAllocationTotal'));
                }
            }
            
            String v_statsQuery5 = 'SELECT Type__c transType, SUM(amount__c)allTimeAmount FROM Transaction__c WHERE Account__c=:p_userAccountId AND CCY__c=:p_ccy AND Status__c IN (\'Confirmed by operations\') AND Type__c IN (\'80.Withdrawal\', \'70.Deposit\')';
                
            if(p_trusteeName != null) {
                v_statsQuery5 = v_statsQuery5+' AND Trustee__c =:p_trusteeName GROUP BY Type__c';  
            } else {
                v_statsQuery5 = v_statsQuery5+' GROUP BY Type__c';  
            }   
            
            AggregateResult[] v_groupedResults5 = database.query(v_statsQuery5);
            for(AggregateResult ar : v_groupedResults5){
                if((string)(ar.get('transType')) == '70.Deposit') {
                    v_allTimeDeposit = (Decimal) ar.get('allTimeAmount');
                }else if((string)(ar.get('transType')) == '80.Withdrawal'){
                    v_allTimeWithdrawal = (Decimal) ar.get('allTimeAmount');
                }
            }
            if((v_allTimeDeposit-v_allTimeWithdrawal) != 0) {
                v_allTimeUtilization = ((v_allTimeAllocationTotal/(v_allTimeDeposit-v_allTimeWithdrawal))*100).setScale(2);
            }
            
            v_result.put('allTimeUtilization', v_allTimeUtilization);
               
            return new GlobalMethods_v9.DecimalMapReturnClass('true', 'Query executed successfully.', v_result);
        
        }else {
            return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid User', null);
        }
    }

}