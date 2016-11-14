@isTest
public class Test_IntgratedAccountOperations {
    
    @isTest public static void createData(){
        Account Acc = new Account(name = 'Acc' , Integration__c = true , Account_Units__c ='SU01/A/1', Rate_AED_m2__c = 200,
                                   Con_Last_Name__c='Test', Con_First_Name__C='test', Con_Email__c='nbeshay@ccwaha.com', Land_Name__c='Test Unserviced', Land_Area__c=5000, Land_Rate__c=20
                                  ,Term_Commencement_Date__c=date.Today(),Lease_Tenure_yrs__c=5,Term_End_Date__c=Date.Today(), Lease_Commencement_Date__c=date.Today());
         Insert Acc;
         Account Acc1 = new Account(name = 'Acc' , Integration__c = true , Account_Units__c ='SU01/A/25', Rate_AED_m2__c = 200,
                                   Con_Last_Name__c='Test', Con_First_Name__C='test', Con_Email__c='nbeshay@ccwaha.com', Land_Name__c='Test Unserviced', Land_Area__c=5000, Land_Rate__c=20
                                  ,Term_Commencement_Date__c=date.Today(), Lease_Tenure_yrs__c=5);
         Insert Acc1;
         Account Acc3 = new Account(name = 'Acc' , Integration__c = true , Account_Units__c ='SU02', Rate_AED_m2__c = 200,
                                   Con_Last_Name__c='Test', Con_Email__c='nbeshay@ccwaha.com', Con_First_Name__C='test', Land_Name__c='Test Unserviced', Land_Area__c=5000, Land_Rate__c=20
                                  ,Term_Commencement_Date__c=date.Today(), Lease_Tenure_yrs__c = 5);
        Insert Acc3;
         
         Plot_Land__c plot = new Plot_Land__c (name ='Unserviced Land');
         insert plot;
         
         Plot_Land__c plot1 = new Plot_Land__c (name ='SU01');
         insert plot1;
         
         Plot_Land__c plot2 = new Plot_Land__c (name ='SU02');
         insert plot2;
         
        Product2 product = new Product2();
        product.Name = 'Unserviced Land';
        insert product;
        Product2 product1 = new Product2();
        product1.Name = 'Serviced Land';
        insert product1;
        Product2 product3 = new Product2();
        product3.Name = 'Industrial Building';
        insert product3;
        
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        Unit__C unit1 = new Unit__C(name = '25', Plot__c = Plot1.Id, Product_Type__c = product.Id, RecordTypeId = RTId,
                            Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000, Area_in_sq_m__c = 250);
        insert unit1;
        
        Unit__C unit3 = new Unit__C(name = '1', Plot__c = Plot1.Id, Product_Type__c = product.Id, RecordTypeId = RTId, Area_in_sq_m__c = 250,
                            Bulidling__c = 'A', ADDC_Account_Number__c = '321', ADDC_Premise_ID_Number__c= '321', List_Price__C = 27000);
        insert unit3;
        Unit__C unit4 = new Unit__C(name = '3', Plot__c = plot2.Id, Product_Type__c = product.Id, RecordTypeId = RTId,
                            Bulidling__c = 'B', ADDC_Account_Number__c = '321', ADDC_Premise_ID_Number__c= '321', List_Price__C = 27000
                           , Availability__c = 'Available', Area_in_sq_m__c = 250);
        insert unit4;
    }
     @isTest static void integration_Test(){
         test.startTest();
         createData();
       
         IntegratedAccountOperations.insertDummyContact();
         IntegratedAccountOperations.insertAccountUnits();
         test.stopTest();
    }
    
    @isTest static void integration_Test2(){
         test.startTest();
         createData();
       
         IntegratedAccountOperations.insertTenancyContract();
         IntegratedAccountOperations.activateTenancyContract();
         test.stopTest();
    }
}