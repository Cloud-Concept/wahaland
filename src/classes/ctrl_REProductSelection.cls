public class ctrl_REProductSelection {
    //Select the Opp Products
    
    //Declare the variables
    public Opportunity opp {get;set;}
    public Id OpportunityId {get;set;}
    public string searchStr {get;set;}
    public Map<String , String> paramMap {get;set;}
    public Id priceBookId {get;set;}
    public List<string> ProductType {get; set;}  
    public Integer resultCount {get;set;}
    public Integer step {get;set;}
    public Integer pageCounter {get;set;}
    public Integer currentPage {get;set;}
    public String qry {get;set;}
    public Integer offset {get;set;}
    public List<Wrapper> searchResult {get;set;}
    public List<Wrapper> selectedItems {get;set;}
    public String x {get;set;}
    public boolean Loader{get;set;}
    private date twoMonths;
    Map<Id, PricebookEntry> pbe;
    public ctrl_REProductSelection() {
        paramMap = new Map<String , String>();
        paramMap = ApexPages.currentPage().getParameters() ;
        Loader = false;
        step = 7 ;
        currentPage = 1 ;
        pageCounter = 0 ;
        offSet = 0 ; 
        searchStr = '' ;
        selectedItems = new List<Wrapper>();
        if(paramMap.containsKey('OpportunityId')) {
            OpportunityId = paramMap.get('OpportunityId') ;
            system.debug(OpportunityId);
            twoMonths = system.today().addMonths(2);
            opp = [select Pricebook2Id , id , Contract_Type__c, Product_Type__C, Term_Commencment_Date__c from Opportunity where id = : opportunityId] ;
            ProductType = New List<String>();
            //ProductType = (opp.Product_Type__C).Replace('Industrial Building', 'Plot').split(';');
            ProductType = opp.Product_Type__C.split(';');
            for(OpportunityLineItem item : [select id , Unit__r.Unit_Name__c, Product2Id , Unit__c , Unit__r.Availability__c , UnitPrice , Quantity from OpportunityLineItem where OpportunityId =: opportunityId])
                selectedItems.add(new Wrapper(item.id , item.Unit__c , item.Product2Id ,  item.Unit__r.Unit_Name__c , item.Unit__r.Availability__c , Double.valueoF(item.UnitPrice) , Double.valueOf(item.UnitPrice) , Double.valueoF(item.Quantity)));
            
            pbe = new Map<Id, PricebookEntry>();
            for(PricebookEntry item : [SELECT Product2Id, id,  Product2.Name FROM PricebookEntry where Product2.Name in :ProductType])
            	pbe.put(item.Product2Id, item);
            system.debug('**'+ pbe);
            searchDetails();
        }
    }
    
    //Paging
    public PageReference first(){
        currentPage = 1 ;
        offset = 0 ;       
        if(!Test.isRunningTest()) searchDetails();
        return null ;
    }
    public PageReference previous(){
        currentPage = currentPage - 1 ;
        offset = (currentPage - 1) * step ;       
        if(!Test.isRunningTest()) searchDetails();
        return null ;
    }
    public PageReference next(){
        currentPage = currentPage + 1 ;
        offset = (currentPage - 1) * step ;       
        if(!Test.isRunningTest()) searchDetails();
        return null ;
    }
    public PageReference last(){ 
        currentPage = pageCounter ;
        offset = (currentPage - 1)  * step ;       
        if(!Test.isRunningTest()) searchDetails();
        return null ;
    }
    
    public PageReference clearSettings(){ 
        currentPage = 1  ;
        offset = 0 ;       
        if(!Test.isRunningTest()) searchDetails();
        return null ;
    }
    public PageReference searchDetails(){ 
        //search the units
        //Avialable units
        //Reserved units under cancellation and Release Unit date < Term Commenement date
        //and the Product name = opp Product Type 
        resultCount = 0 ;
        pageCounter = 0 ;
        if(offset > 2000) offset = 2000 ;
        String filter1 = '' ;
        if(searchStr != '') filter1 = ' and Unit_Name__c like  \'%' + searchStr + '%\' ' ;
        
        String status = ' (Availability__c in (\'Available\') ';
        if(opp.Term_Commencment_Date__c != null){
            status += ' OR ((Current_Tenancy_Contracts__r.Status__c in (\'Under Cancellation\') OR (Current_Tenancy_Contracts__r.Status__c in (\'Active\') and( Current_Tenancy_Contracts__r.ContractExpiryIsEmpty__c = false and Current_Tenancy_Contracts__r.Contract_Expiry_Date__c <= '+string.valueOf(twoMonths)+' ))) and( ReleaseUnitDateIsEmpty__c = false and Availability__c in ( \'Leased\') and Release_Unit_Date__c < '+string.valueOf(opp.Term_Commencment_Date__c)+' )))';
        }
        else status += ')';
        
        string ProductNameFilter = ' and Product_Type__r.Name in( ';
        for(string str:ProductType){
            ProductNameFilter+= '\''+str+'\',';
        }
        ProductNameFilter = ProductNameFilter.substring(0, ProductNameFilter.length()-1);
        String selectedUnitIds = '' ; 
        ProductNameFilter += ' )';
        system.Debug(ProductNameFilter);
        for(Wrapper item : selectedItems){
            if(item.IUId != null){
                if(selectedUnitIds == ''){
                    selectedUnitIds = '(\'' + item.IUId + '\',' ;
                }else{
                    selectedUnitIds += '\'' + item.IUId + '\',' ;
                }
            }
        }
        
        if(selectedUnitIds != '') selectedUnitIds = ' and id not in ' + selectedUnitIds.subString(0 , selectedUnitIds.length() - 1) + ')';
        
        qry = 'select Id, Unit_Name__c, Availability__c, List_Price__c, Product_Type__c, Availability_Flag__c , Area_in_sq_m__c, Client_Account__c from Unit__c where ' + ' ' + status + ' ' + filter1 + ' ' + selectedUnitIds + ' ' + ProductNameFilter + ' '  + ' order by name limit ' + step + ' offset ' + offset ;      
        system.debug(qry);
        searchResult = new List<Wrapper>();
        for(Unit__c item : Database.Query(qry)){
            searchResult.add(new Wrapper(null , item.id , item.Product_Type__c , item.Unit_Name__c , item.Availability__c , Double.valueOF(item.List_Price__c) , Double.valueOF(item.List_Price__c) , Double.valueOF(item.Area_in_sq_m__c)));
        }
        //Prepare Total Number of Pages
        String totalQry = 'select count(id) from Unit__c where ' + ' ' + status + ' ' + filter1 + ' ' + selectedUnitIds + ' ' + ProductNameFilter+ ' '   ;      
        AggregateResult[] result = Database.query(totalQry);
        if(result.size() > 0) resultCount = Integer.valueOf(result[0].get('expr0'));
        
        //Prepare Pagination
        pageCounter = resultCount / step ;
        if (math.mod(resultCount , step) > 0) pageCounter++ ;
        if(pageCounter == 0) currentPage = 0 ;
        if(searchStr <> '' && searchResult.size()==0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Warning, your search criteria meet no units.'));

        }
        return null ;
    }
    
    public PageReference addProduct(){
        //select the 
        loader = true;
        if(selectedItems == null) selectedItems = new List<Wrapper>();
        for(Wrapper item : searchResult){
            if(item.isSelected){
                selectedItems.add(item);
            }
        }
        searchDetails();
        return null ;
    }
    public PageReference updateOpportunity(){
        loader = true;
        Integer count = 0 ;
        Id recordTypeId = [Select Id from RecordType where developerName = 'Waha_Offer_Letter' and SobjectType = 'Opportunity' limit 1].Id;
        for(Wrapper item : selectedItems){
            if(item.isSelected) count++ ;             
        }
        
        if(count == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select at least one Product'));
            return null ;
        }
        
        List<OpportunityLineItem> items = new List<OpportunityLineItem>();
        Map<Id , String> IuMaps = new Map<Id , String>();
        List<Id> toBeRemoved = new List<id>();
        // Updated by Arshad
        
        Set<Id> uIds = new Set<Id>();
        for(Wrapper item : selectedItems){
            if(item.isSelected){
                uIds.add(item.iuId);
            }
        }
        
        
        for(Wrapper item : selectedItems){
            if(item.isSelected){
                if(item.iuAvailability == 'Available'){
                	IuMaps.put(item.iuId , 'Pending Sales'); x =  item.ProductType ;
                }
                else if(item.iuAvailability == 'Leased'){
                	IuMaps.put(item.iuId , 'Leased / Pending Sales'); x =  item.ProductType ;
                }
                if(item.iuArea == null || item.iuArea == 0) item.iuArea = 1 ;
                priceBookId = pbe.get(item.ProductType).Id;
                system.debug('priceBookId ' + priceBookId);
                items.add(new OpportunityLineItem(id = item.lineItemId, ReadOnly__c = true , Name__c = item.iuName, PriceBookEntryId = priceBookId , Unit__c = item.iuId , UnitPrice = item.iuListPrice , Quantity = item.iuArea , OpportunityId = opportunityId));
            }else{
                if(item.lineItemId != null) {
                    if(item.iuAvailability == 'Pending Sales'){
                	IuMaps.put(item.iuId , 'Available'); x =  item.ProductType ;
                }
                else if(item.iuAvailability == 'Leased / Pending Sales'){
                	IuMaps.put(item.iuId , 'Leased'); x =  item.ProductType ;
                }
                    toBeRemoved.add(item.lineItemId);
                }   
            }
        }
        upsert items ;
        opp.StageName='Offer Letter';
        opp.RecordTypeId = recordTypeId;
        update opp;
        //Deleting Old Opportunity Line Items
        List<OpportunityLineItem> toBeRemovedList = [select id , Unit__c from OpportunityLineItem where id in : toBeRemoved] ;
        if(toBeRemovedList.size() > 0){
            for(integer i = 0; i<toBeRemovedList.size(); i++){
                toBeRemovedList[i].ReadOnly__c = false;
            }
            update toBeRemovedList;
            delete toBeRemovedList; 
        }
        
        //Update Inventory Units
        List<Unit__c> ius = new List<Unit__c>();
        for(Id item : IuMaps.KeySet())
            ius.add(new Unit__c(Availability__c = IuMaps.get(item) , id = item));
        
        upsert ius ;
        
        
        // return null ;
        
        PageReference pRef = new PageReference ('/'+opportunityId);
        return pRef.setRedirect(true);
    }
    public PageReference updateOpp(){
        
        List<Opportunity> oppList = [select id , Contract_Type__c  , Pricebook2Id  from Opportunity where id = : opportunityId] ; 
        if(oppList.size() > 0){
            Pricebook2 obj = [Select id , Name From Pricebook2 where isactive = true Limit 1];
            if(oppList[0].Pricebook2Id != null){
                oppList[0].Pricebook2Id = obj.id;
                upsert oppList[0] ;
            }
        }
        return null ;
    }
        
    @TestVisible
    public Class Wrapper{
        public Boolean isSelected {get;set;}
        public Id lineItemId {get;set;}
        public Id iuId {get;set;}
        public String iuName {get;set;}
        public Id productType {get;set;}
        public String iuAvailability {get;set;}
        public double iuListPrice {get;set;}
        public double liUnitPrice {get;set;}
        public double iuArea {get;set;}
        Public double CalculatedPrice{get;set;}
        Public String Name{get;set;}
        
        public Wrapper(id lineItemId , id iuId , id productType , String iuName , String iuAvailability , Double liSalesPrice , Double iuListPrice, Double iuArea ){
            this.lineItemId = lineItemId ;
            this.iuId = iuId ;
            this.productType = productType ;
            this.iuName = iuName ;
            this.iuAvailability = iuAvailability ;
            this.iuListPrice = iuListPrice ;
            this.liUnitPrice = liSalesPrice;
            this.iuArea = iuArea ;  
            this.CalculatedPrice = iuListPrice;
            this.Name = iuName;
            if(this.iuArea != 0){
                If(this.lineItemId == null){
                    this.iuListPrice = this.iuListPrice / this.iuArea ;}
                else{ this.CalculatedPrice = iuListPrice * iuArea;}
            } 
            system.debug('1   '+CalculatedPrice);
            system.debug('2   '+iuListPrice);
            system.debug('3   '+iuArea);
            
            this.isSelected = false ;
            if(LineItemId != null) this.isSelected = true ;
        }
        
    }
    
}