@isTest(SeeAllData=true)
private class Double_Entry_Transaction_test {
    static testMethod void myTest() {
    
   
   Double_Entry_Transaction.DoubleEntryInputs p_inputs = new Double_Entry_Transaction.DoubleEntryInputs();
   
  
   p_inputs.ccy = 'XXX';
   p_inputs.amount = 1234;
   p_inputs.effective_date = date.newinstance(2017, 11, 17);
   p_inputs.status = 'Confirmed by Operations';
   p_inputs.type = '04.Invoice Capital Repayment';
   p_inputs.trustee = 'Amicorp';
   
   account a = new account();
    a.name = 'To TEST';
    insert a;
    
   
   p_inputs.to_account =a.id;
   
    account b = new account();
    b.name = 'from TEST';
    insert b;
    
   
   
   p_inputs.from_account = b.id;
   
   Double_Entry_Transaction.createTransaction(p_inputs);
     }
    
    
    }