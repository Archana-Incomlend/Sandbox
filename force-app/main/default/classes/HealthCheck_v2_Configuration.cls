public class HealthCheck_v2_Configuration
{
	// =======
	// Methods
	// =======
	// This method loads a single configuration value from configurations objects
	public static string LoadConfigurationKey(string key)
	{
		string value = config.getConfig(key);
		
		if(value != null && value.length() > 0 && value != 'key not found')
			return value;
		else
			throw new IncomlendPricing_v3_Configuration_Exception('Configuration "' + key + '" does not exist or is empty.');
	}
	
	// This method loads multiple configuration values from configurations objects
	// E.g.: 	Recipients: address1@incomlend.com;address2@incomlend.com
	// 			Separator: ";"
	public static List<string> LoadConfigurationKey(string key, string separator)
	{
		string value = config.getConfig(key);
		
		if(value != null && value.length() > 0 && value != 'key not found')
		{
			List<string> result = new List<string>();
			string[] valuesArray;
			
			valuesArray = value.split(separator);
			for(string singleValue : valuesArray)
				result.add(singleValue);
			
			return result;
		}
		else
			throw new IncomlendPricing_v3_Configuration_Exception('Configuration "' + key + '" does not exist or is empty.');
	}
	
	// This method loads multiple configuration pair values from configurations objects
	// E.g.: 	Recipients: firstKey=xxxxxxxxxx;secondKey=yyyyyyyyyy
	// 			Separator: ";"
	// 			PairSeparator: "="
	public static Map<string, string> LoadConfigurationKey(string key, string separator, string pairSeparator)
	{
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
			
			AlertsSubject = LoadConfigurationKey('HealthCheck_v2_Notification_AlertsSubject');
			AlertsRecipients = LoadConfigurationKey('HealthCheck_v2_Notification_AlertsRecipients', ';');
			AlertsOnErrorOnly = boolean.valueOf(LoadConfigurationKey('HealthCheck_v2_Notification_AlertsOnErrorOnly'));
			LogsSubject = LoadConfigurationKey('HealthCheck_v2_Notification_LogsSubject');
			LogsRecipients = LoadConfigurationKey('HealthCheck_v2_Notification_LogsRecipients', ';');
			LogsOnErrorOnly = boolean.valueOf(LoadConfigurationKey('HealthCheck_v2_Notification_LogsOnErrorOnly'));
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
		
		// ============
		// Constructors
		// ============
		public BehaviourConfiguration()
		{
			IsSimulation = boolean.valueOf(LoadConfigurationKey('HealthCheck_v2_Behaviour_IsSimulation'));
			FailAtValidation = boolean.valueOf(LoadConfigurationKey('HealthCheck_v2_Behaviour_FailAtValidation'));
		}
	}
}