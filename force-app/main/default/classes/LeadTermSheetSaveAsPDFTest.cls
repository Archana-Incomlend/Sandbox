@isTest 
public class LeadTermSheetSaveAsPDFTest 
{
    static testMethod void testMethod1() 
    {
        Lead objLead = new Lead();
        objLead.Salutation = 'Mr.';
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead Supplier';
        objLead.Street = 'st';
        objLead.City = 'ct';
        objLead.State = '';
        objLead.PostalCode = '68135';
        objLead.Status ='Credit Limit Approved from Risk';
        objLead.Company = 'COMPANY LTD';
        objLead.Country = 'United States';
        objLead.Email = 'test@test.com';
        objLead.Title = 'Director';
        objLead.Decision__c = null;
        objLead.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        insert objLead;
        
        Lead objLeadBuyer = new Lead();
        objLeadBuyer.Salutation = 'Mr.';
        objLeadBuyer.FirstName = 'Test';
        objLeadBuyer.LastName = 'Lead Buyer';
        objLeadBuyer.Street = 'st';
        objLeadBuyer.City = 'ct';
        objLeadBuyer.State = '';
        objLeadBuyer.PostalCode = '68135';
        objLeadBuyer.Status ='Credit Limit Approved from Risk';
        objLeadBuyer.Company = 'COMPANY LTD';
        objLeadBuyer.Country = 'United States';
        objLeadBuyer.Email = 'test@test.com';
        objLeadBuyer.Title = 'Director';
        objLeadBuyer.Decision__c = null;
        objLeadBuyer.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        insert objLeadBuyer;
        
        
        Invoice_Opportunity__c objOpp = new Invoice_Opportunity__c();
        objOpp.Lead_Name__c = objLeadBuyer.Id;
        objOpp.Lead_Name_Supplier__c = objLead.Id;
        objOpp.Opportunity_Status__c = 'Pipeline';
        insert objOpp;

        Test.StartTest(); 
        
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            LeadTermSheetSaveAsPDF obj = new LeadTermSheetSaveAsPDF();
            LeadTermSheetSaveAsPDF.WrapperClass objWrapper = new LeadTermSheetSaveAsPDF.WrapperClass(objOpp, true);
            obj.getTotalPages();
            obj.first();
            obj.last();
            obj.previous();
            obj.next() ;
            obj.savePdf();
        Test.StopTest();
    }
    
    
    static testMethod void testMethod2() 
    {
        Lead objLead = new Lead();
        objLead.Salutation = 'Mr.';
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead Supplier';
        objLead.Street = 'st';
        objLead.City = 'ct';
        objLead.State = '';
        objLead.PostalCode = '68135';
        objLead.Status ='Credit Limit Approved from Risk';
        objLead.Company = 'COMPANY LTD';
        objLead.Country = 'United States';
        objLead.Email = 'test@test.com';
        objLead.Title = 'Director';
        objLead.Decision__c = null;
        objLead.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        objLead.CCY__c = 'USD';
        objLead.Company_Activity__c = 'Supplier of Fertilizers & Agricultural Chemicals';
        objLead.Advanced_Amount__c = 'Up to 90% of the invoice face value';
        objLead.Supplier_Discount_Rate__c = 9;
        objLead.First_Invoice_amount__c = 1000000;
        objLead.Average_Funding_Period__c = '90 Days';
        objLead.Processing_Fees__c = 300;
        objLead.Facility_Fees__c = 0.55;
        objLead.Annual_Fees__c = 1500;
        objLead.Annual_Fees_Per_Trade_Partner__c = 500;
        objLead.One_time_fees_for_opening_dedicated_bank__c = 1500;
        objLead.Maintenance_of_dedicated_bank_account__c = 3000;
        insert objLead;
        
        Lead objLeadBuyer = new Lead();
        objLeadBuyer.Salutation = 'Mr.';
        objLeadBuyer.FirstName = 'Test';
        objLeadBuyer.LastName = 'Lead Buyer';
        objLeadBuyer.Street = 'st';
        objLeadBuyer.City = 'ct';
        objLeadBuyer.State = '';
        objLeadBuyer.PostalCode = '68135';
        objLeadBuyer.Status ='Credit Limit Approved from Risk';
        objLeadBuyer.Company = 'COMPANY LTD';
        objLeadBuyer.Country = 'United States';
        objLeadBuyer.Email = 'test@test.com';
        objLeadBuyer.Title = 'Director';
        objLeadBuyer.Decision__c = null;
        objLeadBuyer.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        insert objLeadBuyer;
        
        
        Invoice_Opportunity__c objOpp = new Invoice_Opportunity__c();
        objOpp.Lead_Name__c = objLeadBuyer.Id;
        objOpp.Lead_Name_Supplier__c = objLead.Id;
        objOpp.Opportunity_Status__c = 'Pipeline';
        insert objOpp;

        Test.StartTest(); 
        
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            ApexPages.currentPage().getParameters().put('OppIds',objOpp.Id);
            LeadTermSheetSaveAsPDF obj = new LeadTermSheetSaveAsPDF();
            LeadTermSheetSaveAsPDF.WrapperClass objWrapper = new LeadTermSheetSaveAsPDF.WrapperClass(objOpp, true);
            obj.wrapperRecordList.add(objWrapper);
            obj.blnSelectAll = True;
            obj.updateSearchItemsMap();
            obj.getTotalPages();
            obj.first();
            obj.last();
            obj.previous();
            obj.next() ;
            obj.savePdf();
        Test.StopTest();
    }
    
