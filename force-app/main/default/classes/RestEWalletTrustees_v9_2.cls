@RestResource(urlMapping='/v9.2/EWalletTrustee')

global with sharing class RestEWalletTrustees_v9_2 {
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
            DateTime lastModifiedStartDate = null;
            DateTime lastModifiedEndDate = null;
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
                List<eWallet_Trustee__c> v_result = new List<eWallet_Trustee__c>();
                List<EWalletTrusteeCustomClass> eWallets = new List<EWalletTrusteeCustomClass> ();
                EWalletTrusteeCustomClass eWallet;
                String v_listQuery = 'SELECT Id, Name, Account__c, CCY__c, Balance__c, Trustee__c FROM eWallet_Trustee__c WHERE IsDeleted = false AND LastModifiedDate >= :lastModifiedStartDate' + subCondition;
                v_result = database.query(v_listQuery);
                for (eWallet_Trustee__c v_eWallet : v_result) {
                    eWallet = new EWalletTrusteeCustomClass(v_eWallet);
                    eWallets.add(eWallet);
                }
                res.responseBody = Blob.valueOf(JSON.serialize(eWallets));
                res.statusCode = 200;
            }
        }
    }
}