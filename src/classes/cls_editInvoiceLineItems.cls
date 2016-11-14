public class cls_editInvoiceLineItems {
    //Generate the Tenancy Contract' Invoices.
    public Id TenancyContractId{get;set;}
    private Tenancy_Contract__c currentTC;
    Public List<Tenancy_Contract_Payment__c> Payments{get;set;}
    public Invoice__c invoice{get;set;}
    public list<Invoice_Line_Item__c> invoiceLineItems{get;set;}
    private list<Invoice_Line_Item__c> invoiceOldLineItems;
    public list<paymentWrapper> paymentList{get;set;}
    private Id invoiceId;
    private List<Invoice_Line_Item__c> selectedInvLI;
    
    public cls_editInvoiceLineItems(){
        invoice = new Invoice__c();
        invoiceLineItems = new list<Invoice_Line_Item__c>();
        selectedInvLI = new list<Invoice_Line_Item__c>();
        Payments = new List<Tenancy_Contract_Payment__c>();
        if(ApexPages.currentPage().getParameters().get('InvoiceId') != null){
            invoiceId = ApexPages.currentPage().getParameters().get('InvoiceId');
            invoice = [select Id, Tenancy_Contract__c from invoice__c where Id = :invoiceId];
            system.debug('invoice ' + invoice.Id);
            selectedInvLI = [select Id, Tenancy_Contract_Payment__c from Invoice_Line_Item__c where invoice__c = :invoiceId];
            system.debug('selectedInvLI ' + selectedInvLI);
            TenancyContractId =  invoice.Tenancy_Contract__c;
            currentTC = [Select Id, Account__c, Quote__c, Term_Commencement_Date__c, Lease_Commencement_Date__c, Contract_Duration__c From Tenancy_Contract__c where Id = :TenancyContractId];
            Payments = [select id, Invoice__c, Related_to_Offer_Proposal__c, Related_to_Offer_Proposal__r.Unit__c, Name, Payment_Name__c, Due_Date_To__c, Payment_Amount__c, isSecurityDeposit__c, isServiceCharge__c, YearNumber__c from Tenancy_Contract_Payment__c  where Tenancy_Contract__c = :TenancyContractId and Paid__c = false and (Invoice__c = null or Invoice__c=:invoiceId)];
            //Set the Tenancy Contract Payments Related to this Contract
            setPayments();
        }
    }
    
    public PageReference setPayments(){
        paymentList = new list<paymentWrapper>();
        for(Tenancy_Contract_Payment__c item:Payments){
            paymentList.add(new paymentWrapper(item.Id, item.Related_to_Offer_Proposal__c, item.Name, item.Related_to_Offer_Proposal__r.Unit__c, item.Payment_Name__c, item.Due_Date_To__c, item.Payment_Amount__c, false, item.isSecurityDeposit__c, item.isServiceCharge__c, item.YearNumber__c ));
        }
        for(paymentWrapper pw:paymentList){
            for(Invoice_Line_Item__c InvLI:selectedInvLI){
                if(pw.uId == InvLI.Tenancy_Contract_Payment__c){
                    pw.isSelected = true;
                }
            }
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
        
        if(selectedInvLI.size()>0){
            delete selectedInvLI;
            for(Tenancy_Contract_Payment__c tcpItem:Payments){
                tcpItem.Invoice__c = null;
            }
            
            update Payments;
        }
        
        invId = invoice.Id;
        invoiceLineItems = new List<Invoice_Line_Item__c>();
        pp = [Select Id, Invoice__c from Tenancy_Contract_Payment__c where id in :paymentsIds];
        Integer i = 0;
        string description='';
        string invoiceDescription = '';
        for(paymentWrapper item:selectedPayments){
            if(item.isServiceCharge){
                if(item.YearNumber == '1'){
                    description = 'Basic Service Charge';
                }
                else{
                    description = 'Service Charge';
                }
            }
            else if(item.isSecurityDeposit){
                description ='Security Deposit';
            }
            else{
                description = 'Annual Rent';
            }
            if(!(invoiceDescription.contains(description))){
                invoiceDescription += ', ' + description;
            }
            invoiceLineItems.add(new Invoice_Line_Item__c(Invoice__c = invId, Tenancy_Contract_Payment__c = item.uId, Invoice_Line_Item_Name__c = item.Payment_Name, RC_Unit__c = item.unit, Related_to_Registration__c = currentTC.Account__c, Unit_Price__c = item.Payment_Amount, Amount__c = item.Payment_Amount, Quantity__c = 1, Description__c = description));
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
        PageReference orderPage = new PageReference('/' + InvoiceId);
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