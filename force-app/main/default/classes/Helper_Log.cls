//===============================================================================================================
// This class contains helping methods to handle logging operations.
// 
// Author: Pierre PETESCH
//===============================================================================================================
public class Helper_Log
{
    //===========================================================================================================
    // Enum
    //===========================================================================================================
    public enum Style
    {
        Bold,
        Underline,
        Italic
    }
    
    public enum Color
    {
        Black,
        Blue,
        Green,
		Grey,
		LightGreen,
		LightGrey,
		LightRed,
        Red
    }
    
    //===========================================================================================================
    // Fields
    //===========================================================================================================
	private List<LogEntry> field_logEntries;
    private string field_fontFamily;
    private decimal field_fontSize;
    
    //===========================================================================================================
    // Properties
    //===========================================================================================================    
	private List<LogEntry> LogEntries
    {
        get {return field_logEntries;}
        private set {field_logEntries = value;}
    }

    private string FontFamily
    {
        get {return field_fontFamily;}
        private set {field_fontFamily = value;}
    }
    
	private decimal FontSize
    {
        get {return field_fontSize;}
        private set {field_fontSize = value;}
    }
    
    public string HTMLFontStyle
    {
        get {return string.format('font-family:{0};font-size:{1}', new string[] {this.FontFamily, string.valueOf(this.FontSize)});}
    }
    
    public string PlainLog
    {
        get {return ToString(false);}
    }
    
    public string HTMLLog
    {
        get {return ToString(true);}
    }
    
    public List<Helper_Email.Attachment> CSVTables
    {
        get
        {
            List<Helper_Email.Attachment> csvTables = new List<Helper_Email.Attachment>();
            
            for(LogEntry entry : this.LogEntries)
            {
                if(entry instanceof Helper_Log.TableEntry)
                {
                    TableEntry table = (TableEntry)entry;
                    string tableName = table.Title;

                    string[] invalidCharacters = new string[] {'<', '>', ':', '"', '/', '\\', '|', '?', '*'};
                    for(string character : invalidCharacters)
                        tableName = tableName.replace(character, '');
                    tableName = tableName + '.csv';

                    Helper_Email.Attachment attachment = new Helper_Email.Attachment(tableName, blob.valueOf(table.toString(false)));
                    csvTables.add(attachment);
                }
            }

            return csvTables;
        }
    }
    
    //===========================================================================================================
    // Constructors
    //===========================================================================================================
    public Helper_Log()
    {
        this.LogEntries = new List<LogEntry>();
        this.FontFamily = 'Arial';
        this.FontSize = 9.5;
    }
    
    public Helper_Log(string fontFamily, decimal fontSize)
    {
        this();

        this.FontFamily = fontFamily;
        this.FontSize = fontSize;
    }
    
    //===========================================================================================================
    // Methods
    //===========================================================================================================
    private void Log(LogEntry entry)
    {
        entry.HTMLFontStyle = this.HTMLFontStyle;
        this.LogEntries.Add(entry);
    }
    
    public void Log(string message)
    {
        Log(new MessageEntry(message));
    }
    
    public void Log(string message, integer indentLevel)
    {
        Log(new MessageEntry(message, indentLevel));
    }
    
    public void Log(string message, List<Style> styles)
    {
        Log(new MessageEntry(message, styles));
    }
    
    public void Log(string message, Color color)
    {
        Log(new MessageEntry(message, color));
    }
    
    public void Log(string message, List<Style> styles, Color color)
    {
        Log(new MessageEntry(message, styles, color));
    }
    
    public void Log(string message, integer indentLevel, List<Style> styles)
    {
        Log(new MessageEntry(message, indentLevel, styles));
    }
    
    public void Log(string message, integer indentLevel, Helper_Log.Color color)
    {
        Log(new MessageEntry(message, indentLevel, color));
    }
    
    public void Log(string message, integer indentLevel, List<Style> styles, Color color)
    {
        Log(new MessageEntry(message, indentLevel, styles, color));
    }
    
