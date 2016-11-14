public class cls_CommunityCases {
    public List<Case> AccountCasses;
    Id userId;
    Id contactId;
    Id AccountId;
    
    private integer counter=0;  
    private integer list_size=15; 
    public integer total_size;
    
    public cls_CommunityCases(){
        userId = UserInfo.getUserId();
        contactId = [Select contactId from user where Id =:userId].contactId;
        AccountId = [Select accountId from contact where Id=:contactId].accountId;
       // AccountCasses = [Select Id, CaseNumber, Account.Name, Contact.FirstName, Contact.LastName, 
         //                Tenancy_Contract__c, Tenancy_Contract_Number__c,
           //              Unit__c, Type, status, ClosedDate, CreatedDate  from Case where AccountId =:AccountId];
        total_size = [SELECT COUNT() from Case where AccountId =:AccountId];
    }
    
    public PageReference redirectNewCase(){
        PageReference casePage = new PageReference('/Portal/apex/vfp_CommunityCreateCase');
        return casePage;
        
    }
    
    public List<Case> getAccountCasses(){
        AccountCasses = new List<Case>();
        AccountCasses = [Select Id, CaseNumber, Account.Name, Contact.FirstName, Contact.LastName, 
                         Tenancy_Contract__c, Tenancy_Contract_Number__c,
                         Unit__c, Type, status, ClosedDate, CreatedDate  
                         from Case 
                         where AccountId =:AccountId 
                         order by CreatedDate desc
                         limit :list_size 
                         offset :counter];    
            
        return AccountCasses;
    }

    public PageReference Beginning() {
      counter = 0;
      return null;
   }

   public PageReference Previous() {
      counter -= list_size;
      return null;
   }

   public PageReference Next() {
      counter += list_size;
      return null;
   }

   public PageReference End() {
      counter = total_size - math.mod(total_size, list_size);
      return null;
   }

   public Boolean getDisablePrevious() { 
      if (counter>0) return false; else return true;
   }

   public Boolean getDisableNext() {
      if (counter + list_size < total_size) return false; else return true;
   }

   public Integer getTotal_size() {
      return total_size;
   }

   public Integer getPageNumber() {
          if (total_size  == 0) return 0;
          else
      return counter/list_size + 1;
   }

   public Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
   }
}