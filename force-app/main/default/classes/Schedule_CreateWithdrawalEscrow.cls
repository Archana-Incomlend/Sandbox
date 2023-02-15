global class Schedule_CreateWithdrawalEscrow implements Schedulable

{
    global void execute(SchedulableContext SC)
    {
        createWithdrawalEscrow();
    }
    
    static public void createWithdrawalEscrow()
    {
        List<String> accountNameList = new List<String>{
                                       'SHELFORD S.C.A SICAV-RAIF - Sub-Fund INCOMLEND',
                                       'KWAN CHIH TSUNG',
                                       'Fasanara - Generali',
                                       'Fasanara - TFF',
                                       'Fasanara - DEIFF',
                                       'Fasanara - Fintech',
                                       'Fasanara - GDADF',
                                       'Fasanara - CGM FASANARA FUND',
                                       'Helicap Fund I Pte Ltd',
                                       'FASANARA DIGITAL LENDING FUND - FDLF',
                                       'Fasanara - TRF'};  
        
        List<eWallet_Trustee__c> eWalletList = [select Available_Balance__c, Account__c, CCY__c, Trustee__c, Account__r.Name, Main_eWallet__c
                                              from eWallet_Trustee__c  
                                              where Account__r.Name IN :accountNameList
											  AND Trustee__c = 'Amicorp Escrow'];
        
        List<Withdrawal_Deposit__c> withdrawalList = new List<Withdrawal_Deposit__c>();
    
        for(eWallet_Trustee__c eWallet : eWalletList)
        {
            if (eWallet.Available_Balance__c > 0) {
                Withdrawal_Deposit__c wd = new Withdrawal_Deposit__c();
                wd.Account__c = eWallet.Account__c;
                wd.eWallet__c = eWallet.Main_eWallet__c;
                wd.Type__c = '80.Withdrawal';
                wd.Status__c = 'Not Processed';
                wd.CCY__c = eWallet.CCY__c;
                wd.Amount__c = eWallet.Available_Balance__c;
                wd.Trustee__c = eWallet.Trustee__c;
                //wd.Bank_Account__c = [SELECT Id, Currency__c, Account__c  FROM Bank_Account__c WHERE Currency__c =: eWallet.CCY__c AND Account__c =: eWallet.Account__c].get(0).Id;
                wd.Notes__c = 'Migration of funds from Escrow to Trust';
                
                withdrawalList.add(wd);
            }
        }
        insert withdrawalList;
                
    }
}