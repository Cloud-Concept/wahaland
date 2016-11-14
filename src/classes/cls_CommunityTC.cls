public class cls_CommunityTC {
    public List<Tenancy_Contract__c> TCList{get;set;}
    Id userId;
    Id contactId;
    Id AccountId;
    public cls_CommunityTC(){
        userId = UserInfo.getUserId();
        contactId = [Select contactId from user where Id =:userId].contactId;
        AccountId = [Select accountId from contact where Id=:contactId].accountId;
        TCList = [Select Id, Tenancy_Contract_Number__c, Contract_Expiry_Date__c, status__c, Term_Commencement_Date__c
                  from Tenancy_Contract__c where Account__c =:AccountId and status__c in('Active', 'Canceled', 'Renewed')];
        
    }
}