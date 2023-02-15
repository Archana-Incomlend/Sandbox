@RestResource(urlMapping='/v9/Fasanara/*')
global class FasanaraController implements Schedulable {

    public static String CLO_1 = '00O0I00000AXBK5UAP';
    public static String CLO_2 = '00O0I00000AY8pnUAD';
    public static String[] SUPPORTED_IDS = new String[] { CLO_1, CLO_2 };

    public static String DROPBOX_APP_KEY = 'l2lm12j0rb7g4h2';
    public static String DROPBOX_APP_SECRET = 'n675aja0zkuw7r0';
    public static String DROPBOX_AUTH_CODE = '5Bw147EW7AkAAAAAAAAAASRXQnh-EPR8QXV_0NdER6j8b28FhrF1pGs76NGO7oDH'; 

    public static boolean needRunScheduler = true; 
    public Helper_Log Logs { get; set; }

    public FasanaraController(){
        this.Logs = new Helper_Log();
    }
    
    public static void log(Helper_Log Logs, String str) {
        System.debug(str);
        if (Logs != null) Logs.log(str, 2, Helper_Log.Color.Black);
    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        res.statusCode = 500;
        String reportId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 

        // limited access
        if (!GlobalTriggerHandler.runningInASandbox || reportId != '' || Test.isRunningTest()) // block scheduler in sandbox 
        reportId = CLO_1 + ',' + CLO_2;
 
        mainFuture(reportId);
        res.statusCode = 200;
    }

    public static String refreshToken(Helper_Log Logs) {
        if (!needRunScheduler) return '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse res = new HttpResponse();

        String endpoint ='https://api.dropboxapi.com/oauth2/token?';
        endpoint += '&grant_type=refresh_token';
        endpoint += '&refresh_token='+DROPBOX_AUTH_CODE;
        endpoint += '&client_id='+DROPBOX_APP_KEY;
        endpoint += '&client_secret='+DROPBOX_APP_SECRET;
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');

        try {
            res = http.send(request);
            log(Logs, 'Refresh token ' + res.toString());
            String token = null;
            if (res.getStatusCode() == 200) { 
                token = (String)((Map<String, Object>)Json.deserializeUntyped(res.getBody())).get('access_token'); 
                if (token != null) GlobalTriggerHandler.dropboxToken = token; // try { GlobalTriggerHandler.setConfigFuture('dropboxToken', token); } catch (AsyncException e) { System.debug(e.getMessage()); } // lenient
            } else throw new GeneralException(res.getBody()); 
            return token;
        } catch (Exception e) {
            if (!(e instanceof CalloutException)) System.debug(e);
            log(Logs, 'Unable to refresh token ' + e.getMessage());
            return null;
        }
    }

    public static boolean retrieveReport(Helper_Log Logs, String reportId, String refreshToken) {
        if (!needRunScheduler) return true;
        log(Logs, 'Retrieve report ' + reportId);
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        String url = baseUrl+'/'+reportId+'?csv=1'; System.debug(url);
        PageReference pageRef = new PageReference(url); pageRef.setRedirect(true);
        String reportText = !Test.isRunningTest() ? pageRef.getContent().toString() : '';
        // if (reportText.left(20).indexOf('DOCTYPE') != -1) { reportText = 'https://incomlend' + (GlobalTriggerHandler.runningInASandbox?'--icldv04dvp.sandbox':'') + '.lightning.force.com/lightning/_classic/' + ('/'+reportId+'?csv=1&inline=1').replaceAll('/','%2F').replaceAll('\\?','%3F').replaceAll('&','%26').replaceAll('=','%3D'); System.debug(reportText); reportText = new PageReference(reportText).getContent().toString(); }
        if (reportText.left(20).indexOf('DOCTYPE') != -1) { reportText= baseUrl + '/ltng/switcher?destination=classic&referrer=%2F001'; System.debug(reportText); new PageReference(reportText).getContent(); reportText = new PageReference(url).getContent().toString(); }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse res = new HttpResponse();

        String endpoint ='https://content.dropboxapi.com/2/files/upload';
        String token = refreshToken;
        if (token == null) token = GlobalTriggerHandler.getConfiguration('dropboxToken');
        String path = '/deleteme.csv';
        if (!GlobalTriggerHandler.runningInASandbox && reportId == CLO_1) path = '/Incomlend Statements/Incomlend_Fasanara_Transactions.csv';
        if (!GlobalTriggerHandler.runningInASandbox && reportId == CLO_2) path = '/Incomlend Statements/Incomlend_Fasanara_Positions.csv';
        request.setEndpoint(endpoint);
        request.setBody(reportText);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/octet-stream');
        request.setHeader('Content-Length',String.valueOf(reportText.length()));
        request.setHeader('Dropbox-API-Arg', '{"path":"' + path + '","mode":"overwrite"}');
        request.setHeader('Accept', '*/*');
        request.setHeader('Authorization', 'Bearer ' + token);

        try {
            for (integer count : new integer[] { 0, 1 }) {
                if (count == 1) request.setHeader('Dropbox-API-Arg', request.getHeader('Dropbox-API-Arg').replace('Statements/','Statements/CLO ICL Report Archive/').replace('.csv', System.now().format(' ddMMYY') + '.csv'));
                if (!String.isBlank(token)) res = http.send(request);
                log(Logs, 'Dropbox ' + (count==1?'copy ':'') + res.toString());
                if (String.isBlank(token) || ((res.getStatusCode() == 401 || (res.getStatusCode() != 200 && res.getBody().indexOf('access token is malformed') != -1)) && refreshToken == null)) { // && (res.getBody().indexOf('expired_access_token') != -1 || res.getBody().indexOf('invalid_access_token') != -1)
                    log(Logs, res.getBody()); 
                    token = refreshToken(Logs); 
                    if (token != null) {
                        request.setHeader('Authorization', 'Bearer ' + token);
                        res = http.send(request);
                        log(Logs, 'Dropbox redo ' + res.toString());
                    }
                }
                if (res.getStatusCode() != 200) { log(Logs, res.getBody()); return false; }
                if (Test.isRunningTest() || GlobalTriggerHandler.runningInASandbox) break;
            }
        } catch (Exception e) {
            if (!(e instanceof CalloutException)) System.debug(e);
            log(Logs, 'Error occurred ' + e.getMessage());
            return false;
        }
        return true;
    }

    public static void main(String str) {
        if (String.isBlank(str)) return;
        
        Helper_Log Logs = new Helper_Log();
        boolean result = true;
        String temp = GlobalTriggerHandler.getConfiguration('dropboxToken');
        for (String reportId : str.split(',')) {
            if (!SUPPORTED_IDS.contains(reportId)) { log(Logs, 'Invalid report Id ' + reportId); continue; }
            try {
                if (!retrieveReport(Logs, reportId, null)) result = false;
            } catch (Exception ex) {
                System.debug(ex);
                log(Logs, ex.getMessage());
                result = false;
            } 
            if (Test.isRunningTest() || GlobalTriggerHandler.runningInASandbox) break;
        }
        if (!result) GlobalTriggerHandler.OutError('Fasanara Download Report fail', Logs); 
        if (temp != GlobalTriggerHandler.dropboxToken) GlobalTriggerHandler.setConfig('dropboxToken', GlobalTriggerHandler.dropboxToken);
    }

	@future (callout=true)
    public static void main() {
        main(CLO_1);
        main(CLO_2);
    }

	@future (callout=true)
    public static void mainFuture(String reportId) {
        if (String.isBlank(reportId)) return;
        main(reportId);
    }
    
    global void execute(SchedulableContext SC)
    {
        main(); // not working scheduler ApexPagesGenericException: 404 https://cs112.salesforce.com/null?csv=1
    }
}