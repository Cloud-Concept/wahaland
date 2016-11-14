@isTest
public class trg_RestrictEditDelete_OPPLI_Test {
    
    static testMethod void testRestriction(){
        Test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntryStd;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        Plot_Land__c Plot1 = new Plot_Land__c();
        Plot1.Name = 'SU01Test';
        insert Plot1;
        Unit__c unit1 = new Unit__C(name = '0001000', Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId,
                            Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        insert unit1;
        Unit__c unit2 = new Unit__C(name = '0001000', Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId,
                            Bulidling__c = 'B', ADDC_Account_Number__c = '321', ADDC_Premise_ID_Number__c= '321', List_Price__C = 27000);
        insert unit2;
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id, ReadOnly__c = true,PriceBookEntryID=pbEntryStd.id, quantity=4, totalprice=200,Unit__c = unit1.Id);
        insert lineItem1;
        try{
            lineItem1.Quantity = 7;
            update lineItem1;
        }
        catch(Exception e){}
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=opp.id, ReadOnly__c = false,PriceBookEntryID=pbEntryStd.id, quantity=4, totalprice=200,Unit__c = unit2.Id);
        insert lineItem2;
        lineItem2.Quantity = 1000;
        update lineItem2;
        
        test.stopTest();
    }
    
    static testMethod void UpdateProduct_test(){
        Test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntryStd;
        Plot_Land__c Plot1 = new Plot_Land__c();
        Plot1.Name = 'SU01Test';
        insert Plot1;
        Id sLRecordTypeId = [select id from recordtype where SobjectType = 'Unit__c' and developername = 'Service_Land' ].Id;
        Id uSLRecordTypeId = [select id from recordtype where SobjectType = 'Unit__c' and developername = 'Unserviced_Land' ].Id;
        
        Unit__c unit3 = new Unit__C(name = '0001000', Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = sLRecordTypeId,
                            Bulidling__c = 'B', ADDC_Account_Number__c = '321', ADDC_Premise_ID_Number__c= '321', List_Price__C = 27000);
        insert unit3;
        Unit__c unit4 = new Unit__C(name = 'test', Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = uSLRecordTypeId,
                            Bulidling__c = 'B', ADDC_Account_Number__c = '321', ADDC_Premise_ID_Number__c= '321', List_Price__C = 27000
                           , Availability__c = 'Available');
        insert unit4;
        
        PricebookEntry pbEntryStd2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro2.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntryStd2;
        OpportunityLineItem lineItem3 = new OpportunityLineItem (OpportunityID=opp.id, ReadOnly__c = true,PriceBookEntryID=pbEntryStd2.id, quantity=4, totalprice=200,Unit__c = unit3.Id);
        insert lineItem3;
        lineItem3.Quantity = 1000;
        try{update lineItem3;}
        catch(Exception e){}
        
        PricebookEntry pbEntryStd3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro3.Id, UnitPrice = 100.00, IsActive = true);
        insert pbEntryStd3;
        OpportunityLineItem lineItem4 = new OpportunityLineItem (OpportunityID=opp.id, ReadOnly__c = true,PriceBookEntryID=pbEntryStd3.id, quantity=4, totalprice=200,Unit__c = unit4.Id);
        insert lineItem4;
        lineItem4.Quantity = 1000;
        update lineItem4;
        try{
            delete lineItem4;
        }
        catch(Exception e){}
        test.stopTest();
    }
}