public class CalculateFXContractController {

    public static boolean needRunTrigger = true;
    public static boolean IsNeedRunTrigger
    {
      public get  // to enable trigger during test set it to null
      {
        return Test.isRunningTest() ? needRunTrigger == null : needRunTrigger == true;
      }
      public set
      {
          if (value) needRunTrigger = Test.isRunningTest() ? null : true;
          else needRunTrigger = false;
      }
    }

    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    @TestVisible
    Set<string> leftvalues = new Set<string>();
    @TestVisible
    Set<string> rightvalues = new Set<string>();
    public String FX_Contract_Name {get;set;}
    public String CCY {get;set;}
    public boolean isSimulation {get;set;}
    public Date minDate {get;set;}
    public Date maxDate {get;set;}
    public FX_Contract__c fxContract {get;set;}
    public String errorTransaction {get;set;}
    public String accounts{get;set;}
    public String invoices{get;set;}
    private Map<Id,String> mapAllFXContract = new Map<Id,String>();
    private Map<Id,Fx_Contract__c> fxContractMap;
    private static String INVOICE_PURCHASE = '01.Invoice Purchase';
    private String transactionTypeForCalculate = '('
        + '\'04.Invoice Capital Repayment\','
        + '\'05.Invoice Discount Amount\','
        + '\'054.Invoice Discount Amount Overdue\')';
    public List<String> transactionTypeToCheck = new List<String>{'70.Deposit','80.Withdrawal','99.Adjustment'};
    public String result {get;set;}
    public List<String> resultList {get;set;}
    public Map<String, List<ResultDetail>> resultDetails {get;set;} 
    public Map<String, Integer> resultCountMap{get;set;}
    public List<ResultDetail> detailResults {get;set;} 

    private List<Fx_Contract__c> fxContractList = new List<Fx_Contract__c>();
    public Helper_Log Logs { get; set; }

    private integer indexContract;
    private List<Transaction__c> insertTransaction;
    private List<Transaction__c> updateTransaction;
    private Map<ID,Transaction__c> transactionMap;
    private Map<ID,List<Transaction__c>> relatedTrancheTransactionsMap; 
    private List<Invoice_Allocation__c> updateInvoiceAllocations;
    
    public Class ResultDetail {

        public ResultDetail(String fxContractName, String transactionName, String invoiceName, String status)
        {
            this.fxContractName = fxContractName;
            this.transactionName = transactionName;
            this.invoiceName = invoiceName;
            this.status = status;
        }

        public ResultDetail(String fxContractName, String transactionName, String invoiceName, String amount, String status)
        {
            this.fxContractName = fxContractName;
            this.transactionName = transactionName;
            this.invoiceName = invoiceName;
            this.amount = amount;
            this.status = status;
        }

        public String fxContractName {get;set;}
        public String transactionName {get;set;}
        public String invoiceName {get;set;}
        public String amount {get;set;}
        public String status {get;set;}

    }
    
    public CalculateFXContractController(String invoices, Date minDate, String CCY, Boolean isSimulation){
        if (!isNeedRunTrigger) return;
        if (CCY == null && !String.isBlank(invoices)) {
            String invoiceId = invoices.split(';')[0];
            CCY = [SELECT Id, CCY__c FROM Transaction__c WHERE Invoice_Finance_Deal__c =: invoiceId AND CCY__c != 'USD' LIMIT 1].CCY__c;
            if (CCY == null) 
                throw new GeneralException('Cannot find invoices ' + invoices);
        }
        this.invoices = invoices;
        this.fxContract = new FX_Contract__c();
        this.fxContract.CCY_Target__c = CCY;
        init();
        if (minDate != null) this.minDate = minDate;
        if (isSimulation != null) this.isSimulation = isSimulation;
    }

    public CalculateFXContractController(ApexPages.StandardController stdController){
        this.fxContract = (FX_Contract__c)stdController.getRecord();
        errorTransaction = '';
        leftselected = new List<String>();
        rightselected = new List<String>();
        
        this.fxContract = [SELECT ID, Name, Amount__c, CCY_Target__c,Remain_amount__c FROM FX_Contract__c WHERE Id =: this.fxContract.Id];
        init();
        if (String.isBlank(accounts)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please update value of "Account For FX Contract" configuration!'));
            return;
        }
    }
        
