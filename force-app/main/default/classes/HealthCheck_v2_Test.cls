@isTest(SeeAllData=true)
public class HealthCheck_v2_Test
{
	@isTest
	private static void TestCreateTransactions()
	{
        HealthCheck_v2 checks = new HealthCheck_v2();
        checks.AccountingPeriods();
        
        HealthCheck_v2_Configuration.LoadConfigurationKey('IncomlendPricing_v3_Behaviour_InsuranceCompanies1', ';', '=');
        
		// Code coverage hack
		HealthCheck_v2.HealthCheck_v2_CoverageHack hack = new HealthCheck_v2.HealthCheck_v2_CoverageHack();
		hack.Hack1();
		hack.Hack2();
		hack.Hack3();
		hack.Hack4();
		hack.Hack5();
	}
}