@RestResource(urlMapping='/v9.2/Transaction')

global with sharing class RestTransactions_v9_2 {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        //Get URL paramaters
        String isFxFinal = req.params.get('isFxFinal');
        String startDate = req.params.get('lastModifiedStartDate');
        if (startDate == null || startDate == '') {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Start date is required')));
        } else {
            Date lastModifiedStartDate = null;
            Date lastModifiedEndDatePlusOne = null;
            String condition = '';
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
                    condition = ' AND LastModifiedDate >= :lastModifiedStartDate';
                    String endDateString = req.params.get('lastModifiedEndDate');
                    if (endDateString != null && endDateString != '') {
                        myMatcher = myPattern.matcher(endDateString);
                        if (!myMatcher.matches()) {
                            hasError = true;
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid date')));                    
                        } else {
                            lastModifiedEndDatePlusOne = Date.valueOf(endDateString).addDays(1);
                            subCondition = ' AND LastModifiedDate < :lastModifiedEndDatePlusOne';
                            if (lastModifiedStartDate >= lastModifiedEndDatePlusOne) {
                                hasError = true;
                                res.statusCode = 400;
                                res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Start date must be before end date')));
                            }
                            if (isFxFinal == 'true') {
                                subCondition = condition + subCondition;
                                condition = ' AND';
                                subCondition = subCondition.substring(condition.length());
                                subCondition = ' (' + ' (' + subCondition
                                         + ') OR (' + subCondition.replaceAll('LastModifiedDate','Effective_Date__c') 
                                         + ')' + ')';
                            }
                        }
                    }
                }
            } catch(TypeException e) {
                hasError = true;
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid date')));
            }
            if (isFxFinal == 'true') {
                subCondition += ' AND (FX_rate_conversion__c != null OR CCY__c = \'USD\') AND Amount__c != 0 AND (Status__c = \'Confirmed by operations\' OR Status__c = \'Confirmed by Finance\')';
            }
            
            if (!hasError) {
                List<Transaction__c> v_result = new List<Transaction__c>();
                List<TransactionCustomClass> transactionList = new List<TransactionCustomClass>();
                TransactionCustomClass transactionObj;
                String v_listQuery = 'SELECT Id, Name, CreatedDate, Effective_Date__c, Type__c, CCY__c, Amount__c, Status__c, Trustee__c, eWallet_Trustee__c, notes__c, Invoice_Finance_Deal__c, Account__c, Related_Transaction__c, Amount_SGD_equiv__c, FX_rate_conversion__c, FX_USD_Rate_Daily__c '
                    + 'FROM Transaction__c WHERE IsDeleted = false ' + condition + subCondition;
                System.debug('queryString ' + v_listQuery.subString(v_listQuery.indexOf('WHERE')));
                v_result = database.query(v_listQuery);
                for (Transaction__c v_tran : v_result) {
                    transactionObj = new TransactionCustomClass(v_tran);
                    transactionList.add(transactionObj);
                }
                res.responseBody = Blob.valueOf(JSON.serialize(transactionList));
                res.statusCode = 200;
                res.headers.put('Content-Type', 'application/json');
            }
        }
    }
}