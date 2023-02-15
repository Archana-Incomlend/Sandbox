@RestResource(urlMapping='/v9.2/SupplierBuyerMap')

global with sharing class RestSupplierBuyerMaps_v9_2 {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        //Get URL paramaters
        String startDate = req.params.get('lastModifiedStartDate');
        if (startDate == null || startDate == '') {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Start date is required')));
        } else {
            Datetime lastModifiedStartDate = null;
            Datetime lastModifiedEndDate = null;
            String subCondition = '';
            Boolean hasError = false;
            try {
                String dateRegEx = '((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])';
				Pattern myPattern = Pattern.compile(dateRegEx);
				Matcher myMatcher = myPattern.matcher(startDate);
                if (!myMatcher.matches()) {
                    hasError = true;
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid date')));                    
                } else {
                    lastModifiedStartDate = Date.valueOf(startDate);
                    String endDateString = req.params.get('lastModifiedEndDate');
                    if (endDateString != null && endDateString != '') {
                        myMatcher = myPattern.matcher(endDateString);
                        if (!myMatcher.matches()) {
                            hasError = true;
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid date')));                    
                        } else {
                            Date endDate = Date.valueOf(endDateString);
                            lastModifiedEndDate = DateTime.newInstanceGmt(endDate, Time.newInstance(23, 59, 59, 0));
                            subCondition = ' AND LastModifiedDate <= :lastModifiedEndDate';
                            if (lastModifiedStartDate > lastModifiedEndDate) {
                                hasError = true;
                                res.statusCode = 400;
                                res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Start date must be before end date')));
                            }
                        }
                    }
                }
            } catch(TypeException e) {
                hasError = true;
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid date')));
            }
    
            if (!hasError) {
                List<Supplier_Buyer_Map__c> v_result = new List<Supplier_Buyer_Map__c>();
                List<SupplierBuyerMapCustomClass> supplierBuyerMaps = new List<SupplierBuyerMapCustomClass>();
                SupplierBuyerMapCustomClass supplierBuyerMap;
                String v_listQuery = 'SELECT Id, Name, Supplier__c, Buyer__c, Marketplace__c, Sector__c, Goods_and_Services_new__c, Trustee__c, map_onboarding_stage__c, Geographical_zone__c, Map_Sales_Owner__c, Credit_Limit_Provided_by_Insurer__c, CL_USD_Incomlend_for_this_Map__c, Credit_Insurance_Coverage_Starting_Date__c, CL_USD_Available_for_this_Map__c FROM Supplier_Buyer_Map__c WHERE IsDeleted = false AND LastModifiedDate >= :lastModifiedStartDate' + subCondition;
                v_result = database.query(v_listQuery);
                for (Supplier_Buyer_Map__c v_map : v_result) {
                    supplierBuyerMap = new SupplierBuyerMapCustomClass(v_map);
                    supplierBuyerMaps.add(supplierBuyerMap);
                }
                res.responseBody = Blob.valueOf(JSON.serialize(supplierBuyerMaps));
                res.statusCode = 200;
            }
        }
    }
}