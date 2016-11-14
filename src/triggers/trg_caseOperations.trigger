trigger trg_caseOperations on Case (before insert) {
    Id salesEntitlementId;
    Id technicalEntitlementId;
    List<entitlement> salesEntit = [select Id from entitlement where name ='Sales Entitlements' limit 1];
    if(salesEntit.size()>0)
        salesEntitlementId = salesEntit[0].Id;
    List<entitlement> techEntit = [select Id from entitlement where name ='Technical Entitlements' limit 1];
    if(techEntit.size()>0)
        technicalEntitlementId = techEntit[0].Id;
    
    for(Case c:Trigger.New){
        if(c.type == 'Sales/Leasing Issues'){
            c.EntitlementId = salesEntitlementId;
        }
        else if(c.type == 'Technical'){
            c.EntitlementId = technicalEntitlementId;
        }
    }
}