//===============================================================================================================
// Part of the Data Quality process.
// This class is the entry point of the Data Quality process.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public virtual class DataQualityManager
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private DataQualityManagerConfiguration field_configuration;

    //===========================================================================================================
    // Properties
    //===========================================================================================================
    public DataQualityManagerConfiguration Configuration
    {
        get {return field_configuration;}
        protected set {field_configuration = value;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    protected DataQualityManager()
    {

    }

    public DataQualityManager(DataQualityManagerConfiguration configuration)
    {
        this();

        this.Configuration = configuration;
    }

    //===========================================================================================================
    // Methods
    //===========================================================================================================
    public void execute()
    {
        try
        {
            datetime dateFrom = datetime.newInstance(Configuration.DateFrom.year(), Configuration.DateFrom.month(), Configuration.DateFrom.day());
            datetime dateTo = datetime.newInstance(Configuration.DateTo.year(), Configuration.DateTo.month(), Configuration.DateTo.day());

            for(integer i = 0; i < Configuration.Tasks.size(); i++)
            {
                boolean sendAlerts = false;
                Helper_Log currentFullLogs = new Helper_Log();
                Helper_Log currentAlertLogs = new Helper_Log();

                DataQualityController controller = Configuration.Tasks.get(i);

                try
                {
                    if(controller == null)
                        throw new DataIntegrityManagerException(string.format('There is no task in position {0}. Please review your configuration.', new string[] {string.valueOf(i)}));

                    currentFullLogs.Log(string.format('[{0}] Apex schedule started from {1} to {2}.', new string[] {Configuration.Name, dateFrom.format('YYYY-MM-dd'), dateTo.format('YYYY-MM-dd')}), new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.Blue);
                    currentAlertLogs.Log(string.format('[{0}] Apex schedule started from {1} to {2}.', new string[] {Configuration.Name, dateFrom.format('YYYY-MM-dd'), dateTo.format('YYYY-MM-dd')}), new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.Blue);
                    currentFullLogs.Log(string.format('[{0}] Task has started.', new string[] {controller.Name}), new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.Green);
                    currentAlertLogs.Log(string.format('[{0}] Task has started.', new string[] {controller.Name}), new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.Green);

                    DataQualityRequest request = new DataQualityRequest(Configuration.DateFrom, Configuration.DateTo, currentFullLogs, currentAlertLogs);
                    DataQualityResponse response = controller.execute(request);

                    if(response.IsValid)
                    {
                        currentFullLogs.Log(string.format('[{0}] Task has succeeded.', new string[] {controller.Name}), new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.Green);
                        currentAlertLogs.Log(string.format('[{0}] Task has succeeded.', new string[] {controller.Name}), new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.Green);
                    }
                    else
                    {
                        currentFullLogs.Log(string.format('[{0}] Task has failed.', new string[] {controller.Name}), new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.Red);
                        currentAlertLogs.Log(string.format('[{0}] Task has failed.', new string[] {controller.Name}), new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.Red);
                        sendAlerts = true;
                    }
                }
                catch(Exception unmanagedException)
                {
                    currentFullLogs.Log(unmanagedException);
                    currentAlertLogs.Log(string.format('An error occured (see below) while executing the [{0}] Apex schedule. Please contact your System Administrator.', new string[] {Configuration.Name}), 0, Helper_Log.Color.Red);
                    currentAlertLogs.Log(unmanagedException);

                    sendAlerts = true;
                }
                finally
                {
                    currentFullLogs.Log(string.format('[{0}] Apex schedule finished.', new string[] {Configuration.Name}), new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.Blue);
                    currentAlertLogs.Log(string.format('[{0}] Apex schedule finished.', new string[] {Configuration.Name}), new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.Blue);

                    boolean isHTML = true;
                    string subject;

                    // Send Full logs
                    if(Configuration.SendFullLogs || sendAlerts)
                    {
                        subject = string.format('[{0}] - {1} full logs', new string[] {Configuration.Name, controller.Name});
                        Helper_Email.Send(isHTML, this.Configuration.FullLogsRecipients, subject, currentFullLogs.HTMLLog);
                    }
                    
                    // Send Alert logs
                    if(sendAlerts)
                    {
                        // Send alert logs
                        subject = string.format('[{0}] - {1} alert logs', new string[] {Configuration.Name, controller.Name});
                        currentAlertLogs.Log('For more information on this alert, please contact your System Administrator.', 0, new List<Helper_Log.Style> {Helper_Log.Style.Italic}, Helper_Log.Color.Blue);
                        
                        if(currentAlertLogs.CSVTables.size() > 0)
                            Helper_Email.Send(isHTML, this.Configuration.AlertLogsRecipients, subject, currentAlertLogs.HTMLLog, currentAlertLogs.CSVTables);
                        else
                            Helper_Email.Send(isHTML, this.Configuration.AlertLogsRecipients, subject, currentAlertLogs.HTMLLog);
                    }
                }
            }
        }
        catch(Exception unmanagedException)
        {
            // TODO: What to do in case of error at this stage?
        }
    }

    public class DataIntegrityManagerException extends Exception {}
}