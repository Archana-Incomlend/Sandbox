@isTest
private class Test_RestPostUploadInvoiceDoc {

  static testMethod void testDoPost() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.InvoiceDocReturnClass v_results;
    
    ID supplierAccountId = seedincomlenddata.seedAll();
    ID userContactId = seedincomlenddata.createSupplierContact(supplierAccountId);
    ID supplierInvoiceID = seedincomlenddata.makeInvoiceSupplier(1, supplierAccountId);
    ID invoiceID = seedincomlenddata.makeInvoiceBuyer(1,supplierAccountId);
    
    Invoice_Finance_Deal__c invoiceData = [SELECT Id, Supplier_Buyer_Map__c FROM invoice_finance_deal__c WHERE Id = :invoiceID];    
    ID SupplierBuyerMapID = invoiceData.Supplier_Buyer_Map__c;
    
    Map_Supporting_Doc__c objMapSupportingDoc = new Map_Supporting_Doc__c();
    objMapSupportingDoc.Supplier_Buyer_Map__c = SupplierBuyerMapID;
    objMapSupportingDoc.Document_Type__c = 'Invoice Example';
    objMapSupportingDoc.Required_from__c = 'Supplier';
    insert objMapSupportingDoc;
    
    Blob fileBody = EncodingUtil.base64Decode('iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9AQAAAACn+1GIAAACbElEQVR4nNVVwWoTURQ9Ly/NVBiaZpfCtC/YhbjL6CZDYVJBuvUXoukHRNKFi0BG48JCodkKKfE3CmJnKky6aVqXLtQJI8RNadIUnKnTua7VV3xLfcvLPYd77j33Pkb45cUZ/Pb+nYDHFl+O8M1bP+w+ZyUliEau/rZU0Q4aDUHSDMrQ2WZwZK7tOtdZlTqyANBtl+Lz7wXn5ozNkacV1s7nXiuKYym6higOjwsTnqhBYrbeLH1dwv0DZ8QkGSCitCH42K5UiYiiv5OCfOQTBOTC3HW4BAJyzSmRQKV64qAulEgHbn63b0R+Lk9hIq3jyjwfeeP5B1F5aq2qzZaWF3kn1qLDCx5uBnItdt4JopydTyBUKs3iCqdPaDVrvbq7xT9x2TawSZk/TmJ69lkHVzMMrczeadfYvrp9WRsJJXE5c9JFMn668cXY70n6AUrNk1loUNVdaPZkg5JAYtduOoGWy1VniSHpB8ibnlDAyYoWWvVQbbYRS9tBAFcjx2hJSV2wnXpIVd+kQLHSFOYOqKhFNmpyUr8MnRvko9ymjiIpm1I/gUVDqNkBFLFhnkTRr5iTWku6DVF10kCoMaJOT4k0gyNvRRfLhQONbUuNm0XOxiX4eP1i497oTe+j0v148cG4Xor359+L1VBCmgGqkwbCO7dS+3LJUlkxkM/clkAx9stATSqfKAXCsWt5s0Q2KKkd8o4gMUhZpyekpAMaNkMiil2eyDKkZxz6Htj83KOz7EOVrQT5bNjg4TiyJnpddhxBPhvqbU6DiCVQMm4WLD3d6hvM/nGs9YIb5C/wfiJcNpUf2D8C7L/5on8Cl7RBUvin/moAAAAASUVORK5CYII=');
    
    RestPostUploadInvoiceDoc.fromJSON objJason = new RestPostUploadInvoiceDoc.fromJSON();
    objJason.InvoiceId = invoiceID;
    objJason.MapSupportingDocId = objMapSupportingDoc.Id;
    objJason.FileName = 'Test.png';
    objJason.File = fileBody;
    
