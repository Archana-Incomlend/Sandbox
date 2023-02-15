@RestResource(urlMapping='/v7.1/mapsupportingdcs')

global with sharing class RestMapSupportingDocs_v7_1 {
      
    @HttpGet
    global static GlobalMethods.MapSupportingDocsListReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        //Get URL paramaters  
        String p_mapId = RestContext.request.params.get('mapId'); 
        String p_fieldSetType = RestContext.request.params.get('fieldSetType');
        
        //Initializing and declaring variables
        List<Map_Supporting_Doc__c> v_result = new List<Map_Supporting_Doc__c> ();
        Map<String,String> v_FieldSet = new Map<String,String>{
            'supplier' => 'Id, Name, Document_Type__c, Required__c',
            'buyer' => 'Id, Name, Document_Type__c, Required__c'
        };
         Map<String,String> v_FieldSetCondition = new Map<String,String>{
            'supplier' => ' AND Required_from__c=\'Supplier\'',
            'buyer' => ' AND Required_from__c=\'Buyer\''
        };
        String v_listQuery;
        String v_detailQueryFieldSet;
        String v_detailQueryFieldSetCondition;
        
        //Validating map Id
        if(GlobalMethods.isValidId(p_mapId) == false) {
            return new GlobalMethods.MapSupportingDocsListReturnClass('false','Invalid supplier buyer map id', null);
        }
        
        //Validating and adding the fieldSet
        if(v_FieldSet.get(p_fieldSetType) != null) {
            v_detailQueryFieldSet = v_FieldSet.get(p_fieldSetType);
            v_detailQueryFieldSetCondition = v_FieldSetCondition.get(p_fieldSetType);
        }else {
            return new GlobalMethods.MapSupportingDocsListReturnClass('false','Field set parameter is missing or invalid value', null);
        }
        
        //Run the query and return result
        v_listQuery = 'SELECT '+v_detailQueryFieldSet + ' FROM Map_Supporting_Doc__c WHERE Supplier_Buyer_Map__c = :p_mapId '+v_detailQueryFieldSetCondition;
        v_result = database.query(v_listQuery);
        return new GlobalMethods.MapSupportingDocsListReturnClass('true', 'Query executed successfully.', v_result);
    }
 
}