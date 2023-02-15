@isTest
private class InvoiceRepayment_Test {
    private static @testSetup void setup() {

        List<User> userList = new List<User>();
        List<FX_Rates__c> fxList = new List<FX_Rates__c>();
        List<Contact> contactList = new List<Contact>();
        List<Account> accountList = new List<Account>();
        List<Bank_Account__c> backAccountList = new List<Bank_Account__c>();
        List<eWallet__c> ewalletList = new List<eWallet__c>();
        List<incomlend_product__c> productList = new List<incomlend_product__c>();
        List<Supplier_Buyer_Map__c> mapList = new List<Supplier_Buyer_Map__c>();
        List<invoice_finance_deal__c> invoiceList = new List<invoice_finance_deal__c>();
        List<Invoice_Allocation__c> allocationList = new List<Invoice_Allocation__c>();
        List<Invoice_Repayment__c> invoiceRepaymentList = new List<Invoice_Repayment__c>();
        List<Allocation_Repayment__c> allocationRepaymentList = new List<Allocation_Repayment__c>();

        Id testProfileId = [select Id
                            from Profile
                            LIMIT 1].Id;

        Accounting_Period__c ap = new Accounting_Period__c();
        ap.Name = (date.today()).year() + '-' + date.today().month().format().leftpad(2,'0');              
        ap.Start_Date__c = date.today().addMonths(-1);
        ap.End_Date__c = date.today().addMonths(2);
        insert ap;        
        
        User buyerUser = new User();
        buyerUser.Username = 'testbuyer@yopmail.com';
        buyerUser.FirstName = 'TEST';
        buyerUser.LastName = 'BUY';
        buyerUser.Email = 'testbuyer@yopmail.com';
        buyerUser.TimeZoneSidKey = 'Asia/Singapore';
        buyerUser.Alias = 'BUY';
        buyerUser.LocaleSidKey = 'en_US';
        buyerUser.LanguageLocaleKey = 'en_US';
        buyerUser.EmailEncodingKey = 'UTF-8';
        buyerUser.ProfileId = testProfileId;
        userList.add(buyerUser);
        
        User supplierUser = new User();
        supplierUser.Username = 'testsupplier@yopmail.com';
        supplierUser.FirstName = 'TEST';
        supplierUser.LastName = 'SUPP';
        supplierUser.Email = 'testsupplier@yopmail.com';
        supplierUser.TimeZoneSidKey = 'Asia/Singapore';
        supplierUser.Alias = 'SUPP';
        supplierUser.LocaleSidKey = 'en_US';
        supplierUser.LanguageLocaleKey = 'en_US';
        supplierUser.EmailEncodingKey = 'UTF-8';
        supplierUser.ProfileId = testProfileId;
        userList.add(supplierUser);

        User incomlendUser = new User();
        incomlendUser.Username = 'testsuppliericl@yopmail.com';
        incomlendUser.FirstName = 'TEST';
        incomlendUser.LastName = 'SUPP';
        incomlendUser.Email = 'testsuppliericl@yopmail.com';
        incomlendUser.TimeZoneSidKey = 'Asia/Singapore';
        incomlendUser.Alias = 'SUPP';
        incomlendUser.LocaleSidKey = 'en_US';
        incomlendUser.LanguageLocaleKey = 'en_US';
        incomlendUser.EmailEncodingKey = 'UTF-8';
        incomlendUser.ProfileId = testProfileId;
        userList.add(incomlendUser);

        insert userList;
        
        FX_Rates__c fxRateEUR = new FX_Rates__c();
        fxRateEUR.from_currency__c = 'EUR';
        fxRateEUR.to_currency__c = 'USD';
        fxRateEUR.date__c = Date.today();
        fxRateEUR.rate__c = 1.4356129;
        fxList.add(fxRateEUR);
        
        FX_Rates__c fxRateSGD = new FX_Rates__c();
        fxRateSGD.from_currency__c = 'SGD';
        fxRateSGD.to_currency__c = 'USD';
        fxRateSGD.date__c = Date.today();
        fxRateSGD.rate__c = 0.846402;
        fxList.add(fxRateSGD);

        insert fxList;
        
        Marketplace__c marketplace = new Marketplace__c();
        marketplace.FX_Rate_for_MI__c = fxRateEUR.Id;
        marketplace.currency_symbol__c = '$';
        marketplace.minimum_purchase_amount__c = 1;
        marketplace.latest_to_usd_rate__c = 1.4356129;
        insert marketplace;
        
        Contact contactSupplier = new Contact();
        contactSupplier.Email = 'testsupplier@yopmail.com';
        contactSupplier.FirstName = 'TEST';
        contactSupplier.LastName = 'SUPP';
        contactList.add(contactSupplier);
        
        Contact contactBuyer = new Contact();
        contactBuyer.Email = 'testbuyer@yopmail.com';
        contactBuyer.FirstName = 'TEST';
        contactBuyer.LastName = 'BUY';
        contactList.add(contactBuyer);
        
        Contact contactFunder = new Contact();
        contactFunder.Email = 'testfunder@yopmail.com';
        contactFunder.FirstName = 'TEST';
        contactFunder.LastName = 'FUND';
        contactList.add(contactFunder);

        Contact contactIcl = new Contact();
        contactIcl.Email = 'testicl@yopmail.com';
        contactIcl.FirstName = 'TEST';
        contactIcl.LastName = 'ICL';
        contactList.add(contactIcl);

        insert contactList;
        
        Account funder = new Account();
        funder.Name = 'Funder';
        funder.Type = 'Customer';
        funder.Sub_type__c = 'Purchaser';
        funder.Primary_Contact__c = contactFunder.Id;
        funder.Country_of_Incorporation__c = 'Singapore';
        funder.VAT_applicable__c = true;
        accountList.add(funder);
        
        Account supplier = new Account();
        supplier.Name = 'Supplier';
        supplier.Sales_Owner__c = supplierUser.Id;
        supplier.Primary_Contact__c = contactSupplier.Id;
        supplier.Country_of_Incorporation__c = 'Singapore';
        accountList.add(supplier);
        
        Account buyer = new Account();
        buyer.Name = 'Buyer';
        buyer.Type = 'Buyer';
        buyer.Sales_Owner__c = buyerUser.Id;
        buyer.Primary_Contact__c = contactBuyer.Id;
        buyer.Country_of_Incorporation__c = 'Singapore';
        accountList.add(buyer);

        Account incomlendOps = new Account();
        incomlendOps.Name = 'Incomlend Operations';
        incomlendOps.Type = 'Internal';
        incomlendOps.Sales_Owner__c = incomlendUser.Id;
        incomlendOps.Primary_Contact__c = contactIcl.Id;
        incomlendOps.Country_of_Incorporation__c = 'Singapore';
        accountList.add(incomlendOps);

        Account incomlendSupp = new Account();
        incomlendSupp.Name = 'Incomlend - Supplier Discount';
        incomlendSupp.Type = 'Internal';
        incomlendSupp.Sales_Owner__c = incomlendUser.Id;
        incomlendSupp.Primary_Contact__c = contactIcl.Id;
        incomlendSupp.Country_of_Incorporation__c = 'Singapore';
        accountList.add(incomlendSupp);

        Account incomlendFees = new Account();
        incomlendFees.Name = 'Incomlend - fees';
        incomlendFees.Type = 'Internal';
        incomlendFees.Sales_Owner__c = incomlendUser.Id;
        incomlendFees.Primary_Contact__c = contactIcl.Id;
        incomlendFees.Country_of_Incorporation__c = 'Singapore';
        accountList.add(incomlendFees);

        Account incomlendGST = new Account();
        incomlendGST.Name = 'Incomlend GST';
        incomlendGST.Type = 'Internal';
        incomlendGST.Sales_Owner__c = incomlendUser.Id;
        incomlendGST.Primary_Contact__c = contactIcl.Id;
        incomlendGST.Country_of_Incorporation__c = 'Singapore';
        accountList.add(incomlendGST);

        insert accountList;
        
        Bank_Account__c supplierUSDBank = new Bank_Account__c();
        supplierUSDBank.Account__c = supplier.Id;
        supplierUSDBank.Bank_Name__c = 'USD Bank';
        supplierUSDBank.Currency__c = 'USD';
        supplierUSDBank.Country__c = 'Singapore';
        supplierUSDBank.Address__c = 'USD Address';
        supplierUSDBank.SWIFT_Code__c = 'SWFTUSD';
        supplierUSDBank.Beneficiary_Name__c = 'USD Beneficiary';
        supplierUSDBank.transfer_cutoff_time__c = '14:00';
        supplierUSDBank.Bank_Account_Number__c = '0000-0001';
        backAccountList.add(supplierUSDBank);
        
        Bank_Account__c supplierEURBank = new Bank_Account__c();
        supplierEURBank.Account__c = supplier.Id;
        supplierEURBank.Bank_Name__c = 'EUR Bank';
        supplierEURBank.Currency__c = 'EUR';
        supplierEURBank.Country__c = 'Singapore';
        supplierEURBank.Address__c = 'EUR Address';
        supplierEURBank.SWIFT_Code__c = 'SWFTEUR';
        supplierEURBank.Beneficiary_Name__c = 'EUR Beneficiary';
        supplierEURBank.transfer_cutoff_time__c = '12:00';
        supplierEURBank.Bank_Account_Number__c = '0000-0002';
        backAccountList.add(supplierEURBank);

        insert backAccountList;
        
        eWallet__c eWalletFunderUSD = new eWallet__c();
        eWalletFunderUSD.Account__c = funder.Id;
        eWalletFunderUSD.CCY__c = 'USD';
        eWalletFunderUSD.Marketplace_for_FX__c = marketplace.Id;
        eWalletFunderUSD.Bank_Account__c = supplierUSDBank.Id;
        eWalletFunderUSD.Balance__c = 1000000;
        ewalletList.add(eWalletFunderUSD);
        
        eWallet__c eWalletFunderEUR = new eWallet__c();
        eWalletFunderEUR.Account__c = funder.Id;
        eWalletFunderEUR.CCY__c = 'EUR';
        eWalletFunderEUR.Marketplace_for_FX__c = marketplace.Id;
        eWalletFunderEUR.Bank_Account__c = supplierEURBank.Id;
        eWalletFunderEUR.Balance__c = 1000000;
        ewalletList.add(eWalletFunderEUR);

        eWallet__c eWalletSuppUSD = new eWallet__c();
        eWalletSuppUSD.Account__c = supplier.Id;
        eWalletSuppUSD.CCY__c = 'USD';
        eWalletSuppUSD.Marketplace_for_FX__c = marketplace.Id;
        eWalletSuppUSD.Bank_Account__c = supplierUSDBank.Id;
        eWalletSuppUSD.Balance__c = 1000000;
        ewalletList.add(eWalletSuppUSD);
        
        eWallet__c eWalletSuppEUR = new eWallet__c();
        eWalletSuppEUR.Account__c = supplier.Id;
        eWalletSuppEUR.CCY__c = 'EUR';
        eWalletSuppEUR.Marketplace_for_FX__c = marketplace.Id;
        eWalletSuppEUR.Bank_Account__c = supplierEURBank.Id;
        eWalletSuppEUR.Balance__c = 1000000;
        ewalletList.add(eWalletSuppEUR);

        eWallet__c eWalletBuyerUSD = new eWallet__c();
        eWalletBuyerUSD.Account__c = buyer.Id;
        eWalletBuyerUSD.CCY__c = 'USD';
        eWalletBuyerUSD.Marketplace_for_FX__c = marketplace.Id;
        eWalletBuyerUSD.Bank_Account__c = supplierUSDBank.Id;
        eWalletBuyerUSD.Balance__c = 1000000;
        ewalletList.add(eWalletBuyerUSD);
        
        eWallet__c eWalletBuyerEUR = new eWallet__c();
        eWalletBuyerEUR.Account__c = buyer.Id;
        eWalletBuyerEUR.CCY__c = 'EUR';
        eWalletBuyerEUR.Marketplace_for_FX__c = marketplace.Id;
        eWalletBuyerEUR.Bank_Account__c = supplierEURBank.Id;
        eWalletBuyerEUR.Balance__c = 1000000;
        ewalletList.add(eWalletBuyerEUR);

        eWallet__c eWalletIclOpsUSD = new eWallet__c();
        eWalletIclOpsUSD.Account__c = incomlendOps.Id;
        eWalletIclOpsUSD.CCY__c = 'USD';
        eWalletIclOpsUSD.Marketplace_for_FX__c = marketplace.Id;
        eWalletIclOpsUSD.Bank_Account__c = supplierUSDBank.Id;
        eWalletIclOpsUSD.Balance__c = 1000000;
        ewalletList.add(eWalletIclOpsUSD);

        eWallet__c eWalletIclOpsEUR = new eWallet__c();
        eWalletIclOpsEUR.Account__c = incomlendOps.Id;
        eWalletIclOpsEUR.CCY__c = 'EUR';
        eWalletIclOpsEUR.Marketplace_for_FX__c = marketplace.Id;
        eWalletIclOpsEUR.Bank_Account__c = supplierEURBank.Id;
        eWalletIclOpsEUR.Balance__c = 1000000;
        ewalletList.add(eWalletIclOpsEUR);

        eWallet__c eWalletIclSuppUSD = new eWallet__c();
        eWalletIclSuppUSD.Account__c = incomlendSupp.Id;
        eWalletIclSuppUSD.CCY__c = 'USD';
        eWalletIclSuppUSD.Marketplace_for_FX__c = marketplace.Id;
        eWalletIclSuppUSD.Bank_Account__c = supplierUSDBank.Id;
        eWalletIclSuppUSD.Balance__c = 1000000;
        ewalletList.add(eWalletIclSuppUSD);

        eWallet__c eWalletIclSuppEUR = new eWallet__c();
        eWalletIclSuppEUR.Account__c = incomlendSupp.Id;
        eWalletIclSuppEUR.CCY__c = 'EUR';
        eWalletIclSuppEUR.Marketplace_for_FX__c = marketplace.Id;
        eWalletIclSuppEUR.Bank_Account__c = supplierEURBank.Id;
        eWalletIclSuppEUR.Balance__c = 1000000;
        ewalletList.add(eWalletIclSuppEUR);

        eWallet__c eWalletIclFeesUSD = new eWallet__c();
        eWalletIclFeesUSD.Account__c = incomlendFees.Id;
        eWalletIclFeesUSD.CCY__c = 'USD';
        eWalletIclFeesUSD.Marketplace_for_FX__c = marketplace.Id;
        eWalletIclFeesUSD.Bank_Account__c = supplierUSDBank.Id;
        eWalletIclFeesUSD.Balance__c = 1000000;
        ewalletList.add(eWalletIclFeesUSD);

        eWallet__c eWalletIclFeesEUR = new eWallet__c();
        eWalletIclFeesEUR.Account__c = incomlendFees.Id;
        eWalletIclFeesEUR.CCY__c = 'EUR';
        eWalletIclFeesEUR.Marketplace_for_FX__c = marketplace.Id;
        eWalletIclFeesEUR.Bank_Account__c = supplierEURBank.Id;
        eWalletIclFeesEUR.Balance__c = 1000000;
        ewalletList.add(eWalletIclFeesEUR);

        eWallet__c eWalletIclGSTUSD = new eWallet__c();
        eWalletIclGSTUSD.Account__c = incomlendGST.Id;
        eWalletIclGSTUSD.CCY__c = 'USD';
        eWalletIclGSTUSD.Marketplace_for_FX__c = marketplace.Id;
        eWalletIclGSTUSD.Bank_Account__c = supplierUSDBank.Id;
        eWalletIclGSTUSD.Balance__c = 1000000;
        ewalletList.add(eWalletIclGSTUSD);

        eWallet__c eWalletIclGSTEUR = new eWallet__c();
        eWalletIclGSTEUR.Account__c = incomlendGST.Id;
        eWalletIclGSTEUR.CCY__c = 'EUR';
        eWalletIclGSTEUR.Marketplace_for_FX__c = marketplace.Id;
        eWalletIclGSTEUR.Bank_Account__c = supplierEURBank.Id;
        eWalletIclGSTEUR.Balance__c = 1000000;
        ewalletList.add(eWalletIclGSTEUR);

        insert ewalletList;
        
        funder.USD_eWallet__c = eWalletFunderUSD.Id;
        funder.EUR_eWallet__c = eWalletFunderEUR.Id;
        update funder;

        supplier.USD_eWallet__c = eWalletSuppUSD.Id;
        supplier.EUR_eWallet__c = eWalletSuppEUR.Id;
        update supplier;

        buyer.USD_eWallet__c = eWalletBuyerUSD.Id;
        buyer.EUR_eWallet__c = eWalletBuyerEUR.Id;
        update buyer;

        incomlendOps.USD_eWallet__c = eWalletIclOpsUSD.Id;
        incomlendOps.EUR_eWallet__c = eWalletIclOpsEUR.Id;
        update incomlendOps;

        incomlendSupp.USD_eWallet__c = eWalletIclSuppUSD.Id;
        incomlendSupp.EUR_eWallet__c = eWalletIclSuppEUR.Id;
        update incomlendSupp;

        incomlendFees.USD_eWallet__c = eWalletIclFeesUSD.Id;
        incomlendFees.EUR_eWallet__c = eWalletIclFeesEUR.Id;
        update incomlendFees;

        incomlendGST.USD_eWallet__c = eWalletIclGSTUSD.Id;
        incomlendGST.EUR_eWallet__c = eWalletIclGSTEUR.Id;
        update incomlendGST;

        incomlend_product__c customProductUSD = new incomlend_product__c();
        customProductUSD.Name = 'Test Standard USD';
        customProductUSD.launch_date__c = Date.today();
        customProductUSD.months_relationship_with_buyer__c = 12;
        customProductUSD.Auction_Type__c = 'Fixed Discount Rate';
        customProductUSD.CCYs__c = 'USD';
        customProductUSD.approved__c = true;
        productList.add(customProductUSD);
        
        incomlend_product__c customProductEUR = new incomlend_product__c();
        customProductEUR.Name = 'Test Standard EUR';
        customProductEUR.launch_date__c = Date.today();
        customProductEUR.months_relationship_with_buyer__c = 12;
        customProductEUR.Auction_Type__c = 'Fixed Discount Rate';
        customProductEUR.CCYs__c = 'EUR';
        customProductEUR.approved__c = true;
        productList.add(customProductEUR);

        insert productList;
        
        Supplier_Buyer_Map__c supplierBuyerMapUSD = new Supplier_Buyer_Map__c();
        supplierBuyerMapUSD.Supplier__c = supplier.Id;
        supplierBuyerMapUSD.Buyer__c = buyer.Id;
        supplierBuyerMapUSD.Marketplace__c = marketplace.Id;
        supplierBuyerMapUSD.Incomlend_product__c = customProductUSD.Id;
        supplierBuyerMapUSD.Buyer_Sales_Zone__c = 10;
        supplierBuyerMapUSD.Supplier_Zone__c = 5;
        supplierBuyerMapUSD.Overdue_Additional_Discount_rate__c = 1.25;
        supplierBuyerMapUSD.Supplier_Discount_Rate__c = 5.25;
        supplierBuyerMapUSD.Trustee__c = 'Amicorp Trust';
        supplierBuyerMapUSD.map_onboarding_stage__c = '90.Onboarded';
        supplierBuyerMapUSD.buyer_supplier_map_approved__c = true;
        mapList.add(supplierBuyerMapUSD);
        
        Supplier_Buyer_Map__c supplierBuyerMapEUR = new Supplier_Buyer_Map__c();
        supplierBuyerMapEUR.Supplier__c = supplier.Id;
        supplierBuyerMapEUR.Buyer__c = buyer.Id;
        supplierBuyerMapEUR.Marketplace__c = marketplace.Id;
        supplierBuyerMapEUR.Incomlend_product__c = customProductEUR.Id;
        supplierBuyerMapEUR.Buyer_Sales_Zone__c = 10;
        supplierBuyerMapEUR.Supplier_Zone__c = 5;
        supplierBuyerMapEUR.Overdue_Additional_Discount_rate__c = 1.05;
        supplierBuyerMapEUR.Supplier_Discount_Rate__c = 4.25;
        supplierBuyerMapEUR.Trustee__c = 'Amicorp Trust';
        supplierBuyerMapEUR.map_onboarding_stage__c = '90.Onboarded';
        supplierBuyerMapEUR.buyer_supplier_map_approved__c = true;
        mapList.add(supplierBuyerMapEUR);

        insert mapList;
        
        invoice_finance_deal__c invoiceUSD = new invoice_finance_deal__c();
        invoiceUSD.Due_Date__c = Date.today().addMonths(2);
        invoiceUSD.Actual_Repayment_Received_Date__c = Date.today().addDays(10);
        invoiceUSD.advance_send_to_supplier_date__c = Date.today();
        invoiceUSD.CCY__c = 'USD';
        invoiceUSD.Phase__c = '3:IN PROGRESS';
        invoiceUSD.Status__c = 'In Progress';
        invoiceUSD.invoice_amount__c = 250000;
        invoiceUSD.supplier_invoice_reference_number__c = 'INV-0001';
        invoiceUSD.Supplier_Buyer_Map__c = supplierBuyerMapUSD.Id;
        invoiceUSD.requested_amount__c = 225000;
        invoiceUSD.Trustee__c = 'Amicorp Trust';
        invoiceUSD.Tolerance_overdue_days__c = 0;
        invoiceUSD.discount_rate__c = 2;
        invoiceUSD.Repaid_Funded_Amount__c = 0;
        invoiceUSD.Repaid_Amount__c = 0;
        invoiceUSD.Repaid_Supplier_Balance_Amount__c = 0;
        invoiceUSD.Repaid_Supplier_Discount_Amount__c = 0;
        invoiceUSD.Phase__c = '3:IN PROGRESS';
        invoiceUSD.Status__c = 'Delayed';
        invoiceUSD.Overdue_Transaction_fees_Net__c = 0;
        invoiceList.add(invoiceUSD);

        List<eWallet_Trustee__c> trusteeList = new List<eWallet_Trustee__c>();
        eWallet_Trustee__c ewalletTrusteeUSD = new eWallet_Trustee__c();
        ewalletTrusteeUSD.Account__c = funder.Id;
        ewalletTrusteeUSD.CCY__c = 'USD';
        ewalletTrusteeUSD.Trustee__c = 'Amicorp Trust';
        ewalletTrusteeUSD.Main_eWallet__c = eWalletFunderUSD.Id;
        ewalletTrusteeUSD.Marketplace_for_FX__c = marketplace.Id;
        ewalletTrusteeUSD.Balance__c = 1000000;
        trusteeList.add(ewalletTrusteeUSD);
        
        eWallet_Trustee__c ewalletTrusteeEUR = new eWallet_Trustee__c();
        ewalletTrusteeEUR.Account__c = funder.Id;
        ewalletTrusteeEUR.CCY__c = 'EUR';
        ewalletTrusteeEUR.Trustee__c = 'Amicorp Trust';
        ewalletTrusteeEUR.Main_eWallet__c = eWalletFunderEUR.Id;
        ewalletTrusteeEUR.Marketplace_for_FX__c = marketplace.Id;
        ewalletTrusteeEUR.Balance__c = 1000000;
        trusteeList.add(ewalletTrusteeEUR);
        
        insert trusteeList;
        
        Transaction__c TransactionUSD = new Transaction__c();
        TransactionUSD.Status__c = 'Confirmed by Finance';
        TransactionUSD.Type__c = '70.Deposit';
        TransactionUSD.CCY__c = 'USD';
        TransactionUSD.isArchived__c = false;
        TransactionUSD.Account__c = funder.Id;
        TransactionUSD.eWallet__c = eWalletFunderUSD.Id;
        TransactionUSD.Accounting_Period__c = ap.Id;
        TransactionUSD.eWallet_Trustee__c = ewalletTrusteeUSD.Id;
        TransactionUSD.Amount__c = 1000000;
        TransactionUSD.Effective_Date__c = date.today();
        insert TransactionUSD;
        
        Transaction__c TransactionEUR = new Transaction__c();
        TransactionEUR.Status__c = 'Confirmed by Finance';
        TransactionEUR.Type__c = '70.Deposit';
        TransactionEUR.CCY__c = 'EUR';
        TransactionEUR.isArchived__c = false;
        TransactionEUR.Account__c = funder.Id;
        TransactionEUR.eWallet__c = eWalletFunderEUR.Id;
        TransactionEUR.Accounting_Period__c = ap.Id;
        TransactionEUR.eWallet_Trustee__c = ewalletTrusteeEUR.Id;
        TransactionEUR.Amount__c = 1000000;
        TransactionEUR.Effective_Date__c = date.today();
        insert TransactionEUR;
        
        invoice_finance_deal__c invoiceEUR = new invoice_finance_deal__c();
        invoiceEUR.Due_Date__c = Date.today().addMonths(2);
        invoiceEUR.Actual_Repayment_Received_Date__c = Date.today().addDays(10);
        invoiceEUR.advance_send_to_supplier_date__c = Date.today();
        invoiceEUR.CCY__c = 'EUR';
        invoiceEUR.Supplier_name__c = supplier.Id;
        invoiceEUR.Phase__c = '3:IN PROGRESS';
        invoiceEUR.Status__c = 'In Progress';
        invoiceEUR.invoice_amount__c = 175000;
        invoiceEUR.supplier_invoice_reference_number__c = 'INV-0002';
        invoiceEUR.Supplier_Buyer_Map__c = supplierBuyerMapEUR.Id;
        invoiceEUR.requested_amount__c = 75000;
        invoiceEUR.Trustee__c = 'Amicorp Trust';
        invoiceEUR.Tolerance_overdue_days__c = 0;
        invoiceEUR.discount_rate__c = 2;
        invoiceEUR.Repaid_Funded_Amount__c = 0;
        invoiceEUR.Repaid_Amount__c = 0;
        invoiceEUR.Repaid_Supplier_Balance_Amount__c = 0;
        invoiceEUR.Repaid_Supplier_Discount_Amount__c = 0;
        invoiceEUR.Phase__c = '3:IN PROGRESS';
        invoiceEUR.Status__c = 'Delayed';
        invoiceEUR.Overdue_Transaction_fees_Net__c = 0;
        invoiceList.add(invoiceEUR);

        insert invoiceList;
        
        Invoice_Allocation__c allocationUSD = new Invoice_Allocation__c();
        allocationUSD.Applied_Funder_Discount_Profit_Share_Pct__c = 30.00;
        allocationUSD.Funder__c = funder.Id;
        allocationUSD.amount__c = 12500.00;
        allocationUSD.Invoice__c = invoiceUSD.Id;
        allocationUSD.Status__c = 'Reservation';
        allocationUSD.Allocation_Reservation_date__c = DateTime.now();
        allocationUSD.eWallet__c = eWalletFunderUSD.Id;
        allocationUSD.CCY__c = 'USD';
        allocationUSD.Applied_MPR__c = 0.5;
        allocationUSD.Repaid_Amount__c = 0;
        allocationUSD.Repaid_Discount_Amount__c = 0;
        allocationUSD.Status__c = 'Confirmed';
        allocationList.add(allocationUSD);
        
        Invoice_Allocation__c allocationEUR = new Invoice_Allocation__c();
        allocationEUR.Applied_Funder_Discount_Profit_Share_Pct__c = 10.00;
        allocationEUR.Funder__c = funder.Id;
        allocationEUR.amount__c = 15000.00;
        allocationEUR.Invoice__c = invoiceEUR.Id;
        allocationEUR.Status__c = 'Reservation';
        allocationEUR.Allocation_Reservation_date__c = DateTime.now();
        allocationEUR.eWallet__c = eWalletFunderEUR.Id;
        allocationEUR.CCY__c = 'EUR';
        allocationEUR.Applied_MPR__c = 0.25;
        allocationEUR.Repaid_Amount__c = 0;
        allocationEUR.Repaid_Discount_Amount__c = 0;
        allocationEUR.Status__c = 'Confirmed';
        allocationList.add(allocationEUR);

        insert allocationList;
        
        Tax_Rate__c taxRate = new Tax_Rate__c();
        taxRate.Rate__c = 7.00;
        taxRate.Country__c = 'Singapore';
        insert taxRate;
        
        Tax_Invoice__c invoiceOrig = new Tax_Invoice__c();
        invoiceOrig.Invoice_Reference_Number__c = '000001-AH2D-F1-16094023';
        invoiceOrig.Invoice_Date__c = Date.today();
        invoiceOrig.Invoice__c = invoiceUSD.Id;
        invoiceOrig.Customer__c = supplier.Id;
        insert invoiceOrig;

        Invoice_Repayment__c invoiceUSDRepayment = new Invoice_Repayment__c();
        invoiceUSDRepayment.Invoice_Finance_Deal__c = invoiceUSD.Id;
        invoiceUSDRepayment.Due_Date__c = Date.today().addMonths(2);
        invoiceUSDRepayment.Capped_Funder_Discount__c = true;
        invoiceUSDRepayment.Status__c = 'Pending';
        invoiceUSDRepayment.Repaid_Amount__c = 25000;
        invoiceUSDRepayment.Supplier_Discount_Amount__c = 2000;
        invoiceUSDRepayment.Funder_Amount__c = 21500;
        invoiceUSDRepayment.Remaining_Invoice_Amount__c = 50000;
        invoiceRepaymentList.add(invoiceUSDRepayment);

        Invoice_Repayment__c invoiceEURRepayment = new Invoice_Repayment__c();
        invoiceEURRepayment.Invoice_Finance_Deal__c = invoiceEUR.Id;
        invoiceEURRepayment.Due_Date__c = Date.today().addMonths(3);
        invoiceEURRepayment.Capped_Funder_Discount__c = false;
        invoiceEURRepayment.Status__c = 'Pending';
        invoiceEURRepayment.Repaid_Amount__c = 17500;
        invoiceEURRepayment.Supplier_Discount_Amount__c = 100;
        invoiceEURRepayment.Funder_Amount__c = 15750;
        invoiceEURRepayment.Remaining_Invoice_Amount__c = 50000;
        invoiceRepaymentList.add(invoiceEURRepayment);

        insert invoiceRepaymentList;

        Allocation_Repayment__c allocationUSDRepayment = new Allocation_Repayment__c();
        allocationUSDRepayment.Invoice_Allocation__c = allocationUSD.Id;
        allocationUSDRepayment.Invoice_Repayment__c = invoiceUSDRepayment.Id;
        allocationUSDRepayment.Status__c = 'Pending';
        allocationUSDRepayment.Net_Discount_Amount__c = 15.50;
        allocationUSDRepayment.Amount__c = 5000;
        allocationRepaymentList.add(allocationUSDRepayment);

        Allocation_Repayment__c allocationEURRepayment = new Allocation_Repayment__c();
        allocationEURRepayment.Invoice_Allocation__c = allocationEUR.Id;
        allocationEURRepayment.Invoice_Repayment__c = invoiceEURRepayment.Id;
        allocationEURRepayment.Status__c = 'Pending';
        allocationEURRepayment.Net_Discount_Amount__c = 10.25;
        allocationEURRepayment.Amount__c = 2500;
        allocationRepaymentList.add(allocationEURRepayment);

        insert allocationRepaymentList;
        
        invoiceUSD.discount_rate__c = 0.75;
        update invoiceUSD;
        
        invoiceEUR.discount_rate__c = 0.75;
        update invoiceEUR;
    }
    
