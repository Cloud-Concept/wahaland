public class IntegratedAccountOperations {
    private static Map<Id, List<Account_Unit__c>> accountUnitsMap;
    private static set<id> unitIds;
    private static List<Unit__c> searchResult;
    private static List<Unit__c> selectedItems;
    private static List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
    private static Id priceBookId;
    private static List<Opportunity> oppList;
    private static Map<Id, PricebookEntry> pbe;
    
    public static void insertDummyContact(){
        list<account> accounts = [select Id, Name, BillingPostalCode, BillingCity, BillingState, Account_Units__c, Industry, Total_Unit_Area__c, Rate_AED_m2__c, Income_Year__c, Lease_Commencement_Date__c , Term_Commencement_Date__c, Term_End_Date__c, Lease_Tenure_yrs__c, Con_First_Name__C, Con_Last_Name__c, Con_Mobile__c, Con_Email__c, Integration__c from account where Integration__c  = true];
        List<Contact> contacts = new List<Contact>();
        for(account acc:accounts){
            contact con = new contact();
            if(acc.Con_Last_Name__c <> '' && acc.Con_Last_Name__c <> null){
                con.FirstName = acc.Con_First_Name__C;
                con.LastName = acc.Con_Last_Name__c;
                con.AccountId = acc.Id;
                con.MailingPostalCode = acc.BillingPostalCode;
                con.MailingCity = acc.BillingCity;
                con.MailingState = acc.BillingState;
                con.Email = acc.Con_Email__c;
                con.MobilePhone = acc.Con_Mobile__c;
                con.Is_Primary__c = true;
                contacts.add(con);
            }
        }
        if(contacts.size()>0)
            insert contacts;
        
        system.debug('contacts '+ contacts);
    }
    
    public static void insertUnservedLandUnit(){
        list<account> accounts = [select Id, Land_Name__c, Land_Area__c, Land_Rate__c from account where (Land_Name__c<>'' and Land_Name__c<> null) and Integration__c  = true];
        Id RecordType = [Select Id from RecordType where developerName = 'Unserviced_Land' and sobjecttype = 'Unit__c'].Id;
        Id Plot = [Select Id from Plot_Land__c where name ='Unserviced Land' limit 1].Id;
        List<unit__c> unitList = new List<unit__c>();
        for(account acc:accounts){
            unit__c unit = new unit__c(name = acc.Land_Name__c, Area_in_sq_m__c = acc.Land_Area__c , List_Price__c = acc.Land_Rate__c * acc.Land_Area__c, RecordTypeId = RecordType, Plot__c= plot );
            unitList.add(unit);
        }
        insert unitList;
    }
    
    public static void insertAccountUnits(){
        list<account> accounts = [select Id, Account_Units__c, Integration__c, Rate_AED_m2__c from account where Integration__c  = true and Account_Units__c <>'SU02'];
        Map<Id,List<string>> accountMap = new Map<Id,List<string>>();
        Map<string, Id> unitMap = new Map<string, Id>();
        List<string> unitName = new List<string>();
        List<Unit__c> unitList = new List<Unit__c>();
        Map<Id, double> accountRate = new Map<Id, double>();
        List<Account_Unit__c> accUnits = new List<Account_Unit__c>();
        list<account> SU02account = [select Id, Account_Units__c, Integration__c, Rate_AED_m2__c from account where Integration__c  = true and Account_Units__c ='SU02'];
        List<Unit__c> SU02Units = [Select Id, Area_in_sq_m__c from Unit__c where Plot__r.name = 'SU02'];
        for(account acc:SU02account){
            for(Unit__c item:SU02Units){
                accUnits.add(new Account_Unit__c(Account__c = acc.Id, unit__c =item.Id));
                item.List_Price__c = acc.Rate_AED_m2__c * item.Area_in_sq_m__c;
            }
        }
        update SU02Units;
        for(account acc:accounts){
            double rate = 0;
            if(acc.Rate_AED_m2__c <> null)
                rate = acc.Rate_AED_m2__c;
            accountRate.put(acc.Id, rate);
            List<string> units = new List<string>();
            for(string str:acc.Account_Units__c.split('-')){
                units.add(str.trim());
            }
            accountMap.put(acc.Id, units);
            unitName.addall(units);
        }
        List<Unit__c> units = [Select Unit_Name__C, Id from Unit__c where Unit_Name__C in :unitName];
        for(unit__c item:units){
            unitMap.put(item.Unit_Name__C, item.Id);
        }
        for(Id accId:accountMap.keySet()){
            List<string> unitNameList = new List<string>();
            unitNameList = accountMap.get(accId);
            for(string item:unitNameList){
                accUnits.add(new Account_Unit__c(Account__c = accId, Unit__c = unitMap.get(item)));
                string unitN = item.substring(0, 3);
                unitN = unitN.capitalize();
                if(unitN == 'SU0'){
                    Unit__c unitItem = new unit__c(Id = unitMap.get(item), List_Price__c = 250* accountRate.get(accId));
                    unitList.add(unitItem);
                    system.debug('unitItem ' + unitItem);
                }
            }
        }
        if(unitList.size()>0)
            update unitList;
        if(accUnits.size()>0)
            insert accUnits;
    }
    
    public static void insertTenancyContract(){
        list<account> accounts = [select Id, Land_Name__c, Name, BillingPostalCode, BillingCity, BillingState, Account_Units__c, Industry, Total_Unit_Area__c, Rate_AED_m2__c, Income_Year__c, Lease_Commencement_Date__c , Term_Commencement_Date__c, Term_End_Date__c, Lease_Tenure_yrs__c, Integration__c, con_Email__c, Con_Mobile__c, (Select Id, Unit__c, unit__r.Product_Type__c, unit__r.Area_in_sq_m__c, unit__r.List_Price__c from Account_Units__r), (select Id from Contacts where Is_Primary__c = true) from account where Integration__c  = true];
        List<Tenancy_Contract__c> tcList = new List<Tenancy_Contract__c>();
        List<Contract_Line_Item__c> contractList = new List<Contract_Line_Item__c>();
        List<Contract_Payments__c> contractPayments = new List<Contract_Payments__c>();
        List<Tenancy_Contract_Payment__c> tenancyConPaymentList = new List<Tenancy_Contract_Payment__c>();
        Id recordTypeId;
        recordTypeId = [select id from recordtype where SobjectType = 'Tenancy_Contract__c' and developername = 'Draft' ].Id;
        
        Tenancy_Contract_Payment__c tCP;
        List<Payment_Plan__c> payments = new List<Payment_Plan__c>(); 
        List<unit__c> units = new List<unit__c>();
        Map<Id, List<Account_Unit__c>> accountUnits = new Map<Id, List<Account_Unit__c>>();
        for(account acc:accounts){
            if( acc.Term_Commencement_Date__c<> null){
                Tenancy_Contract__c tenancyContract = new Tenancy_Contract__c();        
                tenancyContract.Account__c = acc.Id;
                tenancyContract.Status__c = 'Draft';
                //edited by Nermin
                tenancyContract.Email__c = acc.con_Email__c;
                tenancyContract.Phone__c = acc.con_Mobile__c;
                if( acc.contacts.size()>0){
                    tenancyContract.Contact__c = acc.contacts[0].Id;
                }
                if(acc.Lease_Commencement_Date__c ==null){
                    acc.Lease_Commencement_Date__c = acc.Term_Commencement_Date__c; 
                }
                tenancyContract.Lease_Commencement_Date__c = acc.Lease_Commencement_Date__c;
                tenancyContract.Term_Commencement_Date__c = acc.Term_Commencement_Date__c;
                tenancyContract.Contract_Duration__c = acc.Lease_Tenure_yrs__c;
                tenancyContract.RecordTypeId = recordTypeId;
                if(acc.Term_End_Date__c <> null)
                    tenancyContract.Unit_Release_Date__c = acc.Term_End_Date__c;
                else
                    tenancyContract.Unit_Release_Date__c = acc.Term_Commencement_Date__c.AddMonths(integer.valueof(acc.Lease_Tenure_yrs__c * 12));
                tenancyContract.Contract_Expiry_Date__c = tenancyContract.Unit_Release_Date__c;
                /*tenancyContract.Basic_Service_Charge__c = quoteObj.Basic_Service_Charge__c;
tenancyContract.Annual_Year_Rent__c = quoteObj.Annual_Year_Rent__c;
tenancyContract.Security_Deposit__c = quoteObj.Security_Deposit__c;
tenancyContract.Reservation_Amount__c = quoteObj.Reservation_Amount__c;*/        
                // edited by Marina
                tenancyContract.Number_of_Years_for_Service_Charges__c = acc.Lease_Tenure_yrs__c;
                tenancyContract.Owner_Expiration_Notice_days__c = 60;
                tenancyContract.Agreement_Status__c = 'Approved';
                // tenancyContract.Description__c='Test by Nermin.';
                accountUnits.put(acc.Id, acc.Account_Units__r);
                /*if (quoteObj.quoteLineItems.size()>0){
tenancyContract.First_Line_Item_Unit_Name__c  = quoteObj.quoteLineItems[0].Unit_Name__c;
}*/
                tcList.add(tenancyContract);
            }
        }
        if(tcList.size()>0)
            insert tcList;
        unitIds = new set<Id>();
        for(Tenancy_contract__c tc:tcList){
            system.debug('tc '+ tc );
            system.debug('accountUnits.get(tc.account__c)  '+ accountUnits.get(tc.account__c));
            for(Account_Unit__c accunit:accountUnits.get(tc.account__c)){
                Contract_Line_Item__c cli = new Contract_Line_Item__c();
                cli.Product__c = accunit.Unit__r.Product_Type__c;
                cli.Unit__c = accunit.Unit__c;
                cli.Status__c = 'Draft';
                cli.Contract__c = tc.Id;
                //edited by Nermin
                cli.UnitPrice__c = accunit.unit__r.List_Price__c/accunit.unit__r.Area_in_sq_m__c;
                cli.Quantity__c = accunit.unit__r.Area_in_sq_m__c;
                //cli.ReadOnly__c = false;
                contractList.add(cli);
                unitIds.add(accunit.Unit__c);
            }
        }
        if (contractList.size()>0) {
            insert contractList;
        }
        if(unitIds.size()>0){
            List<Unit__c> unitsList = new List<Unit__c>();
            unitsList = [Select Id, Availability__c from unit__c where id in :unitIds];
            for(unit__c item:unitsList){
                item.Availability__c ='Reserved';
            }
            update unitsList;
        }
    }
    
    Public static void activateTenancyContract(){
        List<Tenancy_Contract__c> contracts = [SELECT Id , Tenancy_Contract__c , Status__c , Quote__c , Activated_by__c , Activated_date__c
                                               ,(SELECT Id, ReadOnly__c, unit__r.Availability__c FROM Contract_Line_Items__r) FROM Tenancy_Contract__c WHERE Account__r.Integration__c = true and Status__c in('Draft', 'Approved') and (Payments_Counter__c >0 or account__r.name like 'Waha%')];  
        List<Contract_line_item__c> updatedCli = new List<Contract_line_item__c>();
        
        for(Tenancy_Contract__c contract:contracts){
            List<Contract_line_item__c> cli = new List<Contract_line_item__c>();
            cli = contract.Contract_Line_Items__r;
            for(Contract_line_item__c cLItem:cli){
                CLItem.ReadOnly__c = true;
            }
            updatedCli.addAll(cli);
            contract.Status__c = 'Active';
            contract.Activated_Date__c = System.today();
            contract.Activated_by__c = userInfo.getUserId();
            System.Approval.lock(contract);            
        }
        if(contracts.size()>0){
            update contracts;
        }
        system.debug('contracts '+ contracts.size());
        if(updatedCli.size()>0){
            update updatedCli;
        }
    }
}