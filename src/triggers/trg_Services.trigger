trigger trg_Services on Services__c (before delete, before insert, before update, after insert, after update){
    
    set<id> servicesIds = new set<id>();
    set<id> docCheckList = new set<id>();
    List<Service_Documents_CheckList__c> serviceDoc = new List<Service_Documents_CheckList__c>();
    List<Contract_Documents__c> contDocuments = new list<Contract_Documents__c>();
    set<Id> serNotSelectedIds = new set<Id>();
    set<Id> serSelectedIds = new set<Id>();
    List<Service_Name__c> serviceNameNotSelected;
    List<Service_Name__c> serviceNameSelected;
    Map<Id, Service_Name__c> contractNamesMap;
    if(trigger.isbefore){
        if(trigger.isdelete){
            serviceNameNotSelected = new List<Service_Name__c>();
            serNotSelectedIds = new set<Id>();
            
            for(Services__c service:trigger.old){
                servicesIds.add(service.Id);
                serNotSelectedIds.add(service.Contract_Documents_Name__c);
            }
            serviceDoc = [select Id from Service_Documents_CheckList__c where services__c in :servicesIds];
            for(Service_Documents_CheckList__c doc:serviceDoc){
                docCheckList.add(doc.Id);
            }
            contDocuments = [Select Id from Contract_Documents__c where Service_Documents_CheckList__c in:docCheckList];
            if(contDocuments.size()>0){
                delete contDocuments;
            }
            
            
            if(serNotSelectedIds.size()>0){
                serviceNameNotSelected=[Select Id, selected__c from Service_Name__c where Id in:serNotSelectedIds];
                for(Service_Name__c scName:serviceNameNotSelected){
                    scName.selected__c = false;
                }
                update serviceNameNotSelected;
            }
            
        }
        else{
            contractNamesMap = new Map<Id, Service_Name__c>();
            contractNamesMap.putall([select Id, Name from Service_Name__c]);
            for(Services__c service:trigger.new){
                service.Service_Identifier__c = contractNamesMap.get(service.Contract_Documents_Name__c).Name;
            }
        }
    }
    else{
        contractNamesMap = new Map<Id, Service_Name__c>();
        serviceNameNotSelected = new List<Service_Name__c>();
        serviceNameSelected = new List<Service_Name__c>();
        serNotSelectedIds = new set<Id>();
        serSelectedIds = new set<Id>();
        contractNamesMap.putall([select Id, Name from Service_Name__c]);
        Services__c oldService;
        
        for(Services__c service:trigger.new){            
            if(trigger.isupdate){
                oldService = trigger.oldMap.get(service.Id);
                if(service.Contract_Documents_Name__c != oldService.Contract_Documents_Name__c){
                    serNotSelectedIds.add(oldService.Contract_Documents_Name__c);
                    serSelectedIds.add(service.Contract_Documents_Name__c);
                }
            }
            else
            {
                serSelectedIds.add(service.Contract_Documents_Name__c);
            }
        }
        if(serNotSelectedIds.size()>0){
            serviceNameNotSelected=[Select Id, selected__c from Service_Name__c where Id in:serNotSelectedIds];
            for(Service_Name__c scName:serviceNameNotSelected){
                scName.selected__c = false; 
            }
            update serviceNameNotSelected;
        }
        if(serSelectedIds.size()>0){
            serviceNameSelected=[Select Id, selected__c from Service_Name__c where Id in:serSelectedIds];
            for(Service_Name__c scName:serviceNameSelected){
                scName.selected__c = true;
            }
            update serviceNameSelected;
        }
    }
    
}