    String jsonString = JSON.serialize(objJason);
    req.requestURI = v_baseUrl+'/v9/UploadInvoiceDoc';   
    req.requestBody = Blob.valueof(jsonString);
    RestContext.request = req;
    RestContext.response= res;
    RestPostUploadInvoiceDoc.doPost();
    
  }
  
  static testMethod void testDoPost1() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.InvoiceDocReturnClass v_results;
    
    ID supplierAccountId = seedincomlenddata.seedAll();
    ID userContactId = seedincomlenddata.createSupplierContact(supplierAccountId);
    ID supplierInvoiceID = seedincomlenddata.makeInvoiceSupplier(1, supplierAccountId);
    ID invoiceID = seedincomlenddata.makeInvoiceBuyer(1,supplierAccountId);
    
    Invoice_Finance_Deal__c invoiceData = [SELECT Id, Supplier_Buyer_Map__c FROM invoice_finance_deal__c WHERE Id = :invoiceID];    
    ID SupplierBuyerMapID = invoiceData.Supplier_Buyer_Map__c;
    
    Map_Supporting_Doc__c objMapSupportingDoc = new Map_Supporting_Doc__c();
    objMapSupportingDoc.Supplier_Buyer_Map__c = SupplierBuyerMapID;
    objMapSupportingDoc.Document_Type__c = 'Invoice Example';
    objMapSupportingDoc.Required_from__c = 'Supplier';
    insert objMapSupportingDoc;
    
    Blob fileBody = EncodingUtil.base64Decode('iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9AQAAAACn+1GIAAACbElEQVR4nNVVwWoTURQ9Ly/NVBiaZpfCtC/YhbjL6CZDYVJBuvUXoukHRNKFi0BG48JCodkKKfE3CmJnKky6aVqXLtQJI8RNadIUnKnTua7VV3xLfcvLPYd77j33Pkb45cUZ/Pb+nYDHFl+O8M1bP+w+ZyUliEau/rZU0Q4aDUHSDMrQ2WZwZK7tOtdZlTqyANBtl+Lz7wXn5ozNkacV1s7nXiuKYym6higOjwsTnqhBYrbeLH1dwv0DZ8QkGSCitCH42K5UiYiiv5OCfOQTBOTC3HW4BAJyzSmRQKV64qAulEgHbn63b0R+Lk9hIq3jyjwfeeP5B1F5aq2qzZaWF3kn1qLDCx5uBnItdt4JopydTyBUKs3iCqdPaDVrvbq7xT9x2TawSZk/TmJ69lkHVzMMrczeadfYvrp9WRsJJXE5c9JFMn668cXY70n6AUrNk1loUNVdaPZkg5JAYtduOoGWy1VniSHpB8ibnlDAyYoWWvVQbbYRS9tBAFcjx2hJSV2wnXpIVd+kQLHSFOYOqKhFNmpyUr8MnRvko9ymjiIpm1I/gUVDqNkBFLFhnkTRr5iTWku6DVF10kCoMaJOT4k0gyNvRRfLhQONbUuNm0XOxiX4eP1i497oTe+j0v148cG4Xor359+L1VBCmgGqkwbCO7dS+3LJUlkxkM/clkAx9stATSqfKAXCsWt5s0Q2KKkd8o4gMUhZpyekpAMaNkMiil2eyDKkZxz6Htj83KOz7EOVrQT5bNjg4TiyJnpddhxBPhvqbU6DiCVQMm4WLD3d6hvM/nGs9YIb5C/wfiJcNpUf2D8C7L/5on8Cl7RBUvin/moAAAAASUVORK5CYII=');
    
    RestPostUploadInvoiceDoc.fromJSON objJason = new RestPostUploadInvoiceDoc.fromJSON();
    objJason.InvoiceId = '';
    objJason.MapSupportingDocId = objMapSupportingDoc.Id;
    objJason.FileName = 'Test.png';
    objJason.File = fileBody;
    
    String jsonString = JSON.serialize(objJason);
    
    req.requestURI = v_baseUrl+'/v9/UploadInvoiceDoc';   
    req.requestBody = Blob.valueof(jsonString);
    RestContext.request = req;
    RestContext.response= res;
    RestPostUploadInvoiceDoc.doPost();
    
  }
  
  static testMethod void testDoPost2() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.InvoiceDocReturnClass v_results;
    
    ID supplierAccountId = seedincomlenddata.seedAll();
    ID userContactId = seedincomlenddata.createSupplierContact(supplierAccountId);
    ID supplierInvoiceID = seedincomlenddata.makeInvoiceSupplier(1, supplierAccountId);
    ID invoiceID = seedincomlenddata.makeInvoiceBuyer(1,supplierAccountId);
    
    Invoice_Finance_Deal__c invoiceData = [SELECT Id, Supplier_Buyer_Map__c FROM invoice_finance_deal__c WHERE Id = :invoiceID];    
    ID SupplierBuyerMapID = invoiceData.Supplier_Buyer_Map__c;
    
    Map_Supporting_Doc__c objMapSupportingDoc = new Map_Supporting_Doc__c();
    objMapSupportingDoc.Supplier_Buyer_Map__c = SupplierBuyerMapID;
    objMapSupportingDoc.Document_Type__c = 'Invoice Example';
    objMapSupportingDoc.Required_from__c = 'Supplier';
    insert objMapSupportingDoc;
    
    Blob fileBody = EncodingUtil.base64Decode('iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9AQAAAACn+1GIAAACbElEQVR4nNVVwWoTURQ9Ly/NVBiaZpfCtC/YhbjL6CZDYVJBuvUXoukHRNKFi0BG48JCodkKKfE3CmJnKky6aVqXLtQJI8RNadIUnKnTua7VV3xLfcvLPYd77j33Pkb45cUZ/Pb+nYDHFl+O8M1bP+w+ZyUliEau/rZU0Q4aDUHSDMrQ2WZwZK7tOtdZlTqyANBtl+Lz7wXn5ozNkacV1s7nXiuKYym6higOjwsTnqhBYrbeLH1dwv0DZ8QkGSCitCH42K5UiYiiv5OCfOQTBOTC3HW4BAJyzSmRQKV64qAulEgHbn63b0R+Lk9hIq3jyjwfeeP5B1F5aq2qzZaWF3kn1qLDCx5uBnItdt4JopydTyBUKs3iCqdPaDVrvbq7xT9x2TawSZk/TmJ69lkHVzMMrczeadfYvrp9WRsJJXE5c9JFMn668cXY70n6AUrNk1loUNVdaPZkg5JAYtduOoGWy1VniSHpB8ibnlDAyYoWWvVQbbYRS9tBAFcjx2hJSV2wnXpIVd+kQLHSFOYOqKhFNmpyUr8MnRvko9ymjiIpm1I/gUVDqNkBFLFhnkTRr5iTWku6DVF10kCoMaJOT4k0gyNvRRfLhQONbUuNm0XOxiX4eP1i497oTe+j0v148cG4Xor359+L1VBCmgGqkwbCO7dS+3LJUlkxkM/clkAx9stATSqfKAXCsWt5s0Q2KKkd8o4gMUhZpyekpAMaNkMiil2eyDKkZxz6Htj83KOz7EOVrQT5bNjg4TiyJnpddhxBPhvqbU6DiCVQMm4WLD3d6hvM/nGs9YIb5C/wfiJcNpUf2D8C7L/5on8Cl7RBUvin/moAAAAASUVORK5CYII=');
    
    RestPostUploadInvoiceDoc.fromJSON objJason = new RestPostUploadInvoiceDoc.fromJSON();
    objJason.InvoiceId = invoiceData.Id;
    objJason.MapSupportingDocId = '';
    objJason.FileName = 'Test.png';
    objJason.File = fileBody;
    
    String jsonString = JSON.serialize(objJason);
    
    req.requestURI = v_baseUrl+'/v9/UploadInvoiceDoc';   
    req.requestBody = Blob.valueof(jsonString);
    RestContext.request = req;
    RestContext.response= res;
    RestPostUploadInvoiceDoc.doPost();
    
  }
  
   static testMethod void testDoPost3() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.InvoiceDocReturnClass v_results;
    
    ID supplierAccountId = seedincomlenddata.seedAll();
    ID userContactId = seedincomlenddata.createSupplierContact(supplierAccountId);
    ID supplierInvoiceID = seedincomlenddata.makeInvoiceSupplier(1, supplierAccountId);
    ID invoiceID = seedincomlenddata.makeInvoiceBuyer(1,supplierAccountId);
    
    Invoice_Finance_Deal__c invoiceData = [SELECT Id, Supplier_Buyer_Map__c FROM invoice_finance_deal__c WHERE Id = :invoiceID];    
    ID SupplierBuyerMapID = invoiceData.Supplier_Buyer_Map__c;
    
    Map_Supporting_Doc__c objMapSupportingDoc = new Map_Supporting_Doc__c();
    objMapSupportingDoc.Supplier_Buyer_Map__c = SupplierBuyerMapID;
    objMapSupportingDoc.Document_Type__c = 'Invoice Example';
    objMapSupportingDoc.Required_from__c = 'Supplier';
    insert objMapSupportingDoc;
    
    Blob fileBody = EncodingUtil.base64Decode('iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9AQAAAACn+1GIAAACbElEQVR4nNVVwWoTURQ9Ly/NVBiaZpfCtC/YhbjL6CZDYVJBuvUXoukHRNKFi0BG48JCodkKKfE3CmJnKky6aVqXLtQJI8RNadIUnKnTua7VV3xLfcvLPYd77j33Pkb45cUZ/Pb+nYDHFl+O8M1bP+w+ZyUliEau/rZU0Q4aDUHSDMrQ2WZwZK7tOtdZlTqyANBtl+Lz7wXn5ozNkacV1s7nXiuKYym6higOjwsTnqhBYrbeLH1dwv0DZ8QkGSCitCH42K5UiYiiv5OCfOQTBOTC3HW4BAJyzSmRQKV64qAulEgHbn63b0R+Lk9hIq3jyjwfeeP5B1F5aq2qzZaWF3kn1qLDCx5uBnItdt4JopydTyBUKs3iCqdPaDVrvbq7xT9x2TawSZk/TmJ69lkHVzMMrczeadfYvrp9WRsJJXE5c9JFMn668cXY70n6AUrNk1loUNVdaPZkg5JAYtduOoGWy1VniSHpB8ibnlDAyYoWWvVQbbYRS9tBAFcjx2hJSV2wnXpIVd+kQLHSFOYOqKhFNmpyUr8MnRvko9ymjiIpm1I/gUVDqNkBFLFhnkTRr5iTWku6DVF10kCoMaJOT4k0gyNvRRfLhQONbUuNm0XOxiX4eP1i497oTe+j0v148cG4Xor359+L1VBCmgGqkwbCO7dS+3LJUlkxkM/clkAx9stATSqfKAXCsWt5s0Q2KKkd8o4gMUhZpyekpAMaNkMiil2eyDKkZxz6Htj83KOz7EOVrQT5bNjg4TiyJnpddhxBPhvqbU6DiCVQMm4WLD3d6hvM/nGs9YIb5C/wfiJcNpUf2D8C7L/5on8Cl7RBUvin/moAAAAASUVORK5CYII=');
    
    RestPostUploadInvoiceDoc.fromJSON objJason = new RestPostUploadInvoiceDoc.fromJSON();
    objJason.InvoiceId = invoiceData.Id;
    objJason.MapSupportingDocId = objMapSupportingDoc.Id;
    objJason.FileName = '';
    objJason.File = fileBody;
    
    String jsonString = JSON.serialize(objJason);
    
    req.requestURI = v_baseUrl+'/v9/UploadInvoiceDoc';   
    req.requestBody = Blob.valueof(jsonString);
    RestContext.request = req;
    RestContext.response= res;
    RestPostUploadInvoiceDoc.doPost();
    
   }
    
    static testMethod void testDoPost4() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    String v_baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res;
    GlobalMethods_v9.InvoiceDocReturnClass v_results;
    
    ID supplierAccountId = seedincomlenddata.seedAll();
    ID userContactId = seedincomlenddata.createSupplierContact(supplierAccountId);
    ID supplierInvoiceID = seedincomlenddata.makeInvoiceSupplier(1, supplierAccountId);
    ID invoiceID = seedincomlenddata.makeInvoiceBuyer(1,supplierAccountId);
    
    Invoice_Finance_Deal__c invoiceData = [SELECT Id, Supplier_Buyer_Map__c FROM invoice_finance_deal__c WHERE Id = :invoiceID];    
    ID SupplierBuyerMapID = invoiceData.Supplier_Buyer_Map__c;
    
    Map_Supporting_Doc__c objMapSupportingDoc = new Map_Supporting_Doc__c();
    objMapSupportingDoc.Supplier_Buyer_Map__c = SupplierBuyerMapID;
    objMapSupportingDoc.Document_Type__c = 'Invoice Example';
    objMapSupportingDoc.Required_from__c = 'Supplier';
    insert objMapSupportingDoc;
    
    Blob fileBody = EncodingUtil.base64Decode('iVBORw0KGgoAAAANSUhEUgAAAH0AAAB9AQAAAACn+1GIAAACbElEQVR4nNVVwWoTURQ9Ly/NVBiaZpfCtC/YhbjL6CZDYVJBuvUXoukHRNKFi0BG48JCodkKKfE3CmJnKky6aVqXLtQJI8RNadIUnKnTua7VV3xLfcvLPYd77j33Pkb45cUZ/Pb+nYDHFl+O8M1bP+w+ZyUliEau/rZU0Q4aDUHSDMrQ2WZwZK7tOtdZlTqyANBtl+Lz7wXn5ozNkacV1s7nXiuKYym6higOjwsTnqhBYrbeLH1dwv0DZ8QkGSCitCH42K5UiYiiv5OCfOQTBOTC3HW4BAJyzSmRQKV64qAulEgHbn63b0R+Lk9hIq3jyjwfeeP5B1F5aq2qzZaWF3kn1qLDCx5uBnItdt4JopydTyBUKs3iCqdPaDVrvbq7xT9x2TawSZk/TmJ69lkHVzMMrczeadfYvrp9WRsJJXE5c9JFMn668cXY70n6AUrNk1loUNVdaPZkg5JAYtduOoGWy1VniSHpB8ibnlDAyYoWWvVQbbYRS9tBAFcjx2hJSV2wnXpIVd+kQLHSFOYOqKhFNmpyUr8MnRvko9ymjiIpm1I/gUVDqNkBFLFhnkTRr5iTWku6DVF10kCoMaJOT4k0gyNvRRfLhQONbUuNm0XOxiX4eP1i497oTe+j0v148cG4Xor359+L1VBCmgGqkwbCO7dS+3LJUlkxkM/clkAx9stATSqfKAXCsWt5s0Q2KKkd8o4gMUhZpyekpAMaNkMiil2eyDKkZxz6Htj83KOz7EOVrQT5bNjg4TiyJnpddhxBPhvqbU6DiCVQMm4WLD3d6hvM/nGs9YIb5C/wfiJcNpUf2D8C7L/5on8Cl7RBUvin/moAAAAASUVORK5CYII=');
    
    RestPostUploadInvoiceDoc.fromJSON objJason = new RestPostUploadInvoiceDoc.fromJSON();
    objJason.InvoiceId = invoiceData.Id;
    objJason.MapSupportingDocId = objMapSupportingDoc.Id;
    objJason.FileName = 'Test.Png';

    
    String jsonString = JSON.serialize(objJason);
    
    req.requestURI = v_baseUrl+'/v9/UploadInvoiceDoc';   
    req.requestBody = Blob.valueof(jsonString);
    RestContext.request = req;
    RestContext.response= res;
    RestPostUploadInvoiceDoc.doPost();
    
  }
}