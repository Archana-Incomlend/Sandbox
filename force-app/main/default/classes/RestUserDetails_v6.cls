@RestResource(urlMapping='/v6/user/*')

global with sharing class RestUserDetails_v6 {
      
    @HttpGet
    global static ReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Account result = new Account();
        String userId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if(RestUserLogin.isValidId(userId) == false) {
        
            return new ReturnClass('false','Invalid user ID', null);
        }
                
        try {

          result = [SELECT is_Master_Agent__c, Agent_Commision_Supplier_Platform_Fee__c, Agent_Commision_Purchaser_Discount_Fee__c, Agent_Commision_Obligor_Platform_Fee__c, XXX_Available_eWallet__c, XXX_total_discount_earned__c, XXX_total_reservations__c, XXX_Total_in_progress_invoices__c, XXX_eWallet_Balance__c, Total_in_progress_Invoices_USD_Equiv__c, Total_Position_USD_Equiv__c, EUR_available_eWallet__c, EUR_Total_in_progress_invoices__c, EUR_eWallet_Balance__c, EUR_total_reservations__c, EUR_available_eWallet_USD_Equiv__c, EUR_Total_Discount_Earned__c, Total_eWallet_USD_Equiv__c, USD_Available_eWallet__c, SGD_Available_eWallet__c, HKD_Available_eWallet__c, SGD_total_discount_earned__c, USD_total_discount_earned__c, HKD_total_discount_earned__c, USD_total_reservations__c, SGD_total_reservations__c, HKD_total_reservations__c, HKD_Total_in_progress_invoices__c, USD_Total_in_progress_invoices__c, SGD_Total_in_progress_invoices__c, Total_Available_eWallet_USD_Equiv__c, SGD_Available_eWallet_USD_Equiv__c, HKD_Available_eWallet_USD_Equiv__c, SGD_eWallet_Balance__c, USD_eWallet_Balance__c, HKD_eWallet_Balance__c FROM Account WHERE Id = :userId];

          return new ReturnClass('true', 'Query executed successfully.', result);
    
        } catch (Exception e) {
          return new ReturnClass('false', e.getMessage(), null);
        }
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global Account records;

        global ReturnClass(String success, String message, Account records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }
      
}