    static testMethod void testMethod3() 
    {
        Lead objLead = new Lead();
        objLead.Salutation = 'Mr.';
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead Supplier';
        objLead.Street = 'st';
        objLead.City = 'ct';
        objLead.State = '';
        objLead.PostalCode = '68135';
        objLead.Status ='Credit Limit Approved from Risk';
        objLead.Company = 'COMPANY LTD';
        objLead.Country = 'United States';
        objLead.Email = 'test@test.com';
        objLead.Title = 'Director';
        objLead.Decision__c = null;
        objLead.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        //objLead.CCY__c = 'USD';
        //objLead.Company_Activity__c = 'Supplier of Fertilizers & Agricultural Chemicals';
        //objLead.Advanced_Amount__c = 'Up to 90% of the invoice face value';
        //objLead.Supplier_Discount_Rate__c = 9;
        //objLead.First_Invoice_amount__c = 1000000;
        //objLead.Average_Funding_Period__c = '90 Days';
        //objLead.Processing_Fees__c = 300;
        //objLead.Facility_Fees__c = 0.55;
        //objLead.Annual_Fees__c = 1500;
        //objLead.Annual_Fees_Per_Trade_Partner__c = 500;
        //objLead.One_time_fees_for_opening_dedicated_bank__c = 1500;
        //objLead.Maintenance_of_dedicated_bank_account__c = 3000;
        insert objLead;
        
        Lead objLeadBuyer = new Lead();
        objLeadBuyer.Salutation = 'Mr.';
        objLeadBuyer.FirstName = 'Test';
        objLeadBuyer.LastName = 'Lead Buyer';
        objLeadBuyer.Street = 'st';
        objLeadBuyer.City = 'ct';
        objLeadBuyer.State = '';
        objLeadBuyer.PostalCode = '68135';
        objLeadBuyer.Status ='Credit Limit Approved from Risk';
        objLeadBuyer.Company = 'COMPANY LTD';
        objLeadBuyer.Country = 'United States';
        objLeadBuyer.Email = 'test@test.com';
        objLeadBuyer.Title = 'Director';
        objLeadBuyer.Decision__c = null;
        objLeadBuyer.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        insert objLeadBuyer;
        
        
        Invoice_Opportunity__c objOpp = new Invoice_Opportunity__c();
        objOpp.Lead_Name__c = objLeadBuyer.Id;
        objOpp.Lead_Name_Supplier__c = objLead.Id;
        objOpp.Opportunity_Status__c = 'Pipeline';
        insert objOpp;

        Test.StartTest(); 
        
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            ApexPages.currentPage().getParameters().put('OppIds',objOpp.Id);
            LeadTermSheetSaveAsPDF obj = new LeadTermSheetSaveAsPDF();
            obj.getTotalPages();
            obj.first();
            obj.last();
            obj.previous();
            obj.next() ;
            obj.savePdf();
        Test.StopTest();
    }
    
