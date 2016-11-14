trigger trg_Account on Account (after update) {
    Account oldAcc = new Account();
    Set<Id> accIds = new Set<Id>();
    Map<Id, String> accIntials = new Map<Id, String>();
    List<Tenancy_Contract__c> tcList = new List<Tenancy_Contract__c>();
    for(Account acc:Trigger.New){
        oldAcc = Trigger.OldMap.get(acc.Id);
        if(oldAcc.Name != acc.Name){
            accIds.add(acc.Id);
            string accAppriviations = '';
            List<String> accList = new List<String>();
            accList = acc.Name.trim().split(' ');
            for(string str :accList){
            	accAppriviations += str.substring(0, 1);
            }
            accIntials.put(acc.Id, accAppriviations);
        }
    }
    
    if(accIds.size()>0){
        tcList = [Select Id, AccountInitials__c, Account__c From Tenancy_Contract__c where Account__c in :accIds];
        for(integer i = 0; i< tcList.Size(); i++){
            tcList[i].AccountInitials__c = accIntials.get(tcList[i].Account__c);
        }
        if(tcList.size()>0){
        	update tcList;
        }
    }
}