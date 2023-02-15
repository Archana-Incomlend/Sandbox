@RestResource(urlMapping='/v9.2/InvoiceFinanceDeal')

global with sharing class RestInvoiceFinanceDealList_v9_2 {
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
                                         + ') OR (' + subCondition.replaceAll('LastModifiedDate','advance_send_to_supplier_date__c') 
                                         + ') OR (' + subCondition.replaceAll('LastModifiedDate','Actual_Repayment_Received_Date__c') 
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
                subCondition += ' AND (FX_conversion_rate__c != null OR CCY__c = \'USD\') AND (Phase__c = \'3:IN PROGRESS\' OR Phase__c = \'4:CLOSED\')';
            }
    
            if (!hasError) {
                List<invoice_finance_deal__c> v_result = new List<invoice_finance_deal__c> ();
                List<InvoiceFinanceDealCustomClass> deals = new List<InvoiceFinanceDealCustomClass>();
                InvoiceFinanceDealCustomClass deal;
                String v_listQuery = 'SELECT Id, Name, Supplier_Buyer_Map__c, Phase__c, supplier_invoice_reference_number__c, buyer_purchase_order_reference__c, Total_Supplier_Discount__c, CCY__c'
                    + ', Real_Face_Value__c, USD_Daily_FX_Real_Value_Invoice__c'
                    + ', requested_amount__c'
                    + ', invoice_amount__c, USD_Daily_FX_invoice_Amount__c'
                    + ', FX_conversion_rate__c'
                    + ', Invoice_date__c, Due_Date__c, submitted_date__c, advance_send_to_supplier_date__c, Actual_Repayment_Received_Date__c, Repaid_Amount__c, Incoterm__c, Trustee__c FROM invoice_finance_deal__c WHERE IsDeleted = false ' + condition + subCondition;
                System.debug('queryString ' + v_listQuery.subString(v_listQuery.indexOf('WHERE')));
                v_result = database.query(v_listQuery);
                for (invoice_finance_deal__c v_deal : v_result) {
                    deal = new InvoiceFinanceDealCustomClass(v_deal);
                    deals.add(deal);
                }
                res.responseBody = Blob.valueOf(JSON.serialize(deals));
                res.statusCode = 200;
                res.headers.put('Content-Type', 'application/json');
            }
    	}
    }
}