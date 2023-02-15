//===============================================================================================================
// Part of the Data Quality process.
// This class is the request object passed to a Data Quality controller.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class DataQualityRequest
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private Helper_Log field_fullLogs;
    private Helper_Log field_alertLogs;
    private date field_dateFrom;
    private date field_dateTo;

    //===========================================================================================================
    // Properties
    //===========================================================================================================
    public Helper_Log FullLogs
    {
        get {return field_fullLogs;}
        set {field_fullLogs = value;}
    }

    public Helper_Log AlertLogs
    {
        get {return field_alertLogs;}
        set {field_alertLogs = value;}
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

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public DataQualityRequest(date dateFrom, date dateTo)
    {
        this.DateFrom = dateFrom;
        this.DateTo = dateTo;
    }

    public DataQualityRequest(date dateFrom, date dateTo, Helper_Log fullLogs, Helper_Log alertLogs)
    {
        this(dateFrom, dateTo);

        this.FullLogs = fullLogs;
        this.AlertLogs = alertLogs;
    }
}