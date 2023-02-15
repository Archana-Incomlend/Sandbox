@RestResource(urlMapping='/v9.2/buyer/stats/*')

global with sharing class RestBuyerStats_v9_2 {
    
    @HttpGet   
    global static GlobalMethods_v9.DecimalMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
        String p_mapId = URLParams[URLParams.size()-1];        
        
        map<String,Decimal> v_result = new Map<String,Decimal>();
        String v_closedPhase = '4:CLOSED';
        GlobalMethods_v9.BuyerMapReturnClass v_mapDataResult;
        Supplier_Buyer_Map__c v_mapData;
        Decimal v_declaredDelay;
        Decimal v_actualDelay;
        Decimal v_delayDeviation = 0;
        
        if(GlobalMethods_v9.isValidId(p_mapId) == false) {
            return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid Supplier buyer map ID', null);
        }
        
        String v_statsQuery1 = 'SELECT SUM(credit_insurance_fee__c)totalCreditInsurance, SUM(Platform_fee_variable_amount__c)totalPlatformFee, SUM(advanced_amount__C)totalAdvanced FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__c=:p_mapId AND phase__C IN (\'2:ON MARKETPLACE\',\'3:IN PROGRESS\',\'4:CLOSED\')';
        String v_statsQuery2 = 'SELECT SUM(Total_Financing_value_alltime__c)totalFinancingAlltime, SUM(number_of_invoices_all_time__c)totalInvoicesAlltime FROM Supplier_Buyer_Map__c WHERE Id=:p_mapId';      
        
        AggregateResult[] v_groupedResults1 = database.query(v_statsQuery1);
                 
        for(AggregateResult ar : v_groupedResults1){
            v_result.put('totalCreditInsurance', (Decimal)(ar.get('totalCreditInsurance')));
            v_result.put('totalPlatformFee', (Decimal)(ar.get('totalPlatformFee')));
            v_result.put('totalAdvanced', (Decimal)(ar.get('totalAdvanced')));
        }
              
        AggregateResult[] v_groupedResults2 = database.query(v_statsQuery2);
                 
        for(AggregateResult ar : v_groupedResults2){
            v_result.put('totalFinancingAlltime', (Decimal)(ar.get('totalFinancingAlltime')));
            v_result.put('totalInvoicesAlltime', (Decimal)(ar.get('totalInvoicesAlltime')));
        }
               
        for(AggregateResult ar : [SELECT phase__C phase, SUM(remaining_amount__c)totalRemaining, SUM(funded_amount__c)totalFunded FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__c=:p_mapId GROUP BY phase__C]) {
    
            String v_phase = (string)(ar.get('phase'));
            v_phase = v_phase.replace(' ', '_');
            v_phase = v_phase.replace(':', '_');
            Decimal v_totalRemaining = (Decimal) ar.get('totalRemaining');
            Decimal v_totalFunded = (Decimal) ar.get('totalFunded');
            
            v_result.put(v_phase+'_totalRemaining', v_totalRemaining);
            v_result.put(v_phase+'_totalFunded', v_totalFunded);
        }
        
        v_mapDataResult = GlobalMethods_v9.getBuyerMapData(p_mapId);
        if(v_mapDataResult.v_success == 'false') {
            return new GlobalMethods_v9.DecimalMapReturnClass('false', 'Invalid invoice Id', null);
        }
        v_mapData = v_mapDataResult.v_records;
        v_declaredDelay = v_mapData.Overdue_days__c;
        
        for(AggregateResult ar : [SELECT AVG(over_due_days__c)averageDelay FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__r.Id=:p_mapId AND Phase__c=:v_closedPhase AND passthrough__c=false]) {
            if((Decimal)(ar.get('averageDelay')) != null && (v_declaredDelay != null && v_declaredDelay != 0)) {
                v_actualDelay = (Decimal)(ar.get('averageDelay'));
                v_delayDeviation = (((v_actualDelay/v_declaredDelay)-1)*100).setScale(2);
            }
        }
        v_result.put('delayDeviation', v_delayDeviation);
        
        return new GlobalMethods_v9.DecimalMapReturnClass('true', 'Query executed successfully.', v_result);
           
    }
        
}