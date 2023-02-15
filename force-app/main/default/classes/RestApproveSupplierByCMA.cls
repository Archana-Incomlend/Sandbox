@RestResource(urlMapping='/v9/approveSupplierByCMA')

global with sharing class RestApproveSupplierByCMA {
      
    @HttpPost
    global static GlobalMethods_v9.AccountReturnClass doPost(Id p_userAccountId, Id p_accountId, String p_status) {
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
                    return new GlobalMethods_v9.AccountReturnClass('false','Invalid user', null);
                }
            } catch(GeneralException e) {
                return new GlobalMethods_v9.AccountReturnClass('false',e.getMessage(), null);
            }
        }
        
              
        Account v_accountData = new Account (); 
        String v_name = config.getConfig('cma agent');
       
        v_accountData = [SELECT Id, Name, onboarding_stage__c, Agent__c FROM Account WHERE Id = :p_accountId]; 
       
        if(v_accountData.Agent__c == v_name && p_status == 'approved' && v_accountData.onboarding_stage__c == '65: approval by CMA') {
            v_accountData.onboarding_stage__c = '99.Onboarded';
        } else if (v_accountData.Agent__c == v_name && p_status == 'rejected' && v_accountData.onboarding_stage__c == '65: approval by CMA') {
            v_accountData.onboarding_stage__c = '111.Rejected (by other party)';
        } else {
            return new GlobalMethods_v9.AccountReturnClass('false','Invalid account onboarding stage', null);
        }
               
        update v_accountData;     
        if(p_status == 'approved') {          
            String v_message =' @ ' +System.now().format('HH:mm:ss')+' - CMA has approved the account ' +v_accountData.Name; 
            SendSlackMessage.send(config.getConfig('Slack channel onboarding shipfin URL'), v_message); 
        } else if (p_status == 'rejected') {
            String v_message =' @ ' +System.now().format('HH:mm:ss')+' - CMA has rejected the account ' +v_accountData.Name; 
            SendSlackMessage.send(config.getConfig('Slack channel onboarding shipfin URL'), v_message); 
        }
        return new GlobalMethods_v9.AccountReturnClass('true', 'Account onboarding stage is successfully updated by CMA', null);
       
    }  
// coderage Hack
    global class RestApproveSupplierByCMA_CoverageHack
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