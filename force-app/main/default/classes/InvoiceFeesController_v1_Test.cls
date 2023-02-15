@isTest
private class InvoiceFeesController_v1_Test {
    private static @testSetup void setup() {
        Id testProfileId = [select Id
                            from Profile
                            LIMIT 1].Id;
        
        User supplierUserUSD = new User();
        supplierUserUSD.Username = 'testsupplierusd@yopmail.com';
        supplierUserUSD.FirstName = 'TEST';
        supplierUserUSD.LastName = 'SUPPUSD';
        supplierUserUSD.Email = 'testsupplierusd@yopmail.com';
        supplierUserUSD.TimeZoneSidKey = 'Asia/Singapore';
        supplierUserUSD.Alias = 'USDSUPP';
        supplierUserUSD.LocaleSidKey = 'en_US';
        supplierUserUSD.LanguageLocaleKey = 'en_US';
        supplierUserUSD.EmailEncodingKey = 'UTF-8';
        supplierUserUSD.ProfileId = testProfileId;
        insert supplierUserUSD;
        
        User buyerUserUSD = new User();
        buyerUserUSD.Username = 'testbuyerusd@yopmail.com';
        buyerUserUSD.FirstName = 'TEST';
        buyerUserUSD.LastName = 'BUYUSD';
        buyerUserUSD.Email = 'testbuyerusd@yopmail.com';
        buyerUserUSD.TimeZoneSidKey = 'Asia/Singapore';
        buyerUserUSD.Alias = 'USDBUY';
        buyerUserUSD.LocaleSidKey = 'en_US';
        buyerUserUSD.LanguageLocaleKey = 'en_US';
        buyerUserUSD.EmailEncodingKey = 'UTF-8';
        buyerUserUSD.ProfileId = testProfileId;
        insert buyerUserUSD;
        
        FX_Rates__c fxRateEUR = new FX_Rates__c();
        fxRateEUR.from_currency__c = 'EUR';
        fxRateEUR.to_currency__c = 'USD';
        fxRateEUR.date__c = Date.today();
        fxRateEUR.rate__c = 1.4356129;
        insert fxRateEUR;
        
        Marketplace__c marketplace = new Marketplace__c();
        marketplace.FX_Rate_for_MI__c = fxRateEUR.Id;
        marketplace.currency_symbol__c = '$';
        marketplace.minimum_purchase_amount__c = 1;
        marketplace.latest_to_usd_rate__c = 1.4356129;
        insert marketplace;
        
        Contact contactSupplierUSD = new Contact();
        contactSupplierUSD.Email = 'testsupplierusd@yopmail.com';
        contactSupplierUSD.FirstName = 'TEST';
        contactSupplierUSD.LastName = 'SUPPUSD';
        insert contactSupplierUSD;
        
        Contact contactBuyerUSD = new Contact();
        contactBuyerUSD.Email = 'testbuyerusd@yopmail.com';
        contactBuyerUSD.FirstName = 'TEST';
        contactBuyerUSD.LastName = 'BUYUSD';
        insert contactBuyerUSD;
        
        Account agent = new Account();
        agent.Name = 'Agent';
        agent.Type = 'Agent';
        insert agent;
        
        Account supplierUSD = new Account();
        supplierUSD.Name = 'SupplierUSD';
        supplierUSD.Sales_Owner__c = supplierUserUSD.Id;
        supplierUSD.Primary_Contact__c = contactSupplierUSD.Id;
        supplierUSD.Agent__c = agent.Id;
        insert supplierUSD;
        
        Account buyerUSD = new Account();
        buyerUSD.Name = 'BuyerUSD';
        buyerUSD.Type = 'Buyer';
        buyerUSD.Sales_Owner__c = buyerUserUSD.Id;
        buyerUSD.Primary_Contact__c = contactBuyerUSD.Id;
        buyerUSD.Agent__c = agent.Id;
        insert buyerUSD;
        
        incomlend_product__c customProductUSD = new incomlend_product__c();
        customProductUSD.Name = 'Test Standard USD';
        customProductUSD.launch_date__c = Date.today();
        customProductUSD.months_relationship_with_buyer__c = 12;
        customProductUSD.Auction_Type__c = 'Fixed Discount Rate';
        customProductUSD.CCYs__c = 'USD';
        customProductUSD.approved__c = true;
        insert customProductUSD;
        
        Supplier_Buyer_Map__c supplierBuyerMapUSD = new Supplier_Buyer_Map__c();
        supplierBuyerMapUSD.Supplier__c = supplierUSD.Id;
        supplierBuyerMapUSD.Buyer__c = buyerUSD.Id;
        supplierBuyerMapUSD.Marketplace__c = marketplace.Id;
        supplierBuyerMapUSD.Incomlend_product__c = customProductUSD.Id;
        supplierBuyerMapUSD.Buyer_Sales_Zone__c = 10;
        supplierBuyerMapUSD.Supplier_Zone__c = 5;
        supplierBuyerMapUSD.Overdue_Additional_Discount_rate__c = 1.25;
        supplierBuyerMapUSD.Supplier_Discount_Rate__c = 5.25;
        //supplierBuyerMapUSD.Trustee__c = 'Amicorp';
        insert supplierBuyerMapUSD;
        
        invoice_finance_deal__c invoiceUSD = new invoice_finance_deal__c();
        invoiceUSD.discount_rate__c = 0.75;
        invoiceUSD.Due_Date__c = Date.today();
        invoiceUSD.advance_send_to_supplier_date__c = Date.today();
        invoiceUSD.CCY__c = 'USD';
        invoiceUSD.Phase__c = '3:IN PROGRESS';
        invoiceUSD.Status__c = 'In Progress';
        invoiceUSD.invoice_amount__c = 250000;
        invoiceUSD.supplier_invoice_reference_number__c = 'INV-0001';
        invoiceUSD.Supplier_Buyer_Map__c = supplierBuyerMapUSD.Id;
        invoiceUSD.requested_amount__c = 225000;
        //invoiceUSD.Trustee__c = 'Amicorp';
        insert invoiceUSD;
        
        Tax_Invoice__c taxInvoiceWithBreakdown = new Tax_Invoice__c();
        taxInvoiceWithBreakdown.Invoice__c = invoiceUSD.Id;
        taxInvoiceWithBreakdown.Customer__c = supplierUSD.Id;
        insert taxInvoiceWithBreakdown;
        
        Tax_Invoice_Fee_Breakdown__c taxInvoiceFeeBreakdown = new Tax_Invoice_Fee_Breakdown__c();
        taxInvoiceFeeBreakdown.Description__c = 'TEST';
        taxInvoiceFeeBreakdown.Quantity__c = 1;
        taxInvoiceFeeBreakdown.Unit_Price__c = 1300.00;
        taxInvoiceFeeBreakdown.Tax_Invoice__c = taxInvoiceWithBreakdown.Id;
        insert taxInvoiceFeeBreakdown;
        
        Tax_Invoice__c taxInvoiceNoBreakdown = new Tax_Invoice__c();
        taxInvoiceNoBreakdown.Invoice__c = invoiceUSD.Id;
        taxInvoiceNoBreakdown.Customer__c = supplierUSD.Id;
        insert taxInvoiceNoBreakdown;
    }
    
