@RestResource(urlMapping='/supplier/stats/*')
global with sharing class RestSupplierStats {
    
    @HttpGet   
    global static ReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String supplierId = URLParams[URLParams.size()-1];        
        String marketplace = URLParams[URLParams.size()-2];
        
        map<String,Decimal> result = new Map<String,Decimal>();
       
        if(RestUserLogin.isValidId(marketplace) == false) {
                    
            return new ReturnClass('false','Invalid marketplace ID', null);
        } 
        
        if(RestUserLogin.isValidId(supplierId) == false) {
        
            return new ReturnClass('false','Invalid User ID', null);
        }  
        
        Account userData = RestUserLogin.validateUser(supplierId);
        
        if(userData.Type == 'Customer' && userData.Sub_type__c == 'Supplier') {              
           
            try {
                 AggregateResult[] groupedResults = [SELECT AVG(discount_rate__c)avgdisc, AVG(supplier_costs_as_percentage__c)avgcost, SUM(credit_insurance_fee__c)creditsum, SUM(Platform_fee_variable_amount__c)feesum, SUM(discount_amount_on_funded_amount__C )discsum, SUM(advanced_amount__C)advsum FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__r.Supplier__r.Id=:supplierId AND Supplier_Buyer_Map__r.Marketplace__c=:marketplace AND phase__C IN ('2:ON MARKETPLACE','3:IN PROGRESS','4:CLOSED') ];
                 
                 
                for(AggregateResult ar : groupedResults){
                    result.put('avgdisc', (Decimal)(ar.get('avgdisc')));
                    result.put('avgcost', (Decimal)(ar.get('avgcost')));
                    result.put('creditsum', (Decimal)(ar.get('creditsum')));
                    result.put('feesum', (Decimal)(ar.get('feesum')));
                    result.put('discsum', (Decimal)(ar.get('discsum')));
                    result.put('advsum', (Decimal)(ar.get('advsum')));
                }
                
               for(AggregateResult ar : [SELECT phase__C phase, SUM(remaining_amount__c)remsum, SUM(funded_amount__c)funsum FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__r.Supplier__r.Id=:supplierId AND Supplier_Buyer_Map__r.Marketplace__c=:marketplace GROUP BY phase__C]) {
    
                  String phase = (string)(ar.get('phase'));
                  phase = phase.replace(' ', '_');
                  phase = phase.replace(':', '_');
                  Decimal remsum = (Decimal) ar.get('remsum');
                  Decimal funsum = (Decimal) ar.get('funsum');
            
                  result.put(phase+'_remTotal', remsum);
                  result.put(phase+'_fundTotal', funsum);
               }
    
                 return new ReturnClass('true', 'Query executed successfully.', result);
        
            } catch (Exception e) {
                  return new ReturnClass('false', e.getMessage(), null);
            }
        }else {
            return new ReturnClass('false','Invalid User', null);
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