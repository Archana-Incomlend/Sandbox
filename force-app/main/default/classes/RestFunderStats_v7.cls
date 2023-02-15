@RestResource(urlMapping='/v7/funder/stats/*')

global with sharing class RestFunderStats_v7 {
    
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
                
            v_result.put('XXX_Available_eWallet__c', (Decimal)(v_userWalletData.v_records.XXX_Available_eWallet__c));
            v_result.put('XXX_eWallet_Balance__c', (Decimal)(v_userWalletData.v_records.XXX_eWallet_Balance__c));
            v_result.put('XXX_total_discount_earned__c', (Decimal)(v_userWalletData.v_records.XXX_total_discount_earned__c));
            v_result.put('XXX_Total_in_progress_invoices__c', (Decimal)(v_userWalletData.v_records.XXX_Total_in_progress_invoices__c));
            v_result.put('XXX_total_reservations__c', (Decimal)(v_userWalletData.v_records.XXX_total_reservations__c));
            v_result.put('XXX_Position__c', (Decimal)(v_userWalletData.v_records.XXX_Position__c));
                                
            v_result.put('USD_Available_eWallet__c', (Decimal)(v_userWalletData.v_records.USD_Available_eWallet__c));
            v_result.put('USD_eWallet_Balance__c', (Decimal)(v_userWalletData.v_records.USD_eWallet_Balance__c));
            v_result.put('USD_total_discount_earned__c', (Decimal)(v_userWalletData.v_records.USD_total_discount_earned__c));
            v_result.put('USD_Total_in_progress_invoices__c', (Decimal)(v_userWalletData.v_records.USD_Total_in_progress_invoices__c));
            v_result.put('USD_total_reservations__c', (Decimal)(v_userWalletData.v_records.USD_total_reservations__c));
            v_result.put('USD_Position__c', (Decimal)(v_userWalletData.v_records.USD_Position__c));
                
            v_result.put('HKD_Available_eWallet__c', (Decimal)(v_userWalletData.v_records.HKD_Available_eWallet__c));
            v_result.put('HKD_eWallet_Balance__c', (Decimal)(v_userWalletData.v_records.HKD_eWallet_Balance__c));
            v_result.put('HKD_total_discount_earned__c', (Decimal)(v_userWalletData.v_records.HKD_total_discount_earned__c));
            v_result.put('HKD_Total_in_progress_invoices__c', (Decimal)(v_userWalletData.v_records.HKD_Total_in_progress_invoices__c));
            v_result.put('HKD_total_reservations__c', (Decimal)(v_userWalletData.v_records.HKD_total_reservations__c));
            v_result.put('HKD_Position__c', (Decimal)(v_userWalletData.v_records.HKD_Position__c));
                
            v_result.put('EUR_available_eWallet__c', (Decimal)(v_userWalletData.v_records.EUR_available_eWallet__c));
            v_result.put('EUR_eWallet_Balance__c', (Decimal)(v_userWalletData.v_records.EUR_eWallet_Balance__c));
            v_result.put('EUR_Total_Discount_Earned__c', (Decimal)(v_userWalletData.v_records.EUR_Total_Discount_Earned__c));
            v_result.put('EUR_Total_in_progress_invoices__c', (Decimal)(v_userWalletData.v_records.EUR_Total_in_progress_invoices__c));
            v_result.put('EUR_total_reservations__c', (Decimal)(v_userWalletData.v_records.EUR_total_reservations__c));
            v_result.put('EUR_Position__c', (Decimal)(v_userWalletData.v_records.EUR_Position__c));
                
            v_result.put('SGD_Available_eWallet__c', (Decimal)(v_userWalletData.v_records.SGD_Available_eWallet__c));
            v_result.put('SGD_eWallet_Balance__c', (Decimal)(v_userWalletData.v_records.SGD_eWallet_Balance__c));
            v_result.put('SGD_total_discount_earned__c', (Decimal)(v_userWalletData.v_records.SGD_total_discount_earned__c));
            v_result.put('SGD_Total_in_progress_invoices__c', (Decimal)(v_userWalletData.v_records.SGD_Total_in_progress_invoices__c));
            v_result.put('SGD_total_reservations__c', (Decimal)(v_userWalletData.v_records.SGD_total_reservations__c));
            v_result.put('SGD_Position__c', (Decimal)(v_userWalletData.v_records.SGD_Position__c));
                
                
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