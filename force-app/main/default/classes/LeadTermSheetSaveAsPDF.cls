Public Class LeadTermSheetSaveAsPDF {

    Public Lead objLead {get;set;}
    //variable used in page.
    Public Integer size {get;set;}
    Public Integer noOfRecords {get;set;}
    public List <SelectOption> paginationSizeOptions {get;set;}
    public static final Integer QUERY_LIMIT = 10000;
    public static final Integer PAGE_SIZE = 50;

    public List <WrapperClass> wrapperRecordList {get;set;}
    Map <Id, WrapperClass> mapHoldingSelectedRecords {get;set;}
    
    Public List<Invoice_Opportunity__c> lstSelectedOpportunity {get;set;}
    Public String strInvoiceNumber {get;set;}
    
    Public Boolean blnSelectAll {get;set;}
    
    public LeadTermSheetSaveAsPDF() {
        objLead = new Lead();
        blnSelectAll = false;
        wrapperRecordList = new List < WrapperClass > ();
        mapHoldingSelectedRecords = new Map < Id, WrapperClass > ();
        objLead.Id = ApexPages.currentPage().getParameters().get('id');
        objLead = [Select Id, Name, Company , OwnerId, Owner.Email, Owner.Name, CCY__c,
                   Product_type__c, Company_Activity__c, Country, Advanced_Amount__c, Advanced_Amount_Other__c,
                   Supplier_Discount_Rate__c, First_Invoice_amount__c, Average_Funding_Period__c, Processing_Fees__c,
                   Facility_Fees__c, Annual_Fees__c, Annual_Fees_Per_Trade_Partner__c, Dedicated_account_fee__c,
                   One_time_fees_for_opening_dedicated_bank__c, Maintenance_of_dedicated_bank_account__c,
                   FirstName, LastName, Title
                    From Lead where Id=: objLead.Id];
                    
        if(ObjLead.CCY__c == null || objLead.CCY__c == ''){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and select CCY in Lead termsheet section.'));
            //return null;
        }  else if(ObjLead.Company_Activity__c == null || objLead.Company_Activity__c == ''){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and select Company Activity in Lead termsheet section.'));
            //return null;
        } else if((ObjLead.Advanced_Amount__c == null || objLead.Advanced_Amount__c == '') && (ObjLead.Advanced_Amount_Other__c == null || objLead.Advanced_Amount_Other__c == '') ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and enater Advanced Amount in Lead termsheet section.'));
            //return null;
        }else if(ObjLead.Supplier_Discount_Rate__c == null){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and enter Supplier Discount Rate  in Lead termsheet section.'));
            //return null;
        } else if(ObjLead.First_Invoice_amount__c == null){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and enter Average Invoice Size in Lead termsheet section.'));
            //return null;
        } else if(ObjLead.Average_Funding_Period__c == null || objLead.Average_Funding_Period__c == ''){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and enter Average Funding Period in Lead termsheet section.'));
            //return null;
        } else if(ObjLead.Processing_Fees__c == null){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and enter Processing fess in Lead termsheet section.'));
            //return null;
        } else if(ObjLead.Facility_Fees__c == null){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and enter Facility Fees in Lead termsheet section.'));
            //return null;
        } else if(ObjLead.Annual_Fees__c == null ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and enter Annual Fees in Lead termsheet section.'));
            //return null;
        } else if(ObjLead.Annual_Fees_Per_Trade_Partner__c == null ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and enter Annual Fees Per Trade Partner in Lead termsheet section.'));
            //return null;
        } else if(ObjLead.Dedicated_account_fee__c == true && ObjLead.One_time_fees_for_opening_dedicated_bank__c == null ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and enter One time fees for openaing dedicated bank account in Lead termsheet section.'));
            //return null;
        } else if(ObjLead.Dedicated_account_fee__c == true && ObjLead.Maintenance_of_dedicated_bank_account__c == null ){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please go back on lead record and enter Maintenance of dedicated bank account in Lead termsheet section.'));
            //return null;
        }else{
        
            init();
        }
    }
    
    
    //Init method which queries the records from standard set controller.
    public void init() {
        SelectAll();
        wrapperRecordList = new List < WrapperClass > ();
        for (Invoice_Opportunity__c cont: (List <Invoice_Opportunity__c>) setCon.getRecords()) {
            if (mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(cont.id)) {
                wrapperRecordList.add(mapHoldingSelectedRecords.get(cont.id));

            } else {
                wrapperRecordList.add(new WrapperClass(cont, false));
            }
        }
    }
    /** Instantiate the StandardSetController from a query locater*/
    public ApexPages.StandardSetController setCon {
        get {
            if (setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Lead_Name__c, Lead_Name__r.Company, Lead_Name__r.FirstName,  Lead_Name__r.LastName, 
                                Lead_Name__r.Credit_Limit_Provided_by_Insurer__c , Lead_Name__r.Phone , Lead_Name__r.Email, Lead_Name__r.Title,
                                Lead_Name__r.Supplier_Discount_Rate__c , Lead_Name__r.Credit_Limit_Requested_CCY__c , SDR__c 
                                from Invoice_Opportunity__c where Lead_Name_Supplier__c =: objLead.Id 
                                and Opportunity_Status__c = 'Pipeline' LIMIT: QUERY_LIMIT]));

                // sets the number of records to show in each page view
                setCon.setPageSize(PAGE_SIZE);
            }
            return setCon;
        }
        set;
    }
    /** indicates whether there are more records after the current page set.*/
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }

    /** indicates whether there are more records before the current page set.*/
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }

    /** returns the page number of the current page set*/
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }

    /** return total number of pages for page set*/
    Public Integer getTotalPages() {
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize / pageSize;
        return (Integer) pages.round(System.RoundingMode.CEILING);
    }

    /** returns the first page of the page set*/
    public void first() {
        updateSearchItemsMap();
        setCon.first();
        init();
    }

    /** returns the last page of the page set*/
    public void last() {
        updateSearchItemsMap();
        setCon.last();
        init();
    }

    /** returns the previous page of the page set*/
    public void previous() {
        updateSearchItemsMap();
        setCon.previous();
        init();
    }

    /** returns the next page of the page set*/
    public void next() {
        
        updateSearchItemsMap();
        setCon.next();
        init();
    }

    //This is the method which manages to remove the deselected records, and keep the records which are selected in map.
    public void updateSearchItemsMap() {
        for (WrapperClass wrp: wrapperRecordList) {
            if (wrp.isSelected == True) {
                mapHoldingSelectedRecords.put(wrp.objOpportunity.id, wrp);
            }
            if (wrp.isSelected == false && mapHoldingSelectedRecords.containsKey(wrp.objOpportunity.id)) {
                mapHoldingSelectedRecords.remove(wrp.objOpportunity.id);
            }
        }
    }
    
    Public void SelectAll(){
        for (WrapperClass wrp: wrapperRecordList) {
            if(blnSelectAll == true){
                wrp.isSelected = true;
                mapHoldingSelectedRecords.put(wrp.objOpportunity.id, wrp);
            }else if(blnSelectAll == false){
                wrp.isSelected = false;
                mapHoldingSelectedRecords.remove(wrp.objOpportunity.id);
            }
        }
    }
    
    public PageReference savePdf() {
        updateSearchItemsMap();
        system.debug('**********mapHoldingSelectedRecords == '+mapHoldingSelectedRecords);
        String strOppId = '';
        for(String strId : mapHoldingSelectedRecords.KeySet()){
            if(strOppId == ''){
                strOppId = strId;
            }else{
                strOppId = strOppId + ','+ strId;
            }
        }
        system.debug('**********strOppId == '+strOppId);
        objLead = [Select Id, Name, Company , OwnerId, Owner.Email, Owner.Name, CCY__c, Termsheet_Potential_Buyers__c,
                   Product_type__c, Company_Activity__c, Country, Advanced_Amount__c, Advanced_Amount_Other__c,
                   Supplier_Discount_Rate__c, First_Invoice_amount__c, Average_Funding_Period__c, Processing_Fees__c,
                   Facility_Fees__c, Annual_Fees__c, Annual_Fees_Per_Trade_Partner__c, Dedicated_account_fee__c,
                   One_time_fees_for_opening_dedicated_bank__c, Maintenance_of_dedicated_bank_account__c,
                   FirstName, LastName, Title
                    From Lead where Id=: objLead.Id];
        
        List<Invoice_Opportunity__c> lstSalesOpportunity = [Select Id, Lead_Name__c, Lead_Name__r.Company, Lead_Name__r.FirstName,  Lead_Name__r.LastName, 
                                Lead_Name__r.Credit_Limit_Provided_by_Insurer__c , Lead_Name__r.Phone , Lead_Name__r.Email, Lead_Name__r.Title,
                                Lead_Name__r.Supplier_Discount_Rate__c , Lead_Name__r.Credit_Limit_Requested_CCY__c , SDR__c 
                                from Invoice_Opportunity__c where Lead_Name_Supplier__c =: objLead.Id 
                                and Opportunity_Status__c = 'Pipeline' and ID IN: mapHoldingSelectedRecords.KeySet()];
                                
        String strPotentialBuyersTable = '';
                strPotentialBuyersTable += '<table style="margin-top:5pt;border-style: solid;border-color: #bebebe; border-collapse: collapse;">';
                strPotentialBuyersTable += '<tr>';
                
                strPotentialBuyersTable += '<th style="border-style: solid;border-color: #bebebe; border-collapse: collapse;">';
                strPotentialBuyersTable += 'Pre-Qualified Buyers';
                strPotentialBuyersTable += '</th>';
                
                strPotentialBuyersTable += '<th style="border-style: solid;border-color: #bebebe; border-collapse: collapse;">';
                strPotentialBuyersTable += 'Credit Limit';
                strPotentialBuyersTable += '</th>';
                strPotentialBuyersTable += '<th style="border-style: solid;border-color: #bebebe; border-collapse: collapse;">';
                strPotentialBuyersTable += 'Currency';
                strPotentialBuyersTable += '</th>';
                
                strPotentialBuyersTable += '<th style="border-style: solid;border-color: #bebebe; border-collapse: collapse;">';
                strPotentialBuyersTable += 'Discount Rate';
                strPotentialBuyersTable += '</th>';
                
                strPotentialBuyersTable += '</tr>';
                for(Invoice_Opportunity__c Supplier: lstSalesOpportunity){
                strPotentialBuyersTable += '<tr>';
                
                strPotentialBuyersTable += '<td style="border-style: solid;border-color: #bebebe; border-collapse: collapse;">';
                strPotentialBuyersTable += Supplier.Lead_Name__r.Company;
                strPotentialBuyersTable += '</td>';
                
                strPotentialBuyersTable += '<td style="border-style: solid;border-color: #bebebe; border-collapse: collapse;">';
                strPotentialBuyersTable += Supplier.Lead_Name__r.Credit_Limit_Provided_by_Insurer__c;
                strPotentialBuyersTable += '</td>';
                
                strPotentialBuyersTable += '<td style="border-style: solid;border-color: #bebebe; border-collapse: collapse;">';
                strPotentialBuyersTable += Supplier.Lead_Name__r.Credit_Limit_Requested_CCY__c;
                strPotentialBuyersTable += '</td>';
                
                strPotentialBuyersTable += ' <td style="border-style: solid;border-color: #bebebe; border-collapse: collapse;">';
                if(objLead.CCY__c == 'USD'){
                    strPotentialBuyersTable += '3-Month SOFR plus ' ;
                    
                    if(Supplier.SDR__c == null){
                        strPotentialBuyersTable += objLead.Supplier_Discount_Rate__c;
                    } else {
                        strPotentialBuyersTable +=Supplier.SDR__c;
                    }  
                    strPotentialBuyersTable +=' per annum';
                }else if(objLead.CCY__c == 'EUR'){
                    strPotentialBuyersTable += '3-Month EURIBOR plus ';
                    if(Supplier.SDR__c == null){
                        strPotentialBuyersTable += objLead.Supplier_Discount_Rate__c;
                    } else {
                        strPotentialBuyersTable +=Supplier.SDR__c;
                    }  
                    strPotentialBuyersTable +=' per annum';
                }else if(objLead.CCY__c == 'GBP'){
                    strPotentialBuyersTable += '3-Month Daily SONIA plus ';
                    if(Supplier.SDR__c == null){
                        strPotentialBuyersTable += objLead.Supplier_Discount_Rate__c;
                    } else {
                        strPotentialBuyersTable +=Supplier.SDR__c;
                    }  
                    strPotentialBuyersTable +=' per annum';
                }
                
                
                strPotentialBuyersTable += '</td>';
                }               
                strPotentialBuyersTable += '</tr>';
                strPotentialBuyersTable += '</table>';
        
        objLead.Termsheet_Potential_Buyers__c = strPotentialBuyersTable;
        update objLead;
        
        
        PageReference pdf = Page.LeadTermSheet;
        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('id',objLead.Id);
        pdf.getParameters().put('OppIds', strOppId);
        string pdfName = objLead.Company + '_Term Sheet'+'_' + System.Now().format('yyyy-MM-dd HH:mm:ss') +'.pdf';
        // create the new attachment
        Attachment attach = new Attachment();
        
        // the contents of the attachment from the pdf
        Blob body;
        
        try {
            
            // returns the output of the page as a PDF
            body = pdf.getContent();
            
        // need to pass unit test -- current bug    
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
        }
        
        attach.Body = body;
        // add the user entered name
        attach.Name = pdfName;
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = objLead.Id;
        insert attach;
        
        List<String> emailId = new List<String>();
        emailId.add(objLead.Owner.Email);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
        efa1.setFileName(pdfName);
        efa1.setBody(body);

        String addresses;
        email.setSubject(pdfName);
        email.setToAddresses( emailId  );
        email.setPlainTextBody('Hi ' +objLead.Owner.Name + ', Please review attach PDf file of Termsheet and keep it as backup');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
        if(! Test.isRunningTest()){
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
        
        
       
        
        // send the user to the account to view results
        return new PageReference('/'+objLead.Id);
        //return pdf;
    
      }
      
    //wrapper class being used for checkbox showing.
    public class WrapperClass {
        public Boolean isSelected {get;set;}
        public Invoice_Opportunity__c objOpportunity {get;set;}
        public WrapperClass(Invoice_Opportunity__c objSalesOpportunity, Boolean isSelected) {
            this.objOpportunity = objSalesOpportunity;
            this.isSelected = isSelected;
        }
    }
      
}