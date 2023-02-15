@RestResource(urlMapping='/v8.2/marketplaces')

global with sharing class RestMarketplaceList_v8_2 {
    
    @HttpGet   
    global static GlobalMethods.MarketplaceListReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String p_userAccountId = RestContext.request.params.get('userAccountId');
        List<Marketplace__c> v_result = new List<Marketplace__c>();  
        
        if(GlobalMethods.isValidId(p_userAccountId) == false) {
           return new GlobalMethods.MarketplaceListReturnClass('false','Invalid User account id', null);
        }
        
        //Get logged in user account Id using the email Id from header
        map<String,String> v_headers = new map<String,String>();
        v_headers = req.headers;
        String v_email = v_headers.get('email');
        if(v_email > '') {
            try{
                Id v_loggedInUserAccountId = GlobalMethods.getLoggedinUserAccountId(v_email); 
            }catch(GeneralException e) {
                return new GlobalMethods.MarketplaceListReturnClass('false',e.getMessage(), null);
            }
        }
        
        String v_listQuery = 'SELECT Name, Available_on_Marketplace_RH__c, Id, Currency__c, active__c, icon_URL__c, currency_symbol__c FROM Marketplace__c WHERE active__c=true AND is_Private__c=false ORDER BY Name DESC NULLS LAST'; 
        v_result = database.query(v_listQuery);
        
        String v_privateListQuery = 'SELECT Name, Id, Currency__c, active__c, icon_URL__c, Available_on_Marketplace__c, All_Time_Invoice_Value__c, currency_symbol__c FROM Marketplace__c WHERE active__c=true AND is_Private__c=true AND Marketplace__c.Id IN (SELECT Marketplace__c FROM Account_Marketplace_Map__c WHERE  Account__c =:p_userAccountId AND approved__c=true)';
        List<Marketplace__c> v_privateMarketplaceList = database.query(v_privateListQuery);
        for(Marketplace__c v_marketplace : v_privateMarketplaceList) {
            v_result.add(v_marketplace);
        }
        return new GlobalMethods.MarketplaceListReturnClass('true', 'Query executed successfully.', v_result);
    }
}