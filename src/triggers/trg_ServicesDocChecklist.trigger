trigger trg_ServicesDocChecklist on Service_Documents_CheckList__c (after insert, before delete, after update) {
    List<Tenancy_Contract__c> tcToBeUpdated = new List<Tenancy_Contract__c>();
    Map<Id, List<Service_Documents_CheckList__c>> serviceDocsMap = new Map<Id, List<Service_Documents_CheckList__c>>();
    Map<string, List<Service_Documents_CheckList__c>> serviceName_DocsMap = new Map<string, List<Service_Documents_CheckList__c>>();
    List<Service_Documents_CheckList__c> serviceDocsList;
    Map<Id, Services__c> serviceMap = new Map<Id, Services__c>();
    List<contract_documents__c> cdList;
    set<Id> docsId = new set<Id>();
    Map<Id, List<string>> checkListDocNames = new Map<Id, List<string>>();
    set<Id> docIds = new set<Id>();
    List<contract_documents__c> contractDocs = new List<contract_documents__c>();
    string docName;
    string Name;
    if(trigger.isDelete){
        for(Service_Documents_CheckList__c doc:Trigger.Old){
            docsId.add(doc.Id);
        }
        system.debug('docsId ' + docsId);
        cdList = new List<contract_documents__c>();
        cdList = [Select Id from contract_documents__c where Service_Documents_CheckList__c in :docsId and tenancy_contract__r.status__c = 'Active'];
        system.debug('cdList ' + cdList);
        if(cdList.size()>0){
            delete cdList;
        }
    }
    if(trigger.isInsert){
        for(Service_Documents_CheckList__c doc:Trigger.New){
            serviceDocsList = serviceDocsMap.get(doc.services__c);
            if(serviceDocsList == null){
                serviceDocsList = new List<Service_Documents_CheckList__c>();
            }
            serviceDocsList.add(doc);
            serviceDocsMap.put(doc.services__c, serviceDocsList);
        }
        if(serviceDocsMap.size()>0){
            serviceMap.putAll([Select Id, Service_Identifier__c from services__c where id in:serviceDocsMap.keySet()]);
            for(Id servId:serviceMap.keySet()){
                serviceName_DocsMap.put(serviceMap.get(servId).Service_Identifier__c, serviceDocsMap.get(servId));
            }
            tcToBeUpdated = [Select Id, Contract_Type__c,PrimaryContactEmail__c from Tenancy_Contract__c where contract_type__c in:serviceName_DocsMap.keySet() and status__c = 'Active'];
            cdList = new List<contract_documents__c>();
            for(Tenancy_Contract__c tc:tcToBeUpdated){
                serviceDocsList = serviceName_DocsMap.get(tc.Contract_Type__c);
                if(serviceDocsList != null){
                    for(Service_Documents_CheckList__c doc:serviceDocsList){
                        cdList.add(new contract_documents__c (Service_Documents_CheckList__c = doc.Id, Name = doc.Name , Doc_Name__c = doc.Doc_Name__c , Doc_Type__c = doc.Doc_Type__c
                           , Has_Template__c = doc.Has_Template__c , Tenancy_Contract__c = tc.Id
                           , Template_URL__c = doc.Template_URL__c, ContactEmail__c = tc.PrimaryContactEmail__c));
                    }
                }
            }
            if(cdList.size()>0){
                insert cdList;
            }
        }
    }
    if(trigger.isupdate){
        for(Service_Documents_CheckList__c doc :trigger.New){
            docName = trigger.OldMap.get(doc.Id).Doc_Name__c;
            Name = trigger.OldMap.get(doc.Id).Name;
            if(docName != doc.Doc_Name__c || Name != doc.Name){
                docIds.add(doc.Id);
                List<string> names = new List<string>();
                names.add(doc.Name);
                names.add(doc.Doc_Name__c);
                checkListDocNames.put(doc.Id, names);
            }
        }
        contractDocs = [Select Id, doc_Name__c, Service_Documents_CheckList__c from contract_documents__c where Service_Documents_CheckList__c in :docIds and tenancy_contract__r.status__c = 'Active'];
        for(contract_documents__c doc:contractDocs){
            doc.Name = checkListDocNames.get(doc.Service_Documents_CheckList__c)[0];
            doc.doc_Name__c = checkListDocNames.get(doc.Service_Documents_CheckList__c)[1];
        }
        if(contractDocs.size()>0){
            update contractDocs;
        }
    }
}