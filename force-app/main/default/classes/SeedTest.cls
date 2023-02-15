@isTest
public class SeedTest {

    public static Map<String, Object> resultMap {get; set;}

    public static Map<String, Object> init() {
        return init(null, null, null, null, null);
    }

    public static Map<String, Object> init(String name, String CCY, String special) {
        return init(name, CCY, special, null, null);
    }

    public static Map<String, Object> init(String name, String CCY, String special, Decimal amount, decimal sdr, Map<String, Object> result) {
        if (name == null) name = '';
        if (CCY == null) CCY = 'USD';
        if (special == null) special = '';
        if (amount == null) amount = 1000;
        if (sdr == null) sdr = 0.85;
        // Override 
        special = special.indexOf('017938') != -1 ? special + 'overdue-buffer profitshare'
                : special.indexOf('017804') != -1 ? special + 'overdue-buffer'
                : special.indexOf('018601') != -1 ? special + 'multi-funder listing'
                : special.indexOf('018228') != -1 ? special + 'early'
                : special.indexOf('018228') != -1 ? special + 'early'
                : special.indexOf('018608') != -1 ? special + 'overdue'
                : special.indexOf('018377') != -1 ? special + 'no-deposit'
                : special.indexOf('019123') != -1 ? special + 'overdue'
                : special.indexOf('018898') != -1 ? special + 'multi-funder buyback early' 
                : special;
        amount  = special.indexOf('017938') != -1 ? 7168.90
                : special.indexOf('017804') != -1 ? 492290.4
                : special.indexOf('018601') != -1 ? 464748.90
                : special.indexOf('018228') != -1 ? 121953.60
                : special.indexOf('018608') != -1 ? 10857.40
                : special.indexOf('018377') != -1 ? 141148.34
                : special.indexOf('019123') != -1 ? 12374.00
                : special.indexOf('018898') != -1 ? 945732.32
                : amount;
        sdr     = special.indexOf('017938') != -1 ? 0.51
                : special.indexOf('017804') != -1 ? 0.5417
                : special.indexOf('018601') != -1 ? 0.7083
                : special.indexOf('018228') != -1 ? 0.85
                : special.indexOf('018608') != -1 ? 0.68
                : special.indexOf('018377') != -1 ? 1.0
                : special.indexOf('019123') != -1 ? 0.5708
                : special.indexOf('018898') != -1 ? 0.6083
                : sdr;
                

        if (result == null) result = new Map<String,Object>();
        List<Account> listAccount = new List<Account>();
        List<Bank_Account__c> listBankAccount = new List<Bank_Account__c>();
        List<eWallet__c> listEWallet = new List<eWallet__c>();
        List<eWallet_Trustee__c> listEWalletTrustee = new List<eWallet_Trustee__c>();        
        List<Supplier_Buyer_Map__c> listMap = new List<Supplier_Buyer_Map__c>();   
        List<Map_Product__c> listMapProduct = new List<Map_Product__c>(); 
        List<Invoice_Finance_Deal__c> listInvoice = new List<Invoice_Finance_Deal__c>(); 
        List<Invoice_Allocation__c> listInvoiceAllocation = new List<Invoice_Allocation__c>(); 
        List<Transaction__c> listTransaction = new List<Transaction__c>(); 

        List<Profile> listProfiles = [SELECT ID FROM Profile WHERE Name ='BASE INCOMLEND PROFILE - salesforce'];
        if (listProfiles.isEmpty()) System.assert(false);
        result.put('profile', listProfiles[0]);

        String buyerId = 'Buyer';
        String funderId = 'Funder';
        String supplierId = 'Supplier';
        String agentFunderId = 'AgentFunder';
        String agentSupplierId = 'AgentSupplier';
        if (special.indexOf('agent-funder-360') != -1) {
            funderId = 'Funder360';
            agentFunderId = 'AgentFunder360';    
        }
        if (special.indexOf('tax') != -1) {
            funderId += 'Tax';
            supplierId += 'Tax';
            agentFunderId += 'Tax';
            agentSupplierId += 'Tax';
        }
        if (special.indexOf('in-transit') != -1) {
            supplierId = 'Incomlend Trading Limited';
        }
        
        List<Contact> listContact = new List<Contact>();
        if (special.indexOf('contact') != -1) { // enable bc Email to funder on new allocation activated
            listContact.add(createContact(result, buyerId));
            listContact.add(createContact(result, supplierId));
            listContact.add(createContact(result, funderId));
            insert listContact;
        }
        List<User> listUser = new List<User>();
        if (special.indexOf('user') != -1) {
            listUser.add(createUser(result, buyerId));
            listUser.add(createUser(result, supplierId));
            listUser.add(createUser(result, funderId));
            insert listUser;
        }

        listAccount.add(createAccount(result, 'Atradius', 'Partner'));
        listAccount.add(createAccount(result, 'Incomlend Operations', 'Internal'));
        listAccount.add(createAccount(result, 'Incomlend - Supplier Discount', 'Internal'));
        listAccount.add(createAccount(result, 'Incomlend GST', 'Internal'));
        listAccount.add(createAccount(result, 'Incomlend - fees', 'Internal'));
        listAccount.add(createAccount(result, 'Incomlend Agent Provision', 'Internal'));
        listAccount.add(createAccount(result, 'Incomlend Provision', 'Internal'));
        listAccount.add(createAccount(result, 'Transwap Account', 'Internal'));
        listAccount.add(createAccount(result, 'Volofin Provision', 'Internal'));

        listAccount.add(createAccount(result, buyerId, 'Buyer', special));
        if (special.indexOf('agent-supplier') != -1 || special.indexOf('volofin') != -1) listAccount.add(createAccount(result, agentSupplierId, 'Agent'));
        listAccount.add(createAccount(result, supplierId, 'Supplier', special));
        if (special.indexOf('agent-funder') != -1) listAccount.add(createAccount(result, agentFunderId, 'Agent'));
        listAccount.add(createAccount(result, funderId, 'Purchaser', special));
        if (special.indexOf('with-factory') != -1) listAccount.add(createAccount(result, 'Factory' + name, 'Supplier'));
        if (special.indexOf('in-transit') != -1) {
            listAccount.add(createAccount(result, 'Factory' + name, 'Supplier'));
            listAccount.add(createAccount(result, 'Incomlend In Transit Provision', 'Internal'));
        }
        if (special.indexOf('buyback') != -1 || special.indexOf('partial-fund') != -1 || special.indexOf('multi-funder') != -1) 
                listAccount.add(createAccount(result, funderId+'9', 'Purchaser', special));

        for (Account account : listAccount) {
            System.debug('account detail ' + account.Name);
            // insert account;
        }
        insert listAccount;
        if (special.indexOf('contact') != -1) {
            for (Contact currentContact : listContact) {
                currentContact.AccountId = getId(result, 'account' + currentContact.preferred_name__c);
            }
            update listContact;
        }
        if (special.indexOf('credit-insurance') != -1 || special.indexOf('volofin') != -1) {
            ((Account)result.get('account' + supplierId.replace(' ',''))).Credit_insurance_fee__c = 0.73; // only work with fast field update 
        }
        if (special.indexOf('agent-funder') != -1) 
            ((Account)result.get('account' + funderId.replace(' ',''))).Agent__c = getId(result, 'accountAgent' + funderId.replace(' ',''));
        if (special.indexOf('agent-supplier') != -1 || special.indexOf('volofin') != -1) 
            ((Account)result.get('account' + supplierId.replace(' ',''))).Agent__c = getId(result, 'accountAgent' + supplierId.replace(' ',''));
        
        // update listAccount;
        
        for (Account account : listAccount) {
            // System.debug('bankAccount detail ' + account.Name);
            listBankAccount.add(createBankAccount(result, account.Name));
        }
        insert listBankAccount;

        createMarketPlace(result, CCY);
        Incomlend_product__c incomlendProduct = null;
        if (special.indexOf('in-transit') != -1) {
            String incomlendProductName = 'In Transit - NON Insured - ' + CCY;
            incomlendProduct = createIncomlendProduct(incomlendProductName, CCY);
            result.put('incomlendProduct' + CCY, incomlendProduct);
            insert incomlendProduct;
        }

        Map<Account, eWallet__c> mapAccountWallet = new Map<Account, eWallet__c>();
        for (Account account : listAccount) {
            // System.debug('eWallet detail ' + account.Name + CCY);
            eWallet__c wallet = createEWallet(result, account.Name, CCY);
            mapAccountWallet.put(account, wallet);
            listEWallet.add(wallet);
        }
        insert listEWallet;
        for (Account account : mapAccountWallet.keySet()) {
            if (CCY == 'USD') account.USD_eWallet__c = mapAccountWallet.get(account).Id;
            else if (CCY == 'EUR') account.EUR_eWallet__c = mapAccountWallet.get(account).Id;
            else if (CCY == 'SGD') account.SGD_eWallet__c = mapAccountWallet.get(account).Id;
            else if (CCY == 'GBP') account.GBP_eWallet__c = mapAccountWallet.get(account).Id;
            else if (CCY == 'HKD') account.HKD_eWallet__c = mapAccountWallet.get(account).Id;
            else if (CCY == 'XXX') account.XXX_eWallet__c = mapAccountWallet.get(account).Id;
        }
        // update listAccount;
        for (Account account : listAccount) {
            System.debug('eWallet Trustee detail ' + account.Name + CCY);
            listEWalletTrustee.add(createEWalletTrustee(result, account.Name, CCY));
        }
        insert listEWalletTrustee;
        if (special.indexOf('volofin') != -1) ((Account)result.get('account' + agentSupplierId)).Name = IncomlendPricing_v3.VOLOFIN_AGENT;
        update listAccount;

        Supplier_Buyer_Map__c supplierBuyerMap = createMap(result, name, supplierId, buyerId, CCY, sdr, special);
        listMap.add(supplierBuyerMap);
        if (incomlendProduct != null) supplierBuyerMap.Incomlend_product__c = incomlendProduct.Id;
        if (special.indexOf('in-transit') != -1) supplierBuyerMap.Max_advance_amount_percentage__c = 0.8;
        insert listMap;
        Map_Extension__c Map_Extension = null;
        if (special.indexOf('in-transit') != -1) {
            Map_Extension = createMapExtension(result, name, true);
        } else if (special.indexOf('with-factory') != -1) {
            Map_Extension = createMapExtension(result, name, special.indexOf('upfront') != -1);
        }

        Map_Product__c mapProduct = createMapProduct(result, name, supplierBuyerMap);
        listMapProduct.add(mapProduct);
        insert listMapProduct;

        if (special.indexOf('installment-insurance') != -1) {
            insert createInstalment(result, name, supplierId, 'Insurance');
        } 
        if (special.indexOf('installment-membership') != -1) {
            insert createInstalment(result, name, supplierId, 'Membership');
        }
        if (special.indexOf('installment-maintenance') != -1) {
            insert createInstalment(result, name, supplierId, 'Maintenance Fees');
        }

        if (special.indexOf('in-transit') != -1) amount = 100000;
        if (special.indexOf('partial-fund') != -1) amount = (amount * 0.6 / 0.9).setScale(2);
        Invoice_Finance_Deal__c invoice = createInvoice(result, null, name, CCY, amount, sdr, special);
        listInvoice.add(invoice);
        if (incomlendProduct != null) invoice.Incomlend_product_del__c = incomlendProduct.Id;
        if (special.indexOf('in-transit') != -1) invoice.In_Transit_fee__c = 1000;
        // Date Actual_Repayment_Received_Date = invoice.Actual_Repayment_Received_Date__c;
        // if (special.indexOf('buyback') != -1) invoice.Actual_Repayment_Received_Date__c = null;
        insert listInvoice;
        // if (special.indexOf('buyback') != -1) invoice.Actual_Repayment_Received_Date__c = Actual_Repayment_Received_Date;

        if (result.get('rateSGD') == null) insert createFxRate(result, 'SGD', null, null);
        if (special.indexOf('floating-rate') != -1) createFloatingRate();
        createAccountingPeriod(result);

        // create transaction
        listTransaction.add(createTransaction(result, null, buyerId, CCY, amount, null));
        decimal funded = amount * 0.9;
        if (supplierBuyerMap.Bangladesh_special_case__c != null) funded = amount * 0.95;
        if (special.indexOf('in-transit') != -1) funded = amount * 0.8;
        listTransaction.add(createTransaction(result, null, funderId, CCY, funded, null));
        if (special.indexOf('buyback') != -1 && special.indexOf('buyback-partial') == -1) listTransaction.add(createTransaction(result, null, funderId, CCY, funded * 0.7 / 0.9, null));
        if (special.indexOf('buyback') != -1 || special.indexOf('partial-fund') != -1 || special.indexOf('multi-funder') != -1) 
            listTransaction.add(createTransaction(result, null, funderId+'9', CCY, amount, null));
        // RollupUtility.isNeedRunTrigger = true;
        insert listTransaction;
        // RollupUtility.isNeedRunTrigger = false;
        // unneed with rollup
        update listEWallet;
        update listEWalletTrustee;
        // create transaction end

        Invoice_Allocation__c invAllocation = createInvoiceAllocation(result, null, name, funderId, CCY, funded, special);
        if (special.indexOf('buyback') != -1 || special.indexOf('partial-fund') != -1) invAllocation.amount__c = funded;
        listInvoiceAllocation.add(invAllocation);
        if (special.indexOf('multi-funder') != -1) listInvoiceAllocation.add(createInvoiceAllocation(result, '2', name, funderId+'2', CCY, funded, special + 'invAllocation'+'2'));
        insert listInvoiceAllocation;
        
        if (special.indexOf('listing') != -1) return result;

        if (Map_Extension != null) {
            insert Map_Extension;
            invoice.Map_Extension__c = Map_Extension.Id;
            update invoice;
        }

        // addition transaction 
        // for funded repaid
        List<Transaction__c> listTransactionExtra = updateFundedRepaid(result, name, funderId, supplierId, buyerId, CCY, amount, funded, special, null);
        if (listTransactionExtra.size() > 0) {
            // RollupUtility.isNeedRunTrigger = true;
            insert listTransactionExtra;
            // RollupUtility.isNeedRunTrigger = false;
            // unneed with rollup
            update listEWallet;
            update listEWalletTrustee;
        }
        resultMap = result;
        return result;
    }

