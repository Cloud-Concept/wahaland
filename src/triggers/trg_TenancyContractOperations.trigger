trigger trg_TenancyContractOperations on Tenancy_Contract__c (after update, after insert , after delete) {
    //trg_Tenancy_Status_Changed
    // This trigger will fire if the Tenancy Contract changed to Under Cancelletion or Canceled or Active.
    
    //declare the variables
    Tenancy_Contract__c updatedTC = new Tenancy_Contract__c();
    Tenancy_Contract__c oldTC = new Tenancy_Contract__c();
    List<Tenancy_Contract_Payment__c> tenancyPaymentList;
    List<Tenancy_Contract_Payment__c> updatedTenancyPaymentList = new List<Tenancy_Contract_Payment__c>();
    set<id> TCUpdatedId = new set<id>();
    Map<id, Tenancy_Contract__c> TCMap = new Map<id, Tenancy_Contract__c>();
    Map<id, Tenancy_Contract__c> TCUnderCancellationMap = new Map<id, Tenancy_Contract__c>();
    Map<id, Tenancy_Contract__c> TCUActivatedMap = new Map<id, Tenancy_Contract__c>();
    List<Unit__c> unitList = new List<Unit__c>();
    List<Unit__c> updatedUnitList = new List<Unit__c>();
    List<Tenancy_Contract__c> toBeLocked = new List<Tenancy_Contract__c>();
    set<Id> toBeLockedIds = new set<Id>();
    set<id> TCUnderCancellation = new set<id>();
    set<id> TCUActive = new set<id>();
    List<Unit__c> unitsToBeLeased = new List<Unit__c>();
    List<Contract_Line_Item__c> cli;
    Set<Id> unitsToBeLeasedIds;
    Map<Id, Id> contractUnitMap;
    List<Tenancy_Contract__c> oldTenancyContractList= new List<Tenancy_Contract__c>();
    Set<Id> OldTCIds = new Set<Id>();
    List<Unit__c> unitsToBeAvailable = new List<Unit__c>();
    Set<Id> renewedContracts = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    Map<Id, Account> accountsMap = new Map<Id, Account>();
    //Doaa Rollup manual Quote
    List <Id> quoteIds = new List <Id>();
    List <Id> actvQquoteIds = new List <Id>();
    list <Quote> quoteList;
    list <Quote> actvQuoteList;
    List<contract_Line_item__c> cLIList;
    
    if(Trigger.IsAfter){
        if(Trigger.IsInsert){
            for(Tenancy_Contract__c TC: Trigger.New){
                accountIds.add(TC.Account__c);
                quoteIds.add(TC.Quote__c);
                
                if(TC.Status__c == 'Approved'|| TC.Status__c == 'Active'|| TC.Status__c == 'Draft'|| TC.Status__c == 'In review'|| TC.Status__c == 'Under Approval' ){
                    actvQquoteIds.add(TC.Quote__c);
                }
            }
            System.debug('qidsssss '+quoteIds);
           quoteList = [select Id, ContractCount__c from quote where id in :quoteIds];
            for(quote qt:quoteList){
                qt.ContractCount__c +=1;
            }
            
           actvQuoteList = [select Id, ActiveContracts__c   from quote where id in :actvQquoteIds];
            for(quote qt:actvQuoteList){
                qt.ActiveContracts__c +=1;
            }
            
        update quoteList;
        update actvQuoteList;
        }
        
        
        if(Trigger.IsDelete){
            for(Tenancy_Contract__c TC: Trigger.Old){
                if(TC.Quote__c <> null){
                    quoteIds.add(TC.Quote__c);
                    if(TC.Status__c == 'Approved'|| TC.Status__c == 'Active'|| TC.Status__c == 'Draft'|| TC.Status__c == 'In review'|| TC.Status__c == 'Under Approval' ){
                        actvQquoteIds.add(TC.Quote__c);
                    }
                }
            }
           quoteList = [select Id, ContractCount__c from quote where id in :quoteIds];
            for(quote qt:quoteList){
                qt.ContractCount__c -=1;
            }
            
           actvQuoteList = [select Id, ActiveContracts__c  from quote where id in :actvQquoteIds];
            for(quote qt:actvQuoteList){
                qt.ActiveContracts__c -=1;
            }
            if(quoteList.size()>0)
                update quoteList;
            if(actvQuoteList.size()>0)
                update actvQuoteList;
        }
        
        
    //define the records which is the changed field is the status
    //define which fields are canceled and which are under cancellation
        if(Trigger.IsUpdate){
            for(Id TCId : trigger.newMap.Keyset()){
                tenancyPaymentList = new List<Tenancy_Contract_Payment__c>();
                updatedTC = trigger.newMap.get(TCId);
                oldTC = trigger.oldMap.get(TCId);
                if(oldTc.Account__c != updatedTC.Account__c){
                    accountIds.add(updatedTC.Account__c);
                }
                if(oldTC.Status__c != updatedTC.Status__c){
                    if(updatedTC.Status__c == 'Canceled' || updatedTC.Status__c == 'Expired'){
                        system.debug(updatedTC.Status__c);
                        TCUpdatedId.add(updatedTC.Id);
                        TCMap.Put(updatedTC.Id, updatedTC);
                    }
                    else if(updatedTC.Status__c == 'Under Cancellation'){
                        TCUnderCancellation.add(updatedTC.Id);
                        TCUnderCancellationMap.Put(updatedTC.Id, updatedTC);
                    }
                    else if(updatedTC.Status__c == 'Active'){
                        TCUActive.add(updatedTC.Id);
                        TCUActivatedMap.Put(updatedTC.Id, updatedTC);
                        IF(updatedTC.Renewed_Contract__c != null)
                            OldTCIds.add(updatedTC.Renewed_Contract__c);
                    }
                    else if (updatedTC.Status__c == 'Renewed'){
                        renewedContracts.add(updatedTC.Id);
                    }
                }
            }   
        }
        // For the Canceled Records
        // Update the Payments Cancellation Date and ReleaseUnitDateDev
        // the date changes will fire 2 process builders to inactive the payments and mark the units as avialable.
        if(TCUpdatedId.size()>0){
            List<Id> TCIdList = new List<Id>();
            TCIdList.addAll(TCUpdatedId);
            CommunityUser.deactivatePortalUser(TCIdList);
            tenancyPaymentList = [Select Id, Payment_Cancellation_Date__c, Tenancy_Contract__c From Tenancy_Contract_Payment__c where Status__c = 'Active' and Paid__C = False and Tenancy_Contract__c in :TCUpdatedId];
            for(Tenancy_Contract_Payment__c tcp:tenancyPaymentList){
                updatedTC = new Tenancy_Contract__c();
                updatedTC = TCMap.get(tcp.Tenancy_Contract__c);
                tcp.Payment_Cancellation_Date__c = updatedTC.Payments_Cancellation_Date__c;
                updatedTenancyPaymentList.add(tcp);
            }
            
            if(updatedTenancyPaymentList.size()>0){
                update updatedTenancyPaymentList;
            }
            cLIList = [select Id, unit__c from contract_line_item__c where contract__c in:TCUpdatedId];
            set<Id> unitIds=new set<Id>();
            unitList = [Select Id, Release_Unit_Date__c, ReleaseUnitDateDev__c, Current_Tenancy_Contracts__c From Unit__c where Current_Tenancy_Contracts__c in :TCUpdatedId];
            for(contract_line_item__c item:cLIList){
                unitIds.add(item.Unit__c);
            }
            
            for(Unit__c item:unitList){
                unitIds.add(item.Id);
            }
            
            unitList = [Select Id, Release_Unit_Date__c, ReleaseUnitDateDev__c, Current_Tenancy_Contracts__c, 
                        (select Id, contract__c from contract_line_items__r where contract__c in :TCUpdatedId)
                        From Unit__c where Id in :unitIds];
            for(Unit__c unit:unitList){
                unit.ReleaseUnitDateDev__c = null;
                unit.Release_Unit_Date__c = null;
                updatedUnitList.add(unit);
            }
            if(updatedUnitList.size()>0){
                update updatedUnitList;
            }
            updatedUnitList = new List<Unit__c>();
            for(Unit__c unit:unitList){
                updatedTC = new Tenancy_Contract__c();
                updatedTC = TCMap.get(unit.contract_line_items__r[0].contract__c);
                unit.ReleaseUnitDateDev__c = updatedTC.Unit_Release_Date__c;
                unit.Release_Unit_Date__c = updatedTC.Unit_Release_Date__c;
                updatedUnitList.add(unit);
            }
            if(updatedUnitList.size()>0)
                update updatedUnitList;
        }
        
        //for the under cancellation records
        //update the unit Release date for the units related
        if(TCUnderCancellation.size()>0){
            unitList = new List<Unit__c>();
            unitList = [Select Id,  Release_Unit_Date__c, Current_Tenancy_Contracts__c From Unit__c where Current_Tenancy_Contracts__c in :TCUnderCancellation];
            for(Unit__c unit:unitList){
                updatedTC = new Tenancy_Contract__c();
                updatedTC = TCUnderCancellationMap.get(unit.Current_Tenancy_Contracts__c);
                unit.Release_Unit_Date__c = updatedTC.Unit_Release_Date__c;
                updatedUnitList.add(unit);
                system.debug(unit);
            }
            if(updatedUnitList.size()>0)
                update updatedUnitList;
        }
        
        if(TCUActive.size() > 0){
            List<Id> TCIdList = new List<Id>();
            TCIdList.addAll(TCUActive);
            CommunityUser.createPortalUsers(TCIdList);
            cli = new List<Contract_Line_Item__c>(); 
            cli = [Select Id, Unit__c, Contract__c From Contract_Line_Item__c where Contract__c in :TCUActive ];
            unitsToBeLeasedIds = new Set<Id>();
            contractUnitMap = new Map<Id, Id>();
            List<Tenancy_Contract_Payment__c> payments = [SELECT Id, Status__c FROM Tenancy_Contract_Payment__c WHERE Tenancy_Contract__c =: TCUActive];
            for(integer i = 0; i<payments.size(); i++){
                payments[i].Status__c = 'Active';
            }
            Approval.LockResult[] lrList = Approval.locK(payments, false);
            Approval.LockResult[] lrListCLI = Approval.locK(cli, false);
            
            for(Contract_Line_Item__c item:cli){
                unitsToBeLeasedIds.add(item.unit__c);
                contractUnitMap.put(item.Unit__c, item.Contract__c);
            }
            unitsToBeLeased = new List<Unit__c>();
            unitsToBeLeased = [Select Id, Current_Tenancy_Contracts__c, Availability__c From Unit__c where Id in :unitsToBeLeasedIds];
            Integer i = 0;
            for(Unit__c unit:unitsToBeLeased){
                updatedTC = TCUActivatedMap.get(contractUnitMap.get(unit.Id));
                unitsToBeLeased[i].Current_Tenancy_Contracts__c = updatedTC.Id;
                unitsToBeLeased[i].Availability__c = 'Leased';
                i++;
            }
            if(unitsToBeLeased.size()>0){
                update unitsToBeLeased;
            }
            if(payments.size()>0)
                update payments;
            
            if(OldTCIds.Size()>0){
                oldTenancyContractList = [Select Id, Status__c from Tenancy_Contract__C where Id in :OldTCIds];
                for(integer y =0; y<oldTenancyContractList.size(); y++){
                    oldTenancyContractList[y].Status__c = 'Renewed';
                }
                update oldTenancyContractList;
            }
            List<services__c> services = new List<services__c>();
            Map<string, List<Service_Documents_CheckList__c>> sDC = new Map<string, List<Service_Documents_CheckList__c>>();
            services = [Select Id , Service_Identifier__c , (select Name ,Doc_Name__c , Doc_Type__c
                   , Has_Template__c , Template_URL__c from Service_Documents_CheckList__r) from services__c];
            for(services__c serv:services){
                sDC.put(serv.Service_Identifier__c, serv.Service_Documents_CheckList__r);
            }
            List<Tenancy_Contract__c> tcActiveList = [Select Id, contract_type__c, PrimaryContactEmail__c from Tenancy_Contract__c where id in:TCUActive];
            Map<Id, List<contract_documents__c>> tcDocumentCheckList = new Map<Id, List<contract_documents__c>>();
            for(Tenancy_Contract__c tc:[Select Id, (select Id from contract_documents__r) from Tenancy_Contract__c where id in:TCUActive]){
                tcDocumentCheckList.put(tc.Id, tc.contract_documents__r);
            }
            List<contract_documents__c> custDocuments = new List<contract_documents__c>();
            List<Service_Documents_CheckList__c> serviceDocuments;
            system.debug('tcDocumentCheckList '+ tcDocumentCheckList);
            for(Tenancy_Contract__c tc:tcActiveList){
                if(tcDocumentCheckList.get(tc.Id).size() == 0){
                    serviceDocuments = new List<Service_Documents_CheckList__c>();
                    serviceDocuments = sDC.get(tc.contract_type__c);
                    if(serviceDocuments != null){
                        for(Service_Documents_CheckList__c doc:serviceDocuments){
                            custDocuments.add(new contract_documents__c (Service_Documents_CheckList__c = doc.Id,Name = doc.Name , Doc_Name__c = doc.Doc_Name__c , Doc_Type__c = doc.Doc_Type__c
                           , Has_Template__c = doc.Has_Template__c , Tenancy_Contract__c = tc.Id
                           , Template_URL__c = doc.Template_URL__c, ContactEmail__c = tc.PrimaryContactEmail__c));
                        }
                    }
                }
            }
            system.debug('custDocuments ' + custDocuments);
            if(custDocuments.size()>0){
                insert custDocuments;
            }
        }
        
        if(renewedContracts.size() > 0){
            unitsToBeAvailable = [Select Id, Current_Tenancy_Contracts__c, Reserved_by_Offer_Letter__c, Availability__c, Release_Unit_Date__c, ReleaseUnitDateDev__c From Unit__c where Current_Tenancy_Contracts__c in :renewedContracts];
            for(integer i = 0; i<unitsToBeAvailable.size(); i++){
                unitsToBeAvailable[i].Availability__c = 'Available';
                unitsToBeAvailable[i].Current_Tenancy_Contracts__c = null;
                unitsToBeAvailable[i].Reserved_by_Offer_Letter__c = null;
                unitsToBeAvailable[i].Release_Unit_Date__c = null;
                unitsToBeAvailable[i].ReleaseUnitDateDev__c = null; 
            }
            update unitsToBeAvailable;
        }
        
        if(accountIds.Size()>0){
            string accIntials;
            string AccountName;
            List<String> accList;
            accountsMap.putAll([Select Name From Account where Id in :accountIds]);
            List<Tenancy_Contract__c> contractList = [Select Id, AccountInitials__c, Account__c From Tenancy_Contract__c where Account__c in :accountIds];
            for(Integer i = 0; i< contractList.size(); i++){
                string accAppriviations = '';
                accList = new List<String>();
                accList = accountsMap.get(contractList[i].Account__c).Name.trim().split(' ');
                for(string str :accList)
                    accAppriviations += str.substring(0, 1);
                contractList[i].AccountInitials__c = accAppriviations;
            }
            update contractList;
        }
    }
}