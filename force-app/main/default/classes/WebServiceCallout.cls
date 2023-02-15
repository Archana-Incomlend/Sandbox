public class WebServiceCallout {
    public static boolean needRunTrigger = true;
    public static boolean IsNeedRunTrigger
    {
      public get  // to enable trigger during test set it to null
      {
        return Test.isRunningTest() ? needRunTrigger == null : needRunTrigger == true;
      }
      public set
      {
          if (value) needRunTrigger = Test.isRunningTest() ? null : true;
          else needRunTrigger = false;
      }
    }

    public static boolean IgnoreFirstRun = false;
    public static void resetFirstRun() {
        afterEWallet = true;
        afterAccount = true;
        afterMap = true;
        afterInvoice = true;
        afterEWalletTrustee = true;
    }
    public static boolean afterEWallet = true;
    public static boolean FirstrunAfterEWallet { 
        public get
        {
          if (IgnoreFirstRun) return true; else if (!afterEWallet) return false;
          afterEWallet = false;
          return true;
        }
    }
    public static boolean afterInvoice = true;
    public static boolean FirstrunAfterInvoice { 
        public get
        {
          if (IgnoreFirstRun) return true; else if (!afterInvoice) return false;
          afterInvoice = false;
          return true;
        }
    }  
    public static boolean afterMap = true;
    public static boolean FirstrunAfterMap { 
        public get
        {
          if (IgnoreFirstRun) return true; else if (!afterMap) return false;
          afterMap = false;
          return true;
        }
    }  
    public static boolean afterAccount = true;
    public static boolean FirstrunAfterAccount { 
        public get
        {
          if (IgnoreFirstRun) return true; else if (!afterAccount) return false;
          afterAccount = false;
          return true;
        }
    }  
    public static boolean afterEWalletTrustee = true;
    public static boolean FirstrunAfterEWalletTrustee { 
        public get
        {
          if (IgnoreFirstRun) return true; else if (!afterEWalletTrustee) return false;
          afterEWalletTrustee = false;
          return true;
        }
    }

	@future (callout=true)
    public static void notifyInvoiceAllocationRequest(String type, String data) {
        if (!IsNeedRunTrigger) return;
        if (type == null || data == null) return;
        String endpoint = GlobalTriggerHandler.getConfiguration('salesforceEndpoint');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        endpoint += '?';
        endpoint += '&type=' + type;
        endpoint += '&data=' + data;
        if(!Test.isRunningTest()) request.setEndpoint(endpoint);
        request.setMethod('PUT');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        if(!Test.isRunningTest())
            request.setHeader('x-api-key', GlobalTriggerHandler.getConfiguration('salesforceApiKey'));
        
        HttpResponse res = new HttpResponse();

        try {
            if(!Test.isRunningTest()){
                res = http.send(request);
                System.debug(res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }

    }

}