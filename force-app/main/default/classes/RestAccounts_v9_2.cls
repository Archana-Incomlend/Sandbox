@RestResource(urlMapping='/v9.2/Account')

global with sharing class RestAccounts_v9_2 {
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
            Date lastModifiedStartDate = null;
            Date lastModifiedEndDatePlusOne = null;
            String condition = ' AND LastModifiedDate >= :lastModifiedStartDate';
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
                            lastModifiedEndDatePlusOne = Date.valueOf(endDateString).addDays(1);
                            subCondition = ' AND LastModifiedDate < :lastModifiedEndDatePlusOne';
                            System.debug(lastModifiedStartDate + ' ' + lastModifiedEndDatePlusOne);
                            if (lastModifiedStartDate >= lastModifiedEndDatePlusOne) {
                                hasError = true;
                                res.statusCode = 400;
                                res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Start date must be before end date')));
                            }
                            if (true) {
                                subCondition = condition + subCondition;
                                condition = ' AND';
                                subCondition = subCondition.substring(condition.length());
                                subCondition = ' (' + ' (' + subCondition
                                         + ') OR (' + subCondition.replaceAll('LastModifiedDate','CreatedDate') 
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
    
            if (!hasError) {
                List<Account> v_result = new List<Account>();
                List<AccountCustomClass> accounts = new List<AccountCustomClass>();
                AccountCustomClass account;
                
                String v_listQuery = 'SELECT Id, Name, Company_registration_number__c, onboarding_stage__c, Type, Sub_type__c,'
                    					+ ' Country_of_Incorporation__c, Year_of_incorporation__c, BillingAddress, ShippingAddress,'
                    					+ ' Sector__c, Goods_and_Services_new__c, Goods_or_Services_Offered__c, Insured_by__c, AnnualRevenue,'
                    					+ ' NumberOfEmployees, Credit_Limited_Provided_by_Insurer__c, Total_CL_Limit_from_Incomlend__c,'
                    					+ ' Sales_Owner__r.Name, Trustee__c, (SELECT Name, CCY__c FROM eWallets__r),'
                    					+ ' Gross_Funder_Discount_Rate_EUR__c, Gross_Funder_Discount_Rate_GBP__c, Gross_Funder_Discount_Rate_HKD__c,'
                    					+ ' Gross_Funder_Discount_Rate_SGD__c, Gross_Funder_Discount_Rate_USD__c,'
                    					+ ' Discount_Profit_Share_Percent_EUR__c, Discount_Profit_Share_Percent_GBP__c, Discount_Profit_Share_Percent_HKD__c,'
                    					+ ' Discount_Profit_Share_Percent_SGD__c, Discount_Profit_Share_Percent_USD__c'
                    					+ ' FROM Account WHERE IsDeleted = false ' + condition + subCondition;
                
                System.debug('queryString ' + v_listQuery.subString(v_listQuery.indexOf('WHERE')));
                v_result = database.query(v_listQuery);
                for (Account acct : v_result) {
                    account = new AccountCustomClass(acct, '');
                    accounts.add(account);
                }
                res.responseBody = Blob.valueOf(JSON.serialize(accounts));
                res.statusCode = 200;
                res.headers.put('Content-Type', 'application/json');
            }
        }
    }
}