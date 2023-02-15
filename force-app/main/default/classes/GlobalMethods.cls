global class GlobalMethods {

    public static ReturnClass validateIsAgentForUserAccount(Id v_agentId, Id v_userAccountId) {
        
        Account[] v_result = [SELECT Agent__c FROM Account WHERE Id = :v_userAccountId];
        
        if (v_result.size() == 0) {
            return new ReturnClass('false','Invalid Account Id');
        }else if(v_result.get(0).Agent__c == v_agentId) {
            return new ReturnClass('true','Correct Agent Id');
        }else {
            return new ReturnClass('false','Invalid Agent Id');
        }
   
    }
        
    global static AccountReturnClass getUserData(id v_userAccountId) {
        List<Account> v_result = new List<Account> ();
        v_result = [SELECT Id, Name, discount_profit_share_percent__c, Primary_Contact__r.Id,  Type, Sub_type__c, XXX_Available_eWallet__c, EUR_available_eWallet__c, USD_Available_eWallet__c, SGD_Available_eWallet__c, HKD_Available_eWallet__c FROM Account WHERE Id = :v_userAccountId];

        if (v_result.size() == 0) {
            return new AccountReturnClass('false','Invalid Account Id', null);
        }else {
            return new AccountReturnClass('true','Query executed successfully.', v_result.get(0));
        }
    }
    
    global static Id getLoggedinUserAccountId(String v_email) {
        if(v_email != null) {
            List<Contact> v_result = new List<Contact> ();
            v_result = [SELECT Id, account.suspended__C ,account.onboarded__c , Name, Account.Id, Account.RecordType.Name, Account.Name, Account.Type, Account.Sub_type__c, Email FROM Contact WHERE facebook_username__c = :v_email OR google_username__c = :v_email OR google_username_support__c = :v_email OR google_username_agent__c = :v_email OR Linkedin_username__c = :v_email limit 1];
    
            if (v_result.size() == 0) {
                throw new GeneralException('Invalid Email Id');
            }else if(v_result.get(0).account.suspended__C == true){
                throw new GeneralException('User is suspended');
            }else {
                return v_result.get(0).Account.Id;
            }
        }else {
            throw new GeneralException('No email id is in header');
        }
       
    }
    
    global static ContactReturnClass getLoggedinUserData(String v_email) {
        if(v_email != null) {
            List<Contact> v_result = new List<Contact> ();
            v_result = [SELECT Id, account.suspended__C ,account.onboarded__c , Name, Account.Id, Account.RecordType.Name, Account.Name, Account.Type, Account.Sub_type__c, Email FROM Contact WHERE facebook_username__c = :v_email OR google_username__c = :v_email OR google_username_support__c = :v_email OR google_username_agent__c = :v_email OR Linkedin_username__c = :v_email limit 1];
    
            if (v_result.size() == 0) {
                throw new GeneralException('Invalid Email Id');
            }else if(v_result.get(0).account.suspended__C == true){
                throw new GeneralException('User is suspended');
            }else {
                return new ContactReturnClass('true','Query executed successfully.', v_result.get(0));
            }
        }else {
            throw new GeneralException('No email id is in header');
        }
       
    }
    
    global static double getAvailableEwallet(Id v_userAccountId, String v_ccy) {
        List<eWallet__c> v_result = new List<eWallet__c> ();
        v_result = [SELECT Id, Available_Balance__c FROM eWallet__c WHERE Account__c = :v_userAccountId AND  CCY__c = :v_ccy];
        
        if (v_result.size() == 0) {
            throw new GeneralException('No eWallet found for this user');
        }else {
            return v_result.get(0).Available_Balance__c;
        }
    }
    
    global static boolean validateUserAccess(Id v_loggedInUserAccountId, Id v_userAccountId) {
        if(v_loggedInUserAccountId == v_userAccountId){
            return true;
        }else {
            List<Account> v_result = new List<Account> ();
            v_result = [SELECT Agent__c, Agent__r.Agent__c FROM Account WHERE Id = :v_userAccountId];
            if ((v_result.size() != 0) && (v_loggedInUserAccountId == v_result.get(0).Agent__c || v_loggedInUserAccountId == v_result.get(0).Agent__r.Agent__c)) {
                return true;
            }else {
                return false;
            }
        }
    }
    
    global static BankAccountReturnClass getBankAccountData(id v_bankAccountId, id v_userAccountId) {
        List<Bank_Account__c> v_result = new List<Bank_Account__c> ();
        v_result = [SELECT Bank_Name__c, Bank_Account_Number__c, Address__c, Beneficiary_Name__c, SWIFT_Code__c, Country__c FROM Bank_Account__c WHERE Account__c = :v_userAccountId AND Id=:v_bankAccountId];

        if (v_result.size() == 0) {
            return new BankAccountReturnClass('false','Invalid bank account Id', null);
        }else {
            return new BankAccountReturnClass('true','Query executed successfully.', v_result.get(0));
        }
    }
    
    global static InvoiceReturnClass getInvoiceData(id v_invoiceId) {
        List<invoice_finance_deal__c> v_result = new List<invoice_finance_deal__c> ();
        v_result = [SELECT Id, Invoice_name__c, MAX_bid_amount__c, bid_in_progress__c, funded_amount__c, auto_status__c, Phase__c, remaining_amount__c, CCY__c, marketplace_currency_symbol__c, requested_amount__c, Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :v_invoiceId];

        if (v_result.size() == 0) {
            return new InvoiceReturnClass('false','Invalid invoice Id', null);
        }else {
            return new InvoiceReturnClass('true','Query executed successfully.', v_result.get(0));
        }
    }
    
    global static AccountReturnClass getUserWalletData(id v_userAccountId) {
        List<Account> v_result = new List<Account> ();
        v_result = [SELECT discount_profit_share_percent__c, EUR_Position__c, HKD_Position__c, SGD_Position__c, USD_Position__c, XXX_Position__c, XXX_Available_eWallet__c, XXX_total_discount_earned__c, XXX_total_reservations__c, XXX_Total_in_progress_invoices__c, XXX_eWallet_Balance__c, Total_in_progress_Invoices_USD_Equiv__c, Total_Position_USD_Equiv__c, EUR_available_eWallet__c, EUR_Total_in_progress_invoices__c, EUR_eWallet_Balance__c, EUR_total_reservations__c, EUR_available_eWallet_USD_Equiv__c, EUR_Total_Discount_Earned__c, Total_eWallet_USD_Equiv__c, USD_Available_eWallet__c, SGD_Available_eWallet__c, HKD_Available_eWallet__c, SGD_total_discount_earned__c, USD_total_discount_earned__c, HKD_total_discount_earned__c, USD_total_reservations__c, SGD_total_reservations__c, HKD_total_reservations__c, HKD_Total_in_progress_invoices__c, USD_Total_in_progress_invoices__c, SGD_Total_in_progress_invoices__c, Total_Available_eWallet_USD_Equiv__c, SGD_Available_eWallet_USD_Equiv__c, HKD_Available_eWallet_USD_Equiv__c, SGD_eWallet_Balance__c, USD_eWallet_Balance__c, HKD_eWallet_Balance__c FROM Account WHERE Id = :v_userAccountId];

        if (v_result.size() == 0) {
            return new AccountReturnClass('false','Invalid Account Id', null);
        }else {
            return new AccountReturnClass('true','Query executed successfully.', v_result.get(0));
        }
    }
    
    global static void addContactLog(Id v_userContactId, Id InvoiceId, String v_action, String v_info, String v_notes) {
        contact_log__c newlog = new contact_log__c();
        newlog.date__c = System.now();
        if(v_userContactId != null) {
            newlog.contact__c = v_userContactId;
        }
        newlog.action__C = v_action;
        newlog.extra_info__C = v_info;
        newlog.Invoice_Finance_Deal__c = InvoiceId;
        newlog.notes__c = v_notes;
        insert newLog;
    }
    
    global static Boolean isValidId(String v_strId) {
        Boolean v_isValid = (v_strId InstanceOf ID) ? true : false ;
        return v_isValid ;
    }
    
    global static Boolean isvalidCurrency(String ccy){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Marketplace__c.Currency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Boolean currencyStatus = false;
        for( Schema.PicklistEntry pickListVal : ple){
            if(ccy == pickListVal.getValue()){
                currencyStatus = true;
            }
        }     
        return currencyStatus;
    }
    
    global static List<String> getPicklistValues(Schema.DescribeFieldResult fieldResult) {
        List<String> pickListValuesList = new List<String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }    
        return pickListValuesList;
    }
    
    global static map<String,Decimal> createAllocationResponse(Double v_availableEwallet, invoice_finance_deal__c v_invoiceData, integer v_amount) {
            map<String,Decimal> resp = new Map<String,Decimal>();
            resp.put('availableEwallet', (Decimal)(v_availableEwallet));
            resp.put('remainingAmount', (Decimal)(v_invoiceData.remaining_amount__c));
            resp.put('reservationAmount', (Decimal)(v_amount));
            resp.put('fundedAmount', (Decimal)(v_invoiceData.funded_amount__c));
            return resp;
    }
    
    global static void sendReservationSlack(String v_name, Id v_invoiceId, integer v_amount, string v_status, datetime v_now, boolean v_partialbidStatus, string v_reason, integer v_bidAmount) {
        
        invoice_finance_deal__c v_invoiceData = [SELECT Id, Invoice_name__c, MAX_bid_amount__c, bid_in_progress__c, funded_amount__c, auto_status__c, Phase__c, remaining_amount__c, CCY__c, marketplace_currency_symbol__c, requested_amount__c, Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :v_invoiceId LIMIT 1];
        
        Integer v_remAmountInt = v_invoiceData.remaining_amount__c.intvalue();
        String v_currencySymbol = v_invoiceData.marketplace_currency_symbol__c;
        String v_invoiceName = v_invoiceData.Invoice_name__c;
        
        String v_message = '';
        
        String v_reservationDate = v_now.format('HH:mm:ss');
        
        if(v_status == 'true' && v_partialbidStatus == true) {
            v_message = 'Deal: '+v_invoiceName+ ' @ ' +v_reservationDate+' - '+v_name+' attempted to place a reservation of '+v_currencySymbol+' '+v_bidAmount+'. Partial reservation of '+v_currencySymbol+' '+v_amount+' was successfully placed. Remaining amount is '+v_currencySymbol+' '+v_remAmountInt;
            if(v_remAmountInt == 0) {
                v_message = v_message + '\n*' + v_invoiceName + ' has been sold :champagne:*';                    
            }
        }else if(v_status == 'true') {
            v_message = 'Deal: '+v_invoiceName+ ' @ ' +v_reservationDate+' - '+v_name+' successfully placed reservation of '+v_currencySymbol+' '+v_amount+'. Remaining amount is '+v_currencySymbol+' '+v_remAmountInt;
        }else{
            v_message = 'Failed: '+v_invoiceName+ ' @ ' +v_reservationDate+' - '+v_name+' failed reservation of '+v_currencySymbol+' '+v_amount+'. Remaining amount is '+v_currencySymbol+' '+v_remAmountInt + '. Fail Reason : ' + v_reason + ':hankey::hankey::hankey::hankey:';
        }
        
        SendSlackMessage.send(config.getConfig('live slack channel url'), v_message);
    }
    
    global static void createReservationLog(Id v_userContactId, Id v_invoiceId, integer v_amount, String v_status, datetime v_now, boolean v_partialbidStatus, integer v_bidAmount) {
        
        if(v_userContactId != null) {
            
            invoice_finance_deal__c v_invoiceData = [SELECT Id, Invoice_name__c, MAX_bid_amount__c, bid_in_progress__c, funded_amount__c, auto_status__c, Phase__c, remaining_amount__c, CCY__c, marketplace_currency_symbol__c, requested_amount__c, Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c FROM invoice_finance_deal__c WHERE Id = :v_invoiceId LIMIT 1];
            
            String v_bidStatus;
            if(v_status == 'true') {
                v_bidStatus = 'Success';
            }else {
                v_bidStatus = 'Failed';
            }
            
            Integer v_remAmountInt = v_invoiceData.remaining_amount__c.intvalue();
            String v_currencySymbol = v_invoiceData.marketplace_currency_symbol__c;
            
            contact_log__c v_newlog = new contact_log__c();
            v_newlog.date__c = System.now();
            v_newlog.contact__c = v_userContactId;
            v_newlog.action__C = 'Bid';
            v_newlog.invoice_finance_deal__c = v_invoiceId;
            v_newlog.extra_info__C = 'Status = ' + v_bidStatus +'; Attempted amount = '+v_currencySymbol+' '+ v_bidAmount+'; Reservation amount = '+v_currencySymbol+' '+ v_amount + '; Remaining amount = '+v_currencySymbol+' '+v_remAmountInt+'; Partial bid: '+v_partialbidStatus+'; Time = '+v_now;
            insert v_newlog;
        }
    }
    
    global static String createMaskedAccountNumber(String v_accountNumber) {
        
        Integer v_numberLength = v_accountNumber.length();
        String v_accountStr;
        if(v_numberLength > 4) {
            for (Integer i = 0;i < (v_numberLength-4); i++) {
                if(v_accountStr == null) {
                    v_accountStr = '*';
                }else {
                    v_accountStr = v_accountStr+'*';
                }
            }
        }else {
            v_accountStr = '********';
        }
        
        String v_lastFour = v_accountNumber.substring(v_numberLength-4);
        v_accountStr = v_accountStr+v_lastFour;
        return v_accountStr;
    }
    
    global class ReturnClass {

        global String v_success;
        global String v_message;

        global ReturnClass(String v_success, String v_message) {
          this.v_success = v_success;
          this.v_message = v_message;
        }

    }
    
    global class AccountReturnClass {

        global String v_success;
        global String v_message;
        global Account v_records;

        global AccountReturnClass(String v_success, String v_message, Account v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class AccountListReturnClass {

        global String v_success;
        global String v_message;
        global List<Account> v_records;

        global AccountListReturnClass(String v_success, String v_message, List<Account> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class ContactListReturnClass {

        global String v_success;
        global String v_message;
        global List<Contact> v_records;

        global ContactListReturnClass(String v_success, String v_message, List<Contact> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class ContactReturnClass {

        global String v_success;
        global String v_message;
        global Contact v_records;

        global ContactReturnClass(String v_success, String v_message, Contact v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class DecimalMapReturnClass {

        global String v_success;
        global String v_message;
        global map<String,Decimal> v_records;

        global DecimalMapReturnClass(String v_success, String v_message, map<String,Decimal> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class InvoiceReturnClass {

        global String v_success;
        global String v_message;
        global invoice_finance_deal__c v_records;

        global InvoiceReturnClass(String v_success, String v_message, invoice_finance_deal__c v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class BuyerMapReturnClass {

        global String v_success;
        global String v_message;
        global Supplier_Buyer_Map__c v_records;

        global BuyerMapReturnClass(String v_success, String v_message, Supplier_Buyer_Map__c v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class BuyerMapListReturnClass {

        global String v_success;
        global String v_message;
        global List<Supplier_Buyer_Map__c> v_records;

        global BuyerMapListReturnClass(String v_success, String v_message, List<Supplier_Buyer_Map__c> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class InvoiceListReturnClass {

        global String v_success;
        global String v_message;
        global List<invoice_finance_deal__c> v_records;

        global InvoiceListReturnClass(String v_success, String v_message, List<invoice_finance_deal__c> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class AllocationListReturnClass {

        global String v_success;
        global String v_message;
        global List<Invoice_Allocation__c> v_records;

        global AllocationListReturnClass(String v_success, String v_message, List<Invoice_Allocation__c> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class MarketplaceReturnClass {

        global String v_success;
        global String v_message;
        global Marketplace__c v_records;

        global MarketplaceReturnClass(String v_success, String v_message, Marketplace__c v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class MarketplaceListReturnClass {

        global String v_success;
        global String v_message;
        global List<Marketplace__c> v_records;

        global MarketplaceListReturnClass(String v_success, String v_message, List<Marketplace__c> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class BankAccountListReturnClass {

        global String v_success;
        global String v_message;
        global List<Bank_Account__c> v_records;

        global BankAccountListReturnClass(String v_success, String v_message, List<Bank_Account__c> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class BankAccountReturnClass {

        global String v_success;
        global String v_message;
        global Bank_Account__c v_records;

        global BankAccountReturnClass(String v_success, String v_message, Bank_Account__c v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class TransactionReturnClass {

        global String v_success;
        global String v_message;
        global Transaction__c v_records;

        global TransactionReturnClass(String v_success, String v_message, Transaction__c v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class TransactionListReturnClass {

        global String v_success;
        global String v_message;
        global List<Transaction__c> v_records;

        global TransactionListReturnClass(String v_success, String v_message, List<Transaction__c> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class StringMapReturnClass {

        global String v_success;
        global String v_message;
        global map<String,String> v_records;

        global StringMapReturnClass(String v_success, String v_message, map<String,String> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class ListMapReturnClass {

        global String v_success;
        global String v_message;
        global map<String,List<String>> v_records;

        global ListMapReturnClass(String v_success, String v_message, map<String,List<String>> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
     global class MapProductListReturnClass {

        global String v_success;
        global String v_message;
        global List<Map_Product__c> v_records;

        global MapProductListReturnClass(String v_success, String v_message, List<Map_Product__c> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class MapSupportingDocsListReturnClass {

        global String v_success;
        global String v_message;
        global List<Map_Supporting_Doc__c> v_records;

        global MapSupportingDocsListReturnClass(String v_success, String v_message, List<Map_Supporting_Doc__c> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class WithdrawalDepositReturnClass {

        global String v_success;
        global String v_message;
        global List<Withdrawal_Deposit__c> v_records;

        global WithdrawalDepositReturnClass(String v_success, String v_message, List<Withdrawal_Deposit__c> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    global class EwalletListReturnClass {

        global String v_success;
        global String v_message;
        global List<eWallet__c> v_records;

        global EwalletListReturnClass(String v_success, String v_message, List<eWallet__c> v_records) {
          this.v_success = v_success;
          this.v_message = v_message;
          this.v_records = v_records;
        }

    }
    
    
}