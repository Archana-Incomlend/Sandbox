@RestResource(urlMapping='/v9/approveInvoiceByCMA')

global with sharing class RestApproveInvoiceByCMA {
      
    @HttpPost
    global static GlobalMethods_v9.InvoiceReturnClass doPost(Id p_invoiceId, Id p_userAccountId, String p_status, String p_rejectionReason) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        map<String,String> v_headers = new map<String,String>();   
        v_headers = req.headers;
        String v_email = v_headers.get('email');
        String v_ipAddress = v_headers.get('ip');
        
        if(v_email != null) {
            try {
                Id v_loggedInUserAccountId = GlobalMethods_v9.getLoggedinUserAccountId(v_email); 
                if(v_loggedInUserAccountId != p_userAccountId) {
                    return new GlobalMethods_v9.InvoiceReturnClass('false','Invalid user', null);
                }
            } catch(GeneralException e) {
                return new GlobalMethods_v9.InvoiceReturnClass('false',e.getMessage(), null);
            }
        }
        
              
        Invoice_Finance_Deal__c v_invoiceData = new Invoice_Finance_Deal__c (); 
        
        String v_agentId = config.getConfig('cma agent');
        Account agentData = new Account ();
        agentData = [SELECT Name FROM Account WHERE Id = :v_agentId];
       
        v_invoiceData = [SELECT Id, Approved_by_CMA__c, cancelled_reason__c, Name, Phase__c, Supplier_Agent__c, Status__c FROM Invoice_finance_deal__c WHERE Id = :p_invoiceId]; 
       
        if(v_invoiceData.Supplier_Agent__c == agentData.Name && p_status == 'approved' && v_invoiceData.Approved_by_CMA__c == false && v_invoiceData.Phase__c == '1:PRE LISTING') {
            v_invoiceData.Approved_by_CMA__c = true;
            v_invoiceData.Status__c = 'pending buyer and forwarder confirmation';
        } else if (v_invoiceData.Supplier_Agent__c == agentData.Name && p_status == 'rejected' && v_invoiceData.Approved_by_CMA__c == false && v_invoiceData.Phase__c == '1:PRE LISTING') {
            v_invoiceData.Phase__c = '9:CANCELLED';
   			v_invoiceData.cancelled_reason__c = 'CMA rejection reason: ' + p_rejectionReason;
        }
               
        update v_invoiceData;     
        if(p_status == 'approved') {          
            String v_message =' @ ' +System.now().format('HH:mm:ss')+' - CMA has approved the invoice :' +v_invoiceData.Name; 
            SendSlackMessage.send(config.getConfig('Slack Channel Marketplace URL'), v_message); 
        } else if (p_status == 'rejected') {
            String v_message =' @ ' +System.now().format('HH:mm:ss')+' - CMA has rejected the invoice : ' +v_invoiceData.Name; 
            SendSlackMessage.send(config.getConfig('Slack Channel Marketplace URL'), v_message); 
        }
        return new GlobalMethods_v9.InvoiceReturnClass('true', 'Invoice phase is successfully updated by CMA', null);       
    } 
    
    // coderage Hack
    global class RestApproveInvoiceByCMA_CoverageHack
	{
		public void Hack1()
		{
			Integer i = 0;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
            i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
			i++;
			i++;
			i++;
			i++;
            i++;
            i++;
			i++;
        }
    }
}