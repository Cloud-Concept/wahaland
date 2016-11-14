public class cls_InvoiceGeneration {
    //Generate the Tenancy Contract' Invoices.
    public Id TenancyContractId{get;set;}
    private Id quoteId;
    private Tenancy_Contract__c currentTC;
    Public List<Tenancy_Contract_Payment__c> Payments{get;set;}
    public integer invoiceYear{get;set;}
    private double contractTerm;
    public Invoice__c invoice{get;set;}
    public list<Invoice_Line_Item__c> invoiceLineItems{get;set;}
    public list<paymentWrapper> paymentList{get;set;}
    private account acc;
    private Id accId;
    private integer invoiceYearCount = 0;
    
    public cls_InvoiceGeneration(){
        
        invoice = new Invoice__c();
        invoiceLineItems = new list<Invoice_Line_Item__c>();
        Payments = new List<Tenancy_Contract_Payment__c>();
        if(ApexPages.currentPage().getParameters().get('TenancyContractId') != null){
            TenancyContractId = ApexPages.currentPage().getParameters().get('TenancyContractId') ;
            currentTC = [Select Id, Account__c, Quote__c, Term_Commencement_Date__c, Lease_Commencement_Date__c, Contract_Duration__c From Tenancy_Contract__c where Id = :TenancyContractId];
            quoteId = currentTC.Quote__c;
            Payments = [select id, Related_to_Offer_Proposal__c, Related_to_Offer_Proposal__r.Unit__c, Name, Payment_Name__c, Due_Date_To__c, Payment_Amount__c, isSecurityDeposit__c, isServiceCharge__c, YearNumber__c from Tenancy_Contract_Payment__c  where Tenancy_Contract__c = :TenancyContractId and Paid__c = false and Invoice__c = null];
            accId = currentTC.Account__c;
            acc = [Select Id, Name From Account where Id = :accId];
            invoiceYear = currentTC.Lease_Commencement_Date__c.year();
            contractTerm = currentTC.Contract_Duration__c;
            //Set the Tenancy Contract Payments Related to this Contract
            setPayments();
        }
    }
    
    public list<selectoption> getContractYears() { 
        // based on Term Commencement Date and the Contract Duration in Years
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption( string.valueOf(invoiceYear) , string.valueOf(invoiceYear))); 
        for(integer i = 1; i< contractTerm; i++){
            options.add(new selectOption( string.valueOf(invoiceYear+i) , string.valueOf(invoiceYear+i)));
        }
        return options;
    }
    
    public PageReference setPayments(){
        paymentList = new list<paymentWrapper>();
        for(Tenancy_Contract_Payment__c item:Payments){
            paymentList.add(new paymentWrapper(item.Id, item.Related_to_Offer_Proposal__c, item.Name, item.Related_to_Offer_Proposal__r.Unit__c, item.Payment_Name__c, item.Due_Date_To__c, item.Payment_Amount__c, false, item.isSecurityDeposit__c, item.isServiceCharge__c, item.YearNumber__c ));
        }
        return null;
    }
    
    public PageReference Generate_Invoice(){
        //Insert the Invoice and Invoice Line Items.
        integer selectedCount = 0;
        string invoiceName;
        Id invId;
        List<Tenancy_Contract_Payment__c> pp = new List<Tenancy_Contract_Payment__c>();
        set<Id> paymentsIds = new set<Id>();
        List<paymentWrapper> selectedPayments = new List<paymentWrapper>();
        for(paymentWrapper item:paymentList){
            if(item.isSelected){ 
                selectedPayments.add(item);
                paymentsIds.add(item.uid);
            }
        }
        selectedCount = selectedPayments.size();
        if(selectedCount == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select at least one Payment'));
            return null ;
        }
        invoice = new invoice__c();
        invoiceYearCount = [Select Count() From Invoice__c where Tenancy_Contract__c    = :TenancyContractId and invoiceYear__c = :invoiceYear];
        invoiceYearCount++;
        string accAppriviations = '';
        List<String> accList = new List<String>();
        accList = acc.Name.trim().split(' ');
        for(string str :accList){
            accAppriviations += str.substring(0, 1);
        }
        invoiceName = 'WL001/'+accAppriviations+'/'+ string.valueOf(invoiceYear)+'/' + string.valueOf(invoiceYearCount);
        invoice.name = invoiceName;
        invoice.Tenancy_Contract__c = TenancyContractId;
        invoice.Received_From__c = accID;
        invoice.Related_To_Quote__c = QuoteId;
        invoice.invoiceYear__c = invoiceYear;
        invoice.Related_To_Quote__c=quoteId;
        insert invoice;
        invId = invoice.Id;
        Invoice__c[] invoices = [SELECT Id from Invoice__c WHERE Id = :invId];      
        Approval.LockResult[] lrList = Approval.locK(invoices, false);
        invoiceLineItems = new List<Invoice_Line_Item__c>();
        pp = [Select Id, Invoice__c from Tenancy_Contract_Payment__c where id in :paymentsIds];
        Integer i = 0;
        string description='';
        string invoiceDescription = '';
        for(paymentWrapper item:selectedPayments){
            if(item.isServiceCharge){
                if(item.YearNumber == '1')
                    description = 'Basic Service Charge';
                else
                    description = 'Service Charge';
            }
            else if(item.isSecurityDeposit)
                description ='Security Deposit';
            else
                description = 'Annual Rent';
            if(!(invoiceDescription.contains(description)))
                invoiceDescription += ', ' + description;
            invoiceLineItems.add(new Invoice_Line_Item__c(Invoice__c = invId, Tenancy_Contract_Payment__c = item.uId, Invoice_Line_Item_Name__c = item.Payment_Name, RC_Unit__c = item.unit, Related_to_Registration__c = accId, Unit_Price__c = item.Payment_Amount, Amount__c = item.Payment_Amount, Quantity__c = 1, Description__c = description));
            pp[i].Invoice__c = invId;
            i++;
        }
        insert invoiceLineItems;
        update pp;
        invoiceDescription = invoiceDescription.substring(2);
        invoice.Description__c = invoiceDescription;
        update invoice;
        set<Id> invoiceLIIds = new set<Id>();
        for(Invoice_Line_Item__c item:invoiceLineItems){
            invoiceLIIds.add(item.Id);
        }
        
        Invoice_Line_Item__c[] invoicesLI = [SELECT Id from Invoice_Line_Item__c WHERE Id = :invoiceLIIds];      
        Approval.LockResult[] lrListInvoiceLI = Approval.locK(invoicesLI, false);
        
        PageReference orderPage = new PageReference('/' + InvId);
        orderPage.setRedirect(true);
        return orderPage;
    }
    
    public PageReference Cancel(){
        //Redirect to the Tenancy Contratc object
        PageReference orderPage = new PageReference('/' + TenancyContractId);
        orderPage.setRedirect(true);
        return orderPage;
    }
    
    @TestVisible
    public class paymentWrapper{
        //helper class to save the Payments data and check if this record is selected or not.
        public Id uId{get;set;}
        public string Name{get;set;}
        public string Payment_Name{get;set;}
        public date Due_Date{get;set;}
        public decimal Payment_Amount{get;set;}
        public boolean isSelected{get;set;}
        public Id unit{get;set;}
        public Id offerPayment;
        public boolean isSecurityDeposit{get;set;}
        public boolean isServiceCharge{get;set;}
        public string YearNumber{get;set;}
        public paymentWrapper(Id uId, Id offerPayment, string Name, Id unit, string Payment_Name, date Due_Date, decimal Payment_Amount, boolean isSelected, boolean isSecurityDeposit, boolean isServiceCharge, string YearNumber){
            this.uId = uId;
            this.offerPayment = offerPayment;
            this.Name = name;
            this.Payment_Name = Payment_Name;
            this.Due_Date = Due_Date;
            this.Payment_Amount = Payment_Amount;
            this.isSelected = isSelected;
            this.unit= unit;
            this.isSecurityDeposit = isSecurityDeposit;
            this.isServiceCharge = isServiceCharge;
            this.YearNumber = YearNumber;
        }
    }
}