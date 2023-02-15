@RestResource(urlMapping='/v3/buyer/*')

global with sharing class RestBuyerDetails_v3 {
      
    @HttpGet
    global static ReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Supplier_Buyer_Map__c result = new Supplier_Buyer_Map__c();
        
        String mapId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        String detailQuery = 'SELECT Name, Buyer__r.Year_of_incorporation__c, Buyer__c, number_of_invoices_all_time__c, Total_Financing_value_alltime__c, Incomlend_product__r.CCYs__c, Incomlend_product__r.max_invoice_value_USD__c, Incomlend_product__r.minimum_face_value__c, Recommended_Discount_Rate__c, Incomlend_imposed_credit_limit__c, buyer_EH_rating__c, offer_conditions_met__c, is_offer_conditional__c, Rejected_Reason__c, Offer_Accepted_Date__c, Offer_Sent_Date__c, Onboarding_Notes__c, buyer_onboarding_stage__c, Public_description_of_relationship__c, Buyer__r.Public_Profile__c, Public_Payment_History_Comments__c, Buyer__r.Website, number_of_invoices_in_last_12_months__c, months_relationship_with_buyer__c, Internal_Payment_History_Comments__c, Buyer__r.BillingAddress, Buyer__r.Countries_of_operation__c, Buyer__r.head_office_country__c, Buyer__r.AnnualRevenue, Buyer__r.Industry, Buyer__r.logo_URL__c, map_onboarding_stage__c, Public_Verification_Requirements__c, Buyer__r.suspended__c, Buyer__r.suspended_notes__c, Accepted_Payment_Terms__c, buyer_supplier_map_approved__c, approval_date__c, accepted_incoterms__c, Incomlend_product__r.active__c, Incomlend_product__r.Name, Buyer__r.Name, Marketplace__r.currency__c, insurable__c, Id FROM Supplier_Buyer_Map__c WHERE Id = :mapId';
       
        if(RestUserLogin.isValidId(mapId) == false) {
        
           return new ReturnClass('false','Invalid Buyer id', null);
        }
        try {
            result = database.query(detailQuery);
            return new ReturnClass('true', 'Query executed successfully.', result);
        }
        catch (Exception e) {
           return new ReturnClass('false', e.getMessage(), null);
        }
        
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global Supplier_Buyer_Map__c records;

        global ReturnClass(String success, String message, Supplier_Buyer_Map__c records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }
      
}