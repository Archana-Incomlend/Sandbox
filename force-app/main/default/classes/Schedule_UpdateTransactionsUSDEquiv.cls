//===============================================================================================================
// Data quality - Update of Transactions 'Amount USD Equiv Daily FX' field.
// This schedule processes an update of Transactions of SalesForce data 'Amount USD Equiv Daily FX' field.
// 
// Author: Pierre PETESCH
//===============================================================================================================
global class Schedule_UpdateTransactionsUSDEquiv extends DataQualityManager implements Schedulable
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private List<string> field_currencies;

    //===========================================================================================================
    // Properties
    //===========================================================================================================
    public List<string> FullLogsRecipients
    {
        get {return this.Configuration.FullLogsRecipients;}
        set {this.Configuration.FullLogsRecipients = value;}
    }

    public List<string> AlertLogsRecipients
    {
        get {return this.Configuration.AlertLogsRecipients;}
        set {this.Configuration.AlertLogsRecipients = value;}
    }

    private List<string> Currencies
    {
        get {return field_currencies;}
        set {field_currencies = value;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public Schedule_UpdateTransactionsUSDEquiv()
    {
        super();

        this.Currencies = new List<string> {'USD', 'EUR', 'SGD', 'HKD', 'GBP'};

        this.Configuration = getConfiguration();
        this.Configuration.FullLogsRecipients = new List<string> {'pierre@incomlend.com'};
        this.Configuration.AlertLogsRecipients = new List<string> {'operations@incomlend.com', 'pierre@incomlend.com'};
    }

    public Schedule_UpdateTransactionsUSDEquiv(date dateFrom)
    {
        this();

        this.Configuration = getConfiguration(dateFrom);
    }

    public Schedule_UpdateTransactionsUSDEquiv(date dateFrom, date dateTo)
    {
        this();

        this.Configuration = getConfiguration(dateFrom, dateTo);
    }

    public Schedule_UpdateTransactionsUSDEquiv(date dateFrom, date dateTo, List<string> currencies)
    {
        this();

        this.Currencies = currencies;

        this.Configuration = getConfiguration(dateFrom, dateTo);
    }

    public Schedule_UpdateTransactionsUSDEquiv(date dateFrom, date dateTo, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
    {
        this();

        this.Configuration = getConfiguration(dateFrom, dateTo, sendFullLogs, fullLogsRecipients, alertLogsRecipients);
    }

    public Schedule_UpdateTransactionsUSDEquiv(date dateFrom, date dateTo, List<string> currencies, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
    {
        this();

        this.Currencies = currencies;

        this.Configuration = getConfiguration(dateFrom, dateTo, sendFullLogs, fullLogsRecipients, alertLogsRecipients);
    }

	//===========================================================================================================
    // Methods
    //===========================================================================================================
    private Map<integer, DataQualityController> getTasks()
    {        
        Map<integer, DataQualityController> tasks = new Map<integer, DataQualityController>();

        // First step - Amount USD Equiv Daily FX
        UpdateTransactionsUSDEquiv updateTransactionsUSDEquiv = new UpdateTransactionsUSDEquiv(this.Currencies);
        tasks.put(0, updateTransactionsUSDEquiv);

        return tasks;
    }

    private DataQualityManagerConfiguration getConfiguration(date dateFrom, date dateTo, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
    {
        // Configuration object
        DataQualityManagerConfiguration configuration = new DataQualityManagerConfiguration('Update of Transactions \'Amount USD Equiv Daily FX\' field', dateFrom, dateTo, getTasks(), sendFullLogs, fullLogsRecipients, alertLogsRecipients);

        return configuration;
    }

    private DataQualityManagerConfiguration getConfiguration(date dateFrom, date dateTo)
    {
        // Configuration object
        DataQualityManagerConfiguration configuration = new DataQualityManagerConfiguration('Update of Transactions \'Amount USD Equiv Daily FX\' field', dateFrom, dateTo, getTasks());

        return configuration;
    }
    
    private DataQualityManagerConfiguration getConfiguration(date dateFrom)
    {
        return getConfiguration(dateFrom, dateFrom);
    }

    private DataQualityManagerConfiguration getConfiguration()
    {
        // Default run date is yesterday.
        // 
        // OpenExchangeRates documentation:
        // Thus, if your server is in the UTC+2 timezone, the previous day's historical file would become available at 02:00 in your timezone, etc.
        // 
        // Close date is 8AM for Singapore, the schedule must therefore run at >8AM to download yesterday rates.
        datetime yesterday = system.today().addDays(-1);
        date dateFrom = date.newInstance(yesterday.year(), yesterday.month(), yesterday.day());

        return getConfiguration(dateFrom);
    }

    global void execute(SchedulableContext schedulableContext)
    {
        execute();
    }
}