@isTest
public class trg_TenancyContractOperations_Test {
        @isTest static void One(){
        
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today());
        Insert pp;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        List<Product2> products =  new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        products.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        products.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        products.add(pro3);
        insert products;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;

        Tenancy_Contract__c Oldtc = new Tenancy_Contract__c(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4, Status__c = 'Draft');
        Insert Oldtc;
        
        Tenancy_Contract__c tc = new Tenancy_Contract__c(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4, Status__c = 'Draft');
        Insert tc;
        
        tc.Status__c = 'Renewed' ;
        update tc;
    }
    
    @isTest static void Two(){
        
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today());
        Insert pp;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        List<Product2> products =  new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        products.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        products.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        products.add(pro3);
        insert products;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;

        Tenancy_Contract__c Oldtc = new Tenancy_Contract__c(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4, Status__c = 'Draft');
        Insert Oldtc;
        
        Tenancy_Contract__c tc = new Tenancy_Contract__c(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4, Status__c = 'Draft');
        Insert tc;
        Unit__c unit1 = new Unit__c(name = '0001000', Current_Tenancy_Contracts__c = OldTc.Id, Plot__c = Plot1.Id, Product_Type__c = pro.Id, RecordTypeId = RTId, Availability__c = 'Available', 
                                    Bulidling__c = 'A', ADDC_Account_Number__c = '123', ADDC_Premise_ID_Number__c= '123', List_Price__C = 16000);
        
        insert unit1;
        Contract_Line_Item__c cli = new Contract_Line_Item__c(Contract__c = tc.Id, Unit__c = unit1.Id, Quantity__c = 50, UnitPrice__c = 55);
        Insert cli;
        
        tc.Status__c = 'Canceled' ;
        update tc;
        
    }
    
    @isTest static void Three(){
        
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today());
        Insert pp;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        List<Product2> products =  new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        products.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        products.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        products.add(pro3);
        insert products;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;

        Tenancy_Contract__c Oldtc = new Tenancy_Contract__c(Quote__c = q.Id, Account__c = Acc.Id, contract_type__c = 'Standard Lease', Contract_Duration__c = 4, Status__c = 'Active');
        Insert Oldtc;
        
        Tenancy_Contract__c tc = new Tenancy_Contract__c(Quote__c = q.Id, Account__c = Acc.Id, contract_type__c = 'Standard Lease', Contract_Duration__c = 4, Status__c = 'Draft');
        tc.Renewed_Contract__c = Oldtc.Id;
        Insert tc;
        
        tc.Status__c = 'Active' ;
        update tc;    
        delete tc;
        delete Oldtc;
    }
    
    
    @isTest static void Three_2(){
        
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        List<Product2> products =  new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        products.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        products.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        products.add(pro3);
        insert products;
        Service_Name__c servName = new Service_Name__c(Name= 'Standard Lease');
        insert servName;
        Services__c service = new Services__c(Contract_Documents_Name__c = servName.Id);
        insert service;
        Service_Documents_CheckList__c sdc = new Service_Documents_CheckList__c(doc_Name__c = 'Test',Name = 'Test', services__c = service.Id);
        insert sdc;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Tenancy_Contract__c tc = new Tenancy_Contract__c(Account__c = Acc.Id, contract_type__c = 'Standard Lease', Contract_Duration__c = 4, Status__c = 'Draft');
        Insert tc;
        
        tc.Status__c = 'Active' ;
        update tc;
        
        
        Service_Documents_CheckList__c sdc2 = new Service_Documents_CheckList__c(doc_Name__c = 'Test',Name = 'Test', services__c = service.Id);
        insert sdc2;
        
        sdc2.Name = 'Test 3';
        update sdc2;
        
        delete sdc2;
        delete service;
    }
    
    @isTest static void four(){
        
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today());
        Insert pp;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        List<Product2> products =  new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        products.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        products.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        products.add(pro3);
        insert products;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Tenancy_Contract__c tc = new Tenancy_Contract__c(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4, Status__c = 'Draft');
        Insert tc;
        
        tc.Status__c = 'Under Cancellation' ;
        update tc;
    }
    
    @isTest static void Five(){
        
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        Quote q = new Quote(name = 'q', OpportunityId = opp.Id, Contract_Duration__c = 4);
        insert q;
        Payment_Plan__c pp = new Payment_Plan__c(Quote__c = q.Id, Due_Date__c = System.today());
        Insert pp;
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        List<Product2> products =  new List<Product2>();
        Product2 pro = new Product2(name = 'Industrial Building');
        products.add(pro);
        Product2 pro2 = new Product2(name = 'Serviced Land');
        products.add(pro2);
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        products.add(pro3);
        insert products;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;

        Tenancy_Contract__c tc = new Tenancy_Contract__c(Quote__c = q.Id, Account__c = Acc.Id, Contract_Duration__c = 4, Status__c = 'Draft');
        Insert tc;
        
        tc.Status__c = 'Canceled' ;
        update tc;
    }
}