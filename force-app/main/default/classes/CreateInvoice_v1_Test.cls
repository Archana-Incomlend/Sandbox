@isTest
private class CreateInvoice_v1_Test {
    private static @testSetup void setup() {
        List<User> userList = new List<User>();
        List<FX_Rates__c> fxRatesList = new List<FX_Rates__c>();
        List<Contact> contactList = new List<Contact>();
        List<Account> accountList = new List<Account>();
        List<Bank_Account__c> bankAccountList = new List<Bank_Account__c>();
        List<eWallet__c> ewalletList = new List<eWallet__c>();
        List<incomlend_product__c> productList = new List<incomlend_product__c>();
        List<Supplier_Buyer_Map__c> mapList = new List<Supplier_Buyer_Map__c>();
        List<invoice_finance_deal__c> invoiceList = new List<invoice_finance_deal__c>();
        List<Invoice_Allocation__c> allocationList = new List<Invoice_Allocation__c>();

        Id testProfileId = [select Id
                            from Profile
                            LIMIT 1].Id;
        
        User buyerUser = new User();
        buyerUser.Username = 'testbuyerusd@yopmail.com';
        buyerUser.FirstName = 'TEST';
        buyerUser.LastName = 'BUYUSD';
        buyerUser.Email = 'testbuyerusd@yopmail.com';
        buyerUser.TimeZoneSidKey = 'Asia/Singapore';
        buyerUser.Alias = 'USDBUY';
        buyerUser.LocaleSidKey = 'en_US';
        buyerUser.LanguageLocaleKey = 'en_US';
        buyerUser.EmailEncodingKey = 'UTF-8';
        buyerUser.ProfileId = testProfileId;
        userList.add(buyerUser);
        
        User supplierUser = new User();
        supplierUser.Username = 'testsupplierusd@yopmail.com';
        supplierUser.FirstName = 'TEST';
        supplierUser.LastName = 'SUPPUSD';
        supplierUser.Email = 'testsupplierusd@yopmail.com';
        supplierUser.TimeZoneSidKey = 'Asia/Singapore';
        supplierUser.Alias = 'USDSUPP';
        supplierUser.LocaleSidKey = 'en_US';
        supplierUser.LanguageLocaleKey = 'en_US';
        supplierUser.EmailEncodingKey = 'UTF-8';
        supplierUser.ProfileId = testProfileId;
        userList.add(supplierUser);

        insert userList;
        
        FX_Rates__c fxRateEUR = new FX_Rates__c();
        fxRateEUR.from_currency__c = 'EUR';
        fxRateEUR.to_currency__c = 'USD';
        fxRateEUR.date__c = Date.today();
        fxRateEUR.rate__c = 1.4356129;
        fxRatesList.add(fxRateEUR);
        
        FX_Rates__c fxRateSGD = new FX_Rates__c();
        fxRateSGD.from_currency__c = 'SGD';
        fxRateSGD.to_currency__c = 'USD';
        fxRateSGD.date__c = Date.today();
        fxRateSGD.rate__c = 0.846402;
        fxRatesList.add(fxRateSGD);

        insert fxRatesList;
        
        Marketplace__c marketplace = new Marketplace__c();
        marketplace.FX_Rate_for_MI__c = fxRateEUR.Id;
        marketplace.currency_symbol__c = '$';
        marketplace.minimum_purchase_amount__c = 1;
        marketplace.latest_to_usd_rate__c = 1.4356129;
        insert marketplace;
        
        Contact contactSupplier = new Contact();
        contactSupplier.Email = 'testsupplierusd@yopmail.com';
        contactSupplier.FirstName = 'TEST';
        contactSupplier.LastName = 'SUPP';
        contactList.add(contactSupplier);
        
        Contact contactBuyer = new Contact();
        contactBuyer.Email = 'testbuyerusd@yopmail.com';
        contactBuyer.FirstName = 'TEST';
        contactBuyer.LastName = 'BUY';
        contactList.add(contactBuyer);
        
        Contact contactFunder = new Contact();
        contactFunder.Email = 'testfunderusd@yopmail.com';
        contactFunder.FirstName = 'TEST';
        contactFunder.LastName = 'FUNDER';
        contactList.add(contactFunder);

        insert contactList;

        Account agent = new Account();
        agent.Name = 'Agent';
        agent.Type = 'Agent';
        insert agent;
        
        Account funder = new Account();
        funder.Name = 'Funder';
        funder.Type = 'Customer';
        funder.Sub_type__c = 'Purchaser';
        funder.Primary_Contact__c = contactFunder.Id;
        accountList.add(funder);
        
        Account supplier = new Account();
        supplier.Name = 'Supplier';
        supplier.Sales_Owner__c = supplierUser.Id;
        supplier.Primary_Contact__c = contactSupplier.Id;
        supplier.Agent__c = agent.Id;
        accountList.add(supplier);
        
        Account buyer = new Account();
        buyer.Name = 'Buyer';
        buyer.Type = 'Buyer';
        buyer.Sales_Owner__c = buyerUser.Id;
        buyer.Primary_Contact__c = contactBuyer.Id;
        buyer.Agent__c = agent.Id;
        accountList.add(buyer);

        insert accountList;
        
        Bank_Account__c usd = new Bank_Account__c();
        usd.Account__c = funder.Id;
        usd.Bank_Name__c = 'USD Bank';
        usd.Currency__c = 'USD';
        usd.Country__c = 'Singapore';
        usd.Address__c = 'USD Address';
        usd.SWIFT_Code__c = 'SWFTUSD';
        usd.Beneficiary_Name__c = 'USD Beneficiary';
        usd.transfer_cutoff_time__c = '14:00';
        usd.Bank_Account_Number__c = '0000-0001';
        bankAccountList.add(usd);
        
        Bank_Account__c eur = new Bank_Account__c();
        eur.Account__c = funder.Id;
        eur.Bank_Name__c = 'EUR Bank';
        eur.Currency__c = 'EUR';
        eur.Country__c = 'Singapore';
        eur.Address__c = 'EUR Address';
        eur.SWIFT_Code__c = 'SWFTEUR';
        eur.Beneficiary_Name__c = 'EUR Beneficiary';
        eur.transfer_cutoff_time__c = '12:00';
        eur.Bank_Account_Number__c = '0000-0002';
        bankAccountList.add(eur);

        insert bankAccountList;
        
        eWallet__c eWalletUSD = new eWallet__c();
        eWalletUSD.Account__c = funder.Id;
        eWalletUSD.CCY__c = 'USD';
        eWalletUSD.Marketplace_for_FX__c = marketplace.Id;
        eWalletUSD.Bank_Account__c = usd.Id;
        eWalletUSD.Balance__c = 1000000000;
        ewalletList.add(eWalletUSD);

        eWallet__c eWalletEUR = new eWallet__c();
        eWalletEUR.Account__c = funder.Id;
        eWalletEUR.CCY__c = 'EUR';
        eWalletEUR.Marketplace_for_FX__c = marketplace.Id;
        eWalletEUR.Bank_Account__c = eur.Id;
        eWalletEUR.Balance__c = 75000000;
        ewalletList.add(eWalletEUR);

        insert ewalletList;
        
        funder.USD_eWallet__c = eWalletUSD.Id;
        funder.EUR_eWallet__c = eWalletEUR.Id;
        update funder;
        
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
        supplierBuyerMapUSD.buyer_supplier_map_approved__c = true;
        supplierBuyerMapUSD.Active__c = true;
        supplierBuyerMapUSD.map_onboarding_stage__c = '90.Onboarded';
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
        supplierBuyerMapEUR.buyer_supplier_map_approved__c = true;
        supplierBuyerMapEUR.Active__c = true;
        supplierBuyerMapEUR.map_onboarding_stage__c = '90.Onboarded';
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
        invoiceUSD.discount_rate__c = 0.75;
        invoiceList.add(invoiceUSD);

        invoice_finance_deal__c invoiceEUR = new invoice_finance_deal__c();
        invoiceEUR.Due_Date__c = Date.today().addMonths(2);
        invoiceEUR.Actual_Repayment_Received_Date__c = Date.today().addDays(10);
        invoiceEUR.advance_send_to_supplier_date__c = Date.today();
        invoiceEUR.CCY__c = 'EUR';
        invoiceEUR.Phase__c = '3:IN PROGRESS';
        invoiceEUR.Status__c = 'In Progress';
        invoiceEUR.invoice_amount__c = 175000;
        invoiceEUR.supplier_invoice_reference_number__c = 'INV-0002';
        invoiceEUR.Supplier_Buyer_Map__c = supplierBuyerMapEUR.Id;
        invoiceEUR.requested_amount__c = 75000;
        invoiceEUR.discount_rate__c = 0.75;
        invoiceList.add(invoiceEUR);

        insert invoiceList;
        
        Invoice_Allocation__c allocationUSD = new Invoice_Allocation__c();
        allocationUSD.Applied_Funder_Discount_Profit_Share_Pct__c = 30.00;
        allocationUSD.Funder__c = funder.Id;
        allocationUSD.amount__c = 0;
        allocationUSD.Invoice__c = invoiceUSD.Id;
        allocationUSD.Status__c = 'Reservation';
        allocationUSD.Allocation_Reservation_date__c = DateTime.now();
        allocationUSD.eWallet__c = eWalletUSD.Id;
        allocationUSD.CCY__c = 'USD';
        allocationList.add(allocationUSD);
        
        Invoice_Allocation__c allocationEUR = new Invoice_Allocation__c();
        allocationEUR.Applied_Funder_Discount_Profit_Share_Pct__c = 10.00;
        allocationEUR.Funder__c = funder.Id;
        allocationEUR.amount__c = 0;
        allocationEUR.Invoice__c = invoiceEUR.Id;
        allocationEUR.Status__c = 'Reservation';
        allocationEUR.Allocation_Reservation_date__c = DateTime.now();
        allocationEUR.eWallet__c = eWalletEUR.Id;
        allocationEUR.CCY__c = 'EUR';
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
    }
    
