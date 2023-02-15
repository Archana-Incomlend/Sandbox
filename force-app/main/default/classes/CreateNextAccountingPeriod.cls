//===============================================================================================================
// Part of the Data Quality process - Creation of the next Accounting Period.
// This class defines the creation steps regarding the creation of the next Accounting Period SalesForce objects.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class CreateNextAccountingPeriod extends DataQualityController
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private List<Accounting_Period__c> field_existingAccountingPeriods;

    //===========================================================================================================
    // Properties
    //===========================================================================================================
    private date NextAccountingPeriod
    {
        get
        {
            if(this.Request.DateTo.month() != 12)
                return date.newInstance(this.Request.DateTo.year(), this.Request.DateTo.month() + 1, 1);
            else
                return date.newInstance(this.Request.DateTo.year() + 1, 1, 1);
        }
    }
    
    private boolean IsNextAccountingPeriodRequired
    {
        get
        {
            return (NextAccountingPeriod.addDays(-7) <= this.Request.DateTo);
        }
    }
    
    private List<Accounting_Period__c> ExistingAccountingPeriods
    {
        get {return field_existingAccountingPeriods;}
        set {field_existingAccountingPeriods = value;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public CreateNextAccountingPeriod()
    {
        super();

        this.Name = 'Creation of the next Accounting Period';
    }

    //===========================================================================================================
    // Methods
    //===========================================================================================================
    public override DataQualityResponse execute(DataQualityRequest request)
    {
        this.Request = request;

        ExistingAccountingPeriods = new List<Accounting_Period__c>();

        createAccountingPeriod();
        
        return new DataQualityResponse(IsValid);
    }
    
    private void createAccountingPeriod()
    {
        try
        {
            Request.FullLogs.Log('1. Checking if the next Accounting Period is required', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

            if(IsNextAccountingPeriodRequired)
            {
                string strNextAccountingPeriod = datetime.newInstance(NextAccountingPeriod.year(), NextAccountingPeriod.month(), NextAccountingPeriod.day()).format('YYYY-MM');

                Request.FullLogs.Log(string.format('Creation of the next Accounting Period {0} is required.', new string[] {strNextAccountingPeriod}), 2);

                Request.FullLogs.Log('2. Checking if the next Accounting Period exists', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

                ExistingAccountingPeriods = [   SELECT  id,
                                                        Name,
                                                        MI__c,
                                                        Status__c,
                                                        Start_Date__c,
                                                        End_Date__c,
                                                        Previous_Accounting_Period__c
                                                FROM    Accounting_Period__c
                                                WHERE   Start_Date__c = :NextAccountingPeriod
                                                ORDER BY Start_Date__c DESC];

                if(ExistingAccountingPeriods.size() != 0)
                    Request.FullLogs.Log('The next Accounting Period already exists.', 2);
                else
                {
                    Request.FullLogs.Log('The next Accounting Period does not exist.', 2);

                    Request.FullLogs.Log('3. Creating the next Accounting Period', 1, new List<Helper_Log.Style> {Helper_Log.Style.Bold}, Helper_Log.Color.LightGreen);

                    // Get the MI object
                    List<MI__c> existingMIs = [ SELECT  id,
                                                        name
                                                FROM    MI__c];
                    
                    MI__c existingMI;
                    if(existingMIs.size() == 1)
                        existingMI = existingMIs[0];
                    else if(existingMIs.size() == 0)
                        throw new CreateNextAccountingPeriodException('No MI reference found.');
                    else
                        throw new CreateNextAccountingPeriodException('More than one MI reference found.');

                    // Get the previous Accounting Period
                    date previousAccountingPeriod = NextAccountingPeriod.addMonths(-1);
                    string previousAccountingPeriodName = previousAccountingPeriod.year() + '-' + ('0' + previousAccountingPeriod.month()).right(2);
                    List<Accounting_Period__c> previousAccountingPeriods = [    SELECT  id
                                                                                FROM    Accounting_Period__c
                                                                                WHERE   name = :previousAccountingPeriodName];

                    if(previousAccountingPeriods.size() == 0)
                        throw new CreateNextAccountingPeriodException('Previous Accounting Period does not exist.');
                    else if(previousAccountingPeriods.size() > 1)
                        throw new CreateNextAccountingPeriodException('Previous Accounting Period is duplicated.');

                    // Create the next Accounting Period
                    Accounting_Period__c newAccountingPeriod = new Accounting_Period__c();
                    newAccountingPeriod.name = NextAccountingPeriod.year() + '-' + ('0' + NextAccountingPeriod.month()).right(2);
                    newAccountingPeriod.Start_Date__c = NextAccountingPeriod;
                    if(NextAccountingPeriod.month() != 12)
                        newAccountingPeriod.End_Date__c = (date.newInstance(NextAccountingPeriod.year(), NextAccountingPeriod.month() + 1, 1)).addDays(-1);
                    else
                        newAccountingPeriod.End_Date__c = (date.newInstance(NextAccountingPeriod.year() + 1, 1, 1)).addDays(-1);
                    newAccountingPeriod.Status__c = 'Open';
                    newAccountingPeriod.MI__c = existingMI.id;
                    newAccountingPeriod.Previous_Accounting_Period__c = previousAccountingPeriods[0].id;

                    insert newAccountingPeriod;

                    Request.FullLogs.Log('Next Accounting Period created.', 2);
                }
            }
            else
                Request.FullLogs.Log('Creation of the next Accounting Period is not required now.', 2);

        }
        catch(Exception unmanagedException)
        {
            this.IsValid = false;
            throw new CreateNextAccountingPeriodException('Creating the next Account Period failed.', unmanagedException);
        }
    }

    public class CreateNextAccountingPeriodException extends Exception {}
}