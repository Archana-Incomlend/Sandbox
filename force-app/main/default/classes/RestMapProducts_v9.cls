@RestResource(urlMapping='/v9/mapproducts')

global with sharing class RestMapProducts_v9 {
      
    @HttpGet
    global static GlobalMethods_v9.MapProductListReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        //Get URL paramaters  
        String p_mapId = RestContext.request.params.get('mapId'); 
        String p_fieldSetType = RestContext.request.params.get('fieldSetType');
        
        //Initializing and declaring variables
        List<Map_Product__c> v_result = new List<Map_Product__c> ();
        Map<String,String> v_FieldSet = new Map<String,String>{
            'supplier' => 'Id, Name, Custom_Product__c, Custom_Product__r.Name, Custom_Product__r.CCYs__c, Custom_Product__r.public_product_name__c, Custom_Product__r.Invoice_Record_Type__c',
            'buyer' => 'Id, Name, Custom_Product__c, Custom_Product__r.Name, Custom_Product__r.CCYs__c, Custom_Product__r.public_product_name__c, Custom_Product__r.Invoice_Record_Type__c'
        };
        String v_listQuery;
        String v_detailQueryFieldSet;
        
        //Validating map Id
        if(GlobalMethods_v9.isValidId(p_mapId) == false) {
            return new GlobalMethods_v9.MapProductListReturnClass('false','Invalid supplier buyer map id', null);
        }
        
        //Validating and adding the fieldSet
        if(v_FieldSet.get(p_fieldSetType) != null) {
            v_detailQueryFieldSet = v_FieldSet.get(p_fieldSetType);
        }else {
            return new GlobalMethods_v9.MapProductListReturnClass('false','Field set parameter is missing or invalid value', null);
        }
        
        //Run the query and return result
        v_listQuery = 'SELECT '+v_detailQueryFieldSet + ' FROM Map_Product__c WHERE Supplier_Buyer_map__c = :p_mapId';
        v_result = database.query(v_listQuery);
        return new GlobalMethods_v9.MapProductListReturnClass('true', 'Query executed successfully.', v_result);
    }
 
}