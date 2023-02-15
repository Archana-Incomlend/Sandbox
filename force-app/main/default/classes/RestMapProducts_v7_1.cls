@RestResource(urlMapping='/v7.1/mapproducts')

global with sharing class RestMapProducts_v7_1 {
      
    @HttpGet
    global static GlobalMethods.MapProductListReturnClass doGet() {
    
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
        if(GlobalMethods.isValidId(p_mapId) == false) {
            return new GlobalMethods.MapProductListReturnClass('false','Invalid supplier buyer map id', null);
        }
        
        //Validating and adding the fieldSet
        if(v_FieldSet.get(p_fieldSetType) != null) {
            v_detailQueryFieldSet = v_FieldSet.get(p_fieldSetType);
        }else {
            return new GlobalMethods.MapProductListReturnClass('false','Field set parameter is missing or invalid value', null);
        }
        
        //Run the query and return result
        v_listQuery = 'SELECT '+v_detailQueryFieldSet + ' FROM Map_Product__c WHERE Supplier_Buyer_map__c = :p_mapId';
        v_result = database.query(v_listQuery);
        return new GlobalMethods.MapProductListReturnClass('true', 'Query executed successfully.', v_result);
    }
 
}