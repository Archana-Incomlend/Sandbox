/*
Author : Sanjay(Techmatrix)
Description: This class is used to populate the FX Rate in the transaction. This is called from a process "FX rate invoice&transaction".
*/
public without sharing class PopulateTransactionFxRateController {
	@InvocableMethod(label='fxRateToTransaction' Description='Method to populate FX Rate in Transaction' Category='Transaction')
    public static void fxRateToTransaction(List<FX_Rates__c> fxRate){
        if(!RefreshFXRates.isNeedRunTrigger) return;
        if(fxRate!=null && fxRate.size()>0){
            try {
                List<FX_Rates__c> fxRateList = [Select id,date__c,from_currency__c,to_currency__c,rate__c from FX_Rates__c where date__c=:fxRate[0].date__c];
                if(fxRateList.size()>0){
                    List<Transaction__c> transList = [select id,CCY_TXT__c,CCY__c,Effective_Date__c,Amount__c,amount_USD_equiv__c,FX_rate_conversion__c,Amount_USD_Equiv_daily_fx__c,FX_USD_Rate_Daily__c,Amount_USD_FX_empty__c,FX_conversion_rate_calculated__c from Transaction__c where CCY__c!='USD' and Effective_Date__c=:fxRate[0].date__c and FX_conversion_rate_calculated__c=0];
                    if(transList.size()>0){
                        Map<string,FX_Rates__c> fromCurrencFxRateMap = new Map<string,FX_Rates__c>();
                        for(FX_Rates__c frt:fxRateList){
                            fromCurrencFxRateMap.put(frt.from_currency__c,frt);
                        }
                        
                        for(Transaction__c tran:transList){
                            if(fromCurrencFxRateMap.containsKey(tran.CCY__c)){
                                FX_Rates__c frt = fromCurrencFxRateMap.get(tran.CCY__c);
                                tran.FX_rate_conversion__c = frt.rate__c;
                            }
                        }
                        
                        database.update(transList,false);
                        
                        transList = [Select id,CCY__c,FX_USD_Rate_Daily__c from Transaction__c where Id in:transList];
                        
                        for(Transaction__c tran:transList){
                            if(fromCurrencFxRateMap.containsKey(tran.CCY__c)){
                                tran.Amount_USD_Equiv_daily_fx__c = tran.FX_USD_Rate_Daily__c;
                                system.debug('Test==='+tran.Amount_USD_Equiv_daily_fx__c+'----'+tran.FX_USD_Rate_Daily__c);
                            }
                        }
                        
                        database.update(transList,false);
                    }
                }    
            } catch (Exception ex) {
                RefreshFXRates.OutLog('Error in update rate to invoice', fxRate, ex.getMessage());
            }    
        }
    }
}