    public static Map<String, Object> init(String name, String CCY, String special, Decimal amount, decimal sdr) {
        boolean debug = true;
        if (special != null && debug) System.debug('params ' + special);
        Map<String, Object> result = new Map<String, Object>();
        try {
            return init(name, CCY, special, amount, sdr, result);
        } catch (Exception e) {
            if (debug) {
                for (String key : result.keySet()) {
                    if (key.indexOf('account') == 0) System.debug(key + ' ' + ((Account)result.get(key)).Id + ' ' + ((Account)result.get(key)).Name);
                    if (key.indexOf('wallet') == 0) System.debug(key + ' ' + ((eWallet__c)result.get(key)).Id + ' ' + ((eWallet__c)result.get(key)).Balance__c);
                    if (key.indexOf('eWalletTrustee') == 0) System.debug(key + ' ' + ((eWallet_Trustee__c)result.get(key)).Id + ' ' + ((eWallet_Trustee__c)result.get(key)).Balance__c);
                }    
            }
            throw e;
        }
    }

    public static List<Transaction__c> updateFundedRepaid(Map<String, Object> result, String name, String funderId, String supplierId, String buyerId, String CCY, decimal amount, decimal funded, String special, List<Transaction__c> listTransaction) {
        if (listTransaction == null) listTransaction = new List<Transaction__c>(); 
        if (special.indexOf('funded') != -1 || special.indexOf('repaid') != -1) { // simplified wo 06 07
            listTransaction.add(createTransaction(result, name, funderId, CCY, -funded, '01.Invoice Purchase'));
            listTransaction.add(createTransaction(result, name, supplierId, CCY, funded, '02.Invoice Advance Amount'));
        }
        if (special.indexOf('repaid') != -1) { // simplified wo 05 06
            listTransaction.add(createTransaction(result, name, buyerId, CCY, -amount, '03.Invoice Repayment'));
            listTransaction.add(createTransaction(result, name, funderId, CCY, funded, '04.Invoice Capital Repayment'));
            listTransaction.add(createTransaction(result, name, supplierId, CCY, amount-funded, '08.Invoice Balance Payment'));
        }
        return listTransaction;
    }
    
