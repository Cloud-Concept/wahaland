trigger trg_Payments_Count on Payment_Plan__c (before insert, after delete) {
    Set<Id> quoteId = new Set<Id>();
    Set<Id> quoteIdToBeUpdated = new Set<Id>();
    Map<Id, Integer> paymentsCount = new Map<Id, Integer>();
    List<Quote> quotes = new List<Quote>();
    List<AggregateResult> quotesList = new List<AggregateResult>();
    Quote q;
    If(Trigger.IsDelete){
        for(Payment_Plan__c pp:Trigger.old){
            quoteId.add(pp.Quote__c);
        }
    }
    else{
        for(Payment_Plan__c pp:Trigger.New){
            quoteId.add(pp.Quote__c);
        }
    }
    if(quoteId.Size()>0){
        quotesList = [Select Quote__c, count(Id) paymentCount From Payment_Plan__c Where Quote__c in :quoteId group by Quote__c];
        for(AggregateResult al:quotesList){
            paymentsCount.put((Id)al.get('Quote__c'), Integer.valueOf(al.get('paymentCount')));
        }
        quotes = new List<Quote>();
        for(Id qId:quoteID){
            q = new Quote();
            Integer count;
            system.debug(paymentsCount.keySet());
            count = Integer.valueOf(paymentsCount.get(qId));
            system.debug(count);
            if(count == null || count ==0){
                q.id = qId;
                q.PaymentsGenerated__c = false;
            }
            else{
                q.id = qId;
                q.PaymentsGenerated__c = true;
            }
             quotes.add(q);   
        }
        update quotes;
    }
}