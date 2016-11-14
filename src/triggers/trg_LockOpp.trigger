trigger trg_LockOpp on Opportunity (after update) {
    Set<Id> oppToBeLocked = new Set<Id>();
    List<Opportunity> opps = new List<Opportunity>();
    for(Opportunity opp: Trigger.New){
        if(opp.StageName == 'Closed Won' && opp.StageName != Trigger.OldMap.get(opp.Id).StageName){
            oppToBeLocked.add(opp.Id);
        }
    }
    
    if(oppToBeLocked.size()>0){
        opps = [Select Id From Opportunity where id in:oppToBeLocked];
        Approval.lock(opps, false);
    }
}