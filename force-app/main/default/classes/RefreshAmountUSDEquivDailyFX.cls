//===============================================================================================================
//This class refreshes the 'Amount USD Equiv daily fx' field of all transactions for a specific:
//- Accounting Period
//- List of currencies
// Author: Pierre PETESCH
//===============================================================================================================
public class RefreshAmountUSDEquivDailyFX
{
    //===========================================================================================================
    // Class Fields
    //===========================================================================================================
    private static DebugHelper field_debug;
    
    //===========================================================================================================
    // Class Methods (external)
    //===========================================================================================================
    public static integer RefreshAccountingPeriod(string accountingPeriodName, List<string> currencies, boolean sendEmailLogs, List<string> recipients)
    {
        field_debug = new DebugHelper(sendEmailLogs, true);
        Validation currentValidation;
        
        Accounting_Period__c accountingPeriod;
        List<FX_Rates__c> fxRates;
        List<Transaction__c> allTransactions;
        List<Transaction__c> skippedTransactions = new List<Transaction__c>();
        List<Transaction__c> processedTransactions = new List<Transaction__c>();
        List<Transaction__c> suspiciousTransactions = new List<Transaction__c>();
        integer allTransactionNumber = 0;
        integer processedTransactionNumber = 0;
        integer skippedTransactionNumber = 0;
        integer suspiciousTransactionNumber = 0;
        integer currentTransactionIndex = 0;
        integer currentSuspiciousTransactionIndex = 0;
        
        try
        {
            field_debug.Debug('RefreshAmountUSDEquivDailyFX.RefreshAccountingPeriod() started', true, false, true);
            field_debug.Debug('');
            field_debug.Debug('Parameters:', true, false, false);
            field_debug.Debug(string.format('- Accounting Period Name: \'\'{0}\'\'', new string[] {accountingPeriodName}), false, false, false);
            field_debug.Debug('- Currencies: \'' + currencies + '\'', false, false, false);
			
            //###################################################################################################
            // Validating the parameters
            //###################################################################################################
            field_debug.Debug('');
            field_debug.Debug('1. Validating the parameters...', true, false, false);
			currentValidation = IsValid(accountingPeriodName, currencies);
            if(!currentValidation.IsValid)
            {
                field_debug.Debug('-> Validation failed', false, false, false);
                throw new RefreshAccountingPeriodException(currentValidation.Details);
            }
            else
                field_debug.Debug('-> Validation succeeded', false, false, false);
            
            //###################################################################################################
            // Searching the relevant Accounting Period
            //###################################################################################################
            field_debug.Debug('');
            field_debug.Debug('2. Searching the relevant Accounting Period...', true, false, false);
            currentValidation = GetAccountingPeriod(accountingPeriodName);
            if(!currentValidation.IsValid)
            {
                field_debug.Debug('-> Search failed', false, false, false);
                throw new RefreshAccountingPeriodException(currentValidation.Details);
            }
            else
            {
                field_debug.Debug('-> Search succeeded:', false, false, false);
                
                accountingPeriod = (Accounting_Period__c)currentValidation.Result;
                
                field_debug.Debug('Accounting Period found:', false, true, true);
                field_debug.Debug(string.format('- ID: \'\'{0}\'\'', new string[] {accountingPeriod.ID}), false, true, false);
                field_debug.Debug(string.format('- Name: \'\'{0}\'\'', new string[] {accountingPeriod.Name}), false, true, false);
                field_debug.Debug(string.format('- Start Date: \'\'{0}\'\'', new string[] {string.valueof(accountingPeriod.Start_Date__c)}), false, true, false);
                field_debug.Debug(string.format('- End Date: \'\'{0}\'\'', new string[] {string.valueof(accountingPeriod.End_Date__c)}), false, true, false);
            }
            
            //###################################################################################################
            // Searching the corresponding FX Rates
            //###################################################################################################
            field_debug.Debug('');
            field_debug.Debug('3. Searching the corresponding FX Rates...', true, false, false);
            currentValidation = GetFXRates(accountingPeriod, currencies);
            if(!currentValidation.IsValid)
            {
                field_debug.Debug('-> Search failed', false, false, false);
                throw new RefreshAccountingPeriodException(currentValidation.Details);
            }
            else
            {
                field_debug.Debug('-> Search succeeded:', false, false, false);
                
                fxRates = (List<FX_Rates__c>)currentValidation.Result;
                
                field_debug.Debug(string.format('\'\'{0}\'\' FX Rates found', new string[] {string.valueof(fxRates.size())}), false, true, false);
            }
            
            //###################################################################################################
            // Searching the corresponding Transactions
            //###################################################################################################
            field_debug.Debug('');
            field_debug.Debug('4. Searching the corresponding Transactions...', true, false, false);
            currentValidation = GetTransactions(accountingPeriod, currencies);
            if(!currentValidation.IsValid)
            {
                field_debug.Debug('-> Search failed', false, false, false);
                throw new RefreshAccountingPeriodException(currentValidation.Details);
            }
            else
            {
                field_debug.Debug('-> Search succeeded:', false, false, false);
                
                allTransactions = (List<Transaction__c>)currentValidation.Result;
                allTransactionNumber = allTransactions.size();
                
                field_debug.Debug(string.format('\'\'{0}\'\' Transactions found', new string[] {string.valueof(allTransactionNumber)}), false, true, false);
            }
            
            //###################################################################################################
            // Calculating 'Amount USD Equiv daily fx' amount
            //###################################################################################################
            field_debug.Debug('');
            field_debug.Debug('5. Calculating \'Amount USD Equiv daily fx\' amount...', true, false, false);
            for(Transaction__c currentTransaction : allTransactions)
            {
                field_debug.Debug(string.format('Analysing Transaction (\'\'{0}\'\') {1} of {2}:', new string[] {currentTransaction.Name, string.valueof(currentTransactionIndex + 1), string.valueof(allTransactionNumber)}), false, false, true);
                
                field_debug.Debug(string.format('- ID: \'\'{0}\'\'', new string[] {currentTransaction.ID}), false, true, false);
                field_debug.Debug(string.format('- Posting ID: \'\'{0}\'\'', new string[] {currentTransaction.Name}), false, true, false);
                field_debug.Debug(string.format('- Type: \'\'{0}\'\'', new string[] {currentTransaction.Type__c }), false, true, false);
                field_debug.Debug(string.format('- Currency: \'\'{0}\'\'', new string[] {currentTransaction.CCY__c}), false, true, false);
                field_debug.Debug(string.format('- Effective Date: \'\'{0}\'\'', new string[] {string.valueof(currentTransaction.Effective_Date__c)}), false, true, false);
                field_debug.Debug(string.format('- Amount: \'\'{0}\'\'', new string[] {string.valueof(currentTransaction.Amount__c)}), false, true, false);
                field_debug.Debug(string.format('- Amount USD Equiv: \'\'{0}\'\'', new string[] {string.valueof(currentTransaction.amount_USD_equiv__c)}), false, true, false);
                field_debug.Debug(string.format('- Amount USD Equiv Daily FX: \'\'{0}\'\'', new string[] {string.valueof(currentTransaction.Amount_USD_Equiv_daily_fx__c)}), false, true, false);
				
				//###################################################################################################
				// Validating the transaction
				//###################################################################################################
                currentValidation = IsTransactionValid(currentTransaction);
                if(!currentValidation.IsValid)
                {
                    field_debug.Debug('-> Transaction update rejected', true, false, false);
                    field_debug.Debug('-> Reason:' + currentValidation.Details, false, true, false);
                    
                    //This transaction needs Operations Team review
                    if(currentTransaction.CCY__c != 'USD' && currentTransaction.CCY__c != 'XXX')
                    	suspiciousTransactions.Add(currentTransaction);
                    
                    skippedTransactionNumber++;
                    skippedTransactions.Add(currentTransaction);
                }
				//###################################################################################################
				// Finding the corresponding FX rate to apply
				//###################################################################################################
                else
                {
                    currentValidation = FindFXRate(currentTransaction, fxRates);
                    if(!currentValidation.IsValid)
                    {
                        field_debug.Debug('-> Transaction update rejected', true, false, false);
                        field_debug.Debug('-> Reason:' + currentValidation.Details, false, true, false);
                        
                    	//This transaction needs Operations Team review
                    	if(currentTransaction.CCY__c != 'USD' && currentTransaction.CCY__c != 'XXX')
                        	suspiciousTransactions.Add(currentTransaction);
                        
                        skippedTransactionNumber++;
                        skippedTransactions.Add(currentTransaction);
                    }
                    else
                    {
                        //###########################################################################################
						// Calculating the new Amount_USD_Equiv_daily_fx__c amount
                        //###########################################################################################
                        FX_Rates__c currentFXRate = (FX_Rates__c)currentValidation.Result;
                        decimal oldAmountUSDEquivDailyFX = currentTransaction.Amount_USD_Equiv_daily_fx__c;
                        if(currentTransaction.CCY__c != 'USD')
                            currentTransaction.Amount_USD_Equiv_daily_fx__c = (currentTransaction.Amount__c * currentFXRate.rate__c).setscale(2);
                        else
                            currentTransaction.Amount_USD_Equiv_daily_fx__c = currentTransaction.Amount__c;
						
                		field_debug.Debug(string.format('- (updated) Amount USD Equiv Daily FX: \'\'{0}\'\', FX Rate applied \'\'{1}\'\', \'\'{2}\'\', \'\'{3}\'\': ', new string[] {string.valueof(currentTransaction.Amount_USD_Equiv_daily_fx__c), string.valueof(currentFXRate.date__c), currentFXRate.from_currency__c, string.valueof(currentFXRate.rate__c)}), false, true, false);
                        field_debug.Debug('-> Transaction update accepted', true, false, false);
                        
                        processedTransactionNumber++;
                        processedTransactions.Add(currentTransaction);
                    }
                }
				
                field_debug.Debug('');
                currentTransactionIndex++;
            }
            
            //###################################################################################################
            // Transactions to review by Operations Team
            //###################################################################################################
            field_debug.Debug('');
            field_debug.Debug('6. Please review these suspicious transactions:', true, false, false);
            suspiciousTransactionNumber = suspiciousTransactions.size();
			for(Transaction__c currentSuspiciousTransaction : suspiciousTransactions)
            {
                field_debug.Debug(string.format('Suspicious Transaction (\'\'{0}\'\') {1} of {2}:', new string[] {currentSuspiciousTransaction.Name, string.valueof(currentSuspiciousTransactionIndex + 1), string.valueof(suspiciousTransactionNumber)}), false, false, true);
                
                field_debug.Debug(string.format('- ID: \'\'{0}\'\'', new string[] {currentSuspiciousTransaction.ID}), false, true, false);
                field_debug.Debug(string.format('- Posting ID: \'\'{0}\'\'', new string[] {currentSuspiciousTransaction.Name}), false, true, false);
                field_debug.Debug(string.format('- Type: \'\'{0}\'\'', new string[] {currentSuspiciousTransaction.Type__c }), false, true, false);
                field_debug.Debug(string.format('- Currency: \'\'{0}\'\'', new string[] {currentSuspiciousTransaction.CCY__c}), false, true, false);
                field_debug.Debug(string.format('- Effective Date: \'\'{0}\'\'', new string[] {string.valueof(currentSuspiciousTransaction.Effective_Date__c)}), false, true, false);
                field_debug.Debug(string.format('- Amount: \'\'{0}\'\'', new string[] {string.valueof(currentSuspiciousTransaction.Amount__c)}), false, true, false);
                field_debug.Debug(string.format('- Amount USD Equiv: \'\'{0}\'\'', new string[] {string.valueof(currentSuspiciousTransaction.amount_USD_equiv__c)}), false, true, false);
                field_debug.Debug(string.format('- Amount USD Equiv Daily FX: \'\'{0}\'\'', new string[] {string.valueof(currentSuspiciousTransaction.Amount_USD_Equiv_daily_fx__c)}), false, true, false);
                
                field_debug.Debug('');
                currentSuspiciousTransactionIndex++;
            }
            if(suspiciousTransactionNumber == 0)
                field_debug.Debug('No suspicious transactions detected.', false, false, false);
            
            //###################################################################################################
            // Updating transactions
            //###################################################################################################
            field_debug.Debug('');
            field_debug.Debug('7. Updating relevant transactions...', true, false, false);
            update processedTransactions;
            field_debug.Debug(string.format('-> Results: {0} Transactions, {1} processed and {2} skipped', new string[] {string.valueof(allTransactionNumber), string.valueof(processedTransactionNumber), string.valueof(skippedTransactionNumber)}), false, false, false);
            if(suspiciousTransactionNumber > 0)
            	field_debug.Debug(string.format('-> WARNING: {0} suspicious transactions detected', new string[] {string.valueof(suspiciousTransactionNumber)}), false, false, false);
        }
        catch(RefreshAccountingPeriodException managedException)
        {
            processedTransactionNumber = 0;
            field_debug.Debug(managedException);
        }
        catch(Exception unmanagedException)
        {
            processedTransactionNumber = 0;
            field_debug.Debug(unmanagedException);
        }
        finally
        {
        	field_debug.Debug('');
			field_debug.Debug('RefreshAmountUSDEquivDailyFX.RefreshAccountingPeriod() finished', true, false, true);
        	field_debug.SendLogs(recipients, 'RefreshAmountUSDEquivDailyFX.RefreshAccountingPeriod() - Logs');
        }
        
        return processedTransactionNumber;
    }
	
