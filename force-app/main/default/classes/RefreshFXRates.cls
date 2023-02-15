global class RefreshFXRates implements Schedulable
{
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
    
    public static map<string, decimal> getFXRate(list<string> p_ccy, date p_date) {
        
        string l_date = String.valueOf(p_date); 
        // system.debug('date is ' + l_date);
        map<string, decimal> rates = new map<string,decimal>() ; 
        decimal rate;
        string errorMessage = '';

        for (string ccy : p_ccy) {
            // system.debug('ccy is ' + ccy);
            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();
            //https://openexchangerates.org/api/historical/2021-12-26.json?symbols=HKD&app_id=3e3e8a9d427c4b42b3f25e068ba1465d
            String endpoint = 'https://openexchangerates.org/api/historical/' + l_date + '.json?symbols=' + ccy + '&app_id=3e3e8a9d427c4b42b3f25e068ba1465d';
            request.setEndPoint(endpoint);
            request.setMethod('GET');
            //request.setTimeout(2 * 60 * 1000);
            HttpResponse response = httpProtocol.send(request);
            System.debug(response.getBody());

            JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if (parser.getCurrentName() == ccy)
                {
                    parser.nextValue();
                    rate = (1/parser.getDecimalValue()).setScale(5);
                    system.debug('rate is ' + rate);
                    
                    rates.put(ccy,  rate);
                }
            }
            if (response.getStatusCode() != 200 || !rates.containsKey(ccy)) {
                errorMessage += 'Unable to retrieve rate for ' + ccy + '\n' + 'Response body: ' + response.getBody();
            }
        }
        if (errorMessage != '') rates.put(errorMessage, -1);
        
        return rates;  
    }   
    
    
    @future(callout=true)
    public static void InsertNewFxRates()
    {
        DateTime l_dt = System.now().addDays(-1);
        Date l_date = Date.valueOf(l_dt.format('YYYY-MM-dd'));
        InsertNewFxRatesDate(l_date, false, true);
    }
    
    public static void InsertNewFxRatesDate(Date l_date, boolean isTest, boolean isLatest)
    {
        if (!isNeedRunTrigger) return;
        if (l_date == null) return;
        list<string> l_ccys = new list<string>();
        l_ccys.add('HKD');
        l_ccys.add('GBP');
        l_ccys.add('SGD');
        l_ccys.add('EUR');
        l_ccys.add('AUD');

        List<FX_Rates__c> listRate = new List<FX_Rates__c>() ;
        String errorMessage = null;
        Exception e = null;
        try{
            map<string, decimal> l_rates = getFXRate(l_ccys, l_date);
        
            for(string l_key : l_rates.keySet() ) 
            { 
                if (l_rates.get(l_key) == -1) { // error
                    errorMessage = l_key;        
                    continue;
                }
                decimal l_rate = l_rates.get(l_key);
                system.debug('rate is ' + l_key + ':' + l_rate);
                
                FX_Rates__c newFXRate = new FX_Rates__c();
                newFXRate.rate__c = l_rates.get(l_key);
                newFXRate.to_currency__c = 'USD';
                newFXRate.from_currency__c = l_key;
                newFXRate.date__c = l_date;
                listRate.add(newFXRate);
            }
    
            if (!isTest) {
                // insert listRate;
                Database.SaveResult[] results = Database.Insert(listRate, true);
                for(Database.SaveResult result : results)
                {
                    if (!result.isSuccess()) {
                        if (errorMessage == null) errorMessage = '';
                        errorMessage += 'Unable to insert rate';
                        for(Database.Error err : result.getErrors()) {
                            errorMessage += ' : ' + err.getStatusCode() + ' ' + err.getMessage();
                        }
                        errorMessage += '\n';
                    }
                }
            }
            if (!String.isBlank(errorMessage)) System.debug(errorMessage);
            if (!isLatest) return;
            List<marketplace__c> marketplaces = [select id, FX_Rate_for_MI__c, Currency__c from marketplace__c where Currency__c in :l_rates.keySet()];
            for ( marketplace__c marketplace : marketplaces) 
            {
                for (FX_Rates__c newFXRate : listRate) 
                {
                    if (newFXRate.from_currency__c == marketplace.Currency__c) {
                        marketplace.FX_Rate_for_MI__c = newFXRate.id;
                        marketplace.latest_to_usd_rate__c = newFXRate.rate__c;    
                        break;    
                    }
                }
            }   
            update marketplaces;
        } catch(Exception ex){
            errorMessage = ex.getMessage();
            System.debug(ex);
        } finally {
            if (!String.isBlank(errorMessage)){
                OutLog('Error in RefreshFXRate ' + l_date.format(), listRate, errorMessage);
            }
        }
    }
    
    public static void OutLog(String subject, List<FX_Rates__c> listRate, String errorMessage){
        try {
            List<String> listEmail = new List<String> {'mel.dinh@incomlend.com','michel@incomlend.com','mohamed.asif@incomlend.com'};
            Helper_Log Logs = new Helper_Log();
            Logs.log('to_currency__c: USD', 1, Helper_Log.Color.Black);
            for (FX_Rates__c fxrate : listRate) {
                Logs.log('fromcurrency:' + fxrate.from_currency__c, 1, Helper_Log.Color.Black);
                Logs.log('rate:' + fxrate.rate__c, 2, Helper_Log.Color.Grey);
                Logs.log('date:' + fxrate.date__c, 2, Helper_Log.Color.Grey);
            }

            if (!String.isBlank(errorMessage)) {
                Logs.log('Error message ' + errorMessage, 1, Helper_Log.Color.Black);
            }
            String body = Logs.HTMLLog.replaceAll('[\\[\\]\\s-:\\d]{20,}','');

            for (User currentUser : [SELECT ID, Email, isActive FROM USER WHERE Email IN :listEmail]) {
                integer index = listEmail.indexOf(currentUser.Email);
                // if (currentUser.isActive) listEmail[index] = currentUser.Id;
                if (!currentUser.isActive) listEmail.remove(index);
            }
            if (!listEmail.isEmpty()) {
                // Helper_Email.Send(true, listEmail, subject, body);
                // System.debug('The email "' + subject + '" was sent successfully. ' + listEmail);
                GlobalTriggerHandler.sendEmail(listEmail, subject, body);
            } else 
                System.debug('The email "' + subject + '" no active recipient.');
        } catch (Exception ex) {
            System.debug('The email "' + subject + '" failed to send: ' + ex.getMessage());
        }
    }
    
    global void execute(SchedulableContext SC)
    {
        InsertNewFxRates();
    }
    
    
    
    
}