    private static testMethod void validateRepaidCreateTaxInvoiceFunder() {
        Map<InvoiceUtil.Description, Decimal> amountMap = new Map<InvoiceUtil.Description, Decimal>();
        Map<InvoiceUtil.Description, Decimal> amountNoTaxMap = new Map<InvoiceUtil.Description, Decimal>();
        
        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        Invoice_Allocation__c allocation = [select Id,
                                                   Incomlend_Profit_share__c,
                                                   Funder__c
                                            from Invoice_Allocation__c
                                            where Invoice__c = :invoice.Id];

        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        amountMap.put(InvoiceUtil.Description.FUNDER_PROFIT_SHARE, allocation.Incomlend_Profit_share__c);
        amountNoTaxMap.put(InvoiceUtil.Description.TEST, allocation.Incomlend_Profit_share__c);
        
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(allocation.Funder__c,
                                                                      invoice,
                                                                      allocation,
                                                                      amountMap,
                                                                      taxRate,
                                                                      amountNoTaxMap,
                                                                      InvoiceUtil.RecordType.FUNDER,
                                                                      InvoiceUtil.ActionType.Repaid,
                                                                      false,
                                                                      null,
                                                                      false);
        boolean isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        System.assertEquals(true, isCreatedSuccessfully);
    }
    
