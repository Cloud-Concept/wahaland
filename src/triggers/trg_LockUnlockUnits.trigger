trigger trg_LockUnlockUnits on Unit__c (after update) {
    List<Unit__c> LockUnits = new List<Unit__C>();
    List<Unit__c> UnLockUnits = new List<Unit__C>();
    Unit__c oldUnit = new Unit__c();
    for(Unit__C unit:Trigger.New){
        oldUnit = Trigger.OldMap.get(unit.Id);
        if(unit.Availability__c != oldUnit.Availability__c){
            if(unit.Availability__c == 'Available')
                UnLockUnits.Add(unit);
            else if(oldUnit.Availability__c == 'Available')
                LockUnits.add(Unit);
        }
    }
    
    if(UnLockUnits.size() > 0)
        System.Approval.Unlock(UnLockUnits, false);
    if(LockUnits.size() > 0)
        system.Approval.lock(LockUnits, false);

}