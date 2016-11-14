trigger trg_Quote_Attachment on Attachment (after insert, after update, after delete) {
    String imageURL ='/servlet/servlet.FileDownload?file=';
    String fullFileURL;
    List<Quote_Attachment__c> insertAttachmentURL = new List<Quote_Attachment__c>();
    List<Quote_Attachment__c> updateAttachmentURL = new List<Quote_Attachment__c>();
    List<Quote_Attachment__c> deleteAttachmentQuote = new List<Quote_Attachment__c>();
    List<String> attachmentIdtoBeDeleted = new List<String>();
    List<String> attachmentIdtoBeUpdated = new List<String>();
    set<Id> invoiceIds;
    set<Id> attachmentIds;
    Map<Id, string> invoiceAttachmentMap;
    if(Trigger.IsDelete){
        for(Attachment attach:Trigger.Old){
            if(attach.ParentId.getSobjectType() == Quote.SobjectType){
                attachmentIdtoBeDeleted.add(attach.Id);
            }
        }
        if(attachmentIdtoBeDeleted.size()>0){
            deleteAttachmentQuote = [Select Id From Quote_Attachment__c where name in :attachmentIdtoBeDeleted];
            if(deleteAttachmentQuote.size()>0)
                delete deleteAttachmentQuote;
        }
    }
    else if(Trigger.IsUpdate){
        for(Attachment attach:Trigger.New){
            if(attach.ParentId.getSobjectType() == Quote.SobjectType){
                attachmentIdtoBeUpdated.add(attach.Id);
            }
        }
        if(attachmentIdtoBeUpdated.size()>0){
            updateAttachmentURL = [Select Id, name, URL__c From Quote_Attachment__c where name in :attachmentIdtoBeUpdated];
            for(integer i = 0; i < updateAttachmentURL.size(); i++){
                Attachment attach = trigger.newMap.get(Id.valueof(updateAttachmentURL[i].name));
                
                fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + imageURL + attach.id;
                system.debug(fullFileURL);
                updateAttachmentURL[i].Attachment_Name__c = attach.Name;
                updateAttachmentURL[i].URL__C = fullFileURL;
            }
            
            if(updateAttachmentURL.size() > 0)
                update updateAttachmentURL;
        }
    }
    else if(Trigger.IsInsert){
        invoiceIds = new set<Id>();
        attachmentIds = new set<Id>();
        invoiceAttachmentMap = new Map<Id, string>();
        for(Attachment attach:Trigger.New){
            if(attach.ParentId.getSobjectType() == Quote.SobjectType){
                fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + imageURL + attach.id;
                system.debug(fullFileURL);
                insertAttachmentURL.add(New Quote_Attachment__c(Attachment_Name__c = attach.Name, name = attach.Id, Quote__c = attach.ParentId, URL__c = fullFileURL ));
            }
            if(attach.ParentId.getSobjectType() == invoice__c.SobjectType){
                invoiceIds.add(attach.ParentId);
                attachmentIds.add(attach.Id);
                invoiceAttachmentMap.put(attach.ParentId, attach.Name);
            }
        }
        if(insertAttachmentURL.size()>0) 
            insert insertAttachmentURL;
        
        if(invoiceIds.size()>0){
            List<invoice__c> invoices = new List<invoice__c>();
            List<attachment> deleteAttachments = new List<attachment>();
            invoices = [select Id, name, Invoice_Attached__c, (select Id, name from attachments where id not in :attachmentIds) from Invoice__c where id in:invoiceIds];
            List<invoice__c> invoicesAttachToBeUpdated = new List<invoice__c>();
            string attachName;
            for(invoice__c inv:invoices){
                attachName = invoiceAttachmentMap.get(inv.Id);
                if(attachName.Substring(0, attachName.indexOf('.')) == inv.Name.replace('/', '_')){
                    inv.Invoice_Attached__c = true;
                    invoicesAttachToBeUpdated.add(inv);
                }
            }
            if(invoicesAttachToBeUpdated.size()>0){
                update invoicesAttachToBeUpdated;
                for(invoice__c inv:invoicesAttachToBeUpdated){
                    for(attachment attach:inv.attachments){
                        if(attach.Name.Substring(0, attach.Name.indexOf('.')) == inv.Name.replace('/', '_')){
                            deleteAttachments.add(attach);
                        }
                    }
                }
                if(deleteAttachments.size()>0){
                    delete deleteAttachments;
                }
            } 
        }
    }
}