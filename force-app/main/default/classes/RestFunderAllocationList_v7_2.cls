@RestResource(urlMapping='/v7.2/user/invoiceallocations')

global with sharing class RestFunderAllocationList_v7_2 {
    
    @HttpGet   
    global static GlobalMethods.AllocationListReturnClass doGet() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String p_funderAccountId = RestContext.request.params.get('funderAccountId');    
        String p_phase = RestContext.request.params.get('phase');
        String p_ccy = RestContext.request.params.get('ccy');
        String p_overdue = RestContext.request.params.get('overdue');   
        
        List<Invoice_Allocation__c> v_result = new List<Invoice_Allocation__c> (); 
        Map<String,String> v_phases = new Map<String,String>{
            'onmarketplace' => '2:ON MARKETPLACE',
            'inprogress' => '3:IN PROGRESS',
            'closed' => '4:CLOSED'
        };    
        Map<String,String> v_status = new Map<String,String>{
            'onmarketplace' => 'Reservation',
            'inprogress' => 'Confirmed',
            'closed' => 'Repaid invoice deal closed'
        };
        String v_SFphase;
        String v_SFstatus;
        
        String v_listQuery = 'SELECT Incomlend_commision__c, Funder_Agent_Commission_Amount__c, funder_discount_amount__c, Total_commission__c, Invoice__r.Invoice_name__c, Invoice__r.over_due_days__c, Invoice__r.calculated_expected_payment_date__c, Invoice__r.Actual_Repayment_Received_Date__c, Invoice__r.Expected_Payment_Date__c, Invoice__r.financing_period_for_calcs__c, Invoice__r.supplier_costs_as_percentage__c, Invoice__r.remaining_amount__c, Invoice__r.submitted_date__c, Invoice__r.buyer_purchase_order_reference__c, Invoice__r.supplier_invoice_reference_number__c, Invoice__r.marketplace_currency_symbol__c, Invoice__r.invoice_amount__c, Invoice__r.expected_financing_period__c, Invoice__r.Supplier_Buyer_Map__r.Marketplace__c, Invoice__r.Supplier_Buyer_Map__r.Marketplace__r.Name, Invoice__r.Supplier_Buyer_Map__r.months_relationship_with_buyer__c, Invoice__r.auto_status__c,  Invoice__r.Phase__c, Invoice__r.Invoice_date__c, Invoice__r.discount_rate__c, Invoice__r.actual_financing_period__c, Invoice__r.Due_Date__c, Invoice__r.requested_amount__c, Invoice__r.funded_amount__c, Invoice__r.requested_amount_funded_percentage__c, Invoice__r.discount_amount_on_funded_amount__c, Invoice__r.Listing_Start__c, Invoice__r.Listing_End__c, amount__c FROM Invoice_Allocation__c';        
        
        if(GlobalMethods.isValidId(p_funderAccountId) == true) {
            GlobalMethods.AccountReturnClass v_userData = GlobalMethods.getUserData(p_funderAccountId);
            if(v_userData.v_success == 'true' && v_userData.v_records.Sub_type__c == 'Purchaser') {
                v_listQuery = v_listQuery+' WHERE Funder__r.Id=:p_funderAccountId'; 
            } else {
                return new GlobalMethods.AllocationListReturnClass('false','Invalid user', null);
            }
        } else {
            return new GlobalMethods.AllocationListReturnClass('false','Invalid user account Id', null);
        }      
                
        if(GlobalMethods.isvalidCurrency(p_ccy) == true) {
            v_listQuery = v_listQuery+' AND CCY__c=:p_ccy'; 
        } else {
            return new GlobalMethods.AllocationListReturnClass('false','Invalid currency', null);
        }
        
        if(v_phases.get(p_phase) != null) {
            v_SFphase = v_phases.get(p_phase);
            v_SFstatus = v_status.get(p_phase);
            v_listQuery = v_listQuery+' AND Invoice__r.Phase__c=:v_SFphase and Status__c=:v_SFstatus';
        }else {
            return new GlobalMethods.AllocationListReturnClass('false','Invalid phase', null);
        }
        
        if(p_overdue == 'true') {
            v_listQuery = v_listQuery+' AND Invoice__r.overdue__c=true';
        }else if(p_overdue == 'false') {
            v_listQuery = v_listQuery+' AND Invoice__r.overdue__c=false';
        } 
        
        v_result = database.query(v_listQuery);
        return new GlobalMethods.AllocationListReturnClass('true', 'Query executed successfully.', v_result);
       
    }
    
}