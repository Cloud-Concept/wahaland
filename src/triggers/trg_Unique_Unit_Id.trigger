trigger trg_Unique_Unit_Id on Unit__c (before insert, before update) {
    
    List<AggregateResult> units = new List<AggregateResult>();
    Set<String> UnitIds = new Set<String>();
    Set<Id> UIds = new Set<Id>();
    Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
    for(Unit__C unit: Trigger.New){
        if(unit.RecordTypeId == RTId){
        	UnitIds.add(unit.Name);
            UIds.add(unit.Id);
        }
    }
    units.AddAll([Select count(Id)cnum, Plot__C, Bulidling__c, name From Unit__C where Id not in :UIds and name in:UnitIds and RecordType.DeveloperName = 'Plot' group by name, Plot__C, Bulidling__c]);    
    for(Unit__c unit:Trigger.New){
        for(AggregateResult ar:Units){
            if(ar.get('name') == unit.name && ar.get('Plot__C') == unit.Plot__C && ar.get('Bulidling__c') == unit.Bulidling__c && Integer.valueOf(ar.get('cnum')) > 0){
                unit.adderror('You cannot Insert dublicate unit for the same Plot and Building', false);  
            }
        }
    }
    
}