    static testMethod void testMethod4() 
    {
        Lead objLead = new Lead();
        objLead.Salutation = 'Mr.';
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead Supplier';
        objLead.Street = 'st';
        objLead.City = 'ct';
        objLead.State = '';
        objLead.PostalCode = '68135';
        objLead.Status ='Credit Limit Approved from Risk';
        objLead.Company = 'COMPANY LTD';
        objLead.Country = 'United States';
        objLead.Email = 'test@test.com';
        objLead.Title = 'Director';
        objLead.Decision__c = null;
        objLead.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        //objLead.CCY__c = 'USD';
        objLead.Company_Activity__c = 'Supplier of Fertilizers & Agricultural Chemicals';
        objLead.Advanced_Amount__c = 'Up to 90% of the invoice face value';
        objLead.Supplier_Discount_Rate__c = 9;
        objLead.First_Invoice_amount__c = 1000000;
        objLead.Average_Funding_Period__c = '90 Days';
        objLead.Processing_Fees__c = 300;
        objLead.Facility_Fees__c = 0.55;
        objLead.Annual_Fees__c = 1500;
        objLead.Annual_Fees_Per_Trade_Partner__c = 500;
        objLead.One_time_fees_for_opening_dedicated_bank__c = 1500;
        objLead.Maintenance_of_dedicated_bank_account__c = 3000;
        insert objLead;
        
        Lead objLeadBuyer = new Lead();
        objLeadBuyer.Salutation = 'Mr.';
        objLeadBuyer.FirstName = 'Test';
        objLeadBuyer.LastName = 'Lead Buyer';
        objLeadBuyer.Street = 'st';
        objLeadBuyer.City = 'ct';
        objLeadBuyer.State = '';
        objLeadBuyer.PostalCode = '68135';
        objLeadBuyer.Status ='Credit Limit Approved from Risk';
        objLeadBuyer.Company = 'COMPANY LTD';
        objLeadBuyer.Country = 'United States';
        objLeadBuyer.Email = 'test@test.com';
        objLeadBuyer.Title = 'Director';
        objLeadBuyer.Decision__c = null;
        objLeadBuyer.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        insert objLeadBuyer;
        
        
        Invoice_Opportunity__c objOpp = new Invoice_Opportunity__c();
        objOpp.Lead_Name__c = objLeadBuyer.Id;
        objOpp.Lead_Name_Supplier__c = objLead.Id;
        objOpp.Opportunity_Status__c = 'Pipeline';
        insert objOpp;

        Test.StartTest(); 
        
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            ApexPages.currentPage().getParameters().put('OppIds',objOpp.Id);
            LeadTermSheetSaveAsPDF obj = new LeadTermSheetSaveAsPDF();
            obj.getTotalPages();
            obj.first();
            obj.last();
            obj.previous();
            obj.next() ;
            obj.savePdf();
        Test.StopTest();
    }
    
