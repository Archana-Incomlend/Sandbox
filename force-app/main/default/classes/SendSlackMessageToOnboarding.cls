public class SendSlackMessageToOnboarding
{
      @InvocableMethod 
      public static void send(List<String> Message)
      {
          SendSlackMessage.send(config.getConfig('Slack Onboarding Channel URL'), Message.get(0));
      }
}