    private void init() {
        accounts = config.getConfig('Tranche_Account_For_Fx_Contract');
        if (accounts != null) accounts = accounts.replaceAll(';', '\n');

        this.Logs = new Helper_Log();
        FX_Contract_Name = this.fxContract.Name;
        CCY = this.fxContract.CCY_Target__c;
        List<FX_Contract__c> fxContracts = [SELECT ID, Name, CCY_Target__c,Amount__c, Remain_amount__c, Tranche_Name__c, Origination_Rate__c, Status__c
                                            FROM FX_Contract__c
                                            WHERE CCY_Target__c =: this.fxContract.CCY_Target__c
                                            ORDER BY Tranche_Number__c];

        for(FX_Contract__c fxContract:fxContracts){
            String name = fxContract.Name + ' ' + fxContract.Tranche_Name__c + ' (Amount ' + fxContract.Amount__c + ', remain ' +  + fxContract.Remain_amount__c + ')';
            mapAllFXContract.put(fxContract.Id, name);
            if(fxContract.Id == this.fxContract.Id || (this.fxContract.Id == null && fxContract.Status__c != 'Closed')) {
                rightvalues.add(name);
                fxContractList.add(fxContract);
            } else{
                if (fxContract.Status__c == 'Closed') continue;
                leftvalues.add(name);
            }
        }
        // Get all target FX_Contract__c
        this.fxContractMap = new Map<Id, FX_Contract__c>(fxContracts);
        fxContractMap.put(null, new Fx_Contract__c());
        this.detailResults = new List<ResultDetail>();
        
        isSimulation = true;
        minDate = Date.valueOf('2021-07-01');
    }
    
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
            for(ID fxContractId: mapAllFXContract.keySet()){
                if(mapAllFXContract.get(fxContractId) == s){
                    fxContractList.add(fxContractMap.get(fxContractId));
                    break;
                }
            }
        }
        return null;
    }
    
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
            for(ID fxContractId: mapAllFXContract.keySet()){
                if(mapAllFXContract.get(fxContractId) == s){
                    Integer index = fxContractList.indexOf(fxContractMap.get(fxContractId));
                    if (index != -1) fxContractList.remove(index);
                    break;
                }
            }
        }
        return null;
    }
    
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
    
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    public void close(){
        errorTransaction = 'OK';
    }
    
    private void log(String str) {
        System.debug(str);
        this.Logs.Log(str, 2, Helper_Log.Color.Grey);
    }

    private List<Transaction__c> retrieveTransactionToUpdate(boolean unlink) {
        System.debug('fxContractList ' + fxContractList.size());
        boolean isCalledFromVfs = this.fxContract.Id == null;
        if(rightvalues.isEmpty() || fxContractList.size() == 0){
            if (!isCalledFromVfs) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please choose FX Contract to calculate!'));
            return null;
        }
        if(minDate == null){
            if (!isCalledFromVfs) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please input Min date !'));
            return null;
        }

        // Prepare Account
        if (accounts == null) accounts = '';
        String accountSearch = '';
        if (!String.isBlank(accounts)) {
            List<String> tempAccount = accounts.split('\n');
            accountSearch += '(';
            for(String tempAcc: tempAccount){
                accountSearch += '\'' + tempAcc + '\',';
            }
            accountSearch = accountSearch.removeEnd(',') + ')';    
        }
        
        // Prepare Invoice
        if (invoices == null) invoices = '';
        String invoiceSearch = '';
        if (!String.isBlank(invoices)) {
            List<String> tempInvoice = invoices.split(';');
            invoiceSearch += '(';
            for(String tempAcc: tempInvoice){
                invoiceSearch += '\'' + tempAcc + '\',';
            }
            invoiceSearch = invoiceSearch.removeEnd(',') + ')';    
        }
        
        Map<Id, Fx_Contract__c> fxcMap = new Map<Id, Fx_Contract__c>(fxContractList);
        List<Id> fxcIdList = new List<Id>(fxcMap.keySet());
        // Prepare Query String
        String queryString = 'SELECT ID, Name,'
            + ' Account__c, Type__c, Status__c, Amount__c, notes__c, Effective_Date__c, CCY__c, DebitCredit__c, Invoice_Finance_Deal__r.Name, Invoice_Allocation__r.Name, '
            + ' Invoice_Finance_Deal__c, Invoice_Allocation__c, Accounting_Period__c, eWallet_Trustee__c, eWallet__c, Trustee_Approved__c, '
            + ' FX_Contract__c, Tranche_amount__c, Tranche_amount_USD__c, Tranche_Name__c, Tranche_amount_percentage__c, Related_Tranche_Transaction__c '
            + ' FROM Transaction__c'
            + ' WHERE Account__r.Name IN ' + accountSearch
            + (String.isBlank(invoices) ? '' : ' AND Invoice_Finance_Deal__c IN ' + invoiceSearch)
            + ' AND CCY__c = \'' + this.fxContract.CCY_Target__c + '\'' 
            + ' AND Effective_Date__c >= : minDate'
            + ' AND (Type__c = \'' + INVOICE_PURCHASE + '\'' + ' OR Type__c IN ' + transactionTypeForCalculate + ')'
            + ' AND Amount__c != 0 AND Status__c IN (\'Confirmed by Finance\', \'Confirmed by Operations\')'
           ; 

        if(maxDate != null){
            queryString += ' AND Effective_Date__c <= : maxDate';
        }
        if (!unlink) queryString += ' AND FX_Contract__c = null';
        if (unlink) queryString += ' AND FX_Contract__c IN :fxcIdList';

        queryString += ' ORDER BY Effective_Date__c ASC, CreatedDate ASC';
        
        system.debug('queryString:' + Pattern.compile('(.{200})').matcher(queryString).replaceAll('$1\n'));
        // Execute Query
        List<Transaction__c> targetTransactions = database.query(queryString);
        System.debug('No of transactions to update ' + targetTransactions.size());
        detailResults.clear();
        transactionMap = new Map<Id, Transaction__c>(targetTransactions);
        relatedTrancheTransactionsMap = new Map<ID,List<Transaction__c>>();
        insertTransaction = new List<Transaction__c>();
        updateTransaction = new List<Transaction__c>();
        updateInvoiceAllocations = new List<Invoice_Allocation__c>();
        return targetTransactions;
    }

    public void execute(){
        if (!isNeedRunTrigger) return;
        log('Params invoices ' + invoices + ' minDate ' + minDate + ' CCY ' + CCY + ' isSimulation ' + isSimulation);
        List<Transaction__c> targetTransactions = retrieveTransactionToUpdate(false);
        if (targetTransactions == null) return;

        // Added tranche detail to invoice allocation
        Map<Id, Invoice_Allocation__c> mapInvoiceAllocation = new Map<Id, Invoice_Allocation__c>();
        // Get all existing fx contract of same invoice
        Map<Id, Transaction__c> mapInvAlloWithInvPurchaseTranx = new Map<Id, Transaction__c>();
        for (Transaction__c target : targetTransactions) {
            mapInvAlloWithInvPurchaseTranx.put(target.Invoice_Finance_Deal__c, null);
            mapInvAlloWithInvPurchaseTranx.put(target.Invoice_Allocation__c, null);
            mapInvoiceAllocation.put(target.Invoice_Allocation__c, null);
        }
        
        Map<Id, Transaction__c> prevInvPurchase = new Map<Id, Transaction__c> (
            [SELECT Id, Invoice_Finance_Deal__c, Invoice_Allocation__c, FX_Contract__c, Tranche_amount__c, Amount__c, Invoice_Finance_Deal__r.Name
             FROM Transaction__c
             WHERE (Invoice_Finance_Deal__c IN :mapInvAlloWithInvPurchaseTranx.keySet() 
                    OR Invoice_Allocation__c IN :mapInvAlloWithInvPurchaseTranx.keySet()) 
             AND FX_Contract__c != null AND Type__c = :INVOICE_PURCHASE]);

        for (Transaction__c previousTrn : prevInvPurchase.values()) {
            if (previousTrn.Invoice_Finance_Deal__c != null && mapInvAlloWithInvPurchaseTranx.get(previousTrn.Invoice_Finance_Deal__c) == null)
                mapInvAlloWithInvPurchaseTranx.put(previousTrn.Invoice_Finance_Deal__c, previousTrn);
            if (previousTrn.Invoice_Allocation__c != null && mapInvAlloWithInvPurchaseTranx.get(previousTrn.Invoice_Allocation__c) == null)
                mapInvAlloWithInvPurchaseTranx.put(previousTrn.Invoice_Allocation__c, previousTrn);
        }

        updateRelatedTrancheTransactionsMap(relatedTrancheTransactionsMap, prevInvPurchase.keySet());

        if (mapInvoiceAllocation != null) {
            mapInvoiceAllocation = new Map<Id, Invoice_Allocation__c>([
                SELECT Id, Name, Fx_Contract__c FROM Invoice_Allocation__c WHERE Id IN :mapInvoiceAllocation.keySet()
            ]);
        }

        // Re calculate Remain Amount with current Related Transaction
        TransactionTriggerHandler.recalculateRemainAmount(fxContractList, CCY);
        
        // Re calculate Remain Amount with 01.Invoice Purchase Fx Contract Transaction and Update this Transaction with new FX Contract
        for(Integer indexTran = 0; indexTran < targetTransactions.size(); indexTran ++){
            indexContract = 0;
            Transaction__c target = targetTransactions.get(indexTran);

            // Update this Transaction with FX Contract of same invoice if not '01.Invoice Purchase'
            if (target.Type__c != INVOICE_PURCHASE) {
                Transaction__c previousTransaction = null;
                if (target.Invoice_Allocation__c != null && mapInvAlloWithInvPurchaseTranx.get(target.Invoice_Allocation__c) != null)
                    previousTransaction = mapInvAlloWithInvPurchaseTranx.get(target.Invoice_Allocation__c);
                else if (target.Invoice_Finance_Deal__c != null && mapInvAlloWithInvPurchaseTranx.get(target.Invoice_Finance_Deal__c) != null)
                    previousTransaction = mapInvAlloWithInvPurchaseTranx.get(target.Invoice_Finance_Deal__c);
                else {
                    detailResults.add(new ResultDetail('',
                                                       target.Name, target.Invoice_Finance_Deal__r.Name, 
                                                       target.DebitCredit__c + ' ' + target.Amount__c,
                                                       'Nok Tranche not found for transaction of same invoice with type Invoice Purchase'));
                    log(fxContractMap.get(target.Fx_Contract__c).Tranche_Name__c + ' ' + toString(target) + ' ' + 'Not found 01 Purchase Transaction');
                    continue;
                }
                target.Fx_Contract__c = previousTransaction.Fx_Contract__c;
                target.Tranche_amount__c = (previousTransaction.Tranche_amount__c * target.amount__c / previousTransaction.amount__c).setScale(2, System.RoundingMode.HALF_EVEN);
                fxContractMap.get(target.Fx_Contract__c).Remain_amount__c += target.Tranche_amount__c;
                updateTransaction.add(target);
                if (relatedTrancheTransactionsMap.containsKey(previousTransaction.Id)) {
                    for (Transaction__c trn : relatedTrancheTransactionsMap.get(previousTransaction.Id)) {
                        Transaction__c rollOverTransaction = target.clone(false,true,false,false);
                        rollOverTransaction.Related_Tranche_Transaction__c = target.Id;
                        rollOverTransaction.Amount__c = 0;
                        rollOverTransaction.Type__c = target.Type__c + ' (Tr)';
                        rollOverTransaction.Tranche_amount__c = (trn.Tranche_amount__c * target.amount__c / previousTransaction.amount__c).setScale(2, System.RoundingMode.HALF_EVEN);
                        rollOverTransaction.Fx_Contract__c = trn.Fx_Contract__c;
                        rollOverTransaction.Tranche_amount_percentage__c = trn.Tranche_amount_percentage__c;
                        fxContractMap.get(rollOverTransaction.Fx_Contract__c).Remain_amount__c += rollOverTransaction.Tranche_amount__c;
                        insertTransaction.add(rollOverTransaction);
                        log(fxContractMap.get(rollOverTransaction.Fx_Contract__c).Tranche_Name__c + ' ' + '----------' + ' ' + toString(rollOverTransaction) + ' ' + 'New');
                    }
                }
                continue;
            }

            while(indexContract < fxContractList.size() && fxContractList.get(indexContract).Remain_amount__c <= 0){
                indexContract++;
            }
            if(indexContract == fxContractList.size()){
                detailResults.add(new ResultDetail('',
                                                   target.Name, target.Invoice_Finance_Deal__r.Name, 
                                                   target.DebitCredit__c + ' ' + target.Amount__c,
                                                   'Nok Insufficient remaining amount from all FX Contract ' + target.Effective_Date__c));
                log(fxContractMap.get(target.Fx_Contract__c).Tranche_Name__c + ' ' + toString(target) + ' ' + 'No more amount from all tranches');
                break;
            }
            target.FX_Contract__c = fxContractList.get(indexContract).Id;
            target.Tranche_amount__c = target.Amount__c;
            fxContractList.get(indexContract).Remain_amount__c += target.Tranche_amount__c;
            if(fxContractList.get(indexContract).Remain_amount__c < 0) {
                // Create new Transaction for roll over
                String resultCreateTrans = createRollOverTransaction(target);
                
                // If have over amount
                if(String.isNotBlank(resultCreateTrans)){
                    target.Tranche_amount__c = null;
                    detailResults.add(new ResultDetail('',
                                                       target.Name, target.Invoice_Finance_Deal__r.Name, 
                                                       target.DebitCredit__c + ' ' + target.Amount__c,
                                                       'Nok Insufficient remaining amount from all FX Contract ' + target.Effective_Date__c));
                    log(fxContractMap.get(target.Fx_Contract__c).Tranche_Name__c + ' ' + toString(target) + ' ' + 'No more amount from all tranches');
                    break;
                } 
            } 
            // System.debug('wa ' + mapInvoiceAllocation.get(target.Invoice_Allocation__c));
            if (mapInvoiceAllocation != null && mapInvoiceAllocation.get(target.Invoice_Allocation__c) != null) {
                Invoice_Allocation__c invoiceAllocation = mapInvoiceAllocation.get(target.Invoice_Allocation__c);
                updateAllocationWeightedRate(invoiceAllocation, target, fxContractMap, relatedTrancheTransactionsMap);
                updateInvoiceAllocations.add(invoiceAllocation);
                System.debug('allocation ' + toString(invoiceAllocation));
            }
            
            if (target.Fx_Contract__c != null && target.Tranche_amount__c != null) {
                mapInvAlloWithInvPurchaseTranx.put(target.Invoice_Allocation__c, target);
                mapInvAlloWithInvPurchaseTranx.put(target.Invoice_Finance_Deal__c, target);    
                updateTransaction.add(target);
                log(fxContractMap.get(target.Fx_Contract__c).Tranche_Name__c + ' ' + toString(target));
            } else {
                detailResults.add(new ResultDetail('',
                                                   target.Name, target.Invoice_Finance_Deal__r.Name, 
                                                   target.DebitCredit__c + ' ' + target.Amount__c,
                                                   'Nok Calculation fail'));
                log(fxContractMap.get(target.Fx_Contract__c).Tranche_Name__c + ' ' + toString(target) + ' ' + 'Calculation fail');
            }
        }

        Savepoint sv = Database.setSavepoint();
        boolean preNeedRunTrigger = TransactionTriggerHandler.needRunTrigger;
        boolean isCalledFromVfs = this.fxContract.Id == null;
        try{
            TransactionTriggerHandler.needRunTrigger = false;
            transactionmap.put(null, new Transaction__c());
            if(insertTransaction.size() > 0){
                for (Transaction__c trn : insertTransaction) {
                    trn.Tranche_name__c = fxContractMap.get(trn.Fx_Contract__c).Tranche_name__c;
                    trn.Tranche_amount_USD__c = trn.Tranche_amount__c * fxContractMap.get(trn.Fx_Contract__c).Origination_Rate__c;
                }
                Integer indexTransaction = 0;
                Database.SaveResult[] results = Database.Insert(insertTransaction, true);
                for(Database.SaveResult result : results){
                    Transaction__c original = transactionmap.get((insertTransaction.get(indexTransaction).Related_Tranche_Transaction__c));
                    Transaction__c target = insertTransaction.get(indexTransaction);
                    detailResults.add(new ResultDetail(fxContractMap.get(target.FX_Contract__c).Tranche_name__c,
                                                       original.Name + ' (Copy) ', target.Invoice_Finance_Deal__r.Name,
                                                       original.DebitCredit__c + ' ' + target.Tranche_amount__c 
                                                       + ' (' + target.Tranche_amount_percentage__c + '%)',
                                                       !result.isSuccess() ? 'Nok' : 'OK'));
                    indexTransaction++;
                }
                indexTransaction = 0;                
            }
            
            if(updateTransaction.size() > 0){
                for (Transaction__c trn : updateTransaction) {
                    trn.Tranche_amount_percentage__c = (trn.Tranche_amount__c / trn.amount__c * 100).setScale(2, System.RoundingMode.HALF_EVEN);
                    trn.Tranche_name__c = fxContractMap.get(trn.Fx_Contract__c).Tranche_name__c;
                    trn.Tranche_amount_USD__c = trn.Tranche_amount__c * fxContractMap.get(trn.Fx_Contract__c).Origination_Rate__c;
                }

                Database.SaveResult[] results = Database.Update(updateTransaction, true);
                for(Database.SaveResult result : results){
                    Transaction__c target = transactionmap.get(result.getId());
                    detailResults.add(new ResultDetail(fxContractMap.get(target.FX_Contract__c).Tranche_name__c,
                                                       target.Name, target.Invoice_Finance_Deal__r.Name, 
                                                       target.DebitCredit__c + ' ' + target.Tranche_amount__c 
                                                       + (target.amount__c == target.Tranche_amount__c ? '' : ' (' + target.Tranche_amount_percentage__c + '%)'),
                                                       !result.isSuccess() ? 'Nok' : 'OK'));
                    log(fxContractMap.get(target.Fx_Contract__c).Tranche_Name__c + ' ' + toString(target) + ' ' + 'ok ' + result.isSuccess());
                }
            }

            List<FX_Contract__c> previousFXContractList = new List<FX_Contract__c>();
            if (!isSimulation) {
                TransactionTriggerHandler.recalculateRemainAmount(fxContractList, CCY);
                update fxContractList;
                Set<FX_Contract__c> previousFXContract = new Set<FX_Contract__c>();
                for (Transaction__c trn : mapInvAlloWithInvPurchaseTranx.values()) {
                    if (trn != null)
                        previousFXContract.add(fxContractMap.get(trn.Fx_Contract__c));
                }
                previousFXContract.remove(null);
                previousFXContract.removeAll(fxContractList);
                previousFXContractList = new List<FX_Contract__c>(previousFXContract);
                if (previousFXContractList.size() > 0) {
                    TransactionTriggerHandler.recalculateRemainAmount(previousFXContractList, CCY);
                    update previousFXContractList;
                }
            }
            
            for (Fx_Contract__c fxContract : fxContractList) {
                detailResults.add(new ResultDetail(fxContract.Tranche_name__c, '', 'Remain amount ' + fxContract.Remain_amount__c, ''));
            }
            for (Fx_Contract__c fxContract : previousFXContractList) {
                detailResults.add(new ResultDetail(fxContract.Tranche_name__c, '', 'Remain amount ' + fxContract.Remain_amount__c, ''));
            }
            
            if (mapInvoiceAllocation != null) {
                if (updateInvoiceAllocations.size() > 0) {
                    // update updateInvoiceAllocations;
                    Database.SaveResult[] results = null;
                    results = Database.Update(updateInvoiceAllocations, false);
                    for (Database.SaveResult result : results)
                    {
                        Invoice_Allocation__c invoiceAllocation = mapInvoiceAllocation.get(result.getId());
                        Fx_Contract__c targetContract = fxContractMap.get(invoiceAllocation.FX_Contract__c);
                        detailResults.add(new ResultDetail(targetContract.Tranche_name__c,
                                                           '', invoiceAllocation.Name,  
                                                           invoiceAllocation.Tranche_name__c + ' ' + invoiceAllocation.FX_Rate_manual__c,
                                                           !result.isSuccess() ? 'Nok' : 'OK'));
                        log(targetContract.Tranche_name__c + ' ' + toString(invoiceAllocation) + ' ' + 'ok ' + result.isSuccess());
                    }            
                }
            }
            if (isSimulation) {
                Database.rollback(sv);
            }
        } catch(DMLException ex){
            if (!isCalledFromVfs) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()));
            Database.rollback(sv);
        } finally {
            TransactionTriggerHandler.needRunTrigger = preNeedRunTrigger;
        }

        outputResult(detailResults);
        if (!isSimulation && !isCalledFromVfs) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Total Updated Transactions : ' + updateTransaction.size()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Total Roll Over Transactions : ' + insertTransaction.size()));
        }
    }
    
    public void unlink() {
        List<Transaction__c> targetTransactions = retrieveTransactionToUpdate(true);
        if (targetTransactions == null) return;

        Savepoint sv = Database.setSavepoint();
        try{
            if(targetTransactions.size() > 0){
                Map<Id, Id> trancheToRemoveMap = new Map<Id, Id>();
                Map<Id, Transaction__c> updateTransaction = new Map<Id, Transaction__c>(targetTransactions);
                for (Transaction__c trn : targetTransactions) {
                    trancheToRemoveMap.put(trn.Id, trn.Fx_Contract__c);
                    trn.Fx_Contract__c = null;
                    trn.Tranche_amount__c = null;
                    trn.Tranche_name__c = null;
                    trn.Tranche_amount_percentage__c = null;
                    trn.Tranche_amount_USD__c = null;
                }
                List<Transaction__c> deleteTransactions = [SELECT Id, Name, Invoice_Finance_Deal__r.Name, Invoice_Allocation__r.Name, FX_Contract__c 
                                                           FROM Transaction__c 
                                                           WHERE Related_Tranche_Transaction__c IN :trancheToRemoveMap.keySet()];
                Database.SaveResult[] results = Database.Update(targetTransactions, true);
                for(Database.SaveResult result : results){
                    Transaction__c target = transactionmap.get(result.getId());
                    detailResults.add(new ResultDetail(fxContractMap.get(trancheToRemoveMap.get(result.getId())).Tranche_name__c,
                                                       target.Name, target.Invoice_Finance_Deal__r.Name,
                                                       !result.isSuccess() ? 'Nok' : 'OK'));
                }
                delete deleteTransactions;
                for (Transaction__c target : deleteTransactions) {
                    detailResults.add(new ResultDetail(fxContractMap.get(target.FX_Contract__c).Tranche_name__c,
                                                       target.Name + ' (Copy)', target.Invoice_Finance_Deal__r.Name,
                                                       'Delete Ok'));
                }
                TransactionTriggerHandler.recalculateRemainAmount(fxContractList, CCY);
            }
            
            if (isSimulation) {
                Database.rollback(sv);
            }
        } catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ex.getMessage()));
            Database.rollback(sv);
        }

        outputResult(detailResults);
        if (!isSimulation) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Total Updated Transactions : ' + targetTransactions.size()));
        }
    }

    public void recalculateRemainAmount() {
        TransactionTriggerHandler.recalculateRemainAmount(fxContractList, CCY);
        detailResults.clear();
        for (Fx_Contract__c fxContract : fxContractList) {
            detailResults.add(new ResultDetail(fxContract.Tranche_name__c, '', 'Remain amount ' + fxContract.Remain_amount__c, ''));
        } 
        outputResult(detailResults);
        if (!isSimulation) {
            update fxContractList;
            close();
        }
    }

    private void outputResult(List<ResultDetail> detailResults) {
        resultDetails = new Map<String, List<ResultDetail>>();
        resultCountMap = new Map<String, Integer>();
        resultList = new List<String>();

        if(detailResults.size() > 0){
            for(ResultDetail result: detailResults){
                List<ResultDetail> results = new List<ResultDetail>();
                if(resultDetails.containsKey(result.fxContractName)){
                    results = resultDetails.get(result.fxContractName);
                }
                results.add(result);
                resultDetails.put(result.fxContractName, results);
                resultCountMap.put(result.fxContractName, results.size());
            }
            for (Fx_Contract__c fxContract : fxContractList) {
                if (resultDetails.containsKey(fxContract.Tranche_Name__c))
                    resultList.add(fxContract.Tranche_Name__c);
            }
            List<String> repaidAdditionalList = new List<String>(resultDetails.keySet());
            repaidAdditionalList.sort();
            for (String fxContractName : repaidAdditionalList) {
                if (resultList.indexOf(fxContractName) == -1)
                    resultList.add(fxContractName);
            }
        }

    }

    private String createRollOverTransaction(Transaction__c target){
        String result = '';
        Transaction__c rollOverTransaction = target.clone(false,true,false,false);
        rollOverTransaction.Tranche_amount__c = 0;
        if(fxContractList.get(indexContract).Remain_amount__c < 0){
            decimal currentRemainAmount = this.fxContractList.get(indexContract).Remain_amount__c;
            target.Tranche_amount__c -= currentRemainAmount;
            fxContractList.get(indexContract).Remain_amount__c = 0;
            while(indexContract < fxContractList.size() && fxContractList.get(indexContract).Remain_amount__c <= 0){
                indexContract++;
            }
            if(indexContract == fxContractList.size()) {
                return String.valueOf(currentRemainAmount);
            }
            if (target.Related_Tranche_Transaction__c == null) {
                rollOverTransaction.Related_Tranche_Transaction__c = target.Id;
            }
            rollOverTransaction.Type__c = '01.Invoice Purchase (Tr)';
            rollOverTransaction.Tranche_amount__c = currentRemainAmount;
            rollOverTransaction.Fx_Contract__c = fxContractList.get(indexContract).Id;
            this.fxContractList.get(indexContract).Remain_amount__c += rollOverTransaction.Tranche_amount__c;
            insertTransaction.add(rollOverTransaction);
            log(fxContractMap.get(rollOverTransaction.Fx_Contract__c).Tranche_Name__c + ' ' + '000-------' + ' ' + toString(rollOverTransaction) + ' ' + 'New');
            result = createRollOverTransaction(rollOverTransaction);
        }
        indexContract--;
        if (rollOverTransaction.Tranche_amount__c == 0) {
        } else if (String.isNotBlank(result)) {
            insertTransaction.remove(insertTransaction.indexOf(rollOverTransaction));
            rollOverTransaction.Tranche_amount__c = 0;
            this.fxContractList.get(indexContract).Remain_amount__c -= rollOverTransaction.Tranche_amount__c;
        } else {
            rollOverTransaction.Tranche_amount_percentage__c = (rollOverTransaction.Tranche_amount__c / rollOverTransaction.amount__c * 100).setScale(2, System.RoundingMode.HALF_EVEN);
            rollOverTransaction.amount__c = 0;
            List<Transaction__c> relTrancheList = new List<Transaction__c>();
            if (relatedTrancheTransactionsMap.get(rollOverTransaction.Related_Tranche_Transaction__c) != null) {
                relTrancheList = relatedTrancheTransactionsMap.get(rollOverTransaction.Related_Tranche_Transaction__c);
            }
            if (relTrancheList.size() == 0) relTrancheList.add(rollOverTransaction);
            else relTrancheList.add(0, rollOverTransaction);
            relatedTrancheTransactionsMap.put(rollOverTransaction.Related_Tranche_Transaction__c, relTrancheList);
        }

        return result;
    }

    public static void updateRelatedTrancheTransactionsMap(Map<ID,List<Transaction__c>> relatedTrancheTransactionsMap, Set<Id> setInvoicePurchaseId) {
        List<Transaction__c> prevRelTrancheTrn = [SELECT Related_Tranche_Transaction__c, Tranche_amount__c, Tranche_amount_percentage__c, Amount__c, Invoice_Finance_Deal__r.Name, Fx_Contract__c
                                                  FROM Transaction__c
                                                  WHERE Related_Tranche_Transaction__c IN :setInvoicePurchaseId 
                                                  AND FX_Contract__c != null AND Type__c = '01.Invoice Purchase (Tr)'];
        for (Transaction__c trn : prevRelTrancheTrn) {
            List<Transaction__c> relTrancheList = new List<Transaction__c>();
            if (relatedTrancheTransactionsMap.get(trn.Related_Tranche_Transaction__c) != null) {
                relTrancheList = relatedTrancheTransactionsMap.get(trn.Related_Tranche_Transaction__c);
            }
            relTrancheList.add(trn);
            relatedTrancheTransactionsMap.put(trn.Related_Tranche_Transaction__c, relTrancheList);
        }
    }

    public static void updateAllocationWeightedRate(Invoice_Allocation__c invoiceAllocation, Transaction__c target, Map<Id, Fx_Contract__c> fxContractMap, Map<ID,List<Transaction__c>> relatedTrancheTransactionsMap) {
        invoiceAllocation.Fx_Contract__c = target.Fx_Contract__c;
        Fx_Contract__c fxContract = fxContractMap.get(target.Fx_Contract__c);
        invoiceAllocation.FX_Rate_manual__c = fxContract.Origination_Rate__c;
        invoiceAllocation.Tranche_Name__c = fxContract.Tranche_Name__c;
        if (relatedTrancheTransactionsMap.get(target.Id) != null) {
            decimal allocationTrancheAmount = fxContract.Origination_Rate__c * target.Tranche_amount__c;
            for (Transaction__c rollOverTransaction : relatedTrancheTransactionsMap.get(target.Id)) 
            {
                fxContract = fxContractMap.get(rollOverTransaction.Fx_Contract__c);
                invoiceAllocation.Tranche_Name__c += ' ' + fxContract.Tranche_Name__c;
                allocationTrancheAmount += fxContract.Origination_Rate__c * rollOverTransaction.Tranche_amount__c;
            }
            invoiceAllocation.FX_Rate_manual__c = allocationTrancheAmount / target.Amount__c;
        }
    }

    public static boolean toRunTranche(String CCY, List<Invoice_Allocation__c> listAllocation) {
        if (CCY == 'USD' || CCY == null) return false;
        String accounts = ';' + config.getConfig('Tranche_Account_For_Fx_Contract') + ';';
        for (Invoice_Allocation__c allocation : listAllocation) {
          if (accounts.indexOf(';' + allocation.Funder__r.Name + ';') != -1) 
                  return true;
        }
        return false;
      }    

    public static String toString(Object obj) {
        if (obj instanceof Transaction__c) {
            Transaction__c trn = (Transaction__c)obj;
            return trn.Name + ' ' + trn.Tranche_Name__c + ' ' + trn.Invoice_Finance_Deal__r.Name + ':' + trn.Invoice_Allocation__r.Name + ' ' + trn.DebitCredit__c + ' ' + trn.Tranche_amount__c + ' ' + trn.Tranche_amount_percentage__c + '%';
        } else if (obj instanceof Invoice_Allocation__c) {
            Invoice_Allocation__c invoiceAllocation = (Invoice_Allocation__c)obj;
            return invoiceAllocation.Name + ' ' + invoiceAllocation.Tranche_name__c + ' ' + invoiceAllocation.FX_Rate_manual__c;
        }
        return String.valueOf(obj);
    }
}