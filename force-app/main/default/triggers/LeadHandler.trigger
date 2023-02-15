trigger LeadHandler on Lead (after update) {
  
  if (Trigger.isUpdate) {
    if (Trigger.isBefore || Trigger.isAfter) {
      if (CreditLimitController.IsNeedRunTrigger) {
        List<Id> listLeadId = new List<Id>();
        for (Lead currentLead : Trigger.New) 
        {
          Lead oldLead = Trigger.OldMap.get(currentLead.Id);
          
          if (currentLead.Credit_Limit_Request_Approved__c && !oldLead.Credit_Limit_Request_Approved__c) {
            listLeadId.add(currentLead.Id);
          } else if (currentLead.Status == 'Credit Limit Approved from Risk' && oldLead.Status == 'Credit Limit Requested') {
            listLeadId.add(currentLead.Id); // last try
          } else continue;

          // if (currentLead.Risk_Member__c != null) continue;
          // if (currentLead.Date_Credit_Limit_Requested_by_Risk__c != null) continue;
          // if (currentLead.Atradius_Cover_Id__c != null) continue;
          // if (currentLead.Atradius_Status__c == 'Attempted') continue;

          if (currentLead.Insured_by__c != null && currentLead.Insured_by__c != 'Atradius') continue;
          if (currentLead.Decision__c != null && currentLead.Decision__c != 'Pending') {
            if (GlobalTriggerHandler.coalesce(currentLead.Credit_Limit_Provided_by_Insurer__c) <= 0
                && GlobalTriggerHandler.coalesce(currentLead.Date_Credit_Limit_Requested_by_Risk__c, currentLead.LastModifiedDate.date()).addDays(90) >= System.Today()) {
              if (Trigger.isBefore) currentLead.Atradius_Comment__c = 'Skip because rejected recently, please Run Atradius manually to re-apply';
              continue;
            }
            if (GlobalTriggerHandler.coalesce(currentLead.Credit_Limit_Provided_by_Insurer__c) >= GlobalTriggerHandler.coalesce(currentLead.Credit_Limit_requested__c)) {
              if (Trigger.isBefore) currentLead.Atradius_Comment__c = 'Skip because CL Provided by Insurer was higher than Credit Limit requested';
              continue;
            }
          }
          if (currentLead.Credit_Limit_Requested_CCY__c != 'USD' && currentLead.Credit_Limit_Requested_CCY__c != 'EUR') {
            if (Trigger.isBefore) currentLead.Atradius_Comment__c = 'Currency not covered by Atradius';
            continue;
          }
          // if (currentLead.New_Increase__c != null && currentLead.New_Increase__c != 'New') continue;
          if (currentLead.Type__c == 'Credit Limit') {
            if (Trigger.isBefore) currentLead.Atradius_Comment__c = 'Only Indication-type is automated, Credit Limit-type is manual';
            continue;
          }
        }
        if (Trigger.isBefore) return;
        if (listLeadId.size() > 0) {
          List<Lead> listLead = 
              [ SELECT Id, Comments__c,
                  (SELECT Id, Comments FROM ProcessSteps),// ORDER BY CreatedDate DESC LIMIT 1),                  
                  (SELECT Id, Name, ContentType FROM Attachments ORDER BY CreatedDate ASC LIMIT 1)
                FROM Lead WHERE Id IN : listLeadId];
          String leadSearch = '';

          for (Lead currentLead : listLead) 
          {
            boolean bypass = false;
            String comment = '';
            for (ProcessInstanceHistory processSteps : currentLead.ProcessSteps) comment += ' ' + processSteps.Comments;
            if (comment == null) comment = '';
            if (currentLead.Comments__c != null) comment += ' ' + currentLead.Comments__c;
            String filename = '';
            // filename = currentLead.Attachments.size() > 0 ? currentLead.Attachments[0].Name : null; // remove the check for file
            // System.debug('filename ' + filename + ' comment ' + comment);

            if (comment.indexOf('BCC') != -1) bypass = true;
            if (comment.indexOf('FCI') != -1) bypass = true;
            if (comment.indexOf('ICEIC') != -1) bypass = true;
            if (comment.indexOf('ICIEC') != -1) bypass = true;
            // if (comment.indexOf('reapply') != -1) bypass = true;
            // if (comment.indexOf('re-apply') != -1) bypass = true;

            if (!bypass && (!String.isBlank(filename) || Test.isRunningTest())) {
              bypass = true;
              String company = Trigger.NewMap.get(currentLead.Id).Company;
              String leadOwner = Trigger.NewMap.get(currentLead.Id).Lead_Owner_email__c;
              if (!String.IsBlank(leadOwner)) leadOwner = '@' + leadOwner.subString(0, leadOwner.indexOf('@'));
              String subject = leadOwner + ' CL for ' + company + ' has file(s) requires manual attention';
              String body = '';

              Helper_Log Logs = new Helper_Log();
              body = 'Lead <a href="https://incomlend.my.salesforce.com/' + currentLead.Id + '">' + currentLead.Id + '</a>';
              if (filename != null) {
                body += ' file(s) ' + filename;  
              }

              String email = GlobalTriggerHandler.getConfiguration('notificationAtradius');
              if (!String.isBlank(email)) GlobalTriggerHandler.calloutSendEmail(new List<String> { email }, subject, body);
            
            }
            if (!bypass) leadSearch += currentlead.Id + ';';
            
          }
          if (leadSearch != '') System.debug('put ' + leadSearch);
          if (leadSearch != '') CreditLimitController.execute(leadSearch);    
        }

        String leadSearch = '';
        for (Lead currentLead : Trigger.New) 
        {
          if (listLeadId.indexOf(currentLead.Id) != -1) continue;
          Lead oldLead = Trigger.OldMap.get(currentLead.Id);
          if (currentLead.Date_Credit_Limit_Requested_by_Risk__c != null && currentLead.Date_Credit_Limit_Requested_by_Risk__c != oldLead.Date_Credit_Limit_Requested_by_Risk__c) {
            if (currentLead.Decision__c == null || currentLead.Decision__c == oldLead.Decision__c) 
              leadSearch += currentlead.Id + ';';
          }
        }
        if (leadSearch != '') System.debug('get ' + leadSearch);
        if (leadSearch != '') CreditLimitController.mainFuture(leadSearch); 
      }
    }
  }

}