@RestResource(urlMapping='/v9/invoice/duedatedelta')

global with sharing class RestDueDateDeltaStats_v9 {
      
    @HttpGet
    global static GlobalMethods_v9.StringMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        map<String,String> v_result = new Map<String,String>();
        String p_marketplaceId = RestContext.request.params.get('marketplace');
        String p_phase = RestContext.request.params.get('phase');
        String p_ccy = RestContext.request.params.get('ccy');
        String p_supplierAccountId = RestContext.request.params.get('supplierAccountId');
        String p_buyerAccountId = RestContext.request.params.get('buyerAccountId');
        String p_mapId = RestContext.request.params.get('mapId');
        String p_fieldset = RestContext.request.params.get('fieldset');
        String p_option = RestContext.request.params.get('option');
        
        String v_SFphase ;
        Map<String,String> v_phases = new Map<String,String>{
            'prelisting' => '1:PRE LISTING',
            'onmarketplace' => '2:ON MARKETPLACE',
            'inprogress' => '3:IN PROGRESS',
            'closed' => '4:CLOSED'
        };
         Map<String,String> v_FieldSet = new Map<String,String>{
            'deltaBucketCount' => 'COUNT(Id)deltaBucketCount',
            'totalAdvanced' => 'SUM(requested_amount__c)totalAdvanced',
            'totalRequestedUSD' => 'SUM(requested_amount_usd_equiv__c)totalRequestedUSD',
            'totalinvoiceUSD' => 'SUM(invoice_amount_USD_Equivalent__c)totalinvoiceUSD'
        };
        string v_field;
        String v_bucket;
        String v_fieldvalue;
        
        if(v_FieldSet.get(p_fieldset) != null) {
            v_field = v_FieldSet.get(p_fieldset);
        }else {
            return new GlobalMethods_v9.StringMapReturnClass('false','Field set parameter is missing or invalid value', null);
        }
        
        String v_listQuery = 'SELECT due_date_delta_bucket_value__c bucket, ' + v_field + ' FROM invoice_finance_deal__c ';
        
        if(v_phases.get(p_phase) != null) {
            v_SFphase = v_phases.get(p_phase);
            v_listQuery = v_listQuery +' WHERE phase__c=:v_SFphase';
        }else {
            return new GlobalMethods_v9.StringMapReturnClass('false','Phase parameter is missing or invalid value', null);
        }
        
        if(p_buyerAccountId != null) {
            if(GlobalMethods_v9.isValidId(p_buyerAccountId) == false) {
                return new GlobalMethods_v9.StringMapReturnClass('false','Invalid buyerAccountId', null);
            }else { 
                v_listQuery = v_listQuery + ' and supplier_buyer_map__r.Buyer__r.Id =:p_buyerAccountId';
            }
        }
        
        if(p_marketplaceId != null) {
            if(GlobalMethods_v9.isValidId(p_marketplaceId) == false) {
                return new GlobalMethods_v9.StringMapReturnClass('false','Invalid Marketplace Id', null);
            }else {
                 v_listQuery = v_listQuery + ' and Marketplace_link__c =:p_marketplaceId';
            } 
        }
        
        if(p_mapId != null) {
            if(GlobalMethods_v9.isValidId(p_mapId) == false) {
                return new GlobalMethods_v9.StringMapReturnClass('false','Invalid map Id', null);
            }else { 
                v_listQuery = v_listQuery + ' and supplier_buyer_map__c =:p_mapId';
            }
        }
        
        if(p_option == 'due') {
            v_listQuery = v_listQuery + ' and due_date_delta__c >= 0';
        }else if(p_option == 'overdue') {
            v_listQuery = v_listQuery + ' and due_date_delta__c < 0';
        }       
             
        v_listQuery = v_listQuery + ' AND due_date_delta_bucket_value__c !=null GROUP BY due_date_delta_bucket_value__c'; 
        System.debug('v_listQuery: '+ v_listQuery);
        List<SObject>  v_records = database.query(v_listQuery);        
      
       for( Sobject ar : v_records) {
         
            v_bucket = String.valueOf(ar.get('bucket'));
            v_bucket = v_bucket.replace('Due ', '');
            v_bucket = v_bucket.replace('Overdue ', '');
            
            v_fieldvalue = String.valueOf(ar.get(p_fieldset));
            v_result.put(v_bucket, v_fieldvalue);
            
        }
              
        return new GlobalMethods_v9.StringMapReturnClass('true', 'Query executed successfully.', v_result);
    }
}