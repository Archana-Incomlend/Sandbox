@RestResource(urlMapping='/v7.1/supplierbuyermap/*')

global with sharing class RestSupplierBuyerMapDetails_v7_1 {
      
    @HttpGet
    global static GlobalMethods.BuyerMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        //Get URL paramaters  
        String p_mapId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String p_fieldSetType = RestContext.request.params.get('fieldSetType'); 
        
        //Initializing and declaring variables
        List<Supplier_Buyer_Map__c> v_result = new List<Supplier_Buyer_Map__c> ();
        Map<String,String> v_FieldSet = new Map<String,String>{
            'supplier' => 'Name, Incomlend_product__c, Buyer__r.Un_utilised_adv_amt_all_phases_usd_equiv__c, Incomlend_product__r.Invoice_Record_Type__c, Inprogress_invoice_amount_usd_equiv__c, overdue_invoice_amount_usd_equiv__c, Buyer__r.Un_utilised_advanced_amount_usd_equiv__c, total_invoice_value_in_progress__c, Inprogress_advanced_amount_usd_equiv__c, Supplier__r.Year_of_incorporation__c, Supplier__c, number_of_invoices_all_time__c, Total_Financing_value_alltime__c, Incomlend_product__r.CCYs__c, Incomlend_product__r.max_invoice_value_USD__c, Incomlend_product__r.minimum_face_value__c, Recommended_Discount_Rate__c, Incomlend_imposed_credit_limit__c, buyer_EH_rating__c, offer_conditions_met__c, is_offer_conditional__c, Rejected_Reason__c, Offer_Accepted_Date__c, Offer_Sent_Date__c, Onboarding_Notes__c, buyer_onboarding_stage__c, Public_description_of_relationship__c, Supplier__r.Public_Profile__c, Public_Payment_History_Comments__c, Supplier__r.Website, number_of_invoices_in_last_12_months__c, months_relationship_with_buyer__c, Internal_Payment_History_Comments__c, Supplier__r.BillingAddress, Supplier__r.Countries_of_operation__c, Supplier__r.head_office_country__c, Supplier__r.AnnualRevenue, Supplier__r.Industry, Supplier__r.logo_URL__c, map_onboarding_stage__c, Public_Verification_Requirements__c, Supplier__r.suspended__c, Supplier__r.suspended_notes__c, Accepted_Payment_Terms__c, buyer_supplier_map_approved__c, approval_date__c, accepted_incoterms__c, Incomlend_product__r.active__c, Incomlend_product__r.Name, Supplier__r.Name, Marketplace__r.currency__c, insurable__c, Id',
            'buyer' => 'Name, Incomlend_product__c, Buyer__r.Un_utilised_adv_amt_all_phases_usd_equiv__c, Incomlend_product__r.Invoice_Record_Type__c, Inprogress_invoice_amount_usd_equiv__c, overdue_invoice_amount_usd_equiv__c, Buyer__r.Year_of_incorporation__c, Buyer__c, number_of_invoices_all_time__c, Total_Financing_value_alltime__c, Incomlend_product__r.CCYs__c, Incomlend_product__r.max_invoice_value_USD__c, Incomlend_product__r.minimum_face_value__c, Recommended_Discount_Rate__c, Incomlend_imposed_credit_limit__c, buyer_EH_rating__c, offer_conditions_met__c, is_offer_conditional__c, Rejected_Reason__c, Offer_Accepted_Date__c, Offer_Sent_Date__c, Onboarding_Notes__c, buyer_onboarding_stage__c, Public_description_of_relationship__c, Buyer__r.Public_Profile__c, Public_Payment_History_Comments__c, Buyer__r.Website, number_of_invoices_in_last_12_months__c, months_relationship_with_buyer__c, Internal_Payment_History_Comments__c, Buyer__r.BillingAddress, Buyer__r.Countries_of_operation__c, Buyer__r.head_office_country__c, Buyer__r.AnnualRevenue, Buyer__r.Industry, Buyer__r.logo_URL__c, map_onboarding_stage__c, Public_Verification_Requirements__c, Buyer__r.suspended__c, Buyer__r.suspended_notes__c, Accepted_Payment_Terms__c, buyer_supplier_map_approved__c, approval_date__c, accepted_incoterms__c, Incomlend_product__r.active__c, Incomlend_product__r.Name, Buyer__r.Name, Marketplace__r.currency__c, insurable__c, Id'
        };
        String v_detailQuery;
        String v_detailQueryFieldSet;
        
        //Validating map Id
        if(GlobalMethods.isValidId(p_mapId) == false) {
            return new GlobalMethods.BuyerMapReturnClass('false','Invalid supplier buyer map id', null);
        }
        
        //Validating and adding the fieldSet
        if(v_FieldSet.get(p_fieldSetType) != null) {
            v_detailQueryFieldSet = v_FieldSet.get(p_fieldSetType);
        }else {
            return new GlobalMethods.BuyerMapReturnClass('false','Field set parameter is missing or invalid value', null);
        }
        
        //Run the query and return result
        v_detailQuery = 'SELECT '+v_detailQueryFieldSet + ' FROM Supplier_Buyer_Map__c WHERE Id = :p_mapId';
        v_result = database.query(v_detailQuery);
        if (v_result.size() == 0) {
            return new GlobalMethods.BuyerMapReturnClass('false','Invalid supplier buyer map id', null);
        }else {
            return new GlobalMethods.BuyerMapReturnClass('true', 'Query executed successfully.', v_result.get(0));
        }
    }
 
}