@RestResource(urlMapping='/marketplace/*')

global with sharing class RestInvoiceStatsData {
      
    @HttpGet
    global static ReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Marketplace__c result = new Marketplace__c();
        String mpId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(RestUserLogin.isValidId(mpId) == false) {
        
           return new ReturnClass('false','Invalid Marketplace id', null);
        }
        try {
            result = [SELECT Name, All_Time_Invoice_Value__c, all_time_average_discount_rate__c, All_time_funded_Amount__c, all_time_average_invoice_value__c, Available_on_Marketplace__c, closed__c, in_progress_amount__c, currency_symbol__c FROM Marketplace__c WHERE Id = :mpId];
            return new ReturnClass('true', 'Query executed successfully.', result);
        }
        catch (Exception e) {
           return new ReturnClass('false', e.getMessage(), null);
        }
        
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global Marketplace__c records;

        global ReturnClass(String success, String message, Marketplace__c records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }
      
}