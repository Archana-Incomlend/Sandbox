@RestResource(urlMapping='/v8.1/Account/*')

global with sharing class RestAccountData_v8_1 {
      
    @HttpGet
    global static GlobalMethods.AccountReturnClass doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
          
        String p_accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
        String p_ccy = RestContext.request.params.get('ccy');
        String p_fieldSetType = RestContext.request.params.get('fieldSetType'); 
        
        Map<String,String> v_FieldSet = new Map<String,String>{
            'basic_data' => ' is_Master_Agent__c, EUR_Position__c, HKD_Position__c, SGD_Position__c, USD_Position__c, XXX_Position__c, Agent_Commision_Supplier_Platform_Fee__c, Agent_Commision_Purchaser_Discount_Fee__c, Agent_Commision_Obligor_Platform_Fee__c, XXX_Available_eWallet__c, XXX_total_discount_earned__c, XXX_total_reservations__c, XXX_Total_in_progress_invoices__c, XXX_eWallet_Balance__c, Total_in_progress_Invoices_USD_Equiv__c, Total_Position_USD_Equiv__c, EUR_available_eWallet__c, EUR_Total_in_progress_invoices__c, EUR_eWallet_Balance__c, EUR_total_reservations__c, EUR_available_eWallet_USD_Equiv__c, EUR_Total_Discount_Earned__c, Total_eWallet_USD_Equiv__c, USD_Available_eWallet__c, SGD_Available_eWallet__c, HKD_Available_eWallet__c, SGD_total_discount_earned__c, USD_total_discount_earned__c, HKD_total_discount_earned__c, USD_total_reservations__c, SGD_total_reservations__c, HKD_total_reservations__c, HKD_Total_in_progress_invoices__c, USD_Total_in_progress_invoices__c, SGD_Total_in_progress_invoices__c, Total_Available_eWallet_USD_Equiv__c, SGD_Available_eWallet_USD_Equiv__c, HKD_Available_eWallet_USD_Equiv__c, SGD_eWallet_Balance__c, USD_eWallet_Balance__c, HKD_eWallet_Balance__c',
            'agent' => ' is_Master_Agent__c, Agent_Commision_Supplier_Platform_Fee__c, Agent_Commision_Purchaser_Discount_Fee__c, Agent_Commision_Obligor_Platform_Fee__c, XXX_Available_eWallet__c, XXX_total_discount_earned__c, XXX_total_reservations__c, XXX_Total_in_progress_invoices__c, XXX_eWallet_Balance__c, Total_in_progress_Invoices_USD_Equiv__c, Total_Position_USD_Equiv__c, EUR_available_eWallet__c, EUR_Total_in_progress_invoices__c, EUR_eWallet_Balance__c, EUR_total_reservations__c, EUR_available_eWallet_USD_Equiv__c, EUR_Total_Discount_Earned__c, Total_eWallet_USD_Equiv__c, USD_Available_eWallet__c, SGD_Available_eWallet__c, HKD_Available_eWallet__c, SGD_total_discount_earned__c, USD_total_discount_earned__c, HKD_total_discount_earned__c, USD_total_reservations__c, SGD_total_reservations__c, HKD_total_reservations__c, HKD_Total_in_progress_invoices__c, USD_Total_in_progress_invoices__c, SGD_Total_in_progress_invoices__c, Total_Available_eWallet_USD_Equiv__c, SGD_Available_eWallet_USD_Equiv__c, HKD_Available_eWallet_USD_Equiv__c, SGD_eWallet_Balance__c, USD_eWallet_Balance__c, HKD_eWallet_Balance__c',
            'buyer' => ' Inprogress_invoice_amount_usd_equiv__c , overdue_invoice_amount_usd_equiv__c, Inprogress_advanced_amount_usd_equiv__c, Credit_Limit_Remaining_usd_equiv__c, Insured_Loss_USD_Equiv__c, Credit_Limit_USD_Equiv__c, XXX_Available_eWallet__c, XXX_total_discount_earned__c, XXX_total_reservations__c, XXX_Total_in_progress_invoices__c, XXX_eWallet_Balance__c, Total_in_progress_Invoices_USD_Equiv__c, Total_Position_USD_Equiv__c, EUR_available_eWallet__c, EUR_Total_in_progress_invoices__c, EUR_eWallet_Balance__c, EUR_total_reservations__c, EUR_available_eWallet_USD_Equiv__c, EUR_Total_Discount_Earned__c, Total_eWallet_USD_Equiv__c, USD_Available_eWallet__c, SGD_Available_eWallet__c, HKD_Available_eWallet__c, SGD_total_discount_earned__c, USD_total_discount_earned__c, HKD_total_discount_earned__c, USD_total_reservations__c, SGD_total_reservations__c, HKD_total_reservations__c, HKD_Total_in_progress_invoices__c, USD_Total_in_progress_invoices__c, SGD_Total_in_progress_invoices__c, Total_Available_eWallet_USD_Equiv__c, SGD_Available_eWallet_USD_Equiv__c, HKD_Available_eWallet_USD_Equiv__c, SGD_eWallet_Balance__c, USD_eWallet_Balance__c, HKD_eWallet_Balance__c',
            'buyer_dashboard' => ' id, CL_Rem_inc_prelst_buyer_conf_usd_eq__c , prelisting_reqstd_amt_approv_buye_usd_eq__c , Un_utilised_adv_amt_inc_prel_app_usd_eq__c , Inprogress_invoice_amount_usd_equiv__c , overdue_invoice_amount_usd_equiv__c , Credit_Limit_Remain_inc_mrkplc_usd_equiv__c, Credit_Limit_Rem_all_phases_usd_equiv__c,  Total_eWallet_USD_Equiv__c,  XXX_eWallet_Balance__c, USD_eWallet_Balance__c, SGD_eWallet_Balance__c, HKD_eWallet_Balance__c, EUR_eWallet_Balance__c, Insured_Loss_USD_Equiv__c , insured_loss_percentage__c, Credit_Insurance_CCY__c, Credit_limit_insurance_currency__c, Credit_Limit_USD_Equiv__c, prelisting_requested_amount_usd_equiv__c , Marketplace_Requested_amount_usd_equiv__c, Inprogress_advanced_amount_usd_equiv__c, Credit_Limit_Remaining_usd_equiv__c, Un_utilised_adv_amt_all_phases_usd_equiv__c, Un_utilised_adv_amt_mrk_place_usd_equiv__c, Un_utilised_advanced_amount_usd_equiv__c ',
            'allbuyers' => ' Discussion_board_link__c, suspended__c, suspended_notes__c, Industry, Website, BillingAddress, number_of_defaults__c, days_with_no_defaults__c, Name, logo_URL__c, Onboarding_completed_date__c, countries_of_operation__c, AnnualRevenue, Year_of_incorporation__c, Country_of_Incorporation__c, head_office_country__c, goods_or_services_offered_text__c, Public_Profile__c'
        };
        
        //Get logged in user account Id using the email Id from header
        map<String,String> v_headers = new map<String,String>();
        v_headers = req.headers;
        String v_email = v_headers.get('email');
        if(v_email > '') {
            try{
                Id v_loggedInUserAccountId = GlobalMethods.getLoggedinUserAccountId(v_email); 
            }catch(GeneralException e) {
                return new GlobalMethods.AccountReturnClass('false',e.getMessage(), null);
            }
        }
        
        List<Account> v_result = new List<Account> ();
        String v_listQuery;
        String v_listQueryFieldSet;
        
        if(GlobalMethods.isValidId(p_accountId) == false) {
            return new GlobalMethods.AccountReturnClass('false','Invalid user ID', null);
        }
        
        if(p_ccy != null && GlobalMethods.isvalidCurrency(p_ccy) == false) {
            return new GlobalMethods.AccountReturnClass('false','Invalid currency', null);
        }

        //Validating and adding the fieldSet
        if(v_FieldSet.get(p_fieldSetType) != null) {
            v_listQueryFieldSet = v_FieldSet.get(p_fieldSetType);
        }else {
            return new GlobalMethods.AccountReturnClass('false','Field set parameter is missing or invalid value', null);
        }
        
        v_listQuery = 'SELECT '+v_listQueryFieldSet + ' FROM Account WHERE Id = :p_accountId';
        v_result = database.query(v_listQuery);
        if (v_result.size() == 0) {
            return new GlobalMethods.AccountReturnClass('false','Invalid user account id', null);
        }else {
            return new GlobalMethods.AccountReturnClass('true', 'Query executed successfully.', v_result.get(0));
        }
    }
}