@RestResource(urlMapping='/v1/invoice/invoiceAllocation')

global class RestReceiveBid_v1 {
    global static double bidAmount = 0;
    global static integer errorLoopCount = 0;
    global static integer partialLoopCount = 0;
    global static integer generalLoopCount = 0;
     
    @HttpPost
    global static ReturnClass doPost(id invoiceId, id userId, double amount, boolean acceptPartialBid, id contactId) {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        boolean partialbidStatus = false;
        bidAmount = amount;
        map<String,Decimal> result = new Map<String,Decimal>();
        double maxAmount;
        double availableEwallet;
                        
        if(RestUserLogin.isValidId(invoiceId) == false) {
        
            return new ReturnClass('false','Invalid invoice ID', null);
        }
        
        try {
    
            Invoice_Finance_Deal__c invoiceData = [SELECT Id, Invoice_name__c, MAX_bid_amount__c, bid_in_progress__c, funded_amount__c, auto_status__c, Phase__c, remaining_amount__c, CCY__c, marketplace_currency_symbol__c, requested_amount__c, Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :invoiceId LIMIT 1];
            if(RestUserLogin.isValidId(userId) == false) {
                    return new ReturnClass('false','Invalid user ID', null);
            }
            Account userData = validateUserNew(userId);
            result = createResponse(userData, invoiceData, amount);
            
            if(Approval.isLocked(invoiceId) == false) {
                
                Approval.lock(invoiceId);  
                      
                if(RestUserLogin.isValidId(userId) == false) {
                    Approval.unlock(invoiceId, true);
                    return new ReturnClass('false','Invalid user ID', null);
                }
                if(amount <= 0) {
                    Approval.unlock(invoiceId, true);
                    return new ReturnClass('false','Invalid amount', result);
                }
                
                if((userData.Type == 'Customer') && (userData.Sub_type__c == 'Purchaser')) {
                    
                    if(invoiceData.Phase__c == '2:ON MARKETPLACE' && invoiceData.auto_status__c == 'On marketplace') {
                        
                        if(invoiceData.CCY__c == 'USD') {
                            availableEwallet = userData.USD_Available_eWallet__c;
                        }else if(invoiceData.CCY__c == 'SGD') {
                            availableEwallet = userData.SGD_Available_eWallet__c;
                        }else if(invoiceData.CCY__c == 'HKD') {
                            availableEwallet = userData.HKD_Available_eWallet__c;
                        }else if(invoiceData.CCY__c == 'EUR') {
                            availableEwallet = userData.EUR_available_eWallet__c;
                        }else if(invoiceData.CCY__c == 'XXX') {
                            availableEwallet = userData.XXX_available_eWallet__c;
                        }
                       
                        if(amount > availableEwallet) {
                            Approval.unlock(invoiceId, true);
                            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus);
                            createBidLog(contactId, invoiceId, amount,'false', system.now(), partialbidStatus);
                            return new ReturnClass('false', 'You do not have enough ewallet balance', result);
                        }
                        
                        ReturnClass finalResult =  insertBid(invoiceId, userId, amount, acceptPartialBid, invoiceData, userData, contactId);
                        Approval.unlock(invoiceId, true);
                       
                        return new ReturnClass(finalResult.success, finalResult.message, finalResult.records);
                    
                    }else {
                        Approval.unlock(invoiceId, true);
                        return new ReturnClass('false', 'Reservation for this invoice is full', result);
                    }
                    
                }else {
                    Approval.unlock(invoiceId, true);
                    return new ReturnClass('false', 'Invalid user', result);
                }
                
            }else {                
                return new ReturnClass('false', 'Reservation is in progress. Please try after sometime', result);
            }
        }
        catch (System.QueryException e) {
                return new ReturnClass('false', 'Invalid invoice Id', null);
        }
                
        
    }
    
    global static ReturnClass insertBid(id invoiceId, id userId, double amount, boolean acceptPartialBid, Invoice_Finance_Deal__c invoiceData, Account userData, id contactId) {
        
        String notes = '';
        boolean partialbidStatus = false;
        map<String,Decimal> result1 = createResponse(userData, invoiceData, amount);
        if(invoiceData.remaining_amount__c == 0) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus);
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false', 'Reservation for this invoice is full', result1);
         }
         
         if(amount == null || amount <= 0) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus);
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false','Invalid amount', result1);
         }
         
         double maxAmount = invoiceData.MAX_bid_amount__c;
         if(maxAmount == null) {
            maxAmount = invoiceData.remaining_amount__c;
         }
         if(maxAmount < invoiceData.Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c){
            maxAmount = invoiceData.Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c;
         } 
         
         double minAmount = invoiceData.Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c;
         if((invoiceData.remaining_amount__c - minAmount) < minAmount) {
             minAmount = invoiceData.remaining_amount__c;
         }
               
        if(amount > invoiceData.remaining_amount__c && acceptPartialBid == true) {
            notes = 'Partial Bid \n Requested amount: '+amount+'\n Reservation amount: '+invoiceData.remaining_amount__c;
            partialbidStatus = true;
            amount = invoiceData.remaining_amount__c;
            
        }else if(amount > invoiceData.remaining_amount__c && acceptPartialBid == false) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus);
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false', 'Requested reservation amount is not available', result1);
        }      
               
        if(amount > maxAmount) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus);
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false', 'Reservation amount should be less than maximum amount', result1);  
        }  
                
        if(amount < minAmount) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus);
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false', 'Reservation amount should be greater than minimum amount', result1); 
        }
        
        if(((invoiceData.remaining_amount__c - amount ) > 0 ) && ((invoiceData.remaining_amount__c - amount) < minAmount)) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus);
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false', 'The minimum reservation for this marketplace is '+invoiceData.marketplace_currency_symbol__c+minAmount+'. A bid can not leave less than the market place minimum.', result1);
         }
         
        Invoice_Allocation__c alloc = new Invoice_Allocation__c ();
            
        datetime now  = system.now();
                
        alloc.Funder__c = userId;
        alloc.Invoice__c = invoiceId;
        alloc.Allocation_Reservation_date__c = now;
        alloc.amount__c = amount;
        alloc.CCY__c = invoiceData.CCY__c;
        alloc.Status__c = 'Reservation';
        alloc.Notes__c = notes;
        try {
           insert alloc;
           Invoice_Finance_Deal__c invoiceDetails = [SELECT Id, funded_amount__c, remaining_amount__c, CCY__c, requested_amount__c, Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :invoiceId LIMIT 1];
           Account userDataNew = validateUserNew(userId);
           map<String,Decimal> result2 = createResponse(userDataNew, invoiceDetails, amount);
           sendSlackBid(userData.name, invoiceId, amount, 'true', alloc.Allocation_Reservation_date__c, partialbidStatus);
           createBidLog(contactId, invoiceId, amount, 'true', alloc.Allocation_Reservation_date__c, partialbidStatus);
           return new ReturnClass('true', 'Reservation is accepted', result2);
        }catch (System.QueryException e) {
            Approval.unlock(invoiceId, true);
            if(errorLoopCount == 2){
                errorLoopCount = 0;
                sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus);
                createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
                return new ReturnClass('false', 'Reservation is not submitted. Please try again', result1);
            }else {
                errorLoopCount = errorLoopCount+1;
                ReturnClass resp =  doPost(invoiceId, userId, amount, acceptPartialBid, contactId);
                return resp;
            }
        }catch (System.DmlException e) {
            Approval.unlock(invoiceId, true);
            if(partialLoopCount == 2){
                partialLoopCount = 0;
                sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus);
                createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
                return new ReturnClass('false', e.getDmlMessage(0), result1);
            }else {
                partialLoopCount = partialLoopCount+1;
                ReturnClass resp =  doPost(invoiceId, userId, amount, acceptPartialBid, contactId);
                return resp;
            }
        }catch (System.Exception e) {
            Approval.unlock(invoiceId, true);
            if(generalLoopCount == 2){
                generalLoopCount = 0;
                sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus);
                createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
                return new ReturnClass('false', e.getDmlMessage(0), result1);
            }else {
                generalLoopCount = generalLoopCount+1;
                ReturnClass resp =  doPost(invoiceId, userId, amount, acceptPartialBid, contactId);
                return resp;
            }
        }
        
    }
    
    global static void sleep(Long milliSeconds) {
            Long timeDiff = 0;
            DateTime firstTime = System.now();
            do
            {
                timeDiff = System.now().getTime() - firstTime.getTime();
            }
            while(timeDiff <= milliSeconds);
    }
    
    global static void sendSlackBid(String name, Id invoiceId, double amount, string status, datetime now, boolean partialbidStatus) {
        
        Invoice_Finance_Deal__c invoiceData = [SELECT Id, Invoice_name__c, MAX_bid_amount__c, bid_in_progress__c, funded_amount__c, auto_status__c, Phase__c, remaining_amount__c, CCY__c, marketplace_currency_symbol__c, requested_amount__c, Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :invoiceId LIMIT 1];
        
        Integer remAmountInt = invoiceData.remaining_amount__c.intvalue();
        String currencySymbol = invoiceData.marketplace_currency_symbol__c;
        String invoiceName = invoiceData.Invoice_name__c;
        
        String message = '';
        Integer amountInt = amount.intvalue();
        Integer bidAmountInt = bidAmount.intvalue();
        String bidDate = now.format('HH:mm:ss');
        if(status == 'true' && partialbidStatus == true) {
            message = 'Deal: '+invoiceName+ ' @ ' +bidDate+' - '+name+' attempted to place a reservation of '+currencySymbol+' '+bidAmountInt+'. Partial reservation of '+currencySymbol+' '+amountInt+' was successfully placed. Remaining amount is '+currencySymbol+' '+remAmountInt;
        }else if(status == 'true') {
            message = 'Deal: '+invoiceName+ ' @ ' +bidDate+' - '+name+' successfully placed reservation of '+currencySymbol+' '+amountInt+'. Remaining amount is '+currencySymbol+' '+remAmountInt;
        }else{
            message = 'Failed: '+invoiceName+ ' @ ' +bidDate+' - '+name+' failed reservation of '+currencySymbol+' '+amountInt+'. Remaining amount is '+currencySymbol+' '+remAmountInt;
        }
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        string url;
        if(baseUrl == 'https://incomlend.my.salesforce.com') {
            url = 'https://hooks.slack.com/services/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'; 
        }else {
            url = 'https://hooks.slack.com/services/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'; 
        }       
        SendSlackMessage.send(url, message);
    }
    
    global static void createBidLog(Id contactId, Id invoiceId, double amount, String status, datetime now, boolean partialbidStatus) {
        
        if(contactId != null) {
            
            Invoice_Finance_Deal__c invoiceData = [SELECT Id, Invoice_name__c, MAX_bid_amount__c, bid_in_progress__c, funded_amount__c, auto_status__c, Phase__c, remaining_amount__c, CCY__c, marketplace_currency_symbol__c, requested_amount__c, Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :invoiceId LIMIT 1];
            
            String bidStatus;
            if(status == 'true') {
                bidStatus = 'Success';
            }else {
                bidStatus = 'Failed';
            }
            Integer amountInt = amount.intvalue();
            Integer remAmountInt = invoiceData.remaining_amount__c.intvalue();
            String currencySymbol = invoiceData.marketplace_currency_symbol__c;
            Integer bidAmountInt = bidAmount.intvalue();
            contact_log__c newlog = new contact_log__c();
            newlog.date__c = System.now();
            newlog.contact__c = contactId;
            newlog.action__C = 'Bid';
            newlog.Invoice_Finance_Deal__c = invoiceId;
            newlog.extra_info__C = 'Status = ' + bidStatus +'; Attempted amount = '+currencySymbol+' '+ bidAmountInt+'; Reservation amount = '+currencySymbol+' '+ amountInt + '; Remaining amount = '+currencySymbol+' '+remAmountInt+'; Partial bid: '+partialbidStatus+'; Time = '+now;
            insert newLog;
        }
    }
    
    global static map<String,Decimal> createResponse(Account userData, Invoice_Finance_Deal__c invoiceData, double amount) {
            map<String,Decimal> resp = new Map<String,Decimal>();
            resp.put('usd_available_eWallet', (Decimal)(userData.USD_Available_eWallet__c));
            resp.put('sgd_available_eWallet', (Decimal)(userData.SGD_Available_eWallet__c));
            resp.put('hkd_available_eWallet', (Decimal)(userData.HKD_Available_eWallet__c));
            resp.put('eur_available_eWallet', (Decimal)(userData.EUR_available_eWallet__c));
            resp.put('xxx_available_eWallet', (Decimal)(userData.XXX_Available_eWallet__c));
            resp.put('remaining_amount', (Decimal)(invoiceData.remaining_amount__c));
            resp.put('reservation_amount', (Decimal)(amount));
            resp.put('funded_Amount', (Decimal)(invoiceData.funded_amount__c));
            
            return resp;
    }
    
    global static Account validateUserNew(id userId) {
        
        Account result = new Account();
        
        try {
          result = [SELECT Id, Name, Primary_Contact__r.Id,  Type, Sub_type__c, XXX_Available_eWallet__c, EUR_available_eWallet__c, USD_Available_eWallet__c, SGD_Available_eWallet__c, HKD_Available_eWallet__c FROM Account WHERE Id = :userId];
          return result;
    
        } catch (Exception e) {
          return result;
        }
    
    }
            
    global class ReturnClass {

        global String success;
        global String message;
        global map<String,Decimal> records;

        global ReturnClass(String success, String message, map<String,Decimal> records) {
          this.success = success;
          this.message = message;
          this.records = records;
        }

    }
          
}