    public static ID getId(Map<String, Object> result, String name) {
        Object obj = result.get(name);
        if (obj == null) return null;
        if (name.indexOf('profile') == 0) return ((Profile)obj).Id;
        if (name.indexOf('user') == 0) return ((User)obj).Id;
        if (name.indexOf('contact') == 0) return ((Contact)obj).Id;
        if (name.indexOf('account') == 0) return ((Account)obj).Id;
        if (name.indexOf('bankAccount') == 0) return ((Bank_Account__c)obj).Id;
        if (name.indexOf('wallet') == 0) return ((eWallet__c)obj).Id;
        if (name.indexOf('eWalletTrustee') == 0) return ((eWallet_Trustee__c)obj).Id;
        if (name.indexOf('marketplace') == 0) return ((Marketplace__c)obj).Id;
        if (name.indexOf('rate') == 0) return ((FX_Rates__c)obj).Id;
        if (name.indexOf('incomlendProduct') == 0) return ((Incomlend_product__c)obj).Id;
        if (name.indexOf('taxRate') == 0) return ((Tax_Rate__c)obj).Id;
        if (name.indexOf('aPeriod') == 0) return ((Accounting_Period__c)obj).Id;
        if (name.indexOf('mProduct') == 0) return ((Map_Product__c)obj).Id;
        if (name.indexOf('mExtension') == 0) return ((Map_Extension__c)obj).Id;
        if (name.indexOf('map') == 0) return ((Supplier_Buyer_Map__c)obj).Id;
        if (name.indexOf('invoice') == 0) return ((Invoice_Finance_Deal__c)obj).Id;
        if (name.indexOf('invAllocation') == 0) return ((Invoice_Allocation__c)obj).Id;
        return null;
        
    }
    
    public static Account createAccount(Map<String, Object> result, String name, String type) {
        return createAccount(result, name, type, '');
    }