    public void Log(Exception raisedException)
    {
        Log(new ExceptionEntry(raisedException));
    }
    
    public void Log(List<List<string>> table)
    {
        Log(new TableEntry(table));
    }
    
    public void Log(List<List<string>> table, string title)
    {
        Log(new TableEntry(table, title));
    }
    
    public void Log(List<List<string>> table, boolean hasHeader)
    {
        Log(new TableEntry(table, hasHeader));
    }
    
    public void Log(List<List<string>> table, string title, boolean hasHeader)
    {
        Log(new TableEntry(table, title, hasHeader));
    }
    
    public void LogLine()
    {
        Log(new LineEntry());
    }
    
    private string ToString(boolean htmlVersion)
    {
        string log = '';

        try
        {
            if(htmlVersion)
                log = log + string.format('<div style="{0}">', new string[] {this.HTMLFontStyle});
            
            for(integer i = 0; i < this.LogEntries.size(); i++)
            {
                integer heapSize = limits.getHeapSize();
                integer heapLimit = limits.getLimitHeapSize();

                log = log + this.LogEntries[i].ToString(htmlVersion);
                
                if(i != (this.LogEntries.size() - 1))
                    log = log + '\n';
            }
            
            if(htmlVersion)
                log = log + '</div>';

            return log;
        }
        catch(Exception unmanagedException)
        {
            string text = 'An error occured while generating the logs:\n\n';
            ExceptionEntry singleEntry = new ExceptionEntry(unmanagedException);

            return log + '\n' + text + singleEntry.ToString(false);
        }
    }
    
    //===========================================================================================================
    // Classes
    //===========================================================================================================
    private abstract class LogEntry
    {
		//=======================================================================================================
    	// Fields
    	//=======================================================================================================
        private datetime field_timestamp = system.now();
        private string field_htmlFontStyle = null;
        
		//=======================================================================================================
    	// Properties
    	//=======================================================================================================
        public datetime Timestamp
        {
            get {return field_timestamp;}
        }

        public string HTMLFontStyle
        {
            get {return field_htmlFontStyle;}
            set {field_htmlFontStyle = value;}
        }
        
        //=======================================================================================================
    	// Methods
    	//=======================================================================================================
        public abstract string ToString(boolean htmlVersion);
    }
    
    private class MessageEntry extends LogEntry
    {
		//=======================================================================================================
    	// Fields
    	//=======================================================================================================
        private string field_message;
    	private integer field_indentLevel;
    	private boolean field_isBold;
    	private boolean field_isUnderline;
    	private boolean field_isItalic;
    	private Color field_color;
        
        //=======================================================================================================
    	// Properties
    	//=======================================================================================================
        private string Message
        {
            get {return field_message;}
            set {field_message = value;}
        }

    	private integer IndentLevel
        {
            get {return field_indentLevel;}
            set {field_indentLevel = value;}
        }

    	private boolean IsBold
        {
            get {return field_isBold;}
            set {field_isBold = value;}
        }

    	private boolean IsUnderline
        {
            get {return field_isUnderline;}
            set {field_isUnderline = value;}
        }

    	private boolean IsItalic
        {
            get {return field_isItalic;}
            set {field_isItalic = value;}
        }

    	private Color Color
        {
            get {return field_color;}
            set {field_color = value;}
        }

        //=======================================================================================================
    	// Constructors
    	//=======================================================================================================
        private MessageEntry()
        {
            this.IndentLevel = 0;
            this.IsBold = false;
            this.IsUnderline = false;
            this.IsItalic = false;
            this.Color = Helper_Log.Color.Black;
        }

        public MessageEntry(string message)
        {
            this();

            this.Message = message;
        }
        
    	public MessageEntry(string message, integer indentLevel)
        {
            this(message);

            if(indentLevel >= 0)
                this.IndentLevel = indentLevel;
            else
                this.IndentLevel = 0;
        }
        
