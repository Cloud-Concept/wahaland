@isTest
Private class trg_Unit_Test{
    static Product2 product = new Product2();
    static Plot_Land__c Plot1;
    static Unit__C unit1;
    static Unit__C unit2;
    static Unit__C unit3;
    static Unit__C unit4;
    static Id RTId;
    
    static testMethod void testUnitUniqueId_Insert(){     
        test.startTest();
        CreateUnit();
        unit3 = new Unit__C(name = '0001000', Plot__c = Plot1.Id, Product_Type__c = product.Id, RecordTypeId = RTId, Bulidling__c = 'A');
        try{
            insert unit3;
        }
        catch(Exception e){}
        Unit2.Bulidling__c = 'A';
        try{
            update Unit2;
        }
        catch(Exception e){}
        test.stopTest();
    }
    
    static void CreateUnit(){
        product = new Product2();
        product.Name = 'Unserviced Land';
        insert product;
        product = new Product2();
        product.Name = 'Serviced Land';
        insert product;
        product = new Product2();
        product.Name = 'Industrial Building';
        insert product;
        Plot1 = new Plot_Land__c();
        Plot1.Name = 'SU01Test';
        insert Plot1;
        
        RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        unit1 = new Unit__C(name = '0001000', Plot__c = Plot1.Id, Product_Type__c = product.Id, RecordTypeId = RTId,
                            Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        insert unit1;
        unit2 = new Unit__C(name = '0001000', Plot__c = Plot1.Id, Product_Type__c = product.Id, RecordTypeId = RTId,
                            Bulidling__c = 'B', ADDC_Account_Number__c = '321', ADDC_Premise_ID_Number__c= '321', List_Price__C = 27000);
        insert unit2;
        
        Id sLRecordTypeId = [select id from recordtype where SobjectType = 'Unit__c' and developername = 'Service_Land' ].Id;
        Id uSLRecordTypeId = [select id from recordtype where SobjectType = 'Unit__c' and developername = 'Unserviced_Land' ].Id;
        
        //test trg_updateProductUnit
        unit4 = new Unit__C(name = '0001000', Plot__c = Plot1.Id, Product_Type__c = product.Id, RecordTypeId = sLRecordTypeId,
                            Bulidling__c = 'B', ADDC_Account_Number__c = '321', ADDC_Premise_ID_Number__c= '321', List_Price__C = 27000);
        insert unit4;
        unit4 = new Unit__C(name = 'test', Plot__c = Plot1.Id, Product_Type__c = product.Id, RecordTypeId = uSLRecordTypeId,
                            Bulidling__c = 'B', ADDC_Account_Number__c = '321', ADDC_Premise_ID_Number__c= '321', List_Price__C = 27000
                           , Availability__c = 'Available');
        insert unit4;
        unit4.Availability__c = 'Pending sales';
        update unit4;
        unit4.Availability__c = 'Available';
        update unit4;
    }
}