    private static testMethod void validateRepaidCreateTaxInvoiceFunderAgent() {
        Map<InvoiceUtil.Description, Decimal> amountMap = new Map<InvoiceUtil.Description, Decimal>();
        Map<InvoiceUtil.Description, Decimal> taxMap = new Map<InvoiceUtil.Description, Decimal>();
        
        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        Invoice_Allocation__c allocation = [select Id,
                                                   Incomlend_Profit_share__c,
                                                   Funder__c
                                            from Invoice_Allocation__c
                                            where Invoice__c = :invoice.Id];
        
        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        amountMap.put(InvoiceUtil.Description.FUNDER_PROFIT_SHARE, allocation.Incomlend_Profit_share__c);
        
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(allocation.Funder__c,
                                                                      invoice,
                                                                      allocation,
                                                                      amountMap,
                                                                      taxRate,
                                                                      new Map<InvoiceUtil.Description, Decimal>(),
                                                                      InvoiceUtil.RecordType.FUNDER_AGENT,
                                                                      InvoiceUtil.ActionType.Repaid,
                                                                      false,
                                                                      null,
                                                                      false);
        boolean isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        System.assertEquals(true, isCreatedSuccessfully);
    }
    
    private static testMethod void validateRepaidCreateTaxInvoiceMapAgent() {
        Map<InvoiceUtil.Description, Decimal> amountMap = new Map<InvoiceUtil.Description, Decimal>();
        Map<InvoiceUtil.Description, Decimal> taxMap = new Map<InvoiceUtil.Description, Decimal>();
        
        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        Invoice_Allocation__c allocation = [select Id,
                                                   Incomlend_Profit_share__c,
                                                   Funder__c
                                            from Invoice_Allocation__c
                                            where Invoice__c = :invoice.Id];
        
        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        amountMap.put(InvoiceUtil.Description.FUNDER_PROFIT_SHARE, allocation.Incomlend_Profit_share__c);
        
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(allocation.Funder__c,
                                                                      invoice,
                                                                      allocation,
                                                                      amountMap,
                                                                      taxRate,
                                                                      new Map<InvoiceUtil.Description, Decimal>(),
                                                                      InvoiceUtil.RecordType.MAP_AGENT,
                                                                      InvoiceUtil.ActionType.Repaid,
                                                                      false,
                                                                      null,
                                                                      false);
        boolean isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        System.assertEquals(true, isCreatedSuccessfully);
    }
    
