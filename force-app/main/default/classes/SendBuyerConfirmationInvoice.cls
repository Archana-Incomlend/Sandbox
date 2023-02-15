public with sharing class SendBuyerConfirmationInvoice {

    public String addlRecipients {get; set;}
    public invoice_finance_deal__c   objInvoice {get; set;}
    public EmailMessage emailMsg {get; private set;}

    private OrgWideEmailAddress sender = null;

    private static final String SUPPORT_EMAIL_ADDRESS = 'operations@incomlend.com';
    private static final String SUPPORT_NAME = 'INCOMLEND Operations';
    
    Private List<wrapperAttachments> lstAttachments;
    
    Public List<Attachment> lstNewAttachments {get;set;}
    Private Integer intNewAttachments = 5;
    
    Public string strAttachmentId {get;set;}
    
    Public string TemplateId {get;set;}
    public Attachment objNewAttachment {get;set;}
    
    public ApexPages.StandardSetController ssc {get;set;}
    public List<Id> SetId {get;set;}
    public String objectType {get;set;}
    
    public String CallbackUrl {get;set;}
    Public string ListId {get;set;}
    
    Public string ToEmailAddress = '';
    Public List<invoice_finance_deal__c> lstInvoice;
    
    public ListCollection Paging {get;set;}
    Public set<Id> setBuyers {get;set;}
    Public set<Id> setSuppliers {get;set;}
    
    Public Decimal decTotalRebitAmount {get;set;}
    Public Decimal decTotalFaceValue {get;set;}
    Public string GoodsAndServices {get;set;}
    
    public SendBuyerConfirmationInvoice(ApexPages.StandardController controller) {
        lstAttachments = new List<wrapperAttachments>();
        strAttachmentId = '';
        String strNoOfAttachments = System.Label.No_Of_Attachments_on_Buyer_Confirmation;
        if(strNoOfAttachments != null && strNoOfAttachments != ''){
            intNewAttachments = Integer.ValueOf(strNoOfAttachments);
        }
        
        decTotalRebitAmount = 0.00;
        decTotalFaceValue = 0.00;
        GoodsAndServices = '';
        objNewAttachment = new Attachment();
        lstNewAttachments = new List<Attachment> ();
        for(Integer IntI = 0; IntI < intNewAttachments; IntI++){
            Attachment objAttachment = new Attachment();
            lstNewAttachments.add(objAttachment);
        }        
        objInvoice = (invoice_finance_deal__c)controller.getRecord();
        system.debug('********* objInvoice == '+objInvoice);
        ListId = objInvoice.Id;
        SetId = new List<Id> { objInvoice.Id }; 
        lstInvoice = new List<invoice_finance_deal__c>(); 
        lstInvoice = [Select id, Buyer_Name__c, buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Goods_and_Services_new__c , Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c where Id IN: SetId limit 1];
        if(lstInvoice.size() > 0){
            objInvoice = lstInvoice[0];
            
            for(invoice_finance_deal__c objInv : lstInvoice){
                if(objInv.Total_Rebate_Amount__c != null){
                    decTotalRebitAmount += objInv.Total_Rebate_Amount__c;
                }
                if(objInv.Real_Face_Value__c != null){
                    decTotalFaceValue += objInv.Real_Face_Value__c;
                }
                if(objInv.Goods_Services_description__c != null && GoodsAndServices == ''){
                    GoodsAndServices = objInv.Goods_Services_description__c;
                }else if(objInv.Goods_Services_description__c != null && GoodsAndServices.contains(objInv.Goods_Services_description__c) == false){
                    GoodsAndServices = ',' + objInv.Goods_Services_description__c;
                }
            }
            
            if(decTotalFaceValue > 0 && decTotalRebitAmount > 0){
                decTotalFaceValue = decTotalFaceValue - decTotalRebitAmount;
            }
            
        }    
        ToEmailAddress = objInvoice.buyer_Primary_Contact_Email__c;
        // create our EmailMessage 
        emailMsg = new EmailMessage();
        CallbackUrl = '/'+objInvoice.Id;
        // get our org-wide email address to set from/sender field
        sender = [select Id from OrgWideEmailAddress where DisplayName = :SUPPORT_NAME];
        Paging = new ListCollection();
        Paging.PageSize = 10;
        Paging.allAttachments = getAttachments();
    }
    
    
   public SendBuyerConfirmationInvoice(ApexPages.StandardSetController listcontroller) {
        lstAttachments = new List<wrapperAttachments>();
        strAttachmentId = '';
        String strNoOfAttachments = System.Label.No_Of_Attachments_on_Buyer_Confirmation;
        if(strNoOfAttachments != null && strNoOfAttachments != ''){
            intNewAttachments = Integer.ValueOf(strNoOfAttachments);
        }
        objNewAttachment = new Attachment();
        lstNewAttachments = new List<Attachment> ();
        for(Integer IntI = 0; IntI < intNewAttachments; IntI++){
            Attachment objAttachment = new Attachment();
            lstNewAttachments.add(objAttachment);
        }
        
        decTotalRebitAmount = 0.00;
        decTotalFaceValue = 0.00;
        GoodsAndServices = '';
        
        ssc = listcontroller;

        objectType = '' + listcontroller.getRecord().getSObjectType();
        CallbackUrl = listcontroller.getRecord().getSObjectType().getDescribe().getKeyPrefix();
        CallbackUrl = GlobalTriggerHandler.getBaseUrl() + '/' + CallbackUrl + '?fcf=' + listcontroller.getFilterId().substring(0,15);
        SetId = new List<Id>();
        system.debug('******listcontroller.getSelected().size()  == '+listcontroller.getSelected().size() );
        if (listcontroller.getSelected().size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No record selected, Please select atleast one Invoice '));   
        } else {
            ListId = getRecordList(listcontroller, false, SetId);
            system.debug('******SetId == '+SetId);
            lstInvoice = new List<invoice_finance_deal__c>();
            lstInvoice = [Select id, Buyer_Name__c, Supplier_name__c , buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Goods_and_Services_new__c , Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c where Id IN: SetId];
            
            setBuyers = new set<Id>();
            setSuppliers = new set<Id>();
            
            for(invoice_finance_deal__c objInv: lstInvoice){
                setBuyers.add(objInv.Buyer_Name__c);
                setSuppliers.add(objInv.Supplier_name__c);
                if(objInv.Total_Rebate_Amount__c != null){
                    decTotalRebitAmount += objInv.Total_Rebate_Amount__c;
                }
                if(objInv.Real_Face_Value__c != null){
                    decTotalFaceValue += objInv.Real_Face_Value__c;
                }
                if(objInv.Goods_and_Services_new__c != null && GoodsAndServices == ''){
                    GoodsAndServices = objInv.Goods_Services_description__c;
                }else if(objInv.Goods_Services_description__c != null && GoodsAndServices.contains(objInv.Goods_Services_description__c) == false){
                    GoodsAndServices = ',' + objInv.Goods_Services_description__c;
                }
            }
            
            if(decTotalFaceValue > 0 && decTotalRebitAmount > 0){
                decTotalFaceValue = decTotalFaceValue - decTotalRebitAmount;
            }
            
            if(setBuyers.size() > 1 || setSuppliers.size() > 1){
                ListId = '';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Invoices from same supplier and Buyer.'));   
            }
            
            if(lstInvoice.size() > 0){
                objInvoice = lstInvoice[0];
            }
            ToEmailAddress = objInvoice.buyer_Primary_Contact_Email__c;
            system.debug('***** ListId == '+ ListId);
            // create our EmailMessage 
            emailMsg = new EmailMessage();
            // get our org-wide email address to set from/sender field
            sender = [select Id from OrgWideEmailAddress where DisplayName = :SUPPORT_NAME];
            Paging = new ListCollection();
            Paging.PageSize = 10;
            Paging.allAttachments = getAttachments();
        }
        
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
    
    public pagereference GenerateEmailContent(){
        String strurl = ApexPages.currentPage().getUrl();

        strurl = strurl.split('apex/')[1];
        System.debug('************ strurl ==' +strurl);
        if(strurl.contains('SelectTemplateForSingleBC')){
            return Page.SendBuyerConfirmationSingleInvoice;
        }else{
            return Page.SendBuyerConfirmationInvoice;
        }
    }
    
    Public List<Selectoption> getAllEmailTemplates(){
        List<Selectoption> lstTemplate = new List<selectoption>();
        lstTemplate.add(new selectOption('', '- None -'));
        for(EmailTemplate objEmailTemplate :[select Id, Body, Name, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where EmailTemplate.Folder.Name = 'Incomlend emails' and Name LIKE '%Buyer - 2 - Incomlend: Supplier invoice acknowledgement%']){
            lstTemplate.add(new selectoption(objEmailTemplate.id,objEmailTemplate.name));
        }
        return lstTemplate;
    }
    // send email message per the attributes specified by user.
    public PageReference send() {
        try {
        
            // now create our SingleEmailMessage to send out.
            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();

            // concatenate all Bcc Addresses
            if (emailMsg.BccAddress != null && emailMsg.BccAddress != '') {
                singleEmailMsg.setBccAddresses(emailMsg.BccAddress.split(';'));
            }

            // concatenate all CC Addresses
            if (emailMsg.CcAddress != null && emailMsg.CcAddress != '') {
                singleEmailMsg.setCcAddresses(emailMsg.CcAddress.split(';'));
            }
            singleEmailMsg.setOrgWideEmailAddressId(sender.Id); 
            singleEmailMsg.setWhatId(objInvoice.Id);
            singleEmailMsg.setSubject(emailMsg.Subject);
            singleEmailMsg.setHTMLBody(emailMsg.TextBody);
            singleEmailMsg.setTargetObjectId(objInvoice.Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c);
            singleEmailMsg.setTreatTargetObjectAsRecipient(false);
            singleEmailMsg.setSaveAsActivity(true);
            // now add additional recipients
            String[] addlToAddresses = null;
            if (addlRecipients != null && addlRecipients != '') {
                addlToAddresses = addlRecipients.split(';');
            }
            // now lets add any additional recipients to our list of recipients.
            List<String> lstToAddresses = null;
            if (addlToAddresses != null) {
                // now append these to our main recipient.
                lstToAddresses = new List<String>(addlToAddresses);
            } else {
                lstToAddresses = new List<String>();
            }
            lstToAddresses.add(emailMsg.ToAddress);
            singleEmailMsg.setToAddresses(lstToAddresses); 

            // now we need to reset the ToAddress for our EmailMessage.
            emailMsg.ToAddress += (addlRecipients != null ? ';' + addlRecipients : '');
            
            List<Messaging.EmailFileAttachment> lstEmailAlltachments = new List<Messaging.EmailFileAttachment>();
            if(lstAttachments.size() > 0){
                for(wrapperAttachments objInvoiceAtt : lstAttachments){
                    Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                    emailAttachment.setBody(objInvoiceAtt.objAttachment.Body);
                    emailAttachment.setFileName(objInvoiceAtt.objAttachment.Name);
                    lstEmailAlltachments.add(emailAttachment);
                   
                }
            }
            // now attach file to email if there is one. Have to check the Body as Attachment
            // itself will never be null as it is always created first time it is accessed.
            system.debug('********** lstNewAttachments=====' + lstNewAttachments);
            system.debug('********** objNewAttachment=====' + objNewAttachment);
            for(Attachment objNewAttachment : lstNewAttachments){
                if(objNewAttachment.Body != null){
                    Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                    emailAttachment.setBody(objNewAttachment.Body);
                    emailAttachment.setFileName(objNewAttachment.Name);
                    lstEmailAlltachments.add(emailAttachment);
                }
            }
            if(lstEmailAlltachments.size() > 0){
                singleEmailMsg.setFileAttachments(lstEmailAlltachments);
            }

            List<Messaging.SendEmailResult> results =  Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {singleEmailMsg});

            // now parse  our results
            // on success, return to calling page - Invoice view.
            if (results[0].success) {
                // now insert EmailMessage into database so it is associated with Invoice.
                insert emailMsg;
                // and insert attachment into database as well, associating it with our emailMessage
                List<Attachment> lstAttachmentToInsert = new List<Attachment>();
                for(Attachment objNewAttachment : lstNewAttachments){
                    if (objNewAttachment.Body != null) {
                        objNewAttachment.parentId = emailMsg.Id;
                        lstAttachmentToInsert.add(objNewAttachment);
                        
                    }
                }
                if(lstAttachmentToInsert.size() > 0){
                    insert lstAttachmentToInsert;
                }
                for(invoice_finance_deal__c objInv: lstInvoice){
                    objInv.Buyer_Confirmation_Status__c = 'Asked waiting for response';
                    objInv.Buyer_acknowledgment_date__c = Datetime.valueOf(System.Now().format('yyyy-MM-dd HH:mm:ss'));
                }
                
                update lstInvoice;
                
                PageReference pgRef = new PageReference(CallbackUrl);
                pgRef.setRedirect(true);
                return pgRef;
            } else {
                // on failure, display error message on existing page so return null to return there.
                String errorMsg = 'Error sending Email Message. Details = ' + results.get(0).getErrors()[0].getMessage();
                System.debug('==========> ' + errorMsg);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                return null;
            }
        }
        catch (Exception e) {
            // on failure, display error message on existing page so return null to return there.
            String errorMsg = 'Exception thrown trying to send Email Message. Details = ' + e;
            System.debug('==========> ' + errorMsg);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            return null;
        }
    }
    
      
    private wrapperAttachments[] getAttachments() {
        try {
            List<Attachment> lstInvoiceAttachments = [Select Id, Body, Name, ParentId, Parent.Name from Attachment where ParentId IN: SetId order by Parent.Name limit 40];
        
            if(lstInvoiceAttachments.size() > 0){
                for(Attachment objInvoiceAtt : lstInvoiceAttachments){
                    wrapperAttachments objWrapperAttachment = new wrapperAttachments();
                    objWrapperAttachment.objAttachment = objInvoiceAtt;
                    lstAttachments.add(objWrapperAttachment);
                }
            }               
            return lstAttachments;
        }
        catch (QueryException e) {
            ApexPages.addMessages(e);   
            return null;
        }
    }
      
    
    
    // cancel creation of emailMessage. 
    public PageReference cancel() {
        // no need to do anything - just return to calling page.
        PageReference pgRef = new PageReference(CallbackUrl);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    Public PageReference DeleteAttachments(){
        System.debug('**** strAttachmentId: '+strAttachmentId);
        for (Integer i = (lstAttachments.size()-1) ; i>= 0 ; i--){
            
            if(lstAttachments[i].objAttachment.Id == strAttachmentId){
                lstAttachments.remove(i);
            }
        } 
        
        
        return null;
    }
    
   
    
    // populate our Email Message Template from the database, filling merge fields with
    // values from our Invoice object. Then store resulting template in EmailMessage for
    // display to end-user who is free to edit it before sending.
    public PageReference populateTemplate() {
        
        EmailTemplate emailTemplate = [select Body, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName='Buyer_2_Incomlend_invoice_acknowledgement' limit 1];

        // we need to perform the merge for this email template before displaying to end-user.
        if(TemplateId != '' && TemplateId != null){
            emailTemplate = [select Body, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where Id =: TemplateId limit 1];      
        }
        
        // construct dummy email to have Salesforce merge BrandTemplate (HTML letterhead) with our email
        Messaging.SingleEmailMessage dummyEmailMsg = new Messaging.SingleEmailMessage();
        if(EmailContent() == '' ){
            dummyEmailMsg.setTemplateId(emailTemplate.Id);
        }else{
            dummyEmailMsg.SetSubject( 'Incomlend: '+ objinvoice.supplier_text__c+' invoice(s) acknowledgement');
            dummyEmailMsg.SetHTMLBody(EmailContent());
        }
        
        // This ensures that sending this email is not saved as an activity for the targetObjectId. 
        dummyEmailMsg.setSaveAsActivity(false);

        // send dummy email to populate HTML letterhead in our EmailMessage object's html body.
        String[] toAddresses = new String[]{ToEmailAddress};
        dummyEmailMsg.setToAddresses(toAddresses);
        dummyEmailMsg.setReplyTo(SUPPORT_EMAIL_ADDRESS); 
        
        // now send email and then roll it back but invocation of sendEmail() 
        // means merge of letterhead & body is done

        // TargetObject is User. This tells the emailMsg to use the email message
        // associated with our dummy User. This is necessary so we can populate our
        // email message body & subject with merge fields from template
        Savepoint sp = Database.setSavepoint();

        Account dummyAcct = new Account(Name='dummy account');
        insert dummyAcct;
        
        Contact dummyContact = new Contact(AccountId=dummyAcct.Id);
        dummyContact.FirstName = 'First';
        dummyContact.LastName = 'Last';
        dummyContact.Email = 'nobody@nowhere.com';
        insert dummyContact;

        dummyEmailMsg.setTargetObjectId(dummyContact.Id);
        dummyEmailMsg.setWhatId(objInvoice.Id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {dummyEmailMsg});
        // now rollback our changes.
        Database.rollback(sp);

        // now populate our fields with values from SingleEmailMessage.
        emailMsg.BccAddress  = UserInfo.getUserEmail();
        emailMsg.Subject     = dummyEmailMsg.getSubject();
        emailMsg.TextBody    = dummyEmailMsg.getHTMLBody();
        system.debug('******** HTML == '+dummyEmailMsg.getHTMLBody());
        emailMsg.ToAddress   = dummyEmailMsg.getToAddresses().get(0);
        emailMsg.FromAddress = SUPPORT_EMAIL_ADDRESS; 
        emailMsg.CcAddress   = '';
        return null;
    }
    
    
    Public string EmailContent(){
        string strEmailContent = '';
        system.debug('************* TemplateId == '+TemplateId);
        if(TemplateId != '' && TemplateId != null){
            EmailTemplate ObjemailTemplate = [select Body, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where Id =: TemplateId limit 1];      
            system.debug('************* ObjemailTemplate == '+ObjemailTemplate);
            if(ObjemailTemplate.DeveloperName == 'Buyer_2_Incomlend_invoice_acknowledgement'){
                strEmailContent = Buyer_2_Incomlend_invoice_acknowledgement();
            } else if(ObjemailTemplate.DeveloperName == 'Buyer_2_Incomlend_invoice_acknowledgement_BLUE_PLANET'){
                strEmailContent = Buyer_2_Incomlend_invoice_acknowledgement_BLUE_PLANET();
            } else if(ObjemailTemplate.DeveloperName == 'Buyer_2_Incomlend_Supplier_invoice_acknowledgement_GUILAI_TELEX_BL'){
                strEmailContent = Buyer_2_Incomlend_Supplier_invoice_acknowledgement_GULAI_TELEX_BL();
            } else if(ObjemailTemplate.DeveloperName ==  'Buyer_2_Incomlend_invoice_acknowledgement_ABCOM'){
                strEmailContent = Buyer_2_Incomlend_invoice_acknowledgement_ABCOM();
            } else if(ObjemailTemplate.DeveloperName ==  'Buyer_2_Incomlend_invoice_acknowledgement_fortunex'){
                strEmailContent = Buyer_2_Incomlend_invoice_acknowledgement_fortunex();
            } else if(ObjemailTemplate.DeveloperName ==  'Buyer_2_Incomlend_Supplier_invoice_acknowledgement_Safeflex'){
                strEmailContent = Buyer_2_Incomlend_Supplier_invoice_acknowledgement_Safeflex();
            } else if(ObjemailTemplate.DeveloperName ==  'Buyer_2_Incomlend_invoice_acknowledgement_OBSOLETE1'){
                strEmailContent = Buyer_2_Incomlend_invoice_acknowledgement_OBSOLETE1();
            }else if(ObjemailTemplate.DeveloperName ==  'Buyer_2_Incomlend_invoice_acknowledgement_OBSOLETE2'){
                strEmailContent = Buyer_2_Incomlend_invoice_acknowledgement_OBSOLETE2();
            }else if(ObjemailTemplate.DeveloperName ==  'Buyer_2_Incomlend_Supplier_invoice_acknowledgement_AISHI_TELEX_BL'){
                strEmailContent = Buyer_2_Incomlend_Supplier_invoice_acknowledgement_AISHI_TELEX_BL();
            }
           
        }
        system.debug('************* strEmailContent == '+strEmailContent);
        return strEmailContent;
    }
    
    Public string Buyer_2_Incomlend_invoice_acknowledgement(){
        String strEmailContent = '';
        strEmailContent += '<html>';
        strEmailContent += '<head>';
        strEmailContent += '<style type="text/css">';
        strEmailContent += 'div.content {';
        strEmailContent += 'padding-top: 50px;';
        strEmailContent += 'font-family: sans-serif; ';
        strEmailContent += 'font-size: 10pt;';
        strEmailContent += '}';
        
        strEmailContent += ' </style>';
        
        
        strEmailContent += '</head>';
        
        strEmailContent += '<body>';
        strEmailContent += '<div style="font-family: Calibri">';
        strEmailContent += '<center><p><img src="' + Label.Incomlend_Logo_URL  +' "/> </p></center>';
        strEmailContent += '<div class="content">';
        strEmailContent += '<p>';
        strEmailContent += 'Dear ' + objInvoice.buyer_primary_contact__c+ ',';
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += 'As you may be aware, we have received a request from '+ objInvoice.supplier_text__c +' to assume responsibility for the sale and assignment of the following invoice(s) for '+ GoodsAndServices;
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += '<table style="border-style: solid;border-collapse: collapse; margin-left: 6.16998pt" cellspacing="0" width="95%">';
        strEmailContent += '<tr>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Invoice';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;"> ';
        strEmailContent += 'Issued';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Purchase Order (PO)';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Due Date';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Total amount';
        strEmailContent += '</td>';
        strEmailContent += '</tr>';
        for(Invoice_Finance_Deal__c objInv:  lstInvoice){
            strEmailContent += '<tr>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent +=  objInv.supplier_invoice_reference_number__c;
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Invoice_date__c.format();
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.buyer_purchase_order_reference__c;
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Due_Date__c.format();
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Real_Face_Value__c +' ' + objInv.CCY__c;
            strEmailContent += '</td>';
            
            strEmailContent += '</tr>';
        }
        strEmailContent += '</table>';
        strEmailContent += '</p>';
       
        strEmailContent += '<p>';
        strEmailContent += 'In order to finish verification of the invoice(s), could you please confirm the following information:';
        
        strEmailContent += '<ol>';
        strEmailContent += '<li>';
        strEmailContent += 'The down payment of '+ objInvoice.Total_Rebate_Amount__c+' has been made towards this invoice and the amount of '+ decTotalFaceValue +' remains outstanding and payable on the invoice as an absolute and whole debt.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were made by '+objInvoice.Buyer_text__c+'.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The goods were received / shipped according to the mentioned above Purchase orders and Invoices.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were absent of any credit/debit notes applicable to this/these invoice(s). ';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Any set-off rights you may have against '+objInvoice.supplier_text__c+' shall be terminated and you shall not seek to exercise any such rights in connection with the repayment of this above named invoice.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'To the best of your knowledge, the said invoice(s) are not assigned subject to any rights that any third party may have, including any lien, charge or pledge. In particular, the said invoice(s) have not been the subject of any financing to be provided by any third party company.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'By confirming the contents of this email, please note that you also confirm and accept the terms and conditions set out in the relevant invoice(s).';
        strEmailContent += '</li>';
        strEmailContent += '</ol>';
        
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += 'A simple “Yes, confirmed“ reply to this email will be sufficient.';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Could you please revert to us by today?    <br/> ';
        strEmailContent += 'Please be advised that we will duly notify you upon each assignment of Accounts Receivable to Incomlend. These Accounts Receivable must be repaid directly to Incomlend Pte. Ltd at ';
        strEmailContent += '<br/>';
        
        
        strEmailContent += objInvoice.Bank_Information_for_Payment__c ;
        strEmailContent += '<br/>';
        strEmailContent += '<br/>';
        
        strEmailContent += 'Should you have any questions please feel free to contact us.';
        strEmailContent += '<br/><br/>';
        
        
        strEmailContent += 'Regards,';
        strEmailContent += '<br/>';
        strEmailContent += 'Incomlend Team';
        
        strEmailContent += '</p>';
        strEmailContent += '</div>';
        strEmailContent += '</div>';
        strEmailContent += '</body>';
        
        strEmailContent += '</html>';
        return strEmailContent;
    }
    
    Public string Buyer_2_Incomlend_invoice_acknowledgement_BLUE_PLANET(){
        String strEmailContent = '';
        strEmailContent += '<html>';
        strEmailContent += '<head>';
        strEmailContent += '<style type="text/css">';
        strEmailContent += 'div.content {';
        strEmailContent += 'padding-top: 50px;';
        strEmailContent += 'font-family: sans-serif; ';
        strEmailContent += 'font-size: 10pt;';
        strEmailContent += '}';
        
        strEmailContent += ' </style>';
        
        
        strEmailContent += '</head>';
        
        strEmailContent += '<body>';
        strEmailContent += '<div style="font-family: Calibri">';
        strEmailContent += '<center><p><img src="' + Label.Incomlend_Logo_URL  +' "/> </p></center>';
        strEmailContent += '<div class="content">';
        strEmailContent += '<p>';
        strEmailContent += 'Dear ' + objInvoice.buyer_primary_contact__c+ ',';
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += 'As you may be aware, we have received a request from '+ objInvoice.supplier_text__c +' to assume responsibility for the sale and assignment of the following invoice(s) for '+ GoodsAndServices;
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += '<table style="border-style: solid;border-collapse: collapse; margin-left: 6.16998pt" cellspacing="0" width="95%">';
        strEmailContent += '<tr>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Invoice';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;"> ';
        strEmailContent += 'Issued';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Purchase Order (PO)';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Due Date';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Total amount';
        strEmailContent += '</td>';
        strEmailContent += '</tr>';
        for(Invoice_Finance_Deal__c objInv:  lstInvoice){
            strEmailContent += '<tr>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent +=  objInv.supplier_invoice_reference_number__c;
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Invoice_date__c.format();
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.buyer_purchase_order_reference__c;
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Due_Date__c.format();
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Real_Face_Value__c +' ' + objInv.CCY__c;
            strEmailContent += '</td>';
            
            strEmailContent += '</tr>';
        }
        strEmailContent += '</table>';
        strEmailContent += '</p>';
       
        strEmailContent += '<p>';
        strEmailContent += 'In order to finish verification of the invoice(s), could you please confirm the following information:';
        
        strEmailContent += '<ol>';
        strEmailContent += '<li>';
        strEmailContent += 'The down payment of '+ decTotalRebitAmount +' has been made towards this invoice and the amount of '+ decTotalFaceValue +' remains outstanding and payable on the invoice as an absolute and whole debt.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were made by '+objInvoice.Buyer_text__c+'.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The goods were received / shipped according to the mentioned above Purchase orders and Invoices.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were absent of any credit/debit notes applicable to this/these invoice(s). ';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Any set-off rights you may have against '+objInvoice.supplier_text__c+' shall be terminated and you shall not seek to exercise any such rights in connection with the repayment of this above named invoice.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'To the best of your knowledge, the said invoice(s) are not assigned subject to any rights that any third party may have, including any lien, charge or pledge. In particular, the said invoice(s) have not been the subject of any financing to be provided by any third party company.';
        strEmailContent += '</li>';
        strEmailContent += '</ol>';
        
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += 'A simple “Yes, confirmed“ reply to this email will be sufficient.';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Could you please revert to us by today?    <br/> ';
        strEmailContent += 'Please be advised that we will duly notify you upon each assignment of Accounts Receivable to Incomlend. These Accounts Receivable must be repaid directly to Incomlend Pte. Ltd at ';
        strEmailContent += '<br/>';
        
        
        strEmailContent += objInvoice.Bank_Information_for_Payment__c ;
        strEmailContent += '<br/>';
        strEmailContent += '<br/>';
        
        strEmailContent += 'Should you have any questions please feel free to contact us.';
        strEmailContent += '<br/><br/>';
        
        
        strEmailContent += 'Regards,';
        strEmailContent += '<br/>';
        strEmailContent += 'Incomlend Team';
        
        strEmailContent += '</p>';
        strEmailContent += '</div>';
        strEmailContent += '</div>';
        strEmailContent += '</body>';
        
        strEmailContent += '</html>';
        return strEmailContent;
    }
    
    Public string Buyer_2_Incomlend_Supplier_invoice_acknowledgement_GULAI_TELEX_BL(){
        String strEmailContent = '';
        strEmailContent += '<html>';
        strEmailContent += '<head>';
        strEmailContent += '<style type="text/css">';
        strEmailContent += 'div.content {';
        strEmailContent += 'padding-top: 50px;';
        strEmailContent += 'font-family: sans-serif; ';
        strEmailContent += 'font-size: 10pt;';
        strEmailContent += '}';
        
        strEmailContent += ' </style>';
        
        
        strEmailContent += '</head>';
        
        strEmailContent += '<body>';
        strEmailContent += '<div style="font-family: Calibri">';
        strEmailContent += '<center><p><img src="' + Label.Incomlend_Logo_URL  +' "/> </p></center>';
        strEmailContent += '<div class="content">';
        strEmailContent += '<p>';
        strEmailContent += 'Dear ' + objInvoice.buyer_primary_contact__c+ ',';
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += 'As you may be aware, we have received a request from '+ objInvoice.supplier_text__c +' to assume responsibility for the sale and assignment of the following invoice(s) for '+ GoodsAndServices;
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += '<table style="border-style: solid;border-collapse: collapse; margin-left: 6.16998pt" cellspacing="0" width="95%">';
        strEmailContent += '<tr>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Invoice';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;"> ';
        strEmailContent += 'Issued';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Purchase Order (PO)';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Due Date';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Total amount';
        strEmailContent += '</td>';
        strEmailContent += '</tr>';
        for(Invoice_Finance_Deal__c objInv:  lstInvoice){
            strEmailContent += '<tr>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent +=  objInv.supplier_invoice_reference_number__c;
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Invoice_date__c.format();
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.buyer_purchase_order_reference__c;
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Due_Date__c.format();
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Real_Face_Value__c +' ' + objInv.CCY__c;
            strEmailContent += '</td>';
            
            strEmailContent += '</tr>';
        }
        strEmailContent += '</table>';
        strEmailContent += '</p>';
       
        strEmailContent += '<p>';
        strEmailContent += 'In order to finish verification of the invoice(s), could you please confirm the following information:';
        
        strEmailContent += '<ol>';
        strEmailContent += '<li>';
        strEmailContent += 'The down payment of '+ decTotalRebitAmount +' has been made towards this invoice and the amount of '+ decTotalFaceValue +' remains outstanding and payable on the invoice as an absolute and whole debt.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were made by '+objInvoice.Buyer_text__c+'.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The goods were received / shipped according to the mentioned above Purchase orders and Invoices.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were absent of any credit/debit notes applicable to this/these invoice(s). ';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Any set-off rights you may have against '+objInvoice.supplier_text__c+' shall be terminated and you shall not seek to exercise any such rights in connection with the repayment of this above named invoice.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'To the best of your knowledge, the said invoice(s) are not assigned subject to any rights that any third party may have, including any lien, charge or pledge. In particular, the said invoice(s) have not been the subject of any financing to be provided by any third party company.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'By confirming the contents of this email, please note that you also confirm and accept the terms and conditions set out in the relevant invoice(s).';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Additionally, we have been informed by '+objInvoice.supplier_text__c+' that a Telex Release or Surrendered BL has been requested for the goods specified in the above invoices. By confirming the details in this email, you confirm that you, on behalf of '+objInvoice.Buyer_text__c +', acknowledge and accept the risks incumbent in a Telex Release or Surrendered BL, including but not limited to the possibility of fraud, and agree to pay the relevant account receivables to Incomlend Pte Ltd upon the payment due date.';
        strEmailContent += '</li>';
        strEmailContent += '</ol>';
        
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += 'A simple “Yes, confirmed“ reply to this email will be sufficient.';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Could you please revert to us by today?    <br/> ';
        strEmailContent += 'Please be advised that we will duly notify you upon each assignment of Accounts Receivable to Incomlend. These Accounts Receivable must be repaid directly to Incomlend Pte. Ltd at ';
        strEmailContent += '<br/>';
        
        
        strEmailContent += objInvoice.Bank_Information_for_Payment__c ;
        strEmailContent += '<br/>';
        strEmailContent += '<br/>';
        
        strEmailContent += 'Should you have any questions please feel free to contact us.';
        strEmailContent += '<br/><br/>';
        
        
        strEmailContent += 'Regards,';
        strEmailContent += '<br/>';
        strEmailContent += 'Incomlend Team';
        
        strEmailContent += '</p>';
        strEmailContent += '</div>';
        strEmailContent += '</div>';
        strEmailContent += '</body>';
        
        strEmailContent += '</html>';
        return strEmailContent;
    }
    
    Public string Buyer_2_Incomlend_invoice_acknowledgement_ABCOM(){
        String strEmailContent = '';
        strEmailContent += '<html>';
        strEmailContent += '<head>';
        strEmailContent += '<style type="text/css">';
        strEmailContent += 'div.content {';
        strEmailContent += 'padding-top: 50px;';
        strEmailContent += 'font-family: sans-serif; ';
        strEmailContent += 'font-size: 10pt;';
        strEmailContent += '}';
        
        strEmailContent += ' </style>';
        
        
        strEmailContent += '</head>';
        
        strEmailContent += '<body>';
        strEmailContent += '<div style="font-family: Calibri">';
        strEmailContent += '<center><p><img src="' + Label.Incomlend_Logo_URL  +' "/> </p></center>';
        strEmailContent += '<div class="content">';
        strEmailContent += '<p>';
        strEmailContent += 'Dear ' + objInvoice.buyer_primary_contact__c+ ',';
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += 'As you may be aware, we have received a request from '+ objInvoice.supplier_text__c +' to assume responsibility for the sale and assignment of the following invoice(s) for '+ GoodsAndServices;
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += '<table style="border-style: solid;border-collapse: collapse; margin-left: 6.16998pt" cellspacing="0" width="95%">';
        strEmailContent += '<tr>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Invoice';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;"> ';
        strEmailContent += 'Issued';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Purchase Order (PO)';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Due Date';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Total amount';
        strEmailContent += '</td>';
        strEmailContent += '</tr>';
        for(Invoice_Finance_Deal__c objInv:  lstInvoice){
            strEmailContent += '<tr>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent +=  objInv.supplier_invoice_reference_number__c;
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Invoice_date__c.format();
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.buyer_purchase_order_reference__c;
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Due_Date__c.format();
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Real_Face_Value__c +' ' + objInv.CCY__c;
            strEmailContent += '</td>';
            
            strEmailContent += '</tr>';
        }
        strEmailContent += '</table>';
        strEmailContent += '</p>';
       
        strEmailContent += '<p>';
        strEmailContent += 'In order to finish verification of the invoice(s), could you please confirm the following information:';
        
        strEmailContent += '<ol>';
        strEmailContent += '<li>';
        strEmailContent += 'The down payment of '+ decTotalRebitAmount +' has been made towards this invoice and the amount of '+ decTotalFaceValue +' remains outstanding and payable on the invoice as an absolute and whole debt.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were made by '+objInvoice.Buyer_text__c+'.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The goods were received / shipped according to the mentioned above Purchase orders and Invoices.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were absent of any credit/debit notes applicable to this/these invoice(s). ';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Any set-off rights you may have against '+objInvoice.supplier_text__c+' shall be terminated and you shall not seek to exercise any such rights in connection with the repayment of this above named invoice.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'To the best of your knowledge, the said invoice(s) are not assigned subject to any rights that any third party may have, including any lien, charge or pledge. In particular, the said invoice(s) have not been the subject of any financing to be provided by any third party company.';
        strEmailContent += '</li>';
        /*strEmailContent += '<li>';
        strEmailContent += 'By confirming the contents of this email, please note that you also confirm and accept the terms and conditions set out in the relevant invoice(s).';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Additionally, we have been informed by '+objInvoice.supplier_text__c+' that a Telex Release or Surrendered BL has been requested for the goods specified in the above invoices. By confirming the details in this email, you confirm that you, on behalf of '+objInvoice.Buyer_text__c +', acknowledge and accept the risks incumbent in a Telex Release or Surrendered BL, including but not limited to the possibility of fraud, and agree to pay the relevant account receivables to Incomlend Pte Ltd upon the payment due date.';
        strEmailContent += '</li>';*/
        strEmailContent += '</ol>';
        
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += 'A simple “Yes, confirmed“ reply to this email will be sufficient.';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Could you please revert to us by today?    <br/> ';
        strEmailContent += 'Please be advised that we will duly notify you upon each assignment of Accounts Receivable to Incomlend. These Accounts Receivable must be repaid directly to Incomlend Pte. Ltd at ';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Account Holder Name-Abcom Pte Ltd <br/>';

        strEmailContent += 'IBAN-GB37TCCL04140455526973 <br/>';
        
        strEmailContent += 'BIC-TCCLGB3L <br/>';
        
        strEmailContent += 'Bank Name-The Currency Cloud Limited <br/>';
        
        strEmailContent += 'Bank Address-12 Steward Street, The Steward Building, London, E1 6FQ, <br/>';
        
        strEmailContent += 'GB Bank Country GB <br/>';
        strEmailContent += '<br/>';
        strEmailContent += '<br/>';
        
        strEmailContent += 'Should you have any questions please feel free to contact us.';
        strEmailContent += '<br/><br/>';
        
        
        strEmailContent += 'Regards,';
        strEmailContent += '<br/>';
        strEmailContent += 'Incomlend Team';
        
        strEmailContent += '</p>';
        strEmailContent += '</div>';
        strEmailContent += '</div>';
        strEmailContent += '</body>';
        
        strEmailContent += '</html>';
        return strEmailContent;
    }
    
    Public string Buyer_2_Incomlend_invoice_acknowledgement_fortunex(){
        String strEmailContent = '';
        strEmailContent += '<html>';
        strEmailContent += '<head>';
        strEmailContent += '<style type="text/css">';
        strEmailContent += 'div.content {';
        strEmailContent += 'padding-top: 50px;';
        strEmailContent += 'font-family: sans-serif; ';
        strEmailContent += 'font-size: 10pt;';
        strEmailContent += '}';
        
        strEmailContent += ' </style>';
        
        
        strEmailContent += '</head>';
        
        strEmailContent += '<body>';
        strEmailContent += '<div style="font-family: Calibri">';
        strEmailContent += '<center><p><img src="' + Label.Incomlend_Logo_URL  +' "/> </p></center>';
        strEmailContent += '<div class="content">';
        strEmailContent += '<p>';
        strEmailContent += 'Dear ' + objInvoice.buyer_primary_contact__c+ ',';
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += 'As you may be aware, we have received a request from '+ objInvoice.supplier_text__c +' to assume responsibility for the sale and assignment of the following invoice(s) for '+ GoodsAndServices;
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += '<table style="border-style: solid;border-collapse: collapse; margin-left: 6.16998pt" cellspacing="0" width="95%">';
        strEmailContent += '<tr>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Invoice';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;"> ';
        strEmailContent += 'Issued';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Purchase Order (PO)';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Due Date';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Total amount';
        strEmailContent += '</td>';
        strEmailContent += '</tr>';
        for(Invoice_Finance_Deal__c objInv:  lstInvoice){
            strEmailContent += '<tr>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent +=  objInv.supplier_invoice_reference_number__c;
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Invoice_date__c.format();
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.buyer_purchase_order_reference__c;
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Due_Date__c.format();
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Real_Face_Value__c +' ' + objInv.CCY__c;
            strEmailContent += '</td>';
            
            strEmailContent += '</tr>';
        }
        strEmailContent += '</table>';
        strEmailContent += '</p>';
       
        strEmailContent += '<p>';
        strEmailContent += 'In order to finish verification of the invoice(s), could you please confirm the following information:';
        
        strEmailContent += '<ol>';
        strEmailContent += '<li>';
        strEmailContent += 'The down payment of '+ decTotalRebitAmount +' has been made towards this invoice and the amount of '+ decTotalFaceValue +' remains outstanding and payable on the invoice as an absolute and whole debt.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were made by '+objInvoice.Buyer_text__c+'.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The goods were received / shipped according to the mentioned above Purchase orders and Invoices.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were absent of any credit/debit notes applicable to this/these invoice(s). ';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Any set-off rights you may have against '+objInvoice.supplier_text__c+' shall be terminated and you shall not seek to exercise any such rights in connection with the repayment of this above named invoice.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'To the best of your knowledge, the said invoice(s) are not assigned subject to any rights that any third party may have, including any lien, charge or pledge. In particular, the said invoice(s) have not been the subject of any financing to be provided by any third party company.';
        strEmailContent += '</li>';
        /*strEmailContent += '<li>';
        strEmailContent += 'By confirming the contents of this email, please note that you also confirm and accept the terms and conditions set out in the relevant invoice(s).';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Additionally, we have been informed by '+objInvoice.supplier_text__c+' that a Telex Release or Surrendered BL has been requested for the goods specified in the above invoices. By confirming the details in this email, you confirm that you, on behalf of '+objInvoice.Buyer_text__c +', acknowledge and accept the risks incumbent in a Telex Release or Surrendered BL, including but not limited to the possibility of fraud, and agree to pay the relevant account receivables to Incomlend Pte Ltd upon the payment due date.';
        strEmailContent += '</li>';*/
        strEmailContent += '</ol>';
        
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += 'A simple “Yes, confirmed“ reply to this email will be sufficient.';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Could you please revert to us by today?    <br/> ';
        strEmailContent += 'Please be advised that we will duly notify you upon each assignment of Accounts Receivable to Incomlend. These Accounts Receivable must be repaid directly to Incomlend Pte. Ltd at ';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Bank name: DBS Singapore <br/>';

        strEmailContent += 'Beneficiary name/Account name: ATSL ATO INCOMLEND PTE LTD (BUYER) <br/>';
        
        strEmailContent += 'A/C #: 072-032067-0 <br/>';
        
        strEmailContent += 'SWIFT: DBSSSGSG <br/>';
        
        strEmailContent += 'Currencies: SGD, HKD, EUR, USD <br/>';
        
        strEmailContent += 'Beneficiary address: 8 Cross Street, #23-06, PWC Building, Singapore 048424 <br/>';
        strEmailContent += 'Bank Address: DBS BANK Ltd 12 Marina Boulevard DBS Asia Central Marina Bay Financial Centre Tower 3 Singapore 018982 <br/>';
        
        strEmailContent += '<br/>';
        strEmailContent += '<br/>';
        
        strEmailContent += 'Should you have any questions please feel free to contact us.';
        strEmailContent += '<br/><br/>';
        
        
        strEmailContent += 'Regards,';
        strEmailContent += '<br/>';
        strEmailContent += 'Incomlend Team';
        
        strEmailContent += '</p>';
        strEmailContent += '</div>';
        strEmailContent += '</div>';
        strEmailContent += '</body>';
        
        strEmailContent += '</html>';
        return strEmailContent;
    }

    Public string Buyer_2_Incomlend_Supplier_invoice_acknowledgement_Safeflex(){
        String strEmailContent = '';
        strEmailContent += '<html>';
        strEmailContent += '<head>';
        strEmailContent += '<style type="text/css">';
        strEmailContent += 'div.content {';
        strEmailContent += 'padding-top: 50px;';
        strEmailContent += 'font-family: sans-serif; ';
        strEmailContent += 'font-size: 10pt;';
        strEmailContent += '}';
        
        strEmailContent += ' </style>';
        
        
        strEmailContent += '</head>';
        
        strEmailContent += '<body>';
        strEmailContent += '<div style="font-family: Calibri">';
        strEmailContent += '<center><p><img src="' + Label.Incomlend_Logo_URL  +' "/> </p></center>';
        strEmailContent += '<div class="content">';
        strEmailContent += '<p>';
        strEmailContent += 'Dear ' + objInvoice.buyer_primary_contact__c+ ',';
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += 'As you may be aware, we have received a request from '+ objInvoice.supplier_text__c +' to assume responsibility for the sale and assignment of the following invoice(s) for '+ GoodsAndServices;
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += '<table style="border-style: solid;border-collapse: collapse; margin-left: 6.16998pt" cellspacing="0" width="95%">';
        strEmailContent += '<tr>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Invoice';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;"> ';
        strEmailContent += 'Issued';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Purchase Order (PO)';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Due Date';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Total amount';
        strEmailContent += '</td>';
        strEmailContent += '</tr>';
        for(Invoice_Finance_Deal__c objInv:  lstInvoice){
            strEmailContent += '<tr>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent +=  objInv.supplier_invoice_reference_number__c;
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Invoice_date__c.format();
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.buyer_purchase_order_reference__c;
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Due_Date__c.format();
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Real_Face_Value__c +' ' + objInv.CCY__c;
            strEmailContent += '</td>';
            
            strEmailContent += '</tr>';
        }
        strEmailContent += '</table>';
        strEmailContent += '</p>';
       
        strEmailContent += '<p>';
        strEmailContent += 'In order to finish verification of the invoice(s), could you please confirm the following information:';
        
        strEmailContent += '<ol>';
        strEmailContent += '<li>';
        strEmailContent += 'The down payment of '+ decTotalRebitAmount +' has been made towards this invoice and the amount of '+ decTotalFaceValue +' remains outstanding and payable on the invoice as an absolute and whole debt.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were made by '+objInvoice.Buyer_text__c+'.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The goods were received / shipped according to the mentioned above Purchase orders and Invoices.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were absent of any credit/debit notes applicable to this/these invoice(s). ';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Any set-off rights you may have against '+objInvoice.supplier_text__c+' shall be terminated and you shall not seek to exercise any such rights in connection with the repayment of this above named invoice.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'To the best of your knowledge, the said invoice(s) are not assigned subject to any rights that any third party may have, including any lien, charge or pledge. In particular, the said invoice(s) have not been the subject of any financing to be provided by any third party company.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'By confirming the contents of this email, please note that you also confirm and accept the terms and conditions set out in the relevant invoice(s).';
        strEmailContent += '</li>';
        
        strEmailContent += '</ol>';
        
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += '    ** Please be informed that Safeflex will be seeking to recover from you any late payment charges imposed by us if you make payment afer the contractual due dates **';
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += 'A simple “Yes, confirmed“ reply to this email will be sufficient.';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Could you please revert to us by today?    <br/> ';
        strEmailContent += 'Please be advised that we will duly notify you upon each assignment of Accounts Receivable to Incomlend. These Accounts Receivable must be repaid directly to Incomlend Pte. Ltd at ';
        strEmailContent += '<br/>';
        
        
        strEmailContent += objInvoice.Bank_Information_for_Payment__c;

        
        strEmailContent += '<br/>';
        strEmailContent += '<br/>';
        
        strEmailContent += 'Should you have any questions please feel free to contact us.';
        strEmailContent += '<br/><br/>';
        
        
        strEmailContent += 'Regards,';
        strEmailContent += '<br/>';
        strEmailContent += 'Incomlend Team';
        
        strEmailContent += '</p>';
        strEmailContent += '</div>';
        strEmailContent += '</div>';
        strEmailContent += '</body>';
        
        strEmailContent += '</html>';
        return strEmailContent;
    }
    
    Public string Buyer_2_Incomlend_invoice_acknowledgement_OBSOLETE1(){
        String strEmailContent = '';
        strEmailContent += '<html>';
        strEmailContent += '<head>';
        strEmailContent += '<style type="text/css">';
        strEmailContent += 'div.content {';
        strEmailContent += 'padding-top: 50px;';
        strEmailContent += 'font-family: sans-serif; ';
        strEmailContent += 'font-size: 10pt;';
        strEmailContent += '}';
        
        strEmailContent += ' </style>';
        
        
        strEmailContent += '</head>';
        
        strEmailContent += '<body>';
        strEmailContent += '<div style="font-family: Calibri">';
        strEmailContent += '<center><p><img src="' + Label.Incomlend_Logo_URL  +' "/> </p></center>';
        strEmailContent += '<div class="content">';
        strEmailContent += '<p>';
        strEmailContent += 'Dear ' + objInvoice.buyer_primary_contact__c+ ',';
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += 'As you may be aware, we have received a request from '+ objInvoice.supplier_text__c +' to assume responsibility for the sale and assignment of the following invoice(s) for '+ GoodsAndServices;
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += '<table style="border-style: solid;border-collapse: collapse; margin-left: 6.16998pt" cellspacing="0" width="95%">';
        strEmailContent += '<tr>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Invoice';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;"> ';
        strEmailContent += 'Issued';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Purchase Order (PO)';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Due Date';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Total amount';
        strEmailContent += '</td>';
        strEmailContent += '</tr>';
        for(Invoice_Finance_Deal__c objInv:  lstInvoice){
            strEmailContent += '<tr>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent +=  objInv.supplier_invoice_reference_number__c;
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Invoice_date__c.format();
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.buyer_purchase_order_reference__c;
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Due_Date__c.format();
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Real_Face_Value__c +' ' + objInv.CCY__c;
            strEmailContent += '</td>';
            
            strEmailContent += '</tr>';
        }
        strEmailContent += '</table>';
        strEmailContent += '</p>';
       
        strEmailContent += '<p>';
        strEmailContent += 'In order to finish verification of the invoice(s), could you please confirm the following information:';
        
        strEmailContent += '<ol>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were made by '+objInvoice.Buyer_text__c+'.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The goods were received / shipped according to the mentioned above Purchase orders and Invoices.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were absent of any credit/debit notes applicable to this/these invoice(s). ';
        strEmailContent += '</li>';
        
        
        strEmailContent += '</ol>';
        
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += 'A simple “Yes, confirmed“ reply to this email will be sufficient.';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Could you please revert to us '+ objInvoice.Deadline_for_buyer_acknowledgment__c +' by today?    <br/> ';
        strEmailContent += 'Please be advised that we will duly notify you upon each assignment of Accounts Receivable to Incomlend. These Accounts Receivable must be repaid directly to Incomlend Pte. Ltd ';
        
        strEmailContent += '<br/>';
        strEmailContent += '<br/>';
        
        strEmailContent += 'Should you have any questions please feel free to contact us.';
        strEmailContent += '<br/><br/>';
        
        
        strEmailContent += 'Regards,';
        strEmailContent += '<br/>';
        strEmailContent += 'Incomlend Team';
        
        strEmailContent += '</p>';
        strEmailContent += '</div>';
        strEmailContent += '</div>';
        strEmailContent += '</body>';
        
        strEmailContent += '</html>';
        return strEmailContent;
    }
    
    Public string Buyer_2_Incomlend_invoice_acknowledgement_OBSOLETE2(){
        String strEmailContent = '';
        strEmailContent += '<html>';
        strEmailContent += '<head>';
        strEmailContent += '<style type="text/css">';
        strEmailContent += 'div.content {';
        strEmailContent += 'padding-top: 50px;';
        strEmailContent += 'font-family: sans-serif; ';
        strEmailContent += 'font-size: 10pt;';
        strEmailContent += '}';
        
        strEmailContent += ' </style>';
        
        
        strEmailContent += '</head>';
        
        strEmailContent += '<body>';
        strEmailContent += '<div style="font-family: Calibri">';
        strEmailContent += '<center><p><img src="' + Label.Incomlend_Logo_URL  +' "/> </p></center>';
        strEmailContent += '<div class="content">';
        strEmailContent += '<p>';
        strEmailContent += 'Dear ' + objInvoice.buyer_primary_contact__c+ ',';
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += 'As you may be aware, we have received a request from '+ objInvoice.supplier_text__c +' to assume responsibility for the sale and assignment of the following invoice(s) for '+ GoodsAndServices;
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += '<table style="border-style: solid;border-collapse: collapse; margin-left: 6.16998pt" cellspacing="0" width="95%">';
        strEmailContent += '<tr>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Invoice';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;"> ';
        strEmailContent += 'Issued';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Purchase Order (PO)';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Due Date';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Total amount';
        strEmailContent += '</td>';
        strEmailContent += '</tr>';
        for(Invoice_Finance_Deal__c objInv:  lstInvoice){
            strEmailContent += '<tr>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent +=  objInv.supplier_invoice_reference_number__c;
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Invoice_date__c.format();
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.buyer_purchase_order_reference__c;
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Due_Date__c.format();
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Real_Face_Value__c +' ' + objInv.CCY__c;
            strEmailContent += '</td>';
            
            strEmailContent += '</tr>';
        }
        strEmailContent += '</table>';
        strEmailContent += '</p>';
       
        strEmailContent += '<p>';
        strEmailContent += 'In order to finish verification of the invoice(s), could you please confirm the following information:';
        
        strEmailContent += '<ol>';
        strEmailContent += '<li>';
        strEmailContent += 'The down payment of '+ decTotalRebitAmount +' has been made towards this invoice and the amount of '+ decTotalFaceValue +' remains outstanding and payable on the invoice as an absolute and whole debt.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were made by '+objInvoice.Buyer_text__c+'.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The goods were received / shipped according to the mentioned above Purchase orders and Invoices.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were absent of any credit/debit notes applicable to this/these invoice(s). ';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Any set-off rights you may have against '+objInvoice.supplier_text__c+' shall be terminated and you shall not seek to exercise any such rights in connection with the repayment of this above named invoice.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'To the best of your knowledge, the said invoice(s) are not assigned subject to any rights that any third party may have, including any lien, charge or pledge. In particular, the said invoice(s) have not been the subject of any financing to be provided by any third party company.';
        strEmailContent += '</li>';
        /*strEmailContent += '<li>';
        strEmailContent += 'By confirming the contents of this email, please note that you also confirm and accept the terms and conditions set out in the relevant invoice(s).';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Additionally, we have been informed by '+objInvoice.supplier_text__c+' that a Telex Release or Surrendered BL has been requested for the goods specified in the above invoices. By confirming the details in this email, you confirm that you, on behalf of '+objInvoice.Buyer_text__c +', acknowledge and accept the risks incumbent in a Telex Release or Surrendered BL, including but not limited to the possibility of fraud, and agree to pay the relevant account receivables to Incomlend Pte Ltd upon the payment due date.';
        strEmailContent += '</li>';*/
        strEmailContent += '</ol>';
        
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += 'A simple “Yes, confirmed“ reply to this email will be sufficient.';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Could you please revert to us by today?    <br/> ';
        strEmailContent += 'Please be advised that we will duly notify you upon each assignment of Accounts Receivable to Incomlend. These Accounts Receivable must be repaid directly to Incomlend Pte. Ltd at ';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Bank name: DBS Singapore <br/>';

        strEmailContent += 'Beneficiary name/Account name: AMICORP TRUSTEES – Incomlend PL Buyer <br/>';
        
        strEmailContent += 'A/C #: 003-956034-6 <br/>';
        
        strEmailContent += 'SWIFT: DBSSSGSG <br/>';
        
        strEmailContent += 'Currencies: SGD, HKD, EUR, USD <br/>';
        
        strEmailContent += 'Beneficiary address: 8 Cross Street, #23-06, PWC Building, Singapore 048424 <br/>';
        strEmailContent += 'Bank Address: DBS BANK Ltd 12 Marina Boulevard DBS Asia Central Marina Bay Financial Centre Tower 3 Singapore 018982 <br/>';
        
        strEmailContent += '<br/>';
        strEmailContent += '<br/>';
        
        strEmailContent += 'Should you have any questions please feel free to contact us.';
        strEmailContent += '<br/><br/>';
        
        
        strEmailContent += 'Regards,';
        strEmailContent += '<br/>';
        strEmailContent += 'Incomlend Team';
        
        strEmailContent += '</p>';
        strEmailContent += '</div>';
        strEmailContent += '</div>';
        strEmailContent += '</body>';
        
        strEmailContent += '</html>';
        return strEmailContent;
    }
    
    Public string Buyer_2_Incomlend_Supplier_invoice_acknowledgement_AISHI_TELEX_BL(){
        String strEmailContent = '';
        strEmailContent += '<html>';
        strEmailContent += '<head>';
        strEmailContent += '<style type="text/css">';
        strEmailContent += 'div.content {';
        strEmailContent += 'padding-top: 50px;';
        strEmailContent += 'font-family: sans-serif; ';
        strEmailContent += 'font-size: 10pt;';
        strEmailContent += '}';
        
        strEmailContent += ' </style>';
        
        
        strEmailContent += '</head>';
        
        strEmailContent += '<body>';
        strEmailContent += '<div style="font-family: Calibri">';
        strEmailContent += '<center><p><img src="' + Label.Incomlend_Logo_URL  +' "/> </p></center>';
        strEmailContent += '<div class="content">';
        strEmailContent += '<p>';
        strEmailContent += 'Dear ' + objInvoice.buyer_primary_contact__c+ ',';
        strEmailContent += '</p>';
        strEmailContent += '<p>';
        strEmailContent += 'As you may be aware, we have received a request from '+ objInvoice.supplier_text__c +' to assume responsibility for the sale and assignment of the following invoice(s) for '+ GoodsAndServices;
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += '<table style="border-style: solid;border-collapse: collapse; margin-left: 6.16998pt" cellspacing="0" width="95%">';
        strEmailContent += '<tr>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Invoice';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;"> ';
        strEmailContent += 'Issued';
        strEmailContent += '</td>';
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Purchase Order (PO)';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Due Date';
        strEmailContent += '</td>';
        
        strEmailContent += '<td style="border-style: solid;background-color:#D3D3D3;text-align:center;">';
        strEmailContent += 'Total amount';
        strEmailContent += '</td>';
        strEmailContent += '</tr>';
        for(Invoice_Finance_Deal__c objInv:  lstInvoice){
            strEmailContent += '<tr>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent +=  objInv.supplier_invoice_reference_number__c;
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Invoice_date__c.format();
            strEmailContent += '</td>';
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.buyer_purchase_order_reference__c;
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Due_Date__c.format();
            strEmailContent += '</td>';
            
            strEmailContent += '<td style="border-style: solid;text-align:center;">';
            strEmailContent += objInv.Real_Face_Value__c +' ' + objInv.CCY__c;
            strEmailContent += '</td>';
            
            strEmailContent += '</tr>';
        }
        strEmailContent += '</table>';
        strEmailContent += '</p>';
       
        strEmailContent += '<p>';
        strEmailContent += 'In order to finish verification of the invoice(s), could you please confirm the following information:';
        
        strEmailContent += '<ol>';
        strEmailContent += '<li>';
        strEmailContent += 'The down payment of '+ decTotalRebitAmount +' has been made towards this invoice and the amount of '+ decTotalFaceValue +' remains outstanding and payable on the invoice as an absolute and whole debt.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were made by '+objInvoice.Buyer_text__c+'.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The goods were received / shipped according to the mentioned above Purchase orders and Invoices.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'The orders for the named goods were absent of any credit/debit notes applicable to this/these invoice(s). ';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'Any set-off rights you may have against '+objInvoice.supplier_text__c+' shall be terminated and you shall not seek to exercise any such rights in connection with the repayment of this above named invoice.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'To the best of your knowledge, the said invoice(s) are not assigned subject to any rights that any third party may have, including any lien, charge or pledge. In particular, the said invoice(s) have not been the subject of any financing to be provided by any third party company.';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += 'By confirming the contents of this email, please note that you also confirm and accept the terms and conditions set out in the relevant invoice(s).';
        strEmailContent += '</li>';
        strEmailContent += '<li>';
        strEmailContent += '<b/>Additionally, we have been informed by Guangzhou AC Couture Co., Ltd that a telex release has been requested for the goods specified in the above invoices.</b> By confirming the details in this email, you confirm that you, on behalf of ROF, LLC, acknowledge and accept the risks incumbent in a telex release, including but not limited to the possibility of fraud, and agree to pay the relevant accounts receivables to Incomlend Pte Ltd upon the payment due date.';
        strEmailContent += '</li>';
        strEmailContent += '</ol>';
        
        strEmailContent += '</p>';
        
        strEmailContent += '<p>';
        strEmailContent += 'A simple “Yes, confirmed“ reply to this email will be sufficient.';
        strEmailContent += '<br/>';
        
        
        strEmailContent += 'Could you please revert to us by today?    <br/> ';
        strEmailContent += 'Please be advised that we will duly notify you upon each assignment of Accounts Receivable to Incomlend. These Accounts Receivable must be repaid directly to Incomlend Pte. Ltd at  ';
        strEmailContent += '<br/>';
        
        
        strEmailContent += objInvoice.Bank_Information_for_Payment__c;
        
        strEmailContent += '<br/>';
        strEmailContent += '<br/>';
        
        strEmailContent += 'Should you have any questions please feel free to contact us.';
        strEmailContent += '<br/><br/>';
        
        
        strEmailContent += 'Regards,';
        strEmailContent += '<br/>';
        strEmailContent += 'Incomlend Team';
        
        strEmailContent += '</p>';
        strEmailContent += '</div>';
        strEmailContent += '</div>';
        strEmailContent += '</body>';
        
        strEmailContent += '</html>';
        return strEmailContent;
    }
    
    public class wrapperAttachments{
        public Attachment objAttachment {get;set;}
        
        public wrapperAttachments(){
            objAttachment = new Attachment();
        }
    }
    
    public class ListCollection extends Pageable {
      public List<wrapperAttachments> allAttachments {get;set;}

      public override integer getRecordCount() {
            return (allAttachments == null? 0 : allAttachments.size());
      }
    }
}