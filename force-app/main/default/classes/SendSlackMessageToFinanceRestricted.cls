public class SendSlackMessageToFinanceRestricted
{
      @InvocableMethod 
      public static void send(List<String> Message)
      {
          SendSlackMessage.send(config.getConfig('Slack Channel Finance Restricted URL'), Message.get(0));
      }
}