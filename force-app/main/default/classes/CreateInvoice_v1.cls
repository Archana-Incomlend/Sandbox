public class CreateInvoice_v1 {
    private Helper_Log logs {
        private get;
        private set;
    }
    
    private IncomlendPricing_v3_Configuration.NotificationConfiguration notification {
		private get;
		private set;
	}
    
    private String recordTypeValue {
        private get;
        private set;
    }
    
    private Id customerAccountId {
        private get;
        private set;
    }
    
    private invoice_finance_deal__c invoiceFinanceDeal {
        private get;
        private set;
    }
    
    private Invoice_Allocation__c allocation {
        private get;
        private set;
    }
    
    private Map<InvoiceUtil.Description, Decimal> amountExclGSTMap {
        private get;
        private set;
    }
    
    private Map<InvoiceUtil.Description, Decimal> amountNoTaxMap {
        private get;
        private set;
    }
    
    private Decimal taxRate {
        private get;
        private set;
    }
    
    private InvoiceUtil.RecordType recordType {
        private get;
        private set;
    }
    
    private InvoiceUtil.ActionType actionType {
        private get;
        private set;
    }
    
    private Boolean isEarlyPayment {
        private get;
        private set;
    }

    private Boolean isSimulation {
        private get;
        private set;
    }
    
    public CreateInvoice_v1(Id customerAccountId,
                            invoice_finance_deal__c invoiceFinanceDeal,
                            Invoice_Allocation__c allocation,
                            Map<InvoiceUtil.Description, Decimal> amountExclGSTMap,
                            Decimal taxRate,
                            Map<InvoiceUtil.Description, Decimal> amountNoTaxMap,
                            InvoiceUtil.RecordType recordType,
                            InvoiceUtil.ActionType actionType,
                            Boolean isEarlyPayment,
                            IncomlendPricing_v3_Configuration.NotificationConfiguration notification,
                            Boolean isSimulation) {
        this.logs = new Helper_Log();
        
        if (!Test.isRunningTest()) {
            this.notification = notification;
        }
        
        this.customerAccountId = customerAccountId;
        this.invoiceFinanceDeal = invoiceFinanceDeal;
        this.allocation = allocation;
        this.amountExclGSTMap = amountExclGSTMap;
        this.taxRate = taxRate == null ? 0.00 : taxRate;
        this.amountNoTaxMap = amountNoTaxMap;
        this.recordType = recordType;
        this.actionType = actionType;
        this.isEarlyPayment = isEarlyPayment;
        this.isSimulation = isSimulation;
    }
    
    public boolean createInvoice() {
        logs.LogLine();
        logs.Log('Starting creation of invoice.', 1, Helper_Log.Color.Blue);
        logs.LogLine();
        boolean isCreatedSuccessfully = false;
        boolean hasErrors = false;
        
        try {
            if (Test.isRunningTest() && null == actionType) {
                CalloutException e = new CalloutException();
                e.setMessage('Exception thrown.');
                throw e;
            }
            
            String transactionType = getTransactionType(actionType);
            Id recordTypeId = getRecordTypeId(recordType);
            
            if (String.isNotBlank(transactionType) && String.isNotBlank(recordTypeId)
                   && (null != amountExclGSTMap && !amountExclGSTMap.isEmpty())
                          || (null != amountNoTaxMap && !amountNoTaxMap.isEmpty())) {
                logs.Log('Amount excl GST Map: --' + amountExclGSTMap + '-- Tax Rate: --' + taxRate + '-- Amount No Tax Map: --' + amountNoTaxMap + '--', 2, Helper_Log.Color.Black);
                Tax_Invoice__c newInvoice = setInvoiceDetails(recordTypeId, transactionType);
                List<Tax_Invoice_Fee_Breakdown__c> invoiceFeesList = setInvoiceFeeDetails(newInvoice);
                
                logs.Log('Inserting invoice.', 3, Helper_Log.Color.Green);

                if (!isSimulation) {
                    insert newInvoice;
                }
                
                isCreatedSuccessfully = true;
                
                logs.Log('Setting invoice id for fees breakdown.', 3, Helper_Log.Color.Green);
                for (Tax_Invoice_Fee_Breakdown__c invoiceFees : invoiceFeesList) {
                    invoiceFees.Tax_Invoice__c = newInvoice.Id;
                }
                
                logs.Log('Inserting invoice fees breakdown.', 3, Helper_Log.Color.Green);

                if (!isSimulation) {
                    insert invoiceFeesList;
                }
                
                logs.Log('Invoice and fees breakdown successfully created.', 3, Helper_Log.Color.Green);
                logs.LogLine();
            } else {
                hasErrors = true;
                logs.Log('Record Type, Action Type, and/or Amount Map input/s is/are invalid --'
                         + recordType + '--/--' + actionType + '--/--' + amountExclGSTMap + '--', 3, Helper_Log.Color.Red);
                logs.LogLine();
            }
        } catch(Exception unmanagedException) {
            hasErrors = true;
            logs.LogLine();
            logs.Log(unmanagedException);
            logs.LogLine();
        } finally {
            if (hasErrors && !Test.isRunningTest()) {
                Helper_Email.Send(notification.IsHTML, notification.LogsRecipients, notification.LogsSubject, logs.HTMLLog);
            }
            
        	System.debug(logs.PlainLog);
        }
        
        return isCreatedSuccessfully;
    }
    
    private Id getRecordTypeId(InvoiceUtil.RecordType recordType) {
        logs.Log('Record Type: --' + recordType + '--', 2, Helper_Log.Color.Black);
        
        switch on recordType {
            when SUPPLIER {
                recordTypeValue += '1';
                return Schema.SObjectType.Tax_Invoice__c.getRecordTypeInfosByName().get(InvoiceUtil.SUPPLIER_REC_TYPE).getRecordTypeId();
            }
            
            when FUNDER {
                recordTypeValue += '2';
                return Schema.SObjectType.Tax_Invoice__c.getRecordTypeInfosByName().get(InvoiceUtil.FUNDER_REC_TYPE).getRecordTypeId();
            }
            
            when MAP_AGENT {
                recordTypeValue += '3';
                return Schema.SObjectType.Tax_Invoice__c.getRecordTypeInfosByName().get(InvoiceUtil.MAP_AGENT_REC_TYPE).getRecordTypeId();
            }
            
            when FUNDER_AGENT {
                recordTypeValue += '4';
                return Schema.SObjectType.Tax_Invoice__c.getRecordTypeInfosByName().get(InvoiceUtil.FUNDER_AGENT_REC_TYPE).getRecordTypeId();
            }
            
            when else {
                recordTypeValue += '0';
                return null;
            }
        }
    }
    
    private String getTransactionType(InvoiceUtil.ActionType actionType) {
        logs.Log('Action Type: --' + actionType + '--', 2, Helper_Log.Color.Black);
        
        switch on actionType {
            when Funded, Repaid {
                recordTypeValue = actionType.name().substring(0, 1);
            	return actionType.name();
            }
            
            when else {
                recordTypeValue = '0';
                return null;
            }
        }
    }
    
    private Tax_Invoice__c setInvoiceDetails(Id recordTypeId, String transactionType) {
        Tax_Invoice__c newInvoice = new Tax_Invoice__c();
        newInvoice.Allocation__c = allocation == null ? null : allocation.Id;
        newInvoice.Invoice__c = invoiceFinanceDeal.Id;
        newInvoice.Customer__c = customerAccountId;
        newInvoice.RecordTypeId = recordTypeId;
        newInvoice.Transaction_Type__c = transactionType;
        newInvoice.Tax_Rate_Percentage__c = taxRate;
        newInvoice.Exchange_Rate__c = InvoiceUtil.SGD.equalsIgnoreCase(invoiceFinanceDeal.CCY__c) ? 1.00000000 : getLatestFXRate();
        newInvoice.Invoice_Reference_Number__c = generateInvoiceRefNum();
        
		if (isEarlyPayment) {
			setPrepaymentDetails(newInvoice);
		}
        
        return newInvoice;
    }
    
    private Decimal getLatestFXRate() {
        Decimal usDollarToSGD = [select reverse_rate__c
                				 from FX_Rates__c
                				 where from_currency__c = :InvoiceUtil.SGD
                				 order by date__c desc
                				 nulls last
                				 LIMIT 1].reverse_rate__c;
        
        if (InvoiceUtil.USD.equalsIgnoreCase(invoiceFinanceDeal.CCY__c)) {
            return usDollarToSGD;
        } else {
            Decimal ccyToSGD = [select reverse_rate__c
                				from FX_Rates__c
                				where from_currency__c = :invoiceFinanceDeal.CCY__c
                				order by date__c desc
                				nulls last
                				LIMIT 1].reverse_rate__c;
            
            return (usDollarToSGD / ccyToSGD).setScale(8, System.roundingMode.HALF_UP);
        }
    }
    
    private String generateInvoiceRefNum() {
        return invoiceFinanceDeal.Name + '-' +
            getCustomerIdLastFourChars() + '-' +
            recordTypeValue + '-' +
            getTotalRecordCount();
    }
    
    private String getCustomerIdLastFourChars() {
        String customerId = String.valueOf(customerAccountId);
        return customerId.substring(customerId.length() - 4);
    }
    
    private String getTotalRecordCount() {
        Integer totalRecords = [select COUNT()
                                from Tax_Invoice__c] + 16094001;
        return String.valueOf(totalRecords);
    }
    
    private void setPrepaymentDetails(Tax_Invoice__c newInvoice) {
        Tax_Invoice__c origInvoice = [select Invoice_Reference_Number__c,
                                             Invoice_Date__c
                                      from Tax_Invoice__c
                                      where Invoice__c = :invoiceFinanceDeal.Id
                                      and Invoice_Reference_Number__c like :InvoiceUtil.ORIGINAL_INVOICE_RECORD_TYPE
                                      order by CreatedBy.CreatedDate desc
                                      nulls last
                                      LIMIT 1];
        newInvoice.Original_Invoice_Number__c = origInvoice.Invoice_Reference_Number__c;
        newInvoice.Original_Invoice_Date__c = origInvoice.Invoice_Date__c;
    }
    
    private List<Tax_Invoice_Fee_Breakdown__c> setInvoiceFeeDetails(Tax_Invoice__c newInvoice) {
        List<Tax_Invoice_Fee_Breakdown__c> invoiceFeesList = new List<Tax_Invoice_Fee_Breakdown__c>();
        Decimal gstAmount = 0.00;
        Decimal totalAmountExclGST = 0.00;
        Decimal totalAmountExclGSTNoTax = 0.00;
        
        for (InvoiceUtil.Description key : amountExclGSTMap.keySet()) {
            totalAmountExclGST = addTaxEligibleAmountsToInvoiceFeeList(key, totalAmountExclGST, invoiceFeesList);
        }
        
        if (taxRate > 0.00) {
            gstAmount = calculateGSTAmount(totalAmountExclGST);
        }
        
        if (null != amountNoTaxMap && !amountNoTaxMap.isEmpty()) {
            for (InvoiceUtil.Description key : amountNoTaxMap.keySet()) {
                totalAmountExclGSTNoTax = addNonTaxableAmountsToInvoiceFeeList(key, totalAmountExclGSTNoTax, invoiceFeesList);
            }
        }
        
        newInvoice.Invoice_Amount__c = totalAmountExclGST;
        newInvoice.GST_Amount__c = gstAmount;
        newInvoice.No_Tax_Total_Amount__c = totalAmountExclGSTNoTax;
        newInvoice.Total_Amount__c = totalAmountExclGST + gstAmount + totalAmountExclGSTNoTax;
        
        return invoiceFeesList;
    }
    
    private Decimal addTaxEligibleAmountsToInvoiceFeeList(InvoiceUtil.Description key,
                                                       Decimal totalAmountExclGST,
                                                       List<Tax_Invoice_Fee_Breakdown__c> invoiceFeesList) {
        if (amountExclGSTMap.get(key) != null && amountExclGSTMap.get(key) != 0.00) {
            Tax_Invoice_Fee_Breakdown__c invoiceFees = new Tax_Invoice_Fee_Breakdown__c();
            invoiceFees.Unit_Price__c = amountExclGSTMap.get(key);
            invoiceFees.Description__c = getDescription(key);
            invoiceFeesList.add(invoiceFees);
            
            totalAmountExclGST += invoiceFees.Unit_Price__c;
        }
        
        return totalAmountExclGST;
    }
    
    private Decimal calculateGSTAmount(Decimal amountExclGST) {
        Decimal gstAmount = amountExclGST * taxRate / 100;
        gstAmount.setScale(2, System.roundingMode.HALF_UP);
        
        return gstAmount;
    }
    
    private String getDescription(InvoiceUtil.Description key) {
        switch on key {
            when SUPPLIER_DISCOUNT_AMOUNT {
                return InvoiceUtil.SUPPLIER_DISCOUNT_AMOUNT_DESC;
            }
            
            when ADMIN_FEES {
                return InvoiceUtil.ADMIN_FEES_DESC;
            }
            
            when SUPPLIER_DISCOUNT_AMOUNT_ADJUSTMENT {
                return InvoiceUtil.SUPPLIER_DISCOUNT_AMOUNT_ADJUSTMENT_DESC;
            }
            
            when SUPPLIER_DISCOUNT_AMOUNT_OVERDUE {
                return InvoiceUtil.SUPPLIER_DISCOUNT_AMOUNT_OVERDUE_DESC;
            }
            
            when FUNDER_PROFIT_SHARE {
                return InvoiceUtil.FUNDER_PROFIT_SHARE_DESC;
            }
            
            when else {
                return '';
            }
        }
    }
    
    private Decimal addNonTaxableAmountsToInvoiceFeeList(InvoiceUtil.Description key,
                                                      Decimal totalAmountExclGSTNoTax,
                                                      List<Tax_Invoice_Fee_Breakdown__c> invoiceFeesList) {
        if (amountNoTaxMap.get(key) != null && amountNoTaxMap.get(key) != 0.00) {
            Tax_Invoice_Fee_Breakdown__c invoiceFees = new Tax_Invoice_Fee_Breakdown__c();
            invoiceFees.Unit_Price__c = amountNoTaxMap.get(key);
            invoiceFees.Description__c = getDescription(key);
            invoiceFeesList.add(invoiceFees);
            
            totalAmountExclGSTNoTax += invoiceFees.Unit_Price__c;
        }
        
        return totalAmountExclGSTNoTax;
    }
}