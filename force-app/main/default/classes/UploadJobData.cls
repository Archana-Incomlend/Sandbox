@RestResource(urlMapping='/v9/jobs/*')

global with sharing class UploadJobData {

    @HttpPost
    global static String doPost(String objectName, String csvFile) {
        IncomlendPricing_v3_Configuration.NotificationConfiguration notification = null;
        if (!Test.isRunningTest()) {
                notification = new IncomlendPricing_v3_Configuration.NotificationConfiguration();
        }
        Helper_Log logs = new Helper_Log();

        HttpResponse response1;
        HttpResponse response2;
        HttpResponse response3;
        HttpResponse response4;

        String finalResponse;
        String jobId;

        // ----- First request to create Job ------
        
        // Set up the request
        HttpRequest request1 = new HttpRequest();
        request1.setMethod('POST');
        request1.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v50.0/jobs/ingest');
        request1.setHeader('content-type', 'application/json' );
        request1.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );  
        String body = '{ '+
                        '"externalIdFieldName": "Id",'+   
                        '"operation": "insert",'+ 
                        //'"ColumnDelimiter" : "COMMA",'+
                        '"object": "'+objectName+'",'+ 
                        '"contentType": "CSV"'+
                      '}';

        request1.setBody(body);

        try {
                Http h1 = new Http();
                // Provess the callout
                response1 = h1.send(request1);
                // TO REMOVE
                logs.Log('request1: ' + request1.toString());
                logs.LogLine();
                logs.Log('response1: ' +response1.toString());
                logs.LogLine();
            
            } catch (Exception ex) {
                logs.LogLine();
                logs.Log(ex);
                logs.LogLine();
                
                if (!Test.isRunningTest()) {
                    Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
                }
                return ex.getMessage();
            }
        
        if(response1.getStatusCode() <= 299) {
            // -------- Second request to upload Job -----

            // Set up the request
            Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(response1.getBody());
            jobId = (String)respMap.get('id');

            // TO remove but remove last and first
            csvFile ='Supplier_Buyer_Map__c\na0q0T0000008INb';
            

            Blob beforeBlob = Blob.valueOf(csvFile);
            String csvFileEncoded = EncodingUtil.base64Encode(beforeBlob);

            HttpRequest request2 = new HttpRequest();

            request2.setHeader('content-type', 'text/csv' );
            request2.setHeader('Authorization', 'Bearer ' + userInfo.getSessionId());
            request2.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v50.0/jobs/ingest/'+jobId+'/batches');
            request2.setMethod('PUT');
            request2.setBody(csvFile);

            try {
                Http h2 = new Http();
                // Process the callout
                response2 = h2.send(request2);
                // TO REMOVE
                logs.Log('request2: ' + request2.toString());
                logs.LogLine();
                logs.Log('response2: ' + response2.toString());
                logs.LogLine();
                
            } catch (Exception ex) {
                logs.LogLine();
                logs.Log(ex);
                logs.LogLine();
                
                if (!Test.isRunningTest()) {
                    Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
                }
                return ex.getMessage();
            }
        } else {
            finalResponse =  '{"Status":"' + response1.getStatusCode() + '", "jobId":"' + jobId.removeEnd('QAU') + '"}';
        }

        if(response2.getStatusCode() <= 299) {
            // -------- Third request to process Job -----

            // Create the request
            HttpRequest request3 = new HttpRequest();
            request3.setMethod('PATCH');
            request3.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v50.0/jobs/ingest/'+jobId);
            request3.setHeader('content-type', 'application/json' );
            request3.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );                  
            request3.setBody('{ "state" : "UploadComplete" }');

                try {
                Http h3 = new Http();
                // Process the request
                response3 = h3.send(request3);

                // TO REMOVE
                logs.Log('request3: ' + request3.toString());
                logs.LogLine();
                logs.Log('response3: ' + response3.toString());
                logs.LogLine();

                } catch (Exception ex) {
                    logs.LogLine();
                    logs.Log(ex);
                    logs.LogLine();
                    
                    if (!Test.isRunningTest()) {
                        Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
                    }
                    return ex.getMessage();
                }
        } else {
            finalResponse =  '{"Status":' + response2.getStatusCode() + '", "jobId":"' + jobId.removeEnd('QAU') + '"}';
        }

        String respBody;

        wait(10000);     

        if(response3.getStatusCode() <= 299) {
            // -------- Fourth request to return successful results -----

            // Create the request
            HttpRequest request4 = new HttpRequest();
            request4.setMethod('GET');
            request4.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v50.0/jobs/ingest/'+jobId + '/successfulResults');
            request4.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );
            request4.setHeader('Content-Type', 'application/json' ); 
            request4.setHeader('Accept', 'application/json' ); 
            request4.setHeader('Accept-Encoding', 'gzip, deflate, br');
            request4.setHeader('Connection', 'keep-alive');
            request4.setHeader('Cache-Control', 'no-cache');
            request4.setHeader('Cookie','BrowserId=pSXZua7vEeukVeNcrGB-SQ');
 
                try {
                    Http h4 = new Http();
                    // Process the request
                    response4 = h4.send(request4);
                    //XmlStreamReader respBodyBlob = response4.getXmlStreamReader();
                    respBody = response4.getBody();

                    // sent result
                    finalResponse =  '{"Status":"' + response4.getStatusCode() + '","body":"' + respBody + '"}';

                    // TO REMOVE
                    logs.Log('request4: ' + request4.toString());
                    logs.LogLine();
                    logs.Log('response4: ' + response4.toString());
                    logs.LogLine();

                } catch (Exception ex) {
                    logs.LogLine();
                    logs.Log(ex);
                    logs.LogLine();
                    
                    if (!Test.isRunningTest()) {
                        Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
                    }
                    return ex.getMessage();
                }
        } else {
            finalResponse =  '{"Status":"' + response3.getStatusCode() + '","Body":"' + respBody + '","jobId":"' + jobId + '"}';
        }

        logs.LogLine();
        logs.Log('final response: ' + finalResponse);
        logs.Log('token:' + 'Bearer '+userInfo.getSessionId());
        logs.LogLine();

        // Send notification
        if (!Test.isRunningTest()) {
            Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
        }

        return finalResponse;
    }

    public static void wait(Integer millisec) {
    
    if(millisec == null || millisec < 0) {
      millisec = 0;
    }
      
    Long startTime = DateTime.now().getTime();
    Long finishTime = DateTime.now().getTime();
    while ((finishTime - startTime) < millisec) {
      //sleep for parameter x millisecs
      finishTime = DateTime.now().getTime();
    }
    // System.debug('>>> Done from ' + startTime + ' to ' + finishTime);
  }
    
}