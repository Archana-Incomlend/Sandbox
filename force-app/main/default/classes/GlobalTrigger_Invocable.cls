@RestResource(urlMapping='/v9/GlobalTrigger/*')
global class GlobalTrigger_Invocable implements Schedulable {

    public static String INVOICE_SELECT_STR = 'SELECT Id, Name, CCY__c, Supplier_Buyer_Map__c, Actual_Repayment_Amount__c, Actual_Repayment_Received_Date__c, platform_fee_fixed__c, Phase__c, Status__c, Id_Buyer__c, Id_Supplier__c, Trustee__c FROM Invoice_Finance_Deal__c ';
    public static String EWALLETTRUSTEE_SELECT_STR = 'SELECT Id, Account__c, Account__r.Name, Main_eWallet__c, Main_eWallet__r.Name FROM eWallet_Trustee__c '; // WHERE (Account__c IN :listTest OR Name IN :listStr) AND CCY__c = :ccy AND Trustee__c = :trustee
    public static Map<String, ID> INTERNAL_ACCOUNT = new Map<String, Id>();
    public static String ICL_OPS = 'Incomlend Operations';
    public static String ICL_FEE = 'Incomlend - fees';
    public static String ICL_ISD = 'Incomlend - Supplier Discount';

    @InvocableMethod(label = 'Run Global Trigger Invocable')
    public static void runModule(List<GlobalTriggerInvocableRequest> requests) {
        for (GlobalTriggerInvocableRequest request : requests) {
            try {
                System.debug('Request ' + request);
                if (request.module == 'CreditLimitController') {
                    if (request.submodule == null || (request.id1 == null && String.isBlank(request.str1))) 
                        throw new GeneralException('Operation not supported input invalid');
                    String idStr = !String.isBlank(request.str1) ? request.str1 : request.id1 != null ? '' + request.id1 : '';
                    if (request.submodule == 'get') CreditLimitController.main(idStr);
                    if (request.submodule == 'put') CreditLimitController.execute(idStr);
                } else if (request.module == 'ListViewController') {
                    if (request.submodule == null || request.str1 == null)
                        throw new GeneralException('Operation not supported input invalid');
                    if (request.submodule == 'DownloadAttachment') ListViewController.downloadAttachment(new Helper_Log(), request.str1, null);
                } else if (request.module == 'IntermediateFix') {
                    if (request.submodule == null) throw new GeneralException('Operation not supported input invalid');
                    RestIntermediateDeploymentFix_v9.runMain(request.submodule, request.str1, request.date1, request.date2, request.has1, request.has2);
                } else if (request.module == 'FasanaraController') {
                    // String idStr = !String.isBlank(request.str1) ? request.str1 : request.id1 != null ? '' + request.id1 : '';
                    // if (idStr != '') FasanaraController.mainFuture(idStr); else FasanaraController.main();
                    try {
                        FasanaraController.main();
                    } catch (Exception ex) {
                    }
                    try {
                        FasanaraController.main(FasanaraController.CLO_1);
                    } catch (Exception ex) {
                    }
                } else if (request.module == 'TargetFinance') {
                    if (request.submodule == null || request.str1 == null)
                        throw new GeneralException('Operation not supported input invalid');
                    if (request.submodule == 'New') CalculateTargetFinanceController.updateNewTargetFinance(null, request.str1);
                } else {
                    System.debug('Operation not supported ' + request);    
                }
            } catch (Exception e) {
                Helper_Log Logs = new Helper_Log(); Logs.log(e); System.debug(Logs.PlainLog);
                System.debug(e);
            }
        }
    }
        
    public static void createNextAccountingPeriod() {
       
        List<Accounting_Period__c> listAccountingPeriod = 
            [ SELECT Id FROM Accounting_Period__c ORDER BY CreatedDate DESC LIMIT 1];
        if (listAccountingPeriod.size() == 0) return;
        Accounting_Period__c accountingPeriod = listAccountingPeriod[0];
        
        for (integer i = 0; i < 3; i++) { // max 3 level
            listAccountingPeriod = [ SELECT Id FROM Accounting_Period__c WHERE Previous_Accounting_Period__c =: accountingPeriod.Id];
            if (listAccountingPeriod.size() == 0) break;
            if (i == 3) throw new GeneralException('Limit break, cannot find latest A/P to duplicate from');
            if (listAccountingPeriod.size() > 1) throw new GeneralException('A/P ' + accountingPeriod.Id + ' has 2 others linked to it as Previous A/P');
            accountingPeriod = listAccountingPeriod[0];    
        }
        
        accountingPeriod = [ SELECT Id, Name, Status__c, Start_Date__c, End_Date__c FROM Accounting_Period__c WHERE Id = :accountingPeriod.Id LIMIT 1];
        Id objId = accountingPeriod.Id;
        String objName = accountingPeriod.Name;
        Date startDate = accountingPeriod.Start_Date__c;
        Date endDate;
        String str;

        if (Pattern.compile('\\d\\d\\d\\d\\-\\d\\d').matcher(objName).matches()) {
            startDate = startDate.addMonths(1);
            endDate = startDate.addMonths(1).addDays(-1); // add another month
            if (startDate <= accountingPeriod.End_Date__c) startDate = accountingPeriod.End_Date__c.addDays(1);
            if (endDate <= accountingPeriod.End_Date__c) throw new GeneralException('Pattern detected as month but data integrity cannot be formed ' + objName);
            str = startDate.year() + '-' + (startDate.month() < 10 ? '0' : '') + startDate.month();
        } else if (Pattern.compile('\\d\\d\\d\\d\\-Q\\d').matcher(objName).matches()) {
            startDate = startDate.addMonths(3);
            endDate = startDate.addMonths(3).addDays(-1); // add another month
            if (startDate <= accountingPeriod.End_Date__c) startDate = accountingPeriod.End_Date__c.addDays(1);
            if (endDate <= accountingPeriod.End_Date__c) throw new GeneralException('Pattern detected as quarter but data integrity cannot be formed ' + objName);
            str = startDate.year() + '-Q' + (Math.Round(startDate.month()/3) + 1);
        } else {
            throw new GeneralException('Pattern cannot be detected ' + objName);
        }
    
        accountingPeriod = accountingPeriod.clone(false, true, false, false);
        accountingPeriod.Name = str;
        accountingPeriod.Status__c = 'Open';
        accountingPeriod.Previous_Accounting_Period__c = objId;
        accountingPeriod.Start_Date__c = startDate;
        accountingPeriod.End_Date__c = endDate;
        insert accountingPeriod;
    }
    
    public void execute(SchedulableContext SC)
    {
        try {
            createNextAccountingPeriod();
    } catch (Exception ex) {
            System.debug(ex);
            GlobalTriggerHandler.OutError(ex.getMessage(), new Helper_Log());
        }  
    }

    @HttpPut
    global static void doPut() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        res.statusCode = 200;
        String p_accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
        if (p_accountId == 'CreateNextAccountingPeriod') createNextAccountingPeriod();
    }

    public static void init() {
        if (INTERNAL_ACCOUNT.isEmpty()) {
            ICL_OPS = 'Incomlend Operations';
            ICL_FEE = 'Incomlend - fees';
            ICL_ISD = 'Incomlend - Supplier Discount';
            INTERNAL_ACCOUNT.put(ICL_OPS, '0012800000pjW40AAE');
            INTERNAL_ACCOUNT.put(ICL_FEE, '0012800000sJlJvAAK');
            INTERNAL_ACCOUNT.put(ICL_ISD, '0010I00001i4NWzQAM');
        }
    }

    public static List<Transaction__c> createDoubleTransaction(Id fromAccountId, Id toAccountId, Decimal amount, Date effectiveDate, Id accountingPeriodId, String type, Invoice_Finance_Deal__c invoice, Id allocationId, Map<String, eWallet_Trustee__c> mapObj) {
        List<Transaction__c> listTransaction = new List<Transaction__c>();
        if (!mapObj.containsKey(fromAccountId)) throw new GeneralException('Insufficient data for From Account Id ' + fromAccountId);
        if (!mapObj.containsKey(toAccountId)) throw new GeneralException('Insufficient data for To Account Id ' + toAccountId);
        Transaction__c trn;
        eWallet_Trustee__c eWalletTrustee;
        eWalletTrustee = mapObj.get(fromAccountId);
        trn = CreateTransaction(fromAccountId, eWalletTrustee.Main_eWallet__c, eWalletTrustee.Id, -amount, effectiveDate, accountingPeriodId, type, invoice, allocationId, null);
        listTransaction.add(trn);
        eWalletTrustee = mapObj.get(toAccountId);
        trn = CreateTransaction(toAccountId, eWalletTrustee.Main_eWallet__c, eWalletTrustee.Id, amount, effectiveDate, accountingPeriodId, type, invoice, allocationId, null);
        listTransaction.add(trn);
        return listTransaction;
    }
    
    public static Transaction__c CreateTransaction(Id accountId, Id eWalletId, Id eWalletTrusteeId, Decimal amount, Date effectiveDate, Id accountingPeriodId, String type, Invoice_Finance_Deal__c invoice, Id allocationId, Map<String, eWallet_Trustee__c> mapObj) 
    {
        return CreateTransaction(accountId, eWalletId, eWalletTrusteeId, amount, effectiveDate, accountingPeriodId, type, invoice.Trustee__c, invoice.CCY__c, invoice.Id, allocationId, mapObj);
    }

    public static Transaction__c CreateTransaction(Id accountId, Id eWalletId, Id eWalletTrusteeId, Decimal amount, Date effectiveDate, Id accountingPeriodId, String type, String trustee, String ccy, Id invoiceId, Id allocationId, Map<String, eWallet_Trustee__c> mapObj) 
    {
        Transaction__c newTransaction = new Transaction__c();
        if (accountId == null) throw new GeneralException('accountId is null');
        newTransaction.Account__c = accountId;
        if (amount == null) throw new GeneralException('amount is null');
        if (eWalletId == null && mapObj != null) eWalletId = mapObj.get(accountId).Main_eWallet__c;
        if (eWalletId == null) throw new GeneralException('eWalletId is null');
        newTransaction.eWallet__c = eWalletId;
        if (eWalletTrusteeId == null && mapObj != null) eWalletTrusteeId = mapObj.get(accountId).Id;
        newTransaction.eWallet_Trustee__c = eWalletTrusteeId;
        newTransaction.Amount__c = amount;
        if (effectiveDate == null) effectiveDate = System.today();
        newTransaction.Effective_Date__c = effectiveDate;
        if (accountingPeriodId == null) accountingPeriodId = Accounting_Period.lookup(effectiveDate);
        newTransaction.Accounting_period__c = accountingPeriodId;
        newTransaction.Status__c = 'Confirmed by operations';
        if (type == null) throw new GeneralException('type is null');
        newTransaction.Type__c = type;
        newTransaction.Trustee__c = trustee == null ? 'Amicorp Trust' : trustee; 
        newTransaction.CCY__c = ccy == null ? 'USD' : ccy;
        newTransaction.Invoice_Finance_Deal__c = invoiceId;
        newTransaction.Invoice_Allocation__c = allocationId;
        return newTransaction;
    }
    
    public static void updateRelatedTransaction(List<Transaction__c> listTransaction) {
        Transaction__c currentTransaction = null;
        for (Transaction__c trn : listTransaction) {
            if (currentTransaction == null) {
                currentTransaction = trn;
            } else {
                trn.Related_Transaction__c = currentTransaction.Id;
                currentTransaction.Related_Transaction__c = trn.Id;
                currentTransaction = null;
            }
        }
    }

    public static void log(Helper_Log Logs, String str) {
        System.debug(str);
        if (Logs != null) Logs.log(str, 2, Helper_Log.Color.Black);
    }
    
    public static String toString(Object obj, Map<String, eWallet_Trustee__c> mapObj, String invoiceName) {
        if (obj instanceof Transaction__c) {
            Transaction__c trn = (Transaction__c)obj;
            eWallet_Trustee__c eWalletTrustee = mapObj != null ? mapObj.get(trn.Account__c) : null;
            String str = '';
            if (eWalletTrustee != null) {
                try { str += ' ' + eWalletTrustee.Account__r.Name; } catch (Exception e) { } 
                try { str += ' ' + eWalletTrustee.Main_eWallet__r.Name; } catch (Exception e) { }
            } else {
                str += ' ' + trn.eWallet__c;
                str += ' ' + trn.Account__c;
            }
            str += ' ' + trn.Type__c;
            str += ' ' + trn.CCY__c;
            str += ' ' + trn.Amount__c;
            str += ' ' + trn.Effective_Date__c;
            if (invoiceName != null) str += ' ' + invoiceName != null ? invoiceName: trn.Invoice_Finance_Deal__c; 
            str += ' ' + trn.Status__c;
            return str;
        }
        return String.valueOf(obj);
    }
    
    public class GlobalTriggerInvocableRequest {
        @InvocableVariable(required=true)
        public String module = null;

        @InvocableVariable(required=false)
        public String submodule = null;

        @InvocableVariable(required=false)
        public String str1 = null;

        @InvocableVariable(required=false)
        public String str2 = null;

        @InvocableVariable(required=false)
        public String str3 = null;

        @InvocableVariable(required=false)
        public ID id1 = null;

        @InvocableVariable(required=false)
        public ID id2 = null;

        @InvocableVariable(required=false)
        public Date date1 = null;

        @InvocableVariable(required=false)
        public Date date2 = null;

        @InvocableVariable(required=false)
        public Boolean has1 = false;

        @InvocableVariable(required=false)
        public Boolean has2 = false;

    }
}