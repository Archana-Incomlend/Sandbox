@RestResource(urlMapping='/v9.2/InvoiceAllocation')

global with sharing class RestInvoiceAllocationList_v9_2 {
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
                List<Invoice_Allocation__c> v_result = new List<Invoice_Allocation__c> ();
                List<InvoiceAllocationCustomClass> invoiceAllocationList = new List<InvoiceAllocationCustomClass>();
                InvoiceAllocationCustomClass invoiceAllocation;
                String v_listQuery = 'SELECT Id, Name, Funder__c, Status__c, Allocation_Reservation_date__c, Allocation_Confirmed_Date__c, CCY__c, amount__c, Invoice__c, Applied_MPR__c, Incomlend_Profit_share__c FROM Invoice_Allocation__c WHERE IsDeleted = false AND LastModifiedDate >= :lastModifiedStartDate' + subCondition;
                v_result = database.query(v_listQuery);
                for (Invoice_Allocation__c v_invoice_allocation : v_result) {
                    invoiceAllocation = new InvoiceAllocationCustomClass(v_invoice_allocation);
                    invoiceAllocationList.add(invoiceAllocation);
                }
                res.responseBody = Blob.valueOf(JSON.serialize(invoiceAllocationList));
                res.statusCode = 200;
            }
    	}
    }
}