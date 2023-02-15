public class SendSlackMessageToBookkeepingUpdates
   {
       @InvocableMethod 
      public static void send(List<String> Message) {
            SendSlackMessage.send( config.getConfig('Slack Finance Channel URL') ,Message.get(0));
        }
        }