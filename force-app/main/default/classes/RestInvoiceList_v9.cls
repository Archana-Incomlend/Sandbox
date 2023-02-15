@RestResource(urlMapping='/v9/invoices')

global with sharing class RestInvoiceList_v9 {
    
    @HttpGet   
    global static GlobalMethods_v9.InvoiceListReturnClass doGet() {
        
        System.debug('RestInvoiceList_v9 call');
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<invoice_finance_deal__c> v_result = new List<invoice_finance_deal__c> ();
        String p_marketplaceId = RestContext.request.params.get('marketplace');
        String p_phase = RestContext.request.params.get('phase');
        String p_ccy = RestContext.request.params.get('ccy');
        String p_supplierAccountId = RestContext.request.params.get('supplierAccountId');
        String p_buyerAccountId = RestContext.request.params.get('buyerAccountId');
        String p_mapId = RestContext.request.params.get('mapId');
        String p_overdue = RestContext.request.params.get('overdue');
        String p_passthrough = RestContext.request.params.get('passthrough');
        String p_supplier_approval_status = RestContext.request.params.get('supplierApprovalStatus');
        String p_secondaryMarketplace = RestContext.request.params.get('secondaryMarketplace');
        
        String p_trustee = RestContext.request.params.get('trustee');
        String p_trusteeName = null;
        String p_delayed = 'Overdue';
        List<String> p_notDelayed = new List<String>{'Pending', 'In Progress'};
            if (!String.isBlank(p_trustee)) {
                p_trusteeName = p_trustee;
            }
        
        
        String v_SFphase ;
        Map<String,String> v_phases = new Map<String,String>{
            'prelisting' => '1:PRE LISTING',
            'onmarketplace' => '2:ON MARKETPLACE',
            'inprogress' => '3:IN PROGRESS',
            'closed' => '4:CLOSED'
        };

        String pre_v_listQuery = 'SELECT Amount_Overdue__c, Trustee__c, Name, platform_fee_variable_amount__c, due_date_delta_bucket__c, Buyer_Confirmation_Status__c, supplier_approval_status__c, Map_Product__r.Name, CCY__c, Earliest_date_of_funding__c, Supplier_Buyer_Map__r.Supplier__r.Name, OVERDUE__c, Supplier_Buyer_Map__r.Marketplace__r.Name, Supplier_Buyer_Map__r.Incomlend_product__r.Name, over_due_days__c, calculated_expected_payment_date__c, Actual_Repayment_Received_Date__c, Expected_Payment_Date__c, financing_period_for_calcs__c, supplier_costs_as_percentage__c, total_fees_and_discount_paid_by_supplier__c, remaining_amount__c, submitted_date__c, buyer_purchase_order_reference__c, supplier_invoice_reference_number__c, marketplace_currency_symbol__c, invoice_amount__c, expected_financing_period__c, Supplier_Buyer_Map__r.Marketplace__c, Supplier_Buyer_Map__r.months_relationship_with_buyer__c, Listing_Start__c, Listing_End__c, auto_status__c, Phase__c, Invoice_date__c, Invoice_name__c, id, discount_rate__c, actual_financing_period__c, Due_Date__c, requested_amount__c, funded_amount__c, requested_amount_funded_percentage__c, discount_amount_on_funded_amount__c, discount_amount_if_fully_funded__c, credit_insurance_fee__c, platform_fee_fixed__c, Total_Supplier_Discount__c, Real_Face_Value__c, Total_overdue_cost_Supplier__c, Buyer_Country__c, Supplier_Country__c, Country_of_Origin__c, Country_of_Destination__c, credit_insured__c, Insured_by__c, Supplier_Buyer_Map__r.Age_of_the_map__c, Sector__c, Goods_and_Services_new__c, Product_type__c';
        pre_v_listQuery += ', Display_on_Secondary_Marketplace__c, Supplier_Buyer_Map__r.map_onboarding_stage__c';
        pre_v_listQuery += ' FROM invoice_finance_deal__c ';
        String v_listQuery = '';
        
        if(!String.isBlank(p_supplierAccountId)) {
            if(GlobalMethods_v9.isValidId(p_supplierAccountId) == true) {
                GlobalMethods_v9.AccountReturnClass v_userData = GlobalMethods_v9.getUserData(p_supplierAccountId);
                if(v_userData.v_success == 'true' && v_userData.v_records.Sub_type__c == 'Supplier') {
                    v_listQuery = v_listQuery+' AND (';
                    v_listQuery = v_listQuery+' Supplier_Buyer_Map__r.Supplier__c=:p_supplierAccountId'; 
                    v_listQuery = v_listQuery+' OR Map_Extension__r.Account__c=:p_supplierAccountId'; 
                    v_listQuery = v_listQuery+' )';
                }else {
                    return new GlobalMethods_v9.InvoiceListReturnClass('false','Invalid user', null);
                }
            }else {
                return new GlobalMethods_v9.InvoiceListReturnClass('false','Invalid user ID', null);
            }
        }
        
        if(!String.isBlank(p_buyerAccountId)) {
            if(GlobalMethods_v9.isValidId(p_buyerAccountId) == true) {
                GlobalMethods_v9.AccountReturnClass v_userData = GlobalMethods_v9.getUserData(p_buyerAccountId);
                if(v_userData.v_success == 'true' && v_userData.v_records.Type == 'Buyer') {
                    v_listQuery = v_listQuery+' AND Supplier_Buyer_Map__r.Buyer__r.Id=:p_buyerAccountId';
                }else {
                    return new GlobalMethods_v9.InvoiceListReturnClass('false','Invalid user', null);
                }
            }else {
                return new GlobalMethods_v9.InvoiceListReturnClass('false','Invalid user ID', null);
            }
        }   
        
        if(!String.isBlank(p_mapId)) {
            if(GlobalMethods_v9.isValidId(p_mapId) == true) {
                v_listQuery = v_listQuery+' AND Supplier_Buyer_Map__c=:p_mapId';
            }else {
                return new GlobalMethods_v9.InvoiceListReturnClass('false','Invalid supplier buyer map Id', null);
            }
        }        
        
        if(!String.isBlank(p_marketplaceId)) {
            if(GlobalMethods_v9.isValidId(p_marketplaceId) == false) {
                return new GlobalMethods_v9.InvoiceListReturnClass('false','Invalid marketplace Id', null);
            }
            v_listQuery = v_listQuery+' AND Marketplace_link__r.Id=:p_marketplaceId';
        }
        
        if(!String.isBlank(p_ccy)) {
            if(GlobalMethods_v9.isvalidCurrency(p_ccy) == true) {
                v_listQuery = v_listQuery+' AND CCY__c=:p_ccy';
            } else {
                return new GlobalMethods_v9.InvoiceListReturnClass('false','Invalid currency', null);
            }
        }
        
        if(!String.isBlank(p_trusteeName)) {
            v_listQuery = v_listQuery+' AND Trustee__c =:p_trusteeName'; 
        }
        
        if(!String.isBlank(p_phase)) {
            if(v_phases.get(p_phase) != null) {
                v_SFphase = v_phases.get(p_phase);
                v_listQuery = v_listQuery+' AND phase__c=:v_SFphase';
            }else {
                return new GlobalMethods_v9.InvoiceListReturnClass('false','Invalid phase', null);
            }
        }
        
        if(p_overdue == 'true') {
            v_listQuery = v_listQuery+' AND ((overdue__c=true AND Repayment_Agreement__c = NULL) OR (Repayment_Agreement__c != NULL AND Repayment_Agreement__r.Status__c = :p_delayed))';
        }else if(p_overdue == 'false') {
            v_listQuery = v_listQuery+' AND (overdue__c=false OR (Repayment_Agreement__c != NULL AND Repayment_Agreement__r.Status__c IN :p_notDelayed))';
        } 
        
        if(p_passthrough == 'true') {
            v_listQuery = v_listQuery+' AND passthrough__c=true';
        }else if(p_passthrough == 'false') {
            v_listQuery = v_listQuery+' AND passthrough__c=false';
        }
        
        string v_approved = 'Approved';
        if(p_supplier_approval_status != null) {    
            if(p_supplier_approval_status == 'Approved') {
                v_listQuery = v_listQuery+' AND supplier_approval_status__c=\'Approved\'';
            }else if(p_supplier_approval_status != 'Approved') {
                v_listQuery = v_listQuery+' AND supplier_approval_status__c<>:v_approved';
            }
        }
        if(p_secondaryMarketplace == 'true'){
            v_listQuery = v_listQuery+' AND Display_on_Secondary_Marketplace__c = true';
        }
        if (v_listQuery.startsWith(' AND ')) {
            v_listQuery = ' WHERE ' + v_listQuery.substring(5);
        }
        v_listQuery = pre_v_listQuery + v_listQuery;
        try {
            v_result = database.query(v_listQuery);
        } catch (Exception ex) {
            System.debug('queryString:' + Pattern.compile('(.{200})').matcher(v_listQuery).replaceAll('$1\n'));
            throw ex;
        }
        return new GlobalMethods_v9.InvoiceListReturnClass('true', 'Query executed successfully.', v_result);
        
    }    
}