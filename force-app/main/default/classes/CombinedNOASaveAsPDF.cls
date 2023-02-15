Public Class CombinedNOASaveAsPDF {

    Public Supplier_Buyer_Map__c objSupplierBuyerMap {get;set;}
    Public String lstInvoiceIds {get;set;}
    Public String strInvoiceNumber {get;set;}
    Public List<Invoice_finance_deal__c> lstSelectedInvoice {get;set;}
    Public List<Map_Supporting_Document__c> lstSupportingDoc {get;set;}
    Public String ARPADocRefNo {get;set;}
    Public DateTime ARPADocDate {get;set;}
    Public List<Id> lstInvoiceId {get;set;}
    Public String imageURL{get;set;}
    
    Public Decimal decTotalRebitAmount {get;set;}
    Public Decimal decTotalFaceValue {get;set;}
    
    public CombinedNOASaveAsPDF() {
        objSupplierBuyerMap = new Supplier_Buyer_Map__c();
        lstInvoiceId = new List<Id>();
        lstInvoiceIds = '';
        imageURL = '';
        objSupplierBuyerMap.Id = ApexPages.currentPage().getParameters().get('id');
        lstInvoiceIds = ApexPages.currentPage().getParameters().get('InvoiceIds');
        lstInvoiceId = lstInvoiceIds.split(',');
        strInvoiceNumber = '';
        ARPADocRefNo = '';
        ARPADocDate = null;
        decTotalRebitAmount = 0.00;
        decTotalFaceValue = 0.00;
        
        lstSelectedInvoice = New List<Invoice_finance_deal__c>();
        lstSupportingDoc = new List<Map_Supporting_Document__c>();
        
        List<document> documentList = [select name from document where 
                                                  Name = 'incomlend logo medium'];
    
        if(documentList != null && documentList.size() > 0)
        {
            imageURL = '/servlet/servlet.FileDownload?file=';
            imageURL = imageURL + documentList[0].id;
            System.debug(LoggingLevel.INFO, '//// imageURL modified now ' + imageURL);
        }
        
        savePdf();
    }
    
    public Void savePdf() {
        objSupplierBuyerMap = [Select Id, Name, Buyer_Name__c, Buyer__r.buyer_full_address__c, Supplier_name__c, Supplier__r.Full_billing_Address__c, 
                                Supplier__r.Primary_Contact__r.FirstName, Supplier__r.Primary_Contact__r.LastName,
                                Buyer__r.Primary_contact_First_Name__c, Buyer__r.Primary_Contact__r.Title, 
                                Supplier__r.ARPA_IPA_Ref_Number_Trust__c,Supplier__r.ARPA_IPA_Signature_Date_Trust__c,
                                Supplier__r.Primary_Contact__r.Title from Supplier_Buyer_Map__c where Id =: objSupplierBuyerMap.Id];
        
        if(objSupplierBuyerMap.Supplier__r.ARPA_IPA_Ref_Number_Trust__c != null && objSupplierBuyerMap.Supplier__r.ARPA_IPA_Ref_Number_Trust__c != ''){
            ARPADocRefNo = objSupplierBuyerMap.Supplier__r.ARPA_IPA_Ref_Number_Trust__c;
        }
        if(objSupplierBuyerMap.Supplier__r.ARPA_IPA_Signature_Date_Trust__c != null){
            ARPADocDate = objSupplierBuyerMap.Supplier__r.ARPA_IPA_Signature_Date_Trust__c;
        }
                              
        lstSelectedInvoice = [Select Id, buyer_purchase_order_reference__c, supplier_invoice_reference_number__c, Invoice_date__c, Real_Face_Value__c, buyer_acknowledgment_received_date__c,
                      Due_Date__c, Bank_Information_for_Payment__c , advanced_amount__c, Balance_due__c, Supplier_name__c,
                      supplier_request_signed_date__c , Total_Rebate_Amount__c, Bill_of_Lading_No__c from invoice_finance_deal__c where 
                      Supplier_Buyer_Map__c =: objSupplierBuyerMap.Id and Id IN:lstInvoiceId and Phase__c = '1:PRE LISTING'
                      and RecordType.DeveloperName = 'Pricing_V2_2018'];
                                                    
        for(invoice_finance_deal__c objInvoice : lstSelectedInvoice){
            if(strInvoiceNumber == ''){
                strInvoiceNumber = objInvoice.supplier_invoice_reference_number__c;
            }else{
                strInvoiceNumber += ' ,' + objInvoice.supplier_invoice_reference_number__c;
            }
            if(objInvoice.Total_Rebate_Amount__c != null){
                decTotalRebitAmount += objInvoice.Total_Rebate_Amount__c;
            }
            if(objInvoice.Real_Face_Value__c != null){
                decTotalFaceValue += objInvoice.Real_Face_Value__c;
            }
        }
        
        if(decTotalFaceValue > 0 && decTotalRebitAmount > 0){
            decTotalFaceValue = decTotalFaceValue - decTotalRebitAmount;
        }
        
        if(ARPADocRefNo == '' || ARPADocRefNo == null ){
            lstSupportingDoc = [Select Id, Ref_Number__c, CreatedDate from Map_Supporting_Document__c where 
                                Supplier_Buyer_Map__c =: objSupplierBuyerMap.Id and Document_Type__c = 'RPA' order by CreatedDate desc];
            system.debug('******* lstSupportingDoc == '+ lstSupportingDoc);                   
            if(lstSupportingDoc.size() > 0){
                ARPADocRefNo = lstSupportingDoc[0].Ref_Number__c;
                ARPADocDate = lstSupportingDoc[0].CreatedDate;
            }
        }
        system.debug('******* ARPADocRefNo == '+ ARPADocRefNo);
        system.debug('******* ARPADocDate == '+ ARPADocDate);
    }
    
    
}