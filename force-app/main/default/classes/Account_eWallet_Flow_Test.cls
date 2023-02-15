@isTest
private class Account_eWallet_Flow_Test {
    static testMethod void myTest() {
        
        ICL_Settings__c objSettings = new ICL_Settings__c();
        objSettings.Enable_migrate_flow__c = True;
        insert objSettings;
        
        //Create Agent Account with Primary Contact
        Account objAccountAgent = new Account();
        objAccountAgent.Name = 'Test Account 1';
        objAccountAgent.Type = 'Agent';
        objAccountAgent.Primary_contact_email__c = 'Test@primaryContact.Com';
        insert objAccountAgent;
        
        Contact objAgentPrimaryContact = new Contact();
        objAgentPrimaryContact.FirstName = 'Test';
        objAgentPrimaryContact.LastName = 'Contact - 1';
        objAgentPrimaryContact.Email = 'test@testcontact.com';
        objAgentPrimaryContact.AccountId = objAccountAgent.Id;
        insert objAgentPrimaryContact;
        
        objAccountAgent.Primary_Contact__c = objAgentPrimaryContact.Id;
        Update objAccountAgent;
        
        Account ObjSupplierAccount = new Account();
        ObjSupplierAccount.Name = 'Test Suuplier Account - 1';
        ObjSupplierAccount.Type = 'Supplier';
        ObjSupplierAccount.Agent__c = objAccountAgent.Id;
        ObjSupplierAccount.onboarding_stage__c = '99.Onboarded';
        ObjSupplierAccount.Sales_Owner__c = userInfo.getUserId();
        ObjSupplierAccount.Sub_type__c = 'Supplier';
        //ObjSupplierAccount.Account_Name_for_unique_index__c = 'Temp';
        insert ObjSupplierAccount;

        Contact objSupplierPrimaryContact = objAgentPrimaryContact.clone(false, true, false, false);
        objSupplierPrimaryContact.AccountId = ObjSupplierAccount.Id;
        objSupplierPrimaryContact.Email = 'Test2@primaryContact.Com';
        insert objSupplierPrimaryContact;

        ObjSupplierAccount.Primary_Contact__c = objSupplierPrimaryContact.Id;
        update ObjSupplierAccount;
        
        Account objAccount = [Select Id ,Agent_Email__c, Onboarding_completed_date__c, Account_Name_for_unique_index__c, Master_Agent_Email__c, Primary_contact_email__c  from Account where Id =: ObjSupplierAccount.Id];
        
        System.assertEquals(objAccount.Account_Name_for_unique_index__c , ObjSupplierAccount.Name + ' : ' + ObjSupplierAccount.Type + ' : ' + ObjSupplierAccount.Sub_type__c);
        System.assertEquals(objAccount.Agent_Email__c , 'test@testcontact.com');
        System.assertEquals(objAccount.Master_Agent_Email__c , null);
        System.assert(objAccount.Primary_contact_email__c.equalsIgnoreCase('Test2@primaryContact.Com'));
        System.assertEquals(objAccount.Onboarding_completed_date__c , system.today());

        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        
        Accounting_Period__c objAccountingPeriod = new Accounting_Period__c();
        objAccountingPeriod.Name = 'Test Accounting Period';
        objAccountingPeriod.Start_Date__c = firstDayOfMonth;
        objAccountingPeriod.End_Date__c = lastDayOfMonth;
        insert objAccountingPeriod;
        
        Bank_Account__c objBankAccount = new Bank_Account__c();
        objBankAccount.Account__c = objAccount.id;
        objBankAccount.Beneficiary_Name__c = 'coddle';
        objBankAccount.Bank_Account_Number__c = '121215554455';
        objBankAccount.Currency__c = 'XXX';
        objBankAccount.Purpose__c = 'Bank Account for USD withdrawals1';
        objBankAccount.Incomlend_Account__c = 'Customer';
        objBankAccount.SWIFT_Code__c = 'SF44545';
        objBankAccount.Bank_Name__c = 'HSBC1';
        objBankAccount.Address__c = 'HSBC, Hong Kong';        
        objBankAccount.Country__c = 'Hong Kong';
        objBankAccount.estimated_transfer_time__c = 1;
        objBankAccount.transfer_cutoff_time__c = '5pm';        
        insert objBankAccount;
        
        FX_Rates__c objFxRate = new FX_Rates__c();
        objFxRate.from_currency__c = 'GBP';
        objFxRate.from_currency__c = 'GBP';
        objFxRate.to_currency__c = 'USD';
        objFxRate.date__c = system.today();
        objFxRate.rate__c = 1.207980;
        insert objFxRate;
        
        Marketplace__c objMarketPlace = new Marketplace__c();
        objMarketPlace.Name = 'GBP insured';
        objMarketplace.Currency__c = 'GBP';
        objMarketplace.latest_to_usd_rate__c = 1.207980;
        objMarketplace.FX_Rate_for_MI__c = objFxRate.Id;
        objMarketplace.currency_symbol__c = '£';
        objMarketplace.minimum_purchase_amount__c = 0;
        insert objMarketplace;
        
        eWallet__c objEwallet = new eWallet__c();
        objEwallet.Account__c = objAccount.id;
        objEwallet.Bank_Account__c = objBankAccount.Id;
        objEwallet.CCY__c = 'GBP';
        objEwallet.Marketplace_for_FX__c = objMarketplace.Id;
        objeWallet.Balance__c = 1000000;
        objeWallet.Reservations__c = 0;
        insert objEwallet;
        
        Marketplace__c objMarketPlaceSGD = new Marketplace__c();
        objMarketPlaceSGD.Name = 'SGD insured';
        objMarketPlaceSGD.Currency__c = 'SGD';
        objMarketPlaceSGD.latest_to_usd_rate__c = 1.41;
        objMarketPlaceSGD.FX_Rate_for_MI__c = objFxRate.Id;
        objMarketPlaceSGD.currency_symbol__c = 'S$';
        objMarketPlaceSGD.minimum_purchase_amount__c = 0;
        insert objMarketPlaceSGD;
        
        eWallet_Trustee__c objEWalletTrustee1 = new eWallet_Trustee__c();
        objEWalletTrustee1.Account__c = objAccount.id;
        objEWalletTrustee1.CCY__c = 'GBP';
        objEWalletTrustee1.Marketplace_for_FX__c = objMarketplace.Id;
        objEWalletTrustee1.Main_eWallet__c = objEwallet.Id;
        objEWalletTrustee1.Balance__c = 1000000;
        objEWalletTrustee1.Trustee__c = 'Amicorp Trust';
        insert objEWalletTrustee1;
        
        eWallet_Trustee__c objEWalletTrustee2 = new eWallet_Trustee__c();
        objEWalletTrustee2.Account__c = objAccount.id;
        objEWalletTrustee2.CCY__c = 'GBP';
        objEWalletTrustee2.Marketplace_for_FX__c = objMarketplace.Id;
        objEWalletTrustee2.Main_eWallet__c = objEwallet.Id;
        objEWalletTrustee2.Balance__c = 1000000;
        objEWalletTrustee2.Trustee__c = 'Amicorp Escrow';
        insert objEWalletTrustee2;
        
        objAccount.GBP_eWallet__c = objEwallet.Id;
        objAccount.Marketplace_for_GBP_FX_rate__c = objMarketplace.Id;
        objAccount.Marketplace_for_SGD_FX_rate__c = objMarketPlaceSGD.Id;
        objAccount.Ready_for_Withdrawal__c = True;
        objAccount.onboarding_approved__c = True;
        objAccount.BillingStreet = 'Test Street';
        objAccount.BillingCity = 'Test City';
        objAccount.BillingState = 'Test State';
        objAccount.BillingCountry = 'Test Country';
        objAccount.BillingPostalCode = '12345';
        objAccount.Address_Shipping_is_Address_Billing__c = True;
        objAccount.Account_transferred_another_Sales__c = true;
        update objAccount;
        
        objAccount = [Select Id , Transferred_Date__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, 
                      BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode,
                      XXX_Available_eWallet__c,XXX_Total_in_progress_invoices__c,  XXX_eWallet_Balance__c, GBP_Available_eWallet_USD_Equiv__c, GBP_Total_in_progress_Invoices_USD_Equiv__c, GBP_eWallet_USD_Equiv__c from Account where Id =: ObjSupplierAccount.Id];
        
        Decimal GBPAvailableeWalletUSDEquiv = objMarketplace.latest_to_usd_rate__c * objAccount.XXX_Available_eWallet__c;
        Decimal GBPeWalletUSDEquiv = objMarketplace.latest_to_usd_rate__c * objAccount.XXX_eWallet_Balance__c;
        Decimal GBPTotalinprogressInvoicesUSDEquiv = objAccount.XXX_Total_in_progress_invoices__c * objMarketplace.latest_to_usd_rate__c;
        
        System.assertEquals(objAccount.GBP_Available_eWallet_USD_Equiv__c , GBPAvailableeWalletUSDEquiv);
        System.assertEquals(objAccount.GBP_Total_in_progress_Invoices_USD_Equiv__c , GBPTotalinprogressInvoicesUSDEquiv);
        System.assertEquals(objAccount.GBP_eWallet_USD_Equiv__c , GBPeWalletUSDEquiv);
        /*System.assertEquals(objAccount.ShippingStreet , objAccount.BillingStreet);
        System.assertEquals(objAccount.ShippingCity , objAccount.BillingCity);
        System.assertEquals(objAccount.ShippingState , objAccount.BillingState );
        System.assertEquals(objAccount.ShippingCountry , objAccount.BillingCountry);
        System.assertEquals(objAccount.ShippingPostalCode , objAccount.BillingPostalCode);*/
        System.debug(objAccount.Transferred_Date__c + ' ' + (objAccount.Transferred_Date__c.getTime() - system.now().getTime()));
        System.assert(Math.abs(objAccount.Transferred_Date__c.getTime() - system.now().getTime()) < 3 * 1000); //5s

        //Check for External view record type
        objAccount.External_View__c = True;
        Update objAccount;
        
        objAccount = [Select Id ,Account_Name_for_unique_index__c, RecordTypeId, RecordType.DeveloperName from Account where Id =: objAccount.Id];
        System.assertEquals(objAccount.RecordType.DeveloperName , 'External_view');
        
        //Check for Buyer Record type
        objAccount.External_View__c = False;
        objAccount.Name = 'Buyer';
        objAccount.Sub_Type__c = 'Buyer';
        objAccount.Type = 'Buyer';
        objAccount.Account_Name_for_unique_index__c = 'Buyer Account : Buyer';
        Update objAccount;
        
        Account objBuyerAccount = [Select Id ,Account_Name_for_unique_index__c, Credit_Insurance_CCY__c, Credit_limit_insurance_currency__c, 
                                    Credit_Limit_Requested_CCY__c, Total_CL_Limit_from_Incomlend__c, RecordTypeId, RecordType.DeveloperName from Account where Id =: objAccount.Id];
        System.assertEquals(objBuyerAccount.RecordType.DeveloperName , 'Buyer');
        //System.assertEquals(objBuyerAccount.Credit_Insurance_CCY__c , objBuyerAccount.Credit_Limit_Requested_CCY__c);
        //System.assertEquals(objBuyerAccount.Credit_limit_insurance_currency__c , objBuyerAccount.Total_CL_Limit_from_Incomlend__c);
        
        //Check for Supplier record type
        objAccount.External_View__c = False;
        objAccount.Name = 'Test Account Supplier';
        objAccount.Sub_Type__c = 'Supplier';
        objAccount.Type = 'Supplier';
        objAccount.Account_Name_for_unique_index__c = 'Test Account Supplier';
        Update objAccount;
        
        objAccount = [Select Id ,Account_Name_for_unique_index__c, RecordTypeId, RecordType.DeveloperName from Account where Id =: objAccount.Id];
        System.assertEquals(objAccount.RecordType.DeveloperName , 'Supplier');
        
        //Test for e-Wallet Flow
        eWallet__c objEWalletNew = [Select Id, Balance__c, In_Progress__c, Total_Discount_Earned__c from eWallet__c where Id =: objEwallet.Id];
        
        System.assertNotEquals(objEWalletNew.Balance__c , null);
        System.assertNotEquals(objEWalletNew.In_Progress__c , null);
        System.assertNotEquals(objEWalletNew.Total_Discount_Earned__c , null);
        
        objEWalletTrustee1.Balance__c = -200;
        objEWalletTrustee1.In_Progress__c = -200;
        objEWalletTrustee1.Total_Discount_Earned__c = -200;
        objEWalletTrustee1.Reservations__c = -200;
        update objEWalletTrustee1;
        
        objEWalletTrustee2.Balance__c = -100;
        objEWalletTrustee2.In_Progress__c = -100;
        objEWalletTrustee2.Total_Discount_Earned__c = -100;
        objEWalletTrustee2.Reservations__c = -100;
        update objEWalletTrustee2;
        
        Withdrawal_Deposit__c wd = new Withdrawal_Deposit__c ();
        wd.type__c = '80.Withdrawal';
        wd.Status__c = 'Not Processed';
        wd.Amount__c = 10;
        wd.CCY__c = 'GBP';
        wd.Account__c = objAccount.Id;
        wd.Bank_Account__c = objBankAccount.Id;
        wd.ewallet__c = objEwallet.Id;
        wd.ewallet_Trustee__c = objEWalletTrustee1.Id;
        insert wd;
        
        Update objEWalletNew;
        
        objEWalletNew = [Select Id, CCY__c, Balance__c, In_Progress__c, Total_Discount_Earned__c, Reservations__c, Withdrawals_Not_Processed__c, Withdrawals_Not_Processed_Val__c from eWallet__c where Id =: objEwallet.Id];
        
        System.assertEquals(objEWalletNew.Balance__c, -300);
        System.assertEquals(objEWalletNew.In_Progress__c, -300);
        System.assertEquals(objEWalletNew.Total_Discount_Earned__c, -300);
        System.assertEquals(objEWalletNew.Reservations__c, -300);
        System.assertEquals(objEWalletNew.Withdrawals_Not_Processed_Val__c, 10);
        
        objEWalletNew.Unique_Name__c = 'Test eWallet';
        update objEWalletNew;
        
        objEWalletNew = [Select Id, CCY__c, Unique_Name__c from eWallet__c where Id =: objEwallet.Id];
        
        System.assertEquals(objEWalletNew.Unique_Name__c , objAccount.Id.to15()+objEWalletNew.CCY__c); 

        Transaction__c objTransaction = new Transaction__c();
        objTransaction.account__c = objAccount.id;
        objTransaction.type__C = '70.Deposit';
        objTransaction.ccy__c = 'GBP';
        objTransaction.effective_date__c = system.today();
        objTransaction.amount__c = 1000;
        objTransaction.status__c = 'Confirmed by Operations';
        objTransaction.accounting_period__c = objAccountingPeriod.Id;
        objTransaction.eWallet__c = objEwallet.Id;
        objTransaction.eWallet_Trustee__c = objEWalletTrustee1.Id;
        insert objTransaction;
        
        List<Transaction__c> lstTransaction = [Select Id, amount__c, Amount_SGD_equiv__c, Value_E_wallet_after_transaction_created__c from Transaction__c where account__c =: objAccount.id];
        System.assertEquals(lstTransaction.size() , 1);

        objTransaction = lstTransaction[0];
        decimal rate = objMarketPlace.latest_to_usd_rate__c / objMarketPlaceSGD.latest_to_usd_rate__c;
        System.assert(Math.abs(objTransaction.Amount_SGD_equiv__c - objTransaction.amount__c*rate) < 0.05);
        System.assertEquals(objTransaction.Value_E_wallet_after_transaction_created__c, -300);

    }
}