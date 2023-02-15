//===============================================================================================================
// Data quality health check.
// This schedule processes a Transactions health check of SalesForce data.
// 
// Author: Pierre PETESCH
//===============================================================================================================
global class Schedule_TransactionsHealthCheck extends DataQualityManager implements Schedulable
{
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

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public Schedule_TransactionsHealthCheck()
    {
        super();

        this.Configuration = getConfiguration();
        this.Configuration.FullLogsRecipients = new List<string> {'pierre@incomlend.com'};
        this.Configuration.AlertLogsRecipients = new List<string> {'operations@incomlend.com', 'michel@incomlend.com', 'pierre@incomlend.com'};
    }

    public Schedule_TransactionsHealthCheck(date dateFrom)
    {
        this();

        this.Configuration = getConfiguration(dateFrom);
    }

    public Schedule_TransactionsHealthCheck(date dateFrom, date dateTo)
    {
        this();

        this.Configuration = getConfiguration(dateFrom, dateTo);
    }

    public Schedule_TransactionsHealthCheck(date dateFrom, date dateTo, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
    {
        this();

        this.Configuration = getConfiguration(dateFrom, dateTo, sendFullLogs, fullLogsRecipients, alertLogsRecipients);
    }

	//===========================================================================================================
    // Methods
    //===========================================================================================================
    private Map<integer, DataQualityController> getTasks()
    {        
        Map<integer, DataQualityController> tasks = new Map<integer, DataQualityController>();

        // First step - Transactions
        TransactionsQualityController transactionsController = new TransactionsQualityController();
        tasks.put(0, transactionsController);

        return tasks;
    }

    private DataQualityManagerConfiguration getConfiguration(date dateFrom, date dateTo, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
    {
        // Configuration object
        DataQualityManagerConfiguration configuration = new DataQualityManagerConfiguration('Transactions Health Check', dateFrom, dateTo, getTasks(), sendFullLogs, fullLogsRecipients, alertLogsRecipients);

        return configuration;
    }

    private DataQualityManagerConfiguration getConfiguration(date dateFrom, date dateTo)
    {
        // Configuration object
        DataQualityManagerConfiguration configuration = new DataQualityManagerConfiguration('Transactions Health Check', dateFrom, dateTo, getTasks());

        return configuration;
    }
    
    private DataQualityManagerConfiguration getConfiguration(date dateFrom)
    {
        return getConfiguration(dateFrom, dateFrom);
    }

    private DataQualityManagerConfiguration getConfiguration()
    {
        // Default run date is day-7 to yesterday (last week).
        // 
        // OpenExchangeRates documentation:
        // Thus, if your server is in the UTC+2 timezone, the previous day's historical file would become available at 02:00 in your timezone, etc.
        // 
        // Close date is 8AM for Singapore, the schedule must therefore run at >8AM to download yesterday rates.
        datetime lastWeek = system.today().addDays(-7);
        datetime yesterday = system.today().addDays(-1);
        date dateFrom = date.newInstance(lastWeek.year(), lastWeek.month(), lastWeek.day());
        date dateTo = date.newInstance(yesterday.year(), yesterday.month(), yesterday.day());

        return getConfiguration(dateFrom, dateTo);
    }

    global void execute(SchedulableContext schedulableContext)
    {
        execute();
    }
}