public class SendSlackMessageToOperations
{
      @InvocableMethod 
      public static void send(List<String> Message)
      {
          SendSlackMessage.send(config.getConfig('Slack Operations Channel URL'), Message.get(0));
      }
}