@RestResource(urlMapping='/v7.1/invoices')

global with sharing class RestInvoiceList_v7_1 {
    
    @HttpGet   
    global static GlobalMethods.InvoiceListReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
                
        List<invoice_finance_deal__c> v_result = new List<invoice_finance_deal__c> ();
        String p_marketplaceId = RestContext.request.params.get('marketplace');
        String p_phase = RestContext.request.params.get('phase');
        String p_ccy = RestContext.request.params.get('ccy');
        String p_supplierAccountId = RestContext.request.params.get('supplierAccountId');
        String p_buyerAccountId = RestContext.request.params.get('buyerAccountId');
        String p_mapId = RestContext.request.params.get('mapId');
    
    //    String p_overdue = RestContext.request.params.get('overdue');   
   //    String p_passthrough = RestContext.request.params.get('passthrough');
        String p_supplier_approval_status = RestContext.request.params.get('supplierApprovalStatus');
       
                
        String v_SFphase ;
         Map<String,String> v_phases = new Map<String,String>{
            'prelisting' => '1:PRE LISTING',
            'onmarketplace' => '2:ON MARKETPLACE',
            'inprogress' => '3:IN PROGRESS',
            'closed' => '4:CLOSED'
        };

        String v_listQuery = 'SELECT Name, due_date_delta_bucket__c, Buyer_Confirmation_Status__c, supplier_approval_status__c, Map_Product__r.Name, CCY__c, Earliest_date_of_funding__c, Supplier_Buyer_Map__r.Supplier__r.Name, OVERDUE__c, Supplier_Buyer_Map__r.Marketplace__r.Name, Supplier_Buyer_Map__r.Incomlend_product__r.Name, over_due_days__c, calculated_expected_payment_date__c, Actual_Repayment_Received_Date__c, Expected_Payment_Date__c, financing_period_for_calcs__c, supplier_costs_as_percentage__c, total_fees_and_discount_paid_by_supplier__c, remaining_amount__c, submitted_date__c, buyer_purchase_order_reference__c, supplier_invoice_reference_number__c, marketplace_currency_symbol__c, invoice_amount__c, expected_financing_period__c, Supplier_Buyer_Map__r.Marketplace__c, Supplier_Buyer_Map__r.months_relationship_with_buyer__c, Listing_Start__c, Listing_End__c, auto_status__c, Phase__c, Invoice_date__c, Invoice_name__c, id, discount_rate__c, actual_financing_period__c, Due_Date__c, requested_amount__c, funded_amount__c, requested_amount_funded_percentage__c, discount_amount_on_funded_amount__c, discount_amount_if_fully_funded__c, credit_insurance_fee__c, platform_fee_fixed__c FROM invoice_finance_deal__c ';
               
        if(p_supplierAccountId != null) {
            if(GlobalMethods.isValidId(p_supplierAccountId) == true) {
                GlobalMethods.AccountReturnClass v_userData = GlobalMethods.getUserData(p_supplierAccountId);
                if(v_userData.v_success == 'true' && v_userData.v_records.Sub_type__c == 'Supplier') {
                    v_listQuery = v_listQuery+' WHERE Supplier_Buyer_Map__r.Supplier__r.Id=:p_supplierAccountId'; 
                }else {
                    return new GlobalMethods.InvoiceListReturnClass('false','Invalid user', null);
                }
            }else {
                return new GlobalMethods.InvoiceListReturnClass('false','Invalid user ID', null);
            }
        }
         
        if(p_buyerAccountId != null) {
            if(GlobalMethods.isValidId(p_buyerAccountId) == true) {
                GlobalMethods.AccountReturnClass v_userData = GlobalMethods.getUserData(p_buyerAccountId);
                if(v_userData.v_success == 'true' && v_userData.v_records.Type == 'Buyer') {
                    v_listQuery = v_listQuery+' WHERE Supplier_Buyer_Map__r.Buyer__r.Id=:p_buyerAccountId'; 
                }else {
                    return new GlobalMethods.InvoiceListReturnClass('false','Invalid user', null);
                }
            }else {
                return new GlobalMethods.InvoiceListReturnClass('false','Invalid user ID', null);
            }
        }
        
        if(p_mapId != null) {
            if(GlobalMethods.isValidId(p_mapId) == true) {
                v_listQuery = v_listQuery+' WHERE Supplier_Buyer_Map__c=:p_mapId'; 
            }else {
                return new GlobalMethods.InvoiceListReturnClass('false','Invalid supplier buyer map Id', null);
            }
        }        
        
        if(p_marketplaceId != null) {
            if(GlobalMethods.isValidId(p_marketplaceId) == false) {
                return new GlobalMethods.InvoiceListReturnClass('false','Invalid marketplace Id', null);
            }
            v_listQuery = v_listQuery+' WHERE Marketplace_link__r.Id=:p_marketplaceId'; 
        }
        
        if(p_ccy != null) {
            if(GlobalMethods.isvalidCurrency(p_ccy) == true) {
                v_listQuery = v_listQuery+' AND CCY__c=:p_ccy';
            } else {
                return new GlobalMethods.InvoiceListReturnClass('false','Invalid currency', null);
            }
        }
        
        if(v_phases.get(p_phase) != null) {
            v_SFphase = v_phases.get(p_phase);
            v_listQuery = v_listQuery+' AND phase__c=:v_SFphase';
        }else {
            return new GlobalMethods.InvoiceListReturnClass('false','Phase parameter is missing or invalid value', null);
        }
       
       
       
   /*    if(p_overdue == 'true') {
                 v_listQuery = v_listQuery+' AND overdue__c=true';
        }     
        
       if(p_overdue == 'false') {
                 v_listQuery = v_listQuery+' AND overdue__c=false';
        }      
 
       if(p_passthrough == 'true') {
                 v_listQuery = v_listQuery+' AND passthrough__c=true';
        }*/
       
              
       if(p_supplier_approval_status == 'Approved') {
        
                 v_listQuery = v_listQuery+' AND supplier_approval_status__c=\'Approved\'';
        }
        
        if(p_supplier_approval_status != 'Approved') {
                  string v_approved = 'Approved';
                 v_listQuery = v_listQuery+' AND supplier_approval_status__c<>:v_approved';
        }
       
        v_result = database.query(v_listQuery);
        return new GlobalMethods.InvoiceListReturnClass('true', 'Query executed successfully.', v_result);

    }    
}