    public static Account createAccount(Map<String, Object> result, String name, String type, String special) {
        if (type == null) throw new GeneralException('invalid type ' + type);
        if (name == null) name = type;
        
        Account account = new Account();
        account.Name = name;
        account.onboarding_approved__c = true;
        account.Address_Shipping_is_Address_Billing__c = false;
        if (type == 'Buyer') {
            account.Credit_Insurance_CCY__c = 'USD';
            account.Credit_Limit_Requested_CCY__c = 'USD';
            account.Credit_limit_insurance_currency__c = 1000000;
            account.Total_CL_Limit_from_Incomlend__c = 1000000;
            // account.RecordTypeId = '01228000000vQE5'; // unneed with fast field update
            if (special.indexOf('credit-insurance') != -1 || special.indexOf('installment-insurance') != -1) account.Insured_by__c = 'Atradius';
        }
        String subtype = 'NA';
        if (new List<String>{'Buyer', 'Supplier', 'Agent', 'Purchaser'}.indexOf(type) != -1) {
            subtype = type;
            if (type == 'Purchaser') type = 'Customer';
            if (type == 'Agent') {
                if (name.indexOf('360') != -1) {
                    account.Agent_Commision_Purchaser_Discount_Fee__c = 0.24;
                    account.Agent_Commision_Purchaser_Type__c = 'Annual Rate (360d/year)';
                } else {
                    account.Agent_Commision_Purchaser_Discount_Fee__c = 25;
                }
                if (special.indexOf('agent-supplier') != -1) {
                    account.Account_Agent_s_Type__c = 'Fixed';
                    account.Value_of_agent_s_fee__c = 3;
                }
            } else {
                if (special.indexOf('contact') != -1) {
                    account.Primary_Contact__c = getId(result, 'contact' + name);
                }
                if (special.indexOf('user') != -1) {
                    account.Sales_Owner__c = getId(result, 'user' + name);
                }        
            }
            if (name.indexOf('Tax') != -1) {
                account.Country_of_Incorporation__c = 'Singapore';
                account.VAT_applicable__c = true;                
            } else {
                account.Country_of_Incorporation__c = 'United States';
            }
            account.Agent__c = getId(result, 'account' + 'Agent' + name.replace(' ',''));
        }
        account.Type = type;
        account.Sub_type__c = subtype;
        account.onboarding_stage__c = '99.Onboarded';
        result.put('account' + name.replace(' ',''), account); 
        return account;    
    }

    public static User createUser(Map<String, Object> result, String name) {
        User user = new User();
        String email = name.replace(' ','') + '@yopmail.com';
        user.Username = email;
        user.FirstName = 'Test';
        user.LastName = name;
        user.Email = email;
        user.TimeZoneSidKey = 'Asia/Singapore';
        user.Alias = name.replace(' ','');
        user.ProfileId = getId(result, 'profile');
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        result.put('user' + name.replace(' ',''), user);
        return user;
    }
    
    public static Contact createContact(Map<String, Object> result, String name) {
        Contact contact = new Contact();
        String Email = name.replace(' ','') + '@yopmail.com';
        contact.Email = Email;
        contact.FirstName = 'Test';
        contact.LastName = name;
        contact.google_username__c = Email;
        contact.preferred_name__c = name.replace(' ','');
        result.put('contact' + name.replace(' ',''), contact);
        return contact;
    }

    public static Bank_Account__c createBankAccount(Map<String, Object> result, String name) {
        Bank_Account__c Bank_Account = new Bank_Account__c();
        Bank_Account.Account__c = getId(result, 'account' + name.replace(' ',''));
        Bank_Account.Bank_Name__c = 'Mel Bank';
        Bank_Account.SWIFT_Code__c = 'Mel123456';
        Bank_Account.Currency__c = 'USD';
        Bank_Account.Country__c = 'Singapore';
        Bank_Account.transfer_cutoff_time__c = '18:00';
        Bank_Account.Bank_Account_Number__c = '0123456789';
        Bank_Account.Beneficiary_Name__c = 'Some Company Pte Ltd';
        result.put('bankAccount' + name.replace(' ',''), Bank_Account); 
        return Bank_Account;
    }
    
    public static eWallet__c createEWallet(Map<String, Object> result, String name, String CCY) {
        eWallet__c eWallet = new eWallet__c();
        eWallet.Account__c = getId(result, 'account' + name.replace(' ',''));
        eWallet.CCY__c = CCY;
        eWallet.Marketplace_for_FX__c = getId(result, 'marketplace' + CCY);
        eWallet.Bank_Account__c = getId(result, 'bankAccount' + name.replace(' ',''));
        eWallet.Balance__c = 0; 
        result.put('wallet' + CCY + name.replace(' ',''), eWallet); 
        return eWallet;
    }

    public static eWallet_Trustee__c createEWalletTrustee(Map<String, Object> result, String name, String CCY) {
        eWallet_Trustee__c eWallet_Trustee = new eWallet_Trustee__c();
        eWallet_Trustee.Main_eWallet__c = getId(result, 'wallet' + CCY + name.replace(' ',''));
        eWallet_Trustee.Account__c = getId(result, 'account' + name.replace(' ',''));
        eWallet_Trustee.CCY__c = CCY;
        eWallet_Trustee.Marketplace_for_FX__c = getId(result, 'marketplace' + CCY);
        eWallet_Trustee.Balance__c = 0; // unneed with rollup
        // eWallet_Trustee.Trustee__c = 'Amicorp Trust'; // unneed with fast field update
        result.put('eWalletTrustee' + CCY + name.replace(' ',''), eWallet_Trustee);
        return eWallet_Trustee;
    }

    public static void createAccountingPeriod(Map<String, Object> result) {
        Tax_Rate__c taxRate = new Tax_Rate__c();
        taxRate.Rate__c = 7.00;
        taxRate.Country__c = 'Singapore';
        insert taxRate;
        result.put('taxRate', taxRate); 

        Accounting_Period__c Accounting_Period = new Accounting_Period__c();
        Accounting_Period.Name = (System.today()).year() + '-' + System.today().month().format().leftpad(2,'0');              
        Accounting_Period.Start_Date__c = System.today().addMonths(-12);
        Accounting_Period.End_Date__c = System.today().addMonths(12);
        insert Accounting_Period;    
        result.put('aPeriod', Accounting_Period); 

    }

    public static Dynamic_SDR__c createFloatingRate() {
        Dynamic_SDR__c dynamicSdr = new Dynamic_SDR__c();
        dynamicSdr.Type__c = 'SOFR';
        dynamicSdr.SOFR_Rate_Fixing__c = 2;
        insert dynamicSdr;
        return dynamicSdr;
    }

    public static FX_Rates__c createFxRate(Map<String, Object> result, String CCY, decimal fxrate, Date day) {
        String name = 'rate' + CCY;
        if (day == null) day = Date.newInstance(2000, 01, 01);
        else name += String.valueOf(day);
        // FX rate
        FX_Rates__c rate = new FX_Rates__c();
        if (fxrate == null) fxrate = 1;
        rate.rate__c = fxrate;
        rate.from_currency__c = CCY;
        rate.date__c = day;
        rate.to_currency__c = 'USD';        
        result.put(name, rate);
        return rate; 
    }

    private static Incomlend_product__c createIncomlendProduct(String name, String CCY) {
        Incomlend_product__c incomlend_product = new Incomlend_product__c();
        incomlend_product.Name = name == null ? 'Standard Insured - ' + CCY : name;
        incomlend_product.launch_date__c = Date.newInstance(2000, 01, 01);
        incomlend_product.CCYs__c = CCY;
        incomlend_product.months_relationship_with_buyer__c = 12;
        incomlend_product.Auction_Type__c = 'Fixed Discount Rate';
        incomlend_product.approved__c = true;
        incomlend_product.insured__c = true;
        return incomlend_product;
    }

