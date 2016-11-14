public class ctrl_TCProductSelection {
    //Select the Opp Products
    
    //Declare the variables
    public Tenancy_Contract__c tc {get;set;}
    public Id TenancyContractId {get;set;}
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
    private Id oldTCId;
    private Date twoMonths;
    public ctrl_TCProductSelection() {
        boolean isOldContract = false;
        paramMap = new Map<String , String>();
        paramMap = ApexPages.currentPage().getParameters() ;
        Loader = false;
        step = 7 ;
        currentPage = 1 ;
        pageCounter = 0 ;
        offSet = 0 ; 
        searchStr = '' ;
        selectedItems = new List<Wrapper>();
        if(paramMap.containsKey('TenancyContractId')) {
            TenancyContractId = paramMap.get('TenancyContractId') ;
            system.debug(TenancyContractId);
            twoMonths = system.today().addMonths(2);
            tc = [select id , Contract_Type__c, Quote__r.Opportunity.Product_Type__C, Renewed_Contract__r.Id, Term_Commencement_Date__c from Tenancy_Contract__c where id = :TenancyContractId] ;
            OldTCId = tc.Renewed_Contract__r.Id;
            ProductType = New List<String>();
            system.debug(tc.Quote__r.Opportunity.Product_Type__C);
            //ProductType = (tc.Quote__r.Opportunity.Product_Type__C).Replace('Industrial Building', 'Plot').split(';');
            ProductType = tc.Quote__r.Opportunity.Product_Type__C.split(';');
            List<Contract_Line_Item__c> cLIList = [select id , Unit__r.Unit_Name__c, Product__c, Product__r.ProductCode , Unit__c , Unit__r.Availability__c , UnitPrice__c , Quantity__c, unit__r.Current_Tenancy_Contracts__c from Contract_Line_Item__c where Contract__c =: TenancyContractId];
            system.debug(cLIList.size());
            for(Contract_Line_Item__c item : cLIList) {
                isOldContract = false;
                if(item.unit__r.Current_Tenancy_Contracts__c == OldTCId)
                    isOldContract = true;
                selectedItems.add(new Wrapper(item.id , item.Unit__c , item.Product__c ,  item.Unit__r.Unit_Name__c , item.Unit__r.Availability__c , 
                                              Double.valueoF(item.UnitPrice__c) , Double.valueOf(item.UnitPrice__c) , Double.valueoF(item.Quantity__c), isOldContract));
             }
            
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
            status += ' OR Current_Tenancy_Contracts__c = \''+OldTCId+'\' ';
        if(tc.Term_Commencement_Date__c != null){
        	status += ' OR ((Current_Tenancy_Contracts__r.Status__c in (\'Under Cancellation\') OR (Current_Tenancy_Contracts__r.Status__c in (\'Active\') and( Current_Tenancy_Contracts__r.ContractExpiryIsEmpty__c = false and Current_Tenancy_Contracts__r.Contract_Expiry_Date__c <= '+string.valueOf(twoMonths)+' ))) and( ReleaseUnitDateIsEmpty__c = false and Availability__c in ( \'Leased\') and Release_Unit_Date__c < '+string.valueOf(tc.Term_Commencement_Date__c)+' )))';
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
        
        qry = 'select Id, Unit_Name__c, Availability__c, List_Price__c, Product_Type__c, Availability_Flag__c , Area_in_sq_m__c, Client_Account__c, Current_Tenancy_Contracts__c from Unit__c where ' + ' ' + status + ' ' + filter1 + ' ' + selectedUnitIds + ' ' + ProductNameFilter + ' '  + ' order by name limit ' + step + ' offset ' + offset ;      
        system.debug(qry);
        searchResult = new List<Wrapper>();
        system.debug('uery(qry) ' + Database.Query(qry));
        for(Unit__c item : Database.Query(qry)){
            boolean isOldContract = false;
            if(item.Current_Tenancy_Contracts__c == OldTCId)
                isOldContract = true;
            searchResult.add(new Wrapper(null , item.id , item.Product_Type__c , item.Unit_Name__c , item.Availability__c , Double.valueOF(item.List_Price__c) , Double.valueOF(item.List_Price__c) , Double.valueOF(item.Area_in_sq_m__c), isOldContract));
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
        Loader = true;
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
        Loader = true;
        Integer count = 0 ;
        for(Wrapper item : selectedItems){
            if(item.isSelected) count++ ;             
        }
        
        if(count == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select at least one Product'));
            return null ;
        }
        
        List<Contract_Line_Item__c> items = new List<Contract_Line_Item__c>();
        Map<Id , String> IuMaps = new Map<Id , String>();
        List<Id> toBeRemoved = new List<id>();
        
        Set<Id> uIds = new Set<Id>();
        for(Wrapper item : selectedItems){
            if(item.isSelected){
                uIds.add(item.iuId);
            }
        }
        
        
        for(Wrapper item : selectedItems){
            if(item.isSelected){
                if(item.iuAvailability == 'Available'){
                        IuMaps.put(item.iuId , 'Reserved'); x =  item.ProductType ;
                }
                else if(item.iuAvailability == 'Leased' && item.isOldContract == false){
                        IuMaps.put(item.iuId , 'Leased / Reserved'); x =  item.ProductType ;
                }
                if(item.iuArea == null || item.iuArea == 0) item.iuArea = 1 ;
                items.add(new Contract_Line_Item__c(id = item.lineItemId, ReadOnly__c = true , Product__c = item.ProductType, status__c='Draft', Unit__c = item.iuId , UnitPrice__C = item.iuListPrice , Quantity__c = item.iuArea , Contract__c = TenancyContractId));
            }else{
                if(item.lineItemId != null) {
                    if(item.iuAvailability == 'Reserved'){
                        IuMaps.put(item.iuId , 'Available'); x =  item.ProductType ;
                }
                else if(item.iuAvailability == 'Leased / Reserved'){
                        IuMaps.put(item.iuId , 'Leased'); x =  item.ProductType ;
                }
                else if(item.iuAvailability == 'Leased'){
                        IuMaps.put(item.iuId , 'Leased'); x =  item.ProductType ;
                }
                    toBeRemoved.add(item.lineItemId);
                }   
            }
        }
        
        upsert items ;
        
        //Deleting Old Opportunity Line Items
        List<Contract_Line_Item__c> toBeRemovedList = [select id , Unit__c, ReadOnly__c from Contract_Line_Item__c where id in : toBeRemoved] ;
        if(toBeRemovedList.size() > 0){
            for(integer i = 0; i<toBeRemovedList.size(); i++){
                toBeRemovedList[i].ReadOnly__c = false;
            }
            update toBeRemovedList;
            delete toBeRemovedList ; 
        }
        
        //Update Inventory Units
        List<Unit__c> ius = new List<Unit__c>();
        for(Id item : IuMaps.KeySet())
            ius.add(new Unit__c(Availability__c = IuMaps.get(item) , id = item));
        
        upsert ius ;
        
        // return null ;
        
        PageReference pRef = new PageReference ('/'+TenancyContractId);
        return pRef.setRedirect(true);
    }
    public PageReference updateOpp(){
        return null ;
    }
    
    @TestVisible
    public Class Wrapper{
        public Boolean isSelected {get;set;}
        public Id lineItemId {get;set;}
        public Id iuId {get;set;}
        public String iuName {get;set;}
        public String productType {get;set;}
        public String iuAvailability {get;set;}
        public double iuListPrice {get;set;}
        public double liUnitPrice {get;set;}
        public double iuArea {get;set;}
        Public double CalculatedPrice{get;set;}
        Public String Name{get;set;}
        public boolean isOldContract{get;set;}
        public Wrapper(id lineItemId , id iuId , id productType , String iuName , String iuAvailability , Double liSalesPrice , Double iuListPrice, Double iuArea, boolean isOldContract ){
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
            this.isOldContract = isOldContract;
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