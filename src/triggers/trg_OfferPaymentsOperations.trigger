trigger trg_OfferPaymentsOperations on Payment_Plan__c (after insert, after update, after delete, before delete) {
    //This Trigger is to calculate all the Service charge Payments on a the contract 
    //each time we will re-calcuate the service charge.
    //Update the annual rent, basic service charge, security deposit, reservation Amount
    
    //Declare the variables
    Set<Id> QPIds = new set<Id>();
    List<Quote> QuoteList = new List<Quote>();
    List<AggregateResult> QuoteSumList = new List<AggregateResult>();
    List<Payment_Plan__c> QuptePayments = new List<Payment_Plan__c>();
    Map<Id, Decimal> QPMap = new Map<Id, Decimal>();
    Set<Id> PPIds = new Set<Id>();
    Set<Id> quoteIds = new Set<Id>();
    Map<Id, Quote> quoteBasicCharge = new Map<Id, Quote>();
    Map<Id, Quote> quoteSecurityDeposit = new Map<Id, Quote>();
    Map<Id, Quote> quoteReservation = new Map<Id, Quote>();
    Map<Id, Decimal> quoteAnnualRent = new Map<Id, Decimal>();
    
    Decimal annualRent = 0;
    Decimal securityDeposit = 0;
    Decimal basicCharge = 0;
    Decimal reservationAmount=0;
    Decimal sum;
    Integer i;
    if(trigger.isbefore){
        if(trigger.IsDelete){
            for(Payment_Plan__c item: Trigger.Old){
                if(item.ReadOnly__c == true){
                    item.AddError('You Cannot Delete This Record.');
                }
            }
        }
    }
    if(trigger.isAfter){
        if(Trigger.IsDelete){
            for(Payment_Plan__c QP:Trigger.Old){
                if(QP.isServiceCharge__c){
                    QPIds.add(QP.Quote__c);
                    if(QP.YearNumber__c == '1')
                        quoteIds.add(QP.Quote__c);
                }
                else if(QP.isReservation__c|| QP.isSecurityDeposit__c || QP.YearNumber__c == '1'){
                    quoteIds.add(QP.Quote__c);
                }
            }
        }
        else if(Trigger.isInsert){
            for(Payment_Plan__c QP:Trigger.New){
                
                if(QP.isServiceCharge__c){
                    QPIds.add(QP.Quote__c);
                    if(QP.YearNumber__c == '1')
                        quoteIds.add(QP.Quote__c);
                }
                else if(QP.isReservation__c|| QP.isSecurityDeposit__c || QP.YearNumber__c == '1'){
                    quoteIds.add(QP.Quote__c);
                }
            }
        }
        else If(Trigger.isupdate){
            for(Payment_Plan__c QP:Trigger.New){
                if(QP.Payment_Amount__C != Trigger.OldMap.get(QP.Id).Payment_Amount__C)
                {
                    if(QP.isServiceCharge__c){
                        QPIds.add(QP.Quote__c);
                        if(QP.YearNumber__c == '1')
                            quoteIds.add(QP.Quote__c);
                    }
                    else if(QP.isReservation__c|| QP.isSecurityDeposit__c || QP.YearNumber__c == '1'){
                        quoteIds.add(QP.Quote__c);
                    }
                }
                if(QP.SubmitForApproval__c == true && QP.SubmitForApproval__c != Trigger.OldMap.get(QP.Id).SubmitForApproval__c){
                    PPIds.add(QP.Id);
                }
            }
        }
        
        if(QPIds.size()>0){
            QuoteSumList = [Select Quote__c, Sum(Payment_Amount__c) payments From Payment_Plan__c Where Quote__c in:QPIds and isServiceCharge__c = true group by Quote__c];
            QuptePayments = [Select Quote__c, Payment_Amount__c From Payment_Plan__c Where Quote__c in:QPIds and isServiceCharge__c = true];
            QuoteList = [Select Id, Total_Service_Charges__c From Quote Where Id in :QPIds];
            
            for(AggregateResult ar:QuoteSumList){
                sum = 0;
                sum = (Decimal)ar.get('payments');
                string a = string.valueof(ar.get('Quote__c'));
                Id qid = Id.Valueof(a);
                QPMap.Put(qid, sum);
            }
            i=0;
            for(Quote Q:QuoteList){
                QuoteList[i].Total_Service_Charges__c = (Decimal)QPMap.get(QuoteList[i].Id);
                i++;
            }
            if(QuoteList.size()>0){
                update QuoteList;
            }
        }
        If(PPIds.Size()>0){
            // Query the Payments to lock
            system.debug('Lock ' + PPIds.Size());
            Payment_Plan__c[] paymentPlans = [SELECT Id from Payment_Plan__c WHERE Id In :PPIds];
            system.debug('Lock ' + paymentPlans.size());        
            // Lock the Payments
            Approval.LockResult[] lrList = Approval.locK(paymentPlans, false);
            
            // Iterate through each returned result
            for(Approval.LockResult lr : lrList) {
                if (lr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully locked Payments with ID: ' + lr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : lr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Payments fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        if(quoteIds.size()>0){
            QuoteList = new List<Quote>();
            QuoteList = [Select Id, Basic_Service_Charge__c, Annual_Year_Rent__c, Security_Deposit__c, Reservation_Amount__c From Quote Where Id in :quoteIds];
            QuoteSumList = new List<AggregateResult>();
            quoteBasicCharge.putAll([Select Id, (Select Quote__c, Payment_Amount__c From Offer_Payments__r Where isServiceCharge__c = True and YearNumber__c ='1') From Quote Where Id in:quoteIds]);
            quoteReservation.putAll([Select Id, (Select Quote__c, Payment_Amount__c From Offer_Payments__r Where isReservation__c = True) From Quote where Id in:quoteIds]);
            quoteSecurityDeposit.putAll([Select Id, (Select Quote__c, Payment_Amount__c From Offer_Payments__r Where isSecurityDeposit__c = True) From Quote where Id in:quoteIds]);
            QuoteSumList = [Select Quote__c, Sum(Payment_Amount__c) payments From Payment_Plan__c Where Quote__c in:quoteIds 
                            and isServiceCharge__c = false and isSecurityDeposit__c = false group by Quote__c];
            for(AggregateResult ar:QuoteSumList){
                Id quoteId = Id.Valueof(string.valueof(ar.get('Quote__c')));
                quoteAnnualRent.put(quoteId, (Decimal)ar.get('payments'));
            }
            for(i = 0; i<QuoteList.size(); i++){
                if(quoteAnnualRent.size()>0 && quoteAnnualRent.get(QuoteList[i].Id) != null)
                    annualRent = quoteAnnualRent.get(QuoteList[i].Id);
                else
                    annualRent = 0;
                if(quoteBasicCharge.size()>0 && quoteBasicCharge.get(QuoteList[i].Id).Offer_Payments__r.size() > 0)
                    basicCharge = quoteBasicCharge.get(QuoteList[i].Id).Offer_Payments__r[0].Payment_Amount__c;
                else
                    basicCharge = 0;
                if(quoteSecurityDeposit.size()>0 && quoteSecurityDeposit.get(QuoteList[i].Id).Offer_Payments__r.size() > 0)
                    securityDeposit = quoteSecurityDeposit.get(QuoteList[i].Id).Offer_Payments__r[0].Payment_Amount__c;
                else
                    securityDeposit = 0;
                if(quoteReservation.size()>0 && quoteReservation.get(QuoteList[i].Id).Offer_Payments__r.size() > 0)
                    reservationAmount = quoteReservation.get(QuoteList[i].Id).Offer_Payments__r[0].Payment_Amount__c;
                else
                    reservationAmount = 0;
                QuoteList[i].Basic_Service_Charge__c = basicCharge;
                QuoteList[i].Total_Price_with_Escalation_rate__c = annualRent;
                QuoteList[i].Security_Deposit__c = securityDeposit;
                QuoteList[i].Reservation_Amount__c = reservationAmount;
                QuoteList[i].Reservation_Deposit_Amount__c = reservationAmount;
            }
            update QuoteList;
        }
    }
    
}