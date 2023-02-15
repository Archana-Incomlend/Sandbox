@RestResource(urlMapping='/v1/buyer/stats/*')

global with sharing class RestBuyerStats_v1 {
    
    @HttpGet   
    global static ReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String mapId = URLParams[URLParams.size()-1];        
        
        map<String,Decimal> result = new Map<String,Decimal>();
        
        String statsQuery1 = 'SELECT SUM(credit_insurance_fee__c)totalCreditInsurance, SUM(Platform_fee_variable_amount__c)totalPlatformFee, SUM(advanced_amount__C)totalAdvanced FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__c=:mapId AND phase__C IN (\'2:ON MARKETPLACE\',\'3:IN PROGRESS\',\'4:CLOSED\')';
        String statsQuery2 = 'SELECT SUM(Total_Financing_value_alltime__c)totalFinancingAlltime, SUM(number_of_invoices_all_time__c)totalInvoicesAlltime FROM Supplier_Buyer_Map__c WHERE Id=:mapId';      
        
        if(RestUserLogin.isValidId(mapId) == false) {
        
            return new ReturnClass('false','Invalid Supplier buyer map ID', null);
        }  
        
        try {
                AggregateResult[] groupedResults1 = database.query(statsQuery1);
                 
                for(AggregateResult ar : groupedResults1){
                    result.put('totalCreditInsurance', (Decimal)(ar.get('totalCreditInsurance')));
                    result.put('totalPlatformFee', (Decimal)(ar.get('totalPlatformFee')));
                    result.put('totalAdvanced', (Decimal)(ar.get('totalAdvanced')));
                }
                
                AggregateResult[] groupedResults2 = database.query(statsQuery2);
                 
                for(AggregateResult ar : groupedResults2){
                    result.put('totalFinancingAlltime', (Decimal)(ar.get('totalFinancingAlltime')));
                    result.put('totalInvoicesAlltime', (Decimal)(ar.get('totalInvoicesAlltime')));
                }
                
                 for(AggregateResult ar : [SELECT phase__C phase, SUM(remaining_amount__c)totalRemaining, SUM(funded_amount__c)totalFunded FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__c=:mapId GROUP BY phase__C]) {
    
                  String phase = (string)(ar.get('phase'));
                  phase = phase.replace(' ', '_');
                  phase = phase.replace(':', '_');
                  Decimal totalRemaining = (Decimal) ar.get('totalRemaining');
                  Decimal totalFunded = (Decimal) ar.get('totalFunded');
            
                  result.put(phase+'_totalRemaining', totalRemaining);
                  result.put(phase+'_totalFunded', totalFunded);
                }
    
                 return new ReturnClass('true', 'Query executed successfully.', result);
        
            } catch (Exception e) {
                return new ReturnClass('false', e.getMessage(), null);
            }    
           
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global map<String,Decimal> records;

        global ReturnClass(String success, String message, map<String,Decimal> records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }

    
}