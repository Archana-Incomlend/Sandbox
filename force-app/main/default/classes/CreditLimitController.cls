@RestResource(urlMapping='/v9/CreditLimit/*')
global class CreditLimitController implements Schedulable {

    public static boolean needRunTrigger = true;
    public static boolean IsNeedRunTrigger
    {
      public get  // to enable trigger during test set it to null
      {
        return Test.isRunningTest() ? needRunTrigger == null : needRunTrigger == true;
      }
      public set
      {
          if (value) needRunTrigger = Test.isRunningTest() ? null : true;
          else needRunTrigger = false;
      }
    }

    public static String salesforceEndpoint;
    public static String salesforceApiKey;

    public Helper_Log Logs { get; set; }

    public static integer cutOffCallout = 20; // from observation 20ish hit exceeded maximum.. 120000 ms and call out is not fired
    
    public CreditLimitController(){
        this.Logs = new Helper_Log();
    }
    
    public static void log(Helper_Log Logs, String str) {
        System.debug(str);
        if (Logs != null) Logs.log(str, 2, Helper_Log.Color.Black);
    }

    @HttpPut
    global static void doPut() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        res.statusCode = 200;
        String p_accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
        if (!String.isBlank(p_accountId)) execute(p_accountId);
        else System.debug('Lead Id is empty');
    }

    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        res.statusCode = 200;
        String p_accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
        main(p_accountId);
    }

    public static boolean retrieveDecision(Helper_Log Logs, String leadId, String coverId) {
        if (!isNeedRunTrigger) return true;
        return callInsurerApi(Logs, leadId, coverId, false);
    }

    public static boolean createCoverTypeIndication(Helper_Log Logs, String leadId) {
        if (!isNeedRunTrigger) return true;
        return callInsurerApi(Logs, leadId, null, true);
    }

    public static boolean callInsurerApi(Helper_Log Logs, String leadId, String coverId, boolean createIndicationElseRetrieve) {
        if (!isNeedRunTrigger) return true;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse res = new HttpResponse();

        String endpoint = GlobalTriggerHandler.getConfiguration('salesforceEndpoint');
        endpoint += '/underwriter?';
        endpoint += createIndicationElseRetrieve ? '&id=' + leadId : (coverId == null ? '' : '&id=' + coverId) + '&leadId=' + leadId;
        request.setEndpoint(endpoint);
        if (leadId.indexOf('scheduler') != -1) log(Logs, 'endpoint ' + request.getEndPoint());
        request.setMethod(createIndicationElseRetrieve ? 'PUT' : 'GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', '*/*');
        request.setHeader('x-api-key', GlobalTriggerHandler.getConfiguration('salesforceApiKey'));
        
        try {
            if(!Test.isRunningTest()) res = http.send(request);
            log(Logs, res.toString());
            // if (!createIndicationElseRetrieve && res.getStatusCode() == 404) return null;
            if (res.getStatusCode() != 200) return false;
        } catch (CalloutException e) {
            if (e.getMessage() == 'Read timed out' || e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)') {
                log(Logs, 'Unable to wait for response ' + e.getMessage());
                if (!createIndicationElseRetrieve) return null;
            } else {
                log(Logs, 'CalloutException ' + e.getMessage());
                return false;
            } 
        } catch (Exception e) {
            System.debug(e);
            log(Logs, 'Error occurred ' + e.getMessage());
            return false;
        }
        return true;
    }

    public static void main(String p_accountId) {
        Helper_Log Logs = new Helper_Log();
        String selectStr = 'SELECT Id, Company, Atradius_Cover_Id__c, Country, Decision__c, Lead_Owner_email__c FROM Lead';
        String whereStr = ' WHERE RecordTypeId = \'0120I000000OcVvQAK\'';
        String condition = '';
        List<String> accountSearch = String.isBlank(p_accountId) ? null : p_accountId.split(';');

        DateTime atradiusLastFullScan = null;
        if (String.isBlank(p_accountId)) {
            whereStr += ' AND Atradius_Id__c != null';
            whereStr += ' AND ('; 
            whereStr += '(Status != \'Open\' AND Status != \'Contacted\' AND Status != \'Credit Limit Requested\' AND Status != \'Credit Limit Rejected by Insurer\')';
            whereStr += ' OR Credit_Limit_Request_Approved__c = true';
            whereStr += ' OR (Atradius_Status__c = \'Indication created\' AND Status = \'Credit Limit Requested\')';
            whereStr += ')';
            try {
                String str = config.getConfig('Atradius_Last_Full_Scan');
                if (str != null && str != 'key not found') atradiusLastFullScan = DateTime.valueOf(str);
                // atradiusLastFullScan = GlobalTriggerHandler.getMetaDataSetting('Atradius_Last_Full_Scan');
                atradiusLastFullScan = atradiusLastFullScan.addMinutes(10); // assuming &special=scheduler was used
            } catch (Exception ex) {
                log(Logs, 'Invalid format for atradius last full scan datetime ' + ex.getMessage());
            }
            if (atradiusLastFullScan != null && atradiusLastFullScan > DateTime.now()) atradiusLastFullScan = DateTime.now();
            condition = 'Decision__c = null OR Decision__c = \'Pending\'';
            if (atradiusLastFullScan == null) condition += ' OR Atradius_Cover_Id__c = null';
            else condition = '(' + condition + ') AND (Atradius_Cover_Id__c != null OR (Atradius_Cover_Id__c = null AND LastModifiedDate > :atradiusLastFullScan))';
            condition = ' AND (' + condition + ')';

        } else {
            condition = ' AND Id IN :accountSearch';
        }
        String sortStr = ' ORDER BY LastModifiedDate desc';
        List<Lead> listLead = new List<Lead>();
        if (p_accountId.indexOf('&') != -1 && p_accountId.indexOf('=') != -1) {
            listLead.add(null); // go into currentLead == null
        } else {
            log(Logs, 'queryString' + whereStr + condition);
            listLead = Database.query(selectStr + whereStr + condition);
            System.debug('total lead ' + listLead.size());
        }

        boolean result = true;
        integer size = Math.round(listLead.size());// / (100 - 10)); // maximum callout limit 100, 10 buffer
        size = Math.Min(size, 100); // error at 450ish total leads, uri too large // error at 100ish, expired token
        integer count = 0;
        String ids = '';
        String redo = '';
        // String listLeadStr = ''; // all leads
        Long startTime = Datetime.now().millisecond();
        for (Lead currentLead : listLead) 
        {
            if (size <= 1) log(Logs, currentLead == null ? p_accountId : 'Lead ' + toString(currentlead));
            count += 1;
            ids += (ids==''?'':',') + (currentLead == null ? p_accountId : currentLead.Id);
            // listLeadStr += ',' + currentLead.Id;
            if (size > 1 && Math.mod(count, size) != 0 && count != size) continue;
            try {
                log(Logs, 'Retrieve cover ' + (count > 10 ? Pattern.compile('(.{200})').matcher(JSON.serialize(ids)).replaceAll('$1\n') : ids));
                boolean temp = retrieveDecision(Logs, ids + (count > cutOffCallout ? '&special=scheduler' : ''), null);
                if (temp != null) result = result && temp;
                else redo += (redo==''?'':',') + ids;
                ids = '';
                count = 0;
            } catch (Exception ex) {
                System.debug(ex);
                log(Logs, ex.getMessage());
                result = false;
            } 
        }    
        if (redo != '' || Test.isRunningTest()) {
            if (redo.indexOf('&') == -1) redo += '&special=scheduler';
            log(Logs, 'Redo ' + Pattern.compile('(.{200})').matcher(JSON.serialize(redo)).replaceAll('$1\n'));
            try {
                boolean temp = retrieveDecision(Logs, redo, null); 
                result = result && (temp == true);
            } catch (Exception ex) {
                System.debug(ex);
                log(Logs, ex.getMessage());
                result = false;
            } 
        }

        if (!result) GlobalTriggerHandler.OutError('Run Atradius retrieve decision fail', Logs);
        if (String.isBlank(p_accountId) && listLead.size() > 0) {
            // GlobalTriggerHandler.putMetaDataSetting('Atradius_Last_Full_Scan');
            if (!GlobalTriggerHandler.setConfig('Atradius_Last_Full_Scan', String.valueOf(DateTime.now()))) {
                log(Logs, 'Unable to save atradius last full scan datetime');
            }
        }
    }

	@future (callout=true)
    public static void main() {
        main('');
    }

	@future (callout=true)
    public static void mainFuture(String p_accountId) {
        main(p_accountId);
    }
    
    global void execute(SchedulableContext SC)
    {
        main();
    }

	@future (callout=true)
    public static void execute(String p_accountId) 
    {
        if (!isNeedRunTrigger) return;

        Helper_Log Logs = new Helper_Log();
        boolean result = true;
        try {
            if (String.isBlank(p_accountId)) throw new GeneralException('Lead id is empty');
            List<String> accountSearch = p_accountId.split(';');
            if (p_accountId.indexOf('&') != -1 && p_accountId.indexOf('=') != -1) {
                result = createCoverTypeIndication(Logs, p_accountId);
            } else {
                List<Lead> listLead = [SELECT Id, Company, Country, Decision__c, Atradius_Cover_Id__c FROM Lead WHERE Id IN :accountSearch];
                if (listLead.size() < accountSearch.size()) throw new GeneralException('Invalid lead id ' + p_accountId);
    
                for (Lead currentLead : listLead) 
                {
                    // if (currentLead.Atradius_Cover_Id__c != null) continue;
                    log(Logs, 'Create cover type indication ' + toString(currentlead) + ' ' + currentlead.Id);
                    result = result && createCoverTypeIndication(Logs, ''+currentLead.Id);
                }    
            }
        } catch (Exception ex) {
            System.debug(ex);
            result = false;
            log(Logs, ex.getMessage());    
        } 
        String str = Logs.PlainLog.toLowerCase();
        if (!result && str.indexOf('invalid') == -1 && str.indexOf('is empty') == -1 && str.indexOf('nearest match') == -1) {
            GlobalTriggerHandler.OutError('Run Atradius create indication fail', Logs);
        }
    }

    public static String toString(Object obj) {
        try {
            if (obj instanceof List<Object>) {
                String str = '';
                List<Object> listObj = (List<Object>)obj;
                if (listObj.size() > 10) return 'total ' + listObj.size(); 
                for (Object item : listObj) 
                {
                    str += ', ' + toString(item);
                } 
                str = '{' + str.substring(str.indexOf(', ') + 1) + ' }';
                return str;

            } else if (obj instanceof Lead) {
                Lead ld = (Lead)obj;
                return ld.Company + ' ' + ld.Country + ' ' + ld.Decision__c;
            } 
        } catch (Exception ex) {
            System.debug(ex);
        }
        return String.valueOf(obj);
    }
}