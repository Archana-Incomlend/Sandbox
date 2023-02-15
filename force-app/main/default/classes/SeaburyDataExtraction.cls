//===============================================================================================================
// Part of the Data Extraction process.
// This class extracts all data regarding Seabury Data Extraction process.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class SeaburyDataExtraction extends DataQualityController
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    // TODO: Replace this field with Seabury Account ID value
    private id field_SeaburyAccountId = '0010I00001rkssk'; // <= Sigma ID for testing purpose / Seabury Account ID: '0010I00001xwEKN';
    private List<eWallet__c> field_existingeWallets;
    private List<Transaction__c> field_existingTransactions;
    private List<Invoice_Finance_Deal__c> field_existingInvoices;
    private List<Supplier_Buyer_Map__c> field_existingSupplierBuyerMaps;
    private List<Account> field_existingAccounts;

    //===========================================================================================================
    // Properties
    //===========================================================================================================
    private id SeaburyAccountId
    {
        get {return field_SeaburyAccountId;}
    }

    private List<eWallet__c> ExistingeWallets
    {
        get {return field_existingeWallets;}
        set {field_existingeWallets = value;}
    }

    private List<Transaction__c> ExistingTransactions
    {
        get {return field_existingTransactions;}
        set {field_existingTransactions = value;}
    }

    private List<Invoice_Finance_Deal__c> ExistingInvoices
    {
        get {return field_existingInvoices;}
        set {field_existingInvoices = value;}
    }

    private List<Supplier_Buyer_Map__c> ExistingSupplierBuyerMaps
    {
        get {return field_existingSupplierBuyerMaps;}
        set {field_existingSupplierBuyerMaps = value;}
    }

    private List<Account> ExistingAccounts
    {
        get {return field_existingAccounts;}
        set {field_existingAccounts = value;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public SeaburyDataExtraction()
    {
        super();

        this.Name = 'Seabury Data Extraction';
    }

    //===========================================================================================================
    // Methods
    //===========================================================================================================
    public override DataQualityResponse execute(DataQualityRequest request)
    {
        this.Request = request;

        ExistingeWallets = new List<eWallet__c>();
        ExistingTransactions = new List<Transaction__c>();
        ExistingInvoices = new List<Invoice_Finance_Deal__c>();
        ExistingSupplierBuyerMaps = new List<Supplier_Buyer_Map__c>();
        ExistingAccounts = new List<Account>();

        loadeWallets();
        loadTransactions();
        loadInvoices();
        loadSupplierBuyerMaps();
        loadAccounts();
        createExtraction();
        
        return new DataQualityResponse(IsValid);
    }

    private void loadeWallets()
    {
        try
        {
            Request.FullLogs.Log('1. Loading existing eWallet(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            ExistingeWallets = [    SELECT  id,
                                            Name,
                                            Account__c,
                                            Account__r.Name,
                                            CCY__c,
                                            Total_Position__c,
                                            Balance__c,
                                            Available_Balance__c,
                                            In_Progress__c,
                                            Reservations__c,
                                            Deposits_Not_Processed__c,
                                            Withdrawals_Not_Processed__c
                                    FROM    eWallet__c
                                    WHERE   CCY__c <> 'XXX'
                                    AND     Account__c = :SeaburyAccountId
                                    ORDER BY CCY__c];

            if(ExistingeWallets.size() != 0)
                Request.FullLogs.Log(string.format('{0} existing eWallet(s).', new string[] {string.valueOf(ExistingeWallets.size())}), 2);
            else
            {
                Request.FullLogs.Log('Warning: No existing eWallet found.', 2, Helper_Log.Color.Red);
                Request.AlertLogs.Log('Warning: No existing eWallet found.', 0, Helper_Log.Color.Red);
                this.IsValid = false;
            }
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new SeaburyDataExtractionException('Loading of existing eWallet(s) failed.', unmanagedException);
        }
    }

    private void loadTransactions()
    {
        try
        {
            Request.FullLogs.Log('2. Loading existing Transaction(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            Map<id, eWallet__c> eWallets = (new Map<Id, eWallet__c>(ExistingeWallets));
            Set<id> eWalletIds = eWallets.keySet();

            ExistingTransactions = [    SELECT  id,
                                                Name,
                                                Invoice_Finance_Deal__c,
                                                Invoice_Allocation__c,
                                                eWallet__c,
                                                Effective_Date__c,
                                                Type__c,
                                                Status__c,
                                                Amount__c,
                                                CCY__c
                                        FROM    Transaction__c
                                        WHERE   CCY__c <> 'XXX'
                                        AND     eWallet__c = :eWalletIds
                                        ORDER BY Effective_Date__c, CCY__c];

            if(ExistingTransactions.size() != 0)
                Request.FullLogs.Log(string.format('{0} existing Transaction(s).', new string[] {string.valueOf(ExistingTransactions.size())}), 2);
            else
            {
                Request.FullLogs.Log('Warning: No existing Transaction found.', 2, Helper_Log.Color.Red);
                Request.AlertLogs.Log('Warning: No existing Transaction found.', 0, Helper_Log.Color.Red);
                this.IsValid = false;
            }
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new SeaburyDataExtractionException('Loading of existing Transaction(s) failed.', unmanagedException);
        }
    }

    private void loadInvoices()
    {
        try
        {
            Request.FullLogs.Log('3. Loading existing Invoice(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            Set<id> invoiceIds = new Set<id>();
            for(Transaction__c currentTransaction : ExistingTransactions)
                if(!invoiceIds.contains(currentTransaction.Invoice_Finance_Deal__c))
                    invoiceIds.add(currentTransaction.Invoice_Finance_Deal__c);

            ExistingInvoices = [    SELECT  id,
                                            Name,
                                            Supplier_Buyer_Map__c,
                                            supplier_invoice_reference_number__c,
                                            Phase__c,
                                            Status__c,
                                            invoice_amount__c,
                                            funded_amount__c,
                                            CCY__c,
                                            Marketplace_link__c,
                                            submitted_date__c,
                                            Invoice_date__c,
                                            Due_Date__c,
                                            advance_send_to_supplier_date__c,
                                            Expected_Payment_Date__c,
                                            Actual_Repayment_Received_Date__c,
                                            Payment_Terms_Days__c,
                                            Early_payment__c,
                                            OVERDUE__c,
                                            first_deal_for_map__c,
                                            Country_of_Origin__c,
                                            Country_of_Destination__c,
                                            cross_border__c,
                                            Goods_or_Services_Category__c,
                                            Goods_Services_description__c
                                    FROM    Invoice_Finance_Deal__c
                                    WHERE   CCY__c <> 'XXX'
                                    AND     id = :invoiceIds
                                    ORDER BY submitted_date__c, CCY__c];

            if(ExistingInvoices.size() != 0)
                Request.FullLogs.Log(string.format('{0} existing Invoice(s).', new string[] {string.valueOf(ExistingInvoices.size())}), 2);
            else
            {
                Request.FullLogs.Log('Warning: No existing Invoice found.', 2, Helper_Log.Color.Red);
                Request.AlertLogs.Log('Warning: No existing Invoice found.', 0, Helper_Log.Color.Red);
                this.IsValid = false;
            }
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new SeaburyDataExtractionException('Loading of existing Invoice(s) failed.', unmanagedException);
        }
    }

    private void loadSupplierBuyerMaps()
    {
        try
        {
            Request.FullLogs.Log('4. Loading existing Supplier Buyer Map(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            Set<id> supplierBuyerMapIds = new Set<id>();
            for(Invoice_Finance_Deal__c currentInvoice : ExistingInvoices)
                if(!supplierBuyerMapIds.contains(currentInvoice.Supplier_Buyer_Map__c))
                    supplierBuyerMapIds.add(currentInvoice.Supplier_Buyer_Map__c);

            ExistingSupplierBuyerMaps = [   SELECT  id,
                                                    Name,
                                                    Name__c,
                                                    Currency__c,
                                                    Supplier__c,
                                                    Buyer__c
                                            FROM    Supplier_Buyer_Map__c
                                            WHERE   Currency__c <> 'XXX'
                                            AND     id = :supplierBuyerMapIds
                                            ORDER BY Currency__c];

            if(ExistingSupplierBuyerMaps.size() != 0)
                Request.FullLogs.Log(string.format('{0} existing Supplier Buyer Map(s).', new string[] {string.valueOf(ExistingSupplierBuyerMaps.size())}), 2);
            else
            {
                Request.FullLogs.Log('Warning: No existing Supplier Buyer Map found.', 2, Helper_Log.Color.Red);
                Request.AlertLogs.Log('Warning: No existing Supplier Buyer Map found.', 0, Helper_Log.Color.Red);
                this.IsValid = false;
            }
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new SeaburyDataExtractionException('Loading of existing Supplier Buyer Map(s) failed.', unmanagedException);
        }
    }

    private void loadAccounts()
    {
        try
        {
            Request.FullLogs.Log('5. Loading existing Account(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            Set<id> accountIds = new Set<id>();
            for(Supplier_Buyer_Map__c currentSupplierBuyerMap : ExistingSupplierBuyerMaps)
            {
                if(!accountIds.contains(currentSupplierBuyerMap.Supplier__c))
                    accountIds.add(currentSupplierBuyerMap.Supplier__c);
                if(!accountIds.contains(currentSupplierBuyerMap.Buyer__c))
                    accountIds.add(currentSupplierBuyerMap.Buyer__c);
            }

            ExistingAccounts = [    SELECT  id,
                                            Name,
                                            Account_Name_for_unique_index__c,
                                            Type,
                                            Sub_type__c,
                                            Company_registration_number__c,
                                            Country_of_Incorporation__c,
                                            Year_of_incorporation__c,
                                            Industry,
                                            head_office_country__c,
                                            Goods_or_Services_Offered__c,
                                            BillingStreet,
                                            BillingPostalCode,
                                            BillingCity,
                                            BillingState,
                                            BillingCountry,
                                            Phone,
                                            Website
                                    FROM    Account
                                    WHERE   id = :accountIds
                                    ORDER BY Name];

            if(ExistingAccounts.size() != 0)
                Request.FullLogs.Log(string.format('{0} existing Account(s).', new string[] {string.valueOf(ExistingAccounts.size())}), 2);
            else
            {
                Request.FullLogs.Log('Warning: No existing Account found.', 2, Helper_Log.Color.Red);
                Request.AlertLogs.Log('Warning: No existing Account found.', 0, Helper_Log.Color.Red);
                this.IsValid = false;
            }
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new SeaburyDataExtractionException('Loading of existing Account(s) failed.', unmanagedException);
        }
    }

    private void createExtraction()
    {
        try
        {
            Request.FullLogs.Log('6. Creating data extraction', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            // Invoices data extraction
            string invSellerID, invSellerName, invBuyerID, invBuyerName, invDocumentType, invInvoiceNumber, invInvoiceDate, invInvoiceDueDate, invCurrency, invAmount, invPurchasedDate, invPurchasedAmount, invDiscountPercentage, invPurchasePaymentRefID, invRepaymentRefID, invRepaymentDate, invRepaymentAmount;
            List<List<string>> invoicesExtract = new List<List<string>> ();
            List<string> invoicesExtractHeaders = new List<string> {'Seller ID',
                                                                    'Seller Name',
                                                                    'Buyer ID',
                                                                    'Buyer Name',
                                                                    'Document Type',
                                                                    'Invoice Number',
                                                                    'Invoice Date',
                                                                    'Invoice Due Date',
                                                                    'Currency',
                                                                    'Amount',
                                                                    'Purchased Date',
                                                                    'Purchased Amount',
                                                                    'Discount Percentage',
                                                                    'Purchase Payment Ref ID',
                                                                    'Repayment Ref ID',
                                                                    'Repayment Date',
                                                                    'Repayment Amount'};
            invoicesExtract.add(invoicesExtractHeaders);
            for(Invoice_Finance_Deal__c currentInvoice : ExistingInvoices)
            {
                // Searches the related supplier and buyer
                Account currentSupplier, currentBuyer;
                for(Supplier_Buyer_Map__c currentSupplierBuyerMap : ExistingSupplierBuyerMaps)
                {
                    if(currentSupplierBuyerMap.id == currentInvoice.Supplier_Buyer_Map__c)
                    {
                        for(Account currentAccount : ExistingAccounts)
                        {
                            if(currentAccount.id == currentSupplierBuyerMap.Supplier__c)
                                currentSupplier = currentAccount;
                            else if(currentAccount.id == currentSupplierBuyerMap.Buyer__c)
                                currentBuyer = currentAccount;

                            if(currentSupplier != null && currentBuyer != null)
                                break;
                        }

                        break;
                    }
                }

                if(currentSupplier == null)
                {
                    Request.FullLogs.Log(string.format('Warning: No existing Supplier found for Suplier Buyer Map {0}.', new string[] {currentInvoice.Supplier_Buyer_Map__c}), 2, Helper_Log.Color.Red);
                    Request.AlertLogs.Log(string.format('Warning: No existing Supplier found for Suplier Buyer Map {0}.', new string[] {currentInvoice.Supplier_Buyer_Map__c}), 0, Helper_Log.Color.Red);
                    this.IsValid = false;
                }
                if(currentBuyer == null)
                {
                    Request.FullLogs.Log(string.format('Warning: No existing Buyer found for Suplier Buyer Map {0}.', new string[] {currentInvoice.Supplier_Buyer_Map__c}), 2, Helper_Log.Color.Red);
                    Request.AlertLogs.Log(string.format('Warning: No existing Buyer found for Suplier Buyer Map {0}.', new string[] {currentInvoice.Supplier_Buyer_Map__c}), 0, Helper_Log.Color.Red);
                    this.IsValid = false;
                }

                // TODO: Handle case of several purchases on the same invoice (auto-sweep + order) => Duplicate transactions for all types
                Transaction__c currentPurchaseTransaction, currentRepaymentTransaction, currentDiscountTransaction;
                for(Transaction__c currentTransaction : ExistingTransactions)
                {
                    if(currentTransaction.Invoice_Finance_Deal__c == currentInvoice.id)
                    {
                        // Searches the purchase Transaction
                        if(currentTransaction.Type__c == '01.Invoice Purchase')
                            currentPurchaseTransaction = currentTransaction;
                        // Searches the repayment Transaction
                        else if(currentTransaction.Type__c == '04.Invoice Capital Repayment')
                            currentRepaymentTransaction = currentTransaction;
                        // Searches the discount Transaction
                        else if(currentTransaction.Type__c == '05.Invoice Discount Amount')
                            currentDiscountTransaction = currentTransaction;
                    }
                    
                    if((currentPurchaseTransaction != null && currentRepaymentTransaction != null && currentDiscountTransaction != null)
                        || (currentPurchaseTransaction != null && currentInvoice.Phase__c == '3:IN PROGRESS'))
                        break;
                }

                if(currentPurchaseTransaction == null)
                {
                    Request.FullLogs.Log(string.format('Warning: No existing Purchase Transaction found for Invoice {0}.', new string[] {currentInvoice.Name}), 2, Helper_Log.Color.Red);
                    Request.AlertLogs.Log(string.format('Warning: No existing Purchase Transaction found for Invoice {0}.', new string[] {currentInvoice.Name}), 0, Helper_Log.Color.Red);
                    this.IsValid = false;
                }
                if(currentRepaymentTransaction == null && currentInvoice.Phase__c != '3:IN PROGRESS')
                {
                    Request.FullLogs.Log(string.format('Warning: No existing Repayment Transaction found for Invoice {0}.', new string[] {currentInvoice.Name}), 2, Helper_Log.Color.Red);
                    Request.AlertLogs.Log(string.format('Warning: No existing Repayment Transaction found for Invoice {0}.', new string[] {currentInvoice.Name}), 0, Helper_Log.Color.Red);
                    this.IsValid = false;
                }
                if(currentDiscountTransaction == null && currentInvoice.Phase__c != '3:IN PROGRESS')
                {
                    Request.FullLogs.Log(string.format('Warning: No existing Discount Transaction found for Invoice {0}.', new string[] {currentInvoice.Name}), 2, Helper_Log.Color.Red);
                    Request.AlertLogs.Log(string.format('Warning: No existing Discount Transaction found for Invoice {0}.', new string[] {currentInvoice.Name}), 0, Helper_Log.Color.Red);
                    this.IsValid = false;
                }

                invSellerID = (currentSupplier != null && currentSupplier.id != null ? string.valueOf(currentSupplier.id).right(13) : '');
                invSellerName = (currentSupplier.Name != null ? capitalizeAllWords(currentSupplier.Name) : '');
                invBuyerID = (currentBuyer != null && currentBuyer.id != null ? string.valueOf(currentBuyer.id).right(13) : '');
                invBuyerName = (currentBuyer.Name != null ? capitalizeAllWords(currentBuyer.Name) : '');
                invDocumentType = 'INV';
                invInvoiceNumber = (currentInvoice.Name != null ? currentInvoice.Name : '');
                invInvoiceDate = (currentInvoice.Invoice_date__c != null ? string.valueOf(currentInvoice.Invoice_date__c) : '');
                invInvoiceDueDate = (currentInvoice.Due_Date__c != null ? string.valueOf(currentInvoice.Due_Date__c) : '');
                invCurrency = (currentInvoice.CCY__c != null ? currentInvoice.CCY__c : '');
                invAmount = (currentInvoice.invoice_amount__c != null ? string.valueOf(currentInvoice.invoice_amount__c) : '');
                invPurchasedDate = (currentPurchaseTransaction != null && currentPurchaseTransaction.Effective_Date__c != null ? string.valueOf(currentPurchaseTransaction.Effective_Date__c) : '');
                invPurchasedAmount = (currentPurchaseTransaction != null && currentPurchaseTransaction.Amount__c != null ? string.valueOf(currentPurchaseTransaction.Amount__c) : '');
                invDiscountPercentage = '';
                invPurchasePaymentRefID = (currentPurchaseTransaction != null && currentPurchaseTransaction.id != null ? string.valueOf(currentPurchaseTransaction.id).right(13) : '');
                invRepaymentRefID = (currentRepaymentTransaction != null && currentRepaymentTransaction.id != null ? string.valueOf(currentRepaymentTransaction.id).right(13) : '');
                invRepaymentDate = (currentRepaymentTransaction != null && currentRepaymentTransaction.Effective_Date__c != null ? string.valueOf(currentRepaymentTransaction.Effective_Date__c) : '');
                invRepaymentAmount = (currentRepaymentTransaction != null && currentRepaymentTransaction.Amount__c != null ? string.valueOf(currentRepaymentTransaction.Amount__c) : '');
                
                List<string> invoicesExtractRow = new List<string> {invSellerID,
                                                                    invSellerName,
                                                                    invBuyerID,
                                                                    invBuyerName,
                                                                    invDocumentType,
                                                                    invInvoiceNumber,
                                                                    invInvoiceDate,
                                                                    invInvoiceDueDate,
                                                                    invCurrency,
                                                                    invAmount,
                                                                    invPurchasedDate,
                                                                    invPurchasedAmount,
                                                                    invDiscountPercentage,
                                                                    invPurchasePaymentRefID,
                                                                    invRepaymentRefID,
                                                                    invRepaymentDate,
                                                                    invRepaymentAmount};
                invoicesExtract.add(invoicesExtractRow);
            }

            // Companies data extraction
            string comLegalName, comCompanyID, comAddressLine1, comAddressLine2, comAddressLine3, comAddressLine4, comAddressLine5, comCity, comCountry, comPostalCode, comState, comWebSite, comPhoneNumber, comBusinessRegistrationNumber, comBusinessRegistrationType;
            List<List<string>> companiesExtract = new List<List<string>> ();
            List<string> companiesExtractHeaders = new List<string> {'Legal Name',
                                                                    'Company ID',
                                                                    'Address Line 1',
                                                                    'Address Line 2',
                                                                    'Address Line 3',
                                                                    'Address Line 4',
                                                                    'Address Line 5',
                                                                    'City',
                                                                    'Country',
                                                                    'Postal Code',
                                                                    'State',
                                                                    'Web Site',
                                                                    'Phone Number',
                                                                    'Business Registration Number',
                                                                    'Business Registration Type'};
            companiesExtract.add(companiesExtractHeaders);
            for(Account currentAccount : ExistingAccounts)
            {
                comLegalName = (currentAccount.Name != null ? capitalizeAllWords(currentAccount.Name) : '');
                comCompanyID = (currentAccount.id != null ? string.valueOf(currentAccount.id).right(13) : '');
                comAddressLine1 = (currentAccount.BillingStreet != null ? capitalizeAllWords(currentAccount.BillingStreet) : '');
                comAddressLine2 = '';
                comAddressLine3 = '';
                comAddressLine4 = '';
                comAddressLine5 = '';
                comCity = (currentAccount.BillingCity != null ? capitalizeAllWords(currentAccount.BillingCity) : '');
                comCountry = (currentAccount.BillingCountry != null ? capitalizeAllWords(currentAccount.BillingCountry) : '');
                comPostalCode = (currentAccount.BillingPostalCode != null ? currentAccount.BillingPostalCode.toUpperCase() : '');
                comState = (currentAccount.BillingState != null ? capitalizeAllWords(currentAccount.BillingState) : '');
                comWebSite = (currentAccount.Website != null ? currentAccount.Website.toLowerCase() : '');
                comPhoneNumber = (currentAccount.Phone != null ? currentAccount.Phone : '');
                comBusinessRegistrationNumber = (currentAccount.Company_registration_number__c != null ? currentAccount.Company_registration_number__c.toUpperCase() : '');
                comBusinessRegistrationType = (currentAccount.Country_of_Incorporation__c != null ? capitalizeAllWords(currentAccount.Country_of_Incorporation__c) : '');

                List<string> companiesExtractRow = new List<string> {comLegalName,
                                                                    comCompanyID,
                                                                    comAddressLine1,
                                                                    comAddressLine2,
                                                                    comAddressLine3,
                                                                    comAddressLine4,
                                                                    comAddressLine5,
                                                                    comCity,
                                                                    comCountry,
                                                                    comPostalCode,
                                                                    comState,
                                                                    comWebSite,
                                                                    comPhoneNumber,
                                                                    comBusinessRegistrationNumber,
                                                                    comBusinessRegistrationType};
                companiesExtract.add(companiesExtractRow);
            }

            Request.FullLogs.Log(invoicesExtract, 'Invoices Data Extraction', true);
            Request.AlertLogs.Log(invoicesExtract, 'Invoices Data Extraction', true);

            Request.FullLogs.Log(companiesExtract, 'Companies Data Extraction', true);
            Request.AlertLogs.Log(companiesExtract, 'Companies Data Extraction', true);

            // TODO: Remove this statement?
            this.IsValid = false;
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new SeaburyDataExtractionException('Creation of data extraction failed.', unmanagedException);
        }
    }

    private string capitalizeAllWords(string text)
    {
        if(text != null && text.length() > 0)
        {
            string updatedText = text.replace('  ', ' ').trim().toLowerCase();

            // For each split characters
            List<string> splitCharacters = new List<string> {' ', '-', '/', '\\\\', '#', ',', ':', '\\(', '\\)'};
            for(string currentCharacter : splitCharacters)
            {
                List<string> words = updatedText.split(currentCharacter);
                string reconstructedText = '';

                // For each words
                for(string word : words)
                {
                    if(reconstructedText.length() > 0)
                        reconstructedText = reconstructedText + currentCharacter + word.capitalize();
                    else
                        reconstructedText = word.capitalize();
                }

                updatedText = reconstructedText;
            }

            return updatedText;
        }
        else
            return text;
    }

    public class SeaburyDataExtractionException extends Exception {}
}