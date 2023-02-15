@RestResource(urlMapping='/v6.1/transactions/stats/user/*')

global with sharing class RestUserTransactionsStats_v6_1 {
      
    @HttpGet
    global static ReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        map<String,Decimal> v_result = new Map<String,Decimal>();
        String p_userAccountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String v_depositType = '70.Deposit';
        String v_depositStatus = 'Expected';
        String v_withdrawType = '80.Withdrawal';
        String v_withdrawStatus = 'Requested';
        
        if(GlobalMethods.isValidId(p_userAccountId) == false) {
            return new ReturnClass('false','Invalid user account Id', null);
        }
      
        for(AggregateResult ar : [SELECT CCY__c ccy, SUM(Amount__c)totalDepositAmount FROM Transaction__c WHERE Account__c=:p_userAccountId AND Type__c=:v_depositType AND Status__c=:v_depositStatus GROUP BY CCY__c]) {
                String v_ccy = (string)(ar.get('ccy'));
                Decimal v_totalDepositAmount = (Decimal) ar.get('totalDepositAmount');
                v_result.put(v_ccy+'_totalDepositAmount', v_totalDepositAmount);
        }
        
        for(AggregateResult ar : [SELECT CCY__c ccy, SUM(Amount__c)totalWithdrawAmount FROM Transaction__c WHERE Account__c=:p_userAccountId AND Type__c=:v_withdrawType AND Status__c=:v_withdrawStatus GROUP BY CCY__c]) {
                String v_ccy = (string)(ar.get('ccy'));
                Decimal v_totalWithdrawAmount = (Decimal) ar.get('totalWithdrawAmount');
                v_result.put(v_ccy+'_totalWithdrawAmount', v_totalWithdrawAmount);
        }
        
        AggregateResult[] v_groupedResults3 = [SELECT CCY__c ccy, SUM(amount__c)repaidTotal FROM Invoice_Allocation__c WHERE Funder__c=:p_userAccountId AND Status__c IN ('Repaid invoice deal closed') AND Invoice__r.phase__C IN ('4:CLOSED') GROUP BY CCY__c];
        for(AggregateResult ar : v_groupedResults3){
                String v_ccy = (string)(ar.get('ccy'));
                Decimal v_repaidTotal = (Decimal) ar.get('repaidTotal');
                v_result.put(v_ccy+'_repaidTotal', v_repaidTotal);
        }
        return new ReturnClass('true', 'Query executed successfully.', v_result);                
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