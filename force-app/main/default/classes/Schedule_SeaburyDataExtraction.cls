//===============================================================================================================
// Part of the Data Extraction process.
// This schedule extracts all data regarding Seabury Data Extraction process.
// 
// Author: Pierre PETESCH
//===============================================================================================================
global class Schedule_SeaburyDataExtraction extends DataQualityManager implements Schedulable
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
    public Schedule_SeaburyDataExtraction()
    {
        super();

        this.Configuration = getConfiguration();
        this.Configuration.FullLogsRecipients = new List<string> {'pierre@incomlend.com'};
        this.Configuration.AlertLogsRecipients = new List<string> {'pierre@incomlend.com'};
    }

    public Schedule_SeaburyDataExtraction(date dateFrom)
    {
        this();

        this.Configuration = getConfiguration(dateFrom);
    }

    public Schedule_SeaburyDataExtraction(date dateFrom, date dateTo)
    {
        this();

        this.Configuration = getConfiguration(dateFrom, dateTo);
    }

    public Schedule_SeaburyDataExtraction(date dateFrom, date dateTo, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
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

        // First step - eWallets
        SeaburyDataExtraction SeaburyExtract = new SeaburyDataExtraction();
        tasks.put(0, SeaburyExtract);

        return tasks;
    }

    private DataQualityManagerConfiguration getConfiguration(date dateFrom, date dateTo, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
    {
        // Configuration object
        DataQualityManagerConfiguration configuration = new DataQualityManagerConfiguration('Seabury Data Extraction', dateFrom, dateTo, getTasks(), sendFullLogs, fullLogsRecipients, alertLogsRecipients);

        return configuration;
    }
    
    private DataQualityManagerConfiguration getConfiguration(date dateFrom, date dateTo)
    {
        // Configuration object
        DataQualityManagerConfiguration configuration = new DataQualityManagerConfiguration('Seabury Data Extraction', dateFrom, dateTo, getTasks());

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