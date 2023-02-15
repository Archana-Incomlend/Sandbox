@RestResource(urlMapping='/v9.2/SupplierBuyerMap/*')

global with sharing class RestSupplierBuyerMapData_v9_2 {
      
    @HttpGet
    global static void doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        //Get URL paramaters  
        String p_mapId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        //Validating map Id
        if(GlobalMethods_v9.isValidId(p_mapId) == false) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid supplier buyer map id')));
        } else {

            List<Supplier_Buyer_Map__c> v_result = new List<Supplier_Buyer_Map__c> ();
            String v_detailQuery = 'SELECT Id, Name, Supplier__c, Buyer__c, Marketplace__c, Sector__c, Goods_and_Services_new__c, Trustee__c, map_onboarding_stage__c, Geographical_zone__c, Map_Sales_Owner__c, Credit_Limit_Provided_by_Insurer__c, CL_USD_Incomlend_for_this_Map__c, Credit_Insurance_Coverage_Starting_Date__c, CL_USD_Available_for_this_Map__c FROM Supplier_Buyer_Map__c WHERE Id = :p_mapId AND IsDeleted = false';
            v_result = database.query(v_detailQuery);
            if (v_result.size() == 0) {
            	res.statusCode = 400;
            	res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid supplier buyer map id')));
            } else {
                SupplierBuyerMapCustomClass supplierBuyerMap = new SupplierBuyerMapCustomClass(v_result.get(0));
                res.responseBody = Blob.valueOf(JSON.serialize(supplierBuyerMap));
                res.statusCode = 200;
            }
        }
    }
 
}