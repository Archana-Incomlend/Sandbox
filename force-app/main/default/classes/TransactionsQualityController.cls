//===============================================================================================================
// Part of the Data Quality process.
// This class defines the controlling steps regarding the process of Transactions SalesForce objects.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class TransactionsQualityController extends DataQualityController
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private List<Transaction__c> field_existingTransactions;
    private List<FX_Rates__c> field_existingFXRates;
    private Map<Transaction__c, FX_Rates__c> field_existingTransactionFXRates;
    private Map<Transaction__c, string> field_invalidatedTransactions;

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
    
    private Map<Transaction__c, string> InvalidatedTransactions
    {
        get {return field_invalidatedTransactions;}
        set {field_invalidatedTransactions = value;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public TransactionsQualityController()
    {
        super();

        this.Name = 'Transactions Quality Controller';
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
        InvalidatedTransactions = new Map<Transaction__c, string>();

        loadTransactions();
        loadFXRates();
        controlTransactions();
        
        return new DataQualityResponse(IsValid);
    }

    private void loadTransactions()
    {
        try
        {
            Request.FullLogs.Log('1. Loading existing Transaction(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            ExistingTransactions = [    SELECT  id,
                                                Name,
                                                type__c,
                                                status__c,
                                                Effective_Date__c,
                                                Amount__c,
                                                Amount_USD_Equiv_daily_fx__c,
                                                CCY__c,
                                                Related_Transaction__c,
                                                Related_Transaction__r.Amount__c,
                                                Related_Transaction__r.CCY__c,
                                                Related_Transaction__r.status__c
                                        FROM    Transaction__c
                                        WHERE   Effective_Date__c >= :this.Request.DateFrom
                                        AND     Effective_Date__c <= :this.Request.DateTo
                                        AND     CCY__c <> 'XXX'
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
            throw new TransactionsQualityControllerException('Loading of existing Transaction(s) failed.', unmanagedException);
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
            throw new TransactionsQualityControllerException('Loading of existing Transaction FX Rate(s) failed.', unmanagedException);
        }
    }

    private void controlTransactions()
    {
        try
        {
            Request.FullLogs.Log('3. Controlling existing Transaction(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

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

            for(Transaction__c currentTransaction : ExistingTransactions)
            {
                if(currentTransaction.status__c <> 'Cancelled')
                {
                    // Related Transaction validation
                    List<string> transactionTypesWithNoRelevantTransactions = new List<string>
                    {
                        /*'01.Invoice Purchase',
                        '02.Invoice Advance Amount',
                        '03.Invoice Repayment',
                        '031.Partial Payment Topup',
                        '04.Invoice Capital Repayment',
                        '05.Invoice Discount Amount',
                        '051.Agent Commission on Discount Amount',
                        '052.discount amount fees',
                        '053.Master Agent Commission on Discount Amount',
                        '06.Transaction Fee',
                        '061.Agent Commission on Transaction Fee',
                        '07.Credit Insurance',
                        '08.Invoice Balance Payment',*/
                        '70.Deposit',
                        '80.Withdrawal',
                        /*'88.Annual membership fee',
                        '888.Additional buyer onboarding fee',*/
                        '90.Bank Fees'/*,
                        '99.Adjustment'*/
                    };

                    List<string> statusesToIgnore = new List<string>
                    {
                        'Confirmed by operations',
                        'Confirmed by Finance'
                    };

                    if(currentTransaction.Related_Transaction__c == null
                        && !transactionTypesWithNoRelevantTransactions.contains(currentTransaction.type__c))
                    {
                        InvalidatedTransactions.put(currentTransaction, 'The transaction has no related transaction');

                        this.IsValid = false;
                    }
                    else if(currentTransaction.Related_Transaction__c != null)
                    {
                        // Related Transaction Amount
                        if(currentTransaction.Amount__c <> (currentTransaction.Related_Transaction__r.Amount__c * -1)) // If both amounts don't match
                        {
                            if(currentTransaction.type__c != '90.Bank Fees' || currentTransaction.CCY__c != 'SGD' || currentTransaction.Amount__c != -0.5) // If it's not a Bank Fees transaction
                            {
                                InvalidatedTransactions.put(currentTransaction, string.format('Related transaction amount is inconsistant ({0} / {1})', new string[] {string.valueOf(currentTransaction.Amount__c), string.valueOf(currentTransaction.Related_Transaction__r.Amount__c)}));

                                this.IsValid = false;
                            }
                        }
                        // Related Transaction Status
                        else if(currentTransaction.status__c <> currentTransaction.Related_Transaction__r.status__c)
                        {
                            if(!statusesToIgnore.contains(currentTransaction.status__c) || !statusesToIgnore.contains(currentTransaction.Related_Transaction__r.status__c)) // If it's not 'Confirmed by operations' versus 'Confirmed by Finance' (or the opposite)
                            {
                                InvalidatedTransactions.put(currentTransaction, string.format('Related transaction status is inconsistant ({0} / {1})', new string[] {string.valueOf(currentTransaction.status__c), string.valueOf(currentTransaction.Related_Transaction__r.status__c)}));

                                this.IsValid = false;
                            }
                        }
                        // Related Transaction Currency
                        else if(currentTransaction.CCY__c <> currentTransaction.Related_Transaction__r.CCY__c)
                        {
                            InvalidatedTransactions.put(currentTransaction, string.format('Related transaction status is inconsistant ({0} / {1})', new string[] {string.valueOf(currentTransaction.CCY__c), string.valueOf(currentTransaction.Related_Transaction__r.CCY__c)}));

                            this.IsValid = false;
                        }
                    }

                    // Amount USD Equiv Daily FX validation
                    if(currentTransaction.Amount_USD_Equiv_daily_fx__c == null)
                    {
                        InvalidatedTransactions.put(currentTransaction, 'Amount USD Equiv Daily FX is empty');

                        this.IsValid = false;
                    }
                    else if(currentTransaction.CCY__c == 'USD' &&
                            currentTransaction.Amount__c != currentTransaction.Amount_USD_Equiv_daily_fx__c)
                    {
                        InvalidatedTransactions.put(currentTransaction, 'Amount USD Equiv Daily FX is invalid for this Transaction in USD');

                        this.IsValid = false;
                    }
                    else if(currentTransaction.CCY__c != 'USD')
                    {
                        FX_Rates__c currentFXRate = ExistingTransactionFXRates.get(currentTransaction);

                        if(currentFXRate != null)
                        {
                            decimal correctAmountUSDEquiv = (currentTransaction.Amount__c * currentFXRate.rate__c).setscale(2);

                            if(math.abs(correctAmountUSDEquiv - currentTransaction.Amount_USD_Equiv_daily_fx__c) > 0.099)
                            {
                                InvalidatedTransactions.put(currentTransaction, string.format('Amount USD Equiv Daily FX is invalid (calculated on the fly: {0} USD)', new string[] {string.valueOf(correctAmountUSDEquiv)}));

                                this.IsValid = false;
                            }
                        }
                        else
                        {
                            InvalidatedTransactions.put(currentTransaction, 'No FX Rate available for this Transaction');

                            this.IsValid = false;
                        }
                    }
                }
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
            throw new TransactionsQualityControllerException('Controling existing Transaction(s) failed.', unmanagedException);
        }
    }

    public class TransactionsQualityControllerException extends Exception {}
}