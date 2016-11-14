trigger trg_RestrictEditDelete_OPPLI on OpportunityLineItem (before update, before delete) {
    OpportunityLineItem oldItem = new OpportunityLineItem();
    Set<Id> unitIds = new Set<Id>();
    Set<Id> oppIds = new Set<Id>();
    List<OpportunityLineItem> updatedLI = new List<OpportunityLineItem>();
    List<Unit__c> units = new List<Unit__c>();
    Map<Id, Unit__c> unitsMap = new Map<Id, Unit__c>();
    Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>();
    Map<Id, OpportunityLineItem> oppLIMaps = new Map<Id, OpportunityLineItem>();
    OpportunityLineItem oppLI = new OpportunityLineItem();
    
    if(Trigger.IsDelete){
        for(OpportunityLineItem item: Trigger.Old){
            if(item.ReadOnly__c == true){
                item.AddError('You Cannot Delete This Record.');
            }
        }
    }
    else{
        for(OpportunityLineItem item: Trigger.New){
            oldItem = Trigger.OldMap.get(item.Id);
           if(item.ReadOnly__c == true && (item.UnitPrice != oldItem.UnitPrice || item.Quantity != oldItem.Quantity)){
                unitIds.add(item.Unit__c);
                oppIds.add(item.OpportunityId);
                updatedLI.add(item);
            }
        }
        if(updatedLI.size()>0){
            unitsMap.putAll([Select Id, RecordType.DeveloperName from Unit__c where id in:unitIds ]);
            oppsMap.putAll([Select Id, NumberOfGeneratedPropsals__c from Opportunity where id in:oppIds]);
            unitIds = new Set<Id>();
            
            for(OpportunityLineItem item:updatedLI){
                if(oppsMap.get(item.OpportunityId).NumberOfGeneratedPropsals__c > 0){
                    item.adderror('You cannot edit the sales price or the Area of this record.');
                }
                else{
                    unitIds.add(item.Unit__c);
                    oppLIMaps.put(item.Unit__c, item);
                }
            }
            if(unitIds.size()>0){
                units = [Select Id, List_Price__c, Area_in_sq_m__c From Unit__c where Id in :unitIds];
                for(integer i = 0; i < units.size(); i++){
                oppLI = oppLIMaps.get(units[i].Id);
                units[i].Area_in_sq_m__c = oppLI.Quantity;
                units[i].List_Price__c = oppLI.UnitPrice * oppLI.Quantity;
            }
            update units;
            }
            
        }
    }

}