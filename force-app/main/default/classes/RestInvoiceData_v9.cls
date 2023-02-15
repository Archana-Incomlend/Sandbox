@RestResource(urlMapping='/v9/invoice/*')

global with sharing class RestInvoiceData_v9 {
      
    @HttpGet
    global static GlobalMethods_v9.InvoiceReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List <Invoice_Finance_Deal__c> v_result = new List <Invoice_Finance_Deal__c> ();
        Date v_repaymentDate = null;
        String p_invoiceId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        //Get logged in user account Id using the email Id from header
        map<String,String> v_headers = new map<String,String>();
        v_headers = req.headers;
        String v_email = v_headers.get('email');
        if(v_email > '') {
            try{
                Id v_loggedInUserAccountId = GlobalMethods_v9.getLoggedinUserAccountId(v_email); 
            }catch(GeneralException e) {
                return new GlobalMethods_v9.InvoiceReturnClass('false',e.getMessage(), null);
            }
        }
        
        
        if(GlobalMethods_v9.isValidId(p_invoiceId) == false) {
           return new GlobalMethods_v9.InvoiceReturnClass('false','Invalid invoice id', null);
        }
        
        v_result = [SELECT Amount_Overdue__c, Overdue_Supplier_discount_rate__c, over_due_days__c, Total_supplier_discount_amount_expected__c, Total_Supplier_Discount__c, Approved_by_CMA__c, Goods_and_Services_new__c, Total_Platform_Fee__c, Name, Buyer_other_Overdue_15_30__c, Buyer_other_Overdue_8_14__c, Phase__c, Supplier_Buyer_Map__r.Buyer__r.Discussion_board_link__c, Public_invoice_updates__c, Supplier_Buyer_Map__r.Buyer__r.Goods_and_Services_new__c, Supplier_Buyer_Map__r.Supplier__r.Goods_and_Services_new__c, Supplier_Buyer_Map__r.Buyer__r.Goods_or_Services_Offered__c, Supplier_Buyer_Map__r.Buyer__r.goods_or_services_offered_text__c, Supplier_Buyer_Map__r.Buyer__r.Year_of_incorporation__c, Supplier_Buyer_Map__r.Buyer__r.Country_of_Incorporation__c, Supplier_Buyer_Map__r.Supplier__r.Goods_or_Services_Offered__c, Supplier_Buyer_Map__r.Supplier__r.goods_or_services_offered_text__c, Supplier_Buyer_Map__r.Supplier__r.Year_of_incorporation__c, Supplier_Buyer_Map__r.Supplier__r.Country_of_Incorporation__c, platform_fee_variable_amount__c,  Supplier_Buyer_Map__r.Buyer__r.Credit_Limit_Remain_inc_mrkplc_usd_equiv__c, Supplier_Buyer_Map__r.Buyer__r.Credit_Limit_Rem_all_phases_usd_equiv__c, Supplier_Buyer_Map__r.Buyer__r.Insured_by__c, Supplier_Buyer_Map__r.Buyer__r.Insurance_Policy_Ownership__r.Name,Total_Rebate_Amount__c, Earliest_date_of_funding__c, Map_Product__r.Name, MAX_bid_amount__c, Incoterm__c, total_fees_and_discount_paid_by_supplier__c, credit_insurance_fee__c, platform_fee_fixed__c, marketplace_currency_symbol__c, supplier_invoice_reference_number__c, Supplier_Buyer_Map__r.RMA__c, Goods_Services_description__c, auto_status__c, public_supplier_name__c, expected_financing_period__c, calculated_expected_payment_date__c,  credit_insured__c, supplier_buyer_map_public_name__c, has_quality_report__c, remaining_amount_USD_Equivalent__c, remaining_amount__c, Supplier_Buyer_Map__r.Public_description_of_relationship__c, Supplier_Buyer_Map__r.number_of_invoices_in_last_12_months__c, Supplier_Buyer_Map__r.months_relationship_with_buyer__c, Supplier_Buyer_Map__r.Public_Payment_History_Comments__c, buyer_confirmed_PO_details__c, Supplier_Buyer_Map__r.Buyer__r.Description, Supplier_Buyer_Map__r.Supplier__r.Public_Profile__c, Supplier_Buyer_Map__r.Buyer__r.Public_Profile__c, Supplier_Buyer_Map__r.Buyer__r.Website, public_validation_notes__c, repeat_order__c, invoice_amount__c, Public_Description__c, buyer_confirmed_invoice_details__c, Buyer_Confirmed_acceptance__c, good_shipped__c, confirmed_delivery__c, Country_of_Destination__c, Country_of_Origin__c, Goods_or_Services_Category__c, Invoice_date__c,  Supplier_Buyer_Map__r.Supplier__r.logo_URL__c, Supplier_Buyer_Map__r.Buyer__r.logo_URL__c, Supplier_Buyer_Map__r.Supplier__r.AnnualRevenue, Supplier_Buyer_Map__r.Buyer__r.AnnualRevenue,  Supplier_Buyer_Map__r.Buyer__r.Euler_Hermes_Credit_Rating__c, Supplier_Buyer_Map__r.Supplier__r.Countries_of_operation__c, Supplier_Buyer_Map__r.Supplier__r.BillingAddress, Supplier_Buyer_Map__r.Buyer__r.BillingAddress, Supplier_Buyer_Map__r.Buyer__r.Countries_of_operation__c, Supplier_Buyer_Map__r.Buyer__r.head_office_country__c, Supplier_Buyer_Map__r.Buyer__r.Industry, Supplier_Buyer_Map__r.Buyer__r.Name, Invoice_name__c, Listing_End__c, Listing_Start__c, Supplier_Buyer_Map__r.Supplier__r.Website , Supplier_Buyer_Map__r.Supplier__r.Industry, CCY__c, Supplier_Buyer_Map__r.Supplier__r.head_office_country__c, Supplier_Buyer_Map__r.Supplier__r.Name, id, discount_rate__c, Gross_funder_discount_amount_expected__c, discount_amount_if_fully_funded__c, actual_financing_period__c, Due_Date__c, requested_amount__c, funded_amount__c, requested_amount_funded_percentage__c, Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c , Real_Face_Value__c, Repaid_Amount__c, Repaid_Funded_Amount__c, Repayment_Agreement__c
                    , Buyer_acknowledgment_date__c, Supplier_Buyer_Map__r.Funder_Discount_Rate__c
                    FROM Invoice_Finance_Deal__c WHERE Id = :p_invoiceId];
        if (v_result.size() == 0) {
            return new GlobalMethods_v9.InvoiceReturnClass('false','Invalid invoice Id', null);
        }else {
            // handle old account with old goods and services
            if (v_result.get(0).Supplier_Buyer_Map__r.Supplier__r.Goods_and_Services_new__c != null) {
                v_result.get(0).Supplier_Buyer_Map__r.Supplier__r.Goods_or_Services_Offered__c = v_result.get(0).Supplier_Buyer_Map__r.Supplier__r.Goods_and_Services_new__c;
            }
            if (v_result.get(0).Supplier_Buyer_Map__r.Buyer__r.Goods_and_Services_new__c != null) {
                v_result.get(0).Supplier_Buyer_Map__r.Buyer__r.Goods_or_Services_Offered__c = v_result.get(0).Supplier_Buyer_Map__r.Buyer__r.Goods_and_Services_new__c;
            }
            if (v_result.get(0).Goods_and_Services_new__c != null) {
                v_result.get(0).Goods_or_Services_Category__c = v_result.get(0).Goods_and_Services_new__c;
            }
            if (v_result.get(0).Repayment_Agreement__c != null) {
                List<Repayment_Installment__c> v_ListInstallment = [SELECT Due_Date__c FROM Repayment_Installment__c WHERE Repayment_Agreement__c = :v_result.get(0).Repayment_Agreement__c ORDER BY Due_Date__c DESC LIMIT 1];
                if(v_ListInstallment.size() > 0){
                    v_repaymentDate = v_ListInstallment.get(0).Due_Date__c;    
                }
            }
            return new GlobalMethods_v9.InvoiceReturnClass('true','Query executed successfully.', v_result.get(0), v_repaymentDate);
        } 
    } 
}