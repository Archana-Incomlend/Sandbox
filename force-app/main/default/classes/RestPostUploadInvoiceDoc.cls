//===============================================================================================================
// This class defines the POST controller and service logic regarding the process of inserting Invoice Supporting Documents
// 
// Author: Archana Patel.
//===============================================================================================================
@RestResource(urlMapping='/v9/UploadInvoiceDoc/*')

Global with sharing class RestPostUploadInvoiceDoc {

    
    @HttpPOST 
    global static GlobalMethods_v9.InvoiceDocReturnClass doPost() {
        RestRequest     request    = RestContext.request;
        RestResponse    response   = RestContext.response;    
        response.addHeader('Content-Type','applicatin/json');
        fromJSON jsonBody ;
        try{
            jsonBody  = (fromJSON) JSON.deserialize(request.requestBody.toString(),fromJSON.class);
            
            system.debug('******* jsonBody.InvoiceId == ' + jsonBody.InvoiceId );
            system.debug('******* jsonBody.MapSupportingDocId== ' +jsonBody.MapSupportingDocId );
            system.debug('******* jsonBody.File== ' +jsonBody.File );
            
            if(jsonBody.InvoiceId != null && jsonBody.InvoiceId != '' && jsonBody.MapSupportingDocId != null && jsonBody.MapSupportingDocId != ''
                && jsonBody.File != null && jsonBody.FileName != null & jsonBody.FileName != ''){
                
                String strRequest = jsonBody.InvoiceId + '-' + jsonBody.MapSupportingDocId + '-' + jsonBody.FileName;
                
                String cachedInvoiceDocStr = config.getConfig('Marketplace_Cached_Invoice_Supporting_Doc_Str');
                String invoiceDocHashStr = GlobalTriggerHandler.getHash(strRequest); // data value too large
                if (cachedInvoiceDocStr != null && cachedInvoiceDocStr != 'key not found' && invoiceDocHashStr == cachedInvoiceDocStr) {
                    return new GlobalMethods_v9.InvoiceDocReturnClass('true', 'Duplicate request, submitted document is already exist for Invoice.', null);
                }
                
                Map_Supporting_Doc__c objMapSupportingDoc = new Map_Supporting_Doc__c();
                objMapSupportingDoc = [Select Id, Supplier_Buyer_Map__c, Document_Type__c from Map_Supporting_Doc__c where Id =: jsonBody.MapSupportingDocId];
                
                Invoice_finance_deal__c objInvoice = new Invoice_finance_deal__c();
                objInvoice = [Select Id , Supplier_Buyer_Map__c from invoice_finance_deal__c where Id =: jsonBody.InvoiceId];
                
                if(objMapSupportingDoc.Supplier_Buyer_Map__c != objInvoice.Supplier_Buyer_Map__c){
                    return new GlobalMethods_v9.InvoiceDocReturnClass('True', 'Invoice Supporting Doc can not created as Supplier Buyer Map for Invoice and Map Supporting Doc is different.', null);
                }
                
                Invoice_supporting_documents__c objInvSupportingDoc = new Invoice_supporting_documents__c();
                objInvSupportingDoc.Invoice_Finance_deal__c = jsonBody.InvoiceId;
                objInvSupportingDoc.Map_Supporting_Doc__c = jsonBody.MapSupportingDocId;
                insert objInvSupportingDoc;
                
                Attachment objAttachment = new Attachment();
                objAttachment.ParentId = objInvSupportingDoc.Id;
                objAttachment.body = jsonBody.File;
                objAttachment.Name = jsonBody.FileName;
                insert objAttachment;
                
                objInvSupportingDoc.Attachment_URL__c = GlobalTriggerHandler.getBaseUrl() + objAttachment.Id;
                update objInvSupportingDoc;

                GlobalTriggerHandler.setConfig('Marketplace_Cached_Invoice_Supporting_Doc_Str', invoiceDocHashStr);
                
                return new GlobalMethods_v9.InvoiceDocReturnClass('True', 'Invoice Supporting Doc Created', objInvSupportingDoc);
                
            }else if(jsonBody.InvoiceId == null || jsonBody.InvoiceId == ''){
                return new GlobalMethods_v9.InvoiceDocReturnClass('False', 'InvoiceId is Null', Null);
            }else if(jsonBody.MapSupportingDocId == null || jsonBody.MapSupportingDocId == ''){
                return new GlobalMethods_v9.InvoiceDocReturnClass('False', 'MapSupportingDocId is Null', Null);
            }else if(jsonBody.FileName == null || jsonBody.FileName == ''){
                return new GlobalMethods_v9.InvoiceDocReturnClass('False', 'FileName is Null', Null);
            }else if(jsonBody.File == null){
                return new GlobalMethods_v9.InvoiceDocReturnClass('False', 'File is Null', Null);
            }
            
            
        }Catch(Exception ee){
        }
        return new GlobalMethods_v9.InvoiceDocReturnClass('False', 'Invoice Supporting Doc Not Created', Null);
    }
    
    
    public class fromJSON{
        public String InvoiceId;    
        public String MapSupportingDocId;  
        Public String FileName; 
        public Blob  File; 
        public fromJSON parse(String json){
            return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
        }
        
    }
}