    public static void createMarketPlace(Map<String, Object> result, String strCCY) {
        createMarketPlace(result, strCCY, null);
    }

    public static void createMarketPlace(Map<String, Object> result, String strCCY, String name) {
        List<FX_Rates__c> listRate = new List<FX_Rates__c>();
        for (String CCY : strCCY.split(';')) {
            if (result.containsKey('rate' + CCY)) continue;
            listRate.add(createFxRate(result, CCY, null, null));
        }
        insert listRate;

        List<Marketplace__c> listMarketPlace = new List<Marketplace__c>();
        List<Incomlend_product__c> listIncomlendProduct = new List<Incomlend_product__c>();
        for (String CCY : strCCY.split(';')) {
            if (result.containsKey('marketplace' + CCY + (name == null ? '' : name.replace(' ','')))) continue;
            // Market Place
            Marketplace__c marketplace = new Marketplace__c();
            marketplace.Name = CCY + (name == null ? ' Insured' : ' ' + name);
            marketplace.Currency__c = CCY;
            marketplace.FX_Rate_for_MI__c = getId(result, 'rate' + CCY);
            marketplace.currency_symbol__c = CCY;
            marketplace.minimum_purchase_amount__c = 1;
            listMarketPlace.add(marketplace);
            result.put('marketplace' + CCY + (name == null ? '' : name.replace(' ','')), marketplace);

            // Incomlend Product
            if (result.containsKey('incomlendProduct' + CCY)) continue;
            Incomlend_product__c incomlend_product = createIncomlendProduct(null, CCY);
            listIncomlendProduct.add(incomlend_product);
            result.put('incomlendProduct' + CCY, incomlend_product);
        }
        insert listMarketPlace;
        insert listIncomlendProduct;

    }
    
    public static Supplier_Buyer_Map__c createMap(Map<String, Object> result, String name, String accountSupplierId, String accountBuyerId, String CCY, Decimal sdr, String special) {
        Supplier_Buyer_Map__c Supplier_Buyer_Map = new Supplier_Buyer_Map__c();

        Supplier_Buyer_Map.Buyer__c = getId(result, 'account' + accountBuyerId.replace(' ',''));
        Supplier_Buyer_Map.Supplier__c = getId(result, 'account' + accountSupplierId.replace(' ',''));
        Supplier_Buyer_Map.Incomlend_product__c = getId(result, 'incomlendProduct' + CCY);
        Supplier_Buyer_Map.Marketplace__c = getId(result, 'marketplace' + CCY);
        Supplier_Buyer_Map.buyer_supplier_map_approved__c = true;
        Supplier_Buyer_Map.map_onboarding_stage__c = '90.Onboarded';
        Supplier_Buyer_Map.Bangladesh_special_case__c = 
            special.indexOf('with-factory') != -1 ? 'With factory' :
            special.indexOf('with-deposit') != -1 ? 'With deposit' : 
            special.indexOf('no-deposit') != -1 ? 'No deposit' : 
            null;
        Supplier_Buyer_Map.Inprogress_invoice_amount_usd_equiv__c = 0;
        Supplier_Buyer_Map.Buyer_Sales_Zone__c = 10;
        Supplier_Buyer_Map.Supplier_Zone__c = 5;
        Supplier_Buyer_Map.Ops_Owner__c = null;
        Supplier_Buyer_Map.accepted_incoterms__c = 'EXW;FOB;CFR;CIF';
        Supplier_Buyer_Map.CL_Limit_requested_for_this_Map__c = 1000000;
        Supplier_Buyer_Map.CL_Incomlend_for_this_Map__c = 1000000;
        Supplier_Buyer_Map.Geographical_zone__c = 'Zone 1';
        Supplier_Buyer_Map.Overdue_Additional_Discount_rate__c = 0;
        Supplier_Buyer_Map.Funder_Discount_Rate__c = 0; 
        Supplier_Buyer_Map.Minimum_Spread__c = 0;

        Supplier_Buyer_Map.Insurance_Premium_Logic__c = null; // 'Supplier Insurance';
        if (special.indexOf('credit-insurance') != -1 || special.indexOf('volofin') != -1) {
            Supplier_Buyer_Map.Insurance_Premium_Logic__c = 'Invoice based';
            Supplier_Buyer_Map.Insurance_cost_for_Supplier__c = 0.73;
        }
        if (special.indexOf('installment-insurance') != -1) Supplier_Buyer_Map.Insurance_Premium_Logic__c = 'Instalments';

        if (special.indexOf('floating-rate') != -1) Supplier_Buyer_Map.Floating_Rate_Margin__c = 10;
        Supplier_Buyer_Map.Supplier_Discount_Rate__c = sdr;
        if (special.indexOf('platform-fee') != -1) { Supplier_Buyer_Map.Value_of_agent_s_fee__c = 3; Supplier_Buyer_Map.Agent_s_fee_type__c = 'Platform fee (%)'; }// legacy
        
        // unneed with fast field update
        // Supplier_Buyer_Map.RecordTypeId = '0120I000000OcqIQAS';
        // if (special.indexOf('agent-supplier') != -1 || special.indexOf('volofin') != -1) Supplier_Buyer_Map.Account_Agent__c = getId(result, 'accountAgent' + accountSupplierId.replace(' ','')); 
        // unneed with GlobalTriggerHandler
        Supplier_Buyer_Map.Trustee__c = 'Amicorp Trust'; 
        if (special.indexOf('agent-supplier') != -1) {
            Supplier_Buyer_Map.Value_of_agent_s_fee__c = 3;
            Supplier_Buyer_Map.Agent_s_fee_type__c = 'Part of the supplier discount rate (%)';
        }

        result.put('map' + name.replace(' ',''), Supplier_Buyer_Map);

        return Supplier_Buyer_Map;
    }

    public static Map_Extension__c createMapExtension(Map<String, Object> result, String mapId, boolean isUpfront) {
        Map_Extension__c Map_Extension = new Map_Extension__c();
        Map_Extension.Account__c = getId(result, 'accountFactory' + mapId.replace(' ',''));
        Map_Extension.Supplier_Buyer_Map__c = getId(result, 'map' + mapId.replace(' ','')); 
        Map_Extension.Map_extension_type__c = 'Factoring / Reverse Factoring';
        Map_Extension.Funding_Upfront_fees__c = false;
        if (isUpfront) Map_Extension.Funding_Upfront_fees__c = true;
        result.put('mExtension' + mapId.replace(' ',''), Map_Extension);
        return Map_Extension;
    }

