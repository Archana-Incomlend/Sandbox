@isTest
private class Test_GlobalMethods_v9 {
    
    static testmethod void test_GlobalMethods_validateIsAgentForUserAccount() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        insert listAccount;
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0.5;
        accountSupplier.Agent__c = accountAgent.id;
        insert accountSupplier;
        
        GlobalMethods_v9.ReturnClass actual = GlobalMethods_v9.validateIsAgentForUserAccount(accountAgent.id ,accountSupplier.id);
        
        System.assertEquals('true', actual.v_success);
        System.assertEquals('Correct Agent Id', actual.v_message);
    }
    
    static testmethod void test_GlobalMethods_validateIsAgentForUserAccountFailInvalidAccount() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        insert listAccount;
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0.5;
        accountSupplier.Agent__c = accountAgent.id;
        Insert accountSupplier;
        
        
        String idAccount = accountSupplier.id;
        delete accountSupplier;
        
        GlobalMethods_v9.ReturnClass actual = GlobalMethods_v9.validateIsAgentForUserAccount(accountAgent.id ,idAccount);
        
        System.assertEquals('false', actual.v_success);
        System.assertEquals('Invalid Account Id', actual.v_message);
    }
    
    static testmethod void test_GlobalMethods_validateIsAgentForUserAccountFailInvalidAgent() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0.5;
        accountSupplier.Agent__c = accountAgent.id;
        listAccount.add(accountSupplier);
        insert listAccount;
        
        GlobalMethods_v9.ReturnClass actual = GlobalMethods_v9.validateIsAgentForUserAccount(accountAgent.id ,accountSupplier.id);
        
        System.assertEquals('false', actual.v_success);
        System.assertEquals('Invalid Agent Id', actual.v_message);
    }
    
    static testmethod void test_GlobalMethods_getUserDataTrue() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        insert listAccount;
        
        GlobalMethods_v9.AccountReturnClass actual = GlobalMethods_v9.getUserData(accountAgent.id);
        
        Account expectedAccount = [SELECT Id, Name, discount_profit_share_percent__c, Primary_Contact__r.Id,  Type, Sub_type__c FROM Account WHERE Id = :accountAgent.id];
        System.assertEquals('true', actual.v_success);
        System.assertEquals('Query executed successfully.', actual.v_message);
        System.assertEquals(expectedAccount, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_getUserDataFalse() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        insert listAccount;
        String recordID = accountAgent.id;
        
        delete accountAgent;
        
        GlobalMethods_v9.AccountReturnClass actual = GlobalMethods_v9.getUserData(recordID);
        
        System.assertEquals('false', actual.v_success);
        System.assertEquals('Invalid Account Id', actual.v_message);
        System.assertEquals(null, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_getLoggedinUserAccountIdTrue() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        insert listAccount;
        
        Contact contact = new Contact();
        contact.LastName = 'Luna';
        contact.AccountId = accountAgent.id;
        contact.Linkedin_username__c = 'Luna@yopmail.com';
        insert contact;
        String actualMessage = '';
        Id actual = null;
        try{
            actual = GlobalMethods_v9.getLoggedinUserAccountId('Luna@yopmail.com');
        }
        catch(GeneralException e){
            actualMessage = e.getMessage();
        }
        
        System.assertEquals('', actualMessage);
        System.assertEquals(accountAgent.id, actual);
    }
    
    static testmethod void test_GlobalMethods_getLoggedinUserAccountIdInvalidEmailId() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        insert listAccount;
        String actualMessage = '';
        try{
            Id actual = GlobalMethods_v9.getLoggedinUserAccountId('Luna@yopmail.com');
        }
        catch(GeneralException e){
            actualMessage = e.getMessage();
        }
        System.assertEquals('Invalid Email Id', actualMessage);
    }
    
    static testmethod void test_GlobalMethods_getLoggedinUserAccountIdFalseNoEmail() {
        String actualMessage = '';
        Id actual = null;
        try{
            actual = GlobalMethods_v9.getLoggedinUserAccountId(null);
        }
        catch(GeneralException e){
            actualMessage = e.getMessage();
        }
        
        System.assertEquals('No email id is in header', actualMessage);
    }
    
    static testmethod void test_GlobalMethods_getLoggedinUserAccountIdFalseUserIsSuspended() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        accountAgent.suspended__C = True;
        listAccount.add(accountAgent);
        insert listAccount;
        
        Contact contact = new Contact();
        contact.LastName = 'Luna';
        contact.AccountId = accountAgent.id;
        contact.Linkedin_username__c = 'Luna@yopmail.com';
        insert contact;
        String actualMessage = '';
        Id actual = null;
        try{
            actual = GlobalMethods_v9.getLoggedinUserAccountId('Luna@yopmail.com');
        }
        catch(GeneralException e){
            actualMessage = e.getMessage();
        }
        
        System.assertEquals('User is suspended', actualMessage);
    }
    
    static testmethod void test_GlobalMethods_getLoggedinUserDataTrue() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        insert listAccount;
        
        Contact contact = new Contact();
        contact.LastName = 'Luna';
        contact.AccountId = accountAgent.id;
        contact.Linkedin_username__c = 'Luna@yopmail.com';
        insert contact;
        String actualMessage = '';
        GlobalMethods_v9.ContactReturnClass actual = null;
        try{
            actual = GlobalMethods_v9.getLoggedinUserData('Luna@yopmail.com');
        }
        catch(GeneralException e){
            actualMessage = e.getMessage();
        }
        
        Contact expected = [SELECT Id, account.suspended__C ,account.onboarded__c , Name, Account.Id, Account.RecordType.Name, Account.Name, Account.Type, Account.Sub_type__c, Email FROM Contact WHERE Id =:contact.id];
        System.assertEquals('', actualMessage);
        System.assertEquals('true', actual.v_success);
        System.assertEquals('Query executed successfully.', actual.v_message);
        System.assertEquals(expected, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_getLoggedinUserDataNoEmail() {
        
        String actualMessage = '';
        GlobalMethods_v9.ContactReturnClass actual = null;
        try{
            actual = GlobalMethods_v9.getLoggedinUserData(null);
        }
        catch(GeneralException e){
            actualMessage = e.getMessage();
        }
        
        System.assertEquals('No email id is in header', actualMessage);
    }
    
    static testmethod void test_GlobalMethods_getLoggedinUserDataInvalidEmail() {
        
        String actualMessage = '';
        GlobalMethods_v9.ContactReturnClass actual = null;
        try{
            actual = GlobalMethods_v9.getLoggedinUserData('Luna@yopmail.com');
        }
        catch(GeneralException e){
            actualMessage = e.getMessage();
        }
        
        System.assertEquals('Invalid Email Id', actualMessage);
    }
    
    static testmethod void test_GlobalMethods_getLoggedinUserisSuspended() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        accountAgent.suspended__C = true;
        listAccount.add(accountAgent);
        insert listAccount;
        
        Contact contact = new Contact();
        contact.LastName = 'Luna';
        contact.AccountId = accountAgent.id;
        contact.Linkedin_username__c = 'Luna@yopmail.com';
        insert contact;
        String actualMessage = '';
        GlobalMethods_v9.ContactReturnClass actual = null;
        try{
            actual = GlobalMethods_v9.getLoggedinUserData('Luna@yopmail.com');
        }
        catch(GeneralException e){
            actualMessage = e.getMessage();
        }
        
        System.assertEquals('User is suspended', actualMessage);
    }
    
    static testmethod void test_GlobalMethods_validateUserAccessTrue1() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        accountAgent.suspended__C = true;
        listAccount.add(accountAgent);
        insert listAccount;
        
        accountAgent.Agent__c = accountAgent.id;
        
        boolean actual = GlobalMethods_v9.validateUserAccess(accountAgent.id, accountAgent.id);
        
        System.assertEquals(True, actual);
    }
    
    static testmethod void test_GlobalMethods_validateUserAccessTrue2() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        accountAgent.suspended__C = true;
        listAccount.add(accountAgent);
        insert listAccount;
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0.5;
        accountSupplier.Agent__c = accountAgent.id;
        insert accountSupplier;
        
        boolean actual = GlobalMethods_v9.validateUserAccess(accountAgent.id, accountSupplier.id);
        
        System.assertEquals(True, actual);
    }
    
    static testmethod void test_GlobalMethods_validateUserAccessFalse() {
        
        List<Account> listAccount = new List<Account>();
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        accountAgent.suspended__C = true;
        listAccount.add(accountAgent);
        insert listAccount;
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0.5;
        insert accountSupplier;
        
        boolean actual = GlobalMethods_v9.validateUserAccess(accountAgent.id, accountSupplier.id);
        
        System.assertEquals(False, actual);
    }
    
    static testmethod void test_GlobalMethods_getAvailableEwalletOK() {
        
        List<Account> listAccount = new List<Account>();
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        accountAgent.suspended__C = true;
        listAccount.add(accountAgent);
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        listAccount.add(accountFunder);
        insert listAccount;
        
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        insert Bank_AccountFunder;
        
        eWallet__c eWalletAgent = new eWallet__c();
        eWalletAgent.Balance__c = 50;
        eWalletAgent.Account__c = accountAgent.id;
        eWalletAgent.CCY__c = 'USD';
        eWalletAgent.Marketplace_for_FX__c = marketplace.id;
        eWalletAgent.Bank_Account__c = Bank_AccountFunder.id;
        eWalletAgent.Reservations__c = 10;
        eWalletAgent.Pre_Reservations__c = 10;
        insert eWalletAgent;
        eWalletAgent.Balance__c = 60;
        update eWalletAgent;
        String actualMessage = '';
        double actual = 0;
        
        try{
            actual = GlobalMethods_v9.getAvailableEwallet(accountAgent.id, 'USD');
        } catch (GeneralException e){
            actualMessage = e.getMessage();
        }
        
        System.assertEquals('', actualMessage);
    }
    
    static testmethod void test_GlobalMethods_getAvailableEwalletNG() {
        
        List<Account> listAccount = new List<Account>();
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        accountAgent.suspended__C = true;
        listAccount.add(accountAgent);
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        listAccount.add(accountFunder);
        insert listAccount;
        
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        insert Bank_AccountFunder;
        
        eWallet__c eWalletAgent = new eWallet__c();
        eWalletAgent.Balance__c = 4214595;
        eWalletAgent.Account__c = accountAgent.id;
        eWalletAgent.CCY__c = 'USD';
        eWalletAgent.Marketplace_for_FX__c = marketplace.id;
        eWalletAgent.Bank_Account__c = Bank_AccountFunder.id;
        insert eWalletAgent;
        String actualMessage = '';
        double actual = 0;
        try{
            actual = GlobalMethods_v9.getAvailableEwallet(accountAgent.id, 'SGD');
        } catch (GeneralException e){
            actualMessage = e.getMessage();
        }
        
        System.assertEquals('No eWallet found for this user', actualMessage);
    }
    
    static testmethod void test_GlobalMethods_getBankAccountDataOK() {
        
        List<Account> listAccount = new List<Account>();
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        accountAgent.suspended__C = true;
        listAccount.add(accountAgent);
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        listAccount.add(accountFunder);
        insert listAccount;
        
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        insert Bank_AccountFunder;
        
        GlobalMethods_v9.BankAccountReturnClass actual = GlobalMethods_v9.getBankAccountData(Bank_AccountFunder.id, accountFunder.id);
        
        Bank_Account__c expected = [SELECT Bank_Name__c, Bank_Account_Number__c, Address__c, Beneficiary_Name__c, SWIFT_Code__c, Country__c FROM Bank_Account__c WHERE Id=:Bank_AccountFunder.id];
        System.assertEquals('true', actual.v_success);
        System.assertEquals('Query executed successfully.', actual.v_message);
        System.assertEquals(expected, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_getBankAccountDataNG() {
        
        List<Account> listAccount = new List<Account>();
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        accountAgent.suspended__C = true;
        listAccount.add(accountAgent);
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        listAccount.add(accountFunder);
        insert listAccount;
        
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        insert Bank_AccountFunder;
        
        GlobalMethods_v9.BankAccountReturnClass actual = GlobalMethods_v9.getBankAccountData(Bank_AccountFunder.id, accountAgent.id);
        
        System.assertEquals('false', actual.v_success);
        System.assertEquals('Invalid bank account Id', actual.v_message);
        System.assertEquals(null, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_getInvoiceDataOK() {
        
        accounting_period__c accounting_period = new accounting_period__c();
        accounting_period.start_date__C = date.today();
        accounting_period.end_date__C = date.today();
        
        insert accounting_period;
        
        List<Account> listAccount = new List<Account>();
        // Incomlend Operations
        Account accountAtradius = new Account();
        accountAtradius.Name = 'Atradius';
        accountAtradius.Type = 'Partner';
        accountAtradius.Sub_type__c = 'NA';
        accountAtradius.VAT_applicable__c = true;
        listAccount.add(accountAtradius);
        
        // Incomlend Operations
        Account accountIncomlendOperation = new Account();
        accountIncomlendOperation.Name = 'Incomlend Operations';
        accountIncomlendOperation.Type = 'Internal';
        accountIncomlendOperation.Sub_type__c = 'NA';
        accountIncomlendOperation.VAT_applicable__c = true;
        listAccount.add(accountIncomlendOperation);
        
        // Incomlend - Supplier Discount
        Account accountIncomlendSupplierDiscount = new Account();
        accountIncomlendSupplierDiscount.Name = 'Incomlend - Supplier Discount';
        accountIncomlendSupplierDiscount.Type = 'Internal';
        accountIncomlendSupplierDiscount.Sub_type__c = 'NA';
        accountIncomlendSupplierDiscount.VAT_applicable__c = true;
        listAccount.add(accountIncomlendSupplierDiscount);
        
        // Incomlend GST
        Account accountIncomlendGST = new Account();
        accountIncomlendGST.Name = 'Incomlend GST';
        accountIncomlendGST.Type = 'Internal';
        accountIncomlendGST.Sub_type__c = 'NA';
        accountIncomlendGST.VAT_applicable__c = true;
        listAccount.add(accountIncomlendGST);
        
        // Incomlend - fees
        Account accountIncomlendfees = new Account();
        accountIncomlendfees.Name = 'Incomlend - fees';
        accountIncomlendfees.Type = 'Internal';
        accountIncomlendfees.Sub_type__c = 'NA';
        accountIncomlendfees.VAT_applicable__c = true;
        listAccount.add(accountIncomlendfees);
        
        // Incomlend Agent Provision
        Account accountIncomlendAgentProvision = new Account();
        accountIncomlendAgentProvision.Name = 'Incomlend Agent Provision';
        accountIncomlendAgentProvision.Type = 'Internal';
        accountIncomlendAgentProvision.Sub_type__c = 'NA';
        accountIncomlendAgentProvision.VAT_applicable__c = true;
        listAccount.add(accountIncomlendAgentProvision);
        
        Account accountBuyer = new Account();
        accountBuyer.Name = 'Buyer';
        accountBuyer.Type = 'Buyer';
        accountBuyer.Sub_type__c = 'Buyer';
        accountBuyer.Country_of_Incorporation__c = 'United States';
        accountBuyer.VAT_applicable__c = true;
        listAccount.add(accountBuyer);
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0;
        listAccount.add(accountSupplier);
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        
        listAccount.add(accountFunder);
        
        insert listAccount;
        
        List<Bank_Account__c> listBankAccount = new List<Bank_Account__c>();
        Bank_Account__c Bank_AccountAtradius = new Bank_Account__c();
        Bank_AccountAtradius.Account__c = accountAtradius.id;
        Bank_AccountAtradius.Bank_Name__c = 'Luna Bank';
        Bank_AccountAtradius.SWIFT_Code__c = 'Luna123456';
        Bank_AccountAtradius.Currency__c = 'USD';
        Bank_AccountAtradius.Country__c = 'VietNam';
        Bank_AccountAtradius.transfer_cutoff_time__c = '18:00';
        Bank_AccountAtradius.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountAtradius.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAtradius);
        
        Bank_Account__c Bank_AccountBuyer = new Bank_Account__c();
        Bank_AccountBuyer.Account__c = accountBuyer.id;
        Bank_AccountBuyer.Bank_Name__c = 'Luna Bank';
        Bank_AccountBuyer.SWIFT_Code__c = 'Luna123456';
        Bank_AccountBuyer.Currency__c = 'USD';
        Bank_AccountBuyer.Country__c = 'VietNam';
        Bank_AccountBuyer.transfer_cutoff_time__c = '18:00';
        Bank_AccountBuyer.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountBuyer.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountBuyer);
        
        Bank_Account__c Bank_AccountSupplier = new Bank_Account__c();
        Bank_AccountSupplier.Account__c = accountSupplier.id;
        Bank_AccountSupplier.Bank_Name__c = 'Luna Bank';
        Bank_AccountSupplier.SWIFT_Code__c = 'Luna123789';
        Bank_AccountSupplier.Currency__c = 'USD';
        Bank_AccountSupplier.Country__c = 'VietNam';
        Bank_AccountSupplier.transfer_cutoff_time__c = '18:00';
        Bank_AccountSupplier.Bank_Account_Number__c = '4514-5341345-1423423';
        Bank_AccountSupplier.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountSupplier);
        
        Bank_Account__c Bank_AccountAgent = new Bank_Account__c();
        Bank_AccountAgent.Account__c = accountAgent.id;
        Bank_AccountAgent.Bank_Name__c = 'Luna Bank';
        Bank_AccountAgent.SWIFT_Code__c = 'Luna456456';
        Bank_AccountAgent.Currency__c = 'USD';
        Bank_AccountAgent.Country__c = 'VietNam';
        Bank_AccountAgent.transfer_cutoff_time__c = '18:00';
        Bank_AccountAgent.Bank_Account_Number__c = '4514-5341345-1467587';
        Bank_AccountAgent.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAgent);
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountFunder);
        
        Bank_Account__c Bank_AccountIncomlendOperation = new Bank_Account__c();
        Bank_AccountIncomlendOperation.Account__c = accountIncomlendOperation.id;
        Bank_AccountIncomlendOperation.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendOperation.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendOperation.Currency__c = 'USD';
        Bank_AccountIncomlendOperation.Country__c = 'VietNam';
        Bank_AccountIncomlendOperation.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendOperation.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendOperation.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendOperation);
        
        Bank_Account__c Bank_AccountIncomlendSupplierDiscount = new Bank_Account__c();
        Bank_AccountIncomlendSupplierDiscount.Account__c = accountIncomlendSupplierDiscount.id;
        Bank_AccountIncomlendSupplierDiscount.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendSupplierDiscount.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendSupplierDiscount.Currency__c = 'USD';
        Bank_AccountIncomlendSupplierDiscount.Country__c = 'VietNam';
        Bank_AccountIncomlendSupplierDiscount.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendSupplierDiscount.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendSupplierDiscount.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendSupplierDiscount);
        
        Bank_Account__c Bank_AccountIncomlendGST = new Bank_Account__c();
        Bank_AccountIncomlendGST.Account__c = accountIncomlendGST.id;
        Bank_AccountIncomlendGST.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendGST.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendGST.Currency__c = 'USD';
        Bank_AccountIncomlendGST.Country__c = 'VietNam';
        Bank_AccountIncomlendGST.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendGST.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendGST.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendGST);
        
        Bank_Account__c Bank_AccountIncomlendfees = new Bank_Account__c();
        Bank_AccountIncomlendfees.Account__c = accountIncomlendfees.id;
        Bank_AccountIncomlendfees.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendfees.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendfees.Currency__c = 'USD';
        Bank_AccountIncomlendfees.Country__c = 'VietNam';
        Bank_AccountIncomlendfees.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendfees.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendfees.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendfees);
        
        Bank_Account__c Bank_AccountIncomlendAgentProvision = new Bank_Account__c();
        Bank_AccountIncomlendAgentProvision.Account__c = accountIncomlendAgentProvision.id;
        Bank_AccountIncomlendAgentProvision.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendAgentProvision.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendAgentProvision.Currency__c = 'USD';
        Bank_AccountIncomlendAgentProvision.Country__c = 'VietNam';
        Bank_AccountIncomlendAgentProvision.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendAgentProvision.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendAgentProvision.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendAgentProvision);
        
        insert listBankAccount;
        
        // FX rate
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        // factoring
        incomlend_product__c incomlend_product = new incomlend_product__c();
        incomlend_product.Name = 'Standard Insured - USD';
        incomlend_product.launch_date__c = Date.newInstance(2016, 11, 14);
        incomlend_product.CCYs__c = 'USD';
        incomlend_product.months_relationship_with_buyer__c = 12;
        incomlend_product.Auction_Type__c = 'Fixed Discount Rate';
        incomlend_product.approved__c = true;
        incomlend_product.insured__c = true;
        insert incomlend_product;
        
        Supplier_Buyer_Map__c Supplier_Buyer_Map = new Supplier_Buyer_Map__c();
        Supplier_Buyer_Map.Buyer__c = accountBuyer.id;
        Supplier_Buyer_Map.Supplier__c = accountSupplier.id;
        Supplier_Buyer_Map.Account_Agent__c = accountAgent.id;
        Supplier_Buyer_Map.Value_of_agent_s_fee__c = 15;
        Supplier_Buyer_Map.Incomlend_product__c = incomlend_product.id;
        Supplier_Buyer_Map.Marketplace__c = marketPlace.id;
        Supplier_Buyer_Map.buyer_supplier_map_approved__c = true;
        Supplier_Buyer_Map.map_onboarding_stage__c = '90.Onboarded';
        Supplier_Buyer_Map.Bangladesh_special_case__c = 'With factory';
        Insert Supplier_Buyer_Map;
        
        Map_Extension__c Map_Extension = new Map_Extension__c();
        Map_Extension.Account__c = accountIncomlendOperation.id;
        Map_Extension.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        Map_Extension.Map_extension_type__c = 'Factoring / Reverse Factoring';
        Map_Extension.Funding_Upfront_fees__c = false;
        Insert Map_Extension;
        
        invoice_finance_deal__c invoice = new invoice_finance_deal__c();
        invoice.Actual_Repayment_Amount__c = 1000000;
        invoice.Actual_Repayment_Received_Date__c = Date.newInstance(2021, 7, 10);
        //invoice.actual_financing_period__c = '4';
        //invoice.Actual_supplier_s_Agent_Commission_amt__c = 420;
        invoice.advance_send_to_supplier_date__c = Date.newInstance(2021, 7, 7);
        //invoice.Amount_Overdue__c = 0;
        
        invoice.CCY__c = 'USD';
        // if( credit_insured__c =false,0,ROUND(invoice_amount__c * credit_insurance_fee_percentage__c,2))
        // invoice.credit_insured__c  = Supplier_Buyer_Map__r.Incomlend_product__r.insured__c
        invoice.credit_insurance_fee_percentage__c = 1;
        
        invoice.discount_rate__c = 0.56;
        invoice.Due_Date__c = Date.newInstance(2021, 7, 28);
        //invoice.expected_financing_period__c = 12;
        invoice.Factory_Amount__c = 0;
        //invoice.funded_amount__c = 900000;
        invoice.invoice_amount__c = 10000000;
        invoice.requested_amount__c = 1000;
        invoice.Sum_Of_All_Pre_Reservations__c = 0;
        invoice.Insured_by__c = 'Atradius';
        invoice.Map_Extension__c = null;
        invoice.Marketplace_link__c = marketPlace.id;
        //invoice.Name = '012345';
        invoice.Notice_of_Assignment_signed__c = true;
        invoice.Phase__c = '2:ON MARKETPLACE';
        invoice.Status__c = 'On marketplace';
        //invoice.Supplier_balance__c = 100000;
        invoice.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        //invoice.Supplier_s_Agent_Commission_amount__c = 420;
        //invoice.Supplier_Country__c = 'China';
        invoice.Tolerance_overdue_days__c = 0;
        //invoice.Total_platform_fee__c = 0;
        invoice.Specific_additional_Platform_fee_amount__c = 1000;
        invoice.Total_Supplier_Discount__c = 0.7;
        //invoice.Total_supplier_discount_amount_expected__c = 2800;
        //invoice.Transaction_fees_overdue__c = 0;
        invoice.Trustee__c ='Amicorp Trust';
        //invoice.over_due_days__c = 0;
        invoice.supplier_invoice_reference_number__c = 'INV-0001';
        invoice.Real_Face_Value__c = 1000000;
        invoice.Factory_Amount__c = 100;
        invoice.Map_Extension__c = Map_Extension.id;
        insert invoice;
        
        GlobalMethods_v9.InvoiceReturnClass actual = GlobalMethods_v9.getInvoiceData(invoice.id);
        
        invoice_finance_deal__c expected = [SELECT Id, Invoice_name__c, MAX_bid_amount__c, bid_in_progress__c, funded_amount__c, auto_status__c, Phase__c, remaining_amount__c, CCY__c, marketplace_currency_symbol__c, requested_amount__c, Supplier_Buyer_Map__r.Marketplace__r.minimum_purchase_amount__c, Total_Supplier_Discount__c, Total_Platform_Fee__c FROM invoice_finance_deal__c WHERE Id = :invoice.id];
        System.assertEquals('true', actual.v_success);
        System.assertEquals('Query executed successfully.', actual.v_message);
        System.assertEquals(expected, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_getInvoiceDataNG() {
        
        accounting_period__c accounting_period = new accounting_period__c();
        accounting_period.start_date__C = date.today();
        accounting_period.end_date__C = date.today();
        
        insert accounting_period;
        
        List<Account> listAccount = new List<Account>();
        // Incomlend Operations
        Account accountAtradius = new Account();
        accountAtradius.Name = 'Atradius';
        accountAtradius.Type = 'Partner';
        accountAtradius.Sub_type__c = 'NA';
        accountAtradius.VAT_applicable__c = true;
        listAccount.add(accountAtradius);
        
        // Incomlend Operations
        Account accountIncomlendOperation = new Account();
        accountIncomlendOperation.Name = 'Incomlend Operations';
        accountIncomlendOperation.Type = 'Internal';
        accountIncomlendOperation.Sub_type__c = 'NA';
        accountIncomlendOperation.VAT_applicable__c = true;
        listAccount.add(accountIncomlendOperation);
        
        // Incomlend - Supplier Discount
        Account accountIncomlendSupplierDiscount = new Account();
        accountIncomlendSupplierDiscount.Name = 'Incomlend - Supplier Discount';
        accountIncomlendSupplierDiscount.Type = 'Internal';
        accountIncomlendSupplierDiscount.Sub_type__c = 'NA';
        accountIncomlendSupplierDiscount.VAT_applicable__c = true;
        listAccount.add(accountIncomlendSupplierDiscount);
        
        // Incomlend GST
        Account accountIncomlendGST = new Account();
        accountIncomlendGST.Name = 'Incomlend GST';
        accountIncomlendGST.Type = 'Internal';
        accountIncomlendGST.Sub_type__c = 'NA';
        accountIncomlendGST.VAT_applicable__c = true;
        listAccount.add(accountIncomlendGST);
        
        // Incomlend - fees
        Account accountIncomlendfees = new Account();
        accountIncomlendfees.Name = 'Incomlend - fees';
        accountIncomlendfees.Type = 'Internal';
        accountIncomlendfees.Sub_type__c = 'NA';
        accountIncomlendfees.VAT_applicable__c = true;
        listAccount.add(accountIncomlendfees);
        
        // Incomlend Agent Provision
        Account accountIncomlendAgentProvision = new Account();
        accountIncomlendAgentProvision.Name = 'Incomlend Agent Provision';
        accountIncomlendAgentProvision.Type = 'Internal';
        accountIncomlendAgentProvision.Sub_type__c = 'NA';
        accountIncomlendAgentProvision.VAT_applicable__c = true;
        listAccount.add(accountIncomlendAgentProvision);
        
        Account accountBuyer = new Account();
        accountBuyer.Name = 'Buyer';
        accountBuyer.Type = 'Buyer';
        accountBuyer.Sub_type__c = 'Buyer';
        accountBuyer.Country_of_Incorporation__c = 'United States';
        accountBuyer.VAT_applicable__c = true;
        listAccount.add(accountBuyer);
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0;
        listAccount.add(accountSupplier);
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        
        listAccount.add(accountFunder);
        
        insert listAccount;
        
        List<Bank_Account__c> listBankAccount = new List<Bank_Account__c>();
        Bank_Account__c Bank_AccountAtradius = new Bank_Account__c();
        Bank_AccountAtradius.Account__c = accountAtradius.id;
        Bank_AccountAtradius.Bank_Name__c = 'Luna Bank';
        Bank_AccountAtradius.SWIFT_Code__c = 'Luna123456';
        Bank_AccountAtradius.Currency__c = 'USD';
        Bank_AccountAtradius.Country__c = 'VietNam';
        Bank_AccountAtradius.transfer_cutoff_time__c = '18:00';
        Bank_AccountAtradius.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountAtradius.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAtradius);
        
        Bank_Account__c Bank_AccountBuyer = new Bank_Account__c();
        Bank_AccountBuyer.Account__c = accountBuyer.id;
        Bank_AccountBuyer.Bank_Name__c = 'Luna Bank';
        Bank_AccountBuyer.SWIFT_Code__c = 'Luna123456';
        Bank_AccountBuyer.Currency__c = 'USD';
        Bank_AccountBuyer.Country__c = 'VietNam';
        Bank_AccountBuyer.transfer_cutoff_time__c = '18:00';
        Bank_AccountBuyer.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountBuyer.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountBuyer);
        
        Bank_Account__c Bank_AccountSupplier = new Bank_Account__c();
        Bank_AccountSupplier.Account__c = accountSupplier.id;
        Bank_AccountSupplier.Bank_Name__c = 'Luna Bank';
        Bank_AccountSupplier.SWIFT_Code__c = 'Luna123789';
        Bank_AccountSupplier.Currency__c = 'USD';
        Bank_AccountSupplier.Country__c = 'VietNam';
        Bank_AccountSupplier.transfer_cutoff_time__c = '18:00';
        Bank_AccountSupplier.Bank_Account_Number__c = '4514-5341345-1423423';
        Bank_AccountSupplier.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountSupplier);
        
        Bank_Account__c Bank_AccountAgent = new Bank_Account__c();
        Bank_AccountAgent.Account__c = accountAgent.id;
        Bank_AccountAgent.Bank_Name__c = 'Luna Bank';
        Bank_AccountAgent.SWIFT_Code__c = 'Luna456456';
        Bank_AccountAgent.Currency__c = 'USD';
        Bank_AccountAgent.Country__c = 'VietNam';
        Bank_AccountAgent.transfer_cutoff_time__c = '18:00';
        Bank_AccountAgent.Bank_Account_Number__c = '4514-5341345-1467587';
        Bank_AccountAgent.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAgent);
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountFunder);
        
        Bank_Account__c Bank_AccountIncomlendOperation = new Bank_Account__c();
        Bank_AccountIncomlendOperation.Account__c = accountIncomlendOperation.id;
        Bank_AccountIncomlendOperation.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendOperation.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendOperation.Currency__c = 'USD';
        Bank_AccountIncomlendOperation.Country__c = 'VietNam';
        Bank_AccountIncomlendOperation.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendOperation.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendOperation.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendOperation);
        
        Bank_Account__c Bank_AccountIncomlendSupplierDiscount = new Bank_Account__c();
        Bank_AccountIncomlendSupplierDiscount.Account__c = accountIncomlendSupplierDiscount.id;
        Bank_AccountIncomlendSupplierDiscount.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendSupplierDiscount.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendSupplierDiscount.Currency__c = 'USD';
        Bank_AccountIncomlendSupplierDiscount.Country__c = 'VietNam';
        Bank_AccountIncomlendSupplierDiscount.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendSupplierDiscount.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendSupplierDiscount.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendSupplierDiscount);
        
        Bank_Account__c Bank_AccountIncomlendGST = new Bank_Account__c();
        Bank_AccountIncomlendGST.Account__c = accountIncomlendGST.id;
        Bank_AccountIncomlendGST.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendGST.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendGST.Currency__c = 'USD';
        Bank_AccountIncomlendGST.Country__c = 'VietNam';
        Bank_AccountIncomlendGST.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendGST.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendGST.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendGST);
        
        Bank_Account__c Bank_AccountIncomlendfees = new Bank_Account__c();
        Bank_AccountIncomlendfees.Account__c = accountIncomlendfees.id;
        Bank_AccountIncomlendfees.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendfees.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendfees.Currency__c = 'USD';
        Bank_AccountIncomlendfees.Country__c = 'VietNam';
        Bank_AccountIncomlendfees.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendfees.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendfees.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendfees);
        
        Bank_Account__c Bank_AccountIncomlendAgentProvision = new Bank_Account__c();
        Bank_AccountIncomlendAgentProvision.Account__c = accountIncomlendAgentProvision.id;
        Bank_AccountIncomlendAgentProvision.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendAgentProvision.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendAgentProvision.Currency__c = 'USD';
        Bank_AccountIncomlendAgentProvision.Country__c = 'VietNam';
        Bank_AccountIncomlendAgentProvision.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendAgentProvision.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendAgentProvision.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendAgentProvision);
        
        insert listBankAccount;
        
        // FX rate
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        // factoring
        incomlend_product__c incomlend_product = new incomlend_product__c();
        incomlend_product.Name = 'Standard Insured - USD';
        incomlend_product.launch_date__c = Date.newInstance(2016, 11, 14);
        incomlend_product.CCYs__c = 'USD';
        incomlend_product.months_relationship_with_buyer__c = 12;
        incomlend_product.Auction_Type__c = 'Fixed Discount Rate';
        incomlend_product.approved__c = true;
        incomlend_product.insured__c = true;
        insert incomlend_product;
        
        Supplier_Buyer_Map__c Supplier_Buyer_Map = new Supplier_Buyer_Map__c();
        Supplier_Buyer_Map.Buyer__c = accountBuyer.id;
        Supplier_Buyer_Map.Supplier__c = accountSupplier.id;
        Supplier_Buyer_Map.Account_Agent__c = accountAgent.id;
        Supplier_Buyer_Map.Value_of_agent_s_fee__c = 15;
        Supplier_Buyer_Map.Incomlend_product__c = incomlend_product.id;
        Supplier_Buyer_Map.Marketplace__c = marketPlace.id;
        Supplier_Buyer_Map.buyer_supplier_map_approved__c = true;
        Supplier_Buyer_Map.map_onboarding_stage__c = '90.Onboarded';
        Supplier_Buyer_Map.Bangladesh_special_case__c = 'With factory';
        Insert Supplier_Buyer_Map;
        
        Map_Extension__c Map_Extension = new Map_Extension__c();
        Map_Extension.Account__c = accountIncomlendOperation.id;
        Map_Extension.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        Map_Extension.Map_extension_type__c = 'Factoring / Reverse Factoring';
        Map_Extension.Funding_Upfront_fees__c = false;
        Insert Map_Extension;
        
        invoice_finance_deal__c invoice = new invoice_finance_deal__c();
        invoice.Actual_Repayment_Amount__c = 1000000;
        invoice.Actual_Repayment_Received_Date__c = Date.newInstance(2021, 7, 10);
        //invoice.actual_financing_period__c = '4';
        //invoice.Actual_supplier_s_Agent_Commission_amt__c = 420;
        invoice.advance_send_to_supplier_date__c = Date.newInstance(2021, 7, 7);
        //invoice.Amount_Overdue__c = 0;
        
        invoice.CCY__c = 'USD';
        // if( credit_insured__c =false,0,ROUND(invoice_amount__c * credit_insurance_fee_percentage__c,2))
        // invoice.credit_insured__c  = Supplier_Buyer_Map__r.Incomlend_product__r.insured__c
        invoice.credit_insurance_fee_percentage__c = 1;
        
        invoice.discount_rate__c = 0.56;
        invoice.Due_Date__c = Date.newInstance(2021, 7, 28);
        //invoice.expected_financing_period__c = 12;
        invoice.Factory_Amount__c = 0;
        //invoice.funded_amount__c = 900000;
        invoice.invoice_amount__c = 10000000;
        invoice.requested_amount__c = 1000;
        invoice.Sum_Of_All_Pre_Reservations__c = 0;
        invoice.Insured_by__c = 'Atradius';
        invoice.Map_Extension__c = null;
        invoice.Marketplace_link__c = marketPlace.id;
        //invoice.Name = '012345';
        invoice.Notice_of_Assignment_signed__c = true;
        invoice.Phase__c = '2:ON MARKETPLACE';
        invoice.Status__c = 'On marketplace';
        //invoice.Supplier_balance__c = 100000;
        invoice.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        //invoice.Supplier_s_Agent_Commission_amount__c = 420;
        //invoice.Supplier_Country__c = 'China';
        invoice.Tolerance_overdue_days__c = 0;
        //invoice.Total_platform_fee__c = 0;
        invoice.Specific_additional_Platform_fee_amount__c = 1000;
        invoice.Total_Supplier_Discount__c = 0.7;
        //invoice.Total_supplier_discount_amount_expected__c = 2800;
        //invoice.Transaction_fees_overdue__c = 0;
        invoice.Trustee__c ='Amicorp Trust';
        //invoice.over_due_days__c = 0;
        invoice.supplier_invoice_reference_number__c = 'INV-0001';
        invoice.Real_Face_Value__c = 1000000;
        invoice.Factory_Amount__c = 100;
        invoice.Map_Extension__c = Map_Extension.id;
        insert invoice;
        
        String InvoiceID = invoice.id;
        Delete invoice;
        GlobalMethods_v9.InvoiceReturnClass actual = GlobalMethods_v9.getInvoiceData(InvoiceID);
        
        System.assertEquals('false', actual.v_success);
        System.assertEquals('Invalid invoice Id', actual.v_message);
        System.assertEquals(null, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_getBuyerMapDataOK() {
        
        accounting_period__c accounting_period = new accounting_period__c();
        accounting_period.start_date__C = date.today();
        accounting_period.end_date__C = date.today();
        
        insert accounting_period;
        
        List<Account> listAccount = new List<Account>();
        // Incomlend Operations
        Account accountAtradius = new Account();
        accountAtradius.Name = 'Atradius';
        accountAtradius.Type = 'Partner';
        accountAtradius.Sub_type__c = 'NA';
        accountAtradius.VAT_applicable__c = true;
        listAccount.add(accountAtradius);
        
        // Incomlend Operations
        Account accountIncomlendOperation = new Account();
        accountIncomlendOperation.Name = 'Incomlend Operations';
        accountIncomlendOperation.Type = 'Internal';
        accountIncomlendOperation.Sub_type__c = 'NA';
        accountIncomlendOperation.VAT_applicable__c = true;
        listAccount.add(accountIncomlendOperation);
        
        // Incomlend - Supplier Discount
        Account accountIncomlendSupplierDiscount = new Account();
        accountIncomlendSupplierDiscount.Name = 'Incomlend - Supplier Discount';
        accountIncomlendSupplierDiscount.Type = 'Internal';
        accountIncomlendSupplierDiscount.Sub_type__c = 'NA';
        accountIncomlendSupplierDiscount.VAT_applicable__c = true;
        listAccount.add(accountIncomlendSupplierDiscount);
        
        // Incomlend GST
        Account accountIncomlendGST = new Account();
        accountIncomlendGST.Name = 'Incomlend GST';
        accountIncomlendGST.Type = 'Internal';
        accountIncomlendGST.Sub_type__c = 'NA';
        accountIncomlendGST.VAT_applicable__c = true;
        listAccount.add(accountIncomlendGST);
        
        // Incomlend - fees
        Account accountIncomlendfees = new Account();
        accountIncomlendfees.Name = 'Incomlend - fees';
        accountIncomlendfees.Type = 'Internal';
        accountIncomlendfees.Sub_type__c = 'NA';
        accountIncomlendfees.VAT_applicable__c = true;
        listAccount.add(accountIncomlendfees);
        
        // Incomlend Agent Provision
        Account accountIncomlendAgentProvision = new Account();
        accountIncomlendAgentProvision.Name = 'Incomlend Agent Provision';
        accountIncomlendAgentProvision.Type = 'Internal';
        accountIncomlendAgentProvision.Sub_type__c = 'NA';
        accountIncomlendAgentProvision.VAT_applicable__c = true;
        listAccount.add(accountIncomlendAgentProvision);
        
        Account accountBuyer = new Account();
        accountBuyer.Name = 'Buyer';
        accountBuyer.Type = 'Buyer';
        accountBuyer.Sub_type__c = 'Buyer';
        accountBuyer.Country_of_Incorporation__c = 'United States';
        accountBuyer.VAT_applicable__c = true;
        listAccount.add(accountBuyer);
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0;
        listAccount.add(accountSupplier);
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        
        listAccount.add(accountFunder);
        
        insert listAccount;
        
        List<Bank_Account__c> listBankAccount = new List<Bank_Account__c>();
        Bank_Account__c Bank_AccountAtradius = new Bank_Account__c();
        Bank_AccountAtradius.Account__c = accountAtradius.id;
        Bank_AccountAtradius.Bank_Name__c = 'Luna Bank';
        Bank_AccountAtradius.SWIFT_Code__c = 'Luna123456';
        Bank_AccountAtradius.Currency__c = 'USD';
        Bank_AccountAtradius.Country__c = 'VietNam';
        Bank_AccountAtradius.transfer_cutoff_time__c = '18:00';
        Bank_AccountAtradius.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountAtradius.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAtradius);
        
        Bank_Account__c Bank_AccountBuyer = new Bank_Account__c();
        Bank_AccountBuyer.Account__c = accountBuyer.id;
        Bank_AccountBuyer.Bank_Name__c = 'Luna Bank';
        Bank_AccountBuyer.SWIFT_Code__c = 'Luna123456';
        Bank_AccountBuyer.Currency__c = 'USD';
        Bank_AccountBuyer.Country__c = 'VietNam';
        Bank_AccountBuyer.transfer_cutoff_time__c = '18:00';
        Bank_AccountBuyer.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountBuyer.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountBuyer);
        
        Bank_Account__c Bank_AccountSupplier = new Bank_Account__c();
        Bank_AccountSupplier.Account__c = accountSupplier.id;
        Bank_AccountSupplier.Bank_Name__c = 'Luna Bank';
        Bank_AccountSupplier.SWIFT_Code__c = 'Luna123789';
        Bank_AccountSupplier.Currency__c = 'USD';
        Bank_AccountSupplier.Country__c = 'VietNam';
        Bank_AccountSupplier.transfer_cutoff_time__c = '18:00';
        Bank_AccountSupplier.Bank_Account_Number__c = '4514-5341345-1423423';
        Bank_AccountSupplier.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountSupplier);
        
        Bank_Account__c Bank_AccountAgent = new Bank_Account__c();
        Bank_AccountAgent.Account__c = accountAgent.id;
        Bank_AccountAgent.Bank_Name__c = 'Luna Bank';
        Bank_AccountAgent.SWIFT_Code__c = 'Luna456456';
        Bank_AccountAgent.Currency__c = 'USD';
        Bank_AccountAgent.Country__c = 'VietNam';
        Bank_AccountAgent.transfer_cutoff_time__c = '18:00';
        Bank_AccountAgent.Bank_Account_Number__c = '4514-5341345-1467587';
        Bank_AccountAgent.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAgent);
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountFunder);
        
        Bank_Account__c Bank_AccountIncomlendOperation = new Bank_Account__c();
        Bank_AccountIncomlendOperation.Account__c = accountIncomlendOperation.id;
        Bank_AccountIncomlendOperation.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendOperation.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendOperation.Currency__c = 'USD';
        Bank_AccountIncomlendOperation.Country__c = 'VietNam';
        Bank_AccountIncomlendOperation.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendOperation.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendOperation.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendOperation);
        
        Bank_Account__c Bank_AccountIncomlendSupplierDiscount = new Bank_Account__c();
        Bank_AccountIncomlendSupplierDiscount.Account__c = accountIncomlendSupplierDiscount.id;
        Bank_AccountIncomlendSupplierDiscount.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendSupplierDiscount.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendSupplierDiscount.Currency__c = 'USD';
        Bank_AccountIncomlendSupplierDiscount.Country__c = 'VietNam';
        Bank_AccountIncomlendSupplierDiscount.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendSupplierDiscount.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendSupplierDiscount.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendSupplierDiscount);
        
        Bank_Account__c Bank_AccountIncomlendGST = new Bank_Account__c();
        Bank_AccountIncomlendGST.Account__c = accountIncomlendGST.id;
        Bank_AccountIncomlendGST.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendGST.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendGST.Currency__c = 'USD';
        Bank_AccountIncomlendGST.Country__c = 'VietNam';
        Bank_AccountIncomlendGST.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendGST.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendGST.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendGST);
        
        Bank_Account__c Bank_AccountIncomlendfees = new Bank_Account__c();
        Bank_AccountIncomlendfees.Account__c = accountIncomlendfees.id;
        Bank_AccountIncomlendfees.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendfees.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendfees.Currency__c = 'USD';
        Bank_AccountIncomlendfees.Country__c = 'VietNam';
        Bank_AccountIncomlendfees.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendfees.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendfees.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendfees);
        
        Bank_Account__c Bank_AccountIncomlendAgentProvision = new Bank_Account__c();
        Bank_AccountIncomlendAgentProvision.Account__c = accountIncomlendAgentProvision.id;
        Bank_AccountIncomlendAgentProvision.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendAgentProvision.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendAgentProvision.Currency__c = 'USD';
        Bank_AccountIncomlendAgentProvision.Country__c = 'VietNam';
        Bank_AccountIncomlendAgentProvision.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendAgentProvision.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendAgentProvision.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendAgentProvision);
        
        insert listBankAccount;
        
        // FX rate
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        // factoring
        incomlend_product__c incomlend_product = new incomlend_product__c();
        incomlend_product.Name = 'Standard Insured - USD';
        incomlend_product.launch_date__c = Date.newInstance(2016, 11, 14);
        incomlend_product.CCYs__c = 'USD';
        incomlend_product.months_relationship_with_buyer__c = 12;
        incomlend_product.Auction_Type__c = 'Fixed Discount Rate';
        incomlend_product.approved__c = true;
        incomlend_product.insured__c = true;
        insert incomlend_product;
        
        Supplier_Buyer_Map__c Supplier_Buyer_Map = new Supplier_Buyer_Map__c();
        Supplier_Buyer_Map.Buyer__c = accountBuyer.id;
        Supplier_Buyer_Map.Supplier__c = accountSupplier.id;
        Supplier_Buyer_Map.Account_Agent__c = accountAgent.id;
        Supplier_Buyer_Map.Value_of_agent_s_fee__c = 15;
        Supplier_Buyer_Map.Incomlend_product__c = incomlend_product.id;
        Supplier_Buyer_Map.Marketplace__c = marketPlace.id;
        Supplier_Buyer_Map.buyer_supplier_map_approved__c = true;
        Supplier_Buyer_Map.map_onboarding_stage__c = '90.Onboarded';
        Supplier_Buyer_Map.Bangladesh_special_case__c = 'With factory';
        Insert Supplier_Buyer_Map;
        
        GlobalMethods_v9.BuyerMapReturnClass actual = GlobalMethods_v9.getBuyerMapData(Supplier_Buyer_Map.id);
        
        Supplier_Buyer_Map__c expected = [SELECT Id, Overdue_days__c FROM Supplier_Buyer_Map__c WHERE Id = :Supplier_Buyer_Map.id];
        System.assertEquals('true', actual.v_success);
        System.assertEquals('Query executed successfully.', actual.v_message);
        System.assertEquals(expected, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_getBuyerMapDataNG() {
        
        accounting_period__c accounting_period = new accounting_period__c();
        accounting_period.start_date__C = date.today();
        accounting_period.end_date__C = date.today();
        
        insert accounting_period;
        
        List<Account> listAccount = new List<Account>();
        // Incomlend Operations
        Account accountAtradius = new Account();
        accountAtradius.Name = 'Atradius';
        accountAtradius.Type = 'Partner';
        accountAtradius.Sub_type__c = 'NA';
        accountAtradius.VAT_applicable__c = true;
        listAccount.add(accountAtradius);
        
        // Incomlend Operations
        Account accountIncomlendOperation = new Account();
        accountIncomlendOperation.Name = 'Incomlend Operations';
        accountIncomlendOperation.Type = 'Internal';
        accountIncomlendOperation.Sub_type__c = 'NA';
        accountIncomlendOperation.VAT_applicable__c = true;
        listAccount.add(accountIncomlendOperation);
        
        // Incomlend - Supplier Discount
        Account accountIncomlendSupplierDiscount = new Account();
        accountIncomlendSupplierDiscount.Name = 'Incomlend - Supplier Discount';
        accountIncomlendSupplierDiscount.Type = 'Internal';
        accountIncomlendSupplierDiscount.Sub_type__c = 'NA';
        accountIncomlendSupplierDiscount.VAT_applicable__c = true;
        listAccount.add(accountIncomlendSupplierDiscount);
        
        // Incomlend GST
        Account accountIncomlendGST = new Account();
        accountIncomlendGST.Name = 'Incomlend GST';
        accountIncomlendGST.Type = 'Internal';
        accountIncomlendGST.Sub_type__c = 'NA';
        accountIncomlendGST.VAT_applicable__c = true;
        listAccount.add(accountIncomlendGST);
        
        // Incomlend - fees
        Account accountIncomlendfees = new Account();
        accountIncomlendfees.Name = 'Incomlend - fees';
        accountIncomlendfees.Type = 'Internal';
        accountIncomlendfees.Sub_type__c = 'NA';
        accountIncomlendfees.VAT_applicable__c = true;
        listAccount.add(accountIncomlendfees);
        
        // Incomlend Agent Provision
        Account accountIncomlendAgentProvision = new Account();
        accountIncomlendAgentProvision.Name = 'Incomlend Agent Provision';
        accountIncomlendAgentProvision.Type = 'Internal';
        accountIncomlendAgentProvision.Sub_type__c = 'NA';
        accountIncomlendAgentProvision.VAT_applicable__c = true;
        listAccount.add(accountIncomlendAgentProvision);
        
        Account accountBuyer = new Account();
        accountBuyer.Name = 'Buyer';
        accountBuyer.Type = 'Buyer';
        accountBuyer.Sub_type__c = 'Buyer';
        accountBuyer.Country_of_Incorporation__c = 'United States';
        accountBuyer.VAT_applicable__c = true;
        listAccount.add(accountBuyer);
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0;
        listAccount.add(accountSupplier);
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        
        listAccount.add(accountFunder);
        
        insert listAccount;
        
        List<Bank_Account__c> listBankAccount = new List<Bank_Account__c>();
        Bank_Account__c Bank_AccountAtradius = new Bank_Account__c();
        Bank_AccountAtradius.Account__c = accountAtradius.id;
        Bank_AccountAtradius.Bank_Name__c = 'Luna Bank';
        Bank_AccountAtradius.SWIFT_Code__c = 'Luna123456';
        Bank_AccountAtradius.Currency__c = 'USD';
        Bank_AccountAtradius.Country__c = 'VietNam';
        Bank_AccountAtradius.transfer_cutoff_time__c = '18:00';
        Bank_AccountAtradius.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountAtradius.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAtradius);
        
        Bank_Account__c Bank_AccountBuyer = new Bank_Account__c();
        Bank_AccountBuyer.Account__c = accountBuyer.id;
        Bank_AccountBuyer.Bank_Name__c = 'Luna Bank';
        Bank_AccountBuyer.SWIFT_Code__c = 'Luna123456';
        Bank_AccountBuyer.Currency__c = 'USD';
        Bank_AccountBuyer.Country__c = 'VietNam';
        Bank_AccountBuyer.transfer_cutoff_time__c = '18:00';
        Bank_AccountBuyer.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountBuyer.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountBuyer);
        
        Bank_Account__c Bank_AccountSupplier = new Bank_Account__c();
        Bank_AccountSupplier.Account__c = accountSupplier.id;
        Bank_AccountSupplier.Bank_Name__c = 'Luna Bank';
        Bank_AccountSupplier.SWIFT_Code__c = 'Luna123789';
        Bank_AccountSupplier.Currency__c = 'USD';
        Bank_AccountSupplier.Country__c = 'VietNam';
        Bank_AccountSupplier.transfer_cutoff_time__c = '18:00';
        Bank_AccountSupplier.Bank_Account_Number__c = '4514-5341345-1423423';
        Bank_AccountSupplier.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountSupplier);
        
        Bank_Account__c Bank_AccountAgent = new Bank_Account__c();
        Bank_AccountAgent.Account__c = accountAgent.id;
        Bank_AccountAgent.Bank_Name__c = 'Luna Bank';
        Bank_AccountAgent.SWIFT_Code__c = 'Luna456456';
        Bank_AccountAgent.Currency__c = 'USD';
        Bank_AccountAgent.Country__c = 'VietNam';
        Bank_AccountAgent.transfer_cutoff_time__c = '18:00';
        Bank_AccountAgent.Bank_Account_Number__c = '4514-5341345-1467587';
        Bank_AccountAgent.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAgent);
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountFunder);
        
        Bank_Account__c Bank_AccountIncomlendOperation = new Bank_Account__c();
        Bank_AccountIncomlendOperation.Account__c = accountIncomlendOperation.id;
        Bank_AccountIncomlendOperation.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendOperation.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendOperation.Currency__c = 'USD';
        Bank_AccountIncomlendOperation.Country__c = 'VietNam';
        Bank_AccountIncomlendOperation.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendOperation.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendOperation.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendOperation);
        
        Bank_Account__c Bank_AccountIncomlendSupplierDiscount = new Bank_Account__c();
        Bank_AccountIncomlendSupplierDiscount.Account__c = accountIncomlendSupplierDiscount.id;
        Bank_AccountIncomlendSupplierDiscount.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendSupplierDiscount.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendSupplierDiscount.Currency__c = 'USD';
        Bank_AccountIncomlendSupplierDiscount.Country__c = 'VietNam';
        Bank_AccountIncomlendSupplierDiscount.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendSupplierDiscount.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendSupplierDiscount.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendSupplierDiscount);
        
        Bank_Account__c Bank_AccountIncomlendGST = new Bank_Account__c();
        Bank_AccountIncomlendGST.Account__c = accountIncomlendGST.id;
        Bank_AccountIncomlendGST.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendGST.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendGST.Currency__c = 'USD';
        Bank_AccountIncomlendGST.Country__c = 'VietNam';
        Bank_AccountIncomlendGST.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendGST.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendGST.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendGST);
        
        Bank_Account__c Bank_AccountIncomlendfees = new Bank_Account__c();
        Bank_AccountIncomlendfees.Account__c = accountIncomlendfees.id;
        Bank_AccountIncomlendfees.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendfees.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendfees.Currency__c = 'USD';
        Bank_AccountIncomlendfees.Country__c = 'VietNam';
        Bank_AccountIncomlendfees.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendfees.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendfees.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendfees);
        
        Bank_Account__c Bank_AccountIncomlendAgentProvision = new Bank_Account__c();
        Bank_AccountIncomlendAgentProvision.Account__c = accountIncomlendAgentProvision.id;
        Bank_AccountIncomlendAgentProvision.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendAgentProvision.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendAgentProvision.Currency__c = 'USD';
        Bank_AccountIncomlendAgentProvision.Country__c = 'VietNam';
        Bank_AccountIncomlendAgentProvision.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendAgentProvision.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendAgentProvision.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendAgentProvision);
        
        insert listBankAccount;
        
        // FX rate
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        // factoring
        incomlend_product__c incomlend_product = new incomlend_product__c();
        incomlend_product.Name = 'Standard Insured - USD';
        incomlend_product.launch_date__c = Date.newInstance(2016, 11, 14);
        incomlend_product.CCYs__c = 'USD';
        incomlend_product.months_relationship_with_buyer__c = 12;
        incomlend_product.Auction_Type__c = 'Fixed Discount Rate';
        incomlend_product.approved__c = true;
        incomlend_product.insured__c = true;
        insert incomlend_product;
        
        Supplier_Buyer_Map__c Supplier_Buyer_Map = new Supplier_Buyer_Map__c();
        Supplier_Buyer_Map.Buyer__c = accountBuyer.id;
        Supplier_Buyer_Map.Supplier__c = accountSupplier.id;
        Supplier_Buyer_Map.Account_Agent__c = accountAgent.id;
        Supplier_Buyer_Map.Value_of_agent_s_fee__c = 15;
        Supplier_Buyer_Map.Incomlend_product__c = incomlend_product.id;
        Supplier_Buyer_Map.Marketplace__c = marketPlace.id;
        Supplier_Buyer_Map.buyer_supplier_map_approved__c = true;
        Supplier_Buyer_Map.map_onboarding_stage__c = '90.Onboarded';
        Supplier_Buyer_Map.Bangladesh_special_case__c = 'With factory';
        Insert Supplier_Buyer_Map;
        
        String SupplierBuyerMap = Supplier_Buyer_Map.id;
        delete Supplier_Buyer_Map;
        
        GlobalMethods_v9.BuyerMapReturnClass actual = GlobalMethods_v9.getBuyerMapData(SupplierBuyerMap);
        
        System.assertEquals('false', actual.v_success);
        System.assertEquals('Invalid Supplier Buyer Map Id', actual.v_message);
        System.assertEquals(null, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_getUserWalletDataOK() {
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0.5;
        
        insert accountSupplier;
        
        GlobalMethods_v9.AccountReturnClass actual = GlobalMethods_v9.getUserWalletData(accountSupplier.id);
        
        Account expected = [SELECT discount_profit_share_percent__c FROM Account WHERE Id = :accountSupplier.id];
        System.assertEquals('true', actual.v_success);
        System.assertEquals('Query executed successfully.', actual.v_message);
        System.assertEquals(expected, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_getUserWalletDataNG() {
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0.5;
        
        insert accountSupplier;
        String accountID = accountSupplier.id;
        delete accountSupplier;
        
        GlobalMethods_v9.AccountReturnClass actual = GlobalMethods_v9.getUserWalletData(accountID);
        
        System.assertEquals('false', actual.v_success);
        System.assertEquals('Invalid Account Id', actual.v_message);
        System.assertEquals(null, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_addContactLog() {
        
        accounting_period__c accounting_period = new accounting_period__c();
        accounting_period.start_date__C = date.today();
        accounting_period.end_date__C = date.today();
        
        insert accounting_period;
        
        List<Account> listAccount = new List<Account>();
        // Incomlend Operations
        Account accountAtradius = new Account();
        accountAtradius.Name = 'Atradius';
        accountAtradius.Type = 'Partner';
        accountAtradius.Sub_type__c = 'NA';
        accountAtradius.VAT_applicable__c = true;
        listAccount.add(accountAtradius);
        
        // Incomlend Operations
        Account accountIncomlendOperation = new Account();
        accountIncomlendOperation.Name = 'Incomlend Operations';
        accountIncomlendOperation.Type = 'Internal';
        accountIncomlendOperation.Sub_type__c = 'NA';
        accountIncomlendOperation.VAT_applicable__c = true;
        listAccount.add(accountIncomlendOperation);
        
        // Incomlend - Supplier Discount
        Account accountIncomlendSupplierDiscount = new Account();
        accountIncomlendSupplierDiscount.Name = 'Incomlend - Supplier Discount';
        accountIncomlendSupplierDiscount.Type = 'Internal';
        accountIncomlendSupplierDiscount.Sub_type__c = 'NA';
        accountIncomlendSupplierDiscount.VAT_applicable__c = true;
        listAccount.add(accountIncomlendSupplierDiscount);
        
        // Incomlend GST
        Account accountIncomlendGST = new Account();
        accountIncomlendGST.Name = 'Incomlend GST';
        accountIncomlendGST.Type = 'Internal';
        accountIncomlendGST.Sub_type__c = 'NA';
        accountIncomlendGST.VAT_applicable__c = true;
        listAccount.add(accountIncomlendGST);
        
        // Incomlend - fees
        Account accountIncomlendfees = new Account();
        accountIncomlendfees.Name = 'Incomlend - fees';
        accountIncomlendfees.Type = 'Internal';
        accountIncomlendfees.Sub_type__c = 'NA';
        accountIncomlendfees.VAT_applicable__c = true;
        listAccount.add(accountIncomlendfees);
        
        // Incomlend Agent Provision
        Account accountIncomlendAgentProvision = new Account();
        accountIncomlendAgentProvision.Name = 'Incomlend Agent Provision';
        accountIncomlendAgentProvision.Type = 'Internal';
        accountIncomlendAgentProvision.Sub_type__c = 'NA';
        accountIncomlendAgentProvision.VAT_applicable__c = true;
        listAccount.add(accountIncomlendAgentProvision);
        
        Account accountBuyer = new Account();
        accountBuyer.Name = 'Buyer';
        accountBuyer.Type = 'Buyer';
        accountBuyer.Sub_type__c = 'Buyer';
        accountBuyer.Country_of_Incorporation__c = 'United States';
        accountBuyer.VAT_applicable__c = true;
        listAccount.add(accountBuyer);
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0;
        listAccount.add(accountSupplier);
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        
        listAccount.add(accountFunder);
        
        insert listAccount;
        
        List<Bank_Account__c> listBankAccount = new List<Bank_Account__c>();
        Bank_Account__c Bank_AccountAtradius = new Bank_Account__c();
        Bank_AccountAtradius.Account__c = accountAtradius.id;
        Bank_AccountAtradius.Bank_Name__c = 'Luna Bank';
        Bank_AccountAtradius.SWIFT_Code__c = 'Luna123456';
        Bank_AccountAtradius.Currency__c = 'USD';
        Bank_AccountAtradius.Country__c = 'VietNam';
        Bank_AccountAtradius.transfer_cutoff_time__c = '18:00';
        Bank_AccountAtradius.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountAtradius.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAtradius);
        
        Bank_Account__c Bank_AccountBuyer = new Bank_Account__c();
        Bank_AccountBuyer.Account__c = accountBuyer.id;
        Bank_AccountBuyer.Bank_Name__c = 'Luna Bank';
        Bank_AccountBuyer.SWIFT_Code__c = 'Luna123456';
        Bank_AccountBuyer.Currency__c = 'USD';
        Bank_AccountBuyer.Country__c = 'VietNam';
        Bank_AccountBuyer.transfer_cutoff_time__c = '18:00';
        Bank_AccountBuyer.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountBuyer.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountBuyer);
        
        Bank_Account__c Bank_AccountSupplier = new Bank_Account__c();
        Bank_AccountSupplier.Account__c = accountSupplier.id;
        Bank_AccountSupplier.Bank_Name__c = 'Luna Bank';
        Bank_AccountSupplier.SWIFT_Code__c = 'Luna123789';
        Bank_AccountSupplier.Currency__c = 'USD';
        Bank_AccountSupplier.Country__c = 'VietNam';
        Bank_AccountSupplier.transfer_cutoff_time__c = '18:00';
        Bank_AccountSupplier.Bank_Account_Number__c = '4514-5341345-1423423';
        Bank_AccountSupplier.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountSupplier);
        
        Bank_Account__c Bank_AccountAgent = new Bank_Account__c();
        Bank_AccountAgent.Account__c = accountAgent.id;
        Bank_AccountAgent.Bank_Name__c = 'Luna Bank';
        Bank_AccountAgent.SWIFT_Code__c = 'Luna456456';
        Bank_AccountAgent.Currency__c = 'USD';
        Bank_AccountAgent.Country__c = 'VietNam';
        Bank_AccountAgent.transfer_cutoff_time__c = '18:00';
        Bank_AccountAgent.Bank_Account_Number__c = '4514-5341345-1467587';
        Bank_AccountAgent.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAgent);
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountFunder);
        
        Bank_Account__c Bank_AccountIncomlendOperation = new Bank_Account__c();
        Bank_AccountIncomlendOperation.Account__c = accountIncomlendOperation.id;
        Bank_AccountIncomlendOperation.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendOperation.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendOperation.Currency__c = 'USD';
        Bank_AccountIncomlendOperation.Country__c = 'VietNam';
        Bank_AccountIncomlendOperation.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendOperation.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendOperation.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendOperation);
        
        Bank_Account__c Bank_AccountIncomlendSupplierDiscount = new Bank_Account__c();
        Bank_AccountIncomlendSupplierDiscount.Account__c = accountIncomlendSupplierDiscount.id;
        Bank_AccountIncomlendSupplierDiscount.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendSupplierDiscount.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendSupplierDiscount.Currency__c = 'USD';
        Bank_AccountIncomlendSupplierDiscount.Country__c = 'VietNam';
        Bank_AccountIncomlendSupplierDiscount.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendSupplierDiscount.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendSupplierDiscount.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendSupplierDiscount);
        
        Bank_Account__c Bank_AccountIncomlendGST = new Bank_Account__c();
        Bank_AccountIncomlendGST.Account__c = accountIncomlendGST.id;
        Bank_AccountIncomlendGST.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendGST.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendGST.Currency__c = 'USD';
        Bank_AccountIncomlendGST.Country__c = 'VietNam';
        Bank_AccountIncomlendGST.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendGST.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendGST.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendGST);
        
        Bank_Account__c Bank_AccountIncomlendfees = new Bank_Account__c();
        Bank_AccountIncomlendfees.Account__c = accountIncomlendfees.id;
        Bank_AccountIncomlendfees.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendfees.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendfees.Currency__c = 'USD';
        Bank_AccountIncomlendfees.Country__c = 'VietNam';
        Bank_AccountIncomlendfees.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendfees.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendfees.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendfees);
        
        Bank_Account__c Bank_AccountIncomlendAgentProvision = new Bank_Account__c();
        Bank_AccountIncomlendAgentProvision.Account__c = accountIncomlendAgentProvision.id;
        Bank_AccountIncomlendAgentProvision.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendAgentProvision.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendAgentProvision.Currency__c = 'USD';
        Bank_AccountIncomlendAgentProvision.Country__c = 'VietNam';
        Bank_AccountIncomlendAgentProvision.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendAgentProvision.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendAgentProvision.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendAgentProvision);
        
        insert listBankAccount;
        
        // FX rate
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        // factoring
        incomlend_product__c incomlend_product = new incomlend_product__c();
        incomlend_product.Name = 'Standard Insured - USD';
        incomlend_product.launch_date__c = Date.newInstance(2016, 11, 14);
        incomlend_product.CCYs__c = 'USD';
        incomlend_product.months_relationship_with_buyer__c = 12;
        incomlend_product.Auction_Type__c = 'Fixed Discount Rate';
        incomlend_product.approved__c = true;
        incomlend_product.insured__c = true;
        insert incomlend_product;
        
        Supplier_Buyer_Map__c Supplier_Buyer_Map = new Supplier_Buyer_Map__c();
        Supplier_Buyer_Map.Buyer__c = accountBuyer.id;
        Supplier_Buyer_Map.Supplier__c = accountSupplier.id;
        Supplier_Buyer_Map.Account_Agent__c = accountAgent.id;
        Supplier_Buyer_Map.Value_of_agent_s_fee__c = 15;
        Supplier_Buyer_Map.Incomlend_product__c = incomlend_product.id;
        Supplier_Buyer_Map.Marketplace__c = marketPlace.id;
        Supplier_Buyer_Map.buyer_supplier_map_approved__c = true;
        Supplier_Buyer_Map.map_onboarding_stage__c = '90.Onboarded';
        Supplier_Buyer_Map.Bangladesh_special_case__c = 'With factory';
        Insert Supplier_Buyer_Map;
        
        Map_Extension__c Map_Extension = new Map_Extension__c();
        Map_Extension.Account__c = accountIncomlendOperation.id;
        Map_Extension.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        Map_Extension.Map_extension_type__c = 'Factoring / Reverse Factoring';
        Map_Extension.Funding_Upfront_fees__c = false;
        Insert Map_Extension;
        
        invoice_finance_deal__c invoice = new invoice_finance_deal__c();
        invoice.Actual_Repayment_Amount__c = 1000000;
        invoice.Actual_Repayment_Received_Date__c = Date.newInstance(2021, 7, 10);
        //invoice.actual_financing_period__c = '4';
        //invoice.Actual_supplier_s_Agent_Commission_amt__c = 420;
        invoice.advance_send_to_supplier_date__c = Date.newInstance(2021, 7, 7);
        //invoice.Amount_Overdue__c = 0;
        
        invoice.CCY__c = 'USD';
        // if( credit_insured__c =false,0,ROUND(invoice_amount__c * credit_insurance_fee_percentage__c,2))
        // invoice.credit_insured__c  = Supplier_Buyer_Map__r.Incomlend_product__r.insured__c
        invoice.credit_insurance_fee_percentage__c = 1;
        
        invoice.discount_rate__c = 0.56;
        invoice.Due_Date__c = Date.newInstance(2021, 7, 28);
        //invoice.expected_financing_period__c = 12;
        invoice.Factory_Amount__c = 0;
        //invoice.funded_amount__c = 900000;
        invoice.invoice_amount__c = 10000000;
        invoice.requested_amount__c = 1000;
        invoice.Sum_Of_All_Pre_Reservations__c = 0;
        invoice.Insured_by__c = 'Atradius';
        invoice.Map_Extension__c = null;
        invoice.Marketplace_link__c = marketPlace.id;
        //invoice.Name = '012345';
        invoice.Notice_of_Assignment_signed__c = true;
        invoice.Phase__c = '2:ON MARKETPLACE';
        invoice.Status__c = 'On marketplace';
        //invoice.Supplier_balance__c = 100000;
        invoice.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        //invoice.Supplier_s_Agent_Commission_amount__c = 420;
        //invoice.Supplier_Country__c = 'China';
        invoice.Tolerance_overdue_days__c = 0;
        //invoice.Total_platform_fee__c = 0;
        invoice.Specific_additional_Platform_fee_amount__c = 1000;
        invoice.Total_Supplier_Discount__c = 0.7;
        //invoice.Total_supplier_discount_amount_expected__c = 2800;
        //invoice.Transaction_fees_overdue__c = 0;
        invoice.Trustee__c ='Amicorp Trust';
        //invoice.over_due_days__c = 0;
        invoice.supplier_invoice_reference_number__c = 'INV-0001';
        invoice.Real_Face_Value__c = 1000000;
        invoice.Factory_Amount__c = 100;
        invoice.Map_Extension__c = Map_Extension.id;
        insert invoice;
        
        Contact contact = new Contact();
        contact.LastName = 'Luna';
        contact.AccountId = accountAgent.id;
        contact.Linkedin_username__c = 'Luna@yopmail.com';
        insert contact;
        
        GlobalMethods_v9.addContactLog(contact.id, invoice.id, 'Login', 'v_info', 'v_notes');
        
        List<contact_log__c> actual = [SELECT date__c,contact__c,action__C,extra_info__C,Invoice_Finance_Deal__c,notes__c FROM contact_log__c];
        System.assertEquals(1, actual.size());
        Datetime dateContactLog = actual.get(0).date__c;
        System.assertEquals(System.today(), Date.newInstance(dateContactLog.year(), dateContactLog.month(), dateContactLog.day()));
        System.assertEquals(contact.id, actual.get(0).contact__c);
        System.assertEquals('Login', actual.get(0).action__C);
        System.assertEquals('v_info', actual.get(0).extra_info__C);
        System.assertEquals(invoice.id, actual.get(0).Invoice_Finance_Deal__c);
        System.assertEquals('v_notes', actual.get(0).notes__c);
    }
    
    static testmethod void test_GlobalMethods_isValidIdTrue() {
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        insert accountAgent;
        Boolean actual = GlobalMethods_v9.isValidId(accountAgent.Id);
        
        System.assertEquals(True, actual);
    }
    
    static testmethod void test_GlobalMethods_isValidIdFalse() {
        
        Boolean actual = GlobalMethods_v9.isValidId('Luna');
        System.assertEquals(False, actual);
    }
    
    static testmethod void test_GlobalMethods_isvalidCurrencyTrue() {
        
        Boolean actual = GlobalMethods_v9.isvalidCurrency('USD');
        System.assertEquals(True, actual);
    }
    
    static testmethod void test_GlobalMethods_isvalidCurrencyFalse() {
        
        Boolean actual = GlobalMethods_v9.isvalidCurrency('USDDD');
        System.assertEquals(False, actual);
    }
    
    static testmethod void test_GlobalMethods_getPicklistValues() {
        
        Schema.DescribeFieldResult v_countryOfOriginFieldResult = invoice_finance_deal__c.Country_of_Origin__c.getDescribe();
        List<String> actual = GlobalMethods_v9.getPicklistValues(v_countryOfOriginFieldResult);
        System.assert(actual.size() > 0);
    }
    
    static testmethod void test_GlobalMethods_createAllocationResponse() {
        accounting_period__c accounting_period = new accounting_period__c();
        accounting_period.start_date__C = date.today();
        accounting_period.end_date__C = date.today();
        
        insert accounting_period;
        
        List<Account> listAccount = new List<Account>();
        // Incomlend Operations
        Account accountAtradius = new Account();
        accountAtradius.Name = 'Atradius';
        accountAtradius.Type = 'Partner';
        accountAtradius.Sub_type__c = 'NA';
        accountAtradius.VAT_applicable__c = true;
        listAccount.add(accountAtradius);
        
        // Incomlend Operations
        Account accountIncomlendOperation = new Account();
        accountIncomlendOperation.Name = 'Incomlend Operations';
        accountIncomlendOperation.Type = 'Internal';
        accountIncomlendOperation.Sub_type__c = 'NA';
        accountIncomlendOperation.VAT_applicable__c = true;
        listAccount.add(accountIncomlendOperation);
        
        // Incomlend - Supplier Discount
        Account accountIncomlendSupplierDiscount = new Account();
        accountIncomlendSupplierDiscount.Name = 'Incomlend - Supplier Discount';
        accountIncomlendSupplierDiscount.Type = 'Internal';
        accountIncomlendSupplierDiscount.Sub_type__c = 'NA';
        accountIncomlendSupplierDiscount.VAT_applicable__c = true;
        listAccount.add(accountIncomlendSupplierDiscount);
        
        // Incomlend GST
        Account accountIncomlendGST = new Account();
        accountIncomlendGST.Name = 'Incomlend GST';
        accountIncomlendGST.Type = 'Internal';
        accountIncomlendGST.Sub_type__c = 'NA';
        accountIncomlendGST.VAT_applicable__c = true;
        listAccount.add(accountIncomlendGST);
        
        // Incomlend - fees
        Account accountIncomlendfees = new Account();
        accountIncomlendfees.Name = 'Incomlend - fees';
        accountIncomlendfees.Type = 'Internal';
        accountIncomlendfees.Sub_type__c = 'NA';
        accountIncomlendfees.VAT_applicable__c = true;
        listAccount.add(accountIncomlendfees);
        
        // Incomlend Agent Provision
        Account accountIncomlendAgentProvision = new Account();
        accountIncomlendAgentProvision.Name = 'Incomlend Agent Provision';
        accountIncomlendAgentProvision.Type = 'Internal';
        accountIncomlendAgentProvision.Sub_type__c = 'NA';
        accountIncomlendAgentProvision.VAT_applicable__c = true;
        listAccount.add(accountIncomlendAgentProvision);
        
        Account accountBuyer = new Account();
        accountBuyer.Name = 'Buyer';
        accountBuyer.Type = 'Buyer';
        accountBuyer.Sub_type__c = 'Buyer';
        accountBuyer.Country_of_Incorporation__c = 'United States';
        accountBuyer.VAT_applicable__c = true;
        listAccount.add(accountBuyer);
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0;
        listAccount.add(accountSupplier);
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        
        listAccount.add(accountFunder);
        
        insert listAccount;
        
        List<Bank_Account__c> listBankAccount = new List<Bank_Account__c>();
        Bank_Account__c Bank_AccountAtradius = new Bank_Account__c();
        Bank_AccountAtradius.Account__c = accountAtradius.id;
        Bank_AccountAtradius.Bank_Name__c = 'Luna Bank';
        Bank_AccountAtradius.SWIFT_Code__c = 'Luna123456';
        Bank_AccountAtradius.Currency__c = 'USD';
        Bank_AccountAtradius.Country__c = 'VietNam';
        Bank_AccountAtradius.transfer_cutoff_time__c = '18:00';
        Bank_AccountAtradius.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountAtradius.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAtradius);
        
        Bank_Account__c Bank_AccountBuyer = new Bank_Account__c();
        Bank_AccountBuyer.Account__c = accountBuyer.id;
        Bank_AccountBuyer.Bank_Name__c = 'Luna Bank';
        Bank_AccountBuyer.SWIFT_Code__c = 'Luna123456';
        Bank_AccountBuyer.Currency__c = 'USD';
        Bank_AccountBuyer.Country__c = 'VietNam';
        Bank_AccountBuyer.transfer_cutoff_time__c = '18:00';
        Bank_AccountBuyer.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountBuyer.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountBuyer);
        
        Bank_Account__c Bank_AccountSupplier = new Bank_Account__c();
        Bank_AccountSupplier.Account__c = accountSupplier.id;
        Bank_AccountSupplier.Bank_Name__c = 'Luna Bank';
        Bank_AccountSupplier.SWIFT_Code__c = 'Luna123789';
        Bank_AccountSupplier.Currency__c = 'USD';
        Bank_AccountSupplier.Country__c = 'VietNam';
        Bank_AccountSupplier.transfer_cutoff_time__c = '18:00';
        Bank_AccountSupplier.Bank_Account_Number__c = '4514-5341345-1423423';
        Bank_AccountSupplier.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountSupplier);
        
        Bank_Account__c Bank_AccountAgent = new Bank_Account__c();
        Bank_AccountAgent.Account__c = accountAgent.id;
        Bank_AccountAgent.Bank_Name__c = 'Luna Bank';
        Bank_AccountAgent.SWIFT_Code__c = 'Luna456456';
        Bank_AccountAgent.Currency__c = 'USD';
        Bank_AccountAgent.Country__c = 'VietNam';
        Bank_AccountAgent.transfer_cutoff_time__c = '18:00';
        Bank_AccountAgent.Bank_Account_Number__c = '4514-5341345-1467587';
        Bank_AccountAgent.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAgent);
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountFunder);
        
        Bank_Account__c Bank_AccountIncomlendOperation = new Bank_Account__c();
        Bank_AccountIncomlendOperation.Account__c = accountIncomlendOperation.id;
        Bank_AccountIncomlendOperation.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendOperation.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendOperation.Currency__c = 'USD';
        Bank_AccountIncomlendOperation.Country__c = 'VietNam';
        Bank_AccountIncomlendOperation.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendOperation.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendOperation.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendOperation);
        
        Bank_Account__c Bank_AccountIncomlendSupplierDiscount = new Bank_Account__c();
        Bank_AccountIncomlendSupplierDiscount.Account__c = accountIncomlendSupplierDiscount.id;
        Bank_AccountIncomlendSupplierDiscount.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendSupplierDiscount.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendSupplierDiscount.Currency__c = 'USD';
        Bank_AccountIncomlendSupplierDiscount.Country__c = 'VietNam';
        Bank_AccountIncomlendSupplierDiscount.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendSupplierDiscount.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendSupplierDiscount.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendSupplierDiscount);
        
        Bank_Account__c Bank_AccountIncomlendGST = new Bank_Account__c();
        Bank_AccountIncomlendGST.Account__c = accountIncomlendGST.id;
        Bank_AccountIncomlendGST.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendGST.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendGST.Currency__c = 'USD';
        Bank_AccountIncomlendGST.Country__c = 'VietNam';
        Bank_AccountIncomlendGST.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendGST.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendGST.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendGST);
        
        Bank_Account__c Bank_AccountIncomlendfees = new Bank_Account__c();
        Bank_AccountIncomlendfees.Account__c = accountIncomlendfees.id;
        Bank_AccountIncomlendfees.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendfees.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendfees.Currency__c = 'USD';
        Bank_AccountIncomlendfees.Country__c = 'VietNam';
        Bank_AccountIncomlendfees.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendfees.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendfees.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendfees);
        
        Bank_Account__c Bank_AccountIncomlendAgentProvision = new Bank_Account__c();
        Bank_AccountIncomlendAgentProvision.Account__c = accountIncomlendAgentProvision.id;
        Bank_AccountIncomlendAgentProvision.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendAgentProvision.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendAgentProvision.Currency__c = 'USD';
        Bank_AccountIncomlendAgentProvision.Country__c = 'VietNam';
        Bank_AccountIncomlendAgentProvision.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendAgentProvision.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendAgentProvision.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendAgentProvision);
        
        insert listBankAccount;
        
        // FX rate
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        // factoring
        incomlend_product__c incomlend_product = new incomlend_product__c();
        incomlend_product.Name = 'Standard Insured - USD';
        incomlend_product.launch_date__c = Date.newInstance(2016, 11, 14);
        incomlend_product.CCYs__c = 'USD';
        incomlend_product.months_relationship_with_buyer__c = 12;
        incomlend_product.Auction_Type__c = 'Fixed Discount Rate';
        incomlend_product.approved__c = true;
        incomlend_product.insured__c = true;
        insert incomlend_product;
        
        Supplier_Buyer_Map__c Supplier_Buyer_Map = new Supplier_Buyer_Map__c();
        Supplier_Buyer_Map.Buyer__c = accountBuyer.id;
        Supplier_Buyer_Map.Supplier__c = accountSupplier.id;
        Supplier_Buyer_Map.Account_Agent__c = accountAgent.id;
        Supplier_Buyer_Map.Value_of_agent_s_fee__c = 15;
        Supplier_Buyer_Map.Incomlend_product__c = incomlend_product.id;
        Supplier_Buyer_Map.Marketplace__c = marketPlace.id;
        Supplier_Buyer_Map.buyer_supplier_map_approved__c = true;
        Supplier_Buyer_Map.map_onboarding_stage__c = '90.Onboarded';
        Supplier_Buyer_Map.Bangladesh_special_case__c = 'With factory';
        Insert Supplier_Buyer_Map;
        
        Map_Extension__c Map_Extension = new Map_Extension__c();
        Map_Extension.Account__c = accountIncomlendOperation.id;
        Map_Extension.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        Map_Extension.Map_extension_type__c = 'Factoring / Reverse Factoring';
        Map_Extension.Funding_Upfront_fees__c = false;
        Insert Map_Extension;
        
        invoice_finance_deal__c invoice = new invoice_finance_deal__c();
        invoice.Actual_Repayment_Amount__c = 1000000;
        invoice.Actual_Repayment_Received_Date__c = Date.newInstance(2021, 7, 10);
        //invoice.actual_financing_period__c = '4';
        //invoice.Actual_supplier_s_Agent_Commission_amt__c = 420;
        invoice.advance_send_to_supplier_date__c = Date.newInstance(2021, 7, 7);
        //invoice.Amount_Overdue__c = 0;
        
        invoice.CCY__c = 'USD';
        // if( credit_insured__c =false,0,ROUND(invoice_amount__c * credit_insurance_fee_percentage__c,2))
        // invoice.credit_insured__c  = Supplier_Buyer_Map__r.Incomlend_product__r.insured__c
        invoice.credit_insurance_fee_percentage__c = 1;
        
        invoice.discount_rate__c = 0.56;
        invoice.Due_Date__c = Date.newInstance(2021, 7, 28);
        //invoice.expected_financing_period__c = 12;
        invoice.Factory_Amount__c = 0;
        //invoice.funded_amount__c = 900000;
        invoice.invoice_amount__c = 10000000;
        invoice.requested_amount__c = 1000;
        invoice.Sum_Of_All_Pre_Reservations__c = 0;
        invoice.Insured_by__c = 'Atradius';
        invoice.Map_Extension__c = null;
        invoice.Marketplace_link__c = marketPlace.id;
        //invoice.Name = '012345';
        invoice.Notice_of_Assignment_signed__c = true;
        invoice.Phase__c = '2:ON MARKETPLACE';
        invoice.Status__c = 'On marketplace';
        //invoice.Supplier_balance__c = 100000;
        invoice.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        //invoice.Supplier_s_Agent_Commission_amount__c = 420;
        //invoice.Supplier_Country__c = 'China';
        invoice.Tolerance_overdue_days__c = 0;
        //invoice.Total_platform_fee__c = 0;
        invoice.Specific_additional_Platform_fee_amount__c = 1000;
        invoice.Total_Supplier_Discount__c = 0.7;
        //invoice.Total_supplier_discount_amount_expected__c = 2800;
        //invoice.Transaction_fees_overdue__c = 0;
        invoice.Trustee__c ='Amicorp Trust';
        //invoice.over_due_days__c = 0;
        invoice.supplier_invoice_reference_number__c = 'INV-0001';
        invoice.Real_Face_Value__c = 1000000;
        invoice.Factory_Amount__c = 100;
        invoice.Map_Extension__c = Map_Extension.id;
        insert invoice;
        
        invoice_finance_deal__c expected = [SELECT remaining_amount__c, funded_amount__c FROM invoice_finance_deal__c WHERE ID =:invoice.id];
        map<String,Decimal> actual = GlobalMethods_v9.createAllocationResponse(10, expected ,1000);
        System.assertEquals(10,actual.get('availableEwallet'));
        System.assertEquals(expected.remaining_amount__c,actual.get('remainingAmount'));
        System.assertEquals(1000,actual.get('reservationAmount'));
        System.assertEquals(expected.funded_amount__c,actual.get('fundedAmount'));
    }
    
    static testmethod void test_GlobalMethods_sendReservationSlack() {
        accounting_period__c accounting_period = new accounting_period__c();
        accounting_period.start_date__C = date.today();
        accounting_period.end_date__C = date.today();
        
        insert accounting_period;
        
        List<Account> listAccount = new List<Account>();
        // Incomlend Operations
        Account accountAtradius = new Account();
        accountAtradius.Name = 'Atradius';
        accountAtradius.Type = 'Partner';
        accountAtradius.Sub_type__c = 'NA';
        accountAtradius.VAT_applicable__c = true;
        listAccount.add(accountAtradius);
        
        // Incomlend Operations
        Account accountIncomlendOperation = new Account();
        accountIncomlendOperation.Name = 'Incomlend Operations';
        accountIncomlendOperation.Type = 'Internal';
        accountIncomlendOperation.Sub_type__c = 'NA';
        accountIncomlendOperation.VAT_applicable__c = true;
        listAccount.add(accountIncomlendOperation);
        
        // Incomlend - Supplier Discount
        Account accountIncomlendSupplierDiscount = new Account();
        accountIncomlendSupplierDiscount.Name = 'Incomlend - Supplier Discount';
        accountIncomlendSupplierDiscount.Type = 'Internal';
        accountIncomlendSupplierDiscount.Sub_type__c = 'NA';
        accountIncomlendSupplierDiscount.VAT_applicable__c = true;
        listAccount.add(accountIncomlendSupplierDiscount);
        
        // Incomlend GST
        Account accountIncomlendGST = new Account();
        accountIncomlendGST.Name = 'Incomlend GST';
        accountIncomlendGST.Type = 'Internal';
        accountIncomlendGST.Sub_type__c = 'NA';
        accountIncomlendGST.VAT_applicable__c = true;
        listAccount.add(accountIncomlendGST);
        
        // Incomlend - fees
        Account accountIncomlendfees = new Account();
        accountIncomlendfees.Name = 'Incomlend - fees';
        accountIncomlendfees.Type = 'Internal';
        accountIncomlendfees.Sub_type__c = 'NA';
        accountIncomlendfees.VAT_applicable__c = true;
        listAccount.add(accountIncomlendfees);
        
        // Incomlend Agent Provision
        Account accountIncomlendAgentProvision = new Account();
        accountIncomlendAgentProvision.Name = 'Incomlend Agent Provision';
        accountIncomlendAgentProvision.Type = 'Internal';
        accountIncomlendAgentProvision.Sub_type__c = 'NA';
        accountIncomlendAgentProvision.VAT_applicable__c = true;
        listAccount.add(accountIncomlendAgentProvision);
        
        Account accountBuyer = new Account();
        accountBuyer.Name = 'Buyer';
        accountBuyer.Type = 'Buyer';
        accountBuyer.Sub_type__c = 'Buyer';
        accountBuyer.Country_of_Incorporation__c = 'United States';
        accountBuyer.VAT_applicable__c = true;
        listAccount.add(accountBuyer);
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0;
        listAccount.add(accountSupplier);
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        
        Account accountFunder = new Account();
        accountFunder.Name = 'Funder';
        accountFunder.Type = 'Customer';
        accountFunder.Sub_type__c = 'Purchaser';
        accountFunder.Country_of_Incorporation__c = 'United States';
        accountFunder.VAT_applicable__c = true;
        accountFunder.Agent__c = accountAgent.id;
        accountFunder.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
        
        listAccount.add(accountFunder);
        
        insert listAccount;
        
        List<Bank_Account__c> listBankAccount = new List<Bank_Account__c>();
        Bank_Account__c Bank_AccountAtradius = new Bank_Account__c();
        Bank_AccountAtradius.Account__c = accountAtradius.id;
        Bank_AccountAtradius.Bank_Name__c = 'Luna Bank';
        Bank_AccountAtradius.SWIFT_Code__c = 'Luna123456';
        Bank_AccountAtradius.Currency__c = 'USD';
        Bank_AccountAtradius.Country__c = 'VietNam';
        Bank_AccountAtradius.transfer_cutoff_time__c = '18:00';
        Bank_AccountAtradius.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountAtradius.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAtradius);
        
        Bank_Account__c Bank_AccountBuyer = new Bank_Account__c();
        Bank_AccountBuyer.Account__c = accountBuyer.id;
        Bank_AccountBuyer.Bank_Name__c = 'Luna Bank';
        Bank_AccountBuyer.SWIFT_Code__c = 'Luna123456';
        Bank_AccountBuyer.Currency__c = 'USD';
        Bank_AccountBuyer.Country__c = 'VietNam';
        Bank_AccountBuyer.transfer_cutoff_time__c = '18:00';
        Bank_AccountBuyer.Bank_Account_Number__c = '4514-5341345-1451453';
        Bank_AccountBuyer.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountBuyer);
        
        Bank_Account__c Bank_AccountSupplier = new Bank_Account__c();
        Bank_AccountSupplier.Account__c = accountSupplier.id;
        Bank_AccountSupplier.Bank_Name__c = 'Luna Bank';
        Bank_AccountSupplier.SWIFT_Code__c = 'Luna123789';
        Bank_AccountSupplier.Currency__c = 'USD';
        Bank_AccountSupplier.Country__c = 'VietNam';
        Bank_AccountSupplier.transfer_cutoff_time__c = '18:00';
        Bank_AccountSupplier.Bank_Account_Number__c = '4514-5341345-1423423';
        Bank_AccountSupplier.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountSupplier);
        
        Bank_Account__c Bank_AccountAgent = new Bank_Account__c();
        Bank_AccountAgent.Account__c = accountAgent.id;
        Bank_AccountAgent.Bank_Name__c = 'Luna Bank';
        Bank_AccountAgent.SWIFT_Code__c = 'Luna456456';
        Bank_AccountAgent.Currency__c = 'USD';
        Bank_AccountAgent.Country__c = 'VietNam';
        Bank_AccountAgent.transfer_cutoff_time__c = '18:00';
        Bank_AccountAgent.Bank_Account_Number__c = '4514-5341345-1467587';
        Bank_AccountAgent.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountAgent);
        
        Bank_Account__c Bank_AccountFunder = new Bank_Account__c();
        Bank_AccountFunder.Account__c = accountFunder.id;
        Bank_AccountFunder.Bank_Name__c = 'Luna Bank';
        Bank_AccountFunder.SWIFT_Code__c = 'Luna234234';
        Bank_AccountFunder.Currency__c = 'USD';
        Bank_AccountFunder.Country__c = 'VietNam';
        Bank_AccountFunder.transfer_cutoff_time__c = '18:00';
        Bank_AccountFunder.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountFunder.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountFunder);
        
        Bank_Account__c Bank_AccountIncomlendOperation = new Bank_Account__c();
        Bank_AccountIncomlendOperation.Account__c = accountIncomlendOperation.id;
        Bank_AccountIncomlendOperation.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendOperation.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendOperation.Currency__c = 'USD';
        Bank_AccountIncomlendOperation.Country__c = 'VietNam';
        Bank_AccountIncomlendOperation.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendOperation.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendOperation.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendOperation);
        
        Bank_Account__c Bank_AccountIncomlendSupplierDiscount = new Bank_Account__c();
        Bank_AccountIncomlendSupplierDiscount.Account__c = accountIncomlendSupplierDiscount.id;
        Bank_AccountIncomlendSupplierDiscount.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendSupplierDiscount.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendSupplierDiscount.Currency__c = 'USD';
        Bank_AccountIncomlendSupplierDiscount.Country__c = 'VietNam';
        Bank_AccountIncomlendSupplierDiscount.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendSupplierDiscount.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendSupplierDiscount.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendSupplierDiscount);
        
        Bank_Account__c Bank_AccountIncomlendGST = new Bank_Account__c();
        Bank_AccountIncomlendGST.Account__c = accountIncomlendGST.id;
        Bank_AccountIncomlendGST.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendGST.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendGST.Currency__c = 'USD';
        Bank_AccountIncomlendGST.Country__c = 'VietNam';
        Bank_AccountIncomlendGST.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendGST.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendGST.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendGST);
        
        Bank_Account__c Bank_AccountIncomlendfees = new Bank_Account__c();
        Bank_AccountIncomlendfees.Account__c = accountIncomlendfees.id;
        Bank_AccountIncomlendfees.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendfees.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendfees.Currency__c = 'USD';
        Bank_AccountIncomlendfees.Country__c = 'VietNam';
        Bank_AccountIncomlendfees.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendfees.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendfees.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendfees);
        
        Bank_Account__c Bank_AccountIncomlendAgentProvision = new Bank_Account__c();
        Bank_AccountIncomlendAgentProvision.Account__c = accountIncomlendAgentProvision.id;
        Bank_AccountIncomlendAgentProvision.Bank_Name__c = 'Luna Bank';
        Bank_AccountIncomlendAgentProvision.SWIFT_Code__c = 'Luna234234';
        Bank_AccountIncomlendAgentProvision.Currency__c = 'USD';
        Bank_AccountIncomlendAgentProvision.Country__c = 'VietNam';
        Bank_AccountIncomlendAgentProvision.transfer_cutoff_time__c = '18:00';
        Bank_AccountIncomlendAgentProvision.Bank_Account_Number__c = '4514-5341345-1450345';
        Bank_AccountIncomlendAgentProvision.Beneficiary_Name__c = 'Some Company Pte Ltd';
        listBankAccount.add(Bank_AccountIncomlendAgentProvision);
        
        insert listBankAccount;
        
        // FX rate
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        
        // factoring
        incomlend_product__c incomlend_product = new incomlend_product__c();
        incomlend_product.Name = 'Standard Insured - USD';
        incomlend_product.launch_date__c = Date.newInstance(2016, 11, 14);
        incomlend_product.CCYs__c = 'USD';
        incomlend_product.months_relationship_with_buyer__c = 12;
        incomlend_product.Auction_Type__c = 'Fixed Discount Rate';
        incomlend_product.approved__c = true;
        incomlend_product.insured__c = true;
        insert incomlend_product;
        
        Supplier_Buyer_Map__c Supplier_Buyer_Map = new Supplier_Buyer_Map__c();
        Supplier_Buyer_Map.Buyer__c = accountBuyer.id;
        Supplier_Buyer_Map.Supplier__c = accountSupplier.id;
        Supplier_Buyer_Map.Account_Agent__c = accountAgent.id;
        Supplier_Buyer_Map.Value_of_agent_s_fee__c = 15;
        Supplier_Buyer_Map.Incomlend_product__c = incomlend_product.id;
        Supplier_Buyer_Map.Marketplace__c = marketPlace.id;
        Supplier_Buyer_Map.buyer_supplier_map_approved__c = true;
        Supplier_Buyer_Map.map_onboarding_stage__c = '90.Onboarded';
        Supplier_Buyer_Map.Bangladesh_special_case__c = 'With factory';
        Insert Supplier_Buyer_Map;
        
        Map_Extension__c Map_Extension = new Map_Extension__c();
        Map_Extension.Account__c = accountIncomlendOperation.id;
        Map_Extension.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        Map_Extension.Map_extension_type__c = 'Factoring / Reverse Factoring';
        Map_Extension.Funding_Upfront_fees__c = false;
        Insert Map_Extension;
        
        invoice_finance_deal__c invoice = new invoice_finance_deal__c();
        invoice.Actual_Repayment_Amount__c = 1000000;
        invoice.Actual_Repayment_Received_Date__c = Date.newInstance(2021, 7, 10);
        //invoice.actual_financing_period__c = '4';
        //invoice.Actual_supplier_s_Agent_Commission_amt__c = 420;
        invoice.advance_send_to_supplier_date__c = Date.newInstance(2021, 7, 7);
        //invoice.Amount_Overdue__c = 0;
        
        invoice.CCY__c = 'USD';
        // if( credit_insured__c =false,0,ROUND(invoice_amount__c * credit_insurance_fee_percentage__c,2))
        // invoice.credit_insured__c  = Supplier_Buyer_Map__r.Incomlend_product__r.insured__c
        invoice.credit_insurance_fee_percentage__c = 1;
        
        invoice.discount_rate__c = 0.56;
        invoice.Due_Date__c = Date.newInstance(2021, 7, 28);
        //invoice.expected_financing_period__c = 12;
        invoice.Factory_Amount__c = 0;
        //invoice.funded_amount__c = 900000;
        invoice.invoice_amount__c = 10000000;
        invoice.requested_amount__c = 0;
        invoice.Sum_Of_All_Pre_Reservations__c = 0;
        invoice.Insured_by__c = 'Atradius';
        invoice.Map_Extension__c = null;
        invoice.Marketplace_link__c = marketPlace.id;
        //invoice.Name = '012345';
        invoice.Notice_of_Assignment_signed__c = true;
        invoice.Phase__c = '2:ON MARKETPLACE';
        invoice.Status__c = 'On marketplace';
        //invoice.Supplier_balance__c = 100000;
        invoice.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        //invoice.Supplier_s_Agent_Commission_amount__c = 420;
        //invoice.Supplier_Country__c = 'China';
        invoice.Tolerance_overdue_days__c = 0;
        //invoice.Total_platform_fee__c = 0;
        invoice.Specific_additional_Platform_fee_amount__c = 1000;
        invoice.Total_Supplier_Discount__c = 0.7;
        //invoice.Total_supplier_discount_amount_expected__c = 2800;
        //invoice.Transaction_fees_overdue__c = 0;
        invoice.Trustee__c ='Amicorp Trust';
        //invoice.over_due_days__c = 0;
        invoice.supplier_invoice_reference_number__c = 'INV-0001';
        invoice.Real_Face_Value__c = 1000000;
        invoice.Factory_Amount__c = 100;
        invoice.Map_Extension__c = Map_Extension.id;
        insert invoice;
        
        Contact contact = new Contact();
        contact.LastName = 'Luna';
        contact.AccountId = accountAgent.id;
        contact.Linkedin_username__c = 'Luna@yopmail.com';
        insert contact;
        
        invoice_finance_deal__c expected = [SELECT remaining_amount__c, funded_amount__c FROM invoice_finance_deal__c WHERE ID =:invoice.id];
        GlobalMethods_v9.sendReservationSlack('', invoice.id ,1000 ,'true' , System.now(), TRUE, '', 100);
        GlobalMethods_v9.sendReservationSlack('', invoice.id ,1000 ,'false' , System.now(), TRUE, '', 100);
        GlobalMethods_v9.sendReservationSlack('', invoice.id ,1000 ,'true' , System.now(), FALSE, '', 100);
        
        GlobalMethods_v9.createReservationLog(contact.id, invoice.id, 100, 'true', System.now(), TRUE, 1000);
        GlobalMethods_v9.createReservationLog(contact.id, invoice.id, 100, 'false', System.now(), TRUE, 1000);
        
        
        String maskedAccount2 = GlobalMethods_v9.createMaskedAccountNumber('abcdxyz');
    }
    
    static testmethod void test_GlobalMethods_createMaskedAccountNumber1() {
        
        String actual = GlobalMethods_v9.createMaskedAccountNumber('wxyzabcd');
        System.assertEquals('****abcd', actual);
    }
    
    static testmethod void test_GlobalMethods_createMaskedAccountNumber2() {
        
        String actual = GlobalMethods_v9.createMaskedAccountNumber('abcdwxyz');
        System.assertEquals('****wxyz', actual);
    }
    
    static testmethod void test_GlobalMethods_InvoiceListReturnClassFalse() {
        
        GlobalMethods_v9.InvoiceListReturnClass actual = new GlobalMethods_v9.InvoiceListReturnClass('false','Invalid user', null);
        
        System.assertEquals('false', actual.v_success);
        System.assertEquals('Invalid user', actual.v_message);
        System.assertEquals(null, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_InvoiceListReturnClassOK() {
        
        List<Account> listAccount = new List<Account>();
        Account accountBuyer = new Account();
        accountBuyer.Name = 'Buyer';
        accountBuyer.Type = 'Buyer';
        accountBuyer.Sub_type__c = 'Buyer';
        accountBuyer.Country_of_Incorporation__c = 'United States';
        accountBuyer.VAT_applicable__c = true;
        listAccount.add(accountBuyer);
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0.5;
        listAccount.add(accountSupplier);
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        
        insert listAccount;
        
        // FX rate
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        // factoring
        incomlend_product__c incomlend_product = new incomlend_product__c();
        incomlend_product.Name = 'Standard Insured - USD';
        incomlend_product.launch_date__c = Date.newInstance(2016, 11, 14);
        incomlend_product.CCYs__c = 'USD';
        incomlend_product.months_relationship_with_buyer__c = 12;
        incomlend_product.Auction_Type__c = 'Fixed Discount Rate';
        incomlend_product.approved__c = true;
        incomlend_product.insured__c = true;
        insert incomlend_product;
        
        Supplier_Buyer_Map__c Supplier_Buyer_Map = new Supplier_Buyer_Map__c();
        Supplier_Buyer_Map.Buyer__c = accountBuyer.id;
        Supplier_Buyer_Map.Supplier__c = accountSupplier.id;
        Supplier_Buyer_Map.Account_Agent__c = accountAgent.id;
        Supplier_Buyer_Map.Value_of_agent_s_fee__c = 15;
        Supplier_Buyer_Map.Incomlend_product__c = incomlend_product.id;
        Supplier_Buyer_Map.Marketplace__c = marketPlace.id;
        Supplier_Buyer_Map.buyer_supplier_map_approved__c = true;
        Supplier_Buyer_Map.map_onboarding_stage__c = '90.Onboarded';
        Insert Supplier_Buyer_Map;
        
        List<invoice_finance_deal__c> listInvoice = new List<invoice_finance_deal__c>();
        invoice_finance_deal__c invoice = new invoice_finance_deal__c();
        invoice.Trustee__c = 'Amicorp Escrow';
        invoice.Buyer_Confirmation_Status__c = '';
        invoice.supplier_approval_status__c = '';
        invoice.Earliest_date_of_funding__c = Date.newInstance(2016, 11, 14);
        invoice.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        invoice.Actual_Repayment_Received_Date__c = Date.newInstance(2016, 11, 14);
        invoice.Expected_Payment_Date__c = Date.newInstance(2016, 11, 14);
        invoice.submitted_date__c = Date.newInstance(2016, 11, 14);
        invoice.buyer_purchase_order_reference__c = '';
        invoice.supplier_invoice_reference_number__c = '';
        invoice.invoice_amount__c = 10000;
        invoice.Listing_Start__c = Date.newInstance(2016, 11, 14);
        invoice.Listing_End__c = Date.newInstance(2016, 11, 14);
        invoice.Phase__c = '2:ON MARKETPLACE';
        invoice.Status__c = 'On marketplace';
        invoice.Invoice_date__c = Date.newInstance(2016, 11, 14);
        invoice.discount_rate__c = 1;
        invoice.Due_Date__c = Date.newInstance(2016, 11, 14);
        invoice.requested_amount__c = 500;
        invoice.platform_fee_fixed__c = 100;
        invoice.Total_Supplier_Discount__c = 100;
        invoice.Real_Face_Value__c = 100;
        invoice.Country_of_Origin__c = '';
        invoice.Country_of_Destination__c = '';
        invoice.Insured_by__c = '';
        invoice.Sector__c = '';
        invoice.Goods_and_Services_new__c = '';
        invoice.Display_on_Secondary_Marketplace__c = true;
        invoice.supplier_invoice_reference_number__c = 'INV-0001';
        listInvoice.add(invoice);
        Insert listInvoice;
        
        GlobalMethods_v9.InvoiceListReturnClass actual = new GlobalMethods_v9.InvoiceListReturnClass('true','Query executed successfully.', listInvoice);
        
        System.assertEquals('true', actual.v_success);
        System.assertEquals('Query executed successfully.', actual.v_message);
        System.assertEquals(listInvoice, actual.v_records);
    }
    
    static testmethod void test_GlobalMethods_InitClass() {
        new GlobalMethods_v9.ResponseClass(0,'','');
        new GlobalMethods_v9.AccountReturnClass('','',null,true);
        new GlobalMethods_v9.AccountReturnClass('','',null,true,null,'');
        new GlobalMethods_v9.AccountReturnClass('','',null,true,null,'',null);
        new GlobalMethods_v9.AccountListReturnClass('','',null);
        new GlobalMethods_v9.ContactListReturnClass('','',null);
        new GlobalMethods_v9.DecimalMapReturnClass('','',null);
        new GlobalMethods_v9.InvoiceReturnClass('','',null,System.today());
        new GlobalMethods_v9.BuyerMapListReturnClass('','',null);
        new GlobalMethods_v9.AllocationListReturnClass('','',null);
        new GlobalMethods_v9.MarketplaceReturnClass('','',null);
        new GlobalMethods_v9.MarketplaceListReturnClass('','',null);
        new GlobalMethods_v9.BankAccountListReturnClass('','',null);
        new GlobalMethods_v9.TransactionReturnClass('','',null);
        new GlobalMethods_v9.TransactionListReturnClass('','',null);
        new GlobalMethods_v9.StringMapReturnClass('','',null);
        new GlobalMethods_v9.ListMapReturnClass('','',null);
        new GlobalMethods_v9.MapProductListReturnClass('','',null);
        new GlobalMethods_v9.MapSupportingDocsListReturnClass('','',null);
        new GlobalMethods_v9.WithdrawalDepositReturnClass('','',null);
        new GlobalMethods_v9.EwalletListReturnClass('','',null);
        new GlobalMethods_v9.EwalletTrusteeListReturnClass('','',null);
        new GlobalMethods_v9.AuditReturnClass('','',true);
        new GlobalMethods_v9.AuditReturnClass('','',new Audit_Trail__c());
        new GlobalMethods_v9.AuditReturnClass('','',new List<Audit_Trail__c>());
        new GlobalMethods_v9.OnboardingChecklistListReturnClass('','',new List<onboarding_checklist__c>());
        
    }
    
    static testmethod void test_GlobalMethods_InvoiceDocReturnClass() {
        List<Account> listAccount = new List<Account>();
        Account accountBuyer = new Account();
        accountBuyer.Name = 'Buyer';
        accountBuyer.Type = 'Buyer';
        accountBuyer.Sub_type__c = 'Buyer';
        accountBuyer.Country_of_Incorporation__c = 'United States';
        accountBuyer.VAT_applicable__c = true;
        listAccount.add(accountBuyer);
        
        Account accountSupplier = new Account();
        accountSupplier.Name = 'Supplier';
        accountSupplier.Type = 'Supplier';
        accountSupplier.Sub_type__c = 'Supplier';
        accountSupplier.Country_of_Incorporation__c = 'United States';
        accountSupplier.VAT_applicable__c = true;
        accountSupplier.Credit_insurance_fee__c = 0.5;
        listAccount.add(accountSupplier);
        
        Account accountAgent = new Account();
        accountAgent.Name = 'Agent';
        accountAgent.Type = 'Agent';
        accountAgent.Sub_type__c = 'Agent';
        accountAgent.Country_of_Incorporation__c = 'United States';
        accountAgent.VAT_applicable__c = true;
        accountAgent.Agent_Commision_Purchaser_Type__c = 'Annual Rate (365d/year)';
        listAccount.add(accountAgent);
        
        insert listAccount;
        
        // FX rate
        FX_Rates__c rate = new FX_Rates__c();
        rate.rate__c = 1;
        rate.from_currency__c = 'USD';
        rate.date__c = Date.newInstance(2017, 01, 01);
        rate.to_currency__c = 'USD';
        
        insert rate;
        
        // Market Place
        Marketplace__c marketPlace = new Marketplace__c();
        marketPlace.Name = 'USD';
        marketPlace.FX_Rate_for_MI__c = rate.id;
        marketPlace.currency_symbol__c = 'US$';
        marketPlace.minimum_purchase_amount__c = 1;
        
        insert marketPlace;
        // factoring
        incomlend_product__c incomlend_product = new incomlend_product__c();
        incomlend_product.Name = 'Standard Insured - USD';
        incomlend_product.launch_date__c = Date.newInstance(2016, 11, 14);
        incomlend_product.CCYs__c = 'USD';
        incomlend_product.months_relationship_with_buyer__c = 12;
        incomlend_product.Auction_Type__c = 'Fixed Discount Rate';
        incomlend_product.approved__c = true;
        incomlend_product.insured__c = true;
        insert incomlend_product;
        
        Supplier_Buyer_Map__c Supplier_Buyer_Map = new Supplier_Buyer_Map__c();
        Supplier_Buyer_Map.Buyer__c = accountBuyer.id;
        Supplier_Buyer_Map.Supplier__c = accountSupplier.id;
        Supplier_Buyer_Map.Account_Agent__c = accountAgent.id;
        Supplier_Buyer_Map.Value_of_agent_s_fee__c = 15;
        Supplier_Buyer_Map.Incomlend_product__c = incomlend_product.id;
        Supplier_Buyer_Map.Marketplace__c = marketPlace.id;
        Supplier_Buyer_Map.buyer_supplier_map_approved__c = true;
        Supplier_Buyer_Map.map_onboarding_stage__c = '90.Onboarded';
        Insert Supplier_Buyer_Map;
        
        List<invoice_finance_deal__c> listInvoice = new List<invoice_finance_deal__c>();
        invoice_finance_deal__c invoice = new invoice_finance_deal__c();
        invoice.Trustee__c = 'Amicorp Escrow';
        invoice.Buyer_Confirmation_Status__c = '';
        invoice.supplier_approval_status__c = '';
        invoice.Earliest_date_of_funding__c = Date.newInstance(2016, 11, 14);
        invoice.Supplier_Buyer_Map__c = Supplier_Buyer_Map.id;
        invoice.Actual_Repayment_Received_Date__c = Date.newInstance(2016, 11, 14);
        invoice.Expected_Payment_Date__c = Date.newInstance(2016, 11, 14);
        invoice.submitted_date__c = Date.newInstance(2016, 11, 14);
        invoice.buyer_purchase_order_reference__c = '';
        invoice.supplier_invoice_reference_number__c = '';
        invoice.invoice_amount__c = 10000;
        invoice.Listing_Start__c = Date.newInstance(2016, 11, 14);
        invoice.Listing_End__c = Date.newInstance(2016, 11, 14);
        invoice.Phase__c = '2:ON MARKETPLACE';
        invoice.Status__c = 'On marketplace';
        invoice.Invoice_date__c = Date.newInstance(2016, 11, 14);
        invoice.discount_rate__c = 1;
        invoice.Due_Date__c = Date.newInstance(2016, 11, 14);
        invoice.requested_amount__c = 500;
        invoice.platform_fee_fixed__c = 100;
        invoice.Total_Supplier_Discount__c = 100;
        invoice.Real_Face_Value__c = 100;
        invoice.Country_of_Origin__c = '';
        invoice.Country_of_Destination__c = '';
        invoice.Insured_by__c = '';
        invoice.Sector__c = '';
        invoice.Goods_and_Services_new__c = '';
        invoice.Display_on_Secondary_Marketplace__c = true;
        invoice.supplier_invoice_reference_number__c = 'INV-0001';
        listInvoice.add(invoice);
        Insert listInvoice;
        
        Map_Supporting_Doc__c objMapSupportingDoc = new Map_Supporting_Doc__c();
        objMapSupportingDoc.Supplier_Buyer_Map__c = Supplier_Buyer_Map.Id;
        objMapSupportingDoc.Document_Type__c = 'Invoice Example';
        objMapSupportingDoc.Required_from__c = 'Supplier';
        insert objMapSupportingDoc;
        
        Invoice_supporting_documents__c objInvSupportingDoc = new Invoice_supporting_documents__c();
        objInvSupportingDoc.Invoice_Finance_deal__c = listInvoice[0].Id;
        objInvSupportingDoc.Map_Supporting_Doc__c = objMapSupportingDoc.Id;
        insert objInvSupportingDoc;
        
        GlobalMethods_v9.InvoiceDocReturnClass actual = new GlobalMethods_v9.InvoiceDocReturnClass('true','Invoice Supporting Doc Created', objInvSupportingDoc);
        
        System.assertEquals('true', actual.v_success);
        System.assertEquals('Invoice Supporting Doc Created', actual.v_message);
        System.assertEquals(objInvSupportingDoc, actual.v_record);
    }

    
}