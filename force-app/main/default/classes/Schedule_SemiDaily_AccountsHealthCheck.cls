//===============================================================================================================
// Data quality health check.
// This schedule processes a health check of SalesForce data.
// 
// Author: Pierre PETESCH
//===============================================================================================================
global class Schedule_SemiDaily_AccountsHealthCheck extends DataQualityManager implements Schedulable
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
    public Schedule_SemiDaily_AccountsHealthCheck()
    {
        super();

        this.Configuration = getConfiguration();
        this.Configuration.FullLogsRecipients = new List<string> {'pierre@incomlend.com'};
        this.Configuration.AlertLogsRecipients = new List<string> {'operations@incomlend.com', 'pierre@incomlend.com'};
    }

    public Schedule_SemiDaily_AccountsHealthCheck(date dateFrom)
    {
        this();

        this.Configuration = getConfiguration(dateFrom);
    }

    public Schedule_SemiDaily_AccountsHealthCheck(date dateFrom, date dateTo)
    {
        this();

        this.Configuration = getConfiguration(dateFrom, dateTo);
    }

    public Schedule_SemiDaily_AccountsHealthCheck(date dateFrom, date dateTo, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
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

        // First step - Accounts
        AccountsQualityController accountsController = new AccountsQualityController();
        tasks.put(0, accountsController);

        return tasks;
    }

    private DataQualityManagerConfiguration getConfiguration(date dateFrom, date dateTo, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
    {
        // Configuration object
        DataQualityManagerConfiguration configuration = new DataQualityManagerConfiguration('Semi-Daily Accounts Health Check', dateFrom, dateTo, getTasks(), sendFullLogs, fullLogsRecipients, alertLogsRecipients);

        return configuration;
    }
    
    private DataQualityManagerConfiguration getConfiguration(date dateFrom, date dateTo)
    {
        // Configuration object
        DataQualityManagerConfiguration configuration = new DataQualityManagerConfiguration('Semi-Daily Accounts Health Check', dateFrom, dateTo, getTasks());

        return configuration;
    }
    
    private DataQualityManagerConfiguration getConfiguration(date dateFrom)
    {
        return getConfiguration(dateFrom, dateFrom);
    }

    private DataQualityManagerConfiguration getConfiguration()
    {
        datetime today = system.today();
        date dateFrom = date.newInstance(today.year(), today.month(), today.day());

        return getConfiguration(dateFrom);
    }

    global void execute(SchedulableContext schedulableContext)
    {
        execute();
    }
}