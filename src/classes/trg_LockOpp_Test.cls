@isTest
public class trg_LockOpp_Test {
    
    static testMethod void lockOPP(){
        test.startTest();
        Account Acc = new Account(name  = 'Acc1');
        Insert Acc;
        Opportunity opp = new Opportunity(name = 'Opp', AccountId = Acc.id, Start_Date__c = System.today(), Product_Type__c = 'Industrial Building', CloseDate = System.today(), StageName = 'Opening');
        Insert opp;
        
        opp.StageName = 'Closed Won';
        update opp;
        test.stopTest();
    }
}