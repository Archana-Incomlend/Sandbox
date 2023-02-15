@RestResource(urlMapping='/v7/buyer/*')

global with sharing class RestBuyerDetails_v7 {
      
    @HttpGet
    global static GlobalMethods.AccountReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<Account> v_result = new List<Account> ();
        
        String p_userAccountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(GlobalMethods.isValidId(p_userAccountId) == false) {
            return new GlobalMethods.AccountReturnClass('false','Invalid user account id', null);
        }
        
        v_result = [SELECT Industry, Website, BillingAddress, number_of_defaults__c, days_with_no_defaults__c, Name, logo_URL__c, Onboarding_completed_date__c, countries_of_operation__c, AnnualRevenue, Year_of_incorporation__c, Country_of_Incorporation__c, head_office_country__c, goods_or_services_offered_text__c, Public_Profile__c FROM Account WHERE Id = :p_userAccountId];
        if (v_result.size() == 0) {
            return new GlobalMethods.AccountReturnClass('false','Invalid Buyer Id', null);
        }else {
            return new GlobalMethods.AccountReturnClass('true', 'Query executed successfully.', v_result.get(0));
        }
    }
 
}