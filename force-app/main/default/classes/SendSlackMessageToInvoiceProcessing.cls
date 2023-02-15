public class SendSlackMessageToInvoiceProcessing
{
      @InvocableMethod 
      public static void send(List<String> Message) {
          SendSlackMessage.send(config.getConfig('Slack Channel Invoice Processing URL') ,Message.get(0));
      }
}