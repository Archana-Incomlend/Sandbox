public class SalesCommissionUtils {

    //Configuration percentage 
    public static final Integer PCT_COM_FUNDING = 0;
    public static final Integer PCT_OWNER_1 = 100;

    // Percentage Com Sales by Age of the Map
    public static final Map<integer, Decimal> PCT_COM_SALES_CONFIG = new Map<integer, Decimal>{
            1 => 0.020,
            2 => 0.010,
            3 => 0.002,
            0 => 0.002
    };

    // Percentage Com Sales Manager by Age of the Map
    public static final Map<integer, Decimal> PCT_COM_MANAGER_CONFIG = new Map<integer, Decimal>{
            1 => 0.00750,
            2 => 0.00375,
            3 => 0.00075
    };

    // Percentage Com Funding by Age of the 
    public static final Map<integer, Decimal> PCT_COM_FUNDER_CONFIG = new Map<integer, Decimal>{
            1 => 0.24,
            2 => 0.12,
            3 => 0.04,
            0 => 0.01
    };

    // // Percentage Agent Portion by Agent value's fees for high agent commission
    public static final Integer HIGH_PCT_AGENT_PORTION_CONFIG = 25;

    // Percentage Agent Portion by Agent value's fees
    public static final Map<integer, Decimal> PCT_AGENT_PORTION_CONFIG = new Map<integer, Decimal>{
            3 => 50,
            4 => 25,
            5 => 10
    };
}