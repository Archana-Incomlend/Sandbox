public class GlobalTriggerHandler {

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

  public static Boolean runningInASandbox {
    get {
        if (runningInASandbox == null) {
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        return runningInASandbox;
    }
    set;
  }
  public static String baseUrl;

  public static String notificationEndpoint;
  public static String notificationApiKey;
  public static String notificationAtradius;
  public static String salesforceEndpoint;
  public static String salesforceApiKey;
  public static String dropboxToken;

  public static final Map<String, String> CONFIG_MAP = new Map<String, String> {
    'notificationEndpoint' => 'IncomlendPricing_v3_Behaviour_Notification_Endpoint',
    'notificationApiKey' => 'IncomlendPricing_v3_Behaviour_Notification_ApiKey',
    'notificationAtradius' => 'IncomlendPricing_v3_Behaviour_Notification_Atradius',
    'salesforceEndpoint' => 'IncomlendPricing_v3_Behaviour_WebServiceCallout_Endpoint',
    'salesforceApiKey' => 'IncomlendPricing_v3_Behaviour_WebServiceCallout_ApiKey',
    'dropboxToken' => 'Download_Report_Dropbox_Token'
  };

  public static final String AGENT_FEE_PS = 'Part of profit share (%)';
  public static final String V_360 = '360';
  public static final String V_365 = '365';
  public static final Integer MAX_EXPECTED_PAYMENT_TO_INVOICE_DATE = 120;
  
  public static Map<Id, Account> getAccountUpdateMap(List<Supplier_Buyer_Map__c> listMap) {
    Map<Id, Account> mapAccount = new Map<Id, Account>();
    if (!isNeedRunTrigger) return mapAccount;
    if (listMap == null) return mapAccount;
    Set<Id> agentList = new Set<Id>();
    
    for (Supplier_Buyer_Map__c supplierBuyerMap : listMap) 
    {
      mapAccount.put(supplierBuyerMap.Supplier__c, null);
      mapAccount.put(supplierBuyerMap.Buyer__c, null);
      agentList.add(supplierBuyerMap.Account_Agent__c);
    }
    if (mapAccount.size() > 0) { 
      mapAccount = new Map<Id, Account>([SELECT Id, Trustee__c , Agent__c FROM Account WHERE Id IN :mapAccount.keySet()]); 
      for (Account currentAccount : mapAccount.values()) {
        agentList.add(currentAccount.Agent__c);
      }
    }
    if (agentList.size() > 0) {
      agentList.removeAll(mapAccount.keySet());
      mapAccount.putAll(new Map<Id, Account>([SELECT Id, Account_Agent_s_Type__c, Value_of_agent_s_fee__c FROM Account WHERE Id IN :agentList])); 
    }
    return mapAccount;
  }

  public static void updateMap(Supplier_Buyer_Map__c supplierBuyerMap) {
    // if (!isNeedRunTrigger) return; // always run
    if (!isNeedRunTrigger) return;
    try {
      if (supplierBuyerMap.Sales_Owner_1__c != supplierBuyerMap.Val_Sales_Owner_1__c) {
        supplierBuyerMap.Sales_Owner_1__c = supplierBuyerMap.Val_Sales_Owner_1__c;
        System.debug('update map sales owner 1 ' + supplierBuyerMap.Id + ' ' + supplierBuyerMap.Name + ' ' + supplierBuyerMap.Sales_Owner_1__c);  
      } 
      if (supplierBuyerMap.Sales_Owner_2__c != supplierBuyerMap.Val_Sales_Owner_2__c) {
        supplierBuyerMap.Sales_Owner_2__c = supplierBuyerMap.Val_Sales_Owner_2__c;
        System.debug('update map sales owner 2 ' + supplierBuyerMap.Id + ' ' + supplierBuyerMap.Name + ' ' + supplierBuyerMap.Sales_Owner_2__c);  
      } 
    } catch (Exception e) {
      System.debug(e);
    } 
  }

  public static void insertMap(Supplier_Buyer_Map__c supplierBuyerMap, Map<Id, Account> mapAccount) {
    // if (!isNeedRunTrigger) return; // always run
    if (mapAccount == null) return;
    if (supplierBuyerMap.Market_Place_Name__c != null) {
      try{
        if (supplierBuyerMap.Trustee__c == null) {
          String Trustee = null;
          if (supplierBuyerMap.Market_Place_Name__c.indexOf('Reverse') == -1) {
            if (mapAccount.get(supplierBuyerMap.Supplier__c) != null) {
              Trustee = mapAccount.get(supplierBuyerMap.Supplier__c).Trustee__c;
            }
          } else {
            if (mapAccount.get(supplierBuyerMap.Buyer__c) != null) {
              Trustee = mapAccount.get(supplierBuyerMap.Buyer__c).Trustee__c;
            }
          }
          // make multi picklist into single picklist field, favor default value
          if (Trustee == null || (Trustee != null && Trustee.indexOf(';') != -1)) Trustee = 'Amicorp Trust';
          supplierBuyerMap.Trustee__c = Trustee; 
          System.debug('update map trustee ' + supplierBuyerMap.Id + ' ' + supplierBuyerMap.Name + ' ' + Trustee);  
        }
      } catch (Exception e) { 
        System.debug(e);
      } 
    }

    try{
      if (supplierBuyerMap.Account_Agent__c != null && mapAccount.get(supplierBuyerMap.Account_Agent__c) != null) {
        Account currentAccount = mapAccount.get(supplierBuyerMap.Account_Agent__c);
        boolean changed = false;
        if (supplierBuyerMap.Agent_s_fee_type__c == null && currentAccount.Account_Agent_s_Type__c != null) {
          supplierBuyerMap.Agent_s_fee_type__c = currentAccount.Account_Agent_s_Type__c == 'Fixed' ? 'Part of the supplier discount rate (%)' :
                  currentAccount.Account_Agent_s_Type__c == 'Tiered' ? 'Part of the supplier discount rate Tiered' : null;
          if (supplierBuyerMap.Agent_s_fee_type__c != null) changed = true;
        }
        if (supplierBuyerMap.Value_of_agent_s_fee__c == null && currentAccount.Value_of_agent_s_fee__c != null) {
          supplierBuyerMap.Value_of_agent_s_fee__c = currentAccount.Value_of_agent_s_fee__c;
          changed = true;
        }
        if (changed) System.debug('update map agent data ' + supplierBuyerMap.Id + ' ' + supplierBuyerMap.Name + ' ' + supplierBuyerMap.Agent_s_fee_type__c + ' ' + supplierBuyerMap.Value_of_agent_s_fee__c);
      }
    } catch (Exception e) { 
      System.debug(e);
    }
  }

  public static Map<Id, Supplier_Buyer_Map__c> getMapUpdateInvoice(List<Invoice_finance_deal__c> listInvoice) {
    Map<Id, Supplier_Buyer_Map__c> mapMap = new Map<Id, Supplier_Buyer_Map__c>();
    if (!isNeedRunTrigger) return mapMap;
    if (listInvoice == null) return mapMap;
    for (Invoice_finance_deal__c invoice : listInvoice) 
    {
      mapMap.put(invoice.Supplier_Buyer_Map__c, null);
    }
    if (mapMap.size() > 0) { 
      mapMap = new Map<Id, Supplier_Buyer_Map__c>(
            [ SELECT  Id, Map_Sales_Owner__c, Overdue_days__c, Sales_Owner_1__c, Buyer__r.Insured_by__c, 
                    Insurance_Premium_Logic__c, Insurance_cost_for_Supplier__c, Incomlend_product__c, 
                    Age_of_the_map__c, First_Invoice_Funded__c, Floating_Rate_Margin__c, Funding_Spread__c, Val_Sales_Owner_1__c
              FROM Supplier_Buyer_Map__c WHERE Id IN :mapMap.keySet()]); 
    }
    return mapMap;
  }

  public static boolean calculateExpectedPaymentDate(Invoice_finance_deal__c invoice, Invoice_finance_deal__c oldInvoice, Supplier_Buyer_Map__c supplierBuyerMap) {
    boolean changed = false;
    if (invoice.Expected_Payment_Date__c != null) return changed;
    Date Expected_Payment_Date = invoice.Due_Date__c == null ? null : invoice.Due_Date__c.addDays(Integer.valueOf( supplierBuyerMap.Overdue_days__c == null ? 0 : supplierBuyerMap.Overdue_days__c));
    if (Expected_Payment_Date != null && invoice.Invoice_date__c != null) {
      Date temp = invoice.Invoice_date__c.addDays(MAX_EXPECTED_PAYMENT_TO_INVOICE_DATE);
      if (Expected_Payment_Date > temp) Expected_Payment_Date = temp;
    } 
    if (oldInvoice == null ? Expected_Payment_Date != null : oldInvoice.Expected_Payment_Date__c != Expected_Payment_Date) 
    {
      changed = true;
      System.debug('Expected Payment Date for invoice ' + (oldInvoice == null ? 'new is ' : invoice.Name + ' changed to ') + Expected_Payment_Date);
    }  
    invoice.Expected_Payment_Date__c = Expected_Payment_Date;
    return changed;
  }

  public static void insertInvoice(Invoice_finance_deal__c invoice, Supplier_Buyer_Map__c supplierBuyerMap) {
    if (!isNeedRunTrigger) return;
    if (supplierBuyerMap == null) return;
    if (invoice.Phase__c == '1:PRE LISTING' || invoice.Phase__c == '2:ON MARKETPLACE') {
      calculateExpectedPaymentDate(invoice, null, supplierBuyerMap);
    } else {
      if (invoice.Phase__c == '3:IN PROGRESS') updateInvoice(invoice, supplierBuyerMap, true);
      if (invoice.Phase__c == '4:CLOSED') updateInvoice(invoice, supplierBuyerMap, false);  
    }
    if (invoice.Insured_by__c == null) {
      List<Schema.PicklistEntry> fieldResult = Invoice_finance_deal__c.Insured_by__c.getDescribe().getPicklistValues();
      if (supplierBuyerMap.Buyer__r.Insured_by__c != null && supplierBuyerMap.Buyer__r.Insured_by__c != 'Non insured') {
        boolean found = false;
        for( Schema.PicklistEntry f : fieldResult )
        {
          if (supplierBuyerMap.Buyer__r.Insured_by__c == f.getLabel() || supplierBuyerMap.Buyer__r.Insured_by__c == f.getValue() 
            || (supplierBuyerMap.Buyer__r.Insured_by__c == 'Bank ( LC lite )' && f.getValue() == 'LC Lite Bank Guaranty')) {
            invoice.Insured_by__c = f.getValue();
            break;
          }
        }
      }  
    }
    // if (invoice.credit_insurance_fee_percentage__c == null) // fast field update also copy from Map's Supplier's Credit insurance fee - override
      if (supplierBuyerMap.Insurance_Premium_Logic__c == 'Invoice based' && supplierBuyerMap.Insurance_cost_for_Supplier__c != null) {
        invoice.credit_insurance_fee_percentage__c = supplierBuyerMap.Insurance_cost_for_Supplier__c;
      }
    if (invoice.Incomlend_product_del__c == null) {
      invoice.Incomlend_product_del__c = supplierBuyerMap.Incomlend_product__c;
    }
    if (invoice.Phase__c == null && (invoice.Status__c == null || invoice.Status__c == 'pending incomlend review')) {
      invoice.Phase__c = '1:PRE LISTING'; // bug marketplace frontend submit invoice (single)
    }
    if (updateFloatingRate(invoice, supplierBuyerMap, true) == null) Helper_Email.Send(true, getEmailToSendException(), 'Dynamic SDR exception', getHtmlBody('No available rate ' + invoice.Name));
  }

  public static void updateInvoice(Invoice_finance_deal__c invoice, Invoice_finance_deal__c oldInvoice, Supplier_Buyer_Map__c supplierBuyerMap) {
    if (!isNeedRunTrigger) return;
    // if (invoice.Sales_Owner__c != supplierBuyerMap.Sales_Owner_1__c) {
    if (invoice.Sales_Owner__c != supplierBuyerMap.Val_Sales_Owner_1__c) {
      // invoice.Sales_Owner__c = supplierBuyerMap.Sales_Owner_1__c;
      invoice.Sales_Owner__c = supplierBuyerMap.Val_Sales_Owner_1__c;
      System.debug('Sales owner for invoice ' + (oldInvoice == null ? 'new is ' : invoice.Name + ' changed to ') + supplierBuyerMap.Sales_Owner_1__c);
    }
    invoice.Invoice_Sales_Owner_2__c = invoice.Sales_Owner__c;

    if (oldInvoice == null || invoice.advance_send_to_supplier_date__c != oldInvoice.advance_send_to_supplier_date__c) updateInvoice(invoice, supplierBuyerMap, true);
    else if (invoice.advance_send_to_supplier_date__c != null && invoice.Funded_age_of_the_map__c == null) updateInvoice(invoice, supplierBuyerMap, true); // migrate
    if (oldInvoice == null || invoice.Actual_Repayment_Received_Date__c != oldInvoice.Actual_Repayment_Received_Date__c) updateInvoice(invoice, supplierBuyerMap, false);      
    else if (invoice.Actual_Repayment_Received_Date__c != null && invoice.Repaid_age_of_the_map__c == null) updateInvoice(invoice, supplierBuyerMap, false); // migrate

    if (oldInvoice != null && ((invoice.Phase__c == '2:ON MARKETPLACE' && oldInvoice.Phase__c == '1:PRE LISTING')
            || (invoice.Invoice_submitted_for_approval__c != oldInvoice.Invoice_submitted_for_approval__c)
            || (invoice.Listing_Start__c != oldInvoice.Listing_Start__c))) {
      if (updateFloatingRate(invoice, supplierBuyerMap) == null) Helper_Email.Send(true, getEmailToSendException(), 'Dynamic SDR exception', getHtmlBody('No available rate ' + invoice.Name));
    }
    if ((oldInvoice == null || oldInvoice.FX_Rate__c != invoice.FX_Rate__c) && invoice.FX_Rate__c != null && invoice.FX_conversion_rate__c == null)  {
      FX_Rates__c rate = [SELECT Name, from_Currency__c, Rate__c FROM FX_Rates__c WHERE Id = :invoice.FX_Rate__c]; 
      if (invoice.CCY__c != rate.from_Currency__c) throw new GeneralException('mismatch fx rate currency ' + invoice.Name + ' ' + rate.Name, null); 
      else if (!invoice.Passthrough_auto__c && invoice.CCY__c != rate.from_Currency__c) throw new GeneralException('mismatch fx rate currency ' + invoice.Name + ' ' + rate.Name, null); 
      else invoice.FX_conversion_rate__c = rate.Rate__c;
    }
  }

  public static void updateInvoice(Invoice_finance_deal__c invoice, Supplier_Buyer_Map__c supplierBuyerMap, boolean fundedElseRepaid) {
    if (supplierBuyerMap == null) return;
    if (fundedElseRepaid != false) { 
      if (invoice.advance_send_to_supplier_date__c == null || invoice.Funded_age_of_the_map__c != null) return; 
    } else {
      if (invoice.Actual_Repayment_Received_Date__c == null || invoice.Repaid_age_of_the_map__c != null) return;
    }

    integer ageOfTheMap = (integer)supplierBuyerMap.Age_of_the_map__c;
    if (supplierBuyerMap.First_Invoice_Funded__c == null) ageOfTheMap = 1;
    else {
      if (fundedElseRepaid != false) ageOfTheMap = (integer)(Math.Floor(supplierBuyerMap.First_Invoice_Funded__c.daysBetween(invoice.advance_send_to_supplier_date__c) + 1)/365)+1;
      else ageOfTheMap = (integer)(Math.Floor(supplierBuyerMap.First_Invoice_Funded__c.daysBetween(invoice.Actual_Repayment_Received_Date__c) + 1)/365)+1;
    }

    String str = ageOfTheMap == 1 ? '1' : ageOfTheMap == 2 ? '2' : ageOfTheMap == 3 ? '3' : ageOfTheMap > 0 ? '4+' : null;
    try {
      if (fundedElseRepaid != false) invoice.Funded_age_of_the_map__c = str;
      else invoice.Repaid_age_of_the_map__c = str;
    } catch (Exception e) {
      Helper_Email.Send(true, getEmailToSendException(), 'Error update funded/repaid date of invoice ', getHtmlBody(str + '\n' + e.getMessage())); // last try
    }
  }

  public static void updateAllocation(Invoice_Allocation__c a) {
    if (!isNeedRunTrigger) return;
    a.Buyer_name_value__c = a.Buyer_name__c;
    a.Supplier_industry_value__c = a.Supplier_industry__c;
  }

  public static boolean calculateAllocationFees(Invoice_Allocation__c a)
  {
    // if (!isNeedRunTrigger) return false; // always run
    boolean changed = false;
    decimal Applied_Funder_Discount_Profit_Share_Pct = a.Applied_Funder_Discount_Profit_Share_Pct__c;
    if (Applied_Funder_Discount_Profit_Share_Pct == null) 
      Applied_Funder_Discount_Profit_Share_Pct = 0;

    // set scale used because otherwise SF will round to 3 dp even though field is defined as 2dp
    System.debug('Discount Brut: ' + a.Discount__c + ' ' + a.Funder_Agent_Commission_Type__c 
            + ' ' + a.Funder_Agent_Commision_Percentage__c + ' ' + a.Expected_finance_period_buyback_capped__c);
    decimal funder_discount_amount = (a.Discount__c * (1 - Applied_Funder_Discount_Profit_Share_Pct / 100));
    
    decimal Funder_Agent_Commission_Amount = 
            (a.funder_agent__c == 'Incomlend - agent'|| String.isEmpty(a.funder_agent__c)) ? 0
            : (a.Funder_Agent_Commission_Type__c == AGENT_FEE_PS) ? 
              a.Discount__c * Applied_Funder_Discount_Profit_Share_Pct / 100 * a.Funder_Agent_Commision_Percentage__c
            : (a.Funder_Agent_Commission_Type__c.contains(V_360)) ?
              a.amount__c * a.Expected_finance_period_buyback_capped__c * a.Funder_Agent_Commision_Percentage__c / 360
            : (a.Funder_Agent_Commission_Type__c.contains(V_365)) ?
              a.amount__c * a.Expected_finance_period_buyback_capped__c * a.Funder_Agent_Commision_Percentage__c / 365
            : 0
            ;
    
    decimal Incomlend_commision = a.Discount__c * Applied_Funder_Discount_Profit_Share_Pct / 100 - Funder_Agent_Commission_Amount;

    // if (a.funder_discount_amount__c != funder_discount_amount.setScale(2)) changed = true;
    a.funder_discount_amount__c = funder_discount_amount.setScale(2);
    
    decimal temp;
    temp = a.Funder_Agent_Commission_Amount__c;
    if (temp == null) changed = true;
    a.Funder_Agent_Commission_Amount__c = Funder_Agent_Commission_Amount.setScale(2);
    if (temp == a.Funder_Agent_Commission_Amount__c) changed = true;
    
    temp = a.Incomlend_commision__c;
    if (temp == null) changed = true;
    a.Incomlend_commision__c = Incomlend_commision.setScale(2);
    if (temp == a.Incomlend_commision__c) changed = true;
    
    if (a.For_balance_upfront_fee_calculation__c != a.Balance_upfront_fee_calculation__c) changed = true;
    a.For_balance_upfront_fee_calculation__c = a.Balance_upfront_fee_calculation__c;

    if (a.For_Gross_Funder_discount_amount_overdue__c != a.Gross_Funder_discount_amount_overdue__c) changed = true; 
    a.For_Gross_Funder_discount_amount_overdue__c = a.Gross_Funder_discount_amount_overdue__c;

    if (a.Applied_MPR__c == null || a.Applied_MPR__c == 0) {
      changed = true;
      a.Applied_MPR__c = a.MPR__c.setScale(4);
    }
    if (a.Funding_Spread__c != null && a.Invoice_Floating_Rate__c != null) {
      decimal rate = ((a.Funding_Spread__c + a.Invoice_Floating_Rate__c) / 12).setScale(4); 
      if (rate != a.Invoice_Floating_Rate__c) {
        changed = true;
        a.Applied_MPR__c = rate;
      }       
    } else if (a.Funding_Spread__c != null && (a.Funding_Spread__c / 12).setScale(4) != a.Applied_MPR__c) {
      changed = true;
      a.Applied_MPR__c = (a.Funding_Spread__c / 12).setScale(4);
    }
    return changed;
  }

  public static boolean updateFloatingRate(Invoice_Finance_Deal__c invoice, Supplier_Buyer_Map__c supplierBuyerMap) {
    return updateFloatingRate(invoice, supplierBuyerMap, false);
  }
  
  public static boolean updateFloatingRate(Invoice_Finance_Deal__c invoice, Supplier_Buyer_Map__c supplierBuyerMap, boolean duringInsert) {
    if (supplierBuyerMap == null) supplierBuyerMap = invoice.Supplier_Buyer_Map__r;
    if (supplierBuyerMap == null) { System.debug('No map info ' + invoice.Name); return null; }
    if (supplierBuyerMap.Floating_Rate_Margin__c != null || supplierBuyerMap.Funding_Spread__c != null ) {
      decimal rate = updateFloatingRate(invoice);
      if (rate != null && supplierBuyerMap.Floating_Rate_Margin__c != null) {
        invoice.Total_Supplier_Discount__c = ((rate + supplierBuyerMap.Floating_Rate_Margin__c) / 12).setScale(4, RoundingMode.HALF_UP);
        invoice.Overdue_sSupplier_discount_rate__c = invoice.Total_Supplier_Discount__c;
      }
      if (rate != null && supplierBuyerMap.Funding_Spread__c != null && (duringInsert || GlobalTriggerHandler.coalesce(invoice.discount_rate__c) == 0)) {
        invoice.discount_rate__c = ((rate + supplierBuyerMap.Funding_Spread__c) / 12).setScale(4, RoundingMode.HALF_UP);
      }
      if (rate != null) return true;
    }
    return false;
  }

  public static decimal updateFloatingRate(Invoice_Finance_Deal__c invoice) {
    String dsdrType = invoice.CCY__c == 'USD' ? 'SOFR' : invoice.CCY__c == 'EUR' ? 'Euribor' : null;
    if (dsdrType == null) return null;
    List<Dynamic_SDR__c> rates = [SELECT Id, Type__c, Date__c, Rate__c FROM Dynamic_SDR__c WHERE Type__c = :dsdrType AND Rate__c != null ORDER BY Date__c DESC LIMIT 1];
    if (rates.size() == 0) { 
      System.debug('No floating rate available ' + invoice.Name); 
      return null; 
    } 
    System.debug('Date to used for floating rate ' + rates.get(0).Date__c);
    decimal rate = rates.get(0).Rate__c;
    if (rate < 0) rate = 0;
    invoice.Floating_Rate__c = rate;  
    return rate;
  }

  public static String coalesceConfig(String configValue) {
    if (configValue == '' || configValue == 'key not found') return null;
    return configValue;
  }

  public static String getConfiguration(String behaviourVariable) {
    try {
      if (behaviourVariable == 'salesforceEndpoint') {
        if (salesforceEndpoint == null) salesforceEndpoint = coalesceConfig(config.getConfig(CONFIG_MAP.get(behaviourVariable)));
        return salesforceEndpoint;
      }
      if (behaviourVariable == 'salesforceApiKey') {
        if (salesforceApiKey == null) salesforceApiKey = coalesceConfig(config.getConfig(CONFIG_MAP.get(behaviourVariable)));
        return salesforceApiKey;
      }
      if (behaviourVariable == 'notificationEndpoint') {
        if (notificationEndpoint == null) notificationEndpoint = coalesceConfig(config.getConfig(CONFIG_MAP.get(behaviourVariable)));
        return notificationEndpoint;
      }
      if (behaviourVariable == 'notificationApiKey') {
        if (notificationApiKey == null) notificationApiKey = coalesceConfig(config.getConfig(CONFIG_MAP.get(behaviourVariable)));
        return notificationApiKey;
      }  
      if (behaviourVariable == 'notificationAtradius') {
        if (notificationAtradius == null) notificationAtradius = coalesceConfig(config.getConfig(CONFIG_MAP.get(behaviourVariable)));
        return notificationAtradius;
      }  
      if (behaviourVariable == 'dropboxToken') {
        if (dropboxToken == null) dropboxToken = coalesceConfig(config.getConfig(CONFIG_MAP.get(behaviourVariable)));
        return dropboxToken;
      }  
      if (CONFIG_MAP.containsKey(behaviourVariable)) return coalesceConfig(config.getConfig(CONFIG_MAP.get(behaviourVariable))); // last try no cache
    } catch (Exception e) {
      System.debug(e);
    }
    return '';
  }

  @future(callout = true) // future method 
  public static void calloutSendEmail(List<String> toAddresses, String subject, String body) {
    sendEmail(toAddresses, subject, body);
  }

  public static void sendEmail(List<String> toAddresses, String subject, String body) {
    if (!isNeedRunTrigger) return; 

    Http http = new Http();
    HttpRequest request = new HttpRequest();
    HttpResponse res = new HttpResponse();

    String endpoint = getConfiguration('notificationEndpoint');
    request.setEndpoint(endpoint);
    request.setMethod('PUT');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Accept', '*/*');
    request.setHeader('x-api-key', getConfiguration('notificationApiKey'));
    request.setTimeout(1000);//1s

    Map<String, Object> message = new Map<String,Object>();
    Map<String, String> messageData = new Map<String,String>();
    messageData.put('from', 'no-reply@incomlend.com');
    messageData.put('to', String.join(toAddresses, ';'));
    messageData.put('subject', subject);
    message.put('message', messageData);
    Map<String, String> templateContent = new Map<String, String>();
    templateContent.put('str', body);
    message.put('templateContent', templateContent);
    message.put('templateName', 'test');
    
    try {
      String jsonString = JSON.serialize(message);
      System.debug(jsonString);
      request.setBody(jsonString);
      if(!Test.isRunningTest()) res = http.send(request);
      System.debug('sendEmail ' + res.toString());
    } catch (CalloutException e) {
      System.debug(e.getMessage());
      if (e.getMessage() != 'Read timed out' && e.getMessage() != 'Exceeded maximum time allotted for callout (120000 ms)') {
        Helper_Email.Send(true, toAddresses, subject, getHtmlBody('')); // last try
      }
    } catch (Exception e) {
      System.debug(e);
      Helper_Email.Send(true, toAddresses, subject, getHtmlBody('')); // last try
    }
  }

  public static List<String> getEmailToSendException() {
    List<String> listEmail = new List<String>{'mel.dinh@incomlend.com'};
    if (runningInASandbox) { String email = getConfiguration('notificationAtradius'); if (email != null) listEmail = new List<String>{ email }; }
    
    for (User currentUser : [SELECT ID, Email, isActive FROM USER WHERE Email IN :listEmail]) 
    {
      if (!currentUser.isActive) listEmail.remove(listEmail.indexOf(currentUser.Email));
    }
    if (listEmail.isEmpty()) listEmail.add('mel.k@yopmail.com');
    return listEmail;
  }

  public static void OutError(String subject, Helper_Log Logs) {
    String str = '';
    if (Logs != null) str = Logs.HTMLLog.replaceAll('[\\[\\]\\s-:\\d]{20,}','');
    Helper_Email.Send(true, getEmailToSendException(), subject, str);
  }

  public static String getHtmlBody(String log) {
    if (String.isBlank(log)) return '<div></div>';
    return '<div>' + '<p>' + log.replace('\n','</p><p>') + '</p>' + '</div>';
  }

  public static String getBaseUrl() {
    if (baseUrl != null) return baseUrl;
    baseUrl = runningInASandbox ? 'https://incomlend--icldv04dvp.my.salesforce.com/' : 'https://incomlend.my.salesforce.com/';
    return baseUrl;
  }

  public static Date coalesce(Date value, Date defaultValue) {
    return value == null ? (defaultValue == null ? Date.valueOf('1970-01-01') : defaultValue) : value;
  }

  public static decimal coalesce(decimal value) {
    return coalesce(value, null);
  }

  public static decimal coalesce(decimal value, decimal defaultValue) {
    return value == null ? (defaultValue == null ? 0 : defaultValue) : value;
  }

  public static integer coalesce(integer value) {
    return coalesce(value, null);
  }
  
  public static integer coalesce(integer value, integer defaultValue) {
    return value == null ? (defaultValue == null ? 0 : defaultValue) : value;
  }

  public static string coalesce(string value) {
    return coalesce(value, null);
  }
  
  public static string coalesce(string value, string defaultValue) {
    return value == null ? (defaultValue == null ? '' : defaultValue) : value;
  }

  public static boolean setConfig(String name, String value) {
    String key = name;
    if (CONFIG_MAP.containsKey(name)) key = CONFIG_MAP.get(name);
    try {
      configuration__c[] temp = [SELECT Name, value__c FROM configuration__c WHERE Name = :key ORDER BY lastModifiedDate DESC LIMIT 1];
      if (temp.size() == 0) { System.debug('configuration not exist ' + key); return false; }
      configuration__c c = temp[0];
      c.value__c = value;
      upsert c Name;
      if (key != name && name == 'notificationEndpoint') notificationEndpoint = value;
      if (key != name && name == 'notificationApiKey') notificationApiKey = value;
      if (key != name && name == 'notificationAtradius') notificationAtradius = value;
      if (key != name && name == 'salesforceEndpoint') salesforceEndpoint = value;
      if (key != name && name == 'salesforceApiKey') salesforceApiKey = value;
      if (key != name && name == 'dropboxToken') dropboxToken = value;
      return true;
    } catch (Exception ex) {
      System.debug('Unable to save config ' + name + (key != name ? ' ' + key : '') + ' ' + ex.getMessage());
      return false;
    }
  }

  @future
  public static void setConfigFuture(String name, String value) {
    setConfig(name, value);
  }

  public static String getHash(String requestInput) {
    Blob requestBlob = Blob.valueOf(requestInput);
    Blob hash = Crypto.generateDigest('MD5', requestBlob);
    String requestSignature = EncodingUtil.convertToHex(hash);
    return requestSignature;
  }

  public static Object getMetadataSetting(String key, Type destType) {
    try {
      String queryString = String.join(new List<String>(Schema.getGlobalDescribe().get('Incomlend_Custom__mdt').getDescribe().fields.getMap().keySet()), ',');
      queryString = 'SELECT ' + queryString + ' FROM Incomlend_Custom__mdt WHERE QualifiedApiName = \'Main\' LIMIT 1';
      Incomlend_Custom__mdt iclCustomMeta = Database.query(queryString);
      Object o = iclCustomMeta.get(key + '__c');
      if (destType != null) {
        String currentType = null;
        if (o instanceof SObject) currentType = ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if (o instanceof Boolean) currentType = 'Boolean';
        if (o instanceof Id) currentType = 'Id';
        if (o instanceof String) currentType = 'String';
        if (o instanceof Blob) currentType = 'Blob';
        if (o instanceof Date) currentType = 'Date';
        if (o instanceof Datetime) currentType = 'Datetime';
        if (o instanceof Time) currentType = 'Time';
        if (o instanceof String) currentType = 'String';
        if (o instanceof Integer) currentType = 'Integer';
        if (o instanceof Long) currentType = 'Long';
        if (o instanceof Decimal) currentType = 'Decimal'; 
        if (currentType != destType.getName()) {
          System.debug('Unable to retrieve metadata ' + key + ' wrong data type ' + currentType + ' should be ' + destType.getName());
          o = null;  
        }
      } 
      return o;
    } catch (Exception e) {
      System.debug('Unable to retrieve metadata ' + key + ' ' + e.getMessage());
      return null;
    }
  }

  private class MetaDeployCallback implements Metadata.DeployCallback {
    public String key { get; set; }
    public boolean success { get; set; }
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
      if (result.status == Metadata.DeployStatus.Succeeded) {
        System.Debug('Update meta data ' + key + ' is successful');
        success = true;
      } else {
        System.Debug('Update meta data ' + key + ' failed');
        success = false;
      }
    }
  }

  public static void debugStackTrace() {
    DebugHelper debugHelper = new DebugHelper();
    debugHelper.Debug(new GeneralException('test'));
    System.debug(debugHelper.FullLog);
  }

  public static void putMetaDataSetting(String key, Object value) {
    Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
    customMetadata.fullName = 'Incomlend_Custom.Main';
    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    mdContainer.addMetadata(customMetadata);
    
    Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
    customField.field = key + '__c';
    customField.value = value;
    customMetadata.values.add(customField);

    Id jobId = Test.isRunningTest() ? null : Metadata.Operations.enqueueDeployment(mdContainer, new MetaDeployCallback());
    if (Test.isRunningTest()) new MetaDeployCallback().handleResult(new Metadata.DeployResult(), null);
    System.debug('Updating meta data ' + key + ' job ' + jobId);
  }
}