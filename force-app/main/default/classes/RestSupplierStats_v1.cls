@RestResource(urlMapping='/v1/supplier/stats/*')

global with sharing class RestSupplierStats_v1 {
    
    @HttpGet   
    global static ReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String supplierId = URLParams[URLParams.size()-1];        
        String ccy = URLParams[URLParams.size()-2];
        
        map<String,Decimal> result = new Map<String,Decimal>();
        
        String statsQuery = 'SELECT AVG(discount_rate__c)averageDiscount, AVG(supplier_costs_as_percentage__c)averageSupplierCost, SUM(credit_insurance_fee__c)totalCreditInsurance, SUM(Platform_fee_variable_amount__c)totalPlatformFee, SUM(discount_amount_on_funded_amount__C )totalDiscount, SUM(advanced_amount__C)totalAdvanced FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__r.Supplier__r.Id=:supplierId AND phase__C IN (\'2:ON MARKETPLACE\',\'3:IN PROGRESS\',\'4:CLOSED\')';
       
        if(ccy != 'all') {
            if(GlobalMethods.isvalidCurrency(ccy) == false) {
                    
                return new ReturnClass('false','Invalid currency', null);
            }else {
                statsQuery = statsQuery+' AND CCY__c=:ccy';
            }
        }
         
        if(RestUserLogin.isValidId(supplierId) == false) {
        
            return new ReturnClass('false','Invalid User ID', null);
        }  
        
        Account userData = RestUserLogin.validateUser(supplierId);
        
        if(userData.Type == 'Customer' && userData.Sub_type__c == 'Supplier') {              
           
            try {
                 AggregateResult[] groupedResults = database.query(statsQuery);
                 
                for(AggregateResult ar : groupedResults){
                    result.put('averageDiscount', (Decimal)(ar.get('averageDiscount')));
                    result.put('averageSupplierCost', (Decimal)(ar.get('averageSupplierCost')));
                    result.put('totalCreditInsurance', (Decimal)(ar.get('totalCreditInsurance')));
                    result.put('totalPlatformFee', (Decimal)(ar.get('totalPlatformFee')));
                    result.put('totalDiscount', (Decimal)(ar.get('totalDiscount')));
                    result.put('totalAdvanced', (Decimal)(ar.get('totalAdvanced')));
                }
                
               for(AggregateResult ar : [SELECT phase__C phase, SUM(remaining_amount__c)totalRemaining, SUM(funded_amount__c)totalFunded FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__r.Supplier__r.Id=:supplierId AND CCY__c=:ccy GROUP BY phase__C]) {
    
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