	//===========================================================================================================
    // Class Methods (internal)
    //===========================================================================================================
    private static Validation IsValid(string accountingPeriodName, List<string> currencies)
    {
        boolean validation = true;
        string details;
        
        if(accountingPeriodName == null || accountingPeriodName.length() != 7)
        {
            details = string.format('Invalid Accounting Period name parameter (\'\'{0}\'\')', new string[] {accountingPeriodName});
            validation = false;
        }
        
        if(currencies == null || currencies.size() == 0)
        {
            details = string.format('Invalid Currency list parameter (\'\'{0}\'\')', new string[] {'NULL or empty'});
            validation = false;
        }
        
        for(string currentCurrency : currencies)
			if(currentCurrency == null || currentCurrency.length() != 3 || currentCurrency == 'XXX')
        	{
                details = string.format('Invalid Currency list parameter (\'\'{0}\'\')', currencies);
                validation = false;
            }
        
        return new Validation(validation, validation, details);
    }
    
	private static Validation IsTransactionValid(Transaction__c currentTransaction)
    {
        boolean validation = true;
        string details;
        
        // If the transaction is XXX currency, it is skipped
        if(currentTransaction.CCY__c == 'XXX')
        {
            details = '\'XXX\' currency';
			validation = false;
        }
        //If the transaction already has a 'Amount_USD_Equiv_daily_fx__c' value, it is skipped
        else if(currentTransaction.Amount_USD_Equiv_daily_fx__c != null && currentTransaction.Amount_USD_Equiv_daily_fx__c != 0)
        {
            details = string.format('\'Amount_USD_Equiv_daily_fx__c\' field already set: \'\'{0}\'\'USD, transaction in \'\'{1}\'\'', new string[] {string.valueof(currentTransaction.Amount_USD_Equiv_daily_fx__c), currentTransaction.CCY__c});
            validation = false;
        }
                
        return new Validation(validation, validation, details);
    }
    
