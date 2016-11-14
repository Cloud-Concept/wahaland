trigger trg_Quote on Quote (before update, after update) {
    
    // this trigger is to 
    // 1- update the record types based on the updated status.
    // 2- in case of accepted status the units will be updated to be reserved.
    // this cannot be done via process builder or workflow, as the record has been changed via Approval Process
    // 3- if Khalif fund changed, update its Tenancy Contract
    
    List<Quote> approvedQuotes = new List<Quote>();
    List<Quote> accpetedQuotes = new List<Quote>();
    Quote oldQuote = new Quote();
    Id AcceptedRTypeId;
    Id ApprovedRTypeId;
    Set<Id> accpetedQuoteIds = new Set<Id>();
    Set<Id> ApprovedQuoteIds = new Set<Id>();
    Set<Id> DeniedQuoteIds = new Set<Id>();
    List<Payment_Plan__C> ppList = new List<Payment_Plan__C>();
    List<Unit__c> units = new List<Unit__c>();
    Set<Id> KFChanged = new Set<Id>();
    Map<Id, boolean> QuoteKFMap = new Map<Id, boolean>();
    List<Tenancy_Contract__c> TCList = new List<Tenancy_Contract__c>();
    
    //define the Approved and Accepted Record Type Ids
    ApprovedRTypeId = [select id from recordtype where SobjectType = 'Quote' and developername = 'Approved' ].Id;
    AcceptedRTypeId = [select id from recordtype where SobjectType = 'Quote' and developername = 'Accepted' ].Id;
    if(Trigger.IsBefore){
        //update the records
        if(Trigger.isUpdate){
            for(Quote item:trigger.New){
                oldQuote = trigger.OldMap.get(item.Id);
                //if KF changed
                if(item.Khalifa_Fund__c != oldQuote.Khalifa_Fund__c){
                    KFChanged.add(item.Id);
                    QuoteKFMap.put(item.Id, item.Khalifa_Fund__c);
                }
                if(item.Reservation_Amount__c != oldQuote.Reservation_Amount__c){
                    item.ReservationAmountWord__c = NumberToWord.english_number((long)item.Reservation_Amount__c);
                }
                //check if the status has been changed
                if(item.Status != oldQuote.Status){
                    if(item.Status == 'Approved'){
                        item.RecordTypeId = ApprovedRTypeId;
                        ApprovedQuoteIds.add(item.Id);
                    }
                    else if(item.Status == 'Accepted'){
                        item.RecordTypeId = AcceptedRTypeId;
                        accpetedQuoteIds.add(item.Id);
                    }
                    else if(item.Status == 'Denied'){
                        DeniedQuoteIds.add(item.Id);
                    }
                }
            }
            
            //if Approved then Lock the Payments 
            if(ApprovedQuoteIds.size()>0){
                ppList = [Select Id, SubmitForApproval__c From Payment_Plan__c where Quote__c in :ApprovedQuoteIds];
                for(integer i = 0; i<ppList.Size(); i++){
                    ppList[i].SubmitForApproval__c = true;
                    system.debug('Offer Payment: '+ ppList[i]);
                }
                if(ppList.size()>0)
                    update ppList;
            }
            //if accepted then Reserve the units
            if(accpetedQuoteIds.Size()>0){
                integer i = 0;
                units = [select Id, Availability__c from unit__c where Reserved_by_Offer_Letter__c in :accpetedQuoteIds];
                i = 0;
                
                for(unit__c item :units){
                    system.debug('N ' + item );
                    if(units[i].Availability__c == 'Pending Sales')
                        units[i].Availability__c = 'Reserved';
                    else if(units[i].Availability__c == 'Leased / Pending Sales')
                        units[i].Availability__c = 'Leased / Reserved';
                    i++;
                }
                
                if(units.size()>0)
                    update units;
                
            }
            
            //update Tenancy Contract KFund
            if(KFChanged.size()>0){
                TCList.addAll([Select Id, KFund__C, Quote__c From Tenancy_Contract__c where Quote__C in :KFChanged]);
                for(integer i = 0; i < TCList.size(); i++){
                    TCList[i].KFund__C = QuoteKFMap.get(TCList[i].Quote__c);
                }
                if(TCList.size()>0){
                    update TCList;
                }
            }
            
            if(DeniedQuoteIds.size()>0){
                List<QuoteLineItem> qli = new List<QuoteLineItem>();
                qli = [Select Id, Unit__c From QuoteLineItem where quoteId in:DeniedQuoteIds];
                set<Id> unitIds = new Set<Id>();
                for(QuoteLineItem item:qli){
                    unitIds.add(item.Unit__c);
                }
                List<Unit__c> iUList = new List<Unit__c>();
                iUList = [Select Id, Reserved_Leased_Until__c, Reserved_by_Offer_Letter__c, Availability__c From Unit__C where id in: unitIds ];
                integer i = 0;
                for(Unit__c unit : iUList){
                    iUList[i].Reserved_Leased_Until__c = null;
                    iUList[i].Reserved_by_Offer_Letter__c = null;
                    if(iUList[i].Availability__c == 'Reserved')
                        iUList[i].Availability__c = 'Pending Sales';
                    else if(iUList[i].Availability__c == 'Leased / Pending Sales')
                        iUList[i].Availability__c = 'Leased / Pending Sales';
                    else if(iUList[i].Availability__c == 'Leased / Reserved')
                        iUList[i].Availability__c = 'Leased / Pending Sales';
                    else 
                        iUList[i].Availability__c = 'Pending Sales';
                    i++;
                }
                if(iUList.size() > 0) update iUList;
            }
        }
    }
    if(Trigger.IsAfter && Trigger.IsUpdate){
        Set<Id> accQuoteIds = new Set<Id>();
        List<Quote> acceptedQuotes  = new List<Quote>();
        Quote oQuote = new Quote();
        Set<Id> dealIds = new Set<Id>();
        List<Opportunity> deals = new List<Opportunity>();
        for(Quote item:trigger.New){
            oQuote = trigger.OldMap.get(item.Id);
            //check if the status has been changed
            if(item.Status != oQuote.Status){
                if(item.Status == 'Accepted'){
                    accQuoteIds.add(item.Id);
                    dealIds.add(item.OpportunityId);
                }
            }
        }
        if(accQuoteIds.size()>0){
            
            acceptedQuotes = [select Id from Quote where Id in:accQuoteIds];
            Approval.LockResult[] lrList = Approval.locK(acceptedQuotes, false);
            
        }
        if(dealIds.size()>0){
            deals = [Select Id, StageName from opportunity where id in: dealIds];
            for(integer i = 0; i< deals.Size(); i++){
                deals[i].StageName = 'Closed Won';
            }
            
            update deals;
        }
    }
}