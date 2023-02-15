@RestResource(urlMapping='/v7.1/approvelisting')

global with sharing class RestApproveListing_v7_1 {
      
    @HttpGet
    global static GlobalMethods.InvoiceReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        list<String> URLParams = req.requestURI.split('/');
                
        String p_userContactId = RestContext.request.params.get('userContactId');         
        String p_supplierAccountId = RestContext.request.params.get('supplierAccountId');
        String p_buyerAccountId = RestContext.request.params.get('buyerAccountId');        
        String p_invoiceId = RestContext.request.params.get('invoiceId');
        String p_status = RestContext.request.params.get('status');
        Invoice_Finance_Deal__c v_invoiceData = new Invoice_Finance_Deal__c (); 
                        
        if(GlobalMethods.isValidId(p_invoiceId) == false) {
            return new GlobalMethods.InvoiceReturnClass('false','Invalid invoice ID', null);
        }
        if(GlobalMethods.isValidId(p_userContactId) == false) {
            return new GlobalMethods.InvoiceReturnClass('false','Invalid contact ID', null);
        }
        
        v_invoiceData = [SELECT Id, Supplier_Buyer_Map__r.Buyer__r.Id, Supplier_Buyer_Map__r.Supplier__r.Id, supplier_del__c, Invoice_name__c, invoice_amount__c, CCY__c, supplier_text__c, auto_status__c FROM invoice_finance_deal__c WHERE Id = :p_invoiceId];
        if(p_supplierAccountId != null) {
            if(v_invoiceData.Supplier_Buyer_Map__r.Supplier__r.Id == p_supplierAccountId && v_invoiceData.auto_status__c == 'pending supplier review') {
                if(p_status == 'approve') {
                    v_invoiceData.supplier_approval_status__c = 'Approved';
                }else if(p_status == 'reject') {
                    v_invoiceData.supplier_approval_status__c = 'Rejected';
                }
                v_invoiceData.Status__c = 'Pending Incomlend Final Review';
                v_invoiceData.Supplier_Confirmed_Date_2__c = system.now();
                v_invoiceData.Supplier_Contact_Who_Confirmed__c = p_userContactId;
            }else {
                return new GlobalMethods.InvoiceReturnClass('false','Invalid supplier invoice', null);
            }
        }else if(p_buyerAccountId != null) { 
            if(v_invoiceData.Supplier_Buyer_Map__r.Buyer__r.Id == p_buyerAccountId && v_invoiceData.auto_status__c == 'pending buyer confirmation') {
                if(p_status == 'approve') {
                    v_invoiceData.Buyer_Confirmation_Status__c = 'Confirmed Accurate';
                }else if(p_status == 'reject') {
                    v_invoiceData.Buyer_Confirmation_Status__c = 'Confirmed not accurate';
                }
                v_invoiceData.Status__c = 'pending incomlend review';
                v_invoiceData.Buyer_Confirmed_Date__c = system.today();
                v_invoiceData.Buyer_Contact_Who_Confirmed__c = p_userContactId;
            }else {
                return new GlobalMethods.InvoiceReturnClass('false','Invalid buyer invoice', null);
            }
        }else {
            return new GlobalMethods.InvoiceReturnClass('false','Account Id parameter is missing', null);
        } 
               
        update v_invoiceData;     
        if(p_supplierAccountId != null) {           
            String v_message =' @ ' +System.now().format('HH:mm:ss')+' - '+v_invoiceData.supplier_text__c+' has approved the invoice ' +v_invoiceData.Invoice_name__c+ ' of '+v_invoiceData.CCY__c+ ' '+v_invoiceData.invoice_amount__c+ ' for listing'; 
            SendSlackMessage.send(config.getConfig('Slack Channel Marketplace URL'), v_message); 
        }
        return new GlobalMethods.InvoiceReturnClass('true', 'Invoice status is successfully updated', null);
       
    }      
}