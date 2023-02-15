//===============================================================================================================
// Part of the Data Quality process.
// This class is the response object returned by a Data Quality controller.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class DataQualityResponse
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private Helper_Log field_fullLogs;
    private Helper_Log field_alertLogs;
    private boolean field_isValid;

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

    public boolean IsValid
    {
        get {return field_isValid;}
        protected set {field_isValid = value;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public DataQualityResponse(boolean isValid)
    {
        this.IsValid = isValid;
    }

    public DataQualityResponse(boolean isValid, Helper_Log fullLogs, Helper_Log alertLogs)
    {
        this(isValid);

        this.FullLogs = fullLogs;
        this.AlertLogs = alertLogs;
    }
}