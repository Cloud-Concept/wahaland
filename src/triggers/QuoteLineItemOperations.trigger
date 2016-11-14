trigger QuoteLineItemOperations on QuoteLineItem (after insert, after delete, after update, before update, before delete) {
    //before update and delete is to restrict the editing or deleting
    //after edit, update, delete is to calcualte the plot reference
    QuoteLineItem oldItem = new QuoteLineItem();
    Set<Id> unitIds = new Set<Id>();
    Set<Id> quoteIds = new Set<Id>();
    List<QuoteLineItem> updatedLI = new List<QuoteLineItem>();
    List<Unit__c> units = new List<Unit__c>();
    Map<Id, Unit__c> unitsMap = new Map<Id, Unit__c>();
    Map<Id, Quote> quotesMap = new Map<Id, Quote>();
    Map<Id, QuoteLineItem> qLIMaps = new Map<Id, QuoteLineItem>();
    QuoteLineItem qLI = new QuoteLineItem();
    
    Set<Id> qIds = new Set<Id>();
    Map<Id, Map<string, List<String>>> qMap = new Map<Id, Map<string, List<String>>>();
    List<QuoteLineItem> quoteLi = new List<QuoteLineItem>();
    Map<string, List<String>> unitMap = new Map<string, List<String>>();
    List<string> unitNames = new List<string>();
    List<Quote> qList = new List<Quote>();
    string plotRefernce;
    string plotBulidingUnit;
    
    if(Trigger.IsBefore){
    if(Trigger.IsDelete){
        for(QuoteLineItem item: Trigger.Old){
            if(item.ReadOnly__c == true){
                item.AddError('You Cannot Delete This Record.', false);
            }
        }
    }
    else{
        for(QuoteLineItem item: Trigger.New){
            oldItem = Trigger.OldMap.get(item.Id);
           if(item.ReadOnly__c == true && (item.UnitPrice != oldItem.UnitPrice || item.Quantity != oldItem.Quantity)){
                unitIds.add(item.Unit__c);
                quoteIds.add(item.QuoteId);
                updatedLI.add(item);
            }
        }
        if(updatedLI.size()>0){
            unitsMap.putAll([Select Id, RecordType.DeveloperName from Unit__c where id in:unitIds ]);
            quotesMap.putAll([Select Id, PaymentsGenerated__c from Quote where id in:quoteIds]);
            unitIds = new Set<Id>();
            
            for(QuoteLineItem item:updatedLI){
                if( quotesMap.get(item.QuoteId).PaymentsGenerated__c == true){
                    item.adderror('You cannot edit the sales price or the Area of this record.');
                }
                else{
                    unitIds.add(item.Unit__c);
                    qLIMaps.put(item.Unit__c, item);
                }
            }
            if(unitIds.size()>0){
                units = [Select Id, List_Price__c, Area_in_sq_m__c From Unit__c where Id in :unitIds];
                for(integer i = 0; i < units.size(); i++){
                qLI = qLIMaps.get(units[i].Id);
                units[i].Area_in_sq_m__c = qLI.Quantity;
                units[i].List_Price__c = qLI.UnitPrice * qLI.Quantity;
            }
            update units;
            }
            
        }
    }
    }
     else if(Trigger.IsAfter){
        
        if(Trigger.IsDelete){
            for(QuoteLineItem qouteli : Trigger.Old){
                qIds.add(qouteli.QuoteId);
            }
        }
        else{
            for(QuoteLineItem qouteli : Trigger.New){
                qIds.add(qouteli.QuoteId);
            }
        }
        if(qIds.size() > 0){
            
            //tCMap.putAll([Select Id, (Select Plot_with_Building_Formula__c, unit__r.name From Contract_Line_Items__r where Product__r.name = 'Plot') from Tenancy_Contract__c where id in: TCIds]);
            List<Quote> quoteList = [Select Id, Plot_Reference__c from Quote where Id in:qIds];
            for(integer i = 0; i<quoteList.size(); i++){
                quoteList[i].Plot_Reference__c = '';
            }
            if(quoteList.size()>0)
            	update quoteList;
            
            quoteLI = [Select Plot_with_Building_Formula__c, unit__r.name, QuoteId From QuoteLineItem where QuoteId in:qIds and unit__r.RecordType.DeveloperName = 'Plot' order by Plot_with_Building_Formula__c];
            for(QuoteLineItem qouteli:quoteLI){
                unitMap = qMap.get(qouteli.QuoteId);
                if(unitMap == null)
                    unitMap = new Map<string, List<String>>();
                unitNames = unitMap.get(qouteli.Plot_with_Building_Formula__c);
                if(unitNames == null)
                    unitNames = new List<string>();
                unitNames.add(qouteli.unit__r.name);
                unitMap.put(qouteli.Plot_with_Building_Formula__c, unitNames);
                qMap.put(qouteli.QuoteId, unitMap);
            }
            for(Id qId:qMap.keySet()){
                plotRefernce = '';
    			unitMap = new Map<string, List<String>>();
                unitMap = qMap.get(qId);
                for(string plotBuilding:unitMap.keySet()){
                    unitNames = new List<String>();
                    unitNames = unitMap.get(plotBuilding);
                    plotBulidingUnit = plotBuilding;
                    plotBulidingUnit += String.join(unitNames, ',');
                    plotRefernce += plotBulidingUnit + ' - ';
                }
                plotRefernce = plotRefernce.substring(0, plotRefernce.length() - 2);
                qList.add(new Quote(Id = qId, Plot_Reference__c = plotRefernce));
            }
            update qList;
        }
    }
}