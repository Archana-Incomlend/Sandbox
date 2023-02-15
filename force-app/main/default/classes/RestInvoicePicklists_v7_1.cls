@RestResource(urlMapping='/v7.1/invoice/picklists')

global with sharing class RestInvoicePicklists_v7_1 {
      
    @HttpGet
    global static GlobalMethods.ListMapReturnClass doGet() {
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        map<String,List<String>> v_result = new map<String,List<String>> ();
                
        Schema.DescribeFieldResult v_countryOfOriginFieldResult = invoice_finance_deal__c.Country_of_Origin__c.getDescribe();
        v_result.put('countryOfOrigin', GlobalMethods.getPicklistValues(v_countryOfOriginFieldResult));
        
        Schema.DescribeFieldResult v_countryOfDestinationFieldResult = invoice_finance_deal__c.Country_of_Destination__c.getDescribe();
        v_result.put('countryOfDestination', GlobalMethods.getPicklistValues(v_countryOfDestinationFieldResult));
        
        Schema.DescribeFieldResult v_goodsServiceFieldResult = invoice_finance_deal__c.Goods_or_Services_Category__c.getDescribe();
        v_result.put('goodsService', GlobalMethods.getPicklistValues(v_goodsServiceFieldResult));
        
        Schema.DescribeFieldResult v_incotermsFieldResult = invoice_finance_deal__c.Incoterm__c.getDescribe();
        v_result.put('incoterms', GlobalMethods.getPicklistValues(v_incotermsFieldResult));
        
        return new GlobalMethods.ListMapReturnClass('true', 'Query executed successfully.', v_result);
    }
 
}