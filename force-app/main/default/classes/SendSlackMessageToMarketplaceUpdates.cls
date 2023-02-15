public class SendSlackMessageToMarketplaceUpdates
   {
       @InvocableMethod 
      public static void send(List<String> Message) {
            SendSlackMessage.send( config.getConfig('Slack Channel Marketplace URL') ,Message.get(0));
        }
        }