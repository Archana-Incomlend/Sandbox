public class SendSlackMessageToLead {
    
    @InvocableMethod 
      public static void send(List<String> Message)
      {
          SendSlackMessage.send(config.getConfig('Slack Lead Channel URL'), Message.get(0));
      }

}