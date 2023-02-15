@RestResource(urlMapping='/v8.1/invoice/*')

global with sharing class RestInvoiceData_v8_1 {
      
    @HttpGet
    global static GlobalMethods.InvoiceReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List <Invoice_Finance_Deal__c> v_result = new List <Invoice_Finance_Deal__c> ();
        String p_invoiceId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if(GlobalMethods.isValidId(p_invoiceId) == false) {
           return new GlobalMethods.InvoiceReturnClass('false','Invalid invoice id', null);
        }
        
        v_result = [SELECT Name, Phase__c, Supplier_Buyer_Map__r.Buyer__r.Discussion_board_link__c, Public_invoice_updates__c, Supplier_Buyer_Map__r.Buyer__r.Goods_or_Services_Offered__c, Supplier_Buyer_Map__r.Buyer__r.goods_or_services_offered_text__c, Supplier_Buyer_Map__r.Buyer__r.Year_of_incorporation__c, Supplier_Buyer_Map__r.Buyer__r.Country_of_Incorporation__c, Supplier_Buyer_Map__r.Supplier__r.Goods_or_Services_Offered__c, Supplier_Buyer_Map__r.Supplier__r.goods_or_services_offered_text__c, Supplier_Buyer_Map__r.Supplier__r.Year_of_incorporation__c, Supplier_Buyer_Map__r.Supplier__r.Country_of_Incorporation__c, platform_fee_variable_amount__c,  Supplier_Buyer_Map__r.Buyer__r.Credit_Limit_Remain_inc_mrkplc_usd_equiv__c, Supplier_Buyer_Map__r.Buyer__r.Credit_Limit_Rem_all_phases_usd_equiv__c, Supplier_Buyer_Map__r.Buyer__r.Insured_by__c, Supplier_Buyer_Map__r.Buyer__r.Insurance_Policy_Ownership__r.Name,Total_Rebate_Amount__c, Earliest_date_of_funding__c, Map_Product__r.Name, MAX_bid_amount__c, Incoterm__c, total_fees_and_discount_paid_by_supplier__c, credit_insurance_fee__c, platform_fee_fixed__c, marketplace_currency_symbol__c, supplier_invoice_reference_number__c, Supplier_Buyer_Map__r.RMA__c, Goods_Services_description__c, auto_status__c, public_supplier_name__c, expected_financing_period__c, calculated_expected_payment_date__c,  credit_insured__c, supplier_buyer_map_public_name__c, has_quality_report__c, remaining_amount_USD_Equivalent__c, remaining_amount__c, Supplier_Buyer_Map__r.Public_description_of_relationship__c, Supplier_Buyer_Map__r.number_of_invoices_in_last_12_months__c, Supplier_Buyer_Map__r.months_relationship_with_buyer__c, Supplier_Buyer_Map__r.Public_Payment_History_Comments__c, buyer_confirmed_PO_details__c, Supplier_Buyer_Map__r.Buyer__r.Description, Supplier_Buyer_Map__r.Supplier__r.Public_Profile__c, Supplier_Buyer_Map__r.Buyer__r.Public_Profile__c, Supplier_Buyer_Map__r.Buyer__r.Website, public_validation_notes__c, repeat_order__c, invoice_amount__c, Public_Description__c, buyer_confirmed_invoice_details__c, Buyer_Confirmed_acceptance__c, good_shipped__c, confirmed_delivery__c, Country_of_Destination__c, Country_of_Origin__c, Goods_or_Services_Category__c, Invoice_date__c,  Supplier_Buyer_Map__r.Supplier__r.logo_URL__c, Supplier_Buyer_Map__r.Buyer__r.logo_URL__c, Supplier_Buyer_Map__r.Supplier__r.AnnualRevenue, Supplier_Buyer_Map__r.Buyer__r.AnnualRevenue,  Supplier_Buyer_Map__r.Buyer__r.Euler_Hermes_Credit_Rating__c, Supplier_Buyer_Map__r.Supplier__r.Countries_of_operation__c, Supplier_Buyer_Map__r.Supplier__r.BillingAddress, Supplier_Buyer_Map__r.Buyer__r.BillingAddress, Supplier_Buyer_Map__r.Buyer__r.Countries_of_operation__c, Supplier_Buyer_Map__r.Buyer__r.head_office_country__c, Supplier_Buyer_Map__r.Buyer__r.Industry, Supplier_Buyer_Map__r.Buyer__r.Name, Invoice_name__c, Listing_End__c, Listing_Start__c, Supplier_Buyer_Map__r.Supplier__r.Website , Supplier_Buyer_Map__r.Supplier__r.Industry, CCY__c, Supplier_Buyer_Map__r.Supplier__r.head_office_country__c, Supplier_Buyer_Map__r.Supplier__r.Name, id, discount_rate__c, discount_amount_if_fully_funded__c, actual_financing_period__c, Due_Date__c, requested_amount__c, funded_amount__c, requested_amount_funded_percentage__c, Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c FROM Invoice_Finance_Deal__c WHERE Id = :p_invoiceId];
        if (v_result.size() == 0) {
            return new GlobalMethods.InvoiceReturnClass('false','Invalid invoice Id', null);
        }else {
            return new GlobalMethods.InvoiceReturnClass('true','Query executed successfully.', v_result.get(0));
        } 
    } 
}