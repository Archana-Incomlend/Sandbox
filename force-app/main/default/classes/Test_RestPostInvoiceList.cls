@isTest
private class Test_RestPostInvoiceList {

    static {
    // setup test data  
  }

  static testMethod void testDoPost() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods.InvoiceListReturnClass v_results;

    String invoiceStr = '{\"IMPORTANT_NOTES__c\":\"Invoice batch clients reference: INB_01\",\"buyer_purchase_order_reference__c\":\"PO_210602_0001\",\"Invoice_date__c\":\"2021-11-11\",\"supplier_invoice_reference_number__c\":\"INV_210602_0001\",\"CCY__c\":\"USD\",\"invoice_amount_before_deductions__c\":100000,\"requested_amount__c\":90000,\"Minimum_requested_amount__c\":60000,\"discount_rate__c\":0,\"Incoterm__c\":\"EXW\",\"Shipment_Date__c\":\"2021-11-24\",\"Carrier_name_icl__c\":\"COSCO Group\",\"Final_destination__c\":\"France\",\"Due_Date__c\":\"2021-08-08\",\"Freight_Forwarder_Agent__c\":\"0\",\"Country_of_Origin__c\":\"China\",\"Country_of_Destination__c\":\"France\",\"Sector__c\":\"Health Care\",\"Goods_and_Services_new__c\":\"Health Care suppliers & Equipment\",\"Goods_Services_description__c\":\"Medocs\",\"Real_Face_Value__c\":100000,\"invoice_amount__c\":100000,\"Map_Product__c\":\"a0F0I00000msIXs\",\"Incomlend_product_del__c\":\"a0t28000000SlnF\",\"recordTypeID\":\"0120I000000TOK6\",\"Supplier_Buyer_Map__c\":\"a0q0I000004ll9v\",\"Phase__c\":\"1:PRE LISTING\",\"Status__c\":\"pending incomlend review\"}';
    String invoiceListStr = '[' + invoiceStr + ',' + invoiceStr + ']';
    req.requestURI = v_baseUrl+'/v9/invoices';   
    v_results = RestPostInvoiceList.doPost(invoiceListStr);
    System.assertEquals('true', v_results.v_success);
    System.assertEquals('Query executed successfully.', v_results.v_message);
  }

}