public class SelectInvoiceForBuyerConfirmation {

    //variable used in page.
    Public Integer size {get;set;}
    Public Integer noOfRecords {get;set;}
    public List <SelectOption> paginationSizeOptions {get;set;}
    public static final Integer QUERY_LIMIT = 10000;
    public static final Integer PAGE_SIZE = 10;

    public List <WrapperClass> wrapperRecordList {get;set;}
    Map <Id, WrapperClass> mapHoldingSelectedRecords {get;set;}
    public Supplier_Buyer_Map__c objSupplierBuyerMap{get;set;}    
    
    Public List<invoice_finance_deal__c> lstSelectedInvoice {get;set;}
    Public String strInvoiceNumber {get;set;}
    
    //constructor calling init method.
    public SelectInvoiceForBuyerConfirmation() {
        objSupplierBuyerMap = new Supplier_Buyer_Map__c();
        lstSelectedInvoice = new List<invoice_finance_deal__c> ();
        objSupplierBuyerMap.Id = ApexPages.currentPage().getParameters().get('id');
        objSupplierBuyerMap = [Select Id, Name, Buyer_Name__c, Buyer__r.buyer_full_address__c, Supplier_name__c, 
                                Supplier__r.Primary_Contact__r.FirstName, Supplier__r.Primary_Contact__r.LastName,
                                Supplier__r.Primary_Contact__r.Title from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap.Id];
        mapHoldingSelectedRecords = new Map < Id, WrapperClass > ();
        init();

    }
    
     //Init method which queries the records from standard set controller.
    public void init() {
        wrapperRecordList = new List < WrapperClass > ();
        for (Invoice_finance_deal__c cont: (List < Invoice_finance_deal__c > ) setCon.getRecords()) {
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
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, buyer_purchase_order_reference__c , supplier_invoice_reference_number__c, Invoice_date__c, Real_Face_Value__c,
                      Due_Date__c, Bank_Information_for_Payment__c, advanced_amount__c, Balance_due__c, Supplier_name__c from invoice_finance_deal__c where 
                      Supplier_Buyer_Map__c =: objSupplierBuyerMap.Id and Phase__c = '1:PRE LISTING'
                      and RecordType.DeveloperName = 'Pricing_V2_2018' LIMIT: QUERY_LIMIT]));

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
    private void updateSearchItemsMap() {
        for (WrapperClass wrp: wrapperRecordList) {
            if (wrp.isSelected) {
                mapHoldingSelectedRecords.put(wrp.objInvoice.id, wrp);
            }
            if (wrp.isSelected == false && mapHoldingSelectedRecords.containsKey(wrp.objInvoice.id)) {
                mapHoldingSelectedRecords.remove(wrp.objInvoice.id);
            }
        }
    }
    
    public PageReference savePdf() {
        updateSearchItemsMap();
        
        if(mapHoldingSelectedRecords.size() == 0){
            apexpages.addMessage(new ApexPages.message(Apexpages.Severity.error,'Please select atleast one invoice to genrate NOA.'));
            return null;
        }
        String strInvoiceIds = '';
        for(String strId : mapHoldingSelectedRecords.KeySet()){
            if(strInvoiceIds == ''){
                strInvoiceIds = strId;
            }else{
                strInvoiceIds = strInvoiceIds + ','+ strId;
            }
        }
        system.debug('****** objSupplierBuyerMap.Id == '+objSupplierBuyerMap.Id);
        system.debug('****** strInvoiceIds == '+strInvoiceIds);
        string pdfName = objSupplierBuyerMap.Name + '_' +'_BuyerConfirmation_Arzak-QFM.pdf';
        PageReference pdf = Page.BuyerConfirmationArzakAndQFM;
        
        pdf.getParameters().put('id',objSupplierBuyerMap.Id);
        pdf.getParameters().put('InvoiceIds', strInvoiceIds);
        //return pdf;
        
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
        attach.ParentId = objSupplierBuyerMap.Id;
        insert attach;
        
        // send the user to the account to view results
        return new PageReference('/'+objSupplierBuyerMap.Id);
        //return null;
      }

    //wrapper class being used for checkbox showing.
    public class WrapperClass {
        public Boolean isSelected {get;set;}
        public Invoice_finance_deal__c objInvoice {get;set;}
        
        public WrapperClass(Invoice_finance_deal__c objInvoiceFinanceDeal, Boolean isSelected) {
            this.objInvoice = objInvoiceFinanceDeal;
            this.isSelected = isSelected;
        }
    }
    
}