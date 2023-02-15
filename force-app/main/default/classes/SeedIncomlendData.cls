public class SeedIncomlendData implements SandboxPostCopy {
     
     public static ID SeedIncomlendAccounts() {

        Account newAccount;
        id rt;

        newAccount = new Account();
        rt= [SELECT id FROM RecordType WHERE Name='incomlend operations'].get(0).Id;
        
        newAccount.Name = 'Incomlend - Test Fees';
        newAccount.Type = 'Internal';
        newAccount.RecordTypeid = rt;
        newAccount.onboarding_stage__c = '99.Onboarded';
        newAccount.onboarding_next_action_on__c = '*onboarded*';
        newAccount.onboarding_approved__c = true;
        newAccount.suspended__c = false;
        newAccount.has_ewallet__c = true;
        
        insert newAccount;
        
        newAccount = new Account();
        rt= [SELECT id FROM RecordType WHERE Name='incomlend operations'].get(0).Id;
        
        newAccount.Name = 'Incomlend Test Operations';
        newAccount.Type = 'Internal';
        newAccount.RecordTypeid = rt;
        newAccount.onboarding_stage__c = '99.Onboarded';
        newAccount.onboarding_next_action_on__c = '*onboarded*';
        newAccount.onboarding_approved__c = true;
        newAccount.suspended__c = false;
        newAccount.has_ewallet__c = true;
        
        insert newAccount;
   
        newAccount = new Account();
        rt= [SELECT id FROM RecordType WHERE Name='other'].get(0).Id;
        
        newAccount.Name = 'Euler Hermes Test';
        newAccount.Type = 'Partner';
        newAccount.RecordTypeid = rt;
        newAccount.has_ewallet__c = true;
        newAccount.onboarding_stage__c = '99.Onboarded';
        newAccount.suspended__c = false;
        
        insert newAccount;
        
        newAccount = new Account();
        rt= [SELECT id FROM RecordType WHERE Name='Agent - company'].get(0).Id;
        
        newAccount.Name = 'Incomlend - Test Agent';
        newAccount.Type = 'Agent';
        newAccount.RecordTypeid = rt;
        newAccount.onboarding_stage__c = '99.Onboarded';
        newAccount.suspended__c = false;
        newAccount.has_ewallet__c = true;
        
        insert newAccount;
        return newAccount.id;
        
        }

    public static void SeedTestSupplierContact(id agentID, string email) {

        Account newAccount;
        ID rt;
  //      ID rt2;
    //    ID buyerId;
        ID supplierId;

        newAccount = new Account();
        rt= [SELECT id FROM RecordType WHERE Name='Supplier'].get(1).Id;
        
        newAccount.Name = 'Mom & Pop SME';
        newAccount.Type = 'Customer';
        newAccount.sub_Type__c = 'Supplier';
        newAccount.RecordTypeid = rt;
        newAccount.onboarding_stage__c = '99.Onboarded';
        newAccount.agent__C = agentID;
        newAccount.Public_Profile__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
   //     newAccount.onboarding_stage__c = 'Onboarded';
        newAccount.onboarding_next_action_on__c = '*onboarded*';
        newAccount.onboarding_approved__c = true;
        newAccount.suspended__c = false;
        newAccount.has_ewallet__c = true;
        
        insert newAccount;
        supplierId = newAccount.id;

        Contact cont = new Contact();
        cont.FirstName='Mom';
        cont.LastName='Pop SME';
        cont.Accountid= newAccount.id;
        cont.google_username__c = email;
        cont.relationship_to_account__c = 'Personal Account';
        insert cont;

    }
        public static ID createFunderContact(id userId) {
            Contact cont = new Contact();
            cont.FirstName='Incomlend';
            cont.LastName='Funder';
            cont.Accountid= userId;
            cont.google_username__c = 'funder@test.com';
            cont.relationship_to_account__c = 'Personal Account';
            insert cont;
            ID contactId = cont.id;
            return contactId;  
        }
        
        public static ID createSupplierContact(id userId) {
            Contact cont = new Contact();
            cont.FirstName='Incomlend';
            cont.LastName='Supplier';
            cont.Accountid= userId;
            cont.google_username__c = 'Supplier@test.com';
            cont.relationship_to_account__c = 'Personal Account';
            insert cont;
            ID contactId = cont.id;
            return contactId;  
        }
        
        public static ID SeedTestAccounts(id agentID,id marketplace) {

        Account newAccount;
        ID rt;
        ID rt2;
        ID buyerId;
        ID supplierId;

        newAccount = new Account();
        rt= [SELECT id FROM RecordType WHERE Name='Supplier'].get(1).Id;
        
        newAccount.Name = 'Mom & Pop SME Test';
        newAccount.Type = 'Customer';
        newAccount.sub_Type__c = 'Supplier';
        newAccount.RecordTypeid = rt;
        newAccount.onboarding_stage__c = '99.Onboarded';
        newAccount.agent__C = agentID;
        newAccount.Public_Profile__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
        newAccount.onboarding_next_action_on__c = '*onboarded*';
        newAccount.onboarding_approved__c = true;
        newAccount.suspended__c = false;
        newAccount.has_ewallet__c = true;
        
        insert newAccount;
        supplierId = newAccount.id;
        
        SupplierID = newAccount.ID;
        
        newAccount = new Account();
        rt= [SELECT id FROM RecordType WHERE Name='Buyer'].get(0).Id;
        
        newAccount.Name = 'Big Buyer International Test';
        newAccount.Type = 'Buyer';
        newAccount.RecordTypeid= rt;
        newAccount.onboarding_stage__c = '99.Onboarded';
        newAccount.agent__C = agentID;
        newAccount.Public_Profile__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
        newAccount.onboarding_next_action_on__c = '*onboarded*';
        newAccount.onboarding_approved__c = true;
        newAccount.suspended__c = false;
        newAccount.has_ewallet__c = true;
        
        insert newAccount;
        buyerId = newAccount.id;
        
        
        newAccount = new Account();
        rt2= [SELECT id FROM RecordType WHERE Name='Purchaser - individual'].get(0).Id;
        
        newAccount.Name = 'Mr Deep Pockets Test';
        newAccount.Type = 'Customer';
        newAccount.sub_Type__c = 'Supplier';
        newAccount.RecordTypeid = rt2;
        newAccount.onboarding_stage__c = '99.Onboarded';
        newAccount.agent__C = agentID;
        newAccount.onboarding_next_action_on__c = '*onboarded*';
        newAccount.onboarding_approved__c = true;
        newAccount.discount_profit_share_percent__c = 0.15;
        newAccount.suspended__c = false;
        newAccount.has_ewallet__c = true;
        
        insert newAccount;
        
        ID product_id= [SELECT id FROM incomlend_product__c where active__c=true and approved__c = true].get(0).Id;
        
        Supplier_Buyer_Map__c newMap;
        newMap = new Supplier_Buyer_Map__c();
        
        newMap.supplier__c = supplierId;
        newMap.buyer__c = buyerId;
        newmap.marketplace__C = Marketplace;
      //  newmap.Incomlend_product__c = product_id;
        //newmap.Public_Payment_History_Comments__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ';
        newmap.Public_description_of_relationship__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ';
        newmap.Public_Payment_History_Comments__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.';
        newmap.approval_date__c =date.today().addMonths(-1);
        newmap.buyer_supplier_map_approved__c   = true;
        insert newMap;
        
        return supplierId;
        }
        
        
    public static ID SeedTestFunderAccounts(id agentID,id marketplace) {

        Account newAccount;
        ID rt2;
        ID funderId;

        newAccount = new Account();
        rt2= [SELECT id FROM RecordType WHERE Name='Purchaser - individual'].get(0).Id;
        
        newAccount.Name = 'Mr John';
        newAccount.Type = 'Customer';
        newAccount.sub_Type__c = 'Purchaser';
        newAccount.RecordTypeid = rt2;
        newAccount.onboarding_stage__c = '99.Onboarded';
        newAccount.agent__C = [select id from account where name = 'Incomlend - Test Agent'].get(0).id;
        newAccount.onboarding_next_action_on__c = '*onboarded*';
        newAccount.onboarding_approved__c = true;
        newAccount.discount_profit_share_percent__c = 0.15;
        newAccount.suspended__c = false;
        newAccount.has_ewallet__c = true;
        
        insert newAccount;
        funderId = newAccount.id;
        
        Accounting_Period__c ap = new Accounting_Period__c();
        ap.Name = (date.today()).year() + '-' + date.today().month().format().leftpad(2,'0');
              
        ap.Start_Date__c = date.today().addMonths(-1);
        ap.End_Date__c = date.today().addMonths(2);
        insert ap;
        Id apId = ap.Id;
        
        Bank_Account__c ba = new Bank_Account__c();
        ba.Account__c = funderId;
        ba.Beneficiary_Name__c = 'coddle';
        ba.Bank_Account_Number__c = '121215554455';
        ba.Currency__c = 'XXX';
        ba.Purpose__c = 'Bank Account for USD withdrawals1';
        ba.Incomlend_Account__c = 'Customer';
        ba.SWIFT_Code__c = 'SF44545';
        ba.Bank_Name__c = 'HSBC1';
        ba.Address__c = 'HSBC, France';        
        ba.Country__c = 'France';
        ba.estimated_transfer_time__c = 1;
        ba.transfer_cutoff_time__c = '5pm';        

        insert ba;
        id bankAccountId = ba.id;
        
        eWallet__c ewallet = new eWallet__c();
        ewallet.Account__c = funderId;
        ewallet.Bank_Account__c = bankAccountId;
        ewallet.CCY__c = 'XXX';
        ewallet.Marketplace_for_FX__c = [select id from marketplace__C where currency__C = :ewallet.CCY__c ].get(0).id;
        
        insert ewallet;
        id ewalletId = ewallet.id;
        
        newAccount.XXX_eWallet__c  = ewalletId;
        update newAccount;
        
        Transaction__c trans = new Transaction__c ();
            
        Date today  = system.today();
                
        trans.Type__c = '70.Deposit';
        trans.Status__c = 'Confirmed by finance';
        trans.Amount__c = 40000;
        trans.CCY__c = 'XXX';
        trans.Account__c = funderId;
        trans.Effective_Date__c = today;
        trans.accounting_period__c = apId;
        trans.eWallet__c = ewalletId;
        
        insert trans;
        
        return funderId;
    }
        
        
        public static ID seedMarketplace(string CCY, id FXRate)
        {
        marketplace__C newMarketplace;
        newMarketplace = new marketplace__C();
        newMarketplace.Name = CCY;
        newMarketplace.FX_Rate_for_MI__c = FXRate;
        newMarketplace.currency_symbol__c = ccy;
        newMarketplace.minimum_purchase_amount__c = 1000;
        newMarketplace.currency__c = 'XXX';
        
        insert newMarketplace;
        return newMarketplace.ID;
        }
         
        public static ID addFXRate(string fromCCY, decimal rate)
        {
        FX_Rates__c newFXRate;
        newFXRate = new FX_Rates__c();
        
        newFXRate.date__c = date.parse('01/01/2017');    
        newFXRate.from_currency__c = fromCCY    ;
        newFXRate.to_currency__c =  'USD'   ;
        newFXRate.rate__c =   rate  ;
        
        insert newFXRate;
        return newFXRate.id;
        }
        
        public static ID seedProducts()
        {
        
        incomlend_product__c newProduct;
        newProduct = new incomlend_product__c();
        
        Id rt= [SELECT id FROM RecordType WHERE Name='Auction Product'].get(0).Id;
        newProduct.Invoice_Record_Type__c = rt;
        newProduct.Name = 'Vanilla';
        newProduct.Auction_Type__C = 'Fixed Discount Rate';
        newProduct.ccys__C = 'XXX';
        newProduct.active__c = true;
        newProduct.approved__c = true;
        newProduct.launch_date__C =  date.parse('01/01/2017');
        
        ID fxrate;
        ID USDMarketplace;
        
        fxrate = addFXRate('XXX',1);
        USDMarketplace = seedMarketplace('XXX', fxrate);
        
        fxrate = addFXRate('SGD',1);
        seedMarketplace('SGD', fxrate);
        
        fxrate = addFXRate('HKD',7.75);
        seedMarketplace('HKD', fxrate);
        
        newProduct.months_relationship_with_buyer__c = 12;
        newProduct.minimum_funding_pct__c  = 0.6;
        newProduct.maximum_funding_pct__c = 0.9;
        
        insert newProduct;
        return USDMarketplace;
        }
        
        public static ID seedAll()
        {
        ID AgentID;
        AgentID = SeedIncomlendAccounts();
        
        ID USDMarketplace;
        USDMarketplace = SeedProducts();  //will make a fxrate to assign to the product for the MI rate.
        ID supplierID = SeedTestAccounts(AgentID, USDMarketplace);
        return supplierID;
        }
        
    public static void createTransactions(Id userId, string transType) {
        
        Id USDMarketplace = SeedProducts();
        
        Accounting_Period__c ap = new Accounting_Period__c();
        ap.Name = 'Test Accounting Period';
        ap.Start_Date__c = date.today().addMonths(-1);
        ap.End_Date__c = date.today().addMonths(2);
        insert ap;
        Id apId = ap.Id;
        
        Bank_Account__c ba = new Bank_Account__c();
        ba.Account__c = userId;
        ba.Beneficiary_Name__c = 'coddle';
        ba.Bank_Account_Number__c = '121215554455';
        ba.Currency__c = 'XXX';
        ba.Purpose__c = 'Bank Account for USD withdrawals1';
        ba.Incomlend_Account__c = 'Customer';
        ba.SWIFT_Code__c = 'SF44545';
        ba.Bank_Name__c = 'HSBC1';
        ba.Address__c = 'HSBC, France';        
        ba.Country__c = 'France';
        ba.estimated_transfer_time__c = 1;
        ba.transfer_cutoff_time__c = '5pm';        

        insert ba;
        id bankAccountId = ba.id;
        
        eWallet__c ewallet = new eWallet__c();
        ewallet.Account__c = userId;
        ewallet.Bank_Account__c = bankAccountId;
        ewallet.CCY__c = 'XXX';
        ewallet.Marketplace_for_FX__c = USDMarketplace;
        
        insert ewallet;
        id ewalletId = ewallet.id;
        
        Transaction__c trans = new Transaction__c ();
            
        Date today  = system.today();
                
        trans.Type__c = transType;
        trans.Status__c = 'Confirmed by operations';
        trans.Amount__c = 2000;
        trans.CCY__c = 'XXX';
        trans.Account__c = userId;
        trans.Effective_Date__c = today;
        trans.accounting_period__c = apId;
        trans.eWallet__c = ewalletId;
        
        insert trans;
        
    }
        
    public static void seedContactAll(string email)
        {
        ID AgentID;
        AgentID = SeedIncomlendAccounts();
        
        ID USDMarketplace;
        USDMarketplace = SeedProducts();  //will make a fxrate to assign to the product for the MI rate.
        SeedTestSupplierContact(AgentID, email);
        }
        
    public static id makeInvoice(integer numberOfDeals)
        {
        id lastmadeinvoiceid;       
        id product_id;
        id map_id;
        id marketplace_id;
        
        product_id= [SELECT id FROM incomlend_product__c where approved__c=true].get(0).Id;
        marketplace_id = [Select ID from marketplace__c where Currency__c = 'XXX'].get(0).id;        
        map_id    = [SELECT id FROM Supplier_Buyer_Map__c where buyer_supplier_map_approved__c=true].get(0).Id;
        
        lastmadeinvoiceid = makeInvoice(map_id, product_id,'','',numberOfDeals);
        return lastmadeinvoiceid;
        }
        
    public static id makeInvoiceSupplier(integer numberOfDeals, string supplierId)
      {
        id lastmadeinvoiceid;       
        id product_id;
        id map_id;
        id marketplace_id;
        System.debug('supplierId: '+ supplierId);
        
        marketplace_id = [Select ID from marketplace__c where Currency__c = 'XXX'].get(0).id;
        product_id= [SELECT id FROM incomlend_product__c where approved__c=true].get(0).Id;
        map_id    = [SELECT id FROM Supplier_Buyer_Map__c where marketplace__r.Currency__c = 'XXX' and Supplier__r.Id = :supplierId and buyer_supplier_map_approved__c=true ].get(0).Id;
        System.debug('map_id: '+ map_id);
        
        
        lastmadeinvoiceid = makeInvoice(map_id, product_id,'','',numberOfDeals);
        return lastmadeinvoiceid;
      }
      
      public static id makeInvoiceBuyer(integer numberOfDeals, string supplierId)
      {
        id lastmadeinvoiceid;       
        id product_id;
        id map_id;
        id marketplace_id;
        System.debug('supplierId: '+ supplierId);
        
        marketplace_id = [Select ID from marketplace__c where Currency__c = 'XXX'].get(0).id;
        product_id= [SELECT id FROM incomlend_product__c where approved__c=true].get(0).Id;
        map_id    = [SELECT id FROM Supplier_Buyer_Map__c where marketplace__r.Currency__c = 'XXX' and Supplier__r.Id = :supplierId and buyer_supplier_map_approved__c=true ].get(0).Id;
        System.debug('map_id: '+ map_id);
        
        lastmadeinvoiceid = makeInvoice(map_id, product_id,'1:PRE LISTING','pending buyer confirmation',numberOfDeals);
        return lastmadeinvoiceid;
      }
      
      
      public static id makeXXXInvoice(string supplierId)
      {
        id lastmadeinvoiceid;       
        id product_id;
        id map_id;
        id marketplace_id;
        System.debug('supplierId: '+ supplierId);
        
        marketplace_id = [Select ID from marketplace__c where Currency__c = 'XXX'].get(0).id;
        product_id= [SELECT id FROM incomlend_product__c where approved__c=true].get(0).Id;
        map_id    = [SELECT id FROM Supplier_Buyer_Map__c where marketplace__r.Currency__c = 'XXX' and buyer_supplier_map_approved__c=true ].get(0).Id;
        
        String l_phase = '1:PRE LISTING';
        String l_status = 'pending supplier review';
        
        invoice_finance_deal__c newDeal = new invoice_finance_deal__c();
        recordtype RT;
        rt= [SELECT id FROM RecordType WHERE Name='Auction Product'];
        newDeal.recordType = RT;
        newDeal.CCY__c = 'XXX';
        newDeal.LINK_ID__c = 'LINK221';
        newDeal.discount_rate__c = 0.1;
        newDeal.Due_Date__c = date.today().addMonths(3);
        newDeal.has_quality_report__c = 'Yes';
        //newDeal.Incomlend_product__c = product;
        newDeal.invoice_amount__c = 10000;
        newDeal.Invoice_date__c = date.today().addMonths(-1);
        newDeal.Listing_End__c =date.today().addDays(2);
        newDeal.Listing_Start__c = date.today().addDays(-1);
        newDeal.Minimum_requested_amount__c = 9000;
        newDeal.Phase__c = l_phase;
        newDeal.Platform_fee_percentage__c =0.1;
        newDeal.Public_Description__c = 'great invoice buy it buy it now!';
        newDeal.public_validation_notes__c = 'nothing to see here';
        newDeal.requested_amount__c = 9000;
        newDeal.send_supplier_funds_delay__c = 1;
        newDeal.Status__c = l_status;
        newDeal.Supplier_Buyer_Map__c = map_id;
        newDeal.supplier_invoice_reference_number__c = 'INVOICE123';
        newDeal.Country_of_Destination__c = 'Thailand';
        newDeal.Country_of_Origin__c = 'France';
        // newDeal.Goods_or_Services_Category__c = 'Goods  Materials';
        newDeal.Goods_Services_description__c ='Gold Plated Widgets';
        newDeal.Public_Description__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.';
        newDeal.public_validation_notes__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ';
        newDeal.Marketplace_link__c = marketplace_id;
        
        insert newDeal;
        return newDeal.id;
      }
      
      public static void makeAllocation(Id supplierId, Id funderId)
      {
        id lastmadeinvoiceid;       
        id product_id;
        id map_id;
        id marketplace_id;
                
        marketplace_id = [Select ID from marketplace__c where Currency__c = 'XXX'].get(0).id;
        product_id= [SELECT id FROM incomlend_product__c where approved__c=true].get(0).Id;
        map_id    = [SELECT id FROM Supplier_Buyer_Map__c where marketplace__r.Currency__c = 'XXX' and Supplier__r.Id = :supplierId and buyer_supplier_map_approved__c=true ].get(0).Id;
        System.debug('map_id: '+ map_id);
        
        lastmadeinvoiceid = makeInvoice(map_id, product_id,'3:IN PROGRESS','In Progress',1);
        
        Invoice_Allocation__c alloc = new Invoice_Allocation__c ();
            
        Date currentDate  = system.today();
                
        alloc.Invoice__c = lastmadeinvoiceid;
        alloc.Funder__c = funderId;
        alloc.Status__c = 'Confirmed';
        alloc.Funder_Agent_Commission_Amount__c = 10;
        alloc.Allocation_Reservation_date__c = currentDate;
        alloc.amount__c = 1000;
        alloc.CCY__c = 'XXX';        
        
      }
      
      public static id makeBankAccount()
      {
        Account newAccount;
        id rt2;
        id userId;

        userId = SeedIncomlendAccounts();
        
        Bank_Account__c ba = new Bank_Account__c();
        ba.Account__c = userId;
        ba.Beneficiary_Name__c = 'coddle';
        ba.Bank_Account_Number__c = '121215554455';
        ba.Currency__c = 'XXX';
        ba.Purpose__c = 'Bank Account for USD withdrawals';
        ba.Incomlend_Account__c = 'Customer';
        ba.SWIFT_Code__c = 'SF45455';
        ba.Bank_Name__c = 'HSBC';
        ba.Address__c = 'HSBC, France';        
        ba.Country__c = 'France';
        ba.Active__c = true;
        ba.estimated_transfer_time__c = 1;
        ba.transfer_cutoff_time__c = '5pm';        

        insert ba;
        
        return userId;
      } 
      
    public static id makeBankAcccountFunder(id userId)  {
        Bank_Account__c ba = new Bank_Account__c();
        ba.Account__c = userId;
        ba.Beneficiary_Name__c = 'coddle';
        ba.Bank_Account_Number__c = '121215554455';
        ba.Currency__c = 'XXX';
        ba.Purpose__c = 'Bank Account for USD withdrawals';
        ba.Incomlend_Account__c = 'Customer';
        ba.SWIFT_Code__c = 'SF45455';
        ba.Bank_Name__c = 'HSBC, France';        
        ba.Country__c = 'France';
        ba.estimated_transfer_time__c = 1;
        ba.transfer_cutoff_time__c = '5pm';        

        insert ba;
        id bankAccountId = ba.id;
        return bankAccountId;
    }
                
    public static id makeInvoice(id buyerSupplierMap,id product, string p_phase, string p_status, integer numberOfDeals )
        {
        string l_phase;
        string l_status;

        
        if (p_phase == '')
        { l_phase = '1:PRE LISTING';}
         else 
         {l_phase = p_phase;}

        if (p_status == '')
        { l_status = 'pending supplier review';}
         else 
         {l_status = p_status;}
        
        ID marketplace_id = [Select ID from marketplace__c where Currency__c = 'XXX'].get(0).id;
        
        invoice_finance_deal__C newDeal;
        for (Integer i = 0, j = 0; i < numberOfDeals; i++) {
            newDeal = new invoice_finance_deal__C();
            Double rand =  Math.random();
            recordtype RT;
            rt= [SELECT id FROM RecordType WHERE Name='Auction Product'];
            newDeal.recordType = RT;
            newDeal.CCY__c = 'XXX';
            newDeal.LINK_ID__c = 'LINK22'+rand;
            newDeal.discount_rate__c = 0.1;
            newDeal.Due_Date__c = date.today().addMonths(3);
            newDeal.has_quality_report__c = 'Yes';
            //newDeal.Incomlend_product__c = product;
            newDeal.invoice_amount__c = 10000;
            newDeal.Invoice_date__c = date.today().addMonths(-1);
            newDeal.Listing_End__c =date.today().addDays(2);
            newDeal.Listing_Start__c = date.today().addDays(-1);
            newDeal.Minimum_requested_amount__c = 9000;
            newDeal.Phase__c = l_phase;
            newDeal.Platform_fee_percentage__c =0.1;
            newDeal.Public_Description__c = 'great invoice buy it buy it now!';
            newDeal.public_validation_notes__c = 'nothing to see here';
            newDeal.requested_amount__c = 9000;
            newDeal.send_supplier_funds_delay__c = 1;
            newDeal.Status__c = l_status;
            newDeal.Supplier_Buyer_Map__c = buyerSupplierMap;
            newDeal.supplier_invoice_reference_number__c = 'INVOICE123';
            newDeal.Country_of_Destination__c = 'Thailand';
            newDeal.Country_of_Origin__c = 'France';
            // newDeal.Goods_or_Services_Category__c = 'Goods  Materials';
            newDeal.Goods_Services_description__c ='Gold Plated Widgets';
            newDeal.Public_Description__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.';
            newDeal.public_validation_notes__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ';
            newDeal.Marketplace_link__c = marketplace_id;
            insert newDeal;
            }
            
            return newDeal.id;
        }
        
        
        
        
        public void runApexClass(SandboxContext context)
        {
        seedAll();
        }
        
        
        }