    // ---------- ///
    /*              
        Test Case 1 : 
        Currency : USD
        Payment details : On time
        Result expected : true
    */
    // ---------- //
    private static testMethod void validateInvoiceRepaymentUSDOnTime() {

        List<eWallet_Trustee__c> trusteeList = new List<eWallet_Trustee__c>();

        for (Account account : [SELECT Id, USD_eWallet__c, EUR_eWallet__c, USD_eWallet__r.Marketplace_for_FX__c, EUR_eWallet__r.Marketplace_for_FX__c FROM Account WHERE Sub_type__c != 'Purchaser']) {
            eWallet_Trustee__c ewalletTrusteeUSD = new eWallet_Trustee__c();
            ewalletTrusteeUSD.Account__c = account.Id;
            ewalletTrusteeUSD.CCY__c = 'USD';
            ewalletTrusteeUSD.Trustee__c = 'Amicorp Trust';
            ewalletTrusteeUSD.Main_eWallet__c = account.USD_eWallet__c;
            ewalletTrusteeUSD.Marketplace_for_FX__c = account.USD_eWallet__r.Marketplace_for_FX__c;
            ewalletTrusteeUSD.Balance__c = 1000000000;
            trusteeList.add(ewalletTrusteeUSD);

            eWallet_Trustee__c ewalletTrusteeEUR = new eWallet_Trustee__c();
            ewalletTrusteeEUR.Account__c = account.Id;
            ewalletTrusteeEUR.CCY__c = 'EUR';
            ewalletTrusteeEUR.Trustee__c = 'Amicorp Trust';
            ewalletTrusteeEUR.Main_eWallet__c = account.EUR_eWallet__c;
            ewalletTrusteeEUR.Marketplace_for_FX__c = account.EUR_eWallet__r.Marketplace_for_FX__c;
            ewalletTrusteeEUR.Balance__c = 10000000;
            trusteeList.add(ewalletTrusteeEUR);
        }

        insert trusteeList;
        
        Map<Invoice_Allocation__c, Allocation_Repayment__c> allocationRepaymentMap = new Map<Invoice_Allocation__c, Allocation_Repayment__c>();
        
        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c,
                                                  Due_Date__c,
                                                  Actual_Repayment_Received_Date__c,
                                                  invoice_amount__c,
                                                  Supplier_Buyer_Map__c,
                                                  Supplier_Buyer_Map__r.Supplier__c,
                                                  Supplier_Buyer_Map__r.Buyer__c,
                                                  Supplier_Country__c,
                                                  Trustee__c,
                                                  over_due_days__c,
                                                  Overdue_Supplier_discount_rate__c,
                                                  Overdue_Transaction_fees_Net__c,
                                                  Tolerance_overdue_days__c,
                                                  Repaid_Funded_Amount__c,
                                                  Repaid_Amount__c,
                                                  Repaid_Supplier_Balance_Amount__c,
                                                  Repaid_Supplier_Discount_Amount__c,
                                                  Phase__c,
                                                  Status__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        List<Invoice_Allocation__c> allocations = [select Id,
                                                   Name,
                                                   Incomlend_Profit_share__c,
                                                   Funder__c,
                                                   Funder__r.Country_of_Incorporation__c,
                                                   Funder__r.VAT_applicable__c,
                                                   Funder_prepayment__c,
                                                   amount__c,
                                                   Applied_MPR__c,
                                                   CCY__c,
                                                   Funder__r.Name,
                                                   eWallet__c,
                                                   eWallet__r.Name,
                                                   Applied_Funder_Discount_Profit_Share_Pct__c,
                                                   Repaid_Amount__c,
                                                   Repaid_Discount_Amount__c,
                                                   Status__c
                                            from Invoice_Allocation__c
                                            where Invoice__c = :invoice.Id];

        List<Id> allocationsIds = new List<Id>();
        for (Invoice_Allocation__c c: allocations) {
            allocationsIds.add(c.Id);
        }
        Invoice_Repayment__c invoiceRepayment = [select Id,
                                                Name,
                                                Repaid_Invoice_Ratio__c,
                                                invoice_finance_deal__r.advance_send_to_supplier_date__c,
                                                Due_Date__c,
                                                Repaid_Amount__c,
                                                Capped_Funder_Discount__c,
                                                Supplier_Discount_Amount__c,
                                                Funder_Amount__c,
                                                Status__c,
                                                Remaining_Invoice_Amount__c
                                            From Invoice_Repayment__c
                                            Where Invoice_Finance_Deal__c =: invoice.Id];

        for (Invoice_Allocation__c currentallocation: allocations) {
                Allocation_Repayment__c currentAllocationsRepayment = [select Id,
                                                       Name,
                                                       Invoice_Allocation__r.Funder__r.Country_of_Incorporation__c,
                                                       Invoice_Allocation__r.Funder__r.VAT_applicable__c,
                                                       Net_Discount_Amount__c,
                                                       Invoice_Allocation__r.Applied_Funder_Discount_Profit_Share_Pct__c,
                                                       Invoice_Allocation__r.Applied_MPR__c,
                                                       Amount__c,
                                                       Invoice_Allocation__r.CCY__c,
                                                       Invoice_Allocation__r.eWallet__c,
                                                       Invoice_Allocation__r.eWallet__r.Name,
                                                       Invoice_Allocation__r.Funder__c,
                                                       Invoice_Allocation__r.Funder__r.Name,
                                                       Invoice_Allocation__r.Id,
                                                       Invoice_Allocation__r.Name,
                                                       Status__c
                                                    From Allocation_Repayment__c
                                                    Where Invoice_Allocation__c = :currentallocation.Id LIMIT 1];
                allocationRepaymentMap.put(currentallocation, currentAllocationsRepayment);
        }

        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        System.debug('Call InvoiceRepayment_v1');
        InvoiceRepayment repayment = new InvoiceRepayment(  invoice,
                                                            allocationRepaymentMap,
                                                            invoiceRepayment,
                                                            1000,
                                                            700,
                                                            false,
                                                            null,
                                                            null,
                                                            new Helper_Log());
        Test.startTest();
        boolean isRepaidSuccessfully = repayment.repayInvoice();
        Test.stopTest();
        System.debug('result InvoiceRepayment_v1: ' + isRepaidSuccessfully);
        System.assertEquals(true, isRepaidSuccessfully);
    }


