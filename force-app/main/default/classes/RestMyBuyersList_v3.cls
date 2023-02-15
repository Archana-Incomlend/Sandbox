@RestResource(urlMapping='/v3/buyersuppliermap/*')
global with sharing class RestMyBuyersList_v3 {
      
    @HttpGet
    global static ReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String supplierId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if(RestUserLogin.isValidId(supplierId) == false) {
        
            return new ReturnClass('false','Invalid user ID', null);
        }
                
        Account userData = RestUserLogin.validateUser(supplierId);
        
        if(userData.Type == 'Customer' && userData.Sub_type__c == 'Supplier') {
        
            String listQuery = 'SELECT Name, map_onboarding_stage__c, Public_Verification_Requirements__c, Buyer__r.suspended__c, Buyer__r.suspended_notes__c, Accepted_Payment_Terms__c, buyer_supplier_map_approved__c, approval_date__c, accepted_incoterms__c, Incomlend_product__r.active__c, Incomlend_product__r.Name, Buyer__r.Name, Marketplace__r.currency__c, insurable__c, Id FROM Supplier_Buyer_Map__c WHERE Supplier__r.Id=:supplierId';
            
            List<Supplier_Buyer_Map__c> buyersList = new List<Supplier_Buyer_Map__c>();  
                    
            try {
    
              buyersList = database.query(listQuery);
              return new ReturnClass('true', 'Query executed successfully.', buyersList);
        
            } catch (Exception e) {
              return new ReturnClass('false', e.getMessage(), null);
            }
         }else {
         
             return new ReturnClass('false','Invalid user', null);
         }
    }
    
    global class ReturnClass {

        global String success;
        global String message;
        global List<Supplier_Buyer_Map__c> records;

        global ReturnClass(String success, String message, List<Supplier_Buyer_Map__c> records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }
      
}