    public static Map_Product__c createMapProduct(Map<String, Object> result, String name, Supplier_Buyer_Map__c Supplier_Buyer_Map) {
        Map_Product__c Map_Product = new Map_Product__c();
        Map_Product.Supplier_Buyer_map__c = Supplier_Buyer_Map.Id;
        Map_Product.Custom_Product__c = Supplier_Buyer_Map.Incomlend_product__c;
        result.put('mProduct' + name.replace(' ',''), Map_Product);
        return Map_Product;
    }
    
    public static invoice_finance_deal__c createInvoice(Map<String, Object> result, String name, String mapId, String CCY, Decimal amount, String special) {
        return createInvoice(result, name, mapId, CCY, amount, null, special);
    }

    public static invoice_finance_deal__c createInvoice(Map<String, Object> result, String name, String mapId, String CCY, Decimal amount, Decimal sdr, String special) {
        invoice_finance_deal__c invoice = new invoice_finance_deal__c();
        if (name == null) name = mapId;
        invoice.supplier_invoice_reference_number__c = 'INV-' + name;
        if (amount == null) amount = 1000;
        if (sdr == null) sdr = 0.85;
        if (special == null) special = '';

        integer expectedFinancePeriod = 90;
        if (special.indexOf('past-cap') != -1) expectedFinancePeriod = 120;
        if (special.indexOf('volofin') != -1) expectedFinancePeriod = 45;
        integer actualFinancingPeriod = expectedFinancePeriod;
        if (special.indexOf('early') != -1) actualFinancingPeriod -= special.indexOf('past-cap') != -1 ? 24 : 12;
        if (special.indexOf('overdue') != -1) actualFinancingPeriod += special.indexOf('past-cap') != -1 ? 66 : 18;
        if (special.indexOf('with-deposit') != -1 && special.indexOf('overdue') != -1) actualFinancingPeriod += 126;
        
        // Override
        expectedFinancePeriod 
                = special.indexOf('017938') != -1 ? 22
                : special.indexOf('017804') != -1 ? 55
                : special.indexOf('018601') != -1 ? 118
                : special.indexOf('018228') != -1 ? 89
                : special.indexOf('018608') != -1 ? 35
                : special.indexOf('018377') != -1 ? 52
                : special.indexOf('019123') != -1 ? 50
                : special.indexOf('018898') != -1 ? 117
                : expectedFinancePeriod;
        actualFinancingPeriod 
                = special.indexOf('017938') != -1 ? 30
                : special.indexOf('017804') != -1 ? 61
                : special.indexOf('018601') != -1 ? 118
                : special.indexOf('018228') != -1 ? 66
                : special.indexOf('018608') != -1 ? 39
                : special.indexOf('018377') != -1 ? 64
                : special.indexOf('019123') != -1 ? 60
                : special.indexOf('018898') != -1 ? 116
                : actualFinancingPeriod;
        
        Date dueDate = System.today().addDays(expectedFinancePeriod - 1);
        
        invoice.Invoice_date__c = System.today();
        invoice.Due_Date__c = dueDate;
        invoice.Listing_Start__c = System.today();
        invoice.Listing_End__c = dueDate;
        invoice.advance_send_to_supplier_date__c = System.today();
        if (special.indexOf('passthrough') != -1) {
            Incomlend_product__c incomlend_product = (Incomlend_product__c)result.get('incomlendProductPassthrough');
            if (incomlend_product == null) {
                incomlend_product = createIncomlendProduct('Passthrough Invoice - ' + CCY, CCY);
                insert incomlend_product;
                result.put('incomlendProductPassthrough', incomlend_product);
            } 
            invoice.Incomlend_product_del__c = incomlend_product.Id;
        }

        invoice.Country_of_Origin__c = 'China';
        invoice.Country_of_Destination__c = 'Australia';
        invoice.Incoterm__c = 'FOB';
        invoice.Goods_Services_description__c = 'test';
        invoice.Tolerance_overdue_days__c = 0;
        invoice.CCY__c = CCY;
        invoice.Incomlend_product_del__c = getId(result, 'incomlendProduct' + CCY);
        invoice.Notice_of_Assignment_signed__c = true;
        invoice.Total_Supplier_Discount__c = sdr;

        invoice.Phase__c = '2:ON MARKETPLACE';
        invoice.Status__c = 'On marketplace';
        if (special.indexOf('funded') != -1) {
            invoice.Phase__c = '3:IN PROGRESS';
            invoice.Status__c = 'In progress';    
        } else if (special.indexOf('repaid') != -1) {
            invoice.Phase__c = '4:CLOSED';
            invoice.Status__c = 'Paid';    
        }

        invoice.Real_Face_Value__c = amount;
        invoice.invoice_amount__c = amount;
        invoice.requested_amount__c = amount * 0.9;
        if (special.indexOf('no-deposit') != -1 || special.indexOf('with-deposit') != -1 || special.indexOf('with-factory') != -1)
            invoice.requested_amount__c = amount * 0.95;
        invoice.Actual_Repayment_Amount__c = amount;
        if (special.indexOf('in-transit') != -1) {
            decimal requested_amount = amount * 0.8;
            invoice.requested_amount__c = requested_amount;
            invoice.Actual_Repayment_Amount__c = requested_amount;
        }

        invoice.Supplier_Buyer_Map__c = getId(result, 'map' + mapId.replace(' ',''));
        invoice.Marketplace_link__c =  getId(result, 'marketplace' + CCY);

        if (special.indexOf('with-factory') != -1) {
            invoice.Map_Extension__c = getId(result, 'mExtension' + name);
            invoice.Factory_Amount__c = amount * 0.94;
        }
        invoice.Actual_Repayment_Received_Date__c = System.today().addDays(actualFinancingPeriod - 1);
        if (special.indexOf('funded') != -1) invoice.Actual_Repayment_Received_Date__c = null;
        if (special.indexOf('overdue') != -1) invoice.Overdue_sSupplier_discount_rate__c = sdr;
        if (special.indexOf('overdue-buffer') != -1) invoice.Tolerance_overdue_days__c = 999;
        if (special.indexOf('platform-fee') != -1) invoice.Specific_additional_Platform_fee_amount__c = 12; // legacy


        // unneed with GlobalTriggerHandler
        invoice.Trustee__c = 'Amicorp Trust'; 
        invoice.Incomlend_product_del__c = getId(result, 'incomlendProduct' + CCY);
        if (special.indexOf('credit-insurance') != -1 || special.indexOf('volofin') != -1) invoice.credit_insurance_fee_percentage__c = 0.73; 
        if (special.indexOf('credit-insurance') != -1 || special.indexOf('installment-insurance') != -1) invoice.Insured_by__c = 'Atradius'; 
        if (special.indexOf('volofin') != -1) invoice.Insured_by__c = 'Volofin'; 

        result.put('invoice' + name.replace(' ',''), invoice);
        return invoice;
    }
        
