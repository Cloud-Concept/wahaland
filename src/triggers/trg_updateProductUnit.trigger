trigger trg_updateProductUnit on Unit__c (before insert, before update) {
    //this trigger is to auto select the product based on the unit record type
    Id PlotProduct;
    Id UnServicedProduct;
    Id ServicedProduct;
    List<Product2> products = new List<Product2>();
    Id plotRecordTypeId;
    Id sLRecordTypeId;
    Id uSLRecordTypeId;
    
    plotRecordTypeId = [select id from recordtype where SobjectType = 'Unit__c' and developername = 'Plot' ].Id;
    sLRecordTypeId = [select id from recordtype where SobjectType = 'Unit__c' and developername = 'Service_Land' ].Id;
    uSLRecordTypeId = [select id from recordtype where SobjectType = 'Unit__c' and developername = 'Unserviced_Land' ].Id;
    
    products = [Select Id From Product2 where Name='Industrial Building' limit 1];
    PlotProduct = products[0].Id;
    products = [Select Id From Product2 where Name='Serviced Land' limit 1];
    ServicedProduct = products[0].Id; 
    products = [Select Id From Product2 where Name='Unserviced Land'limit 1];
    UnServicedProduct = products[0].Id; 
    List<Unit__c> units = new List<Unit__c>();
    
    for(Unit__c item: trigger.New){
        system.debug(item);
        if(item.RecordTypeId == plotRecordTypeId)
            item.Product_Type__c = PlotProduct;
        if(item.RecordTypeId == sLRecordTypeId)
            item.Product_Type__c = ServicedProduct;
        if(item.RecordTypeId == uSLRecordTypeId)
            item.Product_Type__c = UnServicedProduct;
        units.add(item);
    }
    system.debug(units[0]);
}