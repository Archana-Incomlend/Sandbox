@RestResource(urlMapping='/v8/invoice/invoiceAllocation')

global class RestReceiveBid_v8 {
    global static integer bidAmount = 0;
    global static integer errorLoopCount = 0;
    global static integer partialLoopCount = 0;
    global static integer generalLoopCount = 0;
    global static String ipAddress;
     
    @HttpPost
    global static ReturnClass doPost(id invoiceId, id userId, integer amount, boolean acceptPartialBid, id contactId, String confirmationReceipt) {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        boolean partialbidStatus = false;
        bidAmount = amount;
        map<String,Decimal> result = new Map<String,Decimal>();
        double maxAmount;
        double availableEwallet;
        map<String,String> headers = new map<String,String>();   
        headers = req.headers;
        String email = headers.get('email');
        ipAddress = headers.get('ip');
                                
        try {
    
            Invoice_Finance_Deal__c invoiceData = [SELECT Id, Invoice_name__c, MAX_bid_amount__c, bid_in_progress__c, funded_amount__c, auto_status__c, Phase__c, remaining_amount__c, CCY__c, marketplace_currency_symbol__c, requested_amount__c, Marketplace_link__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :invoiceId LIMIT 1];
                      
            Account userData = validateUserNew(userId);
            result = createResponse(userData, invoiceData, amount);
            
            if(Approval.isLocked(invoiceId) == false) {
                
                Approval.lock(invoiceId);  
                                      
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
                            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus,'amount greater than ewallet');
                            createBidLog(contactId, invoiceId, amount,'false', system.now(), partialbidStatus);
                            return new ReturnClass('false', 'You do not have enough ewallet balance.  (amount : ' + invoiceData.CCY__c +' '+ amount + '. Your balance : ' + availableEwallet +')' , result);
                        }
                        
                        ReturnClass finalResult =  insertBid(invoiceId, userId, amount, acceptPartialBid, invoiceData, userData, contactId, confirmationReceipt);
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
    
    global static ReturnClass insertBid(id invoiceId, id userId, integer amount, boolean acceptPartialBid, Invoice_Finance_Deal__c invoiceData, Account userData, id contactId, String confirmationReceipt) {
        
        String notes = '';
        boolean partialbidStatus = false;
        map<String,Decimal> result1 = createResponse(userData, invoiceData, amount);
        if(invoiceData.remaining_amount__c == 0) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus,'remaining amount = 0');
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false', 'Reservation for this invoice is full', result1);
         }
         
         if(amount == null || amount <= 0) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus,'amount is 0 -ve or null');
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false','Invalid amount', result1);
         }
         
         double maxAmount = invoiceData.MAX_bid_amount__c;
         if(maxAmount == null) {
            maxAmount = invoiceData.remaining_amount__c;
         }
         if(maxAmount < invoiceData.Marketplace_link__r.minimum_purchase_amount__c){
            maxAmount = invoiceData.Marketplace_link__r.minimum_purchase_amount__c;
         } 
         
         double minAmount = invoiceData.Marketplace_link__r.minimum_purchase_amount__c;
         if((invoiceData.remaining_amount__c - minAmount) < minAmount) {
             minAmount = invoiceData.remaining_amount__c;
         }
               
        if(amount > invoiceData.remaining_amount__c && acceptPartialBid == true) {
            notes = 'Partial Bid \n Requested amount: '+amount+'\n Reservation amount: '+invoiceData.remaining_amount__c;
            partialbidStatus = true;
            amount = invoiceData.remaining_amount__c.intvalue();
            
        }else if(amount > invoiceData.remaining_amount__c && acceptPartialBid == false) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus,'amount > remaining amount and accept partial is false');
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false', 'Requested reservation amount is not available', result1);
        }      
        if(amount > maxAmount) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus,'amount > max amount');
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false', 'Reservation amount should be less than maximum amount', result1);  
        }  
                
        if(amount < minAmount) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus,'amount < minAmount');
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false', 'Reservation amount should be greater than minimum amount which is ' + minAmount, result1); 
        }
        
        if(((invoiceData.remaining_amount__c - amount ) > 0 ) && ((invoiceData.remaining_amount__c - amount) < minAmount)) {
            Approval.unlock(invoiceId, true);
            sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus,'would leave less than min amount');
            createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
            return new ReturnClass('false', 'The minimum reservation for this marketplace is '+invoiceData.marketplace_currency_symbol__c+minAmount+'. A bid can not leave less than the market place minimum.', result1);
        }
        
        ID ewalletId = eWallet.lookup(invoiceData.CCY__c, userId);
         
        Invoice_Allocation__c alloc = new Invoice_Allocation__c ();
            
        datetime now  = system.now();
        confirmationReceipt = confirmationReceipt+'Logged in user IP address : '+ipAddress+'\n'+
                    'Allocation date : '+String.valueOf(system.now()); 
                
        alloc.Funder__c = userId;
        alloc.Invoice__c = invoiceId;
        alloc.Allocation_Reservation_date__c = now;
        alloc.amount__c = amount;
        alloc.CCY__c = invoiceData.CCY__c;
        alloc.Status__c = 'Reservation';
        alloc.Notes__c = notes;
        alloc.Funder_confirmation_receipt__c = confirmationReceipt;
        alloc.eWallet__c = ewalletId;
        
        try {
           insert alloc;
           Invoice_Finance_Deal__c invoiceDetails = [SELECT Id, funded_amount__c, remaining_amount__c, CCY__c, requested_amount__c, Marketplace_link__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :invoiceId LIMIT 1];
           Account userDataNew = validateUserNew(userId);
           map<String,Decimal> result2 = createResponse(userDataNew, invoiceDetails, amount);
           sendSlackBid(userData.name, invoiceId, amount, 'true', alloc.Allocation_Reservation_date__c, partialbidStatus,'');
           createBidLog(contactId, invoiceId, amount, 'true', alloc.Allocation_Reservation_date__c, partialbidStatus);
           return new ReturnClass('true', 'Reservation is accepted', result2);
        }catch (System.QueryException e) {
            Approval.unlock(invoiceId, true);
            if(errorLoopCount == 2){
                errorLoopCount = 0;
                sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus,'looped too many times');
                createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
                return new ReturnClass('false', 'Reservation is not submitted. Please try again', result1);
            }else {
                errorLoopCount = errorLoopCount+1;
                ReturnClass resp =  doPost(invoiceId, userId, amount, acceptPartialBid, contactId, confirmationReceipt);
                return resp;
            }
        }catch (System.DmlException e) {
            Approval.unlock(invoiceId, true);
            if(partialLoopCount == 2){
                partialLoopCount = 0;
                sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus,e.getDmlMessage(0));
                createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
                return new ReturnClass('false', e.getDmlMessage(0), result1);
            }else {
                partialLoopCount = partialLoopCount+1;
                ReturnClass resp =  doPost(invoiceId, userId, amount, acceptPartialBid, contactId, confirmationReceipt);
                return resp;
            }
        }catch (System.Exception e) {
            Approval.unlock(invoiceId, true);
            if(generalLoopCount == 2){
                generalLoopCount = 0;
                sendSlackBid(userData.name, invoiceId, amount, 'false', system.now(), partialbidStatus,e.getDmlMessage(0));
                createBidLog(contactId, invoiceId, amount, 'false', system.now(), partialbidStatus);
                return new ReturnClass('false', e.getDmlMessage(0), result1);
            }else {
                generalLoopCount = generalLoopCount+1;
                ReturnClass resp =  doPost(invoiceId, userId, amount, acceptPartialBid, contactId, confirmationReceipt);
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
    
   global static void sendSlackBid(String name, Id invoiceId, integer amount, string status, datetime now, boolean partialbidStatus, string reason) {
        
        Invoice_Finance_Deal__c invoiceData = [SELECT Id, Invoice_name__c, MAX_bid_amount__c, bid_in_progress__c, funded_amount__c, auto_status__c, Phase__c, remaining_amount__c, CCY__c, marketplace_currency_symbol__c, requested_amount__c, Marketplace_link__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :invoiceId LIMIT 1];
        
        Integer remAmountInt = invoiceData.remaining_amount__c.intvalue();
        String currencySymbol = invoiceData.marketplace_currency_symbol__c;
        String invoiceName = invoiceData.Invoice_name__c;
        
        String message = '';
        
        String bidDate = now.format('HH:mm:ss');
        if(status == 'true' && partialbidStatus == true) {
            message = 'Deal: '+invoiceName+ ' @ ' +bidDate+' - '+name+' attempted to place a reservation of '+currencySymbol+' '+bidAmount+'. Partial reservation of '+currencySymbol+' '+amount+' was successfully placed. Remaining amount is '+currencySymbol+' '+remAmountInt;
            if (remAmountInt == 0)
                    {
                    message = message + '\n*' + invoiceName + ' has been sold :champagne:*';                    
                    }
        }else if(status == 'true') {
            message = 'Deal: '+invoiceName+ ' @ ' +bidDate+' - '+name+' successfully placed reservation of '+currencySymbol+' '+amount+'. Remaining amount is '+currencySymbol+' '+remAmountInt;
        }else{
            message = 'Failed: '+invoiceName+ ' @ ' +bidDate+' - '+name+' failed reservation of '+currencySymbol+' '+amount+'. Remaining amount is '+currencySymbol+' '+remAmountInt + '. Fail Reason : ' + reason + ':hankey::hankey::hankey::hankey:';
        }
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        string url;
        if(baseUrl == 'https://incomlend.my.salesforce.com') {
            url = config.getConfig('live slack channel url'); 
        }else {
            url = config.getConfig('dev slack channel url'); 
        }       
        SendSlackMessage.send(url, message);
    }
    
    global static void createBidLog(Id contactId, Id invoiceId, integer amount, String status, datetime now, boolean partialbidStatus) {
        
        if(contactId != null) {
            
            Invoice_Finance_Deal__c invoiceData = [SELECT Id, Invoice_name__c, MAX_bid_amount__c, bid_in_progress__c, funded_amount__c, auto_status__c, Phase__c, remaining_amount__c, CCY__c, marketplace_currency_symbol__c, requested_amount__c, Marketplace_link__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :invoiceId LIMIT 1];
            
            String bidStatus;
            if(status == 'true') {
                bidStatus = 'Success';
            }else {
                bidStatus = 'Failed';
            }
            
            Integer remAmountInt = invoiceData.remaining_amount__c.intvalue();
            String currencySymbol = invoiceData.marketplace_currency_symbol__c;
            
            contact_log__c newlog = new contact_log__c();
            newlog.date__c = System.now();
            newlog.contact__c = contactId;
            newlog.action__C = 'Bid';
            newlog.Invoice_Finance_Deal__c = invoiceId;
            newlog.extra_info__C = 'Status = ' + bidStatus +'; Attempted amount = '+currencySymbol+' '+ bidAmount+'; Reservation amount = '+currencySymbol+' '+ amount + '; Remaining amount = '+currencySymbol+' '+remAmountInt+'; Partial bid: '+partialbidStatus+'; Time = '+now;
            insert newLog;
        }
    }
    
    global static map<String,Decimal> createResponse(Account userData, Invoice_Finance_Deal__c invoiceData, integer amount) {
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