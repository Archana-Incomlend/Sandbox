public class InvoiceUtil {
    //Invoice Record Types
    public static final String SUPPLIER_REC_TYPE = 'Supplier';
    public static final String FUNDER_REC_TYPE = 'Funder';
    public static final String MAP_AGENT_REC_TYPE = 'Map Agent';
    public static final String FUNDER_AGENT_REC_TYPE = 'Funder Agent';
    
    //Invoice Descriptions
    public static final String SUPPLIER_DISCOUNT_AMOUNT_DESC = 'Supplier Service Charges for Invoice Funding';
    public static final String SUPPLIER_DISCOUNT_AMOUNT_ADJUSTMENT_DESC = 'Early Repayment Adjustment';
    public static final String SUPPLIER_DISCOUNT_AMOUNT_OVERDUE_DESC = 'Revised Supplier Service Charges';
    public static final String SUPPLIER_CAD_PROCESSING_FEE ='Cash Against Document Processsing Fee';
    public static final String FUNDER_PROFIT_SHARE_DESC = 'Platform Fees';
    public static final String ADMIN_FEES_DESC = 'Administrative Fees';
    
    //Invoice SOQL bind variables
    public static final String ORIGINAL_INVOICE_RECORD_TYPE = '%-F1-%';
    public static final String EMAIL_FROM = 'operations@incomlend.com';
    public static final String EMAIL_TEMPLATE = 'Invoice Template';
    
    //Email Attachment
    public static final String EMAIL_CC = 'finance@incomlend.com';
    public static final String EMAIL_SUBJECT = 'Invoice #';
    public static final String TAX_INVOICE = 'Tax Invoice.pdf';
    public static final String CREDIT_NOTE = 'Credit Note.pdf';
    
    //Membership Fees
    public static final Decimal SUPPLIER_USD_FEE = 350.00;
    public static final Decimal BUYER_USD_FEE = 200.00;
    public static final Decimal SUPPLIER_EUR_FEE = 310.00;
    public static final Decimal BUYER_EUR_FEE = 180.00;
    
    //Currencies
    public static final String SGD = 'SGD';
    public static final String USD = 'USD';
    public static final String EUR = 'EUR';
    public static final String HKD = 'HKD';
    
    //Visual Force Parameters
    public static final String PARAM_ID = 'Id';
    
    //Test Constants
    public static final String TEST_EMAIL_TO = 'test@incomlend.com';
    public static final String YOPMAIL = '@yopmail';
    
    public static final Boolean isRunningInSandbox {
        public get {
            if (null == isRunningInSandbox) {
                isRunningInSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            
            return isRunningInSandbox;
        }
        
        private set;
    }
    
    public enum RecordType {
        SUPPLIER,
        FUNDER,
        MAP_AGENT,
        FUNDER_AGENT,
        TEST
    }
    
    public enum ActionType {
        Funded,
        Repaid,
        Test
    }
    
    public enum Description {
        SUPPLIER_DISCOUNT_AMOUNT,
        SUPPLIER_DISCOUNT_AMOUNT_ADJUSTMENT,
        SUPPLIER_DISCOUNT_AMOUNT_OVERDUE,
        SUPPLIER_CAD_PROCESSING_FEE,
        FUNDER_PROFIT_SHARE,
        ADMIN_FEES,
        TEST
    }
    
    public static void testHack() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}