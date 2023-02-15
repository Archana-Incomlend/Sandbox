@RestResource(urlMapping='/v9.2/InvoiceAllocation/*')

global with sharing class RestInvoiceAllocation_v9_2 {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String p_invoiceAllocationId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(GlobalMethods_v9.isValidId(p_invoiceAllocationId) == false) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid invoice allocation id')));
        } else {

            List<Invoice_Allocation__c> v_result = new List<Invoice_Allocation__c>();
            String v_listQuery = 'SELECT Id, Name, Funder__c, Status__c, Allocation_Reservation_date__c, Allocation_Confirmed_Date__c, CCY__c, amount__c, Invoice__c, Applied_MPR__c, Incomlend_Profit_share__c FROM Invoice_Allocation__c WHERE Id = :p_invoiceAllocationId AND IsDeleted = false';
            v_result = database.query(v_listQuery);
            if (v_result.size() == 0) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid invoice allocation id')));
            } else {
                InvoiceAllocationCustomClass invoice = new InvoiceAllocationCustomClass(v_result.get(0));
                res.responseBody = Blob.valueOf(JSON.serialize(invoice));
                res.statusCode = 200;
            }
        }
    }
}