	private static testMethod void callTaxInvoiceFeesControllerSuccess() {
        Tax_Invoice__c taxInvoice = [select Id
                                     from Tax_Invoice__c
                                     order by CreatedDate asc
                                     LIMIT 1];
        
        InvoiceFeesController_v1 taxInvoiceFeesController = new InvoiceFeesController_v1(new ApexPages.StandardController(taxInvoice));
        
        System.assertEquals(false, taxInvoiceFeesController.invoiceFeesList.isEmpty());
    }
    
    private static testMethod void callTaxInvoiceFeesControllerNullStandardController() {
        try {
            InvoiceFeesController_v1 taxInvoiceFeesController = new InvoiceFeesController_v1(null);
        } catch (Exception e) {
            System.assertEquals(true, e.getMessage().contains('null'));
        }
    }
    
    private static testMethod void callTaxInvoiceFeesControllerNoTaxInvoiceRecord() {
        try {
            Tax_Invoice__c taxInvoice = [select Id
                                     	 from Tax_Invoice__c
                                     	 order by CreatedDate desc
                                     	 LIMIT 1];
            InvoiceFeesController_v1 taxInvoiceFeesController = new InvoiceFeesController_v1(new ApexPages.StandardController(taxInvoice));
        } catch (Exception e) {
            System.assertEquals(true, e.getMessage().contains('List has no rows'));
        }
    }
    
    private static testMethod void callTaxInvoiceFeesControllerNullTaxInvoice() {
        try {
            InvoiceFeesController_v1 taxInvoiceFeesController = new InvoiceFeesController_v1(new ApexPages.StandardController(null));
        } catch (Exception e) {
            System.assertEquals(true, e.getMessage().contains('null'));
        }
    }
}