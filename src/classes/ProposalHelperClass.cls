global class ProposalHelperClass 
{   
    WebService static string isReadyToCreateNewOfferLetter(string OppID)
    {
        //To Validate if the deal ready to have a new offer letter?
        //Opp line items have units
        //another quote exsits but should be denied and have cancellation reason
        string ErrorMsg='';
        integer ErrorCounter=0;
        try
        {
            Opportunity opp = [select id from Opportunity where id = : OppId] ;
            //validation #1 :Check if Opportunity Line Items has no Unit Selected
            String query1 = 'SELECT count(id) from OpportunityLineItem where OpportunityId=:OppID and Unit__c = null';
            AggregateResult [] results1 = Database.query(query1); 
            if (Integer.valueOf(results1[0].get('expr0')) > 0){
                ErrorCounter++;   
                ErrorMsg+=ErrorCounter+'- You must fill out the Unit for each Product.\n';  
            }
            
            //Validation #4 : Check if we have Not Denied Quotes with no Cancellation Reason               
            String query3 = 'select count(id) from quote where OpportunityId=\''+OppID+'\' and Status != \'Denied\' and Cancellation_Reason__c = null ' ;
            AggregateResult [] results3 = Database.query(query3);
            if (Integer.valueOf(results3[0].get('expr0')) > 0){
                ErrorCounter++; 
                ErrorMsg += ErrorCounter +'- Creating Proposal will cancel the current Proposal. Cancellation reason should be mandatory to cancel the Proposal. Please provide the cancellation reason and try again.\n'; 
            }
            
            if (ErrorCounter > 0){
                return ErrorMsg ;
            }else{
                return 'Success' ;            }
            
            
        }
        catch(Exception e){system.debug(e);return 'An error occured while creating the Proposal. Please contact your administrator.';} 
        
        
    }
    
    public static void ConvertOfferLetterStatus(string OppID)
    {
        //get all Proposals of this opportunity to update their status to denied 
        list<Quote> lstQuote = [select Status , id , (select Unit__c from QuoteLineItems) 
                                from Quote where OpportunityId =: OppID and Status != 'Denied'];
        List<Id> invIds = new List<Id>();
        for(Quote quotesObj :lstQuote)
        {
            quotesObj.Status = 'Denied' ;
            for (QuotELineItem qli : quotesObj.QuoteLineItems)
                invIds.add(qli.Unit__c);
        }
        if(lstQuote.size() > 0) Upsert lstQuote;
        
        
        // Free all Units linked to that Quote through trigger
    }
    
    WebService static string CreateOfferLetters(string OppID) 
    {
        
        //Create savepoint
        Savepoint sp = Database.setSavepoint();
        
        Opportunity oppObj = [select id, Term_Commencment_Date__c, Contract_Type__c  , priceBook2.Name  , Broker_Contact_Person__c , Broker_Account__c,Name,AccountId,Contact_Name__c,Pricebook2Id , Account.Fax , Account.Phone , Account.ShippingStreet , Account.ShippingState , Account.ShippingPostalCode , Account.ShippingCity , Account.ShippingCountry , Account.BillingStreet , Account.BillingState , Account.BillingPostalCode , Account.BillingCountry , Account.BillingCity , Account.name from Opportunity where id=:oppID];
        
        //Before generating a new Proposal, if other Proposals exists we should set their status to denied first
        try{
            ConvertOfferLetterStatus(OppID);
        }catch(Exception e){Database.rollback(sp);  system.debug(e);return 'An error occured while creating the Proposal.' + e.getMessage();}
        
        
        //1-get the Opportunity Line Items to create the Quote Line Items
        list<OpportunityLineItem> lstOppLineItem=[select Unit__r.Booking_Fee__c , PricebookEntry.Name , Unit__r.Unit_Name__c, Unit__r.Availability__c , isOfferLineItemGenerated__c,UnitPrice,ListPrice,Quantity,PricebookEntryId,Unit__c from OpportunityLineItem where OpportunityId=:OppID];
        Integer notAvailableIUCounter = 0 ;
        Integer pendingSalesCount  = 0 ; // Defind for Real Estate Sales Process , Added on 11 Oct 2015 by Ahmed Adel
        Boolean UnitPriceDefined = true ; 
        for (OpportunityLineItem item : lstOppLineItem){
            if(item.UnitPrice == null || item.UnitPrice == 0) UnitPriceDefined = false ;
        }
        if(!UnitPriceDefined){
            Database.rollback(sp);
            return 'One of the Opportunity Line Items has Sales Price as Zero , Please define a value Greater than Zero.' ;
        }
        
        List<OpportunityContactRole> ContactRoleObj = [select ContactId , Contact.MobilePhone , Contact.Email , isPrimary from OpportunityContactRole where OpportunityId = :oppObj.id and isPrimary=true];
        
        //2- Create the Proposal header
        Quote quoteObj = new Quote(); 
        quoteObj.Khalifa_Fund__c = false;
        quoteObj.Broker_Contact_Person__c = oppObj.Broker_Contact_Person__c ;
        quoteObj.Broker_Account__c = oppObj.Broker_Account__c ;
        quoteObj.Term_Commencment_Date__c = oppObj.Term_Commencment_Date__c;
        quoteObj.Number_of_Years_for_Service_Charges__c = 0 ;
        quoteObj.Name=oppObj.Name;  
        quoteObj.Contract_Duration_Year_Month__c = '0' ;
        quoteObj.OpportunityId = OppID;
        quoteObj.Status = 'Draft';
        quoteObj.Pricebook2Id = oppObj.Pricebook2Id;        
        quoteObj.BillingName = oppObj.Account.Name;
        quoteObj.BillingCity = oppObj.Account.BillingCity;
        quoteObj.BillingCountry = oppObj.Account.BillingCountry;
        quoteObj.BillingPostalCode = oppObj.Account.BillingPostalCode;
        quoteObj.BillingState = oppObj.Account.BillingState;
        quoteObj.BillingStreet = oppObj.Account.BillingStreet;
        quoteObj.ShippingName = oppObj.Account.Name;
        quoteObj.ShippingCountry = oppObj.Account.ShippingCountry;
        quoteObj.ShippingCity = oppObj.Account.ShippingCity;
        quoteObj.ShippingPostalCode = oppObj.Account.ShippingPostalCode;
        quoteObj.ShippingState = oppObj.Account.ShippingState;
        quoteObj.ShippingStreet = oppObj.Account.ShippingStreet;
        quoteObj.Phone = oppObj.Account.Phone;
        quoteObj.Fax = oppObj.Account.Fax;
        if(ContactRoleObj.size() > 0){
            quoteObj.ContactId = ContactRoleObj[0].Contact.id; 
            quoteObj.Email = ContactRoleObj[0].Contact.Email; 
        }  
        
        List<Id> priceBookIdsList = new List<ID>();  
        for(OpportunityLineItem item :lstOppLineItem)
            priceBookIdsList.add(item.PricebookEntryId);
        
        
        Map<ID , PricebookEntry> oppLineItem_PriceBook_Map = new Map<ID , PricebookEntry>(); 
        for(PricebookEntry item : [select IsActive  , name , id From PricebookEntry where id in : priceBookIdsList]){
            oppLineItem_PriceBook_Map.put(item.id , item);
        }
        
        //capture list of Units
        List<Id> pendingSalesIUIds = new List<Id>();
        
        for(OpportunityLineItem item :lstOppLineItem)
        {   
            pendingSalesIUIds.add(item.Unit__c);
        }   
        
        try{       
            insert quoteObj;
        }catch(Exception e){Database.rollback(sp);  system.debug(e);return 'An error occured while creating the Proposal. Please contact your administrator.';}
        
        
        list<QuoteLineItem> lstQuoteLineItems=new list<QuoteLineItem>();    
        List<id> unitIds = new List<Id>();
        for(OpportunityLineItem item :lstOppLineItem)
        {
            unitIds.add(item.Unit__c);
            //Create The Proposal Line Items
            QuoteLineItem qliObj = new QuoteLineItem(Unit_Name__c = item.Unit__r.Unit_Name__c, ReadOnly__c = true, Base_Service_Charges__c = 0 , Quantity = item.Quantity , QuoteId = quoteObj.id , PricebookEntryId  = item.PricebookEntryId , Unit__c = item.Unit__c);
            Double newRate = item.UnitPrice ;
            qliObj.Rent_Price__c = newRate ;
            qliObj.UnitPrice = newRate ;
            qliObj.Base_Service_Charges__c = 0 ; 
            if (oppLineItem_PriceBook_Map.get(item.PricebookEntryId).IsActive == false){
                Database.rollback(sp);
                return 'One of the used Products is not Active , Please Activate all used Products or Contact your Administrator' ;
            }
            
            lstQuoteLineItems.add(qliObj);
        } 
        // set the units to be related to this offer letter
        if(unitIds.size()>0){
            List<Unit__c> ius = new List<Unit__c>();
            ius = [Select id, Reserved_by_Offer_Letter__c From Unit__c where id in:unitIds ];
            integer i = 0;
            for(Unit__c unit : ius) {
                ius[i].Reserved_by_Offer_Letter__c = quoteObj.Id;
                i++;
            }
            update ius;
        }
        if(pendingSalesIUIds.size() > 0){
            List<Unit__c> ius = new List<Unit__c>();
            ius = [Select id, Availability__c From Unit__c where id in:pendingSalesIUIds ];
            integer i = 0;
            for(Unit__c unit : ius) {
                ius[i].Availability__c = 'Pending Sales';
            }
            if(ius.size()>0)
                update ius ;   
        }
        try
        {
            
            upsert lstQuoteLineItems;
            
            
            return 'Proposal Created Successfully.'+ quoteObj.id;
        }
        //if there is error discard the whole transaction
        catch(Exception e){system.debug(e);Database.rollback(sp);return 'Invalid Unit Selected for the product';}
    }
    
    WebService static string checkSubmitForApproval(Id QuoteId){
        try{
            Quote q = [Select Id, SubmitForApproval__c From Quote where Id = :QuoteId];
            q.SubmitForApproval__c = true;
            update q;
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    WebService static string checkAgreementGenerated(Id QuoteId){
        try{
            Quote q = [Select Id, AgreementGenerated__c From Quote where Id = :QuoteId];
            q.AgreementGenerated__c = true;
            update q;
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
}