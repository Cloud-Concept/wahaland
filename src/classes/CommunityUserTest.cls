@isTest
public class CommunityUserTest {
	static testMethod void test1(){
        test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        contact con = new Contact(accountId = acc.Id, is_Primary__c = true, firstName = 'Test', LastName='Class', Email='testClass@test.com');
        insert con;   
        
        Pricebook2 SPB = new Pricebook2(name = 'pb',  isActive= True);
        insert SPB;
        Product2 pro = new Product2(name = 'Industrial Building');
        insert pro;
        Product2 pro2 = new Product2(name = 'Serviced Land');
        insert pro2;
        Product2 pro3 = new Product2(name = 'Unserviced Land');
        insert pro3;
        
        Plot_Land__c Plot1 = new Plot_Land__c(Name = 'SU01Test');
        insert Plot1;
        Id RTId = [Select Id, DeveloperName from RecordType where DeveloperName = 'Plot' and SObjectType='Unit__c' limit 1].Id;
        
        Tenancy_Contract__C tc = new Tenancy_Contract__C(Account__c = Acc.Id, contract_type__c = 'Standard Lease', Contract_Duration__c = 4, status__c = 'Draft');
        Insert tc;
        tc.Status__c = 'Active';
        update tc;

        tc.Status__c = 'Canceled';
        update tc;
        
        Tenancy_Contract__C tc2 = new Tenancy_Contract__C( Account__c = Acc.Id, contract_type__c = 'Standard Lease', Contract_Duration__c = 4, status__c = 'Draft');
        Insert tc2;
        
        tc2.Status__c = 'Active';
        update tc2;
        tc2.Status__c = 'Canceled';
        update tc2;
        

        test.stopTest();
    }
    
}