    private static Validation GetAccountingPeriod(string accountingPeriodName)
    {
        boolean validation = true;
        string details;
        
        Accounting_Period__c accountingPeriod;
        List<Accounting_Period__c> accountingPeriods = [SELECT Accounting_Period__c.ID,
                                                        Accounting_Period__c.Name,
                                                        Accounting_Period__c.Start_Date__c,
                                                        Accounting_Period__c.End_Date__c
                                                        FROM Accounting_Period__c
                                                        WHERE Accounting_Period__c.Name = :accountingPeriodName];
        
        if(accountingPeriods == null || accountingPeriods.size() == 0)
        {
        	details = string.format('Accounting Period not found (\'\'{0}\'\')', new string[] {accountingPeriodName});
			validation = false;
        }
        else if(accountingPeriods.size() > 1)
        {
        	details = string.format('More than one Accounting Period found (\'\'{0}\'\')', new string[] {accountingPeriodName});
			validation = false;
        }
        
        return new Validation(validation, accountingPeriods[0], details);
    }
    
    private static Validation GetFXRates(Accounting_Period__c accountingPeriod, List<string> currencies)
    {
        boolean validation = true;
        string details;
        
        List<FX_Rates__c> fxRates = [SELECT FX_Rates__c.ID,
                                     FX_Rates__c.Name,
                                     FX_Rates__c.date__c,
                                     FX_Rates__c.from_currency__c,
                                     FX_Rates__c.to_currency__c,
                                     FX_Rates__c.rate__c,
                                     FX_Rates__c.reverse_rate__c
                                     FROM FX_Rates__c
                                     WHERE FX_Rates__c.date__c >= :accountingPeriod.Start_Date__c
                                     AND FX_Rates__c.date__c <= :accountingPeriod.End_Date__c
                                     AND FX_Rates__c.from_currency__c IN :currencies];
        
        if(fxRates == null || fxRates.size() == 0)
        {
            details = string.format('No FX rates found for this Accounting Period (\'\'{0}\'\', \'\'{1}\'\')', new string[] {accountingPeriod.ID, accountingPeriod.Name});
			validation = false;
        }
        
        return new Validation(validation, fxRates, details);
    }
    
