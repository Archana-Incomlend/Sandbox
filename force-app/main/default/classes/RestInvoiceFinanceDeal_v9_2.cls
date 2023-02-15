@RestResource(urlMapping='/v9.2/InvoiceFinanceDeal/*')

global with sharing class RestInvoiceFinanceDeal_v9_2 {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String p_dealId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if (GlobalMethods_v9.isValidId(p_dealId) == false) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid deal id')));
        } else {

            List<invoice_finance_deal__c> v_result = new List<invoice_finance_deal__c>();
            String v_listQuery = 'SELECT Id, Name, Supplier_Buyer_Map__c, Phase__c, supplier_invoice_reference_number__c, buyer_purchase_order_reference__c, Total_Supplier_Discount__c, CCY__c'
                + ', Real_Face_Value__c, USD_Daily_FX_Real_Value_Invoice__c'
                + ', requested_amount__c'
                + ', invoice_amount__c, USD_Daily_FX_invoice_Amount__c'
                + ', FX_conversion_rate__c'
                + ', Invoice_date__c, Due_Date__c, submitted_date__c, advance_send_to_supplier_date__c, Actual_Repayment_Received_Date__c, Repaid_Amount__c, Incoterm__c, Trustee__c FROM invoice_finance_deal__c WHERE Id = :p_dealId AND IsDeleted = false';
            v_result = database.query(v_listQuery);
            if (v_result.size() == 0) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new GlobalMethods_v9.ResponseClass(400, 'Bad Request', 'Invalid deal id')));
            } else {
                InvoiceFinanceDealCustomClass deal = new InvoiceFinanceDealCustomClass(v_result.get(0));
                res.responseBody = Blob.valueOf(JSON.serialize(deal));
                res.statusCode = 200;
            }
        }
    }
}