        public MessageEntry(string message, List<Style> styles)
        {
            this(message);

            for(Style currentStyle : styles)
            {
                if(currentStyle == Style.Bold)
                    this.IsBold = true;
                if(currentStyle == Style.Underline)
                    this.IsUnderline = true;
                if(currentStyle == Style.Italic)
                    this.IsItalic = true;
            }
        }
        
        public MessageEntry(string message, Color color)
        {
			this(message);

            this.Color = color;
        }
        
        public MessageEntry(string message, List<Style> styles, Color color)
        {
			this(message, styles);

            this.Color = color;
        }
        
        public MessageEntry(string message, integer indentLevel, List<Style> styles)
        {
			this(message, styles);

            if(indentLevel >= 0)
                this.IndentLevel = indentLevel;
            else
                this.IndentLevel = 0;
        }
        
        public MessageEntry(string message, integer indentLevel, Color color)
        {
            this(message, indentLevel);

			this.Color = color;
        }
        
        public MessageEntry(string message, integer indentLevel, List<Style> styles, Color color)
        {
            this(message, styles, color);
			
            if(indentLevel >= 0)
                this.IndentLevel = indentLevel;
            else
                this.IndentLevel = 0;
        }
        
        //=======================================================================================================
    	// Methods
    	//=======================================================================================================
        public override string ToString(boolean htmlVersion)
        {
            if(this.Message == null || this.Message.length() == 0)
                if(htmlVersion)
                	return '<p></p>';
            	else
                    return '\n';
            
            string log = '';
            
            if(htmlVersion)
            {
                // Styles
                string prefix = '';
				string postfix = '';
                    
                if(this.IsBold)
                {
                    prefix = prefix + '<b>';
                    postfix = '</b>' + postfix;
                }
                if(this.IsUnderline)
                {
                    prefix = prefix + '<u>';
                    postfix = '</u>' + postfix;
                }
                if(this.IsItalic)
                {
                    prefix = prefix + '<i>';
                    postfix = '</i>' + postfix;
                }
                
                // Color
                string color = 'black';
                if(this.Color == Helper_Log.Color.Blue)
                    color = 'blue';
                if(this.Color == Helper_Log.Color.Green)
                    color = 'green';
                if(this.Color == Helper_Log.Color.Grey)
                    color = '#808080';
                if(this.Color == Helper_Log.Color.LightGreen)
                    color = '#00b300';
                if(this.Color == Helper_Log.Color.LightGrey)
                    color = '#f2f2f2';
                if(this.Color == Helper_Log.Color.LightRed)
                    color = '#ffe6e6';
                if(this.Color == Helper_Log.Color.Red)
                    color = 'red';
                
                // Indentation
                string indent = string.valueOf(this.IndentLevel * 20);
                
                // Final log
                log = string.format('<p><span style="color:#bfbfbf ">[{0}] </span><span style="margin-left:{1}px;color:{2}">{3}{4}{5}</span></p>', new string[] {this.Timestamp.format('dd-MM-yyyy HH:mm:ss'), indent, color, prefix, this.Message, postfix});
            }
            else
            {
                // Indentation
                string indent = '';
                for(integer i = 0; i < this.IndentLevel; i++)
                    indent = indent + '  ';
                
                // Final log
                log = string.format('[{0}] {1}{2}', new string[] {this.Timestamp.format('dd-MM-yyyy HH:mm:ss'), indent, this.Message});
            }
            
            return log;
        }
    }
    
    private class ExceptionEntry extends LogEntry
    {
		//=======================================================================================================
    	// Fields
    	//=======================================================================================================
    	private Exception field_raisedException;
        
        //=======================================================================================================
    	// Properties
    	//=======================================================================================================
        private Exception RaisedException
        {
            get {return field_raisedException;}
            set {field_raisedException = value;}
        }

        //=======================================================================================================
    	// Constructors
    	//=======================================================================================================
        public ExceptionEntry(Exception raisedException)
        {
            this.RaisedException = raisedException;
        }
        
        //=======================================================================================================
    	// Methods
    	//=======================================================================================================
		public override string ToString(boolean htmlVersion)
        {
            return ToString(htmlVersion, this.RaisedException, 0);
        }

