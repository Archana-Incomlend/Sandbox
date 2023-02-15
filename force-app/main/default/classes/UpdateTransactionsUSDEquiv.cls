//===============================================================================================================
// Part of the Data Quality process - Update of Transactions 'Amount USD Equiv Daily FX' field.
// This class defines the updating steps regarding the 'Amount USD Equiv Daily FX' field of Transactions SalesForce objects.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class UpdateTransactionsUSDEquiv extends DataQualityController
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private List<Transaction__c> field_existingTransactions;
    private List<FX_Rates__c> field_existingFXRates;
    private Map<Transaction__c, FX_Rates__c> field_existingTransactionFXRates;
    private Map<Transaction__c, FX_Rates__c> field_updatedTransactions;
    private Map<Transaction__c, string> field_invalidatedTransactions;
    private List<string> field_currencies;

    //===========================================================================================================
    // Properties
    //===========================================================================================================
    private List<Transaction__c> ExistingTransactions
    {
        get {return field_existingTransactions;}
        set {field_existingTransactions = value;}
    }

    private List<FX_Rates__c> ExistingFXRates
    {
        get {return field_existingFXRates;}
        set {field_existingFXRates = value;}
    }

    private Map<Transaction__c, FX_Rates__c> ExistingTransactionFXRates
    {
        get {return field_existingTransactionFXRates;}
        set {field_existingTransactionFXRates = value;}
    }
    
    private Map<Transaction__c, FX_Rates__c> UpdatedTransactions
    {
        get {return field_updatedTransactions;}
        set {field_updatedTransactions = value;}
    }

    private Map<Transaction__c, string> InvalidatedTransactions
    {
        get {return field_invalidatedTransactions;}
        set {field_invalidatedTransactions = value;}
    }

    private List<string> Currencies
    {
        get {return field_currencies;}
        set {field_currencies = value;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public UpdateTransactionsUSDEquiv(List<string> currencies)
    {
        super();

        this.Name = 'Update of Transactions \'Amount USD Equiv Daily FX\' field';
        this.Currencies = currencies;
    }

    //===========================================================================================================
    // Methods
    //===========================================================================================================
    public override DataQualityResponse execute(DataQualityRequest request)
    {
        this.Request = request;

        ExistingTransactions = new List<Transaction__c>();
        ExistingFXRates = new List<FX_Rates__c>();
        ExistingTransactionFXRates = new Map<Transaction__c, FX_Rates__c>();
        UpdatedTransactions = new Map<Transaction__c, FX_Rates__c>();
        InvalidatedTransactions = new Map<Transaction__c, string>();

        loadTransactions();
        loadFXRates();
        updateTransactions();
        
        return new DataQualityResponse(IsValid);
    }

    private void loadTransactions()
    {
        try
        {
            Request.FullLogs.Log('1. Loading existing Transaction(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);
            
            if(this.Currencies != null || this.Currencies.size() > 0)
                Request.FullLogs.Log(string.format('Requested currencies: {0}', new string[] {string.join(this.Currencies, ',')}), 2);
            else
                throw new UpdateTransactionsUSDEquivException('Currencies list is empty.');

            ExistingTransactions = [    SELECT  id,
                                                Name,
                                                type__c,
                                                status__c,
                                                Effective_Date__c,
                                                Amount__c,
                                                Amount_USD_Equiv_daily_fx__c,
                                                CCY__c
                                        FROM    Transaction__c
                                        WHERE   Effective_Date__c >= :this.Request.DateFrom
                                        AND     Effective_Date__c <= :this.Request.DateTo
                                        AND     CCY__c <> 'XXX'
                                        AND     CCY__c IN :this.Currencies
                                        ORDER BY Effective_Date__c];

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
            throw new UpdateTransactionsUSDEquivException('Loading of existing Transaction(s) failed.', unmanagedException);
        }
    }

    private void loadFXRates()
    {
        try
        {
            Request.FullLogs.Log('2. Loading existing Transaction FX Rate(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            ExistingFXRates = [    SELECT   id,
                                            Name,
                                            from_currency__c,
                                            to_currency__c,
                                            date__c,
                                            rate__c
                                    FROM    FX_Rates__c
                                    WHERE   date__c >= :this.Request.DateFrom
                                    AND     date__c <= :this.Request.DateTo
                                    AND     from_currency__c <> 'XXX'
                                    AND     from_currency__c IN :this.Currencies
                                    ORDER BY date__c, from_currency__c];

            if(ExistingFXRates.size() != 0)
                Request.FullLogs.Log(string.format('{0} existing FX Rate(s).', new string[] {string.valueOf(ExistingFXRates.size())}), 2);
            else
            {
                Request.FullLogs.Log('Warning: No existing FX Rate found.', 2, Helper_Log.Color.Red);
                Request.AlertLogs.Log('Warning: No existing FX Rate found.', 0, Helper_Log.Color.Red);
                this.IsValid = false;
            }
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new UpdateTransactionsUSDEquivException('Loading of existing Transaction FX Rate(s) failed.', unmanagedException);
        }
    }

    private void updateTransactions()
    {
        try
        {
            Request.FullLogs.Log('3. Updating existing Transaction(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            // Associating Transactions and FX Rates
            for(Transaction__c currentTransaction : ExistingTransactions)
            {
                if(currentTransaction.CCY__c != 'USD')
                    for(FX_Rates__c currentRate : ExistingFXRates)
                    {
                        if(currentTransaction.Effective_Date__c == currentRate.date__c
                            && currentTransaction.CCY__c == currentRate.from_currency__c)
                        {
                            ExistingTransactionFXRates.put(currentTransaction, currentRate);
                            break;
                        }
                    }
            }

            // Amount USD Equiv Daily FX validation
            for(Transaction__c currentTransaction : ExistingTransactions)
            {
                if(currentTransaction.Amount_USD_Equiv_daily_fx__c == null || currentTransaction.Amount_USD_Equiv_daily_fx__c == 0)
                {
                    if(currentTransaction.CCY__c != 'USD')
                    {
                        FX_Rates__c currentFXRate = ExistingTransactionFXRates.get(currentTransaction);

                        if(currentFXRate != null)
                        {
                            decimal correctAmountUSDEquiv = (currentTransaction.Amount__c * currentFXRate.rate__c).setscale(2);
                            currentTransaction.Amount_USD_Equiv_daily_fx__c = correctAmountUSDEquiv;
                            UpdatedTransactions.put(currentTransaction, currentFXRate);
                        }
                        else
                        {
                            InvalidatedTransactions.put(currentTransaction, 'No FX Rate available for this Transaction');

                            this.IsValid = false;
                        }
                    }
                    else
                    {
                        currentTransaction.Amount_USD_Equiv_daily_fx__c = currentTransaction.Amount__c;
                        UpdatedTransactions.put(currentTransaction, null);
                    }
                }
            }

            List<Transaction__c> updateList = new List<Transaction__c>();
            updateList.addAll(UpdatedTransactions.keySet());

            if(updateList.size() > 0)
                update updateList;

            if(UpdatedTransactions.size() == 0)
                Request.FullLogs.Log('No updated Transaction(s).', 3);
            else
            {
                List<List<string>> transactionTable = new List<List<string>> ();
                
                transactionTable.add(new List<string> {'Transaction Id', 'Transaction Name', 'Transaction Type', 'Transaction Status', 'Transaction Effective Date', 'Transaction Amount', 'Transaction Currency', 'Transaction Amount USD Equiv Daily FX', 'FX Rate Date', 'FX Rate'});
                for(Transaction__c currentTransaction : UpdatedTransactions.keySet())
                {
                    string fxRateDate = '';
                    string fxRateRate = '';

                    FX_Rates__c currentFXRate = UpdatedTransactions.get(currentTransaction);
                    
                    if(currentFXRate != null)
                    {
                        fxRateDate = string.valueOf(currentFXRate.date__c);
                        fxRateRate = string.valueOf(currentFXRate.rate__c);
                    }

                    transactionTable.add(new List<string> { currentTransaction.id,
                                                            currentTransaction.Name,
                                                            currentTransaction.type__c,
                                                            currentTransaction.status__c,
                                                            string.valueOf(currentTransaction.Effective_Date__c),
                                                            string.valueOf(currentTransaction.Amount__c),
                                                            currentTransaction.CCY__c,
                                                            string.valueOf(currentTransaction.Amount_USD_Equiv_daily_fx__c),
                                                            fxRateDate,
                                                            fxRateRate});
                }

                Request.FullLogs.Log(transactionTable, string.format('{0} updated Transaction(s)', new string[] {string.valueOf(UpdatedTransactions.keySet().size())}), true);
                Request.AlertLogs.Log(transactionTable, 'Invalidated Transaction(s)', true);
            }

            if(InvalidatedTransactions.size() == 0)
                Request.FullLogs.Log('Existing Transaction(s) are valid.', 3);
            else
            {
                Request.FullLogs.Log('Warning: One or more Transaction(s) are invalid.', 3, Helper_Log.Color.Red);
                Request.AlertLogs.Log('Warning: One or more Transaction(s) are invalid.', 0, Helper_Log.Color.Red);

                List<List<string>> transactionTable = new List<List<string>> ();
                
                transactionTable.add(new List<string> {'Invalidated Reason', 'Transaction Id', 'Transaction Name', 'Transaction Type', 'Transaction Status', 'Transaction Effective Date', 'Transaction Amount', 'Transaction Currency', 'Transaction Amount USD Equiv Daily FX', 'FX Rate Date', 'FX Rate'});
                for(Transaction__c currentTransaction : InvalidatedTransactions.keySet())
                {
                    string fxRateDate = '';
                    string fxRateRate = '';

                    FX_Rates__c currentFXRate = ExistingTransactionFXRates.get(currentTransaction);
                    
                    if(currentFXRate != null)
                    {
                        fxRateDate = string.valueOf(currentFXRate.date__c);
                        fxRateRate = string.valueOf(currentFXRate.rate__c);
                    }

                    transactionTable.add(new List<string> { InvalidatedTransactions.get(currentTransaction),
                                                            currentTransaction.id,
                                                            currentTransaction.Name,
                                                            currentTransaction.type__c,
                                                            currentTransaction.status__c,
                                                            string.valueOf(currentTransaction.Effective_Date__c),
                                                            string.valueOf(currentTransaction.Amount__c),
                                                            currentTransaction.CCY__c,
                                                            string.valueOf(currentTransaction.Amount_USD_Equiv_daily_fx__c),
                                                            fxRateDate,
                                                            fxRateRate});
                }

                Request.FullLogs.Log(transactionTable, string.format('{0} invalidated Transaction(s)', new string[] {string.valueOf(InvalidatedTransactions.keySet().size())}), true);
                Request.AlertLogs.Log(transactionTable, 'Invalidated Transaction(s)', true);
            }
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new UpdateTransactionsUSDEquivException('Controling existing Transaction(s) failed.', unmanagedException);
        }
    }

    public class UpdateTransactionsUSDEquivException extends Exception {}
}