    // ---------- ///
    /*              
        Test Case 2 : 
        currency : EUR
        Payment details : Overdue 1 month
        Result expected : true
    */
    // ---------- //
        
    private static testMethod void validateInvoiceRepaymentEUROverdue() {

        List<eWallet_Trustee__c> trusteeList = new List<eWallet_Trustee__c>();

        for (Account account : [SELECT Id, USD_eWallet__c, EUR_eWallet__c, USD_eWallet__r.Marketplace_for_FX__c, EUR_eWallet__r.Marketplace_for_FX__c FROM Account WHERE Sub_type__c != 'Purchaser']) {
            eWallet_Trustee__c ewalletTrusteeUSD = new eWallet_Trustee__c();
            ewalletTrusteeUSD.Account__c = account.Id;
            ewalletTrusteeUSD.CCY__c = 'USD';
            ewalletTrusteeUSD.Trustee__c = 'Amicorp Trust';
            ewalletTrusteeUSD.Main_eWallet__c = account.USD_eWallet__c;
            ewalletTrusteeUSD.Marketplace_for_FX__c = account.USD_eWallet__r.Marketplace_for_FX__c;
            ewalletTrusteeUSD.Balance__c = 1000000000;
            trusteeList.add(ewalletTrusteeUSD);

            eWallet_Trustee__c ewalletTrusteeEUR = new eWallet_Trustee__c();
            ewalletTrusteeEUR.Account__c = account.Id;
            ewalletTrusteeEUR.CCY__c = 'EUR';
            ewalletTrusteeEUR.Trustee__c = 'Amicorp Trust';
            ewalletTrusteeEUR.Main_eWallet__c = account.EUR_eWallet__c;
            ewalletTrusteeEUR.Marketplace_for_FX__c = account.EUR_eWallet__r.Marketplace_for_FX__c;
            ewalletTrusteeEUR.Balance__c = 1000000000;
            trusteeList.add(ewalletTrusteeEUR);
        }

        insert trusteeList;
        
        Map<Invoice_Allocation__c, Allocation_Repayment__c> allocationRepaymentMap = new Map<Invoice_Allocation__c, Allocation_Repayment__c>();
        
        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c,
                                                  Due_Date__c,
                                                  Actual_Repayment_Received_Date__c,
                                                  invoice_amount__c,
                                                  Supplier_Buyer_Map__c,
                                                  Supplier_Buyer_Map__r.Supplier__c,
                                                  Supplier_Buyer_Map__r.Buyer__c,
                                                  Supplier_Country__c,
                                                  discount_rate__c,
                                                  Trustee__c,
                                                  over_due_days__c,
                                                  Tolerance_overdue_days__c,
                                                  Overdue_Supplier_discount_rate__c,
                                                  Overdue_Transaction_fees_Net__c,
                                                  Repaid_Funded_Amount__c,
                                                  Repaid_Amount__c,
                                                  Repaid_Supplier_Balance_Amount__c,
                                                  Repaid_Supplier_Discount_Amount__c,
                                                  Phase__c,
                                                  Status__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'EUR'];
        List<Invoice_Allocation__c> allocations = [select Id,
                                                   Name,
                                                   Incomlend_Profit_share__c,
                                                   Funder_prepayment__c,
                                                   Funder__c,
                                                   Funder__r.Country_of_Incorporation__c,
                                                   Funder__r.VAT_applicable__c,
                                                   amount__c,
                                                   Applied_MPR__c,
                                                   CCY__c,
                                                   Funder__r.Name,
                                                   eWallet__c,
                                                   eWallet__r.Name,
                                                   Applied_Funder_Discount_Profit_Share_Pct__c,
                                                   Repaid_Amount__c,
                                                   Repaid_Discount_Amount__c,
                                                   Status__c
                                            from Invoice_Allocation__c
                                            where Invoice__c = :invoice.Id];

