//===============================================================================================================
// Part of the Data Quality process.
// This class defines the controlling steps regarding the process of eWallets SalesForce objects.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class eWalletsQualityController extends DataQualityController
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private List<eWallet__c> field_existingeWallets;
    private Map<eWallet__c, List<Transaction__c>> field_existingeWalletTransactions;
    private Map<eWallet__c, string> field_invalidatedeWallets;

    //===========================================================================================================
    // Properties
    //===========================================================================================================
    private List<eWallet__c> ExistingeWallets
    {
        get {return field_existingeWallets;}
        set {field_existingeWallets = value;}
    }

    private Map<eWallet__c, List<Transaction__c>> ExistingeWalletTransactions
    {
        get {return field_existingeWalletTransactions;}
        set {field_existingeWalletTransactions = value;}
    }
    
    private Map<eWallet__c, string> InvalidatedeWallets
    {
        get {return field_invalidatedeWallets;}
        set {field_invalidatedeWallets = value;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public eWalletsQualityController()
    {
        super();

        this.Name = 'eWallets Quality Controller';
    }

    //===========================================================================================================
    // Methods
    //===========================================================================================================
    public override DataQualityResponse execute(DataQualityRequest request)
    {
        this.Request = request;

        ExistingeWallets = new List<eWallet__c>();
        ExistingeWalletTransactions = new Map<eWallet__c, List<Transaction__c>>();
        InvalidatedeWallets = new Map<eWallet__c, string>();

        loadeWallets();
        loadeWalletTransactions();
        controleWallets();
        
        return new DataQualityResponse(IsValid);
    }

    private void loadeWallets()
    {
        try
        {
            Request.FullLogs.Log('1. Loading existing eWallet(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            ExistingeWallets = [   SELECT   id,
                                            Name,
                                            Account__c,
                                            Account__r.Name,
                                            CCY__c,
                                            In_Progress__c
                                    FROM    eWallet__c
                                    WHERE   CCY__c <> 'XXX'
                                    ORDER BY Account__r.Name, CCY__c];

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
            throw new eWalletsQualityControllerException('Loading of existing eWallet(s) failed.', unmanagedException);
        }
    }

    private void loadeWalletTransactions()
    {
        try
        {
            Request.FullLogs.Log('2. Loading existing eWallet Transaction(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);
            
            Map<id, eWallet__c> eWallets = (new Map<Id, eWallet__c>(ExistingeWallets));
            Set<id> eWalletIds = eWallets.keySet();

            List<Transaction__c> existingTransactions = [   SELECT  id,
                                                                    Name,
                                                                    type__c,
                                                                    status__c,
                                                                    Effective_Date__c,
                                                                    Amount__c,
                                                                    CCY__c,
                                                                    invoice_finance_deal__c,
                                                                    invoice_finance_deal__r.Name,
                                                                    invoice_finance_deal__r.phase__c,
                                                                    eWallet__c
                                                            FROM    Transaction__c
                                                            WHERE   isDeleted = false
                                                            AND     eWallet__c IN :eWalletIds
                                                            ORDER BY eWallet__c, Effective_Date__c];
            
            for(Transaction__c currentTransaction : existingTransactions)
            {
                eWallet__c relatedeWallet = eWallets.get(currentTransaction.eWallet__c);
                
                if(relatedeWallet != null)
                {
                    if(ExistingeWalletTransactions.containsKey(relatedeWallet))
                        ExistingeWalletTransactions.get(relatedeWallet).add(currentTransaction);
                    else
                        ExistingeWalletTransactions.put(relatedeWallet, new List<Transaction__c> {currentTransaction});
                }
                else
                    throw new eWalletsQualityControllerException(string.format('This Transaction (Id: {0}, Posting Id: {1}) has no associated eWallet.', new string[] {currentTransaction.id, currentTransaction.Name}));
            }

            Request.FullLogs.Log(string.format('{0} existing eWallet Transaction(s) found.', new string[] {string.valueOf(existingTransactions.size())}), 2);
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new eWalletsQualityControllerException('Loading of existing eWallet Transaction(s) failed.', unmanagedException);
        }
    }

    private void controleWallets()
    {
        try
        {
            Request.FullLogs.Log('3. Controlling existing eWallet(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            for(eWallet__c currenteWallet : ExistingeWallets)
            {
                // In Progress amount validation
                decimal inProgressCalculation = 0;
                List<Transaction__c> existingTransactions = existingeWalletTransactions.get(currenteWallet);

                if(existingTransactions != null)
                    for(Transaction__c currentTransaction : existingTransactions)
                        if(currentTransaction.invoice_finance_deal__r.phase__c == '3:IN PROGRESS'
                            && currentTransaction.type__c == '01.Invoice Purchase'
                            && currentTransaction.status__c == 'Confirmed by operations')
                            inProgressCalculation = inProgressCalculation + currentTransaction.Amount__c;

                if(currenteWallet.In_Progress__c == null)
                    currenteWallet.In_Progress__c = 0;
                
                if(inProgressCalculation != currenteWallet.In_Progress__c)
                {
                    InvalidatedeWallets.put(currenteWallet, string.format('In Progress amount is incorrect (calculated on the fly: {0} {1})', new string[] {string.valueOf(inProgressCalculation), currenteWallet.CCY__c}));

                    this.IsValid = false;
                }
            }

            if(InvalidatedeWallets.size() == 0)
                Request.FullLogs.Log('Existing eWallet(s) are valid.', 2);
            else
            {
                Request.FullLogs.Log('Warning: One or more eWallet(s) are invalid.', 2, Helper_Log.Color.Red);
                Request.AlertLogs.Log('Warning: One or more eWallet(s) are invalid.', 0, Helper_Log.Color.Red);

                List<List<string>> eWalletTable = new List<List<string>> ();
                List<List<string>> eWalletTransactionTable = new List<List<string>> ();
                
                eWalletTable.add(new List<string> {'Invalidated Reason', 'eWallet Id', 'eWallet Name', 'Account Id', 'Account Name', 'eWallet Currency', 'eWallet In Progress Amount'});
                eWalletTransactionTable.add(new List<string> {'eWallet Id', 'eWallet Name', 'Transaction Id', 'Transaction Name', 'Transaction Type', 'Transaction Status', 'Transaction Effective Date', 'Transaction Amount', 'Transaction Currency', 'Invoice Id', 'Invoice Name', 'Invoice Phase'});
                for(eWallet__c currenteWallet : InvalidatedeWallets.keySet())
                {
                    eWalletTable.add(new List<string> { InvalidatedeWallets.get(currenteWallet),
                                                        currenteWallet.id,
                                                        currenteWallet.Name,
                                                        currenteWallet.Account__c,
                                                        currenteWallet.Account__r.Name,
                                                        currenteWallet.CCY__c,
                                                        string.valueOf(currenteWallet.In_Progress__c)});

                    // TODO: Find a way to annex transactions => Heap size exceeds
                    /*List<Transaction__c> relatedTransactions = ExistingeWalletTransactions.get(currenteWallet);
                    if(relatedTransactions != null)
                        for(Transaction__c currentTransaction : relatedTransactions)
                            eWalletTransactionTable.add(new List<string> {  currenteWallet.id,
                                                                            currenteWallet.Name,
                                                                            currentTransaction.id,
                                                                            currentTransaction.Name,
                                                                            currentTransaction.type__c,
                                                                            currentTransaction.status__c,
                                                                            string.valueOf(currentTransaction.Effective_Date__c),
                                                                            string.valueOf(currentTransaction.Amount__c),
                                                                            currentTransaction.CCY__c,
                                                                            currentTransaction.invoice_finance_deal__c,
                                                                            currentTransaction.invoice_finance_deal__r.Name,
                                                                            currentTransaction.invoice_finance_deal__r.phase__c});*/
                }
                
                Request.FullLogs.Log(eWalletTable, string.format('{0} invalidated eWallet(s)', new string[] {string.valueOf(InvalidatedeWallets.keySet().size())}), true);
                Request.AlertLogs.Log(eWalletTable, 'Invalidated eWallet(s)', true);
                // TODO: Find a way to annex transactions => Heap size exceeds
                //Request.AlertLogs.Log(eWalletTransactionTable, 'Invalidated eWallet Transaction(s)', true);
            }
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new eWalletsQualityControllerException('Controling existing eWallet(s) failed.', unmanagedException);
        }
    }

    public class eWalletsQualityControllerException extends Exception {}
}