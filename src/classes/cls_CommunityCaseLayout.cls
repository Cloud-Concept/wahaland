public class cls_CommunityCaseLayout {
    public case selectedCase{get;set;}
    public string contactName{get;set;}
    Id caseId;
    public cls_CommunityCaseLayout(){
        if(ApexPages.currentPage().getParameters().get('CaseId') != null) {
            caseId = ApexPages.currentPage().getParameters().get('CaseId');
            selectedCase = [Select Id, CaseNumber, Account.Name, Contact.FirstName, Contact.LastName, 
                         Tenancy_Contract__c, Tenancy_Contract_Number__c,
                         Unit__c, Type, status, ClosedDate, CreatedDate, Cost_Responsibility__c, Location__c, TIF_Refrence_No__c, Description from Case where Id =:caseId];
            contactName = selectedCase.Contact.FirstName + ' ' + selectedCase.Contact.LastName;
        }
    }
    
    public PageReference redirectCaseList(){
        PageReference casePage = new PageReference('/Portal/apex/vfp_CommunityCases');
        return casePage;
        
    }
}