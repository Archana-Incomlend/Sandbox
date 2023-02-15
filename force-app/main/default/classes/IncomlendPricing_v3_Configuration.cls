public class IncomlendPricing_v3_Configuration 
{

	public static boolean lenient = true;

	public static Map<String, String> cache = new Map<String, String>();
	
	public static Map<String, String> initCache() {
		cache = new Map<String, String>();
		for (configuration__c c : [SELECT name, value__c FROM configuration__c]) {
			cache.put(c.name, c.value__c);
		}
		cache.put(null, lenient ? '' : null);
		return cache;
	}

	public static void clearCache() {
		cache.clear();
	}

	// =======
	// Methods
	// =======
	// This method loads a single configuration value from configurations objects
	public static string LoadConfigurationKey(string key)
	{
		if (cache.isEmpty()) initCache();
		string value = cache.containsKey(key) ? cache.get(key) : config.getConfig(key);
		
		if(value != null && value.length() > 0 && value != 'key not found')
			return value;
		else if (lenient) return '';
		else
			throw new IncomlendPricing_v3_Configuration_Exception('Configuration "' + key + '" does not exist or is empty.');
	}
	
	// This method loads multiple configuration values from configurations objects
	// E.g.: 	Recipients: address1@incomlend.com;address2@incomlend.com
	// 			Separator: ";"
	public static List<string> LoadConfigurationKey(string key, string separator)
	{
		if (cache.isEmpty()) initCache();
		string value = cache.containsKey(key) ? cache.get(key) : config.getConfig(key);
		
		if(value != null && value.length() > 0 && value != 'key not found')
		{
			List<string> result = new List<string>();
			string[] valuesArray;
			
			valuesArray = value.split(separator);
			for(string singleValue : valuesArray)
				result.add(singleValue);
			
			return result;
		}
		else if (lenient) return new List<String>();
		else
			throw new IncomlendPricing_v3_Configuration_Exception('Configuration "' + key + '" does not exist or is empty.');
	}
	
	// This method loads multiple configuration pair values from configurations objects
	// E.g.: 	Recipients: firstKey=xxxxxxxxxx;secondKey=yyyyyyyyyy
	// 			Separator: ";"
	// 			PairSeparator: "="
	public static Map<string, string> LoadConfigurationKey(string key, string separator, string pairSeparator)
	{
		if (cache.isEmpty()) initCache();
		Map<string, string> result = new Map<string, string>();
		List<string> values = LoadConfigurationKey(key, separator);
		
		for(string pair : values)
		{
			string[] valuesArray;
			
			valuesArray = pair.split(pairSeparator);
			if(valuesArray.size() == 2)
				result.put(valuesArray[0], valuesArray[1]);
			else
				throw new IncomlendPricing_v3_Configuration_Exception('Configuration "' + key + '" is invalid as a multiple pair values (value = "' + values + '", separator = "' + separator + '", pair separator = "' + pairSeparator + '").');
		}
		
		return result;
	}
	
	// =======
	// Classes
	// =======
	public class IncomlendPricing_v3_Configuration_Exception extends Exception {}
	
	public class NotificationConfiguration
	{
		// ==========
		// Properties
		// ==========
		public boolean IsHTML
		{
			get
			{
				return true;
			}
		}
		
		public string AlertsSubject
		{
			get;
			private set;
		}
		
		public List<string> AlertsRecipients
		{
			get;
			private set;
		}
		
		public boolean AlertsOnErrorOnly
		{
			get;
			private set;
		}
		
		public string LogsSubject
		{
			get;
			private set;
		}
		
		public List<string> LogsRecipients
		{
			get;
			private set;
		}
		
		public boolean LogsOnErrorOnly
		{
			get;
			private set;
		}
		
		// ============
		// Constructors
		// ============
		public NotificationConfiguration()
		{
			string recipientsValue;
			string[] recipientsArray;
			
			AlertsSubject = LoadConfigurationKey('IncomlendPricing_v3_Notification_AlertsSubject');
			AlertsRecipients = LoadConfigurationKey('IncomlendPricing_v3_Notification_AlertsRecipients', ';');
			AlertsOnErrorOnly = boolean.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Notification_AlertsOnErrorOnly'));
			LogsSubject = LoadConfigurationKey('IncomlendPricing_v3_Notification_LogsSubject');
			LogsRecipients = LoadConfigurationKey('IncomlendPricing_v3_Notification_LogsRecipients', ';');
			LogsOnErrorOnly = boolean.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Notification_LogsOnErrorOnly'));
		}
	}
	
	public class BehaviourConfiguration
	{
		// ==========
		// Properties
		// ==========
		// If true, does not execute any DML changes into Salesforce
		public boolean IsSimulation
		{
			get;
			private set;
		}
		
		// If true, raises an Exception if a validation failed
		public boolean FailAtValidation
		{
			get;
			private set;
		}
		
		// If true, raises an Exception if an eWallet is negative
		public boolean FailAtNegativeeWallets
		{
			get;
			private set;
		}
		
		// If true, raises an Exception if related transactions are inconsistant
		public boolean FailAtRelatedTransactions
		{
			get;
			private set;
		}
        
        // If true, raises an Exception if Incomlend internal account balance is not null
		public boolean FailAtIncomlendBalance
		{
			get;
			private set;
		}
		
		// If true, applies the early payment calculation
		public boolean ApplyEarlyPayment
		{
			get;
			private set;
		}
		
		// If true, applies the overdue payment calculation
		public boolean ApplyOverduePayment
		{
			get;
			private set;
		}
		
		// Maximum number of days applied for early payments
		public integer CapEarlyPayment
		{
			get;
			private set;
		}
		
		// Maximum number of days applied for overdue payments
		public integer CapOverduePayment
		{
			get;
			private set;
		}
		
		// Web service callout endpoint
		public String WebServiceCalloutEndpoint
		{
			get;
			private set;
		}
		
		// Web service callout api key
		public String WebServiceCalloutApiKey
		{
			get;
			private set;
		}
		
		// Maximum number of days applied for overdue payments
		public Map<string, string> InsuranceCompanies
		{
			get;
			private set;
		}

		// Map to get newer configuration variables
		public Map<String, String> configMap {
			get;
			private set;
		}
		
		// ============
		// Constructors
		// ============
		public BehaviourConfiguration()
		{
			IsSimulation = boolean.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Behaviour_IsSimulation'));
			FailAtValidation = boolean.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Behaviour_FailAtValidation'));
			FailAtNegativeeWallets = boolean.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Behaviour_FailAtNegativeeWallets'));
			FailAtRelatedTransactions = boolean.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Behaviour_FailAtRelatedTransactions'));
            FailAtIncomlendBalance = boolean.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Behaviour_FailAtIncomlendBalance'));
			ApplyEarlyPayment = boolean.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Behaviour_ApplyEarlyPayment'));
			ApplyOverduePayment = boolean.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Behaviour_ApplyOverduePayment'));
			CapEarlyPayment = integer.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Behaviour_CapEarlyPayment'));
			CapOverduePayment = integer.valueOf(LoadConfigurationKey('IncomlendPricing_v3_Behaviour_CapOverduePayment'));
			WebServiceCalloutEndpoint = LoadConfigurationKey('IncomlendPricing_v3_Behaviour_WebServiceCallout_Endpoint');
			WebServiceCalloutApiKey = LoadConfigurationKey('IncomlendPricing_v3_Behaviour_WebServiceCallout_ApiKey');
			
			// Due to configuration value size limitation in Salesforce, this setting is combined
			Map<string, string> companies1 = LoadConfigurationKey('IncomlendPricing_v3_Behaviour_InsuranceCompanies1', ';', '=');
			Map<string, string> companies2 = LoadConfigurationKey('IncomlendPricing_v3_Behaviour_InsuranceCompanies2', ';', '=');
			Map<string, string> companies3 = LoadConfigurationKey('IncomlendPricing_v3_Behaviour_InsuranceCompanies3', ';', '=');
			for(string key : companies2.keySet())
				companies1.put(key, companies2.get(key));
			for(string key : companies3.keySet())
				companies1.put(key, companies3.get(key));
			InsuranceCompanies = companies1;
		}

		public BehaviourConfiguration(String key) {
			configMap = new Map<String, String>();
			configMap.put(key, LoadConfigurationKey(key));
		}
	}
}