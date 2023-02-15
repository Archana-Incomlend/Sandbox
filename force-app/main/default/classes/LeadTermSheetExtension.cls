Public Class LeadTermSheetExtension {
    
    Public Lead objLead {get;set;}
    Public List<Invoice_Opportunity__c> lstSalesOpportunity {get;set;}
    Public Date AcceptanceDate {get;set;}
    Public Date KYCDate {get;set;}
    Public String imageURL{get;set;}
    Public Decimal TotalCreditLimit {get;set;}
    Public List<Id> lstOppId {get;set;}
    
    public LeadTermSheetExtension() {
        lstOppId = new List<Id>();
        String OppoIds = '';
        objLead = new Lead();
        lstSalesOpportunity = new List<Invoice_Opportunity__c>();
        objLead.Id = ApexPages.currentPage().getParameters().get('Id');
        OppoIds = ApexPages.currentPage().getParameters().get('OppIds');
        if(OppoIds != '' && OppoIds != null){
        lstOppId = OppoIds.split(',');
        
        system.debug('****** lstOppId == '+lstOppId);
        system.debug('****** objLead == '+objLead);
        
        TotalCreditLimit = 0;
        AcceptanceDate = System.Today().addDays(15);
        KYCDate = System.Today().addDays(21);
        objLead.Id = ApexPages.currentPage().getParameters().get('id');
        objLead = [Select Id, Name, Company , OwnerId, Owner.Email, Owner.Name, CCY__c,
                   Product_type__c, Company_Activity__c, Country, Advanced_Amount__c, Advanced_Amount_Other__c,
                   Supplier_Discount_Rate__c, First_Invoice_amount__c, Average_Funding_Period__c, Processing_Fees__c,
                   Facility_Fees__c, Annual_Fees__c, Annual_Fees_Per_Trade_Partner__c, Dedicated_account_fee__c,
                   One_time_fees_for_opening_dedicated_bank__c, Maintenance_of_dedicated_bank_account__c, Facility_Fees_To_Be_Paid__c,
                   FirstName, LastName, Title
                   From Lead where Id=: objLead.Id];
        
        lstSalesOpportunity = [Select Id, Lead_Name__c, Lead_Name__r.Company, Lead_Name__r.FirstName,  Lead_Name__r.LastName, 
                                Lead_Name__r.Credit_Limit_Provided_by_Insurer__c , Lead_Name__r.Phone , Lead_Name__r.Email, Lead_Name__r.Title,
                                Lead_Name__r.Supplier_Discount_Rate__c , Lead_Name__r.Credit_Limit_Requested_CCY__c , SDR__c 
                                from Invoice_Opportunity__c where Lead_Name_Supplier__c =: objLead.Id 
                                and Opportunity_Status__c = 'Pipeline' and ID IN: lstOppId];
        
        
        for(Invoice_Opportunity__c objSupplier : lstSalesOpportunity){
            if(objSupplier.Lead_Name__r.Credit_Limit_Provided_by_Insurer__c != null){
                TotalCreditLimit += objSupplier.Lead_Name__r.Credit_Limit_Provided_by_Insurer__c;
            }
        }
        
        List<document> documentList = [select name from document where 
                                                  Name = 'incomlend logo medium'];
    
        if(documentList != null && documentList.size() > 0)
        {
            imageURL = '/servlet/servlet.FileDownload?file=';
            imageURL = imageURL + documentList[0].id;
            System.debug(LoggingLevel.INFO, '//// imageURL modified now ' + imageURL);
        }
        }
    }
    
    
}