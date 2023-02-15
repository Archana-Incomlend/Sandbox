public virtual class Pageable {
    private static final integer DefaultPageSize = 50;

    //Properties
    public integer PageSize {get;set;}
    public integer PageNumber {get;set;}

    public integer PageIndex {
        get { return (PageNumber - 1); }
    }

    public integer RecordCount {
        get { return getRecordCount(); }
    }

    public integer PageCount {
        get { return getPageCount(); }
    }

    public integer Offset {
        get { return (PageSize * PageIndex); }
    }

    public integer LNumber {
        get { return RecordCount == 0 ? 0 : (Offset + 1); }
    }

    public integer UNumber {
        get { 
            integer iUNum = ((LNumber + PageSize) - 1);
            return (iUnum > RecordCount) ? RecordCount : iUNum; 
        }
    }

    public boolean AllowMoveNext {
        get{ return ((PageIndex + 1) < PageCount); }
    }

    public boolean AllowMovePrev {
        get{ return (PageIndex > 0); }
    }

    //Constructors

    public Pageable() {
        PageSize = DefaultPageSize;
        PageNumber = 1;
    }

    //Public Methods

    public virtual integer getRecordCount() {
        return 0;
    }

    public virtual void movePrev() {
        PageNumber--;

        if (PageNumber <= 0) {  
            PageNumber = 1;
        }
    }

    public virtual void moveNext() {
        PageNumber++;

        if (PageNumber > PageCount) {
            PageNumber = PageCount;
        }
    }

    public virtual void moveLast() {
        PageNumber = PageCount; 
    }

    public virtual void moveFirst() {
        PageNumber = 1;
    }

    //Private Methods

    private integer getPageCount() {
        integer iPageCount = 1;

        if (RecordCount != 0 && PageSize != 0) {
            iPageCount = (RecordCount/PageSize) + ((Math.mod(RecordCount, PageSize)) > 0 ? 1 : 0);
        }

        return iPageCount;
    }
}