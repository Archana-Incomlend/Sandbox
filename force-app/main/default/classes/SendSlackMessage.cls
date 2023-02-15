public with sharing class SendSlackMessage {
    // @future(callout=true)   
    public static void send(string url,string Message) {
        // Http h = new Http();
        // HttpRequest req = new HttpRequest();
           
        // if (InvoiceUtil.isRunningInSandbox) {
        //     url = config.getConfig('Slack channel Test IT URL');
        // }
        
        // req.setEndpoint(url);
        // req.setMethod('POST');
        // req.setHeader('Content-Type', 'application/json');
        // req.setBody('{"text":"' + Message + '", "username": "Incomlend"}');

        // if (!Test.isRunningTest()) {
        //     h.send(req);
        // }

        String email = config.getConfig('IncomlendPricing_v3_Notification_AlertsRecipients');
        if (!String.isBlank(email)) {
            List<String> listEmail = new List<String>{email};
            if (email.contains(';')) listEmail = email.split(';');
            String subject = Message.split('\n')[0];
            Helper_Log Logs = new Helper_Log();
            for (String str : Message.split('\n')) {
                Logs.log(str, 1, Helper_Log.Color.Black);
            }
            System.debug('wa ' + Message);
            if (!Test.isRunningTest()) Helper_Email.Send(true, listEmail, subject, Logs.HTMLLog.replaceAll('[\\[\\]\\s-:\\d]{20,}',''));
        }
    
    }
}