@RestResource(urlMapping='/v7.2/approvelisting')

global with sharing class RestApproveListing_v7_2 {
      
    @HttpPost
    global static GlobalMethods.InvoiceReturnClass doPost(Id p_invoiceId, Id p_userContactId, Id p_userAccountId, String p_userType, String p_status, String p_details ) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        map<String,String> v_headers = new map<String,String>();   
        v_headers = req.headers;
        String v_email = v_headers.get('email');
        String v_ipAddress = v_headers.get('ip');
        
        if(v_email != null) {
            try {
                Id v_loggedInUserAccountId = GlobalMethods.getLoggedinUserAccountId(v_email); 
                if(v_loggedInUserAccountId != p_userAccountId) {
                    return new GlobalMethods.InvoiceReturnClass('false','Invalid user', null);
                }
            } catch(GeneralException e) {
                return new GlobalMethods.InvoiceReturnClass('false',e.getMessage(), null);
            }
        }
        
              
        Invoice_Finance_Deal__c v_invoiceData = new Invoice_Finance_Deal__c (); 
       
        v_invoiceData = [SELECT Id, Supplier_Buyer_Map__r.Buyer__r.Id, Supplier_Buyer_Map__r.Supplier__r.Id, supplier_del__c, Invoice_name__c, invoice_amount__c, CCY__c, supplier_text__c, auto_status__c FROM invoice_finance_deal__c WHERE Id = :p_invoiceId];
        
        p_details = p_details+'\n Logged in user email : '+v_email+'\n'+
                    'Logged in user IP address : '+v_ipAddress+'\n'+
                    'Confirmed date : '+String.valueOf(system.now()); 
       
        if(p_userType == 'supplier') {
            if(v_invoiceData.Supplier_Buyer_Map__r.Supplier__r.Id == p_userAccountId && v_invoiceData.auto_status__c == 'pending supplier review') {
                if(p_status == 'approve') {
                    v_invoiceData.supplier_approval_status__c = 'Approved';
                }else if(p_status == 'reject') {
                    v_invoiceData.supplier_approval_status__c = 'Rejected';
                }
                v_invoiceData.Status__c = 'Pending Incomlend Final Review';
                v_invoiceData.Supplier_Confirmed_Date_2__c = system.now();
                v_invoiceData.Supplier_Approval_Details__c = p_details;
                v_invoiceData.Supplier_Contact_Who_Confirmed__c = p_userContactId;
            }else {
                return new GlobalMethods.InvoiceReturnClass('false','Invalid supplier invoice', null);
            }
        }else  if(p_userType == 'buyer') {
            if(v_invoiceData.Supplier_Buyer_Map__r.Buyer__r.Id == p_userAccountId && v_invoiceData.auto_status__c == 'pending buyer confirmation') {
                if(p_status == 'approve') {
                    v_invoiceData.Buyer_Confirmation_Status__c = 'Confirmed Accurate';
                }else if(p_status == 'reject') {
                    v_invoiceData.Buyer_Confirmation_Status__c = 'Confirmed not accurate';
                }
                v_invoiceData.Status__c = 'pending incomlend review';
                v_invoiceData.Buyer_Confirmed_Date__c = system.today();
                v_invoiceData.Buyer_Confirmation_Details__c = p_details;
                v_invoiceData.Buyer_Contact_Who_Confirmed__c = p_userContactId;
            }else {
                return new GlobalMethods.InvoiceReturnClass('false','Invalid buyer invoice', null);
            }
        }else {
             return new GlobalMethods.InvoiceReturnClass('false','Invalid user type', null);
        }
               
        update v_invoiceData;     
         if(p_userType == 'supplier') {          
            String v_message =' @ ' +System.now().format('HH:mm:ss')+' - '+v_invoiceData.supplier_text__c+' has approved the invoice ' +v_invoiceData.Invoice_name__c+ ' of '+v_invoiceData.CCY__c+ ' '+v_invoiceData.invoice_amount__c+ ' for listing'; 
            SendSlackMessage.send(config.getConfig('Slack Channel Marketplace URL'), v_message); 
        }
        GlobalMethods.addContactLog(p_userContactId, p_invoiceId, 'Approve invoice', '', p_details);
        return new GlobalMethods.InvoiceReturnClass('true', 'Invoice status is successfully updated', null);
       
    }      
}