        private string ToString(boolean htmlVersion, Exception currentException, integer level)
        {
            if(currentException == null)
                return null;
            
            string log = '';
            
            // Inner exception
            Exception innerException = currentException.getCause();
            
            // Stack Trace
            string stackTrace = currentException.getStackTraceString();
            string stackTraceTest = stackTrace.replace('\n', '').replace('(', '').replace(')', '').replace('Caused by', '').replace(' ', '');
            if(stackTraceTest.length() == 0)
                stackTrace = null;
            
            if(htmlVersion)
            {
                if(level == 0)
                    log = log + string.format('<hr><table style="width:100%"><tr><td colspan="2" style="background-color:#ffe6e6;{0}"><font color="red"><b>An error occured</b></font></td></tr>', new string[] {this.HTMLFontStyle});
                else
                    log = log + string.format('<tr><td colspan="2" style="{0}"><font color="red"><i>Inner Exception {1}:</i></font></td></tr>', new string[] {this.HTMLFontStyle, string.valueof(level)});
                
                log = log + string.format('<tr><td style="{0}"><b>Timestamp:</b></td><td style="{0}">{1}</td></tr>', new string[] {this.HTMLFontStyle, this.Timestamp.format('dd-MM-yyyy HH:mm:ss')});
                log = log + string.format('<tr><td style="{0}"><b>Type:</b></td><td style="{0}">{1}</td></tr>', new string[] {this.HTMLFontStyle, currentException.getTypeName()});
                log = log + string.format('<tr><td style="{0}"><b>Message:</b></td><td style="{0}">{1}</td></tr>', new string[] {this.HTMLFontStyle, currentException.getMessage()});
                log = log + string.format('<tr><td style="{0}"><b>Line Number:</b></td><td style="{0}">{1}</td></tr>', new string[] {this.HTMLFontStyle, string.valueof(currentException.getLineNumber())});
                if(stackTrace != null)
                	log = log + string.format('<tr><td style="{0}"><b>Stack Trace:</b></td><td style="{0}">{1}</td></tr>', new string[] {this.HTMLFontStyle, stackTrace});
                else
                    log = log + string.format('<tr><td style="{0}"><b>Stack Trace:</b></td><td style="{0}">/</td></tr>', new string[] {this.HTMLFontStyle});
                if(innerException != null)
                	log = log + string.format('<tr><td style="{0}"><b>Inner Exception:</b></td><td style="{0}">{1}</td></tr>', new string[] {this.HTMLFontStyle, innerException.getTypeName()});
                else
                    log = log + string.format('<tr><td style="{0}"><b>Inner Exception:</b></td><td style="{0}">/</td></tr>', new string[] {this.HTMLFontStyle});
                
                //Recursive call in case of inner exception
				if(innerException != null)
                	log = log + string.format('<tr><td style="{0}"></td></tr>', new string[] {this.HTMLFontStyle}) + ToString(htmlVersion, innerException, level + 1);
                
                if(level == 0)
                	log = log + '</table><hr>';
            }
            else
            {
                if(level == 0)
                {
                    log = log + '****************************************************************************************************************\n';
                    log = log + 'An error occured\n';
                    log = log + '****************************************************************************************************************\n';
                }
                else
                    log = log + string.format('\nInner Exception {0}:\n', new string[] {string.valueof(level)});
                
                log = log + string.format('Timestamp: \'\'{0}\'\'\n', new string[] {this.Timestamp.format('dd-MM-yyyy HH:mm:ss')});
                log = log + string.format('Type: \'\'{0}\'\'\n', new string[] {currentException.getTypeName()});
                log = log + string.format('Message: \'\'{0}\'\'\n', new string[] {currentException.getMessage()});
                log = log + string.format('Line Number: \'\'{0}\'\'\n', new string[] {string.valueof(currentException.getLineNumber())});
                if(stackTrace != null)
                	log = log + string.format('Stack Trace: \'\'{0}\'\'\n', new string[] {stackTrace});
                else
                	log = log + 'Stack Trace: /\n';
                if(innerException != null)
                	log = log + string.format('Inner Exception: \'\'{0}\'\'\n', new string[] {innerException.getTypeName()});
                else
                	log = log + 'Inner Exception: /\n';
                
                //Recursive call in case of inner exception
				if(innerException != null)
                	log = log + ToString(htmlVersion, innerException, level + 1);
                
                if(level == 0)
                	log = log + '****************************************************************************************************************';
            }
            
            return log;
        }
    }
    
