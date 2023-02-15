@RestResource(urlMapping='/v9/invoice/picklists')

global with sharing class RestInvoicePicklists_v9 {
      
    @HttpGet
    global static GlobalMethods_v9.ListMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        map<String,List<String>> v_result = new map<String,List<String>> ();
                
        Schema.DescribeFieldResult v_countryOfOriginFieldResult = invoice_finance_deal__c.Country_of_Origin__c.getDescribe();
        v_result.put('countryOfOrigin', GlobalMethods_v9.getPicklistValues(v_countryOfOriginFieldResult));
        
        Schema.DescribeFieldResult v_countryOfDestinationFieldResult = invoice_finance_deal__c.Country_of_Destination__c.getDescribe();
        v_result.put('countryOfDestination', GlobalMethods_v9.getPicklistValues(v_countryOfDestinationFieldResult));
        
        Schema.DescribeFieldResult v_goodsServiceFieldResult = invoice_finance_deal__c.Goods_or_Services_Category__c.getDescribe();
        v_result.put('goodsService', GlobalMethods_v9.getPicklistValues(v_goodsServiceFieldResult));
        
        Schema.DescribeFieldResult v_sectorFieldResult = invoice_finance_deal__c.sector__c.getDescribe();
        v_result.put('sector', GlobalMethods_v9.getPicklistValues(v_sectorFieldResult));
        
        Schema.DescribeFieldResult v_carrierNameShipfinFieldResult = invoice_finance_deal__c.Carrier_Name__c.getDescribe();
        v_result.put('carrierNameShipfin', GlobalMethods_v9.getPicklistValues(v_carrierNameShipfinFieldResult));

        Schema.DescribeFieldResult v_carrierNameIclFieldResult = invoice_finance_deal__c.Carrier_name_icl__c.getDescribe();
        v_result.put('carrierNameIcl', GlobalMethods_v9.getPicklistValues(v_carrierNameIclFieldResult));
        
        Schema.DescribeFieldResult v_incotermsFieldResult = invoice_finance_deal__c.Incoterm__c.getDescribe();
        v_result.put('incoterms', GlobalMethods_v9.getPicklistValues(v_incotermsFieldResult));

        Schema.DescribeFieldResult v_finalDestinationFieldResult = invoice_finance_deal__c.Final_destination__c.getDescribe();
        v_result.put('finalDestination', GlobalMethods_v9.getPicklistValues(v_finalDestinationFieldResult));

         Schema.DescribeFieldResult v_portDischargeFieldResult = invoice_finance_deal__c.Port_of_discharge__c.getDescribe();
        v_result.put('portDischarge', GlobalMethods_v9.getPicklistValues(v_portDischargeFieldResult));

         Schema.DescribeFieldResult v_portLoadingFieldResult = invoice_finance_deal__c.Port_of_loading__c.getDescribe();
        v_result.put('portLoading', GlobalMethods_v9.getPicklistValues(v_portLoadingFieldResult));
        
        return new GlobalMethods_v9.ListMapReturnClass('true', 'Query executed successfully.', v_result);
    }
 
}