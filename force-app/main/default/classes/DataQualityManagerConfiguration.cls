//===============================================================================================================
// Part of the Data Quality process.
// This class contains the configuration of the Data Quality Manager.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class DataQualityManagerConfiguration
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private string field_name;
    private date field_dateFrom;
    private date field_dateTo;
    private Map<integer, DataQualityController> field_tasks;
    private boolean field_sendFullLogs;
    private List<string> field_fullLogsRecipients;
    private List<string> field_alertLogsRecipients;

    //===========================================================================================================
    // Properties
    //===========================================================================================================
    public string Name
    {
        get {return field_name;}
        protected set {field_name = value;}
    }

    public date DateFrom
    {
        get {return field_dateFrom;}
        protected set {field_dateFrom = value;}
    }

    public date DateTo
    {
        get {return field_dateTo;}
        protected set {field_dateTo = value;}
    }

    public Map<integer, DataQualityController> Tasks
    {
        get {return field_tasks;}
        protected set {field_tasks = value;}
    }

    public boolean SendFullLogs
    {
        get { return field_sendFullLogs;}
        protected set { field_sendFullLogs = value;}
    }

    public List<string> FullLogsRecipients
    {
        get
        {
            if(this.IsSandbox || field_fullLogsRecipients.size() == 0)
                return new List<string> {'pierre@incomlend.com'};
            else
                return field_fullLogsRecipients;
        }
        set {field_fullLogsRecipients = value;}
    }

    public List<string> AlertLogsRecipients
    {
        get
        {
            if(this.IsSandbox || field_fullLogsRecipients.size() == 0)
                return new List<string> {'pierre@incomlend.com'};
            else
                return field_alertLogsRecipients;
        }
        set {field_alertLogsRecipients = value;}
    }

    public boolean IsSandbox
    {
        get {return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    private DataQualityManagerConfiguration(string name)
    {
        this.Name = name;
        this.DateFrom =  date.today();
        this.DateTo =  date.today();
        this.Tasks = new Map<integer, DataQualityController>();
        this.SendFullLogs = true;
        this.FullLogsRecipients = new List<string>();
        this.AlertLogsRecipients = new List<string>();
    }
    
    public DataQualityManagerConfiguration(string name, date dateFrom, Map<integer, DataQualityController> tasks)
    {
        this(name);

        this.DateFrom = dateFrom;
        this.DateTo = dateFrom;
        this.Tasks = tasks;
    }

    public DataQualityManagerConfiguration(string name, date dateFrom, date dateTo, Map<integer, DataQualityController> tasks)
    {
        this(name, dateFrom, tasks);

        this.DateTo = dateTo;
    }

    public DataQualityManagerConfiguration(string name, date dateFrom, Map<integer, DataQualityController> tasks, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
    {
        this(name, dateFrom, tasks);

        this.SendFullLogs = sendFullLogs;
        this.FullLogsRecipients = fullLogsRecipients;
        this.AlertLogsRecipients = alertLogsRecipients;
    }

    public DataQualityManagerConfiguration(string name, date dateFrom, date dateTo, Map<integer, DataQualityController> tasks, boolean sendFullLogs, List<string> fullLogsRecipients, List<string> alertLogsRecipients)
    {
        this(name, dateFrom, tasks, sendFullLogs, fullLogsRecipients, alertLogsRecipients);

        this.DateTo = dateTo;
    }
}