//===============================================================================================================
// Part of the Data Quality process.
// This class defines the controlling steps regarding the process of Accounts SalesForce objects.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class AccountsQualityController extends DataQualityController
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private List<Account> field_existingAccounts;
    private Map<Account, string> field_invalidatedAccounts;

    //===========================================================================================================
    // Properties
    //===========================================================================================================
    private List<Account> ExistingAccounts
    {
        get {return field_existingAccounts;}
        set {field_existingAccounts = value;}
    }
    
    private Map<Account, string> InvalidatedAccounts
    {
        get {return field_invalidatedAccounts;}
        set {field_invalidatedAccounts = value;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public AccountsQualityController()
    {
        super();

        this.Name = 'Accounts Quality Controller';
    }

    //===========================================================================================================
    // Methods
    //===========================================================================================================
    public override DataQualityResponse execute(DataQualityRequest request)
    {
        this.Request = request;

        ExistingAccounts = new List<Account>();
        InvalidatedAccounts = new Map<Account, string>();

        loadAccounts();
        controlAccounts();
        
        return new DataQualityResponse(IsValid);
    }

    private void loadAccounts()
    {
        try
        {
            Request.FullLogs.Log('1. Loading existing Account(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            ExistingAccounts = [   SELECT   id,
                                            Name,
                                            Has_eWallet__c,
                                            USD_eWallet_Balance__c,
                                            EUR_eWallet_Balance__c,
                                            SGD_eWallet_Balance__c,
                                            HKD_eWallet_Balance__c
                                    FROM    Account
                                    ORDER BY Account.Name];

            if(ExistingAccounts.size() != 0)
                Request.FullLogs.Log(string.format('{0} existing Account(s).', new string[] {string.valueOf(ExistingAccounts.size())}), 2);
            else
            {
                Request.FullLogs.Log('Warning: No existing Account found.', 2, Helper_Log.Color.Red);
                Request.AlertLogs.Log('Warning: No existing Account found.', 0, Helper_Log.Color.Red);
                this.IsValid = false;
            }
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new AccountsQualityControllerException('Loading of existing Account(s) failed.', unmanagedException);
        }
    }

    private void controlAccounts()
    {
        try
        {
            Request.FullLogs.Log('2. Controlling existing Account(s)', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            for(Account currentAccount : ExistingAccounts)
            {
                // Has eWallet checkbox validation
                decimal totalBalance = math.abs(currentAccount.USD_eWallet_Balance__c + currentAccount.EUR_eWallet_Balance__c + currentAccount.SGD_eWallet_Balance__c + currentAccount.HKD_eWallet_Balance__c);
                
                if(totalBalance == null)
                    totalBalance = 0;

                if(!currentAccount.Has_eWallet__c && totalBalance > 0.1) // Threshold = 0.1
                {
                    InvalidatedAccounts.put(currentAccount, string.format('Has eWallet checkbox is not checked.', new string[] {currentAccount.Name}));

                    this.IsValid = false;
                }
            }

            if(InvalidatedAccounts.size() == 0)
                Request.FullLogs.Log('Existing Account(s) are valid.', 2);
            else
            {
                Request.FullLogs.Log('Warning: One or more Account(s) are invalid.', 2, Helper_Log.Color.Red);
                Request.AlertLogs.Log('Warning: One or more Account(s) are invalid.', 0, Helper_Log.Color.Red);

                List<List<string>> accountTable = new List<List<string>> ();
                
                accountTable.add(new List<string> {'Invalidated Reason', 'Account Id', 'Account Name', 'Account Has eWallet', 'eWallet USD Balance', 'eWallet EUR Balance', 'eWallet SGD Balance', 'eWallet HKD Balance'});
                for(Account currentAccount : InvalidatedAccounts.keySet())
                {
                    accountTable.add(new List<string> { InvalidatedAccounts.get(currentAccount),
                                                        currentAccount.id,
                                                        currentAccount.Name,
                                                        string.valueOf(currentAccount.Has_eWallet__c),
                                                        string.valueOf(currentAccount.USD_eWallet_Balance__c),
                                                        string.valueOf(currentAccount.EUR_eWallet_Balance__c),
                                                        string.valueOf(currentAccount.SGD_eWallet_Balance__c),
                                                        string.valueOf(currentAccount.HKD_eWallet_Balance__c)});
                }
                
                Request.FullLogs.Log(accountTable, string.format('{0} invalidated Account(s)', new string[] {string.valueOf(InvalidatedAccounts.keySet().size())}), true);
                Request.AlertLogs.Log(accountTable, 'Invalidated Account(s)', true);
            }
        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new AccountsQualityControllerException('Controling existing Account(s) failed.', unmanagedException);
        }
    }

    public class AccountsQualityControllerException extends Exception {}
}