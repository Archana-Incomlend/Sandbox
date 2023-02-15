@RestResource(urlMapping='/v1/buyer/invoices/*')

global with sharing class RestBuyerInvoices_v1 {
    
    @HttpGet   
    global static ReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String mapId = URLParams[URLParams.size()-1];    
        String phase  =   URLParams[URLParams.size()-2]; 
        
        if(RestUserLogin.isValidId(mapId) == false) {
        
            return new ReturnClass('false','Invalid Supplier buyer map ID', null);
        }  
                
        String listQuery = 'SELECT Name, CCY__c, Supplier_Buyer_Map__r.Marketplace__r.Name, Supplier_Buyer_Map__r.Incomlend_product__r.Name, over_due_days__c, calculated_expected_payment_date__c, Actual_Repayment_Received_Date__c, Expected_Payment_Date__c, financing_period_for_calcs__c, supplier_costs_as_percentage__c, total_fees_and_discount_paid_by_supplier__c, remaining_amount__c, submitted_date__c, buyer_purchase_order_reference__c, supplier_invoice_reference_number__c, marketplace_currency_symbol__c, invoice_amount__c, expected_financing_period__c, Supplier_Buyer_Map__r.Marketplace__c, Supplier_Buyer_Map__r.months_relationship_with_buyer__c, Listing_Start__c, Listing_End__c, auto_status__c, Phase__c, Invoice_date__c, Invoice_name__c, id, discount_rate__c, actual_financing_period__c, Due_Date__c, requested_amount__c, funded_amount__c, requested_amount_funded_percentage__c, discount_amount_on_funded_amount__c, discount_amount_if_fully_funded__c, credit_insurance_fee__c, platform_fee_fixed__c FROM Invoice_Finance_Deal__c WHERE Supplier_Buyer_Map__c=:mapId ';
        
        String SFphase ;
        if(phase == 'onmarketplace') {
            SFphase = '2:ON MARKETPLACE';
        }else if(phase == 'inprogress') {
            SFphase = '3:IN PROGRESS';
        }else if(phase == 'closed') {
            SFphase = '4:CLOSED';
        }else if(phase == 'prelisting') {
            SFphase = '1:PRE LISTING';
        }else {
            return new ReturnClass('false','Invalid phase', null);
        }
        
        if(SFphase != null) {
            listQuery = listQuery+' AND phase__c=:SFphase';
        }
        
        try {
             List<Invoice_Finance_Deal__c> invoiceList = database.query(listQuery);
             return new ReturnClass('true', 'Query executed successfully.', invoiceList);
    
        } catch (Exception e) {
              return new ReturnClass('false', e.getMessage(), null);
        }    
           
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global List<Invoice_Finance_Deal__c> records;

        global ReturnClass(String success, String message, List<Invoice_Finance_Deal__c> records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }

    
}