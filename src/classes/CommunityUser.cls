global Class CommunityUser{
    @future
    public static void createPortalUsers(List<Id> TCIds)
    {
        Contact c;
        user u;
        Set<Id> accountIds = new Set<Id>();
        List<Account> Accounts = new List<Account>();
        List<Tenancy_Contract__c> tcList = new List<Tenancy_Contract__C>();
        List<account> UserAccounts = new List<account>();
        List<account> activateUsers = new list<account>();
        List<User> users = new List<User>();
        tcList = [Select Id, account__c from Tenancy_Contract__c where id in :TCIds];
        
        for(Tenancy_Contract__c tc: tcList){
            accountIds.add(tc.account__c);
        }
        
        activateUsers = [Select Id, name, user__c From Account where id in :accountIds and user__c <> null and user__r.isactive = false];
        system.debug('activateUsers '  + activateUsers);
        for(account acc :activateUsers){
            u = new user();
            u.id = acc.User__c;
            u.IsActive = true;
            users.add(u);
        }
        if(users.size()>0){
            update users;
        }
        
        Accounts = [Select Id, Email__c, name, (select Id, FirstName, LastName, email, Title, MobilePhone, Phone From contacts where is_Primary__c = true),(select Id from Tenancy_Contracts__r) From Account where id in :accountIds and user__c = null];
        for(account acc: accounts){
            if(acc.contacts.size()>0){
                UserAccounts.add(acc);
            }
        }
        
        Profile p =[SELECT Id from Profile WHERE Name = 'Waha Customer Community Plus User'];
        //userrole r = [select Id from userrole where DeveloperName = 'Customer_Portal_User'];
        
        String accLastName;
        users = new List<User>();
        set<Id> contactIds = new Set<Id>();
        for(Account AccountObj : UserAccounts){  
            system.debug('AccountObj ' + AccountObj);
            c = AccountObj.contacts[0];      
            if(c.email == '' || c.email == null)
                c.Email = AccountObj.Email__c;
            if(c.Email != '' && c.Email != null)
            {
                Integer rand = Math.round(Math.random()*1000);
                u = new User();
                u.Username = string.valueOf(rand) + c.email;
                u.Email = c.email;
                u.FirstName = c.firstname;
                if(c.Lastname == '' || c.Lastname == null) u.LastName = c.firstname ;
                else u.LastName = c.Lastname;
                u.CommunityNickname =  string.valueOf(rand) + c.FirstName.subString(0,2) + u.LastName;
                u.ContactId = c.Id;
                u.ProfileId = p.Id;
                contactIds.add(c.Id);
                u.Alias = c.firstname.substring(0,1) + u.LastName;
                if(u.Alias.length() > 6) u.Alias = u.Alias.substring(0 , 6);
                u.EmailEncodingKey = 'UTF-8';
                u.LocaleSidKey = 'en_US';
                u.LanguageLocaleKey = 'en_US';
                u.DefaultCurrencyIsoCode = 'AED';
                u.TimeZoneSidKey = 'Asia/Dubai';   
                //u.UserRoleId = r.Id;
                system.debug('user ' + u);
                try{
                    users.add(u); 
                //share contracts to the user    
        		//manualShareRead(AccountObj.Tenancy_Contracts__r,u.Id);
                AccountObj.User__c = u.id;
                }
                catch (exception e){
                    system.debug('Exception --> '+e);
                }
                System.debug(LoggingLevel.ERROR, 'u.Username ==========> ' + u.Username);
            }
        } 
        if(users.size()>0){
            insert users; 
        }
        
        if(UserAccounts.size()>0){
            update UserAccounts;
        }
        Map<Id, contact> contactsMap = new Map<Id, contact>();
        contactsMap.putAll([Select Id, accountId from contact where Id in:contactIds]);
        contact con = new contact();
        List<account> accountList = new List<account>();
        for(user comUser:users){
            con = contactsMap.get(comUser.ContactId);
            accountList.add(new account(Id = con.AccountId, user__c = comUser.Id));
        }
        if(accountList.Size()>0){
            update accountList;
        }
        
    }
    
    @future
    public static void deactivatePortalUser(List<Id> TCIds){
        Contact c;
        user u;
        Set<Id> accountIds = new Set<Id>();
        List<Account> Accounts = new List<Account>();
        List<Tenancy_Contract__c> tcList = new List<Tenancy_Contract__C>();
        List<account> UserAccounts = new List<account>();
        Map<Id, account> activeAccounts = new Map<Id, account>();
        tcList = [Select Id, account__c from Tenancy_Contract__c where id in :TCIds];
        List<User> users = new List<User>();
        
        for(Tenancy_Contract__c tc: tcList){
            accountIds.add(tc.account__c);
        }
        
        activeAccounts.putall([Select Id, name from Account where id in :accountIds and id in (select Account__c from Tenancy_Contract__c where status__c = 'active')]);
        
        Accounts = [Select Id, name, user__c From Account where id in :accountIds and user__r.isactive = true];
        for(account acc: accounts){
            if(activeAccounts.get(acc.Id) == null){
                u = new user();
                u.id = acc.User__c;
                u.IsActive = false;
                users.add(u);
            }
        }
        if(users.size()>0){
            update users;
        }
    }
    
    /*
   public static boolean manualShareRead(List<Tenancy_Contract__C> recordList, Id userOrGroupId){
      // Create new sharing object for the custom object Job.
      List<Tenancy_Contract__Share> TCShrList  = new List<Tenancy_Contract__Share>();
       for(Tenancy_Contract__C record:recordList){
           Tenancy_Contract__Share TCShr = new Tenancy_Contract__Share();
            
          // Set the ID of record being shared.
          TCShr.ParentId = record.Id;
            
          // Set the ID of user or group being granted access.
          TCShr.UserOrGroupId = userOrGroupId;
            
          // Set the access level.
          TCShr.AccessLevel = 'Read';
            
          // Set rowCause to 'manual' for manual sharing.
          // This line can be omitted as 'manual' is the default value for sharing objects.
          TCShr.RowCause = Schema.Tenancy_Contract__Share.RowCause.Manual;
          TCShrList.add(TCShr);     
       }  
        
      // Insert the sharing record and capture the save result. 
      // The false parameter allows for partial processing if multiple records passed 
      // into the operation.
      Database.SaveResult[] lsr = Database.insert(TCShrList,false);
		
        // Create counter
        Integer i=0;
        
        // Process the save results
        for(Database.SaveResult sr : lsr){
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default 
                // access level are not allowed. 
                // These sharing records are not required and thus an insert exception is 
                // acceptable. 
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                               &&  err.getMessage().contains('AccessLevel'))){
                    // Throw an error when the error is not related to trivial access level.
                    System.debug('Unable to grant sharing access due to following exception: ' + err.getMessage());
                    return False;
                                                   
                }
            }
            i++;
        }
       
       
       return true;
   }*/
   
}