@RestResource(urlMapping='/v9.1/supplier/stats/*')

global with sharing class RestSupplierStats_v9_1 {
    
    @HttpGet   
    global static GlobalMethods_v9.DecimalMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
        String p_supplierAccountId = URLParams[URLParams.size()-1];        
        String p_ccy = URLParams[URLParams.size()-2]; 
        String v_closedPhase = '4:CLOSED';
        String v_closedStatus = 'repaid (closed)';
        
        map<String,Decimal> v_result = new Map<String,Decimal>();
        
        String v_statsQuery = 'SELECT SUM(funded_amount__c)totalFundedAmount, SUM(requested_amount__c)totalRequestedAmount, AVG(discount_rate__c)averageDiscount, AVG(supplier_costs_as_percentage__c)averageSupplierCost, SUM(credit_insurance_fee__c)totalCreditInsurance, SUM(Platform_fee_variable_amount__c)totalPlatformFee, SUM(discount_amount_on_funded_amount__C )totalDiscount, SUM(advanced_amount__C)totalAdvanced FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__r.Supplier__r.Id=:p_supplierAccountId AND phase__C IN (\'2:ON MARKETPLACE\',\'3:IN PROGRESS\',\'4:CLOSED\')';
       
        if(p_ccy != 'all') {
            if(GlobalMethods_v9.isvalidCurrency(p_ccy) == false) {
                return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid currency', null);
            }else {
                v_statsQuery = v_statsQuery+' AND CCY__c=:p_ccy';
            }
        }
        if(GlobalMethods_v9.isValidId(p_supplierAccountId) == false) {
            return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid User ID', null);
        }  
        
        GlobalMethods_v9.AccountReturnClass v_userData = GlobalMethods_v9.getUserData(p_supplierAccountId);
        if(v_userData.v_success == 'true' && v_userData.v_records.Type == 'Customer' && v_userData.v_records.Sub_type__c == 'Supplier') {
            
            AggregateResult[] v_groupedResults = database.query(v_statsQuery);
            for(AggregateResult ar : v_groupedResults){
                Decimal v_fundingEfficiency = (Decimal)(0);
                if((Decimal)(ar.get('totalAdvanced')) != null && (Decimal)(ar.get('totalRequestedAmount')) != null) {
                    v_fundingEfficiency = (((Decimal) ar.get('totalAdvanced')/(Decimal) ar.get('totalRequestedAmount')).setScale(2))*100;
                }
                
                v_result.put('fundingEfficiency', v_fundingEfficiency);
                v_result.put('averageDiscount', (Decimal)(ar.get('averageDiscount')));
                v_result.put('averageSupplierCost', (Decimal)(ar.get('averageSupplierCost')));
                v_result.put('totalCreditInsurance', (Decimal)(ar.get('totalCreditInsurance')));
                v_result.put('totalPlatformFee', (Decimal)(ar.get('totalPlatformFee')));
                v_result.put('totalDiscount', (Decimal)(ar.get('totalDiscount')));
                v_result.put('totalAdvanced', (Decimal)(ar.get('totalAdvanced')));
            }
            
            for(AggregateResult ar : [SELECT AVG(over_due_days__c)averageDelay FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__r.Supplier__r.Id=:p_supplierAccountId AND CCY__c=:p_ccy AND Phase__c=:v_closedPhase AND auto_status__c=:v_closedStatus]) {
                if((Decimal)(ar.get('averageDelay')) != null) {
                    v_result.put('averageDelay', ((Decimal)(ar.get('averageDelay'))).setScale(0));
                }else {
                    v_result.put('averageDelay', (Decimal)(0));
                }
            }
            
            for(AggregateResult ar : [SELECT phase__C phase, SUM(remaining_amount__c)totalRemaining, SUM(funded_amount__c)totalFunded FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__r.Supplier__r.Id=:p_supplierAccountId AND CCY__c=:p_ccy GROUP BY phase__C]) {
                String v_phase = (string)(ar.get('phase'));
                v_phase = v_phase.replace(' ', '_');
                v_phase = v_phase.replace(':', '_');
                Decimal v_totalRemaining = (Decimal) ar.get('totalRemaining');
                Decimal v_totalFunded = (Decimal) ar.get('totalFunded');
            
                v_result.put(v_phase+'_totalRemaining', v_totalRemaining);
                v_result.put(v_phase+'_totalFunded', v_totalFunded);
            }
            return new GlobalMethods_v9.DecimalMapReturnClass('true', 'Query executed successfully.', v_result);
            
        }else {
            return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid User', null);
        }
    }
}