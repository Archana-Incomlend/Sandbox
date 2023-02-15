@RestResource(urlMapping='/v7/buyerslist')

global with sharing class RestBuyerList_v7 {
    
    @HttpGet   
    global static GlobalMethods.AccountListReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        List<Account> v_result = new List<Account>(); 
        String v_type = 'Buyer';
        
        v_result = [SELECT Id, Name, Onboarding_completed_date__c, AnnualRevenue, Year_of_incorporation__c, head_office_country__c, Industry FROM Account WHERE Type = :v_type AND onboarded__c = true AND onboarding_approved__c = true AND Id IN (SELECT Buyer__c FROM Supplier_Buyer_Map__c WHERE buyer_supplier_map_approved__c = true)]; 
        return new GlobalMethods.AccountListReturnClass('true', 'Query executed successfully.', v_result);
    }
}