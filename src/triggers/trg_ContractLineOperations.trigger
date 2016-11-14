trigger trg_ContractLineOperations on Contract_Line_Item__c (after insert, after delete, after update, before Update, before delete) {
    //before update and delete is to restrict the editing or deleting
    //after edit, update, delete is to calcualte the plot reference
    Set<Id> TCIds = new Set<Id>();
    Set<Id> insertedUnits = new Set<Id>();
    Map<Id, Map<string, List<String>>> tCMap = new Map<Id, Map<string, List<String>>>();
    List<Contract_Line_Item__c> contractLi = new List<Contract_Line_Item__c>();
    Map<string, List<String>> unitMap = new Map<string, List<String>>();
    List<string> unitNames = new List<string>();
    List<Tenancy_Contract__C> tcList = new List<Tenancy_Contract__C>();
    string plotRefernce;
    string plotBulidingUnit;
    set<Id> cliIdSet = new set<Id>();
    if(Trigger.IsBefore){
        system.debug('before');
        Contract_Line_Item__c oldItem = new Contract_Line_Item__c();
        if(Trigger.IsDelete){
            for(Contract_Line_Item__c item: Trigger.Old){
                if(item.ReadOnly__c == true){
                    item.addError('You Cannot Delete This Record.', false);
                }
            }
        }
        else if(Trigger.isUpdate){
            for(Contract_Line_Item__c item: Trigger.New){
                oldItem = Trigger.OldMap.get(item.Id);
                if((item.UnitPrice__c != oldItem.UnitPrice__c || item.Quantity__c != oldItem.Quantity__c)){
                    cliIdSet.add(item.Id);
                }
            }
            if(cliIdSet.size()>0){
                List<Contract_Line_Item__c> CLIList = [Select Id, unit__c, unit__r.Current_Tenancy_Contracts__c,  Contract__r.Renewed_Contract__c, Contract__r.Payments_Counter__c From Contract_Line_Item__c where id in :cliIdSet];
                List<Unit__c> updateUnit = new List<Unit__c>();
                for(Contract_Line_Item__c item: CLIList){
                    if((item.unit__r.Current_Tenancy_Contracts__c  <> null && item.unit__r.Current_Tenancy_Contracts__c == item.Contract__r.Renewed_Contract__c) || item.Contract__r.Payments_Counter__c > 0){
                        Trigger.NewMap.get(item.Id).adderror('You cannot edit the sales price or the Area of this record.');
                    }
                    else{
                        Contract_Line_Item__c newLi = new Contract_Line_Item__c();
                        newLi = Trigger.NewMap.get(item.Id);
                        unit__c unit = new unit__c();
                        unit.Area_in_sq_m__c = newLi.Quantity__c;
                        unit.List_Price__c = newLi.Quantity__c * newLi.UnitPrice__c;
                        unit.id = item.unit__c;
                        updateUnit.add(unit);
                    }
                }
                if(updateUnit.size()>0)
                    update updateUnit;
            }
        }
    }
    else if(Trigger.IsAfter){
        
        if(Trigger.IsDelete){
            for(Contract_Line_Item__c cli : Trigger.Old){
                TCIds.add(cli.Contract__c);
            }
        }
        else{
            for(Contract_Line_Item__c cli : Trigger.New){
                TCIds.add(cli.Contract__c);
            }
        }
        if(TCIds.size() > 0){
            //tCMap.putAll([Select Id, (Select Plot_with_Building_Formula__c, unit__r.name From Contract_Line_Items__r where Product__r.name = 'Plot') from Tenancy_Contract__c where id in: TCIds]);
             List<Tenancy_Contract__c> contractList = [Select Id, Plot_Reference__c from Tenancy_Contract__c where Id in:TCIds];
            for(integer i = 0; i<contractList.size(); i++){
                contractList[i].Plot_Reference__c = '';
            }
            if(contractList.size()>0)
            	update contractList;
            contractLi = [Select Plot_with_Building_Formula__c, unit__r.name, Contract__c From Contract_Line_Item__c where contract__c in:TCIds and unit__r.RecordType.DeveloperName = 'Plot' order by Plot_with_Building_Formula__c];
            system.debug('contractLi ' + contractLi);
            for(Contract_Line_Item__c cli:contractLi){
                unitMap = tCMap.get(cli.Contract__c);
                if(unitMap == null)
                    unitMap = new Map<string, List<String>>();
                unitNames = unitMap.get(cli.Plot_with_Building_Formula__c);
                if(unitNames == null)
                    unitNames = new List<string>();
                unitNames.add(cli.unit__r.name);
                unitMap.put(cli.Plot_with_Building_Formula__c, unitNames);
                tCMap.put(cli.Contract__c, unitMap);
            }
            for(Id tcId:tCMap.keySet()){
                plotRefernce = '';
    			unitMap = new Map<string, List<String>>();
                unitMap = tcMap.get(tcId);
                for(string plotBuilding:unitMap.keySet()){
                    unitNames = new List<String>();
                    unitNames = unitMap.get(plotBuilding);
                    plotBulidingUnit = plotBuilding;
                    plotBulidingUnit += String.join(unitNames, ',');
                    plotRefernce += plotBulidingUnit + ' - ';
                }
                plotRefernce = plotRefernce.substring(0, plotRefernce.length() - 2);
                tcList.add(new Tenancy_Contract__c(Id = tcId, Plot_Reference__c = plotRefernce));
            }
            update tcList;
        }
    }
}