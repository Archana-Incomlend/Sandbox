trigger configuration_update_setting on configuration__c (after insert, after update) {

  String log = '';
  try {
    for (configuration__c c : Trigger.new) {
      String key = c.Name;
      String value = c.value__c;
      configuration__c oldC = Trigger.isUpdate ? Trigger.oldMap.get(c.Id) : null;
      if (oldC != null && value == oldC.value__c) continue;
      String str = 'key ' + key.replace('_', '') + ' value ' + value;
      if (key.indexOf('Marketplace_Cached') != 0) log += (log==''?'\n':'') + str; else System.debug(str);
    }
  } catch (Exception ex) {
    System.debug(ex);
    log += 'Error occurred ' + ex.getMessage();
  } finally {
    if (!String.isBlank(log)) {
      System.debug(log);
      Helper_Email.Send(true, GlobalTriggerHandler.getEmailToSendException(), 'update configuration', GlobalTriggerHandler.getHtmlBody(log));
    }
  }
}