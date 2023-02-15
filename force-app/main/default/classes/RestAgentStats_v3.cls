@RestResource(urlMapping='/v3/agent/stats/*')

global with sharing class RestAgentStats_v3 {
    
    @HttpGet   
    global static ReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String userId = URLParams[URLParams.size()-1];        
        
        map<String,Decimal> result = new Map<String,Decimal>();
      
        if(RestUserLogin.isValidId(userId) == false) {
        
            return new ReturnClass('false','Invalid User ID', null);
        } 
        String supplierFeeType = '061.Agent Commission on Transaction Fee';
        String funderFeeType = '051.Agent Commission on Discount Amount';
        String transStatus = 'Confirmed by operations';
        String allocStatus = 'Confirmed';
        String invoicePhase = '3:IN PROGRESS';
        
        Account userData = RestUserLogin.validateUser(userId);
               if(userData.Type == 'Agent') {              
 
           
            try {
                
                AggregateResult[] groupedResults = [SELECT COUNT(Name)userOnboardCount FROM Account WHERE agent__r.Id=:userId AND onboarded__c = true AND Sub_type__c IN ('Purchaser', 'Supplier')];
                 
                for(AggregateResult ar : groupedResults){
                    result.put('userOnboardCount', (Decimal)(ar.get('userOnboardCount')));
                }
                AggregateResult[] groupedResults1 = [SELECT COUNT(Name)userOnboardingCount FROM Account WHERE agent__r.Id=:userId AND onboarded__c = false AND Sub_type__c IN ('Purchaser', 'Supplier')];
                 
                for(AggregateResult ar : groupedResults1){
                    result.put('userOnboardingCount', (Decimal)(ar.get('userOnboardingCount')));
                }
                
                for(AggregateResult ar : [SELECT CCY__c ccy, SUM(Amount__c)totalSupplierFee FROM Transaction__c WHERE Account__c=:userId AND Status__c=:transStatus AND Type__c=:supplierFeeType GROUP BY CCY__c]) {
    
                      String ccy = (string)(ar.get('ccy'));
                      Decimal totalSupplierFee = (Decimal) ar.get('totalSupplierFee');
                                    
                      result.put(ccy+'_totalSupplierFee', totalSupplierFee);
                }
                
                for(AggregateResult ar : [SELECT CCY__c ccy, SUM(Amount__c)totalFunderFee FROM Transaction__c WHERE Account__c=:userId AND Status__c=:transStatus AND Type__c=:funderFeeType GROUP BY CCY__c]) {
    
                      String ccy = (string)(ar.get('ccy'));
                      Decimal totalFunderFee = (Decimal) ar.get('totalFunderFee');
                                    
                      result.put(ccy+'_totalFunderFee', totalFunderFee);
                }
                
                for(AggregateResult ar : [SELECT CCY__c ccy, SUM(Funder_Agent_Commission_Amount__c)totalFunderCommissionExpected FROM Invoice_Allocation__c WHERE Funder__r.Agent__r.id=:userId AND Status__c=:allocStatus GROUP BY CCY__c]) {
                      
                      String ccy = (string)(ar.get('ccy'));
                      Decimal totalFunderCommissionExpected = (Decimal) ar.get('totalFunderCommissionExpected');
                                    
                      result.put(ccy+'_totalFunderCommissionExpected', totalFunderCommissionExpected);
                }
                
                for(AggregateResult ar : [SELECT CCY__c ccy, SUM(Agent_Commission_on_Platform_Fee__c)totalSupplierCommissionExpected FROM invoice_finance_deal__c WHERE Supplier_Buyer_Map__r.Supplier__r.Agent__r.id=:userId AND Phase__c=:invoicePhase GROUP BY CCY__c]) {
                      
                      String ccy = (string)(ar.get('ccy'));
                      Decimal totalSupplierCommissionExpected = (Decimal) ar.get('totalSupplierCommissionExpected');
                                    
                      result.put(ccy+'_totalSupplierCommissionExpected', totalSupplierCommissionExpected);
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