@RestResource(urlMapping='/v9.2/funder/charts')

global with sharing class RestFunderCharts_v9_2 {
      
    @HttpGet
    global static GlobalMethods_v9.StringMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        map<String,String> v_result = new Map<String,String>();

        String p_ccy = RestContext.request.params.get('ccy');
        String p_funderAccountId = RestContext.request.params.get('funderAccountId');
        String p_type = RestContext.request.params.get('type');
                
        Map<String,String> v_statuses = new Map<String,String>{
            'buyer' => '\'Confirmed\'',
            'industry' => '\'Confirmed\',\'Repaid invoice deal closed\''
        };
        
        Map<String,String> v_phases = new Map<String,String>{
            'buyer' => '\'3:IN PROGRESS\'',
            'industry' => '\'2:ON MARKETPLACE\',\'3:IN PROGRESS\', \'4:CLOSED\''
        };
        
        Map<String,String> v_groups = new Map<String,String>{
            'buyer' => 'Buyer_name_value__c',
            'industry' => 'Supplier_industry_value__c'
        };
       
        Map<String,String> v_fieldSet = new Map<String,String>{
            'buyer' => ' Buyer_name_value__c buyer, SUM(amount__c)fundedAmount ',
            'industry' => ' Supplier_industry_value__c industry, SUM(amount__c)fundedAmount '
        };
        
        String v_chartquery;
        String v_group;
        String v_field;
        string v_buyer;
        string v_industry;
        String v_phase;
        String v_status;
        String v_key;
        String v_value;
        String v_totalQuery;
        
        Decimal v_totalFundedAmount=0;
        Decimal v_availableEwallet=0;
        Decimal v_denom;
        Decimal v_fundedAmount=0;
        Decimal v_exposure = 0;
        Decimal v_cash = 0;
                
        if(p_funderAccountId != null) {
            if(GlobalMethods_v9.isValidId(p_funderAccountId) == false) {
                return new GlobalMethods_v9.StringMapReturnClass('false','Invalid funder AccountId', null);
            }
        }
        
        if(GlobalMethods_v9.isvalidCurrency(p_ccy) == false) {
            return new GlobalMethods_v9.StringMapReturnClass('false','Invalid currency', null);
        }
       
        if(v_fieldSet.get(p_type) != null) {
            v_field = v_fieldSet.get(p_type);
            v_group = v_groups.get(p_type);
            v_phase = v_phases.get(p_type);
            v_status = v_statuses.get(p_type);
            
        }else {
            return new GlobalMethods_v9.StringMapReturnClass('false','Type parameter is missing or invalid value', null);
        }
        
        v_totalQuery = 'SELECT SUM(amount__c)progressAllocationTotal FROM Invoice_Allocation__c WHERE Funder__c=:p_funderAccountId AND CCY__c=:p_ccy AND Status__c IN ('+v_status+') AND Invoice__r.Phase__c IN ('+v_phase+') AND '+v_group +'!=null';
        List<SObject>  v_groupedResults = database.query(v_totalQuery);  
        for(SObject ar : v_groupedResults){
            if((Decimal)(ar.get('progressAllocationTotal')) != null) {
               v_totalFundedAmount = (Decimal)(ar.get('progressAllocationTotal'));
            } 
        }
        
        try {
            v_availableEwallet = GlobalMethods_v9.getAvailableEwallet(p_funderAccountId, p_ccy);
        } catch(GeneralException e) {
            return new GlobalMethods_v9.StringMapReturnClass('false',e.getMessage(), null);
        } 
        
        if(p_type == 'buyer') {
            v_denom = v_totalFundedAmount + v_availableEwallet;
            v_cash = ((v_availableEwallet/v_denom)*100).setScale(2, RoundingMode.HALF_UP);
            v_result.put('Cash', String.valueOf(v_cash));
        }else if(p_type == 'industry') {
            v_denom = v_totalFundedAmount;
        }
        
        v_chartquery = 'SELECT '+v_field + ' FROM Invoice_Allocation__c WHERE Funder__c=:p_funderAccountId AND CCY__c=:p_ccy AND Status__c IN ('+v_status+') AND Invoice__r.Phase__c IN ('+v_phase+') AND '+v_group +'!=null GROUP BY '+ v_group;
               
        List<SObject>  v_records = database.query(v_chartquery);        
        
        for( Sobject ar : v_records) {
            v_key = String.valueOf(ar.get(p_type));
            if((Decimal)(ar.get('fundedAmount')) != null) {
                v_exposure = (((Decimal)(ar.get('fundedAmount'))/v_denom)*100).setScale(2, RoundingMode.HALF_UP);
            } 
            v_result.put(v_key, String.valueOf(v_exposure));
                                        
        }

        return new GlobalMethods_v9.StringMapReturnClass('true', 'Query executed successfully.', v_result);
    }
}