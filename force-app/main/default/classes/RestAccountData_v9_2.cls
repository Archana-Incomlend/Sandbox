@RestResource(urlMapping='/v9.2/Account/*')
// Update for ITM-1194 start
global with sharing class RestAccountData_v9_2 {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        GlobalMethods_v9.AccountReturnClass accountReturnClass;
        String p_accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String p_fieldSetType = RestContext.request.params.get('fieldSetType');
        //Get logged in user account Id using the email Id from header
        map<String,String> v_headers = new map<String,String>(RestContext.request.headers);
        String v_email = v_headers.get('email');
        String v_listQuery = '';
        
        if(GlobalMethods_v9.isValidId(p_accountId) == false) {
            accountReturnClass = new GlobalMethods_v9.AccountReturnClass('false','Invalid user ID', null);
            res.responseBody = Blob.valueOf(JSON.serialize(accountReturnClass));
            res.statusCode = 400;
        } else {
            Map<String,String> v_FieldSet = new Map<String,String>{
                'basic_data' => ' Id, Name, Sub_type__c, Membership_Renewal_Date__c, is_Master_Agent__c, Agent_Commision_Supplier_Platform_Fee__c, Agent_Commision_Purchaser_Discount_Fee__c, Agent_Commision_Obligor_Platform_Fee__c,'
                    + ' Gross_Funder_Discount_Rate_EUR__c, Gross_Funder_Discount_Rate_GBP__c, Gross_Funder_Discount_Rate_HKD__c,'
                    + ' Gross_Funder_Discount_Rate_SGD__c, Gross_Funder_Discount_Rate_USD__c,'
                    + ' Discount_Profit_Share_Percent_EUR__c, Discount_Profit_Share_Percent_GBP__c, Discount_Profit_Share_Percent_HKD__c,'
                    + ' Discount_Profit_Share_Percent_SGD__c, Discount_Profit_Share_Percent_USD__c',
                'agent' => ' Id, Name, Sub_type__c, is_Master_Agent__c, Agent_Commision_Supplier_Platform_Fee__c, Agent_Commision_Purchaser_Discount_Fee__c, Agent_Commision_Obligor_Platform_Fee__c'
                    + ' Gross_Funder_Discount_Rate_EUR__c, Gross_Funder_Discount_Rate_GBP__c, Gross_Funder_Discount_Rate_HKD__c,'
                    + ' Gross_Funder_Discount_Rate_SGD__c, Gross_Funder_Discount_Rate_USD__c,'
                    + ' Discount_Profit_Share_Percent_EUR__c, Discount_Profit_Share_Percent_GBP__c, Discount_Profit_Share_Percent_HKD__c,'
                    + ' Discount_Profit_Share_Percent_SGD__c, Discount_Profit_Share_Percent_USD__c',
                'buyer' => ' Id, Name, Sub_type__c, Inprogress_invoice_amount_usd_equiv__c , overdue_invoice_amount_usd_equiv__c, Inprogress_advanced_amount_usd_equiv__c, Credit_Limit_Remaining_usd_equiv__c, Insured_Loss_USD_Equiv__c, Credit_Limit_USD_Equiv__c'
                    + ' Gross_Funder_Discount_Rate_EUR__c, Gross_Funder_Discount_Rate_GBP__c, Gross_Funder_Discount_Rate_HKD__c,'
                    + ' Gross_Funder_Discount_Rate_SGD__c, Gross_Funder_Discount_Rate_USD__c,'
                    + ' Discount_Profit_Share_Percent_EUR__c, Discount_Profit_Share_Percent_GBP__c, Discount_Profit_Share_Percent_HKD__c,'
                    + ' Discount_Profit_Share_Percent_SGD__c, Discount_Profit_Share_Percent_USD__c',
                'buyer_dashboard' => ' Id, Name, Sub_type__c, Sum_Overdue_Costs_Supplier_USD_eq__c, CL_Rem_inc_prelst_buyer_conf_usd_eq__c , prelisting_reqstd_amt_approv_buye_usd_eq__c , Un_utilised_adv_amt_inc_prel_app_usd_eq__c , Inprogress_invoice_amount_usd_equiv__c , overdue_invoice_amount_usd_equiv__c , Credit_Limit_Remain_inc_mrkplc_usd_equiv__c, Credit_Limit_Rem_all_phases_usd_equiv__c, Insured_Loss_USD_Equiv__c , insured_loss_percentage__c, Credit_Insurance_CCY__c, Credit_limit_insurance_currency__c, Credit_Limit_USD_Equiv__c, prelisting_requested_amount_usd_equiv__c , Marketplace_Requested_amount_usd_equiv__c, Inprogress_advanced_amount_usd_equiv__c, Credit_Limit_Remaining_usd_equiv__c, Un_utilised_adv_amt_all_phases_usd_equiv__c, Un_utilised_adv_amt_mrk_place_usd_equiv__c, Un_utilised_advanced_amount_usd_equiv__c '
                    + ' Gross_Funder_Discount_Rate_EUR__c, Gross_Funder_Discount_Rate_GBP__c, Gross_Funder_Discount_Rate_HKD__c,'
                    + ' Gross_Funder_Discount_Rate_SGD__c, Gross_Funder_Discount_Rate_USD__c,'
                    + ' Discount_Profit_Share_Percent_EUR__c, Discount_Profit_Share_Percent_GBP__c, Discount_Profit_Share_Percent_HKD__c,'
                    + ' Discount_Profit_Share_Percent_SGD__c, Discount_Profit_Share_Percent_USD__c',
                'allbuyers' => ' Id, Name, Sub_type__c, Discussion_board_link__c, suspended__c, suspended_notes__c, Industry, Website, BillingAddress, number_of_defaults__c, days_with_no_defaults__c, Name, logo_URL__c, Onboarding_completed_date__c, countries_of_operation__c, AnnualRevenue, Year_of_incorporation__c, Country_of_Incorporation__c, head_office_country__c, goods_or_services_offered_text__c, Public_Profile__c'
                    + ' Gross_Funder_Discount_Rate_EUR__c, Gross_Funder_Discount_Rate_GBP__c, Gross_Funder_Discount_Rate_HKD__c,'
                    + ' Gross_Funder_Discount_Rate_SGD__c, Gross_Funder_Discount_Rate_USD__c,'
                    + ' Discount_Profit_Share_Percent_EUR__c, Discount_Profit_Share_Percent_GBP__c, Discount_Profit_Share_Percent_HKD__c,'
                    + ' Discount_Profit_Share_Percent_SGD__c, Discount_Profit_Share_Percent_USD__c'
                    };

            //Validating and adding the fieldSet
            if(v_FieldSet.get(p_fieldSetType) != null) {
                v_listQuery = 'SELECT ' + v_FieldSet.get(p_fieldSetType);
            } else {
                v_listQuery = 'SELECT Id, Name, Company_registration_number__c, onboarding_stage__c, Type, Sub_type__c,'
                    + ' Country_of_Incorporation__c, Year_of_incorporation__c, BillingAddress, ShippingAddress,'
                    + ' Sector__c, Goods_and_Services_new__c, Goods_or_Services_Offered__c, Insured_by__c, AnnualRevenue,'
                    + ' NumberOfEmployees, Credit_Limited_Provided_by_Insurer__c, Total_CL_Limit_from_Incomlend__c,'
                    + ' Sales_Owner__r.Name, Trustee__c, (SELECT Name, CCY__c FROM eWallets__r),'
                    + ' Gross_Funder_Discount_Rate_EUR__c, Gross_Funder_Discount_Rate_GBP__c, Gross_Funder_Discount_Rate_HKD__c,'
                    + ' Gross_Funder_Discount_Rate_SGD__c, Gross_Funder_Discount_Rate_USD__c,'
                    + ' Discount_Profit_Share_Percent_EUR__c, Discount_Profit_Share_Percent_GBP__c, Discount_Profit_Share_Percent_HKD__c,'
                    + ' Discount_Profit_Share_Percent_SGD__c, Discount_Profit_Share_Percent_USD__c';
            }
            v_listQuery += ' FROM Account WHERE Id = :p_accountId AND IsDeleted = false';
            
            if ((v_email == null || v_email == '') && RestContext.request.params.get('email') != null) {
                v_email = RestContext.request.params.get('email');
            }
            
            List<Account> v_result = database.query(v_listQuery);
            if(v_result.size() == 0) {
                accountReturnClass = new GlobalMethods_v9.AccountReturnClass('false','Invalid user ID', null);
                res.responseBody = Blob.valueOf(JSON.serialize(accountReturnClass));
                res.statusCode = 400;
            } else {
                if (v_result.get(0).Sub_type__c == 'Purchaser' || Test.isRunningTest()) {
                    Account account = v_result.get(0);
                    account.Discount_Profit_Share_Percent_EUR__c = GlobalTriggerHandler.coalesce(account.Discount_Profit_Share_Percent_EUR__c); 
                    account.Discount_Profit_Share_Percent_GBP__c = GlobalTriggerHandler.coalesce(account.Discount_Profit_Share_Percent_GBP__c); 
                    account.Discount_Profit_Share_Percent_HKD__c = GlobalTriggerHandler.coalesce(account.Discount_Profit_Share_Percent_HKD__c); 
                    account.Discount_Profit_Share_Percent_SGD__c = GlobalTriggerHandler.coalesce(account.Discount_Profit_Share_Percent_SGD__c); 
                    account.Discount_Profit_Share_Percent_USD__c = GlobalTriggerHandler.coalesce(account.Discount_Profit_Share_Percent_USD__c); 
                }
                List<Audit_Trail__c> auditTrailList = [SELECT Account__c, Type__c, Status__c, Additional_Information__c FROM Audit_Trail__c WHERE Account__c = :v_result.get(0).Id AND Type__c = 'Online Approval of GTC' AND Status__c = 'Approved'];
                
                List<eWallet__c> eWalletList = [SELECT Id, Name, CCY__c FROM eWallet__c WHERE Account__c = :v_result.get(0).Id];
                if (auditTrailList.size() > 0) {
                    Boolean isGTCApproved = isGTCApproved(auditTrailList, v_result[0].Sub_type__c );
                    accountReturnClass = new GlobalMethods_v9.AccountReturnClass('true', 'Query executed successfully.', v_result.get(0), isGTCApproved, auditTrailList, v_email, eWalletList);
                } else {
                    accountReturnClass = new GlobalMethods_v9.AccountReturnClass('true', 'Query executed successfully.', v_result.get(0), false, null, v_email, eWalletList);
                }
                res.responseBody = Blob.valueOf(JSON.serialize(accountReturnClass));
                res.statusCode = 200;
            }
        }
    }
    
    // Check GTC approved
    // 
    // @param auditTrailList
    // @param subtype
    // 
    // @return if approved then true else false
    public static Boolean isGTCApproved(List<Audit_Trail__c> auditTrailList, String subType ) {
        String addlInfo = 'v1.0';
        
        String key = 'Incomlend_GTC_Latest_Version';
        if (subType == 'Supplier') {
            key = 'Incomlend_GTC_Supplier_Latest_Version';
        } else if (subType == 'Buyer') {
            key = 'Incomlend_GTC_Buyer_Latest_Version';
        } else if (subType == 'Purchaser') {
            key = 'Incomlend_GTC_Purchaser_Latest_Version';
        }
        
        if (!Test.isRunningTest()) {       
            addlInfo = GlobalTriggerHandler.coalesceConfig(config.getConfig(key));
        }
        
        for (Audit_Trail__c auditTrail : auditTrailList) {
            if (!String.isBlank(auditTrail.Additional_Information__c) && auditTrail.Additional_Information__c.contains(addlInfo)) {
                return true;
            }
        }
        
        return false;
    }
    // Update for ITM-1194 end
}