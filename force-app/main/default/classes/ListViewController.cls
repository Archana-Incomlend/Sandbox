public class ListViewController {

    public static void log(Helper_Log Logs, String str) {
        System.debug(str);
        if (Logs != null) Logs.log(str, 2, Helper_Log.Color.Black);
    }
    
    public List<Id> SetId {get;set;}
    
    public String ListId {get;set;}
    
    public String objectType {get;set;}
    
    public String CallbackUrl {get;set;}

    public String errorMessage {get;set;}

    public String newblobMessage {get;set;}
    
    public boolean isOnboardingChecklist {get;set;}

    public ApexPages.StandardSetController ssc {get;set;}

    public boolean isAllRecords {get;set;}

    private void init() {
        errorMessage = '';
        newblobMessage = null;
        isOnboardingChecklist = false;
        isAllRecords = false;
    }

    public void downloadInit() {

        if (!isAllRecords && (ListId == null || ListId == '')) return;
        Helper_Log logs = new Helper_Log();
        HttpResponse res = downloadAttachment(logs, ListId, objectType);
        if (res.getStatusCode() != 200) {

            if (res.getBody() == 'CalloutException: Exceeded max size limit of 6000000') {
                // workaround CalloutException: Exceeded max size limit of 6000000
                errorMessage = res.getStatusCode() + ' ' + res.getBody();
                String endpoint = GlobalTriggerHandler.getConfiguration('salesforceEndpoint') + '/document-cache';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Preferred total file size less than 6MB <a href="' + endpoint + '" target="_blank" type="application/zip" download="document.zip">download</a>'));   
            } else {
                errorMessage = res.getStatusCode() + ' ' + res.getBody();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));    
            }
        } else {
            try {
                Blob blobMessage = res.getBodyAsBlob();
                newblobMessage = EncodingUtil.base64Encode(blobMessage);     
                if (newblobMessage.length() > 100000) {
                    newblobMessage = null;
                    throw new GeneralException('Maximum view state size limit exceeded');
                }
            } catch (Exception ex) { // Maximum view state size limit (170KB) exceeded. 
                System.debug(ex);
                String endpoint = GlobalTriggerHandler.getConfiguration('salesforceEndpoint') + '/document-cache';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage() + ' - Download here <a href="' + endpoint + '" target="_blank" type="application/zip" download="document.zip">download</a>'));       
            }
        }
    }

    public ListViewController(ApexPages.StandardController stdController){
        SObject obj = (SObject)stdController.getRecord();
        ListId = obj.Id;
        SetId = new List<Id> { obj.Id };  
        objectType = ''+ obj.getSObjectType(); 
        CallbackUrl = GlobalTriggerHandler.getBaseUrl() + '/' + obj.Id;
        init();
        if (objectType == 'Account') {
            isOnboardingChecklist = true;
            objectType = 'onboarding_checklist__c';
        }
    }

    public ListViewController(ApexPages.StandardSetController listcontroller) {
        ListId = '';
        SetId = new List<Id>();   
        ssc = listcontroller;

        init();
        objectType = '' + listcontroller.getRecord().getSObjectType();
        CallbackUrl = listcontroller.getRecord().getSObjectType().getDescribe().getKeyPrefix();
        CallbackUrl = GlobalTriggerHandler.getBaseUrl() + '/' + CallbackUrl + '?fcf=' + listcontroller.getFilterId().substring(0,15);
        SetId = new List<Id>();
        if (listcontroller.getSelected().size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No record selected, request admin to resource-consuming download all (all pages) - 2min+ or 100MB+ or 40+ files - '));   
        } else {
            ListId = getRecordList(listcontroller, false, SetId);
        }
    }

    public void downloadAll() {
        isAllRecords = true;
        ListId = getRecordList(ssc, true, SetId);
        downloadInit();
    }

    private static String getRecordList(ApexPages.StandardSetController listcontroller, boolean isAllRecords, List<Id> setId) {
        String ListId = '';
        if (SetId == null) SetId = new List<Id>();

        if (isAllRecords) {
            listcontroller.setPageNumber(1); 
            while (true) { 
                for (SObject obj : listcontroller.getRecords()) {
                    if (ListId != '') ListId += ',';
                    ListId += obj.Id;
                    SetId.add(obj.Id);
                }
                if (!listcontroller.getHasNext()) break;
                listcontroller.next(); 
            }
        } else {
            for (SObject obj : listcontroller.getSelected()) {
                if (ListId != '') ListId += ',';
                ListId += obj.Id;
                SetId.add(obj.Id);
            }    
        }
        return ListId;
    }

    public static HttpResponse downloadAttachment(Helper_Log Logs, String ListId, String objectType) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/plain');
        res.setStatusCode(500);

        String endpoint = GlobalTriggerHandler.getConfiguration('salesforceEndpoint');
        endpoint += '/document?&id=' + ListId;
        if (objectType != null && objectType != 'Account') endpoint += '&object=' + objectType; 

        String apikey = GlobalTriggerHandler.getConfiguration('salesforceApiKey');
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('x-api-key', apikey);
        request.setTimeout(2 * 60 * 1000); //2m (max value)
        System.debug(endpoint);
        System.debug(apikey);

        try {
            res = http.send(request); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Done'));   
        } catch (CalloutException e) {
            System.debug(e);
            res.setBody('CalloutException: ' + e.getMessage());
        } catch (Exception e) {
            System.debug(e);
            res.setBody('Error occured: ' + e.getMessage());
        }
            
        return res;
    }

    public PageReference close() {
        System.debug('close');
        PageReference pr = new PageReference(CallbackUrl); 
        pr.setRedirect(true);
        return pr;
    }

}