    private static testMethod void validateFundedCreateTaxInvoice() {
        Map<InvoiceUtil.Description, Decimal> amountMap = new Map<InvoiceUtil.Description, Decimal>();
        Map<InvoiceUtil.Description, Decimal> taxMap = new Map<InvoiceUtil.Description, Decimal>();
        
        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c,
                                                  Supplier_name__c,
                                                  advanced_amount__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        amountMap.put(InvoiceUtil.Description.SUPPLIER_DISCOUNT_AMOUNT, invoice.advanced_amount__c);
        amountMap.put(InvoiceUtil.Description.ADMIN_FEES, 30.00);
        
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(invoice.Supplier_name__c,
                                                                      invoice,
                                                                      null,
                                                                      amountMap,
                                                                      taxRate,
                                                                      new Map<InvoiceUtil.Description, Decimal>(),
                                                                      InvoiceUtil.RecordType.SUPPLIER,
                                                                      InvoiceUtil.ActionType.Funded,
                                                                      false,
                                                                      null,
                                                                      false);
        boolean isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        System.assertEquals(true, isCreatedSuccessfully);
    }
    
    private static testMethod void validateRepaidCreateTaxInvoiceEarlyPayment() {
        Map<InvoiceUtil.Description, Decimal> amountMap = new Map<InvoiceUtil.Description, Decimal>();
        Map<InvoiceUtil.Description, Decimal> taxMap = new Map<InvoiceUtil.Description, Decimal>();

        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c,
                                                  Supplier_name__c,
                                                  advanced_amount__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        amountMap.put(InvoiceUtil.Description.SUPPLIER_DISCOUNT_AMOUNT_ADJUSTMENT, invoice.advanced_amount__c);
        
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(invoice.Supplier_name__c,
                                                                      invoice,
                                                                      null,
                                                                      amountMap,
                                                                      taxRate,
                                                                      new Map<InvoiceUtil.Description, Decimal>(),
                                                                      InvoiceUtil.RecordType.SUPPLIER,
                                                                      InvoiceUtil.ActionType.Repaid,
                                                                      true,
                                                                      null,
                                                                      false);
        boolean isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        System.assertEquals(true, isCreatedSuccessfully);
    }
    
    private static testMethod void validateRepaidCreateTaxInvoiceOverdue() {
        Map<InvoiceUtil.Description, Decimal> amountMap = new Map<InvoiceUtil.Description, Decimal>();
        Map<InvoiceUtil.Description, Decimal> taxMap = new Map<InvoiceUtil.Description, Decimal>();

        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c,
                                                  Supplier_name__c,
                                                  advanced_amount__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        amountMap.put(InvoiceUtil.Description.SUPPLIER_DISCOUNT_AMOUNT_OVERDUE, invoice.advanced_amount__c);
        
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(invoice.Supplier_name__c,
                                                                      invoice,
                                                                      null,
                                                                      amountMap,
                                                                      taxRate,
                                                                      new Map<InvoiceUtil.Description, Decimal>(),
                                                                      InvoiceUtil.RecordType.SUPPLIER,
                                                                      InvoiceUtil.ActionType.Repaid,
                                                                      false,
                                                                      null,
                                                                      false);
        boolean isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        System.assertEquals(true, isCreatedSuccessfully);
    }
    
