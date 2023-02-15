@RestResource(urlMapping='/v9/supplierbuyermap')
global with sharing class RestSuppliersBuyersList_v9 {
      
    @HttpGet
    global static GlobalMethods_v9.BuyerMapListReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        //Get URL paramaters
        String p_ccy = RestContext.request.params.get('ccy');
        String p_supplierAccountId = RestContext.request.params.get('supplierAccountId');
        String p_buyerAccountId = RestContext.request.params.get('buyerAccountId');
        String p_fieldSetType = RestContext.request.params.get('fieldSetType');
        String p_trusteeName = null;
        if (RestContext.request.params.get('trustee') != null) {
            p_trusteeName = RestContext.request.params.get('trustee');
        }
        
        //Initializing and declaring variables
        Map<String,String> v_FieldSet = new Map<String,String>{
            'supplier' => 'Name, map_onboarding_stage__c, Public_Verification_Requirements__c, Buyer__r.suspended__c, Buyer__r.suspended_notes__c, Accepted_Payment_Terms__c, buyer_supplier_map_approved__c, approval_date__c, accepted_incoterms__c, Incomlend_product__r.active__c, Incomlend_product__r.Name, Buyer__r.Name, Marketplace__r.currency__c, insurable__c, Id, Funder_Discount_Rate__c',
            'buyer' => 'Name, map_onboarding_stage__c, Public_Verification_Requirements__c, Supplier__r.suspended__c, Supplier__r.suspended_notes__c, Accepted_Payment_Terms__c, buyer_supplier_map_approved__c, approval_date__c, accepted_incoterms__c, Incomlend_product__r.active__c, Incomlend_product__r.Name, Supplier__r.Name, Marketplace__r.currency__c, insurable__c, Id, Funder_Discount_Rate__c'
        };
        String v_listQuery = 'SELECT ';
        List<Supplier_Buyer_Map__c> v_result = new List<Supplier_Buyer_Map__c>();
        
        //Validating the CCY
        if(p_ccy != null) {
            if(GlobalMethods_v9.isvalidCurrency(p_ccy) == false) {
                return new GlobalMethods_v9.BuyerMapListReturnClass('false','Currency parameter is missing or invalid value', null);
            }
        }
        
        //Validating and adding the fieldSet
        if(v_FieldSet.get(p_fieldSetType) != null) {
            v_listQuery = v_listQuery + v_FieldSet.get(p_fieldSetType);
        }else {
            return new GlobalMethods_v9.BuyerMapListReturnClass('false','Field set parameter is missing or invalid value', null);
        }
        
        //Validating supplier/buyer account id and add supplier/buyer field set in the query
        if(p_supplierAccountId != null) {
            GlobalMethods_v9.AccountReturnClass v_userData = GlobalMethods_v9.getUserData(p_supplierAccountId);
            if(v_userData.v_success == 'true' && v_userData.v_records.Sub_type__c == 'Supplier') {
                v_listQuery = v_listQuery + ' FROM Supplier_Buyer_Map__c WHERE Supplier__r.Id=:p_supplierAccountId';
            }else {
                return new GlobalMethods_v9.BuyerMapListReturnClass('false','Invalid supplier account ID', null);
            }
        }else if(p_buyerAccountId != null) {
            GlobalMethods_v9.AccountReturnClass v_userData = GlobalMethods_v9.getUserData(p_buyerAccountId);
            if(v_userData.v_success == 'true' && v_userData.v_records.Type == 'Buyer') {
                v_listQuery = v_listQuery + ' FROM Supplier_Buyer_Map__c WHERE Buyer__r.Id=:p_buyerAccountId';
            }else {
                return new GlobalMethods_v9.BuyerMapListReturnClass('false','Invalid buyer account ID', null);
            }
        }else {
            return new GlobalMethods_v9.BuyerMapListReturnClass('false','User account ID parameter is missing', null);
        }        
        
        //Run the query and return result
        //v_listQuery = v_listQuery + ' AND Currency__c=:p_ccy';
        if(p_trusteeName != null) {
           v_listQuery = v_listQuery+' AND Trustee__c =:p_trusteeName'; 
        }
        v_result = database.query(v_listQuery);
        return new GlobalMethods_v9.BuyerMapListReturnClass('true', 'Query executed successfully.', v_result);
                       
    }

}