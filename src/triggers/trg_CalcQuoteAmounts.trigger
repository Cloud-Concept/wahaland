trigger trg_CalcQuoteAmounts on QuoteLineItem (after insert, after update, after delete) {
    //This Trigger is to calculate all the the Plot, Service Land and Unserviced Land Area on the Quote 
    //each time we will re-calcuate the Plot, Service Land and Unserviced Land Area.
    
    //Declare the variables
    Set<Id> QuoteIds = new set<Id>();
    Set<Id> PlotQLIIds = new set<Id>();
    Set<Id> ServiceQLIIds = new set<Id>();
    Set<Id> UnServicedQLIIds = new set<Id>();
    List<Quote> QuoteList = new List<Quote>();
    List<AggregateResult> QuoteSumList = new List<AggregateResult>();
    Map<Id, Decimal> PlotMap = new Map<Id, Decimal>();
    Map<Id, Decimal> ServiceMap = new Map<Id, Decimal>();
    Map<Id, Decimal> UnServicedMap = new Map<Id, Decimal>();
    Decimal sum;
    Integer i;
    string ProductName;
    set<Id> productIds = new set<Id>();
    Map<Id, Product2> products = new Map<Id, Product2>();
    if(Trigger.IsDelete){
        for(QuoteLineItem QLI:Trigger.Old){
            productIds.add(QLI.Product2Id);
        }
    }
    else{
        for(QuoteLineItem QLI:Trigger.New){
            productIds.add(QLI.Product2Id);
        }
    }
    
    products.PutAll([Select Id, Name From Product2 where id in:productIds]);
    
    if(Trigger.IsDelete){
        for(QuoteLineItem QLI:Trigger.Old){
            ProductName = products.get(QLI.Product2Id).Name;
            if(ProductName == 'Industrial Building'){
                PlotQLIIds.add(QLI.Id);
            }
            else if(ProductName == 'Serviced Land'){
                ServiceQLIIds.add(QLI.Id);
            }
            else if(ProductName == 'Unserviced Land'){
                UnServicedQLIIds.add(QLI.Id);
            }
            QuoteIds.Add(QLI.QuoteId);
        }
    }
    else if(trigger.isUpdate){
        for(QuoteLineItem QLI:Trigger.New){
            if(QLI.Quantity != Trigger.OldMap.get(QLI.Id).Quantity ){
            	ProductName = products.get(QLI.Product2Id).Name;
                if(ProductName == 'Industrial Building'){
                    PlotQLIIds.add(QLI.Id);
                }
                else if(ProductName == 'Serviced Land'){
                    ServiceQLIIds.add(QLI.Id);
                }
                else if(ProductName == 'Unserviced Land'){
                    UnServicedQLIIds.add(QLI.Id);
                }
                QuoteIds.Add(QLI.QuoteId);
            }
        }
    }
    else{
        for(QuoteLineItem QLI:Trigger.New){
            ProductName = products.get(QLI.Product2Id).Name;
            if(ProductName == 'Industrial Building'){
                PlotQLIIds.add(QLI.Id);
            }
            else if(ProductName == 'Serviced Land'){
                ServiceQLIIds.add(QLI.Id);
            }
            else if(ProductName == 'Unserviced Land'){
                UnServicedQLIIds.add(QLI.Id);
            }
            QuoteIds.Add(QLI.QuoteId);
        }
    }
    
    if(QuoteIds.Size()>0){
        QuoteList = [Select Id, Total_Plot_Area__c, Total_Service_Land__c, Total_UnServiced_Land__c From Quote where Id in:QuoteIds];
        if(PlotQLIIds.size()>0){
            QuoteSumList = [Select QuoteId, Sum(Quantity) payments From QuoteLineItem Where QuoteId in:QuoteIds and Product2.Name = 'Industrial Building' group by QuoteId];
            for(AggregateResult ar:QuoteSumList){
                sum = 0;
                sum = (Decimal)ar.get('payments');
                string a = string.valueof(ar.get('QuoteId'));
                system.debug('sum ' + sum);
                system.debug('a ' + a);
                Id qid = Id.Valueof(a);
                PlotMap.Put(qid, sum);
            }
        }

        if(ServiceQLIIds.size()>0){
            QuoteSumList = [Select QuoteId, Sum(Quantity) payments From QuoteLineItem Where QuoteId in:QuoteIds and Product2.Name = 'Serviced Land' group by QuoteId];
            for(AggregateResult ar:QuoteSumList){
                sum = 0;
                sum = (Decimal)ar.get('payments');
                string a = string.valueof(ar.get('QuoteId'));
                Id qid = Id.Valueof(a);
                ServiceMap.Put(qid, sum);
            }
        }
                
        if(UnServicedQLIIds.size()>0){
            QuoteSumList = [Select QuoteId, Sum(Quantity) payments From QuoteLineItem Where QuoteId in:QuoteIds and Product2.Name = 'Unserviced Land' group by QuoteId];
            for(AggregateResult ar:QuoteSumList){
                sum = 0;
                sum = (Decimal)ar.get('payments');
                string a = string.valueof(ar.get('QuoteId'));
                Id qid = Id.Valueof(a);
                UnServicedMap.Put(qid, sum);
            }
        }
        
        for(i = 0; i < QuoteList.size(); i++){
            if(PlotMap.get(QuoteList[i].Id) != null)
            	QuoteList[i].Total_Plot_Area__c =  PlotMap.get(QuoteList[i].Id);
            if(ServiceMap.get(QuoteList[i].Id) != null)
            	QuoteList[i].Total_Service_Land__c = ServiceMap.get(QuoteList[i].Id);
            if(UnServicedMap.get(QuoteList[i].Id) != null)
            	QuoteList[i].Total_UnServiced_Land__c = UnServicedMap.get(QuoteList[i].Id);
        }
        
        update QuoteList;
    }   
}