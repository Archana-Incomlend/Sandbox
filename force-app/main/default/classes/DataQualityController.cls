//===============================================================================================================
// Part of the Data Quality process.
// This class is the base class of all Integrity Quality classes.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public abstract class DataQualityController
{
    //===========================================================================================================
    // Fields
    //===========================================================================================================
    private string field_name;
    private DataQualityRequest field_request;
    private boolean field_isValid;

    //===========================================================================================================
    // Properties
    //===========================================================================================================    
    public string Name
    {
        get {return field_name;}
        protected set {field_name = value;}
    }
    
    protected DataQualityRequest Request
    {
        get {return field_request;}
        set {field_request = value;}
    }
    
    protected boolean IsValid
    {
        get {return field_isValid;}
        set {field_isValid = value;}
    }

    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    protected DataQualityController()
    {
        this.IsValid = true;
    }

    //===========================================================================================================
    // Methods
    //===========================================================================================================
    public abstract DataQualityResponse execute(DataQualityRequest request);
}