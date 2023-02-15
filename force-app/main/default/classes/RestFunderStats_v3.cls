@RestResource(urlMapping='/v3/funder/stats/*')

global with sharing class RestFunderStats_v3 {
    
    @HttpGet   
    global static ReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String userId = URLParams[URLParams.size()-1];        
        String ccy = URLParams[URLParams.size()-2];
        
        map<String,Decimal> result = new Map<String,Decimal>();
                
        if(isvalidCurrency(ccy) == false) {
        
            return new ReturnClass('false','Invalid currency', null);
        }
        
        if(RestUserLogin.isValidId(userId) == false) {
        
            return new ReturnClass('false','Invalid User ID', null);
        }  
        
        Account userDetails = RestUserLogin.validateUser(userId);
        
        if(userDetails.Type == 'Customer' && userDetails.Sub_type__c == 'Purchaser') {              
           
            try {
                
                Account userData = [SELECT XXX_Available_eWallet__c, XXX_total_discount_earned__c, XXX_total_reservations__c, XXX_Total_in_progress_invoices__c, XXX_eWallet_Balance__c, Total_in_progress_Invoices_USD_Equiv__c, Total_Position_USD_Equiv__c, EUR_available_eWallet__c, EUR_Total_in_progress_invoices__c, EUR_eWallet_Balance__c, EUR_total_reservations__c, EUR_available_eWallet_USD_Equiv__c, EUR_Total_Discount_Earned__c, Total_eWallet_USD_Equiv__c, USD_Available_eWallet__c, SGD_Available_eWallet__c, HKD_Available_eWallet__c, SGD_total_discount_earned__c, USD_total_discount_earned__c, HKD_total_discount_earned__c, USD_total_reservations__c, SGD_total_reservations__c, HKD_total_reservations__c, HKD_Total_in_progress_invoices__c, USD_Total_in_progress_invoices__c, SGD_Total_in_progress_invoices__c, Total_Available_eWallet_USD_Equiv__c, SGD_Available_eWallet_USD_Equiv__c, HKD_Available_eWallet_USD_Equiv__c, SGD_eWallet_Balance__c, USD_eWallet_Balance__c, HKD_eWallet_Balance__c FROM Account WHERE Id = :userId];
                
                result.put('XXX_Available_eWallet__c', (Decimal)(userData.XXX_Available_eWallet__c));
                result.put('XXX_eWallet_Balance__c', (Decimal)(userData.XXX_eWallet_Balance__c));
                result.put('XXX_total_discount_earned__c', (Decimal)(userData.XXX_total_discount_earned__c));
                result.put('XXX_Total_in_progress_invoices__c', (Decimal)(userData.XXX_Total_in_progress_invoices__c));
                result.put('XXX_total_reservations__c', (Decimal)(userData.XXX_total_reservations__c));
                                
                result.put('USD_Available_eWallet__c', (Decimal)(userData.USD_Available_eWallet__c));
                result.put('USD_eWallet_Balance__c', (Decimal)(userData.USD_eWallet_Balance__c));
                result.put('USD_total_discount_earned__c', (Decimal)(userData.USD_total_discount_earned__c));
                result.put('USD_Total_in_progress_invoices__c', (Decimal)(userData.USD_Total_in_progress_invoices__c));
                result.put('USD_total_reservations__c', (Decimal)(userData.USD_total_reservations__c));
                
                result.put('HKD_Available_eWallet__c', (Decimal)(userData.HKD_Available_eWallet__c));
                result.put('HKD_eWallet_Balance__c', (Decimal)(userData.HKD_eWallet_Balance__c));
                result.put('HKD_total_discount_earned__c', (Decimal)(userData.HKD_total_discount_earned__c));
                result.put('HKD_Total_in_progress_invoices__c', (Decimal)(userData.HKD_Total_in_progress_invoices__c));
                result.put('HKD_total_reservations__c', (Decimal)(userData.HKD_total_reservations__c));
                
                result.put('EUR_available_eWallet__c', (Decimal)(userData.EUR_available_eWallet__c));
                result.put('EUR_eWallet_Balance__c', (Decimal)(userData.EUR_eWallet_Balance__c));
                result.put('EUR_Total_Discount_Earned__c', (Decimal)(userData.EUR_Total_Discount_Earned__c));
                result.put('EUR_Total_in_progress_invoices__c', (Decimal)(userData.EUR_Total_in_progress_invoices__c));
                result.put('EUR_total_reservations__c', (Decimal)(userData.EUR_total_reservations__c));
                
                result.put('SGD_Available_eWallet__c', (Decimal)(userData.SGD_Available_eWallet__c));
                result.put('SGD_eWallet_Balance__c', (Decimal)(userData.SGD_eWallet_Balance__c));
                result.put('SGD_total_discount_earned__c', (Decimal)(userData.SGD_total_discount_earned__c));
                result.put('SGD_Total_in_progress_invoices__c', (Decimal)(userData.SGD_Total_in_progress_invoices__c));
                result.put('SGD_total_reservations__c', (Decimal)(userData.SGD_total_reservations__c));
                
                
                AggregateResult[] groupedResults = [SELECT SUM(funder_discount_amount__c )remainingDiscountTotal FROM Invoice_Allocation__c WHERE Funder__c=:userId AND Status__c ='Confirmed' AND CCY__c=:ccy AND Invoice__r.phase__C = '3:IN PROGRESS'];
                 
                for(AggregateResult ar : groupedResults){
                    result.put('remainingDiscountTotal', (Decimal)(ar.get('remainingDiscountTotal')));
                }
               
                AggregateResult[] groupedResults1 = [SELECT SUM(amount__c)inProgreesAllocationTotal FROM Invoice_Allocation__c WHERE Funder__c=:userId AND CCY__c=:ccy AND Status__c IN ('Confirmed') AND Invoice__r.phase__C IN ('3:IN PROGRESS')];
                for(AggregateResult ar : groupedResults1){
                    result.put('inProgreesAllocationTotal', (Decimal)(ar.get('inProgreesAllocationTotal')));
                }
                AggregateResult[] groupedResults2 = [SELECT SUM(amount__c)onMarketplaceAllocationTotal FROM Invoice_Allocation__c WHERE Funder__c=:userId AND CCY__c=:ccy AND Status__c IN ('Reservation') AND Invoice__r.phase__C IN ('2:ON MARKETPLACE')];
                for(AggregateResult ar : groupedResults2){
                    result.put('onMarketplaceAllocationTotal', (Decimal)(ar.get('onMarketplaceAllocationTotal')));
                }
                AggregateResult[] groupedResults3 = [SELECT SUM(amount__c)closedAllocationTotal, SUM(Total_commission__c)totalFunderCommission FROM Invoice_Allocation__c WHERE Funder__c=:userId AND CCY__c=:ccy AND Status__c IN ('Repaid invoice deal closed') AND Invoice__r.phase__C IN ('4:CLOSED')];
                for(AggregateResult ar : groupedResults3){
                    result.put('closedAllocationTotal', (Decimal)(ar.get('closedAllocationTotal')));
                    result.put('totalFunderCommission', (Decimal)(ar.get('totalFunderCommission')));
                }
               
               return new ReturnClass('true', 'Query executed successfully.', result);
        
            } catch (Exception e) {
                  return new ReturnClass('false', e.getMessage(), null);
            }
        }else {
            return new ReturnClass('false','Invalid User', null);
        }
    }
    
    global static Boolean isvalidCurrency(String ccy){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Marketplace__c.Currency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Boolean currencyStatus = false;
        for( Schema.PicklistEntry pickListVal : ple){
            if(ccy == pickListVal.getValue()){
                currencyStatus = true;
            }
        }     
        return currencyStatus;
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global map<String,Decimal> records;

        global ReturnClass(String success, String message, map<String,Decimal> records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }

    
}