        List<Id> allocationsIds = new List<Id>();
        for (Invoice_Allocation__c c: allocations) {
            allocationsIds.add(c.Id);
        }
        Invoice_Repayment__c invoiceRepayment = [select Id,
                                                Name,
                                                Repaid_Invoice_Ratio__c,
                                                invoice_finance_deal__r.advance_send_to_supplier_date__c,
                                                Due_Date__c,
                                                Repaid_Amount__c,
                                                Capped_Funder_Discount__c,
                                                Supplier_Discount_Amount__c,
                                                Funder_Amount__c,
                                                Status__c,
                                                Remaining_Invoice_Amount__c
                                            From Invoice_Repayment__c
                                            Where Invoice_Finance_Deal__c =: invoice.Id];

        for (Invoice_Allocation__c currentallocation: allocations) {
                Allocation_Repayment__c currentAllocationsRepayment = [select Id,
                                                       Name,
                                                       Invoice_Allocation__r.Funder__r.Country_of_Incorporation__c,
                                                       Invoice_Allocation__r.Funder__r.VAT_applicable__c,
                                                       Net_Discount_Amount__c,
                                                       Invoice_Allocation__r.Applied_Funder_Discount_Profit_Share_Pct__c,
                                                       Invoice_Allocation__r.Applied_MPR__c,
                                                       Amount__c,
                                                       Invoice_Allocation__r.CCY__c,
                                                       Invoice_Allocation__r.eWallet__c,
                                                       Invoice_Allocation__r.eWallet__r.Name,
                                                       Invoice_Allocation__r.Funder__c,
                                                       Invoice_Allocation__r.Funder__r.Name,
                                                       Invoice_Allocation__r.Id,
                                                       Invoice_Allocation__r.Name,
                                                       Status__c
                                                    From Allocation_Repayment__c
                                                    Where Invoice_Allocation__c = :currentallocation.Id LIMIT 1];
                allocationRepaymentMap.put(currentallocation, currentAllocationsRepayment);
        }

        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        System.debug('Call InvoiceRepayment_v1');
        InvoiceRepayment repayment = new InvoiceRepayment(  invoice,
                                                            allocationRepaymentMap,
                                                            invoiceRepayment,
                                                            1000,
                                                            700,
                                                            false,
                                                            null,
                                                            null,
                                                            new Helper_Log());
        Test.startTest();
        boolean isRepaidSuccessfully = repayment.repayInvoice();
        Test.stopTest();
        System.debug('result InvoiceRepayment_v1: ' + isRepaidSuccessfully);
        System.assertEquals(true, isRepaidSuccessfully);
    }

    // ---------- ///
    /*              
        Test Case 3 : 
        Currency : USD
        Payment Details : On time - complete payment
        Result expected : true
    */
    // ---------- //
        private static testMethod void validateInvoiceRepaymentComplete() {

        List<eWallet_Trustee__c> trusteeList = new List<eWallet_Trustee__c>();

        for (Account account : [SELECT Id, USD_eWallet__c, EUR_eWallet__c, USD_eWallet__r.Marketplace_for_FX__c, EUR_eWallet__r.Marketplace_for_FX__c FROM Account WHERE Sub_type__c != 'Purchaser']) {
            eWallet_Trustee__c ewalletTrusteeUSD = new eWallet_Trustee__c();
            ewalletTrusteeUSD.Account__c = account.Id;
            ewalletTrusteeUSD.CCY__c = 'USD';
            ewalletTrusteeUSD.Trustee__c = 'Amicorp Trust';
            ewalletTrusteeUSD.Main_eWallet__c = account.USD_eWallet__c;
            ewalletTrusteeUSD.Marketplace_for_FX__c = account.USD_eWallet__r.Marketplace_for_FX__c;
            ewalletTrusteeUSD.Balance__c = 1000000000;
            trusteeList.add(ewalletTrusteeUSD);

            eWallet_Trustee__c ewalletTrusteeEUR = new eWallet_Trustee__c();
            ewalletTrusteeEUR.Account__c = account.Id;
            ewalletTrusteeEUR.CCY__c = 'EUR';
            ewalletTrusteeEUR.Trustee__c = 'Amicorp Trust';
            ewalletTrusteeEUR.Main_eWallet__c = account.EUR_eWallet__c;
            ewalletTrusteeEUR.Marketplace_for_FX__c = account.EUR_eWallet__r.Marketplace_for_FX__c;
            ewalletTrusteeEUR.Balance__c = 1000000000;
            trusteeList.add(ewalletTrusteeEUR);
        }

        insert trusteeList;
        
        Map<Invoice_Allocation__c, Allocation_Repayment__c> allocationRepaymentMap = new Map<Invoice_Allocation__c, Allocation_Repayment__c>();
        
        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c,
                                                  Due_Date__c,
                                                  invoice_amount__c,
                                                  Actual_Repayment_Received_Date__c,
                                           		  advance_send_to_supplier_date__c,
                                                  Supplier_Buyer_Map__c,
                                                  Supplier_Buyer_Map__r.Supplier__c,
                                                  Supplier_Buyer_Map__r.Buyer__c,
                                                  Supplier_Country__c,
                                                  discount_rate__c,
                                                  Trustee__c,
                                                  over_due_days__c,
                                                  Overdue_Supplier_discount_rate__c,
                                                  Overdue_Transaction_fees_Net__c,
                                                  Tolerance_overdue_days__c,
                                                  Repaid_Funded_Amount__c,
                                                  Repaid_Amount__c,
                                                  Repaid_Supplier_Balance_Amount__c,
                                                  Repaid_Supplier_Discount_Amount__c,
                                                  Phase__c,
                                                  Status__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        List<Invoice_Allocation__c> allocations = [select Id,
                                                   Name,
                                                   Incomlend_Profit_share__c,
                                                   Funder_prepayment__c,
                                                   Funder__c,
                                                   Funder__r.Country_of_Incorporation__c,
                                                   Funder__r.VAT_applicable__c,
                                                   amount__c,
                                                   Applied_MPR__c,
                                                   CCY__c,
                                                   Funder__r.Name,
                                                   eWallet__c,
                                                   eWallet__r.Name,
                                                   Applied_Funder_Discount_Profit_Share_Pct__c,
                                                   Repaid_Amount__c,
                                                   Repaid_Discount_Amount__c,
                                                   Status__c
                                            from Invoice_Allocation__c
                                            where Invoice__c = :invoice.Id];

        List<Id> allocationsIds = new List<Id>();
        for (Invoice_Allocation__c c: allocations) {
            allocationsIds.add(c.Id);
        }
        Invoice_Repayment__c invoiceRepayment = [select Id,
                                                    Name,
                                                    Repaid_Invoice_Ratio__c,
                                                    invoice_finance_deal__r.advance_send_to_supplier_date__c,
                                                    Due_Date__c,
                                                    Repaid_Amount__c,
                                                    Capped_Funder_Discount__c,
                                                    Supplier_Discount_Amount__c,
                                                    Funder_Amount__c,
                                                    Status__c,
                                                    Remaining_Invoice_Amount__c
                                            From Invoice_Repayment__c
                                            Where Invoice_Finance_Deal__c =: invoice.Id];

        invoiceRepayment.Repaid_Amount__c = invoice.invoice_amount__c;
        invoiceRepayment.Repaid_Invoice_Ratio__c = 1;
        update invoiceRepayment;

        for (Invoice_Allocation__c currentallocation: allocations) {
                Allocation_Repayment__c currentAllocationsRepayment = [select Id,
                                                       Name,
                                                       Invoice_Allocation__r.Funder__r.Country_of_Incorporation__c,
                                                       Invoice_Allocation__r.Funder__r.VAT_applicable__c,
                                                       Net_Discount_Amount__c,
                                                       Invoice_Allocation__r.Applied_Funder_Discount_Profit_Share_Pct__c,
                                                       Invoice_Allocation__r.Applied_MPR__c,
                                                       Amount__c,
                                                       Invoice_Allocation__r.CCY__c,
                                                       Invoice_Allocation__r.eWallet__c,
                                                       Invoice_Allocation__r.eWallet__r.Name,
                                                       Invoice_Allocation__r.Funder__c,
                                                       Invoice_Allocation__r.Funder__r.Name,
                                                       Invoice_Allocation__r.Id,
                                                       Invoice_Allocation__r.Name,
                                                       Status__c
                                                    From Allocation_Repayment__c
                                                    Where Invoice_Allocation__c = :currentallocation.Id LIMIT 1];
                allocationRepaymentMap.put(currentallocation, currentAllocationsRepayment);
        }

        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        System.debug('Call InvoiceRepayment_v1');
        InvoiceRepayment repayment = new InvoiceRepayment(  invoice,
                                                            allocationRepaymentMap,
                                                            invoiceRepayment,
                                                            1000,
                                                            700,
                                                            false,
                                                            null,
                                                            null,
                                                            new Helper_Log());
        Test.startTest();
        boolean isRepaidSuccessfully = repayment.repayInvoice();
        Test.stopTest();
        System.debug('result InvoiceRepayment_v1: ' + isRepaidSuccessfully);
        System.assertEquals(true, isRepaidSuccessfully);
    }

    // ---------- ///
    /*              
        Test Case 4 : 
        Currency : USD
        Payment Details : On time - no invoice repayment parameter
        Result expected : false
    */
    // ---------- //
    private static testMethod void validateInvoiceRepaymentNullInvoiceRepayment() {

        List<eWallet_Trustee__c> trusteeList = new List<eWallet_Trustee__c>();

        for (Account account : [SELECT Id, USD_eWallet__c, EUR_eWallet__c, USD_eWallet__r.Marketplace_for_FX__c, EUR_eWallet__r.Marketplace_for_FX__c FROM Account WHERE Sub_type__c != 'Purchaser']) {
            eWallet_Trustee__c ewalletTrusteeUSD = new eWallet_Trustee__c();
            ewalletTrusteeUSD.Account__c = account.Id;
            ewalletTrusteeUSD.CCY__c = 'USD';
            ewalletTrusteeUSD.Trustee__c = 'Amicorp Trust';
            ewalletTrusteeUSD.Main_eWallet__c = account.USD_eWallet__c;
            ewalletTrusteeUSD.Marketplace_for_FX__c = account.USD_eWallet__r.Marketplace_for_FX__c;
            ewalletTrusteeUSD.Balance__c = 1000000000;
            trusteeList.add(ewalletTrusteeUSD);

            eWallet_Trustee__c ewalletTrusteeEUR = new eWallet_Trustee__c();
            ewalletTrusteeEUR.Account__c = account.Id;
            ewalletTrusteeEUR.CCY__c = 'EUR';
            ewalletTrusteeEUR.Trustee__c = 'Amicorp Trust';
            ewalletTrusteeEUR.Main_eWallet__c = account.EUR_eWallet__c;
            ewalletTrusteeEUR.Marketplace_for_FX__c = account.EUR_eWallet__r.Marketplace_for_FX__c;
            ewalletTrusteeEUR.Balance__c = 1000000000;
            trusteeList.add(ewalletTrusteeEUR);
        }

        insert trusteeList;
        
        Map<Invoice_Allocation__c, Allocation_Repayment__c> allocationRepaymentMap = new Map<Invoice_Allocation__c, Allocation_Repayment__c>();
        
        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c,
                                                  Due_Date__c,
                                                  invoice_amount__c,
                                                  Actual_Repayment_Received_Date__c,
                                                  Supplier_Buyer_Map__c,
                                                  Supplier_Buyer_Map__r.Supplier__c,
                                                  Supplier_Buyer_Map__r.Buyer__c,
                                                  Supplier_Country__c,
                                                  Trustee__c,
                                                  over_due_days__c,
                                                  Overdue_Supplier_discount_rate__c,
                                                  Overdue_Transaction_fees_Net__c,
                                                  Tolerance_overdue_days__c,
                                                  Repaid_Funded_Amount__c,
                                                  Repaid_Amount__c,
                                                  Repaid_Supplier_Balance_Amount__c,
                                                  Repaid_Supplier_Discount_Amount__c,
                                                  Phase__c,
                                                  Status__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        List<Invoice_Allocation__c> allocations = [select Id,
                                                   Name,
                                                   Incomlend_Profit_share__c,
                                                   Funder__c,
                                                   Funder_prepayment__c,
                                                   Funder__r.Country_of_Incorporation__c,
                                                   Funder__r.VAT_applicable__c,
                                                   amount__c,
                                                   Applied_MPR__c,
                                                   CCY__c,
                                                   Funder__r.Name,
                                                   eWallet__c,
                                                   eWallet__r.Name,
                                                   Applied_Funder_Discount_Profit_Share_Pct__c,
                                                   Repaid_Amount__c,
                                                   Repaid_Discount_Amount__c,
                                                   Status__c
                                            from Invoice_Allocation__c
                                            where Invoice__c = :invoice.Id];

        List<Id> allocationsIds = new List<Id>();
        for (Invoice_Allocation__c c: allocations) {
            allocationsIds.add(c.Id);
        }

        for (Invoice_Allocation__c currentallocation: allocations) {
                Allocation_Repayment__c currentAllocationsRepayment = [select Id,
                                                       Name,
                                                       Invoice_Allocation__r.Funder__r.Country_of_Incorporation__c,
                                                       Invoice_Allocation__r.Funder__r.VAT_applicable__c,
                                                       Net_Discount_Amount__c,
                                                       Invoice_Allocation__r.Applied_Funder_Discount_Profit_Share_Pct__c,
                                                       Invoice_Allocation__r.Applied_MPR__c,
                                                       Amount__c,
                                                       Invoice_Allocation__r.CCY__c,
                                                       Invoice_Allocation__r.eWallet__c,
                                                       Invoice_Allocation__r.eWallet__r.Name,
                                                       Invoice_Allocation__r.Funder__c,
                                                       Invoice_Allocation__r.Funder__r.Name,
                                                       Invoice_Allocation__r.Id,
                                                       Invoice_Allocation__r.Name,
                                                       Status__c
                                                    From Allocation_Repayment__c
                                                    Where Invoice_Allocation__c = :currentallocation.Id LIMIT 1];
                allocationRepaymentMap.put(currentallocation, currentAllocationsRepayment);
        }

        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        System.debug('Call InvoiceRepayment_v1');
        InvoiceRepayment repayment = new InvoiceRepayment(  invoice,
                                                            allocationRepaymentMap,
                                                            null,
                                                            1000,
                                                            700,
                                                            false,
                                                            null,
                                                            null,
                                                            new Helper_Log());
        Test.startTest();
        boolean isRepaidSuccessfully = repayment.repayInvoice();
        Test.stopTest();
        System.debug('result InvoiceRepayment_v1: ' + isRepaidSuccessfully);
        System.assertEquals(false, isRepaidSuccessfully);
    }

    // ---------- ///
    /*              
        Test Case 5 : 
        Currency : USD
        Payment Details : On time - no allocation repayment parameter
        Result expected : false
    */
    // ---------- //
    private static testMethod void validateInvoiceRepaymentNullAllocationRepayment() {

        List<eWallet_Trustee__c> trusteeList = new List<eWallet_Trustee__c>();

        for (Account account : [SELECT Id, USD_eWallet__c, EUR_eWallet__c, USD_eWallet__r.Marketplace_for_FX__c, EUR_eWallet__r.Marketplace_for_FX__c FROM Account WHERE Sub_type__c != 'Purchaser']) {
            eWallet_Trustee__c ewalletTrusteeUSD = new eWallet_Trustee__c();
            ewalletTrusteeUSD.Account__c = account.Id;
            ewalletTrusteeUSD.CCY__c = 'USD';
            ewalletTrusteeUSD.Trustee__c = 'Amicorp Trust';
            ewalletTrusteeUSD.Main_eWallet__c = account.USD_eWallet__c;
            ewalletTrusteeUSD.Marketplace_for_FX__c = account.USD_eWallet__r.Marketplace_for_FX__c;
            ewalletTrusteeUSD.Balance__c = 1000000000;
            trusteeList.add(ewalletTrusteeUSD);

            eWallet_Trustee__c ewalletTrusteeEUR = new eWallet_Trustee__c();
            ewalletTrusteeEUR.Account__c = account.Id;
            ewalletTrusteeEUR.CCY__c = 'EUR';
            ewalletTrusteeEUR.Trustee__c = 'Amicorp Trust';
            ewalletTrusteeEUR.Main_eWallet__c = account.EUR_eWallet__c;
            ewalletTrusteeEUR.Marketplace_for_FX__c = account.EUR_eWallet__r.Marketplace_for_FX__c;
            ewalletTrusteeEUR.Balance__c = 1000000000;
            trusteeList.add(ewalletTrusteeEUR);
        }

        insert trusteeList;
        
        Map<Invoice_Allocation__c, Allocation_Repayment__c> allocationRepaymentMap = new Map<Invoice_Allocation__c, Allocation_Repayment__c>();
        
        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c,
                                                  Due_Date__c,
                                                  Actual_Repayment_Received_Date__c,
                                                  invoice_amount__c,
                                                  Supplier_Buyer_Map__c,
                                                  Supplier_Buyer_Map__r.Supplier__c,
                                                  Supplier_Buyer_Map__r.Buyer__c,
                                                  Supplier_Country__c,
                                                  Trustee__c,
                                                  over_due_days__c,
                                                  Overdue_Supplier_discount_rate__c,
                                                  Overdue_Transaction_fees_Net__c,
                                                  Tolerance_overdue_days__c,
                                                  Repaid_Funded_Amount__c,
                                                  Repaid_Amount__c,
                                                  Repaid_Supplier_Balance_Amount__c,
                                                  Repaid_Supplier_Discount_Amount__c,
                                                  Phase__c,
                                                  Status__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        List<Invoice_Allocation__c> allocations = [select Id,
                                                   Name,
                                                   Incomlend_Profit_share__c,
                                                   Funder__c,
                                                   Funder_prepayment__c,
                                                   Funder__r.Country_of_Incorporation__c,
                                                   Funder__r.VAT_applicable__c,
                                                   amount__c,
                                                   Applied_MPR__c,
                                                   CCY__c,
                                                   Funder__r.Name,
                                                   eWallet__c,
                                                   eWallet__r.Name,
                                                   Applied_Funder_Discount_Profit_Share_Pct__c,
                                                   Repaid_Amount__c,
                                                   Repaid_Discount_Amount__c,
                                                   Status__c
                                            from Invoice_Allocation__c
                                            where Invoice__c = :invoice.Id];

        List<Id> allocationsIds = new List<Id>();
        for (Invoice_Allocation__c c: allocations) {
            allocationsIds.add(c.Id);
        }
        Invoice_Repayment__c invoiceRepayment = [select Id,
                                                    Name,
                                                    Repaid_Invoice_Ratio__c,
                                                    invoice_finance_deal__r.advance_send_to_supplier_date__c,
                                                    Due_Date__c,
                                                    Repaid_Amount__c,
                                                    Capped_Funder_Discount__c,
                                                    Supplier_Discount_Amount__c,
                                                    Funder_Amount__c,
                                                    Status__c,
                                                    Remaining_Invoice_Amount__c
                                            From Invoice_Repayment__c
                                            Where Invoice_Finance_Deal__c =: invoice.Id];

        invoiceRepayment.Repaid_Amount__c = invoice.invoice_amount__c;
        invoiceRepayment.Repaid_Invoice_Ratio__c = 1;
        update invoiceRepayment;

        for (Invoice_Allocation__c currentallocation: allocations) {
                Allocation_Repayment__c currentAllocationsRepayment = null;
                allocationRepaymentMap.put(currentallocation, currentAllocationsRepayment);
        }

        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        System.debug('Call InvoiceRepayment_v1');
        InvoiceRepayment repayment = new InvoiceRepayment(  invoice,
                                                            allocationRepaymentMap,
                                                            invoiceRepayment,
                                                            1000,
                                                            700,
                                                            false,
                                                            null,
                                                            null,
                                                            new Helper_Log());
        Test.startTest();
        boolean isRepaidSuccessfully = repayment.repayInvoice();
        Test.stopTest();
        System.debug('result InvoiceRepayment_v1: ' + isRepaidSuccessfully);
        System.assertEquals(false, isRepaidSuccessfully);
    }
}