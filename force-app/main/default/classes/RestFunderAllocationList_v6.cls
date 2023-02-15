@RestResource(urlMapping='/v6/user/invoiceallocations/*')

global with sharing class RestFunderAllocationList_v6 {
    
    @HttpGet   
    global static ReturnClass doGet() {

        String listQuery = '';        
        listQuery = 'SELECT Incomlend_commision__c, Funder_Agent_Commission_Amount__c, funder_discount_amount__c, Total_commission__c, Invoice__r.Invoice_name__c, Invoice__r.over_due_days__c, Invoice__r.calculated_expected_payment_date__c, Invoice__r.Actual_Repayment_Received_Date__c, Invoice__r.Expected_Payment_Date__c, Invoice__r.financing_period_for_calcs__c, Invoice__r.supplier_costs_as_percentage__c, Invoice__r.remaining_amount__c, Invoice__r.submitted_date__c, Invoice__r.buyer_purchase_order_reference__c, Invoice__r.supplier_invoice_reference_number__c, Invoice__r.marketplace_currency_symbol__c, Invoice__r.invoice_amount__c, Invoice__r.expected_financing_period__c, Invoice__r.Supplier_Buyer_Map__r.Marketplace__c, Invoice__r.Supplier_Buyer_Map__r.Marketplace__r.Name, Invoice__r.Supplier_Buyer_Map__r.months_relationship_with_buyer__c, Invoice__r.auto_status__c,  Invoice__r.Phase__c, Invoice__r.Invoice_date__c, Invoice__r.discount_rate__c, Invoice__r.actual_financing_period__c, Invoice__r.Due_Date__c, Invoice__r.requested_amount__c, Invoice__r.funded_amount__c, Invoice__r.requested_amount_funded_percentage__c, Invoice__r.discount_amount_on_funded_amount__c, Invoice__r.Listing_Start__c, Invoice__r.Listing_End__c, amount__c FROM Invoice_Allocation__c';
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String funderId = URLParams[URLParams.size()-1];        
        String phase = URLParams[URLParams.size()-2];  
        String ccy = URLParams[URLParams.size()-3];      
        
        /* funder ID check */      
        if(funderId != null) {
            if(RestUserLogin.isValidId(funderId) == true) {
        
                Account userData = RestUserLogin.validateUser(funderId);
            
                if(userData.Sub_type__c == 'Purchaser') {
                    listQuery = listQuery+' WHERE Funder__r.Id=:funderId'; 
                } else {
                    return new ReturnClass('false','Invalid user', null);
                }
            } else {
                return new ReturnClass('false','Invalid user ID', null);
            }    
        } else {
            return new ReturnClass('false','Invalid funder ID', null);
        }              
        /* Currency check */
        if(GlobalMethods.isvalidCurrency(ccy) == true) {
            listQuery = listQuery+' AND CCY__c=:ccy'; 
        } else {
            return new ReturnClass('false','Invalid currency', null);
        }
        
        /* phase check and setting status */
        String SFphase;
        String status;
        if(phase != null) {
            if(phase == 'onmarketplace') {
                SFphase = '2:ON MARKETPLACE';
                status = 'Reservation';
            }else if(phase == 'inprogress') {
                SFphase = '3:IN PROGRESS';
                status = 'Confirmed';
            }else if(phase == 'closed') {
                SFphase = '4:CLOSED';
                status = 'Repaid invoice deal closed';
            }
            
        } else {
            return new ReturnClass('false','Invalid phase', null);
        }
        
        if(SFphase != null) {
            listQuery = listQuery+' AND Invoice__r.Phase__c=:SFphase and Status__c=:status';
        }else {
            return new ReturnClass('false','Invalid phase', null);
        }
        
        /* executing the query */
        try {
             List<Invoice_Allocation__c> invoiceList = database.query(listQuery);
             return new ReturnClass('true', 'Query executed successfully.', invoiceList);
        } catch (Exception e) {
              return new ReturnClass('false', e.getMessage(), null);
        }
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global List<Invoice_Allocation__c> records;

        global ReturnClass(String success, String message, List<Invoice_Allocation__c> records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }

    
}