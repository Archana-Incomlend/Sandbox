@RestResource(urlMapping='/v9.2/BankAccount')

global with sharing class RestBankAccounts_v9_2 {
    
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
                List<Bank_Account__c> v_result = new List<Bank_Account__c> ();
                List<BankAccountCustomClass> bankAccounts = new List<BankAccountCustomClass> ();
                BankAccountCustomClass bankAccount;
        
                String v_listQuery = 'SELECT Id, Name, Account__c, Beneficiary_Name__c, Bank_Name__c, Country__c, Address__c, Bank_Account_Number__c, IBan__c, Currency__c, SWIFT_Code__c, Incomlend_Account__c, transfer_cutoff_time__c, estimated_transfer_time__c FROM Bank_Account__c WHERE Active__c=true AND IsDeleted=false AND LastModifiedDate >= :lastModifiedStartDate' + subCondition;
                v_result = database.query(v_listQuery);
                for(Bank_Account__c v_bankAccount : v_result) {
                    bankAccount = new BankAccountCustomClass(v_bankAccount);
                    bankAccounts.add(bankAccount);
                }
                res.responseBody = Blob.valueOf(JSON.serialize(bankAccounts));
                res.statusCode = 200;
            }
        }
    }
}