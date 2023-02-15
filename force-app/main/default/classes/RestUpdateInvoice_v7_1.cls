@RestResource(urlMapping='/v7.1/invoice/update')

global with sharing class RestUpdateInvoice_v7_1 {
      
    @HttpPost
    global static GlobalMethods.InvoiceReturnClass doPost(Id p_invoiceId, String p_phase, String p_status, Date p_listingStart, Date p_listingEnd) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        Invoice_Finance_Deal__c v_invoiceData = new Invoice_Finance_Deal__c (); 
        List<Account> v_accountData = new List<Account> (); 
                        
        if(GlobalMethods.isValidId(p_invoiceId) == false) {
            return new GlobalMethods.InvoiceReturnClass('false','Invalid invoice ID', null);
        }
        
        try {
           v_invoiceData = [SELECT Id, CCY__c, Phase__c, Status__c, Listing_Start__c, Listing_End__c FROM invoice_finance_deal__c WHERE Id = :p_invoiceId];
        } catch (Exception e) {
            return new GlobalMethods.InvoiceReturnClass('false', 'Invalid invoice ID', null);
        }
                                               
        if(v_invoiceData.CCY__c <> 'XXX') {
            return new GlobalMethods.InvoiceReturnClass('false','Invalid invoice', v_invoiceData);
        }

        v_invoiceData.Phase__c = p_phase;
        v_invoiceData.Status__c = p_status;
        v_invoiceData.Listing_Start__c = p_listingStart;
        v_invoiceData.Listing_End__c = p_listingEnd;
        
        try {
            update v_invoiceData;     
            return new GlobalMethods.InvoiceReturnClass('true', 'Invoice is successfully updated', null);
        } catch (Exception e) {
            return new GlobalMethods.InvoiceReturnClass('false', e.getMessage(), null);
        }
    }      
}