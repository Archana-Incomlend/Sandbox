public class SendSlackMessageToInvoiceAllocation
{
      @InvocableMethod 
      public static void send(List<String> Message) {
          SendSlackMessage.send(config.getConfig('Slack Channel Invoice Allocation URL') ,Message.get(0));
      }
}