    public static Invoice_Allocation__c createInvoiceAllocation(Map<String, Object> result, String name, String invoiceId, String funderId, String CCY, decimal amount, String special) {
        
        Invoice_Allocation__c allocation = new Invoice_Allocation__c();
        if (name == null) name = invoiceId;
        if (amount == null) amount = ((Invoice_Finance_Deal__c)result.get('invoice')).requested_amount__c;
        allocation.Applied_Funder_Discount_Profit_Share_Pct__c = 0.00;
        if (special.indexOf('profitshare') != -1) 
            allocation.Applied_Funder_Discount_Profit_Share_Pct__c = 10;
        
        allocation.notes__c = funderId;
        allocation.Funder__c = getId(result, 'account' + funderId.replace(' ',''));
        allocation.amount__c = amount;
        allocation.Invoice__c = getId(result, 'invoice' + invoiceId.replace(' ',''));
        allocation.Status__c = 'Reservation';
        if (special.indexOf('funded') != -1) 
            allocation.Status__c = 'Confirmed';
        if (special.indexOf('repaid') != -1) 
            allocation.Status__c = 'Repaid invoice deal closed';
        if (special.indexOf('prepayment') != -1) {
            allocation.Funder_prepayment__c = 'Net EFDA -15days';
        }
        allocation.Allocation_Reservation_date__c = System.today();
        allocation.CCY__c = CCY;
        allocation.Applied_MPR__c = 0.5;
        // Override
        if (special.indexOf('multi-funder') != -1 || special.indexOf('buyback') != -1 || special.indexOf('partial-fund') != -1) {
            allocation.amount__c
                = special.indexOf('018601') != -1 ? 368274.01 
                : special.indexOf('018898') != -1 ? 800000
                : special.indexOf('partial-fund') != -1 ? (amount * 0.6 / 0.9).setScale(3)
                : (amount * 0.7 / 0.9).setScale(3);
            if (special.indexOf('invAllocation'+'9') != -1) allocation.amount__c 
                = special.indexOf('018898') != -1 ? 301159.09
                : amount - allocation.amount__c;
        } 
        allocation.Applied_MPR__c 
                = special.indexOf('017938') != -1 ? 0.47
                : special.indexOf('017804') != -1 ? 0.3833
                : special.indexOf('018601') != -1 && !result.containsKey('invAllocation') ? 0.5167
                : special.indexOf('018601') != -1 ? 0.5
                : special.indexOf('018228') != -1 ? 0.625
                : special.indexOf('018608') != -1 ? 0.51
                : special.indexOf('018377') != -1 ? 0.5
                : special.indexOf('019123') != -1 ? 0.47
                : special.indexOf('018898') != -1 ? 0.42
                : allocation.Applied_MPR__c;
        allocation.Applied_Funder_Discount_Profit_Share_Pct__c 
                = special.indexOf('017938') != -1 ? 12.5
                : special.indexOf('019123') != -1 ? 10
                : allocation.Applied_Funder_Discount_Profit_Share_Pct__c;

        result.put('invAllocation' + name.replace(' ',''), allocation);
        // System.debug('soql ' + limits.getQueries() + ' out of ' + limits.getLimitQueries());
        
        // unneed with fast field update
        // allocation.eWallet__c = getId(result, 'wallet' + CCY + funderId.replace(' ', ''));  
        // allocation.eWallet_Trustee__c = getId(result, 'eWalletTrustee' + CCY + funderId.replace(' ', ''));  
        
        return allocation;
    }
        
    public static Transaction__c createTransaction(Map<String, Object> result, String name, String account, String CCY, Decimal amount) {
        if (CCY == null) CCY = 'USD';
        return createTransaction(result, name, account, CCY, amount, null);
    }

    public static Transaction__c createTransaction(Map<String, Object> result, String name, String account, String CCY, Decimal amount, String type) {
        Transaction__c trn = new Transaction__c();
        trn.Status__c = 'Confirmed by operations';
        String invoiceName = null;
        if (type == null) type = '70.Deposit';
        else if (type.indexOf('0') == 0) invoiceName = name;
        trn.Type__c = type;
        trn.CCY__c = CCY;
        trn.isArchived__c = false;
        trn.Account__c = getId(result, 'account' + account.replace(' ', ''));
        trn.eWallet__c = getId(result, 'wallet' + CCY + account.replace(' ', ''));
        trn.eWallet_Trustee__c = getId(result, 'eWalletTrustee' + CCY + account.replace(' ', ''));
        trn.Accounting_Period__c = getId(result, 'aPeriod');
        if (amount == null) amount = 1000000;
        trn.Amount__c = amount;
        trn.Effective_Date__c = System.today();
        if (invoiceName != null) trn.Invoice_Finance_Deal__c = getId(result, 'invoice' + invoiceName.replace(' ', ''));
        for (integer count = 1; count <= 65535; count++) {
            if (!result.containsKey('transaction' + count)) {
                result.put('transaction' + count, trn);
                break;
            }
        }
        // unneed with rollup
        ((eWallet__c)result.get('wallet' + CCY + account.replace(' ', ''))).Balance__c += amount;
        ((eWallet_Trustee__c)result.get('eWalletTrustee' + CCY + account.replace(' ', ''))).Balance__c += amount;

        System.debug('transaction detail ' + account + ' ' + trn.amount__c + ' ' + trn.Type__c);
        return trn;
    }

    public static Instalment_insurance_fee__c createInstalment(Map<String, Object> result, String name, String supplierId, String type) {
        Instalment_insurance_fee__c Instalment_insurance_fee = new Instalment_insurance_fee__c();
        Instalment_insurance_fee.Supplier_buyer_map_instalment__c = getId(result, 'map' + name.replace(' ',''));
        Instalment_insurance_fee.Account_Supplier__c = getId(result, 'account' + supplierId);
        Instalment_insurance_fee.Fee_Type__c = type;
        Instalment_insurance_fee.Amount_Instalment__c = 100;
        Instalment_insurance_fee.Due_Date__c = System.today();
        Instalment_insurance_fee.Installment_Term_Months__c = '2';
        Instalment_insurance_fee.Status_Instalment__c = 'Pending';
        result.put('installment' + type.replace(' ','') + name.replace(' ',''), Instalment_insurance_fee);
        return Instalment_insurance_fee;
    }