    static testMethod void testMethod5() 
    {
        Lead objLead = new Lead();
        objLead.Salutation = 'Mr.';
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead Supplier';
        objLead.Street = 'st';
        objLead.City = 'ct';
        objLead.State = '';
        objLead.PostalCode = '68135';
        objLead.Status ='Credit Limit Approved from Risk';
        objLead.Company = 'COMPANY LTD';
        objLead.Country = 'United States';
        objLead.Email = 'test@test.com';
        objLead.Title = 'Director';
        objLead.Decision__c = null;
        objLead.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        objLead.CCY__c = 'USD';
        //objLead.Company_Activity__c = 'Supplier of Fertilizers & Agricultural Chemicals';
        objLead.Advanced_Amount__c = 'Up to 90% of the invoice face value';
        objLead.Supplier_Discount_Rate__c = 9;
        objLead.First_Invoice_amount__c = 1000000;
        objLead.Average_Funding_Period__c = '90 Days';
        objLead.Processing_Fees__c = 300;
        objLead.Facility_Fees__c = 0.55;
        objLead.Annual_Fees__c = 1500;
        objLead.Annual_Fees_Per_Trade_Partner__c = 500;
        objLead.One_time_fees_for_opening_dedicated_bank__c = 1500;
        objLead.Maintenance_of_dedicated_bank_account__c = 3000;
        insert objLead;
        
        Lead objLeadBuyer = new Lead();
        objLeadBuyer.Salutation = 'Mr.';
        objLeadBuyer.FirstName = 'Test';
        objLeadBuyer.LastName = 'Lead Buyer';
        objLeadBuyer.Street = 'st';
        objLeadBuyer.City = 'ct';
        objLeadBuyer.State = '';
        objLeadBuyer.PostalCode = '68135';
        objLeadBuyer.Status ='Credit Limit Approved from Risk';
        objLeadBuyer.Company = 'COMPANY LTD';
        objLeadBuyer.Country = 'United States';
        objLeadBuyer.Email = 'test@test.com';
        objLeadBuyer.Title = 'Director';
        objLeadBuyer.Decision__c = null;
        objLeadBuyer.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        insert objLeadBuyer;
        
        
        Invoice_Opportunity__c objOpp = new Invoice_Opportunity__c();
        objOpp.Lead_Name__c = objLeadBuyer.Id;
        objOpp.Lead_Name_Supplier__c = objLead.Id;
        objOpp.Opportunity_Status__c = 'Pipeline';
        insert objOpp;

        Test.StartTest(); 
        
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            ApexPages.currentPage().getParameters().put('OppIds',objOpp.Id);
            LeadTermSheetSaveAsPDF obj = new LeadTermSheetSaveAsPDF();
            obj.getTotalPages();
            obj.first();
            obj.last();
            obj.previous();
            obj.next() ;
            obj.savePdf();
        Test.StopTest();
    }
    
    static testMethod void testMethod6() 
    {
        Lead objLead = new Lead();
        objLead.Salutation = 'Mr.';
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead Supplier';
        objLead.Street = 'st';
        objLead.City = 'ct';
        objLead.State = '';
        objLead.PostalCode = '68135';
        objLead.Status ='Credit Limit Approved from Risk';
        objLead.Company = 'COMPANY LTD';
        objLead.Country = 'United States';
        objLead.Email = 'test@test.com';
        objLead.Title = 'Director';
        objLead.Decision__c = null;
        objLead.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        objLead.CCY__c = 'USD';
        objLead.Company_Activity__c = 'Supplier of Fertilizers & Agricultural Chemicals';
        //objLead.Advanced_Amount__c = 'Up to 90% of the invoice face value';
        objLead.Supplier_Discount_Rate__c = 9;
        objLead.First_Invoice_amount__c = 1000000;
        objLead.Average_Funding_Period__c = '90 Days';
        objLead.Processing_Fees__c = 300;
        objLead.Facility_Fees__c = 0.55;
        objLead.Annual_Fees__c = 1500;
        objLead.Annual_Fees_Per_Trade_Partner__c = 500;
        objLead.One_time_fees_for_opening_dedicated_bank__c = 1500;
        objLead.Maintenance_of_dedicated_bank_account__c = 3000;
        insert objLead;
        
        Lead objLeadBuyer = new Lead();
        objLeadBuyer.Salutation = 'Mr.';
        objLeadBuyer.FirstName = 'Test';
        objLeadBuyer.LastName = 'Lead Buyer';
        objLeadBuyer.Street = 'st';
        objLeadBuyer.City = 'ct';
        objLeadBuyer.State = '';
        objLeadBuyer.PostalCode = '68135';
        objLeadBuyer.Status ='Credit Limit Approved from Risk';
        objLeadBuyer.Company = 'COMPANY LTD';
        objLeadBuyer.Country = 'United States';
        objLeadBuyer.Email = 'test@test.com';
        objLeadBuyer.Title = 'Director';
        objLeadBuyer.Decision__c = null;
        objLeadBuyer.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        insert objLeadBuyer;
        
        
        Invoice_Opportunity__c objOpp = new Invoice_Opportunity__c();
        objOpp.Lead_Name__c = objLeadBuyer.Id;
        objOpp.Lead_Name_Supplier__c = objLead.Id;
        objOpp.Opportunity_Status__c = 'Pipeline';
        insert objOpp;

        Test.StartTest(); 
        
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            ApexPages.currentPage().getParameters().put('OppIds',objOpp.Id);
            LeadTermSheetSaveAsPDF obj = new LeadTermSheetSaveAsPDF();
            LeadTermSheetSaveAsPDF.WrapperClass objWrapper = new LeadTermSheetSaveAsPDF.WrapperClass(objOpp, true);
            
            obj.getTotalPages();
            obj.first();
            obj.last();
            obj.previous();
            obj.next() ;
            obj.savePdf();
        Test.StopTest();
    }
    
