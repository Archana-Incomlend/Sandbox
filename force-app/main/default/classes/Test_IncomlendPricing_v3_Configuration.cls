@isTest
public class Test_IncomlendPricing_v3_Configuration 
{

  @isTest
	public static void runTest() {
    String key = 'key';
    configuration__c config = new configuration__c();
    config.Name = key;
    config.value__c = 'abc';
    insert config;

    IncomlendPricing_v3_Configuration.initCache();
    String str = IncomlendPricing_v3_Configuration.LoadConfigurationKey(key);
    
    List<String> listStr = IncomlendPricing_v3_Configuration.LoadConfigurationKey(key, ';');
    
    config.value__c = 'a=abc;d=def';
    update config;
    IncomlendPricing_v3_Configuration.clearCache();
    Map<String, String> mapStr = IncomlendPricing_v3_Configuration.LoadConfigurationKey(key, ';', '=');

    SeedTest.initConfiguration();
    IncomlendPricing_v3_Configuration.initCache();

    IncomlendPricing_v3_Configuration.NotificationConfiguration notification;
    notification = new IncomlendPricing_v3_Configuration.NotificationConfiguration();
    System.debug(notification.IsHTML);
    System.debug(notification.AlertsSubject);
    System.debug(notification.AlertsRecipients);
    System.debug(notification.AlertsOnErrorOnly);
    System.debug(notification.LogsSubject);
    System.debug(notification.LogsRecipients);
    System.debug(notification.LogsOnErrorOnly);

    IncomlendPricing_v3_Configuration.BehaviourConfiguration behaviour;
    behaviour = new IncomlendPricing_v3_Configuration.BehaviourConfiguration();
    System.debug(behaviour.IsSimulation);
    System.debug(behaviour.FailAtValidation);
    System.debug(behaviour.FailAtNegativeeWallets);
    System.debug(behaviour.FailAtRelatedTransactions);
    System.debug(behaviour.FailAtIncomlendBalance);
    System.debug(behaviour.ApplyEarlyPayment);
    System.debug(behaviour.ApplyOverduePayment);
    System.debug(behaviour.CapEarlyPayment);
    System.debug(behaviour.CapOverduePayment);
    System.debug(behaviour.WebServiceCalloutEndpoint);
    System.debug(behaviour.WebServiceCalloutApiKey);
    System.debug(behaviour.InsuranceCompanies);
    behaviour = new IncomlendPricing_v3_Configuration.BehaviourConfiguration(key);
    System.debug(behaviour.configMap);

  }

  @isTest
  public static void runTestLenient() {
    String key = 'key';
    try {
      String str = IncomlendPricing_v3_Configuration.LoadConfigurationKey(key);
    } catch (Exception ex) {
    }
    try {
      List<String> listStr = IncomlendPricing_v3_Configuration.LoadConfigurationKey(key, ';');
    } catch (Exception ex) {
    }
  }

  @isTest
  public static void runTestError() {
    IncomlendPricing_v3_Configuration.lenient = false;
    runTestLenient();
  }
}