    private static testMethod void validateRepaidCreateTaxInvoiceBlankDesc() {
        Map<InvoiceUtil.Description, Decimal> amountMap = new Map<InvoiceUtil.Description, Decimal>();
        Map<InvoiceUtil.Description, Decimal> taxMap = new Map<InvoiceUtil.Description, Decimal>();

        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c,
                                                  Supplier_name__c,
                                                  advanced_amount__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        amountMap.put(InvoiceUtil.Description.TEST, invoice.advanced_amount__c);
        
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(invoice.Supplier_name__c,
                                                                      invoice,
                                                                      null,
                                                                      amountMap,
                                                                      taxRate,
                                                                      new Map<InvoiceUtil.Description, Decimal>(),
                                                                      InvoiceUtil.RecordType.SUPPLIER,
                                                                      InvoiceUtil.ActionType.Repaid,
                                                                      false,
                                                                      null,
                                                                      false);
        boolean isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        System.assertEquals(true, isCreatedSuccessfully);
    }
    
    private static testMethod void validateRepaidCreateTaxInvoiceEURCCY() {
        Map<InvoiceUtil.Description, Decimal> amountMap = new Map<InvoiceUtil.Description, Decimal>();
        Map<InvoiceUtil.Description, Decimal> taxMap = new Map<InvoiceUtil.Description, Decimal>();

        invoice_finance_deal__c invoice = [select Id,
                                                  Name,
                                                  CCY__c,
                                                  Supplier_name__c,
                                                  advanced_amount__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'EUR'];
        Decimal taxRate = [select Rate__c
                               from Tax_Rate__c
                               LIMIT 1].Rate__c;
        
        amountMap.put(InvoiceUtil.Description.TEST, invoice.advanced_amount__c);
        
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(invoice.Supplier_name__c,
                                                                      invoice,
                                                                      null,
                                                                      amountMap,
                                                                      taxRate,
                                                                      new Map<InvoiceUtil.Description, Decimal>(),
                                                                      InvoiceUtil.RecordType.SUPPLIER,
                                                                      InvoiceUtil.ActionType.Repaid,
                                                                      false,
                                                                      null,
                                                                      false);
        boolean isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        System.assertEquals(true, isCreatedSuccessfully);
    }
    
    private static testMethod void validateCreateTaxInvoiceIncorrectRecordType() {
        invoice_finance_deal__c invoice = [select Supplier_name__c,
                                                  CCY__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(invoice.Supplier_name__c,
                                                                      invoice,
                                                                      null,
                                                                      null,
                                                                      null,
                                                                      new Map<InvoiceUtil.Description, Decimal>(),
                                                                      InvoiceUtil.RecordType.TEST,
                                                                      InvoiceUtil.ActionType.Repaid,
                                                                      false,
                                                                      null,
                                                                      false);
        boolean isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        System.assertEquals(false, isCreatedSuccessfully);
    }
    
    private static testMethod void validateCreateTaxInvoiceIncorrectActionType() {
        invoice_finance_deal__c invoice = [select Supplier_name__c,
                                                  CCY__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(invoice.Supplier_name__c,
                                                                      invoice,
                                                                      null,
                                                                      null,
                                                                      null,
                                                                      new Map<InvoiceUtil.Description, Decimal>(),
                                                                      InvoiceUtil.RecordType.SUPPLIER,
                                                                      InvoiceUtil.ActionType.Test,
                                                                      false,
                                                                      null,
                                                                      false);
        boolean isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        System.assertEquals(false, isCreatedSuccessfully);
    }
    
    private static testMethod void validateCreateTaxInvoiceExceptionThrown() {
        boolean isCreatedSuccessfully = true;
        invoice_finance_deal__c invoice = [select Supplier_name__c,
                                                  CCY__c
                                           from invoice_finance_deal__c
                                           where CCY__c = 'USD'];
        CreateInvoice_v1 createInvoiceTestApxc = new CreateInvoice_v1(invoice.Supplier_name__c,
                                                                      invoice,
                                                                      null,
                                                                      null,
                                                                      null,
                                                                      new Map<InvoiceUtil.Description, Decimal>(),
                                                                      InvoiceUtil.RecordType.SUPPLIER,
                                                                      null,
                                                                      false,
                                                                      null,
                                                                      false);
        try {
            isCreatedSuccessfully = createInvoiceTestApxc.createInvoice();
        } catch (Exception e) {
            System.assertEquals(false, isCreatedSuccessfully);
            System.assertEquals('Exception thrown.', e.getMessage());
        }
    }
}