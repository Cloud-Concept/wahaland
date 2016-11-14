public class cls_CommunityCreateCase {
    public Account Tenant{get;set;}
    Id userId;
    Id contactId;
    Id AccountId;
    public contact RequestedContact{get;set;}
    public Case newCase{get;set;}
    public string TIF_Refrence_Number{get;set;}
    public string Location{get;set;}
    public string costRes{get;set;}
    public string ReuestedByName{get;set;}
    public string SelectedUnits {get;set;}
    public string SelectedTC {get;set;}
    public list<selectoption> UnitList {get;set;}
    public List<Tenancy_Contract__c> TCList ;
    public String errorLevel {get; set;}
    public String messageName {get; set;}
    public boolean inserted{get;set;}
    
    public cls_CommunityCreateCase(){
        if(inserted==null){
            userId = UserInfo.getUserId();
            contactId = [Select contactId from user where Id =:userId].contactId;
            RequestedContact = [Select Id, FirstName, LastName,accountId from contact where Id =:contactId];
            AccountId = RequestedContact.accountId ;
            Tenant = [Select Id, Name from account where Id=:AccountId];
            TCList= [Select Id, Tenancy_Contract_Number__c,(select Id,Unit__r.Unit_Name__C from Contract_Line_Items__r) from Tenancy_Contract__c where Account__c =:AccountId];
            newCase = new Case();
            newCase.AccountId = AccountId;
            newCase.Status = 'New';
            newCase.Origin = 'Web';
            newCase.ContactId = contactId;
            ReuestedByName = RequestedContact.FirstName + ' ' + RequestedContact.LastName;
            inserted = false;
        }
    }
    
    public List<SelectOption> getTC(){
        //System.debug('TCList *** ' + TCList);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0', 'Select')); 
        for(Tenancy_Contract__c item:TCList){
            options.add(new SelectOption(item.Id, item.Tenancy_Contract_Number__c)); 
        }
        return options;
    }
    
    public list<selectoption> getUnits() { 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0', 'Select'));
        if(SelectedTC != null  ){
            System.debug('SelectedTC is : ' + SelectedTC);
            List<Contract_Line_Item__c> TCUnits = [Select Id, Unit__r.Unit_Name__C from Contract_Line_item__c where contract__c =:SelectedTC];
            //List<Contract_Line_Item__c> TCUnits = SelectedTC.Contract_Line_Items__r;
            for(Contract_Line_Item__c item: TCUnits){
                if(item.Unit__c != null){
                    System.debug('CLI-- '+ item.Id+' name --' +item.Unit__r.Unit_Name__C);
                    options.add(new SelectOption(item.Id+'', item.Unit__r.Unit_Name__C));
                }
                
            }
            
        }
        return options;
    }
    
    public void updateUnits(){
        System.debug('SelectedTC is : ***** ' + SelectedTC);
        
    }
    
    public PageReference saveCase(){
        
        inserted = true;
        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();  
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        system.debug('hereee ');
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();  
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id; 
        //Setting the DMLOption on Case instance
        newCase.setOptions(dmlOpts);  
        newCase.TIF_Refrence_No__c = TIF_Refrence_Number;
        newCase.Location__c = Location;
        newCase.Cost_Responsibility__c =costRes;
        if(SelectedTC != null && SelectedTC !='0')
            newCase.Tenancy_Contract__c = SelectedTC;
        if(SelectedUnits != null && SelectedUnits != '0' )
            newCase.Contract_Line_Item__c = SelectedUnits;
        insert newCase;
        system.debug('newCase ' + newCase);
        system.debug('inserted ' + inserted);
        PageReference casePage = new PageReference('/Portal/apex/vfp_CommunityCaseLayout?CaseId='+newCase.Id);
        return casePage;
        
    }
    public PageReference redirectCaseList(){
        PageReference casePage = new PageReference('/Portal/apex/vfp_CommunityCases');
        return casePage;
        
    }
    public void showMessage() {
        if(errorLevel == 'WARNING') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, messageName));
        }
    }
}