	private class TableEntry extends LogEntry
    {
		//=======================================================================================================
    	// Fields
    	//=======================================================================================================
    	private List<List<string>> field_table;
        private string field_title;
        private boolean field_hasHeader;
        
        //=======================================================================================================
    	// Properties
    	//=======================================================================================================
        private List<List<string>> Table
        {
            get {return field_table;}
            set {field_table = value;}
        }

        private string Title
        {
            get {return field_title;}
            set {field_title = value;}
        }

        private boolean HasHeader
        {
            get {return field_hasHeader;}
            set {field_hasHeader = value;}
        }

        //=======================================================================================================
    	// Constructors
    	//=======================================================================================================
        public TableEntry(List<List<string>> table)
        {
            this.Table = table;
            this.HasHeader = false;
        }
        
        public TableEntry(List<List<string>> table, string title)
        {
            this(table);

            if(title != null && title.length() > 0)
                this.Title = title;
        }
        
        public TableEntry(List<List<string>> table, boolean hasHeader)
        {
            this(table, '');

            this.HasHeader = hasHeader;
        }
        
        public TableEntry(List<List<string>> table, string title, boolean hasHeader)
        {
            this(table, title);

            this.HasHeader = hasHeader;
        }
        
        //=======================================================================================================
    	// Methods
    	//=======================================================================================================
        public override string ToString(boolean htmlVersion)
        {
            if(this.Table == null)
                return null;
            
            string log = '';
            
            if(htmlVersion)
            {
                log = log + '<hr><table style="width:100%" bgcolor="#f2f2f2">';
                
                // For each lines
                for(integer i = 0; i < this.Table.size(); i++)
                {
                    List<string> currentRow = this.Table[i];
                    
                    if(i == 0 && this.Title != null)
                        log = log + string.format('<tr><td colspan="{0}" style="color:#6666ff;text-align:center;{1}"><i>{2}</i></td></tr>', new string[] {string.valueof(currentRow.size()), this.HTMLFontStyle, this.Title});
                    
                    log = log + '<tr>';
                    
                    // For each columns
                    for(string column : currentRow)
                    {
                        if(i == 0 && this.HasHeader)
                            log = log + string.format('<td style="{0}"><b><u>{1}</u></b></td>', new string[] {this.HTMLFontStyle, column});
                        else
                            log = log + string.format('<td style="{0}">{1}</td>', new string[] {this.HTMLFontStyle, column});
                    }
                    
                    log = log + '</tr>';
                }
                
                log = log + '</table><hr></span></p>';
            }
            else
            {
                //if(this.Title != null)
				//	log = log + '##' + this.Title + '##\n';
                
                integer line = 0;
                // For each lines
                for(List<string> currentRow : this.Table)
                {
                    // For each columns
                    for(integer i = 0; i < currentRow.size(); i++)
                    {
                        if(line == 0 && this.HasHeader)
                            log = log + '[' + currentRow[i] + ']';
                        else
                        	log = log + currentRow[i];
                        if(i < (currentRow.size() - 1))
                            log = log + ';';
                    }
                    log = log + '\n';
                    line++;
                }
            }
            
            return log;
        }
    }
    
    private class LineEntry extends LogEntry
    {
        //=======================================================================================================
    	// Methods
    	//=======================================================================================================
        public override string ToString(boolean htmlVersion)
        {
            if(htmlVersion)
                return '<hr size="5" style="background-color:blue" noshade>';
            else
                return '<-------------------------------------------------------------------------------------------------------------->';
        }
    }
}