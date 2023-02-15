global class Double_Entry_Transaction
{

        @InvocableMethod
        public static list<id> createTransaction(list<DoubleEntryInputs> p_inputs)
        {

                //  for(Transaction__c v_input : p_inputs)
                //      {
                //         to_ids.add(createTransaction(v_input) ) ;
                //     }
                createTransaction(p_inputs.get(0));

                return null;
        }

        public static ID createTransaction(DoubleEntryInputs p_inputs)
        {
         ID v_Accounting_period ;
                if (p_inputs.accounting_period == null)
                {
               v_Accounting_period = Accounting_Period.lookup(p_inputs.effective_date );
               }
               else
               { v_Accounting_period = p_inputs.accounting_period;}
               
                Transaction__c from_t = new Transaction__c();
                Transaction__c to_t = new Transaction__c();

                to_t.accounting_period__c = v_Accounting_period;
                to_t.eWallet__c = eWallet.lookup( p_inputs.ccy,p_inputs.to_account);
                to_t.eWallet_Trustee__c = [select id from eWallet_Trustee__c where account__c=:p_inputs.to_account AND ccy__c =:p_inputs.ccy AND Trustee__c =: p_inputs.trustee].get(0).Id;
                to_t.Trustee__c = p_inputs.trustee;
                to_t.account__c = p_inputs.to_account;
                to_t.ccy__c = p_inputs.ccy;
                to_t.amount__c = p_inputs.amount;

                if ( p_inputs.ccy == 'USD')
                {       to_t.Amount_USD_Equiv_daily_fx__c = to_t.amount__c;}
                else { to_t.Amount_USD_Equiv_daily_fx__c = 0;} //todo: lookup the right FX rate

                to_t.effective_date__c = p_inputs.effective_date;
                to_t.status__C = p_inputs.status;
                to_t.type__c = p_inputs.type;
                to_t.notes__c = p_inputs.notes;

                to_t.Withdrawal_Deposit_unique_index__c=p_inputs.Withdrawal_Deposit;
                to_t.Withdrawal_Deposit__c=p_inputs.Withdrawal_Deposit;
                to_t.Invoice_Allocation__c=p_inputs.Invoice_Allocation;
                to_t.Bank_Account__c=p_inputs.Bank_Account;
                to_t.Invoice_Finance_Deal__c=p_inputs.Invoice_Finance_Deal;
                to_t.Offer__c=p_inputs.Offer;

                to_t.previous_transaction__c = [select ID from transaction__C order by createddate desc, name desc limit 1].get(0).id;

                insert to_t;

                if (p_inputs.type != '70.Deposit' && p_inputs.type != '80.Withdrawal') {
                        from_t.accounting_period__c = v_Accounting_period;
                        from_t.eWallet__c = eWallet.lookup(p_inputs.ccy, p_inputs.from_account);
                        from_t.eWallet_Trustee__c = [select id from eWallet_Trustee__c where account__c=:p_inputs.from_account AND ccy__c =:p_inputs.ccy AND Trustee__c =: p_inputs.trustee].get(0).Id;
                        from_t.Trustee__c = p_inputs.trustee;

                        from_t.account__c = p_inputs.from_account;
                        from_t.ccy__c = to_t.ccy__c;
                        from_t.amount__c = to_t.amount__c * -1;
                        from_t.Amount_USD_Equiv_daily_fx__c = to_t.Amount_USD_Equiv_daily_fx__c * -1;

                        from_t.effective_date__c = to_t.effective_date__C;
                        from_t.status__C = to_t.status__c;
                        from_t.type__c = to_t.type__c;
                        from_t.notes__c = to_t.notes__c;

                       from_t.Withdrawal_Deposit_unique_index__c=to_t.Withdrawal_Deposit_Unique_index__c;
                        from_t.Withdrawal_Deposit__c=to_t.Withdrawal_Deposit__c;
                        from_t.Invoice_Allocation__c=to_t.Invoice_Allocation__c;
                        from_t.Bank_Account__c=to_t.Bank_Account__c;
                        from_t.Invoice_Finance_Deal__c=to_t.Invoice_Finance_Deal__c;
                        from_t.Offer__c=to_t.Offer__c;

                        from_t.Related_Transaction__c = to_t.id;
                        from_t.transaction_link_id__c = to_t.id;
                        from_t.previous_transaction__c = to_t.id;
                        insert from_t;

                        to_t.Related_Transaction__c = from_t.id;
                        update to_t;
                }



                to_t.hash__c = gethash(makeHash(to_t));

                update to_t;

                if (p_inputs.type != '70.Deposit' && p_inputs.type != '80.Withdrawal') {
                        from_t.hash__c = gethash(makehash(from_t));
                        update from_t;
                }

                return to_t.id;

        }

        public static string makeHash( transaction__C t)
        {
        
       
                string hashstring = '' +
                                    t.Related_Transaction__c +
                                    t.accounting_period__C  +
                                    t.eWallet__c +
                                    t.eWallet_Trustee__c + 
                                    t.account__c +
                                    t.Withdrawal_Deposit_Unique_index__c +
                                    t.Withdrawal_Deposit__c +
                                    t.Invoice_Allocation__c +
                                    t.Bank_Account__c +
                                    t.Invoice_Finance_Deal__c +
                                    t.Offer__c +
                                    t.effective_date__c +
                                    t.ccy__c +
                                    t.amount__c +
                                    t.Amount_USD_Equiv_daily_fx__c +
                                    t.status__C  +
                                    t.type__c +
                                    t.notes__c +
                                    t.previous_hash__c+
                                    t.previous_transaction__c;
                                  
system.debug(hashstring);
  
                                    return hashstring;
        }


        public static string getHash(string hash_string) {
             system.debug('B:' + hash_string);
                blob targetBlob = Blob.valueOf(hash_string);
                blob hash = Crypto.generateDigest('SHA256', targetBlob);
                system.debug(EncodingUtil.base64Encode(hash));
                return EncodingUtil.base64Encode(hash);
        }

        public static boolean verify_hash(id P_transaction){

                transaction__C t = [select Related_Transaction__c,
                                    accounting_period__C,
                                    eWallet__c,
                                    eWallet_Trustee__c,
                                    account__c,
                                    Withdrawal_Deposit_Unique_index__c,
                                    Withdrawal_Deposit__c,
                                    Invoice_Allocation__c,
                                    Bank_Account__c,
                                    Invoice_Finance_Deal__c,
                                    Offer__c,
                                    effective_date__c,
                                    ccy__c,
                                    amount__c,
                                    Amount_USD_Equiv_daily_fx__c,
                                    status__C,
                                    type__c,
                                    notes__c,
                                    previous_hash__c,
                                    previous_transaction__c
                                    from transaction__C where id=:p_transaction].get(0);
               if ( t.hash__c == gethash(makehash(t)) ) 
               { t.verified__c = DateTime.now();
               update t;
               return true;
               }
               return false;
                
        }

        public static boolean verify_chain() {
                boolean verified;
                list<transaction__C> ts = [select ID, verified__c from transaction__C where hash__C != 'xxx' order by name asc limit 1];

                do {
                        transaction__c current_t = ts.get(0);
                        if (verify_hash(current_t.id) ) {
                                verified = true;
                                
                        } else {verified = false;}
                        ts = [select ID,verified__c from transaction__C where previous_transaction__C = :current_t.id];

                }
                while ( verified == true && (ts.isempty() == false) );
                return verified;

        }


        global class DoubleEntryInputs {
                @InvocableVariable(required=true)
                global string ccy;

                @InvocableVariable(required=true)
                global decimal amount;

                @InvocableVariable(required=true)
                global id to_account;

                @InvocableVariable
                global id from_account;

                @InvocableVariable(required=true)
                global date Effective_date;

                @InvocableVariable(required=true)
                global string status;

                @InvocableVariable(required=true)
                global string type;

                @InvocableVariable
                global string notes;

                @InvocableVariable
                global id Withdrawal_Deposit;

                @InvocableVariable
                global id Bank_account;
                
                @InvocableVariable
                global id Invoice_finance_deal;
                
                @InvocableVariable
                global id Invoice_Allocation;

                @InvocableVariable
                global id offer;
                
                @InvocableVariable
                global id Accounting_Period;

                @InvocableVariable
                global String trustee;


        }

}