@RestResource(urlMapping='/marketplaces/*')
global with sharing class RestMarketplaceList {
    
    @HttpGet   
    global static ReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String userId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(RestUserLogin.isValidId(userId) == false) {
        
           return new ReturnClass('false','Invalid User id', null);
        }
        
        String listQuery = 'SELECT Name, Id, Currency__c, active__c, icon_URL__c, Available_on_Marketplace__c, All_Time_Invoice_Value__c, currency_symbol__c FROM Marketplace__c WHERE active__c=true AND is_Private__c=false ORDER BY Name DESC NULLS LAST';
        
        List<Marketplace__c> marketplaceList = new List<Marketplace__c>();    
  
        try {
          marketplaceList = database.query(listQuery);
          String privateListQuery = 'SELECT Name, Id, Currency__c, active__c, icon_URL__c, Available_on_Marketplace__c, All_Time_Invoice_Value__c, currency_symbol__c FROM Marketplace__c WHERE active__c=true AND is_Private__c=true AND Marketplace__c.Id IN (SELECT Marketplace__c FROM Account_Marketplace_Map__c WHERE  Account__c =:userId AND approved__c=true)';
          List<Marketplace__c> privateMarketplaceList = database.query(privateListQuery);
          for(Marketplace__c mp : privateMarketplaceList) {
            marketplaceList.add(mp);
          }
          return new ReturnClass('true', 'Query executed successfully.', marketplaceList);
    
        } catch (Exception e) {
          return new ReturnClass('false', e.getMessage(), null);
        }
        
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global List<Marketplace__c> records;

        global ReturnClass(String success, String message, List<Marketplace__c> records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }
    
}