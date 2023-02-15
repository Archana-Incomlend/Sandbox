@RestResource(urlMapping='/v9/DynamicSdr/*')
global class RefreshDynamicSdrRates implements Schedulable
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

    private static String getNextValue(JSONParser parser) {
        parser.nextValue();
        return parser.getText();
    }
    
    public static Dynamic_SDR__c getRate(Date p_Date, String refRateType) {
        if (refRateType == null) refRateType = 'SOFR-F';
        List<Dynamic_SDR__c> rates = getRate(p_Date, null, refRateType);
        if (rates == null || rates.size() == 0) return null;
        for (Dynamic_SDR__c rate : rates) {
            if (rate.Date__c == p_date) return rate;
        }
        if (refRateType == 'SOFR-F') Helper_Email.Send(false, GlobalTriggerHandler.getEmailToSendException(), 'Refresh Dynamic SDR exception', 'Cant find rate for the exact date');
        return rates.get(0);
    }
    
    public static List<Dynamic_SDR__c> getRate(Date p_Date_start, Date p_Date_end, String refRateType) {
        
        if (refRateType == null) throw new GeneralException('refRateType is required');
        if (p_Date_start == null) return null;
        if (p_Date_end == null) p_Date_end = refRateType == 'SOFR' ? p_Date_start : p_Date_start.addDays(1);
        System.debug('search from date ' + p_Date_start + ' to ' + p_Date_end);
        DateTime p_Date_start_zone = ((DateTime)p_Date_start);
        DateTime p_Date_end_zone = ((DateTime)p_Date_end).addHours(refRateType == 'Euribor' ? 1 : 0);
        
        Map<Date, Decimal> rates = new Map<Date, Decimal>(); // NYFED rate CME 3M Euribor series[0]=2
        Map<Date, Decimal> ratePercentile1st = new Map<Date, Decimal>(); 
        Map<Date, Decimal> ratePercentile25th = new Map<Date, Decimal>(); 
        Map<Date, Decimal> ratePercentile75th = new Map<Date, Decimal>(); 
        Map<Date, Decimal> ratePercentile99th = new Map<Date, Decimal>(); 

        Map<Date, Decimal> rate = new Map<Date, Decimal>(); 
        Map<Date, Decimal> rate1M = new Map<Date, Decimal>(); 
        Map<Date, Decimal> rate6M = new Map<Date, Decimal>(); 
        Map<Date, Decimal> rate1Y = new Map<Date, Decimal>(); 
        
        String errorMessage = '';

        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = '';
        if (refRateType == 'SOFR') endpoint = 'https://markets.newyorkfed.org/read?productCode=50&eventCodes=520' 
                + '&startDt=' + String.valueOf(p_Date_start) + '&endDt=' + String.valueOf(p_Date_end) + '&sort=postDt:1';
        if (refRateType == 'SOFR-F') endpoint = 'https://www.cmegroup.com/services/sofr-strip-rates';
        if (refRateType == 'Euribor') endpoint = 'https://www.euribor-rates.eu/umbraco/api/euriborpageapi/highchartsdata?series[0]=2&minticks=' + p_Date_start_zone.getTime() + '&maxticks=' + p_Date_end_zone.getTime();
        if (endpoint == '') return null;

        System.debug(endpoint);
        request.setEndPoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(2 * 60 * 1000);
        HttpResponse response = null;
        List<Dynamic_SDR__c> result = new List<Dynamic_SDR__c>();

        String responseBody = '';
        try {
            response = httpProtocol.send(request);
            responseBody = response.getBody();
            System.debug('response ' + responseBody);

            if (refRateType == 'Euribor' && responseBody == '{"Message":"Invalid request"}') return result; // no result for give start end date
            if (response.getStatusCode() != 200) { // || !rates.containsKey(l_date)) {
                errorMessage += 'Unable to retrieve rate for ' + String.valueOf(p_Date_start) + ' to ' + String.valueOf(p_Date_end)  + '\n' + 'Response body: ' + responseBody;
            }
        } catch (CalloutException e) {
            if (e.getMessage() == 'Read timed out' || e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)') {
                errorMessage += 'Unable to wait for response ' + e.getMessage();
            } else {
                errorMessage += 'CalloutException ' + e.getMessage();
            } 
        } catch (Exception e) {
            System.debug(e);
            errorMessage += 'Error occurred ' + e.getMessage();
        }
        if (errorMessage != '') throw new GeneralException(errorMessage);
        
        JSONParser parser = null;
        String key_cuto = refRateType == 'SOFR-F' ? ',"sentTimeCurve":' : '';
        boolean numberArr = false;
        try {
            String dataArr = responseBody.trim();
            if (refRateType == 'Euribor') dataArr = dataArr.replaceAll('("[^"]*")|\\s', '$1');
            String anchor = refRateType == 'SOFR-F' ? '"resultsStrip":' : refRateType == 'Euribor' ? '"Data":' : '"data":';
            Integer prefixLength = dataArr.left(1) == '{' ? 1 : dataArr.left(2) == '[{' ? 2 : null;
            if (prefixLength == null || dataArr.indexOf(anchor + '[') == -1 || dataArr.indexOf(anchor + '[]') != -1) {
                System.debug('no data ' + dataArr + ' ' + dataArr.indexOf(anchor + '['));
                errorMessage += 'Invalid response format, no data array';
            } else {
                dataArr = dataArr.substring(dataArr.indexOf(anchor) + anchor.length(), dataArr.length() - prefixLength);
                if (refRateType == 'SOFR') dataArr = dataArr.replace('"{','{').replace('"}','}').replace('\\"','"');
                if (key_cuto != '' && dataArr.indexOf(key_cuto) != -1) dataArr = dataArr.substring(0, dataArr.indexOf(key_cuto));
                System.debug('dataArr ' + Pattern.compile('(.{200})').matcher(dataArr).replaceAll('$1\n'));
            }
            numberArr = dataArr.indexOf('[[') == 0;
            if (dataArr != '') parser = JSON.createParser(dataArr);
        } catch (JSONException ex) {
            errorMessage += 'JSONException ' + ex.getMessage();
        } catch (Exception e) {
            System.debug(e);
            errorMessage += 'Error occurred ' + e.getMessage();
        }
        if (errorMessage != '') throw new GeneralException(errorMessage);
        if (parser == null) return result; // empty dataArr
        
        JSONParser dataParser;
        String key_date = refRateType == 'SOFR' ? 'postDt' : 'date';
        String key_item = refRateType == 'SOFR' ? 'data' : 'sofrRatesFixing';
        try {
            Date p_Date;
            if (numberArr) parser.nextValue();
            while (parser.nextToken() != null) {
                if (parser.getCurrentName() == key_date || (numberArr && parser.getText() == '[')) {
                    String str = getNextValue(parser);
                    if (numberArr && str.replaceFirst('1[0-9]{12}', '') != '') System.debug('input invalid epoch timestamp ' + str);
                    p_Date = numberArr ? DateTime.newInstance(Long.valueOf(str)).addHours(refRateType == 'Euribor' ? 8 : 0).date() : Date.valueOf(str);                    
                    // if (str != l_date) continue;
                    System.debug('date is ' + p_Date);
                    if ((p_Date < p_Date_start || p_Date > p_Date_end) && !Test.isRunningTest()) p_Date = null;
                }
                if (p_Date == null) continue;
                if (refRateType == 'Euribor') rates.put(p_Date, Decimal.valueOf(getNextValue(parser))); 
                if (numberArr) p_date = null; 
                if (numberArr) continue;

                if (parser.getCurrentName() == key_item) {
                    dataParser = parser;

                    decimal currentRate = null;
                    while (dataParser.nextToken() != null) {
                        if (refRateType == 'SOFR') {
                            if (dataParser.getText() == '}') break;
                            if (dataParser.getCurrentName() == 'dailyRate') rates.put(p_Date, Decimal.valueOf(getNextValue(dataParser)));
                            if (dataParser.getCurrentName() == 'ratePercentile1st') ratePercentile1st.put(p_Date, Decimal.valueOf(getNextValue(dataParser)));
                            if (dataParser.getCurrentName() == 'ratePercentile25th') ratePercentile25th.put(p_Date, Decimal.valueOf(getNextValue(dataParser)));
                            if (dataParser.getCurrentName() == 'ratePercentile75th') ratePercentile75th.put(p_Date, Decimal.valueOf(getNextValue(dataParser)));
                            if (dataParser.getCurrentName() == 'ratePercentile99th') ratePercentile99th.put(p_Date, Decimal.valueOf(getNextValue(dataParser)));
                        }
                        if (refRateType == 'SOFR-F') {
                            if (dataParser.getText() == '}' && rate1Y.get(p_Date) != null) break;
                            if (dataParser.getCurrentName() == 'price') currentRate = Decimal.valueOf(getNextValue(dataParser));
                            if (dataParser.getCurrentName() == 'term') {
                                String term = getNextValue(dataParser);
                                if (term == '3M') rates.put(p_Date, currentRate);
                                else if (term == '1M') rate1M.put(p_Date, currentRate);
                                else if (term == '6M') rate6M.put(p_Date, currentRate);
                                else if (term == '1Y') rate1Y.put(p_Date, currentRate);
                            }
                        }
                    }
                    dataParser = null;
                }
            }
        } catch (JSONException ex) {
            if (dataParser != null) System.debug('parser ' + dataParser.getText());
            else if (parser != null) System.debug('parser ' + parser.getText());
            errorMessage += 'JSONException ' + ex.getMessage();
            System.debug(ex);
        }

        for (Date p_Date : rates.keySet()) {
            Dynamic_SDR__c dynamicSdr = new Dynamic_SDR__c();
            dynamicSdr.Date__c = p_Date;
            dynamicSdr.Type__c = refRateType.indexOf('SOFR') != -1 ? 'SOFR' : refRateType;
            if (refRateType == 'SOFR') {
                dynamicSdr.SOFR_Percentile_50__c = rates.get(p_Date);
                System.debug(dynamicSdr + ' ratePercentile ' + ratePercentile1st.get(p_Date) + ' ' + ratePercentile25th.get(p_Date) + ' ' + ratePercentile75th.get(p_Date) + ' ' + ratePercentile99th.get(p_Date));
            }
            if (refRateType == 'SOFR-F') {
                dynamicSdr.SOFR_Rate_Fixing__c = rates.get(p_Date);
                System.debug(dynamicSdr + ' 1M ' + rate1M.get(p_Date) + ' 6M ' + rate6M.get(p_Date) + ' 1Y ' + rate1Y.get(p_Date));
            }
            if (refRateType == 'Euribor') {
                dynamicSdr.Euribor_Rate__c = rates.get(p_Date);
                System.debug(dynamicSdr);
            }
            result.add(dynamicSdr);
        }
        if (!String.isBlank(errorMessage)) Helper_Email.Send(false, GlobalTriggerHandler.getEmailToSendException(), 'Refresh Dynamic SDR exception', errorMessage);
        
        return result;  
    }   
    
    
    @future(callout=true)
    public static void InsertNewRates()
    {
        main();
    }

    public static void main()
    {
        Date l_date = System.today();
        DateTime l_dt = (DateTime)l_date;
        String dayOfWeek = l_dt.format('E');
        System.debug('Day of week ' + dayOfWeek);
        Date l_date1 = l_Date.addDays(-1);
        if (dayOfWeek == 'Mon') l_date1 = l_date1.addDays(-2);
        Date l_date2 = l_date1.addDays(-1);
        if (dayOfWeek == 'Tue') l_date2 = l_date2.addDays(-2);
        Date l_date3 = l_date2.addDays(-1);
        if (dayOfWeek == 'Wed') l_date3 = l_date3.addDays(-2);

        Set<Date> setDate = new Set<Date> { l_date, l_date1, l_date2, l_date3 }; 
        for (integer i = 0; i <= 5; i++) setDate.add(l_date.addDays(-i));  // include weekend
        
        List<Dynamic_SDR__c> listRate = new List<Dynamic_SDR__c>();
        // for (Date l_Date : setDate) addNonNull(listRate, InsertNewRatesDate(l_Date, true, false, refRateType));
        for (String refRateType : new List<String> {'SOFR-F', 'Euribor'}) {
            try {
                for (Dynamic_SDR__c dynamicSdr : getRate(l_date3, l_date, refRateType)) {
                    if (setDate.contains(dynamicSdr.Date__c)) listRate.add(dynamicSdr);
                }
                if (GlobalTriggerHandler.runningInASandbox) sendToProd(listRate);
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
        save(listRate, true);
    }

    // private static void addNonNull(List<Dynamic_SDR__c> listRate, Dynamic_SDR__c newRate) {
    //     if (newRate != null) listRate.add(newRate);
    // }
    
    public static void save(List<Dynamic_SDR__c> listRate, boolean isLatest) {
        System.debug('saving ' + listRate.size() + '(s) ' + listRate);
        Set<Dynamic_SDR__c> setRate = new Set<Dynamic_SDR__c>(listRate);
        Map<String, Dynamic_SDR__c> mapRate = new Map<String, Dynamic_SDR__c>();
        for (Dynamic_SDR__c dynamicSdr : listRate) {
            mapRate.put(dynamicSdr.Type__c + dynamicSdr.Date__c, dynamicSdr);
        }
        for (Dynamic_SDR__c dynamicSdr : [SELECT Type__c, Date__c FROM Dynamic_SDR__c ORDER BY LastModifiedDate DESC LIMIT 100]) {
            Dynamic_SDR__c temp = mapRate.get(dynamicSdr.Type__c + dynamicSdr.Date__c);
            if (temp != null) setRate.remove(temp);
        }
        if (setRate.size() != listRate.size()) System.debug('filter ' + setRate.size() + '(s) ' + setRate);
        if (setRate.size() != listRate.size()) listRate = new List<Dynamic_SDR__c>(setRate);

        String errorMessage = null;
        try {
            insert listRate;
            if (!isLatest) return;
            // List<Invoice_Finance_Deal__c> invoices = [SELECT Id FROM Invoice_Finance_Deal__c WHERE advance_send_to_supplier_Date__c = :l_date];
            // todo change advance_send_to_supplier_Date__c to correct Date
            // upDate invoices;
        } catch(Exception ex){
            errorMessage += ex.getMessage();
            System.debug(ex);
        } finally {
            if (!String.isBlank(errorMessage)){
                Helper_Log Logs = new Helper_Log();
                Logs.log(errorMessage, Helper_Log.Color.Black);
                GlobalTriggerHandler.OutError('Run Refresh Dynamic Rate fail', Logs);
            }
        }
    }

    public static void sendToProd(List<Dynamic_SDR__c> listRate) { // workaround for salesforce production and aws hosted salesforce service cannot access cme group
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse res = new HttpResponse();                
        request.setEndpoint(GlobalTriggerHandler.getConfiguration('salesforceEndpoint') + '/sofr');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/plain');
        request.setHeader('x-api-key', GlobalTriggerHandler.getConfiguration('salesforceApiKey'));
        request.setTimeout(5000);//5s
        
        try {
          String jsonString = JSON.serialize(listRate);
          System.debug(jsonString);
          request.setBody(jsonString);
          if (!Test.isRunningTest()) res = http.send(request);
          System.debug(res.toString());
          if (Test.isRunningTest() || res.getStatusCode() != 200) throw new GeneralException('Response ' + res.getStatusCode() + ' ' + res.getBody());
        } catch (Exception e) {
          if (e instanceof CalloutException) System.debug(e.getMessage()); else System.debug(e);
          if (e.getMessage() != 'Read timed out' && e.getMessage() != 'Exceeded maximum time allotted for callout (120000 ms)') {
            Helper_Email.Send(false, GlobalTriggerHandler.getEmailToSendException(), 'Refresh Dynamic SDR send to production fail', e.getMessage()); // last try
          }
        }
    }

    public static Dynamic_SDR__c InsertNewRatesDate(Date l_date, boolean isTest, boolean isLatest, String refRateType)
    {
        System.debug('InsertNewRatesDate ' + l_date + ' ' + isTest + ' ' + refRateType);
        if (!isNeedRunTrigger) return null;
        if (l_date == null) l_date = System.today().addDays(-1);

        try {
            Dynamic_SDR__c newRate = getRate(l_date, refRateType);
            if (!isTest && newRate != null) save(new List<Dynamic_SDR__c> {newRate}, isLatest);
            return newRate;
        } catch (Exception ex) {
            return null;
        }
    }

    @HttpGet
    global static void doGet() {
        main();
    }

    @HttpPost
    global static String doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;        
        res.statusCode = 500;
        String dynamicSdrStr = RestContext.request.params.get('str');
        if (String.isBlank(dynamicSdrStr)) return 'blank input';
        List<Dynamic_SDR__c> listRate = (List<Dynamic_SDR__c>)JSON.deserialize(dynamicSdrStr, List<Dynamic_SDR__c>.Class);
        if (listRate.size() == 0) return 'list is empty';
        save(listRate, true);
        res.statusCode = 200;
        return 'success';
    }

    global void execute(SchedulableContext SC)
    {
        InsertNewRates();
    }
    
}