    static testMethod void LeadTermSheetExtensionTestMethod() 
    {
        Lead objLead = new Lead();
        objLead.Salutation = 'Mr.';
        objLead.FirstName = 'Test';
        objLead.LastName = 'Lead Supplier';
        objLead.Street = 'st';
        objLead.City = 'ct';
        objLead.State = '';
        objLead.PostalCode = '68135';
        objLead.Status ='Credit Limit Approved from Risk';
        objLead.Company = 'COMPANY LTD';
        objLead.Country = 'United States';
        objLead.Email = 'test@test.com';
        objLead.Title = 'Director';
        objLead.Decision__c = null;
        objLead.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        objLead.CCY__c = 'USD';
        objLead.Company_Activity__c = 'Supplier of Fertilizers & Agricultural Chemicals';
        objLead.Advanced_Amount__c = 'Up to 90% of the invoice face value';
        objLead.Supplier_Discount_Rate__c = 9;
        objLead.First_Invoice_amount__c = 1000000;
        objLead.Average_Funding_Period__c = '90 Days';
        objLead.Processing_Fees__c = 300;
        objLead.Facility_Fees__c = 0.55;
        objLead.Annual_Fees__c = 1500;
        objLead.Annual_Fees_Per_Trade_Partner__c = 500;
        objLead.One_time_fees_for_opening_dedicated_bank__c = 1500;
        objLead.Maintenance_of_dedicated_bank_account__c = 3000;
        insert objLead;
        
        Lead objLeadBuyer = new Lead();
        objLeadBuyer.Salutation = 'Mr.';
        objLeadBuyer.FirstName = 'Test';
        objLeadBuyer.LastName = 'Lead Buyer';
        objLeadBuyer.Street = 'st';
        objLeadBuyer.City = 'ct';
        objLeadBuyer.State = '';
        objLeadBuyer.PostalCode = '68135';
        objLeadBuyer.Status ='Credit Limit Approved from Risk';
        objLeadBuyer.Company = 'COMPANY LTD';
        objLeadBuyer.Country = 'United States';
        objLeadBuyer.Email = 'test@test.com';
        objLeadBuyer.Title = 'Director';
        objLeadBuyer.Decision__c = null;
        objLeadBuyer.Atradius_Cover_Id__c = null;
        objLead.OwnerId = UserInfo.getUserID();
        insert objLeadBuyer;
        
        
        Invoice_Opportunity__c objOpp = new Invoice_Opportunity__c();
        objOpp.Lead_Name__c = objLeadBuyer.Id;
        objOpp.Lead_Name_Supplier__c = objLead.Id;
        objOpp.Opportunity_Status__c = 'Pipeline';
        insert objOpp;
        

        Test.StartTest(); 
        
            ApexPages.currentPage().getParameters().put('Id',objLead.Id);
            ApexPages.currentPage().getParameters().put('OppIds',objOpp.Id);
            LeadTermSheetExtension obj = new LeadTermSheetExtension();
            
        Test.StopTest();
    }
}