    public static Date addUpdateAllocation(Map<String, Object> result, String special) {
        List<Invoice_Allocation__c> listInvoiceAllocation = new List<Invoice_Allocation__c>();
        Set<Id> setId = new Set<Id>();
        setId.add(getId(result, 'invAllocation'));
        if (special.indexOf('018898') != -1) setId.add(getId(result, 'invAllocation2'));
        setId.remove(null);

        integer addUpdateAllocationFinancingPeriod 
                = special.indexOf('018898') != -1 ? 20
                : 6;
        Date addUpdateAllocationDate = null;
        if (special.indexOf('buyback') != -1) {
            addUpdateAllocationDate = System.today().addDays(addUpdateAllocationFinancingPeriod);
            for (Id str : setId) {
                Invoice_Allocation__c buybackAllocation = new Invoice_Allocation__c();
                buybackAllocation.Id = str;
                buybackAllocation.Status__c = 'Buyback';
                buybackAllocation.Buybacked_Date__c = addUpdateAllocationDate;    
                listInvoiceAllocation.add(buybackAllocation);
            }    
        }
        Invoice_Finance_Deal__c invoice = (Invoice_Finance_Deal__c)result.get('invoice');
        decimal funded = invoice.requested_amount__c;

        if (special.indexOf('partial-fund') != -1) {
            Invoice_Finance_Deal__c temp = new Invoice_Finance_Deal__c();
            temp.Id = invoice.Id;
            temp.Real_Face_Value__c = (invoice.Real_Face_Value__c / (0.6 / 0.9)).setScale(3);
            temp.requested_amount__c = (invoice.requested_amount__c / (0.6 / 0.9)).setScale(3);
            // temp.invoice_amount__c = (invoice.invoice_amount__c / (0.6 / 0.9)).setScale(3); // unneed with fast field update
            funded = temp.requested_amount__c;
            update temp;
        }

        String funderId = ((Invoice_Allocation__c)result.get('invAllocation')).notes__c;
        String CCY = invoice.CCY__c;
        Invoice_Allocation__c currentAllocation = createInvoiceAllocation(result, '9', '', funderId+'9', CCY, funded, special + 'invAllocation'+'9');
        if (special.indexOf('buyback') != -1 && special.indexOf('buyback-partial') == -1) {
            Invoice_Allocation__c temp = (Invoice_Allocation__c)result.get('invAllocation');
            if (currentAllocation.amount__c < temp.amount__c) {
                temp = temp.clone(false, true, false, false);
                // copyAllocation.Buybacked_Date__c = null;
                // copyAllocation.Status__c = 'Reservation';
                temp.amount__c = temp.amount__c - currentAllocation.amount__c;
                listInvoiceAllocation.add(temp);
            }
        }
        System.debug('funder new allocation ' + Pattern.compile('(.{200})').matcher(JSON.serialize(currentAllocation)).replaceAll('$1\n'));
        listInvoiceAllocation.add(currentAllocation);
        Id str = getId(result, 'account' + funderId+'9');
        system.debug('ewallet balance ' + funded + ' ' + currentAllocation.amount__c + ' ' + [SELECT Name, USD_Available_eWallet__c, USD_eWallet_Balance__c, USD_eWallet__r.Reservations__c, USD_eWallet__r.Withdrawals_Not_Processed__c FROM Account WHERE Id = :str]);
        upsert listInvoiceAllocation;
        return addUpdateAllocationDate;
    }

    @isTest
    private static void TestDoGet() 
    {
        Map<String, Object> result = init();
        Test.startTest();
        System.assert(true);
        Test.stopTest();

    }

    public static configuration__c createConfiguration(String key, String value) {
        configuration__c configuration = new configuration__c();
        configuration.Name = key;
        configuration.value__c = value;
        return configuration;
    }

    public static void initConfiguration() {
        List<configuration__c> listConfigurations = new List<configuration__c>();
        
        // Notification Configuration start
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Notification_AlertsSubject', 'Pricing v3 - An error occured during the process'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Notification_AlertsRecipients', 'Mel@yopmail.com'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Notification_AlertsOnErrorOnly', 'true'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Notification_LogsSubject', 'Pricing v3 - An invoice has been processed'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Notification_LogsRecipients', 'Mel@yopmail.com'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Notification_LogsOnErrorOnly', 'false'));
        
        // Notification Configuration end
        
        // Behaviour Configuration start
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_IsSimulation', 'false'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_FailAtValidation', 'true'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_FailAtNegativeeWallets', 'false'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_FailAtRelatedTransactions', 'false'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_FailAtIncomlendBalance', 'true'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_ApplyEarlyPayment', 'true'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_ApplyOverduePayment', 'true'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_CapEarlyPayment', '15'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_CapOverduePayment', '60'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_WebServiceCallout_Endpoint', 'https://staging.api-gateway.incomlend.com/salesforce-notify'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_WebServiceCallout_ApiKey', 'api-key'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_InsuranceCompanies1', 'Atradius=Atradius;Volofin=Volofin Provision'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_InsuranceCompanies2', 'A=A;B=B'));
        listConfigurations.add(createConfiguration('IncomlendPricing_v3_Behaviour_InsuranceCompanies3', 'C=C'));
        // Behaviour Configuration end
        
        Insert listConfigurations;
    }
    
    public static Invoice_Finance_Deal__c getInvoice(String invoiceId) {
        List<Invoice_Finance_Deal__c> listInvoice;
        listInvoice = Database.query(IncomlendPricing_v3.INVOICE_SELECT_STR + ' FROM  invoice_finance_deal__c WHERE Id = :invoiceId');
        return listInvoice.isEmpty() ? null : listInvoice[0];
    }

    public static List<Invoice_Allocation__c> getInvoiceAllocation(String invoiceId) {
        List<Invoice_Allocation__c> listInvoiceAllocation;
        listInvoiceAllocation = Database.query(IncomlendPricing_v3.INVOICE_ALLOCATION_SELECT_STR + ' FROM  Invoice_Allocation__c WHERE Invoice__c = :invoiceId');
        return listInvoiceAllocation;
    }

}