    private static Validation GetTransactions(Accounting_Period__c accountingPeriod, List<string> currencies)
    {
        boolean validation = true;
        string details;
        
        List<Transaction__c> transactions = [SELECT Transaction__c.transaction_ID__c,
                                             Transaction__c.Name,
                                             Transaction__c.Type__c,
                                             Transaction__c.Accounting_Period__c,
                                             Transaction__c.Account__c,
                                             Transaction__c.Amount__c,
                                             Transaction__c.CCY__c,
                                             Transaction__c.Effective_Date__c,
                                             Transaction__c.amount_USD_equiv__c,
                                             Transaction__c.Amount_USD_Equiv_daily_fx__c
                                             FROM Transaction__c
                                             WHERE Transaction__c.Accounting_Period__c = :accountingPeriod.ID
                                             AND Transaction__c.CCY__c IN :currencies];
        
        if(transactions == null || transactions.size() == 0)
        {
            details = string.format('No transactions found for this Accounting Period (\'\'{0}\'\', \'\'{1}\'\')', new string[] {accountingPeriod.ID, accountingPeriod.Name});
			validation = false;
        }
        
        return new Validation(validation, transactions, details);
    }
    
    private static Validation FindFXRate(Transaction__c currentTransaction, List<FX_Rates__c> fxRates)
    {
        string details;
        
        for(FX_Rates__c currentFXRate : fxRates)
            if(currentFXRate.date__c == currentTransaction.Effective_Date__c && currentFXRate.from_currency__c == currentTransaction.CCY__c)
            	return new Validation(true, currentFXRate, details);
        
        details = string.format('No FX Rate found for this Transaction (\'\'{0}\'\', \'\'{1}\'\', \'\'{2}\'\')', new string[] {currentTransaction.Name, string.valueof(currentTransaction.Effective_Date__c), currentTransaction.CCY__c});
        return new Validation(false, null, details);
    }
    
	//===========================================================================================================
    // Class Inner Classes
    //===========================================================================================================
    public class Validation
    {
        private boolean field_isValid;
        private object field_result;
        private string field_details;
        
        public boolean IsValid
        {
            public get
            {
                return field_isValid;
            }
            private set
            {
                field_isValid = value;
            }
        }
        
        public object Result
        {
            public get
            {
                return field_result;
            }
            private set
            {
                field_result = value;
            }
        }
        
        public string Details
        {
            public get
            {
                return field_details;
            }
            private set
            {
                field_details = value;
            }
        }
        
        public Validation(boolean isValid, object result, string details)
        {
            this.IsValid = isValid;
            this.Result = result;
            this.Details = details;
        }
    }

	//===========================================================================================================
    // Class Exceptions
    //===========================================================================================================
    public class RefreshAccountingPeriodException extends Exception {}
}