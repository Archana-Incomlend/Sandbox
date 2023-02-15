@RestResource(urlMapping='/v7/allbuyer/invoices/*')

global with sharing class RestAllBuyerInvoices_v7 {
    
    @HttpGet   
    global static GlobalMethods.InvoiceListReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String p_userAccountId = URLParams[URLParams.size()-1];        
        String p_phase = URLParams[URLParams.size()-2];  
        String p_type = URLParams[URLParams.size()-3];  
        String v_SFphase ;
        List<Invoice_Finance_Deal__c> v_result = new List<Invoice_Finance_Deal__c> ();
                
        if(p_userAccountId != null && GlobalMethods.isValidId(p_userAccountId) == false) {
            return new GlobalMethods.InvoiceListReturnClass('false','Invalid User account ID', null);
        }
               
        if(p_phase == 'onmarketplace') {
            v_SFphase = '2:ON MARKETPLACE';
        }else if(p_phase == 'inprogress') {
            v_SFphase = '3:IN PROGRESS';
        }else if(p_phase == 'closed') {
            v_SFphase = '4:CLOSED';
        }else if(p_phase == 'prelisting') {
            v_SFphase = '1:PRE LISTING';
        }else {
            return new GlobalMethods.InvoiceListReturnClass('false','Invalid phase', null);
        }  
        
        String listQuery = 'SELECT Name, CCY__c, Supplier_Buyer_Map__r.Marketplace__r.Name, Supplier_Buyer_Map__r.Incomlend_product__r.Name, over_due_days__c, calculated_expected_payment_date__c, Actual_Repayment_Received_Date__c, Expected_Payment_Date__c, financing_period_for_calcs__c, supplier_costs_as_percentage__c, total_fees_and_discount_paid_by_supplier__c, remaining_amount__c, submitted_date__c, buyer_purchase_order_reference__c, supplier_invoice_reference_number__c, marketplace_currency_symbol__c, invoice_amount__c, expected_financing_period__c, Supplier_Buyer_Map__r.Marketplace__c, Supplier_Buyer_Map__r.months_relationship_with_buyer__c, Listing_Start__c, Listing_End__c, auto_status__c, Phase__c, Invoice_date__c, Invoice_name__c, id, discount_rate__c, actual_financing_period__c, Due_Date__c, requested_amount__c, funded_amount__c, requested_amount_funded_percentage__c, discount_amount_on_funded_amount__c, discount_amount_if_fully_funded__c, credit_insurance_fee__c, platform_fee_fixed__c FROM Invoice_Finance_Deal__c WHERE ';
        if(p_type == 'buyer') {
            listQuery = listQuery+' Supplier_Buyer_Map__r.Buyer__c=:p_userAccountId';
        }else if(p_type == 'map') {
            listQuery = listQuery+' Supplier_Buyer_Map__c=:p_userAccountId';
        }else {
            return new GlobalMethods.InvoiceListReturnClass('false','Invalid type', null);
        }
                
        if(v_SFphase != null) {
            listQuery = listQuery+' AND phase__c=:v_SFphase';
        }
        
        v_result = database.query(listQuery);
        return new GlobalMethods.InvoiceListReturnClass('true', 'Query executed successfully.', v_result);  
           
    }
    
}