public class TransactionCashFlowController {
    public String accountName{get;set;}
    public Date minDate {get;set;}
    public Date maxDate {get;set;}
    public Decimal balanceCollectionUSD{get;set;}
    public Decimal balanceCollectionOther{get;set;}
    public Decimal balanceCollectionOtherUSD{get;set;}
    public Decimal balanceCollectionEUR{get;set;}
    public Decimal balanceCollectionEURUSD{get;set;}
    public Decimal balanceLendingUSD{get;set;}
    public Decimal balanceLendingOther{get;set;}
    public Decimal balanceLendingOtherUSD{get;set;}
    public Decimal balanceLendingEUR{get;set;}
    public Decimal balanceLendingEURUSD{get;set;}
    public List<ResultDetail> allResults;
    public List<ResultDetail> detailResults {get;set;}
    public Integer countTotalRecords{get;set;}
    public Integer offSetSize{get;set;}
    public Integer maxSize{get;set;}
    public List<String> transactionTypeToLending = new List<String>{'04.Invoice Capital Repayment','05.Invoice Discount Amount','054.Invoice Discount Amount Overdue','70.Deposit (Tr)','60.Intra-transfer'};
    public String ccy {get;set;}    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('All currencies', 'All currencies'));
        options.add(new SelectOption('USD', 'USD'));
        options.add(new SelectOption('EUR', 'EUR'));
        options.add(new SelectOption('Other', 'Other'));
        return options;
    }
    public Class ResultDetail implements Comparable {
        public ID id{get;set;}
        public String postingID {get;set;}
        public String invoiceAllocationId {get;set;}
        public String invoiceAllocationName {get;set;}
        public String ccy {get;set;}
        public String type {get;set;}
        public Decimal amount {get;set;}
        public Date effectiveDate {get;set;}
        public Decimal originationRate {get;set;}
        public Decimal trancheAmount {get;set;}
        public String trancheName {get;set;}
        public String trancheNumber {get;set;}
        public Decimal trancheAmountUSD {get;set;}
        public Decimal trancheAmountPercent {get;set;}
        public Decimal trancheCollectionUSD {get;set;}
        public Decimal trancheCollectionEUR {get;set;}
        public Decimal trancheCollectionEURUSD {get;set;}
        public Decimal trancheCollectionOther {get;set;}
        public Decimal trancheCollectionOtherUSD {get;set;}
        public Decimal trancheLendingUSD {get;set;}
        public Decimal trancheLendingEUR {get;set;}
        public Decimal trancheLendingEURUSD {get;set;}
        public Decimal trancheLendingOther {get;set;}
        public Decimal trancheLendingOtherUSD {get;set;}
        
        public Integer compareTo(Object compareTo) {
            ResultDetail compareToEmp = (ResultDetail)compareTo;
            if (postingID == compareToEmp.postingID) return 0;
            if (postingID > compareToEmp.postingID) return 1;
            return -1;        
        }
    }
    
    public TransactionCashFlowController(){
        ccy = 'All currencies';
        maxSize = 100;
        offSetSize = 0;
        detailResults = new List<ResultDetail>();
        accountName = config.getConfig('Tranche_Account_For_Fx_Contract');
        balanceCollectionUSD = 0;
        balanceCollectionOther = 0;
        balanceCollectionEUR = 0;
        balanceLendingUSD = 0;
        balanceLendingOther = 0;
        balanceLendingEUR = 0;
        minDate = Date.newInstance(2021, 07, 01);
        search();
        balanceCollectionUSD = 0;
        balanceCollectionOther = 0;
        balanceCollectionEUR = 0;
        balanceLendingUSD = 0;
        balanceLendingOther = 0;
        balanceLendingEUR = 0;
    }
    
    public void search(){
        balanceCollectionEURUSD = balanceCollectionEUR;
        balanceLendingEURUSD = balanceLendingEUR;
        balanceCollectionOtherUSD = balanceCollectionOther;
        balanceLendingOtherUSD = balanceLendingOther;
        allResults = new List<ResultDetail>();
        String accountSearch = '(';
        if(String.isBlank(accountName)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please input Account Name!'));
            return;
        } else {
            for(String tempAcc: accountName.split(';')){
                accountSearch += '\'' + tempAcc + '\',';
            }
            accountSearch = accountSearch.removeEnd(',') + ')';
        }
        
        if(minDate == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please input Min date !'));
            return;
        }
        
        String queryString = 'SELECT Id,'
            + ' Name,'
            + ' Invoice_Allocation__c,'
            + ' Invoice_Allocation__r.Name,'
            + ' Account__c,'
            + ' Type__c,'
            + ' Amount__c,'
            + ' Effective_Date__c,'
            + ' CCY__c,'
            + ' Tranche_amount_percentage__c,'
            + ' Tranche_amount_USD__c,'
            + ' Tranche_amount__c,'
            + ' Tranche_Name__c,' 
            + ' FX_Contract__c,'
            + ' FX_Contract__r.Origination_Rate__c,'
            + ' Related_Tranche_Transaction__c'
            + ' FROM Transaction__c'
            + ' WHERE Account__r.Name IN ' + accountSearch
            + ' AND Effective_Date__c >= : minDate';
        if(ccy == 'USD' || ccy == 'EUR'){
            queryString += ' AND CCY__c = : ccy';
        } else if(ccy == 'Other'){
            queryString += ' AND CCY__c != \'USD\' AND CCY__c != \'EUR\'';
        }
        if(maxDate != null){
            queryString += ' AND Effective_Date__c <= : maxDate';
        }
        queryString += ' ORDER BY Effective_Date__c ASC, Name ASC';
        
        // Execute Query
        List<Transaction__c> listTransactions = database.query(queryString);
        
        countTotalRecords = listTransactions.size();
        if(countTotalRecords == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No matches found !!!'));
            detailResults = new List<ResultDetail>();
            return;
        }
        Map<ID,ResultDetail> mapResultDetail = new Map<Id,ResultDetail>();
        Map<Date,List<ResultDetail>> mapSortResults = new Map<Date,List<ResultDetail>>();
        for(Transaction__c tran:listTransactions){
            ResultDetail detailResult = mapResultDetail.get(tran.Related_Tranche_Transaction__c);
            if(detailResult == null){
                detailResult = new ResultDetail();
                detailResult.Id = tran.Id;
                detailResult.postingID = tran.Name;
                detailResult.invoiceAllocationId = tran.Invoice_Allocation__c == null ? '' : tran.Invoice_Allocation__c;
                detailResult.invoiceAllocationName = tran.Invoice_Allocation__c == null ? '' : tran.Invoice_Allocation__r.Name;
                detailResult.ccy = tran.CCY__c;
                detailResult.type = tran.Type__c;
                detailResult.amount = tran.Amount__c;
                detailResult.effectiveDate = tran.Effective_Date__c;
                detailResult.trancheAmount = tran.Tranche_amount__c == null ? 0 : tran.Tranche_amount__c.setScale(2);
                detailResult.trancheNumber = String.isBlank(tran.Tranche_Name__c) ? '' : tran.Tranche_Name__c.length() > 4 ? tran.Tranche_Name__c.subString(4) : tran.Tranche_Name__c;
                detailResult.trancheAmountUSD = tran.Tranche_amount_USD__c == null ? 0 : tran.Tranche_amount_USD__c.setScale(2);
                detailResult.trancheAmountPercent = tran.Tranche_amount_percentage__c == null ? 0 : tran.Tranche_amount_percentage__c.setScale(2);
                if(tran.FX_Contract__c != null){
                    detailResult.originationRate = tran.FX_Contract__r.Origination_Rate__c;
                } else {
                    detailResult.originationRate = 0;
                }
                mapResultDetail.put(tran.Id, detailResult);
            } else {
                detailResult.trancheAmount += tran.Tranche_amount__c == null ? 0 : tran.Tranche_amount__c.setScale(2);
                if(String.isBlank(detailResult.trancheNumber)){
                    detailResult.trancheNumber = String.isBlank(tran.Tranche_Name__c) ? '' : tran.Tranche_Name__c.length() > 4 ? tran.Tranche_Name__c.subString(4) : tran.Tranche_Name__c;
                } else {
                    detailResult.trancheNumber += String.isBlank(tran.Tranche_Name__c) ? '' : ' ' + (tran.Tranche_Name__c.length() > 4 ? tran.Tranche_Name__c.subString(4) : tran.Tranche_Name__c);
                }
                detailResult.trancheAmountUSD += tran.Tranche_amount_USD__c == null ? 0 : tran.Tranche_amount_USD__c.setScale(2);
                detailResult.trancheAmountPercent += tran.Tranche_amount_percentage__c == null ? 0 : tran.Tranche_amount_percentage__c.setScale(2);
                mapResultDetail.put(tran.Related_Tranche_Transaction__c, detailResult);
            }
        }
        for(Id key: mapResultDetail.keySet()){
            ResultDetail detailResult = mapResultDetail.get(key);
            if(!transactionTypeToLending.contains(detailResult.type)){
                if(detailResult.ccy == 'USD'){
                    balanceLendingUSD += detailResult.trancheAmountUSD == null || detailResult.trancheAmountUSD == 0 ? detailResult.amount : detailResult.trancheAmountUSD;
                    detailResult.trancheLendingUSD = balanceLendingUSD.setScale(2);
                    detailResult.trancheLendingOther = balanceLendingOther.setScale(2);
                    detailResult.trancheLendingOtherUSD = balanceLendingOtherUSD.setScale(2);
                    detailResult.trancheLendingEUR = balanceLendingEUR.setScale(2);
                    detailResult.trancheLendingEURUSD = balanceLendingEURUSD.setScale(2);
                } else if(detailResult.ccy == 'EUR'){
                    balanceLendingEUR += detailResult.trancheAmount == null || detailResult.trancheAmount == 0 ? detailResult.amount : detailResult.trancheAmount;
                    if(detailResult.originationRate != 0){
                        balanceLendingEURUSD += (detailResult.Amount * detailResult.originationRate);
                    } else {
                        balanceLendingEURUSD += detailResult.trancheAmountUSD == null ? 0 : detailResult.trancheAmountUSD;
                    }
                    detailResult.trancheLendingUSD = balanceLendingUSD.setScale(2);
                    detailResult.trancheLendingOther = balanceLendingOther.setScale(2);
                    detailResult.trancheLendingOtherUSD = balanceLendingOtherUSD.setScale(2);
                    detailResult.trancheLendingEUR = balanceLendingEUR.setScale(2);
                    detailResult.trancheLendingEURUSD = balanceLendingEURUSD.setScale(2);
                } else {
                    balanceLendingOther += detailResult.trancheAmount == null || detailResult.trancheAmount == 0 ? detailResult.amount : detailResult.trancheAmount;
                    if(detailResult.originationRate != 0){
                        balanceLendingOtherUSD += (detailResult.Amount * detailResult.originationRate);
                    } else {
                        balanceLendingOtherUSD += detailResult.trancheAmountUSD == null ? 0 : detailResult.trancheAmountUSD;
                    }
                    detailResult.trancheLendingUSD = balanceLendingUSD.setScale(2);
                    detailResult.trancheLendingOther = balanceLendingOther.setScale(2);
                    detailResult.trancheLendingOtherUSD = balanceLendingOtherUSD.setScale(2);
                    detailResult.trancheLendingEUR = balanceLendingEUR.setScale(2);
                    detailResult.trancheLendingEURUSD = balanceLendingEURUSD.setScale(2);
                } 

                detailResult.trancheCollectionUSD = balanceCollectionUSD.setScale(2);
                detailResult.trancheCollectionOther = balanceCollectionOther.setScale(2);
                detailResult.trancheCollectionOtherUSD = balanceCollectionOtherUSD.setScale(2);
                detailResult.trancheCollectionEUR = balanceCollectionEUR.setScale(2);
                detailResult.trancheCollectionEURUSD = balanceCollectionEURUSD.setScale(2);
            } else {
                if(detailResult.ccy == 'USD'){
                    balanceCollectionUSD += detailResult.trancheAmountUSD == null || detailResult.trancheAmountUSD == 0 ? detailResult.amount : detailResult.trancheAmountUSD;
                    detailResult.trancheCollectionUSD = balanceCollectionUSD.setScale(2);
                    detailResult.trancheCollectionOther = balanceCollectionOther.setScale(2);
                    detailResult.trancheCollectionOtherUSD = balanceCollectionOtherUSD.setScale(2);
                    detailResult.trancheCollectionEUR = balanceCollectionEUR.setScale(2);
                    detailResult.trancheCollectionEURUSD = balanceCollectionEURUSD.setScale(2);
                } else if(detailResult.ccy == 'EUR'){
                    balanceCollectionEUR += detailResult.trancheAmount == null || detailResult.trancheAmount == 0 ? detailResult.amount : detailResult.trancheAmount;
                    if(detailResult.originationRate != 0){
                        balanceCollectionEURUSD += (detailResult.Amount * detailResult.originationRate);
                    } else {
                        balanceCollectionEURUSD += detailResult.trancheAmountUSD == null ? 0 : detailResult.trancheAmountUSD;
                    }
                    balanceCollectionEURUSD += detailResult.trancheAmountUSD == null ? detailResult.Amount : detailResult.trancheAmountUSD;
                    detailResult.trancheCollectionUSD = balanceCollectionUSD.setScale(2);
                    detailResult.trancheCollectionOther = balanceCollectionOther.setScale(2);
                    detailResult.trancheCollectionOtherUSD = balanceCollectionOtherUSD.setScale(2);
                    detailResult.trancheCollectionEUR = balanceCollectionEUR.setScale(2);
                    detailResult.trancheCollectionEURUSD = balanceCollectionEURUSD.setScale(2);
                } else {
                    balanceCollectionOther += detailResult.trancheAmount == null || detailResult.trancheAmount == 0 ? detailResult.amount : detailResult.trancheAmount;
                    if(detailResult.originationRate != 0){
                        balanceCollectionOtherUSD += (detailResult.Amount * detailResult.originationRate);
                    } else {
                        balanceCollectionOtherUSD += detailResult.trancheAmountUSD == null ? 0 : detailResult.trancheAmountUSD;
                    }
                    detailResult.trancheCollectionUSD = balanceCollectionUSD.setScale(2);
                    detailResult.trancheCollectionOther = balanceCollectionOther.setScale(2);
                    detailResult.trancheCollectionOtherUSD = balanceCollectionOtherUSD.setScale(2);
                    detailResult.trancheCollectionEUR = balanceCollectionEUR.setScale(2);
                    detailResult.trancheCollectionEURUSD = balanceCollectionEURUSD.setScale(2);
                } 
                detailResult.trancheLendingUSD = balanceLendingUSD.setScale(2);
                detailResult.trancheLendingOther = balanceLendingOther.setScale(2);
                detailResult.trancheLendingOtherUSD = balanceLendingOtherUSD.setScale(2);
                detailResult.trancheLendingEUR = balanceLendingEUR.setScale(2);
                detailResult.trancheLendingEURUSD = balanceLendingEURUSD.setScale(2);
            }
        }
        allResults.addAll(mapResultDetail.values());
        countTotalRecords = allResults.size();
        getDetailPage();
    }
    
    private void getDetailPage(){
        if(maxSize <= 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Must input number of records/page > 0 !!!'));
            detailResults = new List<ResultDetail>();
            countTotalRecords = 0;
            maxSize = 0;
            return;
        }
        Integer count = 0;
        detailResults = new List<ResultDetail>();
        for(Integer index = offSetSize; index < allResults.size(); index++){
            detailResults.add(allResults.get(index));
            if(++count == maxSize){
                break;
            }
        }
    }
    
    public boolean getprv(){
        if(offSetSize > 0)
            return false;
        else
            return true;
    }
    
    public boolean getnxt(){
        if(offSetSize + maxSize < CountTotalRecords)
            return false;
        else
            return true;
    }
    
    public PageReference nextPage(){
    	offSetSize += maxSize ;
        getDetailPage();
    	return null;
    }
    
    public PageReference prvPage(){
        offSetSize -= maxSize ;
        getDetailPage();
    	return null;
    }
    
    public PageReference firstPage(){
        offSetSize = 0;
        getDetailPage();
    	return null;
    }
    
    public PageReference endPage(){
        offSetSize = countTotalRecords - math.mod(countTotalRecords,maxSize);
        getDetailPage();
    	return null;
    } 
}