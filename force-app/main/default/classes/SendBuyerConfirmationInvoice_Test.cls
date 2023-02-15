@isTest
private class SendBuyerConfirmationInvoice_Test {
    
    private static void createInvoice(){
        Map<String, Object> result = SeedTest.init(null, null, 'contact');//'passthrough');
        Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        invoice.Phase__c = '3:IN PROGRESS';
        invoice.Status__c = 'In progress';    
        invoice.platform_fee_fixed__c = 30;
        update invoice;
    }
    
    private static void createTemplate(String DeveloperName){
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = DeveloperName;
        validEmailTemplate.DeveloperName = DeveloperName;
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        
        insert validEmailTemplate;
    }
    
    static testMethod void myTest1() {
        createInvoice();
        
        
        invoice_finance_deal__c invoice = [Select id, Buyer_Name__c, buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c ];
        
        EmailTemplate objEmailTemplate = [select Id, Body, Name, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName = 'Buyer_2_Incomlend_invoice_acknowledgement' limit 1];
        
        PageReference pageRef = Page.SelectTemplateForSingleBC;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice);
        SendBuyerConfirmationInvoice ext = new SendBuyerConfirmationInvoice(sc);

        SendBuyerConfirmationInvoice.wrapperAttachments wrapper= new SendBuyerConfirmationInvoice.wrapperAttachments ();
        ext.getAllEmailTemplates();
        ext.TemplateId = objEmailTemplate.Id;
        ext.populateTemplate();
        ext.GenerateEmailContent();
        ext.Cancel();
        ext.DeleteAttachments();
        ext.send();
    }
    
    static testMethod void myTest2() {
        createInvoice();
        
        
        invoice_finance_deal__c invoice = [Select id, Buyer_Name__c, buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c ];
        
        EmailTemplate objEmailTemplate = [select Id, Body, Name, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName = 'Buyer_2_Incomlend_invoice_acknowledgement_BLUE_PLANET' limit 1];
        
        PageReference pageRef = Page.SelectTemplateForSingleBC;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice);
        SendBuyerConfirmationInvoice ext = new SendBuyerConfirmationInvoice(sc);

        SendBuyerConfirmationInvoice.wrapperAttachments wrapper= new SendBuyerConfirmationInvoice.wrapperAttachments ();
        ext.getAllEmailTemplates();
        ext.TemplateId = objEmailTemplate.Id;
        ext.populateTemplate();
        ext.GenerateEmailContent();
        ext.Cancel();
        ext.DeleteAttachments();
        ext.send();
    }
    
    static testMethod void myTest3() {
        createInvoice();
        
        
        invoice_finance_deal__c invoice = [Select id, Buyer_Name__c, buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c ];
        
        EmailTemplate objEmailTemplate = [select Id, Body, Name, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName = 'Buyer_2_Incomlend_Supplier_invoice_acknowledgement_GUILAI_TELEX_BL' limit 1];
        
        PageReference pageRef = Page.SelectTemplateForSingleBC;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice);
        SendBuyerConfirmationInvoice ext = new SendBuyerConfirmationInvoice(sc);

        SendBuyerConfirmationInvoice.wrapperAttachments wrapper= new SendBuyerConfirmationInvoice.wrapperAttachments ();
        ext.getAllEmailTemplates();
        ext.TemplateId = objEmailTemplate.Id;
        ext.populateTemplate();
        ext.GenerateEmailContent();
        ext.Cancel();
        ext.DeleteAttachments();
        ext.send();
    }
    
    static testMethod void myTest4() {
        createInvoice();
        
        
        invoice_finance_deal__c invoice = [Select id, Buyer_Name__c, buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c ];
        
        EmailTemplate objEmailTemplate = [select Id, Body, Name, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName = 'Buyer_2_Incomlend_invoice_acknowledgement_ABCOM' limit 1];
        
        PageReference pageRef = Page.SelectTemplateForSingleBC;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice);
        SendBuyerConfirmationInvoice ext = new SendBuyerConfirmationInvoice(sc);

        SendBuyerConfirmationInvoice.wrapperAttachments wrapper= new SendBuyerConfirmationInvoice.wrapperAttachments ();
        ext.getAllEmailTemplates();
        ext.TemplateId = objEmailTemplate.Id;
        ext.populateTemplate();
        ext.GenerateEmailContent();
        ext.Cancel();
        ext.DeleteAttachments();
        ext.send();
    }
    
    static testMethod void myTest5() {
        createInvoice();
        
        
        invoice_finance_deal__c invoice = [Select id, Buyer_Name__c, buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c ];
        
        EmailTemplate objEmailTemplate = [select Id, Body, Name, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName = 'Buyer_2_Incomlend_invoice_acknowledgement_fortunex' limit 1];
        
        PageReference pageRef = Page.SelectTemplateForSingleBC;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice);
        SendBuyerConfirmationInvoice ext = new SendBuyerConfirmationInvoice(sc);

        SendBuyerConfirmationInvoice.wrapperAttachments wrapper= new SendBuyerConfirmationInvoice.wrapperAttachments ();
        ext.getAllEmailTemplates();
        ext.TemplateId = objEmailTemplate.Id;
        ext.populateTemplate();
        ext.GenerateEmailContent();
        ext.Cancel();
        ext.DeleteAttachments();
        ext.send();
    }
    
    static testMethod void myTest6() {
        createInvoice();
        
        
        invoice_finance_deal__c invoice = [Select id, Buyer_Name__c, buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c ];
        
        EmailTemplate objEmailTemplate = [select Id, Body, Name, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName = 'Buyer_2_Incomlend_Supplier_invoice_acknowledgement_Safeflex' limit 1];
        
        PageReference pageRef = Page.SelectTemplateForSingleBC;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice);
        SendBuyerConfirmationInvoice ext = new SendBuyerConfirmationInvoice(sc);

        SendBuyerConfirmationInvoice.wrapperAttachments wrapper= new SendBuyerConfirmationInvoice.wrapperAttachments ();
        ext.getAllEmailTemplates();
        ext.TemplateId = objEmailTemplate.Id;
        ext.populateTemplate();
        ext.GenerateEmailContent();
        ext.Cancel();
        ext.DeleteAttachments();
        ext.send();
    }
    
    static testMethod void myTest7() {
        createInvoice();
        
        
        invoice_finance_deal__c invoice = [Select id, Buyer_Name__c, buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c ];
        
        EmailTemplate objEmailTemplate = [select Id, Body, Name, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName = 'Buyer_2_Incomlend_invoice_acknowledgement_OBSOLETE1' limit 1];
        
        PageReference pageRef = Page.SelectTemplateForSingleBC;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice);
        SendBuyerConfirmationInvoice ext = new SendBuyerConfirmationInvoice(sc);

        SendBuyerConfirmationInvoice.wrapperAttachments wrapper= new SendBuyerConfirmationInvoice.wrapperAttachments ();
        ext.getAllEmailTemplates();
        ext.TemplateId = objEmailTemplate.Id;
        ext.populateTemplate();
        ext.GenerateEmailContent();
        ext.Cancel();
        ext.DeleteAttachments();
        ext.send();
    }
    
    static testMethod void myTest8() {
        createInvoice();
        
        
        invoice_finance_deal__c invoice = [Select id, Buyer_Name__c, buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c ];
        
        EmailTemplate objEmailTemplate = [select Id, Body, Name, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName = 'Buyer_2_Incomlend_invoice_acknowledgement_OBSOLETE2' limit 1];
        
        PageReference pageRef = Page.SelectTemplateForSingleBC;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice);
        SendBuyerConfirmationInvoice ext = new SendBuyerConfirmationInvoice(sc);

        SendBuyerConfirmationInvoice.wrapperAttachments wrapper= new SendBuyerConfirmationInvoice.wrapperAttachments ();
        ext.getAllEmailTemplates();
        ext.TemplateId = objEmailTemplate.Id;
        ext.populateTemplate();
        ext.GenerateEmailContent();
        ext.Cancel();
        ext.DeleteAttachments();
        ext.send();
    }
    static testMethod void myTest9() {
        createInvoice();
        
        invoice_finance_deal__c invoice = [Select id, Buyer_Name__c, buyer_primary_contact__c , supplier_text__c , Goods_Services_description__c, Invoice_name__c, 
                            Bank_Information_for_Payment__c, Buyer_Confirmation_Status__c , Supplier_Buyer_Map__r.Buyer__r.Primary_Contact__c, 
                            buyer_Primary_Contact_Email__c, supplier_invoice_reference_number__c, Invoice_date__c, buyer_purchase_order_reference__c, Good_and_services_offered__c,
                            Due_Date__c, Real_Face_Value__c, CCY__c, Total_Rebate_Amount__c, Buyer_text__c, Deadline_for_buyer_acknowledgment__c from invoice_finance_deal__c ];
        
        EmailTemplate objEmailTemplate = [select Id, Body, Name, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName = 'Buyer_2_Incomlend_Supplier_invoice_acknowledgement_AISHI_TELEX_BL' limit 1];
        
        PageReference pageRef = Page.SelectTemplateForSingleBC;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(invoice);
        SendBuyerConfirmationInvoice ext = new SendBuyerConfirmationInvoice(sc);

        SendBuyerConfirmationInvoice.wrapperAttachments wrapper= new SendBuyerConfirmationInvoice.wrapperAttachments ();
        ext.getAllEmailTemplates();
        ext.TemplateId = objEmailTemplate.Id;
        ext.populateTemplate();
        ext.GenerateEmailContent();
        ext.Cancel();
        ext.DeleteAttachments();
        ext.send();
    }
    
}