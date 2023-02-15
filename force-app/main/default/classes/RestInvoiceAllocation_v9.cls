@RestResource(urlMapping='/v9/invoiceallocation')

global class RestInvoiceAllocation_v9 {
    global static integer v_bidAmount = 0;
    global static integer v_errorLoopCount = 0;
    global static integer v_partialLoopCount = 0;
    global static integer v_generalLoopCount = 0;
    global static String v_email;
    global static String v_ipAddress;
    global static map<String,Decimal> v_result = new Map<String,Decimal>();
     
    @HttpPost
    global static GlobalMethods_v9.DecimalMapReturnClass doPost(Id p_invoiceId, integer p_amount, boolean p_acceptPartialBid, String p_confirmationReceipt) {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        boolean v_partialbidStatus = false;
        v_bidAmount = p_amount;
        String v_notes = '';
        Id v_userAccountId;
        Id v_userContactId;
        
        double v_maxAmount;
        double v_availableEwallet;
        GlobalMethods_v9.InvoiceReturnClass v_invoiceDataResult;
        Invoice_Finance_Deal__c v_invoiceData;
        GlobalMethods_v9.ContactReturnClass v_userDataResult;
        Contact v_userData;
        map<String,String> v_headers = new map<String,String>();   
        v_headers = req.headers;
        if(v_email == null && v_ipAddress == null) {
            v_email = v_headers.get('email');
            v_ipAddress = v_headers.get('ip');
        }
       
        try {
            v_userDataResult = GlobalMethods_v9.getLoggedinUserData(v_email); 
            v_userData = v_userDataResult.v_records;
            v_userAccountId = v_userData.Account.Id;
            v_userContactId = v_userData.Id;
        } catch(GeneralException e) {
            return new GlobalMethods_v9.DecimalMapReturnClass('false',e.getMessage(), null);
        }    
        
        v_invoiceDataResult = GlobalMethods_v9.getInvoiceData(p_invoiceId);
        if(v_invoiceDataResult.v_success == 'false') {
            return new GlobalMethods_v9.DecimalMapReturnClass('false', 'Invalid invoice Id', null);
        }
        v_invoiceData = v_invoiceDataResult.v_records;
         try {
            v_availableEwallet = GlobalMethods_v9.getAvailableEwallet(v_userAccountId, v_invoiceData.CCY__c);
        } catch(GeneralException e) {
            return new GlobalMethods_v9.DecimalMapReturnClass('false',e.getMessage(), null);
        } 
                                
        v_result = GlobalMethods_v9.createAllocationResponse(v_availableEwallet, v_invoiceData, p_amount);
            
        if(Approval.isLocked(p_invoiceId) == false) {
                
            Approval.lock(p_invoiceId);  
                               
            if((v_userData.Account.Type == 'Customer') && (v_userData.Account.Sub_type__c == 'Purchaser')) {
                   
                if(v_invoiceData.Phase__c == '2:ON MARKETPLACE' && v_invoiceData.auto_status__c == 'On marketplace') {
                        
                   
                       
                    if(p_amount > v_availableEwallet) {
                        Approval.unlock(p_invoiceId, true);
                        GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus,'amount greater than ewallet', v_bidAmount);
                        GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount,'false', system.now(), v_partialbidStatus, v_bidAmount);
                        return new GlobalMethods_v9.DecimalMapReturnClass('false', 'You do not have enough ewallet balance', v_result);
                    }
                    
                    if(v_invoiceData.remaining_amount__c == 0) {
                        Approval.unlock(p_invoiceId, true);
                        GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus,'remaining amount = 0', v_bidAmount);
                        GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus , v_bidAmount);
                        return new GlobalMethods_v9.DecimalMapReturnClass('false', 'Reservation for this invoice is full', v_result);
                     }
         
                     if(p_amount == null || p_amount <= 0) {
                        Approval.unlock(p_invoiceId, true);
                        GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus,'amount is 0 -ve or null', v_bidAmount);
                        GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus, v_bidAmount);
                        return new GlobalMethods_v9.DecimalMapReturnClass('false','Invalid amount', v_result);
                     }
         
                     v_maxAmount = v_invoiceData.MAX_bid_amount__c;
                     if(v_maxAmount == null) {
                        v_maxAmount = v_invoiceData.remaining_amount__c;
                     }
                     if(v_maxAmount < v_invoiceData.Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c){
                        v_maxAmount = v_invoiceData.Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c;
                     } 
         
                     double v_minAmount = v_invoiceData.Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c;
                     if((v_invoiceData.remaining_amount__c - v_minAmount) < v_minAmount) {
                         v_minAmount = v_invoiceData.remaining_amount__c;
                     }
               
                    if(p_amount > v_invoiceData.remaining_amount__c && p_acceptPartialBid == true) {
                        v_notes = 'Partial Bid \n Requested amount: '+p_amount+'\n Reservation amount: '+v_invoiceData.remaining_amount__c;
                        v_partialbidStatus = true;
                        p_amount = v_invoiceData.remaining_amount__c.intvalue();
                        
                    }else if(p_amount > v_invoiceData.remaining_amount__c && p_acceptPartialBid == false) {
                        Approval.unlock(p_invoiceId, true);
                        GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus,'amount > remaining amount and accept partial is false', v_bidAmount);
                        GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus, v_bidAmount);
                        return new GlobalMethods_v9.DecimalMapReturnClass('false', 'Requested reservation amount is not available', v_result);
                    }      
                    if(p_amount > v_maxAmount) {
                        Approval.unlock(p_invoiceId, true);
                        GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus,'amount > max amount', v_bidAmount);
                        GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus, v_bidAmount);
                        return new GlobalMethods_v9.DecimalMapReturnClass('false', 'Reservation amount should be less than maximum amount', v_result);  
                    }  
                
                    if(p_amount < v_minAmount) {
                        Approval.unlock(p_invoiceId, true);
                        GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus,'amount < minAmount', v_bidAmount);
                        GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus, v_bidAmount);
                        return new GlobalMethods_v9.DecimalMapReturnClass('false', 'Reservation amount should be greater than minimum amount', v_result); 
                    }
                    
                    if(((v_invoiceData.remaining_amount__c - p_amount ) > 0 ) && ((v_invoiceData.remaining_amount__c - p_amount) < v_minAmount)) {
                        Approval.unlock(p_invoiceId, true);
                        GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus,'would leave less than min amount', v_bidAmount);
                        GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus, v_bidAmount);
                        return new GlobalMethods_v9.DecimalMapReturnClass('false', 'The minimum reservation for this marketplace is '+v_invoiceData.marketplace_currency_symbol__c+' '+v_minAmount+'. A reservation can not leave less than the market place minimum.', v_result);
                    }
                    
                    ID v_ewalletId = eWallet.lookup(v_invoiceData.CCY__c, v_userAccountId);
                    p_confirmationReceipt = p_confirmationReceipt+' Logged in user IP address : '+v_ipAddress+'\n'+
                    'Allocation date : '+String.valueOf(system.now()); 
                    
                    Invoice_Allocation__c v_alloc = new Invoice_Allocation__c ();
            
                    datetime v_now  = system.now();
                            
                    v_alloc.Funder__c = v_userAccountId;
                    v_alloc.Invoice__c = p_invoiceId;
                    v_alloc.Allocation_Reservation_date__c = v_now;
                    v_alloc.amount__c = p_amount;
                    v_alloc.CCY__c = v_invoiceData.CCY__c;
                    v_alloc.Status__c = 'Reservation';
                    v_alloc.Notes__c = v_notes;
                    v_alloc.Funder_confirmation_receipt__c = p_confirmationReceipt;
                    v_alloc.eWallet__c = v_ewalletId;
                    
                    try {
                        insert v_alloc;
                        v_invoiceDataResult = GlobalMethods_v9.getInvoiceData(p_invoiceId);
                        v_invoiceData = v_invoiceDataResult.v_records;
                        v_availableEwallet = GlobalMethods_v9.getAvailableEwallet(v_userAccountId, v_invoiceData.CCY__c);
                        v_result = GlobalMethods_v9.createAllocationResponse(v_availableEwallet, v_invoiceData, p_amount);
                        GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'true', v_alloc.Allocation_Reservation_date__c, v_partialbidStatus,'', v_bidAmount);
                        GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount, 'true', v_alloc.Allocation_Reservation_date__c, v_partialbidStatus, v_bidAmount);
                        Approval.unlock(p_invoiceId, true);
                        return new GlobalMethods_v9.DecimalMapReturnClass('true', 'Reservation is accepted', v_result);
                    }catch (System.QueryException e) {
                        Approval.unlock(p_invoiceId, true);
                        if(v_errorLoopCount == 2){
                            v_errorLoopCount = 0;
                            GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus,'looped too many times', v_bidAmount);
                            GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus, v_bidAmount);
                            return new GlobalMethods_v9.DecimalMapReturnClass('false', 'Reservation is not submitted. Please try again', v_result);
                        }else {
                            v_errorLoopCount = v_errorLoopCount+1;
                            GlobalMethods_v9.DecimalMapReturnClass resp =  doPost(p_invoiceId, p_amount, p_acceptPartialBid, p_confirmationReceipt);
                            return resp;
                        }
                    }catch (System.DmlException e) {
                        Approval.unlock(p_invoiceId, true);
                        if(v_partialLoopCount == 2){
                            v_partialLoopCount = 0;
                            GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus,e.getDmlMessage(0), v_bidAmount);
                            GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus, v_bidAmount);
                            return new GlobalMethods_v9.DecimalMapReturnClass('false', e.getDmlMessage(0), v_result);
                        }else {
                            v_partialLoopCount = v_partialLoopCount+1;
                            GlobalMethods_v9.DecimalMapReturnClass resp =  doPost(p_invoiceId, p_amount, p_acceptPartialBid, p_confirmationReceipt);
                            return resp;
                        }
                    }catch (System.Exception e) {
                        Approval.unlock(p_invoiceId, true);
                        if(v_generalLoopCount == 2){
                            v_generalLoopCount = 0;
                            GlobalMethods_v9.sendReservationSlack(v_userData.Account.Name, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus,e.getMessage(), v_bidAmount);
                            GlobalMethods_v9.createReservationLog(v_userContactId, p_invoiceId, p_amount, 'false', system.now(), v_partialbidStatus, v_bidAmount);
                            return new GlobalMethods_v9.DecimalMapReturnClass('false', e.getMessage(), v_result);
                        }else {
                            v_generalLoopCount = v_generalLoopCount+1;
                            GlobalMethods_v9.DecimalMapReturnClass resp =  doPost(p_invoiceId, p_amount, p_acceptPartialBid, p_confirmationReceipt);
                            return resp;
                        }
                    }
                    
                    
                }else {
                    Approval.unlock(p_invoiceId, true);
                    return new GlobalMethods_v9.DecimalMapReturnClass('false', 'Reservation for this invoice is full', v_result);
                }
                    
            }else {
                Approval.unlock(p_invoiceId, true);
                return new GlobalMethods_v9.DecimalMapReturnClass('false', 'Invalid user', v_result);
             }
                
        }else {                
            return new GlobalMethods_v9.DecimalMapReturnClass('false', 'Reservation is in progress. Please try after sometime', v_result);
        } 
              
    }
          
}