/*
Author : Sanjay(Techmatrix)
Description: This class is used to populate the FX Rate in the invoice. This is called from a process "FX rate invoice&transaction".
*/
public class PopulateInvoiceFxRateController {
	@InvocableMethod(label='fxRateToInvoice' Description='Method to populate FX Rate in invoice' Category='Invoice')
    public static void fxRateToInvoice(List<FX_Rates__c> fxRate){
        if(!RefreshFXRates.isNeedRunTrigger) return;
        if(fxRate!=null && fxRate.size()>0){
            try {
                List<invoice_finance_deal__c> invFinDealList = [Select id,CCY__c,CCY_TXT__c,FX_Rate__c,advance_send_to_supplier_date__c,Passthrough_auto__c,Actual_Repayment_Received_Date__c from invoice_finance_deal__c where CCY__c!='USD' and (advance_send_to_supplier_date__c=:fxRate[0].date__c or (Passthrough_auto__c=true and Actual_Repayment_Received_Date__c=:fxRate[0].date__c))];
                if(invFinDealList.size()>0){
                    Set<Date> dateForFxRate = new Set<Date>();
                    Set<String> ccyForFxRate = new Set<String>();
                        
                    for(invoice_finance_deal__c invFDeal:invFinDealList){
                        if(invFDeal.Passthrough_auto__c){
                            if(invFDeal.Actual_Repayment_Received_Date__c!=null && invFDeal.CCY__c!=null){
                                dateForFxRate.add(invFDeal.Actual_Repayment_Received_Date__c);
                                ccyForFxRate.add(invFDeal.CCY__c);
                            }
                        }else{
                            if(invFDeal.advance_send_to_supplier_date__c!=null && invFDeal.CCY__c!=null){
                                dateForFxRate.add(invFDeal.advance_send_to_supplier_date__c);
                                ccyForFxRate.add(invFDeal.CCY__c);
                            }
                        }
                    }
                    
                    List<FX_Rates__c> fxRateList = [Select id,Name,Rate__c,from_currency__c,to_currency__c,date__c from FX_Rates__c where date__c in:dateForFxRate and from_currency__c in:ccyForFxRate Order by date__c desc];
                    if(fxRateList.size()>0){
                        Map<string,Map<Date,FX_Rates__c>> currencyDateFxRateMap = new Map<string,Map<Date,FX_Rates__c>>();
                        for(FX_Rates__c frate: fxRateList){
                            Map<Date,FX_Rates__c> tempMap = new Map<Date,FX_Rates__c>();
                            if(currencyDateFxRateMap.containsKey(frate.from_currency__c)){
                                tempMap = currencyDateFxRateMap.get(frate.from_currency__c);
                            }
                            
                            if(!tempMap.containsKey(frate.date__c)){
                                tempMap.put(frate.date__c, frate);
                                currencyDateFxRateMap.put(frate.from_currency__c,tempMap);
                            }
                        }
                        
                        List<invoice_finance_deal__c> updateInvFDealList = new List<invoice_finance_deal__c>();
                        for(invoice_finance_deal__c invFDeal:invFinDealList){
                            if(currencyDateFxRateMap.containsKey(invFDeal.CCY__c)){
                                Map<Date,FX_Rates__c> dateFxRateMap = currencyDateFxRateMap.get(invFDeal.CCY__c);
                                if(invFDeal.Passthrough_auto__c){
                                    if(dateFxRateMap.containsKey(invFDeal.Actual_Repayment_Received_Date__c)){
                                        FX_Rates__c fRate = dateFxRateMap.get(invFDeal.Actual_Repayment_Received_Date__c);
                                        invFDeal.FX_Rate__c = fRate.Id;
                                        invFDeal.FX_conversion_rate__c = fRate.rate__c;
                                        updateInvFDealList.add(invFDeal);
                                    }
                                }else{
                                    if(dateFxRateMap.containsKey(invFDeal.advance_send_to_supplier_date__c)){
                                        FX_Rates__c fRate = dateFxRateMap.get(invFDeal.advance_send_to_supplier_date__c);
                                        invFDeal.FX_Rate__c = fRate.Id;
                                        invFDeal.FX_conversion_rate__c = fRate.rate__c;
                                        updateInvFDealList.add(invFDeal);
                                    }
                                }
                            }    
                        }
                        
                        if(updateInvFDealList.size()>0){
                            update updateInvFDealList;
                        }
                    }
                }
            } catch (Exception ex) {
                RefreshFXRates.OutLog('Error in update rate to invoice', fxRate, ex.getMessage());
            }    
        }
    }
}